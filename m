Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id B4E986B005D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:13 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2498021dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:13 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 06/13] ACPIHP: implement ACPI system device hotplug driver skeleton
Date: Sun,  4 Nov 2012 20:50:08 +0800
Message-Id: <1352033415-5606-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

The ACPI based system device hotplug driver is a platform independent
driver to manage all ACPI hotplug slots. It implements a state machine
for hotplug slots and drives state transition according to hotplug
event from firmware or user request from sysfs interfaces.

The hotplug driver will provides following features:
1) Configure/unconfigure affected system devices in optimal order
2) Provide sysfs interfaces for user to trigger hotplug operations
3) Provide interface to cancel ongoing hotplug opertions
4) Resolve dependencies among hotplug slots
5) Better error handling and recovery

The driver depends on the ACPI hotplug slot enumeration driver to
control each slot in platform specific ways, and also depends on
ACPI device drivers for processor, memory, PCI host bridge and
container to configure/unconfigure each system device.

This patch implements the skeleton of the hotplug driver, and following
patches will fulfill all hotplug functionalities.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/acpi/Kconfig              |   15 ++
 drivers/acpi/hotplug/Makefile     |    3 +
 drivers/acpi/hotplug/acpihp_drv.h |   38 ++++
 drivers/acpi/hotplug/drv_main.c   |  344 +++++++++++++++++++++++++++++++++++++
 4 files changed, 400 insertions(+)
 create mode 100644 drivers/acpi/hotplug/acpihp_drv.h
 create mode 100644 drivers/acpi/hotplug/drv_main.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 4d15b49..185ab1d 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -363,6 +363,21 @@ config ACPI_HOTPLUG_SLOT_FAKE
 
 	  Pass parameter "fake_slot=0xf" to enable this function.
 
+config ACPI_HOTPLUG_DRIVER
+	tristate "System Device Hotplug Manager"
+	depends on ACPI_HOTPLUG
+	default m
+	help
+	  This driver implements a framework to manage system device hotplug
+	  slots, which could be used to support hotplug of processor, memory,
+	  PCI host bridge and computner node etc.
+
+	  It depends on ACPI container, processor, memory and PCI host bridge
+	  drivers to configure/unconfigure individual ACPI devices.
+
+	  To compile this driver as a module, choose M here:
+	  the module will be called acpihp_drv.
+
 config ACPI_CONTAINER
 	tristate "Container and Module Devices (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 6e5daf6..6257047 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -9,3 +9,6 @@ obj-$(CONFIG_ACPI_HOTPLUG_SLOT)			+= acpihp_slot.o
 acpihp_slot-y					= slot.o
 acpihp_slot-y					+= slot_ej0.o
 acpihp_slot-$(CONFIG_ACPI_HOTPLUG_SLOT_FAKE)	+= slot_fake.o
