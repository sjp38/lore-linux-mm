Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id AE09C6B006E
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:22 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3667867pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:22 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 07/13] ACPIHP: analyse dependencies among ACPI hotplug slots
Date: Sun,  4 Nov 2012 20:50:09 +0800
Message-Id: <1352033415-5606-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Due to hardware constraints, an ACPI hotplug slot may have dependencies
on other ACPI hotplug slots. For example, if a hotpluggable memory board
is connected to a hotpluggble physical processor, the physical processor
must be powered on before powering the memory board on.

According to physical and device tree topology constraints, we need to
consider following dependency relationships:
1) The parent slot must be powered on before powering a child slot on.
2) All child slots must be powered off before powering a parent slot off.
3) All devices in a slot's _EDL list must be powered off before powering
   a slot off.
4) The parent ACPI device topology must be created before creating ACPI
   devices for devices connecting to a child slot
5) All ACPI devices connecting to child slots must be destroyed before
   destroying ACPI device topology for a parent slot.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/hotplug/Makefile     |    1 +
 drivers/acpi/hotplug/acpihp_drv.h |   27 ++++
 drivers/acpi/hotplug/dependency.c |  245 +++++++++++++++++++++++++++++++++++++
 3 files changed, 273 insertions(+)
 create mode 100644 drivers/acpi/hotplug/dependency.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 6257047..bfb677f 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -12,3 +12,4 @@ acpihp_slot-$(CONFIG_ACPI_HOTPLUG_SLOT_FAKE)	+= slot_fake.o
 
 obj-$(CONFIG_ACPI_HOTPLUG_DRIVER)		+= acpihp_drv.o
 acpihp_drv-y					= drv_main.o
+acpihp_drv-y					+= dependency.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
index 769ee74..32ea054 100644
--- a/drivers/acpi/hotplug/acpihp_drv.h
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -25,14 +25,41 @@
 #ifndef	__ACPIHP_DRV_H__
 #define	__ACPIHP_DRV_H__
 
+/* Commands to drive hotplug slot state machine */
+enum acpihp_drv_cmd {
+	ACPIHP_DRV_CMD_NOOP = 0,
+	ACPIHP_DRV_CMD_POWERON = 0x1,
+	ACPIHP_DRV_CMD_CONNECT = 0x2,
+	ACPIHP_DRV_CMD_CONFIGURE = 0x4,
+	ACPIHP_DRV_CMD_UNCONFIGURE = 0x8,
+	ACPIHP_DRV_CMD_DISCONNECT = 0x10,
+	ACPIHP_DRV_CMD_POWEROFF = 0x20,
+	ACPIHP_DRV_CMD_CANCEL = 0x40,
+	ACPIHP_DRV_CMD_MAX
+};
+
 struct acpihp_slot_drv {
 	struct mutex		op_mutex;
 };
 
+struct acpihp_slot_dependency {
+	struct list_head		node;
+	struct acpihp_slot		*slot;
+	u32				opcodes;
+};
+
 void acpihp_drv_get_data(struct acpihp_slot *slot,
 			 struct acpihp_slot_drv **data);
 int acpihp_drv_enumerate_devices(struct acpihp_slot *slot);
 void acpihp_drv_update_slot_state(struct acpihp_slot *slot);
 int acpihp_drv_update_slot_status(struct acpihp_slot *slot);
 
+int acpihp_drv_add_slot_to_dependency_list(struct acpihp_slot *slot,
+					   struct list_head *slot_list);
+void acpihp_drv_destroy_dependency_list(struct list_head *slot_list);
+int acpihp_drv_filter_dependency_list(struct list_head *old_head,
+		struct list_head *new_head, u32 opcode);
+int acpihp_drv_generate_dependency_list(struct acpihp_slot *slot,
+		struct list_head *slot_list, enum acpihp_drv_cmd cmd);
+
 #endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/dependency.c b/drivers/acpi/hotplug/dependency.c
