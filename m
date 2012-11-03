Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C7C456B005D
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 12:08:15 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3347216pbb.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 09:08:15 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part1 2/4] ACPIHP: introduce acpihp_slot driver to enumerate hotplug slots
Date: Sun,  4 Nov 2012 00:07:43 +0800
Message-Id: <1351958865-24394-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

An ACPI hotplug slot is an abstraction of receptacles, where a group of
system devices could be connected to. This patch implements the skeleton
of the ACPI system device hotplug slot enumerator. On loading, it scans
the whole ACPI namespace for hotplug slots and creates a device node for
each hotplug slot found. Every hotplug slot is associated with a device
class named acpihp_slot_class. Later hotplug drivers will register onto
acpihp_slot_class to manage all hotplug slots.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
---
 drivers/acpi/Kconfig          |   19 ++
 drivers/acpi/hotplug/Makefile |    3 +
 drivers/acpi/hotplug/slot.c   |  417 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 439 insertions(+)
 create mode 100644 drivers/acpi/hotplug/slot.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 9577b23..af0aaf6 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -334,6 +334,25 @@ menuconfig ACPI_HOTPLUG
 	  If your hardware platform does not support system device dynamic
 	  reconfiguration at runtime, you need not to enable this option.
 
+config ACPI_HOTPLUG_SLOT
+	tristate "System Device Hotplug Slot Enumerator"
+	depends on ACPI_HOTPLUG
+	default m
+	help
+	  ACPI system device hotplug slot is an abstraction of ACPI based
+	  system device dynamic reconfiguration control points. On load,
+	  this driver enumerates system device hotplug slots by wakling the
+	  ACPI namespace and provides platform specific methods to control
+	  those hotplug slots.
+
+	  By default, this driver detects system device hotplug slots by
+	  checking avaliability of ACPI _EJ0 method. You may pass a module
+	  parameter "fake_slot=0xf" to enable faking hotplug slots on
+	  platforms without hardware dynamic reconfiguration capabilities.
+
+	  To compile this driver as a module, choose M here:
+	  the module will be called acpihp_slot.
+
 config ACPI_CONTAINER
 	tristate "Container and Module Devices (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 5e7790f..2cbb03c 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -4,3 +4,6 @@
 
 obj-$(CONFIG_ACPI_HOTPLUG)			+= acpihp.o
 acpihp-y					= core.o