+
+obj-$(CONFIG_ACPI_HOTPLUG_DRIVER)		+= acpihp_drv.o
+acpihp_drv-y					= drv_main.o
diff --git a/drivers/acpi/hotplug/acpihp_drv.h b/drivers/acpi/hotplug/acpihp_drv.h
new file mode 100644
index 0000000..769ee74
--- /dev/null
+++ b/drivers/acpi/hotplug/acpihp_drv.h
@@ -0,0 +1,38 @@
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
+#ifndef	__ACPIHP_DRV_H__
+#define	__ACPIHP_DRV_H__
+
+struct acpihp_slot_drv {
+	struct mutex		op_mutex;
+};
+
+void acpihp_drv_get_data(struct acpihp_slot *slot,
+			 struct acpihp_slot_drv **data);
+int acpihp_drv_enumerate_devices(struct acpihp_slot *slot);
+void acpihp_drv_update_slot_state(struct acpihp_slot *slot);
+int acpihp_drv_update_slot_status(struct acpihp_slot *slot);
+
+#endif	/* __ACPIHP_DRV_H__ */
diff --git a/drivers/acpi/hotplug/drv_main.c b/drivers/acpi/hotplug/drv_main.c
new file mode 100644
index 0000000..8ab298a
--- /dev/null
+++ b/drivers/acpi/hotplug/drv_main.c
@@ -0,0 +1,344 @@
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
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/kthread.h>
+#include <linux/delay.h>
+#include <linux/acpi.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp_drv.h"
+
+static struct class_interface acpihp_drv_interface;
+
+void acpihp_drv_get_data(struct acpihp_slot *slot,
+			 struct acpihp_slot_drv **data)
+{
+	*data = NULL;
+	acpihp_slot_get_drv_data(slot, &acpihp_drv_interface, (void **)data);
+}
+
+/* Update slot state according to state of devices connecting to it. */
+void acpihp_drv_update_slot_state(struct acpihp_slot *slot)
+{
+	enum acpihp_dev_type type;
+	enum acpihp_slot_state state;
+	struct klist_iter iter;
+	struct klist_node *ip;
+	struct acpihp_dev_node *dp;
+	bool connected = false;
+	bool configured = false;
+
+	if (!acpihp_slot_present(slot)) {
+		state = ACPIHP_SLOT_STATE_ABSENT;
+		goto out;
+	} else if (!acpihp_slot_powered(slot)) {
+		state = ACPIHP_SLOT_STATE_PRESENT;
+		goto out;
+	}
+
+	for (type = ACPIHP_DEV_TYPE_UNKNOWN;
+	     type < ACPIHP_DEV_TYPE_MAX && !configured;
+	     type++) {
+		klist_iter_init(&slot->dev_lists[type], &iter);
+		while ((ip = klist_next(&iter)) != NULL) {
+			connected = true;
+			dp = container_of(ip, struct acpihp_dev_node, node);
+			if (dp->state == DEVICE_STATE_CONFIGURED) {
+				configured = true;
+				break;
+			}
+		}
+		klist_iter_exit(&iter);
+	}
+
+	if (configured)
+		state = ACPIHP_SLOT_STATE_CONFIGURED;
+	else if (connected)
+		state = ACPIHP_SLOT_STATE_CONNECTED;
+	else
+		state = ACPIHP_SLOT_STATE_POWERED;
+
+out:
+	acpihp_slot_change_state(slot, state);
+}
+
+/* Update slot status according to status of devices connecting to it. */
+int acpihp_drv_update_slot_status(struct acpihp_slot *slot)
+{
+	int ret = 0;
+	enum acpihp_dev_type type;
+	struct klist_iter iter;
+	struct klist_node *ip;
+	struct acpihp_dev_node *np;
+	struct acpi_device *dev;
+	struct acpihp_dev_info *info;
+
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		return -ENOMEM;
+
+	for (type = ACPIHP_DEV_TYPE_CONTAINER;
+	     type <= ACPIHP_DEV_TYPE_HOST_BRIDGE; type++) {
+		klist_iter_init(&slot->dev_lists[type], &iter);
+		while ((ip = klist_next(&iter)) != NULL) {
+			np = container_of(ip, struct acpihp_dev_node, node);
+			dev = container_of(np->dev, struct acpi_device, dev);
+			ret = acpihp_dev_get_info(dev, info);
+			if (ret) {
+				ACPIHP_SLOT_DEBUG(slot,
+					"fails to get info about %s.\n",
+					dev_name(&dev->dev));
+				klist_iter_exit(&iter);
+				goto out;
+			}
+
+			if (info->status & ACPIHP_DEV_STATUS_FAULT)
+				acpihp_slot_set_flag(slot,
+						ACPIHP_SLOT_FLAG_FAULT);
+			if (info->status & ACPIHP_DEV_STATUS_IRREMOVABLE)
+				acpihp_slot_set_flag(slot,
+						ACPIHP_SLOT_FLAG_IRREMOVABLE);
+		}
+		klist_iter_exit(&iter);
+	}
+
+out:
+	kfree(info);
+
+	return ret;
+}
+EXPORT_SYMBOL(acpihp_drv_update_slot_status);
+
+/* Add ACPI device onto hotplug slot's device list */
+static acpi_status acpihp_drv_enum_device(struct acpi_device *dev, void *argp)
+{
+	int ret = -ENOMEM;
+	acpi_status rv = AE_ERROR;
+	enum acpihp_dev_type type;
+	enum acpihp_dev_state state;
+	struct acpihp_dev_info *info;
+	struct acpihp_slot *slot = (struct acpihp_slot *)argp;
+
+	if (acpihp_dev_get_type(dev->handle, &type)) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to get device type of %s.\n",
+				  dev_name(&dev->dev));
+		return AE_ERROR;
+	} else if (type == ACPIHP_DEV_TYPE_MAX) {
+		/*
+		 * Some ACPI objects for IO devices, such as PCI/IDE etc, only
+		 * implement _ADR instead of _HID/_CID, skip them.
+		 */
+		return AE_CTRL_DEPTH;
+	}
+
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (info)
+		ret = acpihp_dev_get_info(dev, info);
+
+	if (!ret) {
+		if (info->status & ACPIHP_DEV_STATUS_STARTED)
+			state = DEVICE_STATE_CONFIGURED;
+		else
+			state = DEVICE_STATE_CONNECTED;
+
+		if (info->status & ACPIHP_DEV_STATUS_IRREMOVABLE)
+			acpihp_slot_set_flag(slot,
+					     ACPIHP_SLOT_FLAG_IRREMOVABLE);
+		if (info->status & ACPIHP_DEV_STATUS_FAULT)
+			acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_FAULT);
+
+		if (acpihp_slot_add_device(slot, type, state, &dev->dev)) {
+			ACPIHP_SLOT_DEBUG(slot, "fails to add device %s.\n",
+					  dev_name(&dev->dev));
+			acpihp_slot_set_flag(slot,
+					     ACPIHP_SLOT_FLAG_IRREMOVABLE);
+		} else
+			rv = AE_OK;
+	} else {
+		ACPIHP_SLOT_DEBUG(slot, "fails to query device info of %s.\n",
+				  dev_name(&dev->dev));
+		acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_IRREMOVABLE);
+	}
+
+	kfree(info);
+
+	return rv;
+}
+
+/*
+ * Enumerate all ACPI devices attached to the slot and add them onto slot's
+ * device lists.
+ */
+int acpihp_drv_enumerate_devices(struct acpihp_slot *slot)
+{
+	return acpihp_walk_devices(slot->handle, acpihp_drv_enum_device, slot);
+}
+
+static void acpihp_drv_remove_devices(struct acpihp_slot *slot)
+{
+	enum acpihp_dev_type type;
+
+	for (type = ACPIHP_DEV_TYPE_UNKNOWN; type < ACPIHP_DEV_TYPE_MAX; type++)
+		acpihp_remove_device_list(&slot->dev_lists[type]);
+}
+
+/* Handle ACPI device hotplug notifications */
+static void acpihp_drv_event_handler(acpi_handle handle, u32 event,
+				     void *context)
+{
+	/* TODO: handle ACPI hotplug events */
+}
+
+static acpi_status acpihp_drv_install_handler(struct acpihp_slot *slot)
+{
+	acpi_status status;
+
+	status = acpi_install_notify_handler(slot->handle, ACPI_SYSTEM_NOTIFY,
+					     acpihp_drv_event_handler, slot);
+	ACPIHP_SLOT_DEBUG(slot, "%s to install event handler.\n",
+			  ACPI_SUCCESS(status) ? "succeeds" : "fails");
+
+	return status;
+}
+
+static void acpihp_drv_uninstall_handler(struct acpihp_slot *slot)
+{
+	acpi_status status;
+
+	status = acpi_remove_notify_handler(slot->handle, ACPI_SYSTEM_NOTIFY,
+					    acpihp_drv_event_handler);
+	ACPIHP_SLOT_DEBUG(slot, "%s to uninstall event handler.\n",
+			  ACPI_SUCCESS(status) ? "succeeds" : "fails");
+}
+
+static int acpihp_drv_slot_add(struct device *dev, struct class_interface *intf)
+{
+	struct acpihp_slot_drv *drv_data;
+	struct acpihp_slot *slot = container_of(dev, struct acpihp_slot, dev);
+
+	/*
+	 * Try to hold a reference to the slot_ops structure to prevent
+	 * the platform specific enumerator driver from unloading.
+	 */
+	if (!slot->slot_ops || !try_module_get(slot->slot_ops->owner)) {
+		ACPIHP_SLOT_DEBUG(slot,
+				  "fails to get reference to slot_ops.\n");
+		return -EINVAL;
+	}
+
+	/* Install ACPI event notification handler */
+	if (ACPI_FAILURE(acpihp_drv_install_handler(slot))) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to install event handler.\n");
+		module_put(slot->slot_ops->owner);
+		return -EBUSY;
+	}
+
+	/*
+	 * Enumerate all ACPI devices attached to the hotplug slot if
+	 * it has been already powered.
+	 */
+	if (!acpihp_slot_powered(slot))
+		ACPIHP_SLOT_DEBUG(slot, "is powered off.\n");
+	else if (acpihp_drv_enumerate_devices(slot))
+		acpihp_slot_set_flag(slot, ACPIHP_SLOT_FLAG_IRREMOVABLE);
+
+	acpihp_drv_update_slot_state(slot);
+	acpihp_drv_update_slot_status(slot);
+
+	drv_data = kzalloc(sizeof(*drv_data), GFP_KERNEL);
+	if (drv_data) {
+		mutex_init(&drv_data->op_mutex);
+	}
+	if (drv_data == NULL ||
+	    acpihp_slot_attach_drv_data(slot, intf, (void *)drv_data)) {
+		ACPIHP_SLOT_DEBUG(slot, "fails to attach driver data.\n");
+		acpihp_drv_remove_devices(slot);
+		module_put(slot->slot_ops->owner);
+		kfree(drv_data);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void acpihp_drv_intf_remove(struct device *dev,
+				  struct class_interface *intf)
+{
+	struct acpihp_slot_drv *drv_data = NULL;
+	struct acpihp_slot *slot =
+			container_of(dev, struct acpihp_slot, dev);
+
+	acpihp_drv_uninstall_handler(slot);
+	acpihp_drv_remove_devices(slot);
+	acpihp_slot_detach_drv_data(slot, intf, (void **)&drv_data);
+	if (drv_data != NULL)
+		kfree(drv_data);
+
+	module_put(slot->slot_ops->owner);
+}
+
+/*
+ * Class driver to bound to ACPI system device hotplug slot devices.
+ */
+static struct class_interface acpihp_drv_interface = {
+	.class		= &acpihp_slot_class,
+	.add_dev	= acpihp_drv_slot_add,
+	.remove_dev	= acpihp_drv_intf_remove,
+};
+
+static int __init acpihp_drv_init(void)
+{
+	int retval;
+
+	retval = acpihp_core_init();
+	if (retval) {
+		ACPIHP_DEBUG("fails to initialize ACPIHP core.\n");
+		return retval;
+	}
+
+	retval = class_interface_register(&acpihp_drv_interface);
+	if (retval) {
+		ACPIHP_DEBUG("fails to register ACPI hotplug slot driver.\n");
+		acpihp_core_fini();
+	}
+
+	return retval;
+}
+
+static void __exit acpihp_drv_exit(void)
+{
+	class_interface_unregister(&acpihp_drv_interface);
+	acpihp_core_fini();
+}
+
+module_init(acpihp_drv_init);
+module_exit(acpihp_drv_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiang Liu <jiang.liu@huawei.com>");
+MODULE_AUTHOR("Hanjun Guo <guohanjun@huawei.com>");
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