new file mode 100644
index 0000000..c2992f4
--- /dev/null
+++ b/drivers/acpi/hotplug/dependency.c
@@ -0,0 +1,245 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ * Copyright (C) 2012 Hanjun Guo <guohanjun@huawei.com>
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
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/acpi.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+#define	ACPI_METHOD_NAME__EDL	"_EDL"
+
+/*
+ * Insert a slot onto the dependency list in FILO order.
+ * Caller needs to protect from concurrent accesses to the dependency list.
+ */
+int acpihp_drv_add_slot_to_dependency_list(struct acpihp_slot *slot,
+					   struct list_head *dep_list)
+{
+	struct acpihp_slot_dependency *dep;
+
+	/*
+	 * A dependent slot may be encountered when both analyzing the array
+	 * returned by _EDL method and walking ACPI namespace topology.
+	 * Should we move the slot to the list head? May need more work
+	 * here on platforms with complex topology.
+	 */
+	list_for_each_entry(dep, dep_list, node)
+		if (dep->slot == slot)
+			return 0;
+
+	dep = kzalloc(sizeof(*dep), GFP_KERNEL);
+	if (!dep) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to allocate memory.\n");
+		return -ENOMEM;
+	}
+
+	dep->slot = slot;
+	list_add(&dep->node, dep_list);
+
+	return 0;
+}
+
+static int acpihp_drv_get_online_dependency(struct acpihp_slot *slot,
+					    struct list_head *dep_list)
+{
+	int ret = 0;
+	struct acpihp_slot *temp;
+
+	/*
+	 * When enabling a hotplug slot, all its ancestors must be enabled
+	 * first.
+	 */
+	for (temp = slot; temp && ret == 0; temp = temp->parent)
+		ret = acpihp_drv_add_slot_to_dependency_list(temp, dep_list);
+
+	return ret;
+}
+
+/*
+ * Analyze dependency relationships by evaulating ACPI _EDL method
+ * when disabling a hotplug slot.
+ */
+static int acpihp_drv_for_each_edl(struct acpihp_slot *slot, void *argp,
+	int(*cb)(struct device *dev, void *argp))
+{
+	int i;
+	acpi_status rc;
+	struct acpi_buffer buf;
+	union acpi_object *obj, *elem;
+	struct acpihp_slot *tmp;
+
+	buf.length = ACPI_ALLOCATE_BUFFER;
+	rc = acpi_evaluate_object_typed(slot->handle, ACPI_METHOD_NAME__EDL,
+					NULL, &buf, ACPI_TYPE_PACKAGE);
+	if (rc == AE_NOT_FOUND) {
+		/* ACPI _EDL method is optional. */
+		return 0;
+	} else if (ACPI_FAILURE(rc)) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to evaluate _EDL.\n");
+		return -EINVAL;
+	}
+	obj = buf.pointer;
+
+	/* validate the returned package object. */
+	for (i = 0, elem = obj->package.elements;
+	     i < obj->package.count; i++, elem++)
+		if (elem->type != ACPI_TYPE_LOCAL_REFERENCE ||
+		    elem->reference.actual_type != ACPI_TYPE_DEVICE ||
+		    elem->reference.handle == NULL) {
+			ACPIHP_SLOT_DEBUG(slot,
+					  "invalid return from _EDL method.\n");
+			rc = AE_ERROR;
+			goto out;
+		}
+
+	/*
+	 * The dependency list will be handled in FILO order, so walk the array
+	 * in reverse order to keep the same order as returned by _EDL.
+	 */
+	for (i = 0, elem--; i < obj->package.count && ACPI_SUCCESS(rc);
+	     i++, elem--) {
+		tmp = acpihp_get_slot(elem->reference.handle);
+		if (tmp) {
+			rc = (*cb)(&tmp->dev, argp);
+			if (rc == AE_CTRL_DEPTH || rc == AE_CTRL_TERMINATE)
+				rc = AE_OK;
+		/*
+		 * ACPI _EDL method may return PCI slots for a hotpluggable
+		 * PCI host bridge, skip such cases. Only bail out if it's
+		 * an ACPI hotplug slot for system devices.
+		 */
+		} else if (acpihp_is_slot(elem->reference.handle)) {
+			ACPIHP_SLOT_WARN(slot,
+					 "fails to get device for slot.\n");
+			rc = AE_ERROR;
+		}
+	}
+
+out:
+	ACPI_FREE(buf.pointer);
+
+	return ACPI_SUCCESS(rc) ? 0 : -EINVAL;
+}
+
+static int acpihp_drv_add_offline_dependency(struct device *dev, void *argp)
+{
+	int ret;
+	struct acpihp_slot *slot;
+	struct list_head *list = argp;
+
+	slot = container_of(dev, struct acpihp_slot, dev);
+	ret = acpihp_drv_add_slot_to_dependency_list(slot, list);
+
+	/* All child slots must be handled first when hot-removing. */
+	if (!ret)
+		ret = device_for_each_child(&slot->dev, argp,
+					    &acpihp_drv_add_offline_dependency);
+
+	/* Add all slots from the _EDL list onto the dependency list */
+	if (!ret)
+		ret = acpihp_drv_for_each_edl(slot, argp,
+				&acpihp_drv_add_offline_dependency);
+
+	return ret;
+}
+
+/*
+ * Genereate dependency list for a given slot according to command.
+ * Caller needs to clean up the returned list if error happens.
+ */
+int acpihp_drv_generate_dependency_list(struct acpihp_slot *slot,
+		struct list_head *slot_list, enum acpihp_drv_cmd cmd)
+{
+	int retval;
+
+	switch (cmd) {
+	case ACPIHP_DRV_CMD_POWERON:
+	/* fall through */
+	case ACPIHP_DRV_CMD_CONNECT:
+	/* fall through */
+	case ACPIHP_DRV_CMD_CONFIGURE:
+		retval = acpihp_drv_get_online_dependency(slot, slot_list);
+		break;
+
+	case ACPIHP_DRV_CMD_POWEROFF:
+	/* fall through */
+	case ACPIHP_DRV_CMD_DISCONNECT:
+	/* fall through */
+	case ACPIHP_DRV_CMD_UNCONFIGURE:
+		retval = acpihp_drv_add_offline_dependency(&slot->dev,
+							   slot_list);
+		break;
+
+	default:
+		retval = -EINVAL;
+		break;
+	}
+
+	return retval;
+}
+
+/*
+ * Generate a new dependency list from the old list by filtering out slots
+ * which don't need to execute a specific operation.
+ */
+int acpihp_drv_filter_dependency_list(struct list_head *old_head,
+		struct list_head *new_head, u32 opcode)
+{
+	struct acpihp_slot_dependency *old_dep, *new_dep;
+
+	/* Initialize new list to empty */
+	INIT_LIST_HEAD(new_head);
+
+	list_for_each_entry(old_dep, old_head, node) {
+		/* Skip if the specified operation is not needed. */
+		if (!(old_dep->opcodes & opcode))
+			continue;
+
+		new_dep = kzalloc(sizeof(*new_dep), GFP_KERNEL);
+		if (!new_dep) {
+			ACPIHP_DEBUG("fails to filter depend list.\n");
+			acpihp_drv_destroy_dependency_list(new_head);
+			return -ENOMEM;
+		}
+
+		new_dep->slot = old_dep->slot;
+		new_dep->opcodes = old_dep->opcodes;
+		list_add_tail(&new_dep->node, new_head);
+	}
+
+	return 0;
+}
+
+void acpihp_drv_destroy_dependency_list(struct list_head *slot_list)
+{
+	struct acpihp_slot_dependency *dep, *temp;
+
+	list_for_each_entry_safe(dep, temp, slot_list, node) {
+		list_del(&dep->node);
+		kfree(dep);
+	}
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
