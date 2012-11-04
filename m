Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 72C076B004D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:07 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3650067pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:07 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 05/13] ACPIHP: implement utility interfaces to support system device hotplug
Date: Sun,  4 Nov 2012 20:50:07 +0800
Message-Id: <1352033415-5606-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

This patch implements some utility interfaces to support ACPI based
system device hotplug.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/hotplug/core.c |   77 +++++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_hotplug.h |    9 +++++
 2 files changed, 86 insertions(+)

diff --git a/drivers/acpi/hotplug/core.c b/drivers/acpi/hotplug/core.c
index bad8e99..139b9c2 100644
--- a/drivers/acpi/hotplug/core.c
+++ b/drivers/acpi/hotplug/core.c
@@ -591,6 +591,83 @@ int acpihp_remove_device_list(struct klist *dev_list)
 }
 EXPORT_SYMBOL_GPL(acpihp_remove_device_list);
 
+bool acpihp_slot_present(struct acpihp_slot *slot)
+{
+	acpi_status status;
+	unsigned long long sta;
+
+	status = acpihp_slot_get_status(slot, &sta);
+	if (ACPI_FAILURE(status)) {
+		ACPIHP_SLOT_WARN(slot, "fails to get status.\n");
+		return false;
+	}
+
+	return !!(sta & ACPI_STA_DEVICE_PRESENT);
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_present);
+
+bool acpihp_slot_powered(struct acpihp_slot *slot)
+{
+	acpi_status status;
+	unsigned long long sta;
+
+	/* hotplug slot must implement _STA method */
+	status = acpihp_slot_get_status(slot, &sta);
+	if (ACPI_FAILURE(status)) {
+		ACPIHP_SLOT_WARN(slot, "fails to get status.\n");
+		return false;
+	}
+
+	if ((sta & ACPI_STA_DEVICE_PRESENT) &&
+	    ((sta & ACPI_STA_DEVICE_ENABLED) ||
+	    (sta & ACPI_STA_DEVICE_FUNCTIONING)))
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_powered);
+
+void acpihp_slot_set_flag(struct acpihp_slot *slot, u32 flags)
+{
+	mutex_lock(&slot->slot_mutex);
+	slot->flags |= flags;
+	mutex_unlock(&slot->slot_mutex);
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_set_flag);
+
+void acpihp_slot_clear_flag(struct acpihp_slot *slot, u32 flags)
+{
+	mutex_lock(&slot->slot_mutex);
+	slot->flags &= ~flags;
+	mutex_unlock(&slot->slot_mutex);
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_clear_flag);
+
+u32 acpihp_slot_get_flag(struct acpihp_slot *slot, u32 flags)
+{
+	mutex_lock(&slot->slot_mutex);
+	flags &= slot->flags;
+	mutex_unlock(&slot->slot_mutex);
+
+	return flags;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_get_flag);
+
+void acpihp_slot_change_state(struct acpihp_slot *slot,
+			      enum acpihp_slot_state state)
+{
+	if (state < ACPIHP_SLOT_STATE_UNKNOWN ||
+	    state > ACPIHP_SLOT_STATE_MAX) {
+		ACPIHP_SLOT_WARN(slot, "slot state %d is invalid.\n", state);
+		BUG_ON(state);
+	}
+
+	mutex_lock(&slot->slot_mutex);
+	slot->state = state;
+	mutex_unlock(&slot->slot_mutex);
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_change_state);
+
 /* SYSFS interfaces */
 static ssize_t acpihp_slot_object_show(struct device *d,
 		struct device_attribute *attr, char *buf)
diff --git a/include/acpi/acpi_hotplug.h b/include/acpi/acpi_hotplug.h
index 9d466ea..3297f51 100644
--- a/include/acpi/acpi_hotplug.h
+++ b/include/acpi/acpi_hotplug.h
@@ -295,6 +295,15 @@ extern int acpihp_slot_remove_device(struct acpihp_slot *slot,
 				     struct device *dev);
 extern int acpihp_remove_device_list(struct klist *dev_list);
 
+/* Utility Interfaces */
+extern bool acpihp_slot_present(struct acpihp_slot *slot);
+extern bool acpihp_slot_powered(struct acpihp_slot *slot);
+extern void acpihp_slot_set_flag(struct acpihp_slot *slot, u32 flags);
+extern void acpihp_slot_clear_flag(struct acpihp_slot *slot, u32 flags);
+extern u32 acpihp_slot_get_flag(struct acpihp_slot *slot, u32 flags);
+extern void acpihp_slot_change_state(struct acpihp_slot *slot,
+				     enum acpihp_slot_state state);
+
 extern int acpihp_debug;
 
 #define ACPIHP_WARN(fmt, ...) \
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
