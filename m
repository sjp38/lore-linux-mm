Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 678796B006C
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:00 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3650067pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:00 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 04/13] ACPIHP: provide interfaces to manage driver data associated with hotplug slots
Date: Sun,  4 Nov 2012 20:50:06 +0800
Message-Id: <1352033415-5606-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

This patch implements interfaces to manage driver data associated with
ACPI hotplug slots.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
---
 drivers/acpi/hotplug/core.c |   88 +++++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_hotplug.h |    7 ++++
 2 files changed, 95 insertions(+)

diff --git a/drivers/acpi/hotplug/core.c b/drivers/acpi/hotplug/core.c
index 7ef8f9b..bad8e99 100644
--- a/drivers/acpi/hotplug/core.c
+++ b/drivers/acpi/hotplug/core.c
@@ -35,9 +35,16 @@
 #include <acpi/acpi_hotplug.h>
 #include "acpihp.h"
 
+struct acpihp_drv_data {
+	struct list_head		node;
+	struct class_interface		*key;
+	void				*data;
+};
+
 #define to_acpihp_slot(d) container_of(d, struct acpihp_slot, dev)
 
 static DEFINE_MUTEX(acpihp_mutex);
+static DEFINE_MUTEX(acpihp_drvdata_mutex);
 static int acpihp_class_count;
 static struct kset *acpihp_slot_kset;
 
@@ -355,6 +362,87 @@ char *acpihp_get_slot_type_name(enum acpihp_slot_type type)
 }
 EXPORT_SYMBOL_GPL(acpihp_get_slot_type_name);
 
+int acpihp_slot_attach_drv_data(struct acpihp_slot *slot,
+				struct class_interface *drv, void *data)
+{
+	struct acpihp_drv_data *dp, *cp;
+
+	if (slot == NULL || drv == NULL) {
+		ACPIHP_DEBUG("invalid parameters.\n");
+		return -EINVAL;
+	}
+
+	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
+	if (dp == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&dp->node);
+	dp->key = drv;
+	dp->data = data;
+
+	mutex_lock(&acpihp_drvdata_mutex);
+	list_for_each_entry(cp, &slot->drvdata_list, node)
+		if (cp->key == drv) {
+			mutex_unlock(&acpihp_drvdata_mutex);
+			kfree(dp);
+			return -EEXIST;
+		}
+	list_add(&dp->node, &slot->drvdata_list);
+	mutex_unlock(&acpihp_drvdata_mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_attach_drv_data);
+
+int acpihp_slot_detach_drv_data(struct acpihp_slot *slot,
+				struct class_interface *drv, void **data)
+{
+	struct acpihp_drv_data *cp;
+
+	if (slot == NULL || drv == NULL || data == NULL) {
+		ACPIHP_DEBUG("invalid parameters.\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&acpihp_drvdata_mutex);
+	list_for_each_entry(cp, &slot->drvdata_list, node)
+		if (cp->key == drv) {
+			list_del(&cp->node);
+			*data = cp->data;
+			mutex_unlock(&acpihp_drvdata_mutex);
+			kfree(cp);
+			return 0;
+		}
+	mutex_unlock(&acpihp_drvdata_mutex);
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_detach_drv_data);
+
+int acpihp_slot_get_drv_data(struct acpihp_slot *slot,
+			     struct class_interface *drv, void **data)
+{
+	int ret = -ENOENT;
+	struct acpihp_drv_data *cp;
+
+	if (slot == NULL || drv == NULL || data == NULL) {
+		ACPIHP_DEBUG("invalid parameters.\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&acpihp_drvdata_mutex);
+	list_for_each_entry(cp, &slot->drvdata_list, node)
+		if (cp->key == drv) {
+			*data = cp->data;
+			ret = 0;
+			break;
+		}
+	mutex_unlock(&acpihp_drvdata_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_get_drv_data);
+
 acpi_status acpihp_slot_get_status(struct acpihp_slot *slot, u64 *status)
 {
 	acpi_status rc;
diff --git a/include/acpi/acpi_hotplug.h b/include/acpi/acpi_hotplug.h
index 35f15a8..9d466ea 100644
--- a/include/acpi/acpi_hotplug.h
+++ b/include/acpi/acpi_hotplug.h
@@ -264,6 +264,13 @@ extern acpi_status acpihp_slot_get_status(struct acpihp_slot *slot,
 extern acpi_status acpihp_slot_poweron(struct acpihp_slot *slot);
 extern acpi_status acpihp_slot_poweroff(struct acpihp_slot *slot);
 
+extern int acpihp_slot_attach_drv_data(struct acpihp_slot *slot,
+			struct class_interface *drv, void *data);
+extern int acpihp_slot_detach_drv_data(struct acpihp_slot *slot,
+			struct class_interface *drv, void **data);
+extern int acpihp_slot_get_drv_data(struct acpihp_slot *slot,
+			struct class_interface *drv, void **data);
+
 /*
  * Scan and create ACPI device objects for devices attached to the handle,
  * but don't cross the hotplug slot boundary.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
