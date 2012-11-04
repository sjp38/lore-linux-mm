Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4494A6B0068
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:52:14 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2498174dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:52:13 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 13/13] ACPIHP: handle ACPI device hotplug events
Date: Sun,  4 Nov 2012 20:50:15 +0800
Message-Id: <1352033415-5606-14-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Implement an event handler for ACPI system device hotplug events.
The handler will relay hotplug events to userspace helper if it's
configured to do so. Otherwise it will queue the hotplug event
onto kacpi_hotplug_wq, which will then invoke acpihp_drv_change_state()
to handle the hotplug event.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/hotplug/Makefile     |    1 +
 drivers/acpi/hotplug/acpihp_drv.h |    2 +
 drivers/acpi/hotplug/drv_main.c   |   11 +--
 drivers/acpi/hotplug/event.c      |  163 +++++++++++++++++++++++++++++++++++++
 4 files changed, 168 insertions(+), 9 deletions(-)
 create mode 100644 drivers/acpi/hotplug/event.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 57e348a..640a625 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -17,3 +17,4 @@ acpihp_drv-y					+= cancel.o
 acpihp_drv-y					+= configure.o
 acpihp_drv-y					+= state_machine.o
 acpihp_drv-y					+= sysfs.o
+acpihp_drv-y					+= event.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
index 2ec2547..aa64c91 100644
--- a/drivers/acpi/hotplug/acpihp_drv.h
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -95,4 +95,6 @@ int acpihp_drv_change_state(struct acpihp_slot *slot, enum acpihp_drv_cmd cmd);
 int acpihp_drv_create_sysfs(struct acpihp_slot *slot);
 void acpihp_drv_remove_sysfs(struct acpihp_slot *slot);
 
+void acpihp_drv_handle_event(acpi_handle handle, u32 event, void *context);
+
 #endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/drv_main.c b/drivers/acpi/hotplug/drv_main.c
index bd5c97c..1935357 100644
--- a/drivers/acpi/hotplug/drv_main.c
+++ b/drivers/acpi/hotplug/drv_main.c
@@ -207,19 +207,12 @@ static void acpihp_drv_remove_devices(struct acpihp_slot *slot)
 		acpihp_remove_device_list(&slot->dev_lists[type]);
 }
 
-/* Handle ACPI device hotplug notifications */
-static void acpihp_drv_event_handler(acpi_handle handle, u32 event,
-				     void *context)
-{
-	/* TODO: handle ACPI hotplug events */
-}
-
 static acpi_status acpihp_drv_install_handler(struct acpihp_slot *slot)
 {
 	acpi_status status;
 
 	status = acpi_install_notify_handler(slot->handle, ACPI_SYSTEM_NOTIFY,
-					     acpihp_drv_event_handler, slot);
+					     &acpihp_drv_handle_event, slot);
 	ACPIHP_SLOT_DEBUG(slot, "%s to install event handler.\n",
 			  ACPI_SUCCESS(status) ? "succeeds" : "fails");
 
@@ -231,7 +224,7 @@ static void acpihp_drv_uninstall_handler(struct acpihp_slot *slot)
 	acpi_status status;
 
 	status = acpi_remove_notify_handler(slot->handle, ACPI_SYSTEM_NOTIFY,
-					    acpihp_drv_event_handler);
+					    &acpihp_drv_handle_event);
 	ACPIHP_SLOT_DEBUG(slot, "%s to uninstall event handler.\n",
 			  ACPI_SUCCESS(status) ? "succeeds" : "fails");
 }
