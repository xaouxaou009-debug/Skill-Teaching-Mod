-- Xaou Jianghu Relations standalone mod.

local mod = GameMain:GetMod("Xaou_JianghuRelations")

local function xjr_show(text, title)
    local shown = false
    pcall(function()
        CS.Wnd_Message.Show(tostring(text), 1, nil, true, tostring(title or "Xaou"), 0, 0, "")
        shown = true
    end)
    if not shown then pcall(function() world:ShowMsgBox(tostring(text)) end) end
end

function Xaou_OpenHeartBySeed(seed, addFavor)
    local ok, err = pcall(function()
        if seed == nil then error("seed ว่าง") end
        seed = tonumber(seed) or seed
        local mgr = JianghuMgr or CS.XiaWorld.JianghuMgr.Instance
        local data = mgr:GetKnowNpcData(seed)
        if data == nil then
            mgr:UnLockJiangHuNpc(seed)
            data = mgr:GetKnowNpcData(seed)
            if data == nil then data = mgr:GetJHNpcDataByRandomSeed(seed) end
            if data == nil then data = mgr:GetJHNpcDataBySeed(seed) end
        end
        if data == nil then error("หา/สร้างข้อมูล NPC ไม่สำเร็จ") end
        pcall(function() data.Vigilance = 0 end)
        pcall(function() data.hlock = 1 end)
        if addFavor == true then
            pcall(function() data.favour = 100 end)
            pcall(function() data.Favour = 100 end)
            pcall(function() data.Favor = 100 end)
        end
    end)
    if ok then
        xjr_show(addFavor and "เปิดใจและเพิ่มความสัมพันธ์สำเร็จ" or "เปิดใจสำเร็จ", "Xaou NPC สำนักอื่น")
        return true
    end
    xjr_show("ดำเนินการไม่สำเร็จ\n" .. tostring(err), "Xaou NPC สำนักอื่น")
    return false
end

function Xaou_JianghuRelations_Open()
    if Xaou_OpenJianghuNpcWindow == nil then
        xjr_show("ไม่พบหน้าต่าง JianghuNpcWindow\nกรุณาตรวจไฟล์ UI ของม็อด", "Xaou NPC สำนักอื่น")
        return false
    end
    local ok, result = pcall(Xaou_OpenJianghuNpcWindow)
    if not ok or result == false then
        xjr_show("เปิดหน้าต่างไม่สำเร็จ\n" .. tostring(result), "Xaou NPC สำนักอื่น")
        return false
    end
    return true
end

function mod:AddButtonToNpc(npc)
    if npc == nil or npc.AddBtnData == nil then return end
    pcall(function() npc:RemoveBtnData("NPC สำนักอื่น") end)
    pcall(function()
        npc:AddBtnData(
            "NPC สำนักอื่น",
            "res/Sprs/ui/icon_haogan01",
            "Xaou_JianghuRelations_Open()",
            "เปิดหน้าต่างจัดการความสัมพันธ์ NPC สำนักอื่นของ Xaou",
            nil
        )
    end)
end

function mod:OnEnter()
    local events = GameMain:GetMod("_Event")
    if events == nil then return end
    events:RegisterEvent(g_emEvent.SelectNpc, function(evt, npc, objs)
        self:AddButtonToNpc(npc)
    end, self)
end

function mod:OnLeave()
    local events = GameMain:GetMod("_Event", true)
    if events ~= nil then pcall(function() events:UnRegisterEvent(g_emEvent.SelectNpc, self) end) end
    pcall(function() Xaou_CloseJianghuNpcWindow() end)
end
