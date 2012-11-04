Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id AB36B6B005D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:50:34 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3667633pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:50:34 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 01/13] ACPIHP: introduce interfaces to scan and walk ACPI devices attached to a slot
Date: Sun,  4 Nov 2012 20:50:03 +0800
Message-Id: <1352033415-5606-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

This patch enhances acpi_bus_scan() to implement acpihp_add_devices(),
which creates ACPI devices for hot-added system devices attached to
an ACPI hotplug slot, but don't cross the slot boundary.

It also introduces a new interface to walk all ACPI devices attached
to an ACPI hotplug slot.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
---
 drivers/acpi/hotplug/Makefile |    2 +-
 drivers/acpi/hotplug/acpihp.h |    1 +
 drivers/acpi/hotplug/device.c |  121 +++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/internal.h       |    3 +
 drivers/acpi/scan.c           |   12 +++-
 include/acpi/acpi_bus.h       |    2 +
 include/acpi/acpi_hotplug.h   |   15 +++++
 7 files changed, 153 insertions(+), 3 deletions(-)
 create mode 100644 drivers/acpi/hotplug/device.c

diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index c19b350..6e5daf6 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -3,7 +3,7 @@
 #
 
 obj-$(CONFIG_ACPI_HOTPLUG)			+= acpihp.o
-acpihp-y					= core.o
+acpihp-y					= core.o device.o
 
 obj-$(CONFIG_ACPI_HOTPLUG_SLOT)			+= acpihp_slot.o
 acpihp_slot-y					= slot.o
diff --git a/drivers/acpi/hotplug/acpihp.h b/drivers/acpi/hotplug/acpihp.h
index 7c49eab..54d9d95 100644
--- a/drivers/acpi/hotplug/acpihp.h
+++ b/drivers/acpi/hotplug/acpihp.h
@@ -26,6 +26,7 @@
 #include <acpi/acpi.h>
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_hotplug.h>
+#include "../internal.h"
 
 extern struct acpi_device *acpi_root;
 extern struct acpihp_slot_ops acpihp_slot_ej0;
diff --git a/drivers/acpi/hotplug/device.c b/drivers/acpi/hotplug/device.c
new file mode 100644
index 0000000..2dcdd83
--- /dev/null
+++ b/drivers/acpi/hotplug/device.c
@@ -0,0 +1,121 @@
+/*
+ * Copyright (C) 2012 Huawei Tech. Co., Ltd.
+ * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
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
+#include <linux/types.h>
+#include <linux/device.h>
+#include <acpi/acpi.h>
+#include <acpi/acpi_bus.h>
+#include <acpi/acpi_hotplug.h>
+#include "acpihp.h"
+
+/*
+ * When creating ACPI devices for hot-added system devices connecting to
+ * a slot, don't cross the slot boundary. Otherwise it will cause
+ * inconsistence to other hotplug slots.
+ */
+static acpi_status acpihp_filter_device(acpi_handle hdl, u32 level, void *arg)
+{
+	/* Skip if the handle corresponds to a child hotplug slot. */
+	if (level > 0 && acpihp_is_slot(hdl))
+		return AE_CTRL_DEPTH;
+
+	return AE_OK;
+}
+
+/* Create ACPI devices for hot-added system devices connecting to a slot. */
+int acpihp_add_devices(acpi_handle handle, struct acpi_device **child)
+{
+	struct acpi_bus_ops ops;
+
+	memset(&ops, 0, sizeof(ops));
+	ops.acpi_op_add = 1;
+	ops.acpi_op_filter = &acpihp_filter_device;
+	ops.acpi_op_filter_arg = NULL;
+
+	return acpi_bus_scan(handle, &ops, child);
+}
+EXPORT_SYMBOL_GPL(acpihp_add_devices);
+
+struct acpihp_walk_arg {
+	acpihp_walk_device_cb cb;
+	void *arg;
+	acpi_status status;
+};
+
+static int acpihp_walk_cb(struct device *dev, void *data)
+{
+	acpi_status status;
+	struct acpihp_walk_arg *argp = (struct acpihp_walk_arg *)data;
+	struct acpi_device *acpi_dev;
+
+	if (dev->bus != &acpi_bus_type)
+		return 0;
+
+	/* Skip if the handle corresponds to a child hotplug slot. */
+	acpi_dev = container_of(dev, struct acpi_device, dev);
+	if (acpihp_is_slot(acpi_dev->handle))
+		return 0;
+
+	status = argp->cb(acpi_dev, argp->arg);
+	if (status == AE_OK) {
+		return device_for_each_child(dev, data, &acpihp_walk_cb);
+	} else if (status == AE_CTRL_DEPTH || status == AE_CTRL_SKIP) {
+		return 0;
+	} else {
+		argp->status = status;
+		return -1;
+	}
+}
+
+/*
+ * Walk all ACPI devices connecting to a hotplug slot, but don't cross the
+ * hotplug slot boundary.
+ */
+int acpihp_walk_devices(acpi_handle handle, acpihp_walk_device_cb cb,
+			void *argp)
+{
+	acpi_status status;
+	struct acpi_device *device;
+	struct acpihp_walk_arg arg;
+
+	if (acpi_bus_get_device(handle, &device))
+		return -ENODEV;
+
+	status = (*cb)(device, argp);
+	if (ACPI_SUCCESS(status)) {
+		arg.cb = cb;
+		arg.arg = argp;
+		arg.status = AE_OK;
+		(void) device_for_each_child(&device->dev, &arg,
+					     &acpihp_walk_cb);
+		status = arg.status;
+	}
+
+	if (status == AE_CTRL_DEPTH || status == AE_CTRL_TERMINATE ||
+	    status == AE_CTRL_SKIP)
+		status = AE_OK;
+	else if (ACPI_FAILURE(status))
+		ACPIHP_DEBUG("fails to walk devices under %p.\n", handle);
+
+	return status == AE_OK ? 0 : -ENODEV;
+}
+EXPORT_SYMBOL_GPL(acpihp_walk_devices);
diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
index ca75b9c..d2c4d83 100644
--- a/drivers/acpi/internal.h
+++ b/drivers/acpi/internal.h
@@ -93,4 +93,7 @@ static inline int suspend_nvs_save(void) { return 0; }
 static inline void suspend_nvs_restore(void) {}
 #endif
 
