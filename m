Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6A1C86B0099
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:27:23 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 06/11] ACPI: Add ACPI resource hotplug handler
Date: Wed, 12 Dec 2012 16:17:18 -0700
Message-Id: <1355354243-18657-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

Added ACPI resource handler for hotplug operations.  The handler,
acpi_set_hp_device(), sets device resource information to a hotplug
request, which is then used by the CPU and memory handlers.
For setting the device resource information, acpi_scan_hp_devices()
walks the acpi_device tree from a target device, and calls .resource
of ACPI drivers.

For hot-add, acpi_set_hp_device() is called right after the ACPI bus
handler so that it can walk through new acpi_device objects.  For 
hot-delete, it is called at the begging of the validate phase so that
other validate handlers can use the device resource information for
their validations.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 drivers/acpi/Makefile      |  1 +
 drivers/acpi/bus.c         |  1 +
 drivers/acpi/hp_resource.c | 86 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/internal.h    |  1 +
 include/acpi/acpi_bus.h    |  4 +++
 5 files changed, 93 insertions(+)
 create mode 100644 drivers/acpi/hp_resource.c

diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index 2a4502b..6ef20f1 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -34,6 +34,7 @@ acpi-$(CONFIG_ACPI_SLEEP)	+= proc.o
 acpi-y				+= bus.o glue.o
 acpi-y				+= scan.o
 acpi-y				+= resource.o
+acpi-y				+= hp_resource.o
 acpi-y				+= processor_core.o
 acpi-y				+= ec.o
 acpi-$(CONFIG_ACPI_DOCK)	+= dock.o
diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 341db34..808d6e9 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -1236,6 +1236,7 @@ static int __init acpi_init(void)
 	acpi_sleep_proc_init();
 	acpi_wakeup_device_init();
 	acpi_hp_init();
+	acpi_hp_res_init();
 	return 0;
 }
 
diff --git a/drivers/acpi/hp_resource.c b/drivers/acpi/hp_resource.c
new file mode 100644
index 0000000..7073feb
--- /dev/null
+++ b/drivers/acpi/hp_resource.c
@@ -0,0 +1,86 @@
+/*
+ * hp_resource.c - Setup hot-plug device resource information
+ *
+ * Copyright (C) 2012 Hewlett-Packard Development Company, L.P.
+ *	Toshi Kani <toshi.kani@hp.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/list.h>
+#include <linux/hotplug.h>
+#include <linux/acpi.h>
+
+#include "internal.h"
+
+static int
+acpi_set_hp_device(struct acpi_device *device, struct hp_request *req)
+{
+	int ret;
+
+	if (!device->driver) {
+		dev_dbg(&device->dev, "driver not bound\n");
+		return 0;
+	}
+
+	if (!device->driver->ops.resource)
+		return 0;
+
+	ret = device->driver->ops.resource(device, req);
+	if (ret) {
+		dev_err(&device->dev, "ops.resource failed (%d)\n", ret);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+acpi_scan_hp_devices(struct acpi_device *device, struct hp_request *req)
+{
+	struct acpi_device *child = NULL;
+
+	if (acpi_set_hp_device(device, req))
+		return 0;
+
+	list_for_each_entry(child, &device->children, node)
+		acpi_scan_hp_devices(child, req);
+
+	return 0;
+}
+
+static int acpi_set_hp_resources(struct hp_request *req, int rollback)
+{
+	acpi_handle handle = (acpi_handle) req->handle;
+	struct acpi_device *device = NULL;
+
+	if (rollback)
+		return 0;
+
+	/* only handle hot-plug operation */
+	if (!hp_is_hotplug_op(req->operation))
+		return 0;
+
+	if (acpi_bus_get_device(handle, &device)) {
+		acpi_handle_err(handle, "acpi_bus_get_device failed\n");
+		return -EINVAL;
+	}
+
+	acpi_scan_hp_devices(device, req);
+
+	return 0;
+}
+
+void __init acpi_hp_res_init(void)
+{
+	hp_register_handler(HP_ADD_EXECUTE, acpi_set_hp_resources,
+				HP_ACPI_RES_ADD_EXECUTE_ORDER);
+	hp_register_handler(HP_DEL_VALIDATE, acpi_set_hp_resources,
+				HP_ACPI_RES_DEL_VALIDATE_ORDER);
+}
diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
index 3c407cd..7aff137 100644
--- a/drivers/acpi/internal.h
+++ b/drivers/acpi/internal.h
@@ -26,6 +26,7 @@
 int init_acpi_device_notify(void);
 int acpi_scan_init(void);
 int acpi_sysfs_init(void);
+void acpi_hp_res_init(void);
 
 #ifdef CONFIG_DEBUG_FS
 extern struct dentry *acpi_debugfs_dir;
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 7ced5dc..10031a8 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -27,6 +27,7 @@
 #define __ACPI_BUS_H__
 
 #include <linux/device.h>
+#include <linux/hotplug.h>
 
 #include <acpi/acpi.h>
 
@@ -94,6 +95,8 @@ typedef int (*acpi_op_start) (struct acpi_device * device);
 typedef int (*acpi_op_bind) (struct acpi_device * device);
 typedef int (*acpi_op_unbind) (struct acpi_device * device);
 typedef void (*acpi_op_notify) (struct acpi_device * device, u32 event);
+typedef int (*acpi_op_resource) (struct acpi_device *device,
+			struct hp_request *hp_req);
 
 struct acpi_bus_ops {
 	u32 acpi_op_add:1;
@@ -107,6 +110,7 @@ struct acpi_device_ops {
 	acpi_op_bind bind;
 	acpi_op_unbind unbind;
 	acpi_op_notify notify;
+	acpi_op_resource resource;
 };
 
 #define ACPI_DRIVER_ALL_NOTIFY_EVENTS	0x1	/* system AND device events */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