+
+obj-$(CONFIG_ACPI_HOTPLUG_SLOT)			+= acpihp_slot.o
+acpihp_slot-y					= slot.o
diff --git a/drivers/acpi/hotplug/slot.c b/drivers/acpi/hotplug/slot.c
new file mode 100644
index 0000000..b76cb16
--- /dev/null
+++ b/drivers/acpi/hotplug/slot.c
@@ -0,0 +1,417 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ * Copyright (C) 2012 Gaohuai Han <hangaohuai@huawei.com>
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
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/acpi.h>
+#include "acpihp.h"
+
+struct acpihp_slot_id {
+	struct list_head node;
+	enum acpihp_slot_type type;
+	unsigned long instance_id;
+};
+
+static LIST_HEAD(slot_list);
+static LIST_HEAD(slot_id_list);
+static struct acpihp_slot_ops *slot_ops_curr;
+
+/*
+ * Platform dependent slot drivers should be sorted in descending order.
+ * The first entry whose init() method returns success will be used.
+ */
+static struct acpihp_slot_ops *slot_ops_array[] = {
+	NULL
+};
+
+static acpi_status __init
+acpihp_slot_get_dev_type(acpi_handle handle, u32 lvl, void *context, void **rv)
+{
+	u32 *tp = (u32 *)rv;
+	acpi_status status = AE_OK;
+	enum acpihp_dev_type type;
+
+	/* Only care about CPU, memory, PCI host bridge and CONTAINER */
+	if (!acpihp_dev_get_type(handle, &type)) {
+		switch (type) {
+		case ACPIHP_DEV_TYPE_CPU:
+			*tp |= 0x0001;
+			status = AE_CTRL_DEPTH;
+			break;
+		case ACPIHP_DEV_TYPE_MEM:
+			*tp |= 0x0002;
+			status = AE_CTRL_DEPTH;
+			break;
+		case ACPIHP_DEV_TYPE_HOST_BRIDGE:
+			*tp |= 0x0004;
+			status = AE_CTRL_DEPTH;
+			break;
+		case ACPIHP_DEV_TYPE_CONTAINER:
+			*tp |= 0x0008;
+			break;
+		default:
+			break;
+		}
+	}
+
+	return status;
+}
+
+static enum acpihp_slot_type __init acpihp_slot_get_type_child(u32 dev_types)
+{
+	BUG_ON(dev_types > 15);
+
+	switch (dev_types) {
+	case 0:
+		/* Generic CONTAINER */
+		return ACPIHP_SLOT_TYPE_COMMON;
+	case 1:
+		/* Physical processor with logical CPUs */
+		return ACPIHP_SLOT_TYPE_CPU;
+	case 2:
+		/* Memory board/box with memory devices */
+		return ACPIHP_SLOT_TYPE_MEM;
+	case 3:
+		/* Physical processor with CPUs and memory controllers */
+		return ACPIHP_SLOT_TYPE_CPU;
+	case 4:
+		/* IO eXtension board/box with IO host bridges */
+		return ACPIHP_SLOT_TYPE_IOX;
+	case 7:
+		/* Physical processor with CPUs, IO host bridges and MCs. */
+		return ACPIHP_SLOT_TYPE_CPU;
+	case 8:
+		/* Generic CONTAINER */
+		return ACPIHP_SLOT_TYPE_COMMON;
+	case 9:
+		/* System board with physical processors */
+		return ACPIHP_SLOT_TYPE_SYSTEM_BOARD;
+	case 11:
+		/* System board with physical processors and memory */
+		return ACPIHP_SLOT_TYPE_SYSTEM_BOARD;
+	case 15:
+		/* Node with processor, memory and IO host bridge */
+		return ACPIHP_SLOT_TYPE_NODE;
+	default:
+		return ACPIHP_SLOT_TYPE_UNKNOWN;
+	}
+}
+
+static enum acpihp_slot_type __init
+acpihp_slot_get_type_self(struct acpihp_slot *slot)
+{
+	enum acpihp_dev_type type;
+
+	if (acpihp_dev_get_type(slot->handle, &type))
+		return ACPIHP_SLOT_TYPE_UNKNOWN;
+
+	switch (type) {
+	case ACPIHP_DEV_TYPE_CPU:
+		/* Logical CPU used in virtualization environment */
+		return ACPIHP_SLOT_TYPE_CPU;
+	case ACPIHP_DEV_TYPE_MEM:
+		/* Memory board with single memory device */
+		return ACPIHP_SLOT_TYPE_MEM;
+	case ACPIHP_DEV_TYPE_HOST_BRIDGE:
+		/* IO eXtension board/box with single IO host bridge */
+		return ACPIHP_SLOT_TYPE_IOX;
+	default:
+		return ACPIHP_SLOT_TYPE_UNKNOWN;
+	}
+}
+
+/*
+ * Generate a meaningful name for a hotplug slot according to types of ACPI
+ * devices which could be attached to the slot.
+ */
+static int __init acpihp_slot_generate_name(struct acpihp_slot *slot)
+{
+	int found = 0;
+	u32 child_types = 0;
+	unsigned long long uid;
+	struct acpihp_slot_id *slot_id;
+
+	/*
+	 * Figure out slot type by checking types of ACPI devices which could
+	 * be attached to the slot.
+	 */
+	slot->type = acpihp_slot_get_type_self(slot);
+	if (slot->type == ACPIHP_SLOT_TYPE_UNKNOWN) {
+		acpi_walk_namespace(ACPI_TYPE_DEVICE, slot->handle,
+				ACPI_UINT32_MAX, acpihp_slot_get_dev_type,
+				NULL, NULL, (void **)&child_types);
+		acpi_walk_namespace(ACPI_TYPE_PROCESSOR, slot->handle,
+				ACPI_UINT32_MAX, acpihp_slot_get_dev_type,
+				NULL, NULL, (void **)&child_types);
+		slot->type = acpihp_slot_get_type_child(child_types);
+	}
+
+	/* Respect firmware settings if ACPI _UID returns a valid value. */
+	if (ACPI_SUCCESS(acpi_evaluate_integer(slot->handle, METHOD_NAME__UID,
+					       NULL, &uid)))
+		goto set_name;
+
+	/* Generate a unique pseudo instance ID */
+	list_for_each_entry(slot_id, &slot_id_list, node)
+		if (slot_id->type == slot->type) {
+			found = 1;
+			break;
+		}
+	if (!found) {
+		slot_id = kzalloc(sizeof(struct acpihp_slot_id), GFP_KERNEL);
+		if (!slot_id) {
+			ACPIHP_SLOT_WARN(slot,
+				"fails to allocate slot instance ID.\n");
+			return -ENOMEM;
+		}
+		slot_id->type = slot->type;
+		list_add_tail(&slot_id->node, &slot_id_list);
+	}
+	uid = slot_id->instance_id++;
+
+set_name:
+	snprintf(slot->name, sizeof(slot->name) - 1, "%s%02llx",
+		 acpihp_get_slot_type_name(slot->type), uid);
+	dev_set_name(&slot->dev, "%s", slot->name);
+
+	return 0;
+}
+
+static int __init acpihp_slot_get_parent(struct acpihp_slot *slot)
+{
+	acpi_handle handle, root_handle;
+	struct acpihp_slot *tmp;
+
+	slot->parent = NULL;
+	handle = slot->handle;
+	if (ACPI_FAILURE(acpi_get_handle(NULL, ACPI_NS_ROOT_PATH,
+					 &root_handle))) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to get ACPI root device.\n");
+		return -ENODEV;
+	}
+
+	do {
+		if (ACPI_FAILURE(acpi_get_parent(handle, &handle))) {
+			ACPIHP_SLOT_DEBUG(slot,
+					  "fails to get parent device.\n");
+			return -ENODEV;
+		}
+		list_for_each_entry(tmp, &slot_list, slot_list)
+			if (tmp->handle == handle) {
+				slot->parent = tmp;
+				return 0;
+			}
+	} while (handle != root_handle);
+
+	return 0;
+}
+
+static int __init acpihp_slot_get_state(struct acpihp_slot *slot)
+{
+	unsigned long long sta;
+
+	/* Hotplug slots must implement ACPI _STA method. */
+	if (ACPI_FAILURE(acpihp_slot_get_status(slot, &sta))) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to execute _STA method.\n");
+		return -EINVAL;
+	}
+
+	if (!(sta & ACPI_STA_DEVICE_PRESENT))
+		slot->state = ACPIHP_SLOT_STATE_ABSENT;
+	else if ((sta & ACPI_STA_DEVICE_ENABLED) ||
+		 (sta & ACPI_STA_DEVICE_FUNCTIONING))
+		slot->state = ACPIHP_SLOT_STATE_POWERED;
+	else
+		slot->state = ACPIHP_SLOT_STATE_PRESENT;
+
+	return 0;
+}
+
+static int __init acpihp_slot_create(acpi_handle handle)
+{
+	struct acpihp_slot *slot;
+
+	slot = acpihp_alloc_slot(handle, NULL);
+	if (!slot) {
+		ACPIHP_DEBUG("fails to allocate memory for slot %p.\n", handle);
+		return -ENOMEM;
+	}
+
+	slot->slot_ops = slot_ops_curr;
+	if (ACPI_FAILURE(slot_ops_curr->create(slot))) {
+		ACPIHP_DEBUG("fails to create slot for %p.\n", handle);
+		goto out_free;
+	}
+	if (acpihp_slot_get_parent(slot))
+		goto out_destroy;
+	if (acpihp_slot_get_state(slot))
+		goto out_destroy;
+	if (acpihp_slot_generate_name(slot))
+		goto out_destroy;
+
+	if (acpihp_register_slot(slot)) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to register slot.\n");
+		goto out_destroy;
+	}
+	if (ACPI_FAILURE(acpihp_mark_slot(handle, slot))) {
+		ACPIHP_SLOT_DEBUG(slot,
+			"fails to attach slot to ACPI device object.\n");
+		goto out_unregister;
+	}
+
+	list_add_tail(&slot->slot_list, &slot_list);
+
+	return 0;
+
+out_unregister:
+	acpihp_unregister_slot(slot);
+out_destroy:
+	if (slot_ops_curr->destroy)
+		slot_ops_curr->destroy(slot);
+out_free:
+	acpihp_slot_put(slot);
+	return -ENODEV;
+}
+
+static acpi_status __init acpihp_slot_scan(acpi_handle handle, u32 lvl,
+					   void *context, void **rv)
+{
+	enum acpihp_dev_type type;
+
+	if (acpihp_dev_get_type(handle, &type) ||
+	    type == ACPIHP_DEV_TYPE_UNKNOWN)
+		return AE_OK;
+
+	if (ACPI_SUCCESS(slot_ops_curr->check(handle)))
+		acpihp_slot_create(handle);
+
+	/*
+	 * Don't scan hotplug slots under PCI host bridges, they should be
+	 * handled by acpiphp or pciehp drivers.
+	 */
+	if (type == ACPIHP_DEV_TYPE_HOST_BRIDGE)
+		return AE_CTRL_DEPTH;
+
+	return AE_OK;
+}
+
+static int __init acpihp_slot_scan_slots(void)
+{
+	acpi_status status;
+
+	status = acpi_walk_namespace(ACPI_TYPE_DEVICE, ACPI_ROOT_OBJECT,
+				     ACPI_UINT32_MAX, acpihp_slot_scan,
+				     NULL, NULL, NULL);
+	if (!ACPI_SUCCESS(status))
+		goto out_err;
+
+	status = acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
+				     ACPI_UINT32_MAX, acpihp_slot_scan,
+				     NULL, NULL, NULL);
+	if (ACPI_SUCCESS(status))
+		return 0;
+
+out_err:
+	ACPIHP_DEBUG("fails to scan ACPI hotplug slots.\n");
+
+	return -ENODEV;
+}
+
+static void acpihp_slot_cleanup(void)
+{
+	struct acpihp_slot *slot, *tmp;
+	struct acpihp_slot_id *slot_id, *tmp_id;
+
+	list_for_each_entry_safe(slot, tmp, &slot_list, slot_list) {
+		acpihp_unmark_slot(slot->handle);
+		acpihp_unregister_slot(slot);
+		if (slot->slot_ops && slot->slot_ops->destroy)
+			slot->slot_ops->destroy(slot);
+		acpihp_slot_put(slot);
+	}
+
+	list_for_each_entry_safe(slot_id, tmp_id, &slot_id_list, node) {
+		list_del(&slot_id->node);
+		kfree(slot_id);
+	}
+}
+
+static int __init acpihp_slot_init(void)
+{
+	int i, retval;
+
+	/* probe for available platform specific slot driver. */
+	for (i = 0; slot_ops_array[i]; i++)
+		if (ACPI_SUCCESS(slot_ops_array[i]->init())) {
+			slot_ops_curr = slot_ops_array[i];
+			break;
+		}
+	if (slot_ops_curr == NULL) {
+		ACPIHP_DEBUG("no platform specific slot driver available.\n");
+		return -ENODEV;
+	}
+
+	retval = acpihp_core_init();
+	if (retval != 0) {
+		ACPIHP_DEBUG("fails to initialize ACPIHP core.\n");
+		goto out_fini;
+	}
+
+	if (acpihp_slot_scan_slots() != 0)
+		ACPIHP_DEBUG("fails to enumerate ACPI hotplug slots.\n");
+
+	/* Back out if no ACPI hotplug slot found. */
+	if (list_empty(&slot_list)) {
+		ACPIHP_DEBUG("no ACPI hotplug slot available.\n");
+		retval = -ENODEV;
+		goto out_core_fini;
+	}
+
+	return 0;
+
+out_core_fini:
+	acpihp_core_fini();
+out_fini:
+	if (slot_ops_curr && slot_ops_curr->fini)
+		slot_ops_curr->fini();
+	ACPIHP_DEBUG("fails to initialize ACPI hotplug slot driver.\n");
+
+	return retval;
+}
+
+static void __exit acpihp_slot_exit(void)
+{
+	acpihp_slot_cleanup();
+	acpihp_core_fini();
+	if (slot_ops_curr && slot_ops_curr->fini)
+		slot_ops_curr->fini();
+}
+
+module_init(acpihp_slot_init);
+module_exit(acpihp_slot_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiang Liu <jiang.liu@huawei.com>");
+MODULE_AUTHOR("Gaohuai Han <hangaohuai@huawei.com>");
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