diff --git a/drivers/acpi/hotplug/event.c b/drivers/acpi/hotplug/event.c
new file mode 100644
index 0000000..a401b10
--- /dev/null
+++ b/drivers/acpi/hotplug/event.c
@@ -0,0 +1,163 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ *
+ * This file is based on pci_root_hp.c from Yinghai Lu <yinghai@kernel.org>
+ * and modified by Jiang Liu <jiang.liu@huawei.com>
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/acpi.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+static bool acpihp_notify_userspace;
+module_param_named(notify_userspace, acpihp_notify_userspace, bool,
+		   S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(notify_userspace, "relay hotplug event to userspace helper");
+
+struct acpihp_hotplug_work {
+	u32 event;
+	struct acpihp_slot *slot;
+	struct acpihp_slot_drv *data;
+	struct work_struct work;
+	struct module *owner;
+};
+
+/*
+ * Queue the event handler onto the kacpi_hotplug_wq, otherwise it may
+ * cause deadlock.
+ */
+static int acpihp_alloc_hotplug_work(struct acpihp_slot *slot,
+				     struct acpihp_slot_drv *data, u32 event,
+				     void (*func)(struct work_struct *work))
+{
+	int ret = -ENOMEM;
+	struct acpihp_hotplug_work *hp_work;
+
+	hp_work = kzalloc(sizeof(*hp_work), GFP_KERNEL);
+	if (hp_work) {
+		hp_work->slot = slot;
+		hp_work->data = data;
+		hp_work->event = event;
+		hp_work->owner = THIS_MODULE;
+		__module_get(hp_work->owner);
+
+		INIT_WORK(&hp_work->work, func);
+		if (queue_work(kacpi_hotplug_wq, &hp_work->work)) {
+			ret = 0;
+		} else {
+			module_put(hp_work->owner);
+			kfree(hp_work);
+		}
+	}
+
+	return ret;
+}
+
+static void acpihp_drv_event_handler(struct work_struct *work)
+{
+	u32 event;
+	struct acpihp_slot *slot;
+	struct acpihp_slot_drv *data;
+	struct acpihp_hotplug_work *hp_work;
+	enum acpihp_drv_cmd cmd = ACPIHP_DRV_CMD_NOOP;
+
+	hp_work = container_of(work, struct acpihp_hotplug_work, work);
+	slot = hp_work->slot;
+	data = hp_work->data;
+	event = hp_work->event;
+
+	switch (event) {
+	case ACPI_NOTIFY_BUS_CHECK:
+		/* bus enumerate */
+		ACPIHP_SLOT_DEBUG(slot, "Bus check notification.\n");
+		cmd = ACPIHP_DRV_CMD_CONFIGURE;
+		break;
+
+	case ACPI_NOTIFY_DEVICE_CHECK:
+		/* device check */
+		ACPIHP_SLOT_DEBUG(slot, "Device check notification.\n");
+		cmd = ACPIHP_DRV_CMD_CONFIGURE;
+		break;
+
+	case ACPI_NOTIFY_EJECT_REQUEST:
+		/* request device eject */
+		ACPIHP_SLOT_DEBUG(slot, "Device eject notification.\n");
+		cmd = ACPIHP_DRV_CMD_POWEROFF;
+		break;
+
+	default:
+		BUG_ON(event);
+		break;
+	}
+
+	if (acpihp_drv_change_state(slot, cmd))
+		ACPIHP_SLOT_WARN(slot,
+			"fails to handle hotplug event 0x%x.\n", event);
+
+	module_put(hp_work->owner);
+	kfree(hp_work);
+}
+
+void acpihp_drv_handle_event(acpi_handle handle, u32 event, void *context)
+{
+	int ret;
+	struct acpihp_slot *slot = context;
+	struct acpihp_slot_drv *data = NULL;
+	char objname[64];
+	struct acpi_buffer buffer = { .length = sizeof(objname),
+				      .pointer = objname };
+
+	acpi_get_name(handle, ACPI_FULL_PATHNAME, &buffer);
+	if (event != ACPI_NOTIFY_BUS_CHECK &&
+	    event != ACPI_NOTIFY_DEVICE_CHECK &&
+	    event != ACPI_NOTIFY_EJECT_REQUEST) {
+		ACPIHP_DEBUG("unsupported system event type 0x%x for %s.\n",
+			     event, objname);
+		return;
+	}
+
+	acpihp_drv_get_data(slot, &data);
+	BUG_ON(data == NULL);
+
+	/*
+	 * Send hotplug events to userspace helper, so they could
+	 * be handled more flexibly.
+	 */
+	if (acpihp_notify_userspace) {
+		ret = acpi_bus_generate_netlink_event("LNXSLOT", slot->name,
+						      event, 0);
+		if (ret)
+			ACPIHP_SLOT_WARN(slot,
+				"fails to send hotplug event to userspace.\n");
+		return;
+	}
+
+	/* Queue event onto kacpi_hotplug_wq */
+	if (acpihp_alloc_hotplug_work(slot, data, event,
+				      acpihp_drv_event_handler))
+		ACPIHP_WARN("fails to queue hotplug event 0x%x for %s.\n",
+			    event, objname);
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