+int acpi_bus_scan(acpi_handle handle, struct acpi_bus_ops *ops,
+		  struct acpi_device **child);
+
 #endif /* _ACPI_INTERNAL_H_ */
diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 1fcb867..f621333 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -1477,6 +1477,14 @@ static acpi_status acpi_bus_check_add(acpi_handle handle, u32 lvl,
 		return AE_CTRL_DEPTH;
 	}
 
+	/* Hooks for ACPI based system device hotplug */
+	if (ops->acpi_op_filter) {
+		result = ops->acpi_op_filter(handle, lvl,
+					     ops->acpi_op_filter_arg);
+		if (ACPI_FAILURE(result))
+			return result;
+	}
+
 	/*
 	 * We may already have an acpi_device from a previous enumeration.  If
 	 * so, we needn't add it again, but we may still have to start it.
@@ -1500,8 +1508,8 @@ static acpi_status acpi_bus_check_add(acpi_handle handle, u32 lvl,
 	return AE_OK;
 }
 
-static int acpi_bus_scan(acpi_handle handle, struct acpi_bus_ops *ops,
-			 struct acpi_device **child)
+int acpi_bus_scan(acpi_handle handle, struct acpi_bus_ops *ops,
+		  struct acpi_device **child)
 {
 	acpi_status status;
 	void *device = NULL;
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 0daa0fb..361a5ea 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -98,6 +98,8 @@ typedef void (*acpi_op_notify) (struct acpi_device * device, u32 event);
 struct acpi_bus_ops {
 	u32 acpi_op_add:1;
 	u32 acpi_op_start:1;
+	acpi_status (*acpi_op_filter)(acpi_handle, u32, void *);
+	void *acpi_op_filter_arg;
 };
 
 struct acpi_device_ops {
diff --git a/include/acpi/acpi_hotplug.h b/include/acpi/acpi_hotplug.h
index 298f679..d39dece 100644
--- a/include/acpi/acpi_hotplug.h
+++ b/include/acpi/acpi_hotplug.h
@@ -183,6 +183,21 @@ extern acpi_status acpihp_slot_get_status(struct acpihp_slot *slot,
 extern acpi_status acpihp_slot_poweron(struct acpihp_slot *slot);
 extern acpi_status acpihp_slot_poweroff(struct acpihp_slot *slot);
 
+/*
+ * Scan and create ACPI device objects for devices attached to the handle,
+ * but don't cross the hotplug slot boundary.
+ */
+extern int acpihp_add_devices(acpi_handle handle, struct acpi_device **child);
+
+typedef acpi_status (*acpihp_walk_device_cb)(struct acpi_device *acpi_device,
+					     void *argp);
+/*
+ * Walk all ACPI device objects attached to an ACPI hotplug slot,
+ * but don't cross the hotplug slot boundary.
+ */
+extern int acpihp_walk_devices(acpi_handle handle,
+			       acpihp_walk_device_cb cb, void *argp);
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
