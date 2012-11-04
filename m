Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id ECD116B005A
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:08:53 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2527790dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:08:53 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part3 2/2] ACPIHP/container: move container.c into drivers/acpi/hotplug
Date: Sun,  4 Nov 2012 23:08:18 +0800
Message-Id: <1352041698-6243-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352041698-6243-1-git-send-email-jiang.liu@huawei.com>
References: <1352041698-6243-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Now the ACPI container driver is only used to support the ACPI system
device hotplug framework, so move it into drivers/acpi/hotplug.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/Makefile            |    1 -
 drivers/acpi/container.c         |  124 --------------------------------------
 drivers/acpi/hotplug/Makefile    |    2 +
 drivers/acpi/hotplug/container.c |  124 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 126 insertions(+), 125 deletions(-)
 delete mode 100644 drivers/acpi/container.c
 create mode 100644 drivers/acpi/hotplug/container.c

diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index 17bea6c..fa5b6d3 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -53,7 +53,6 @@ obj-$(CONFIG_ACPI_FAN)		+= fan.o
 obj-$(CONFIG_ACPI_VIDEO)	+= video.o
 obj-$(CONFIG_ACPI_PCI_SLOT)	+= pci_slot.o
 obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
-obj-$(CONFIG_ACPI_CONTAINER)	+= container.o
 obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
 obj-$(CONFIG_ACPI_HOTPLUG_MEMORY) += acpi_memhotplug.o
 obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
diff --git a/drivers/acpi/container.c b/drivers/acpi/container.c
deleted file mode 100644
index ed1e59f..0000000
--- a/drivers/acpi/container.c
+++ /dev/null
@@ -1,124 +0,0 @@
-/*
- * acpi_container.c  - ACPI Generic Container Driver
- * ($Revision: )
- *
- * Copyright (C) 2004 Anil S Keshavamurthy (anil.s.keshavamurthy@intel.com)
- * Copyright (C) 2004 Keiichiro Tokunaga (tokunaga.keiich@jp.fujitsu.com)
- * Copyright (C) 2004 Motoyuki Ito (motoyuki@soft.fujitsu.com)
- * Copyright (C) 2004 Intel Corp.
- * Copyright (C) 2004 FUJITSU LIMITED
- * Copyright (C) 2012 Jiang Liu (jiang.liu@huawei.com)
- *
- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- *
- *  This program is free software; you can redistribute it and/or modify
- *  it under the terms of the GNU General Public License as published by
- *  the Free Software Foundation; either version 2 of the License, or (at
- *  your option) any later version.
- *
- *  This program is distributed in the hope that it will be useful, but
- *  WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  General Public License for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
- *
- * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- */
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/slab.h>
-#include <linux/types.h>
-#include <linux/acpi.h>
-#include <acpi/acpi_bus.h>
-#include <acpi/acpi_drivers.h>
-#include <acpi/acpi_hotplug.h>
-
-#define PREFIX "ACPI: "
-
-#define ACPI_CONTAINER_DEVICE_NAME	"ACPI container device"
-#define ACPI_CONTAINER_CLASS		"container"
-
-#define _COMPONENT			ACPI_CONTAINER_COMPONENT
-ACPI_MODULE_NAME("container");
-
-MODULE_AUTHOR("Anil S Keshavamurthy");
-MODULE_DESCRIPTION("ACPI container driver");
-MODULE_LICENSE("GPL");
-
-static int acpi_container_add(struct acpi_device *device);
-static int acpi_container_remove(struct acpi_device *device, int type);
-
-static int acpihp_container_get_devinfo(struct acpi_device *device,
-					struct acpihp_dev_info *info);
-static int acpihp_container_configure(struct acpi_device *device,
-				      struct acpihp_cancel_context *argp);
-static void acpihp_container_unconfigure(struct acpi_device *device);
-
-struct acpihp_dev_ops acpihp_container_ops = {
-	.get_info = acpihp_container_get_devinfo,
-	.configure = acpihp_container_configure,
-	.unconfigure = acpihp_container_unconfigure,
-};
-
-static const struct acpi_device_id container_device_ids[] = {
-	{"ACPI0004", 0},
-	{"PNP0A05", 0},
-	{"PNP0A06", 0},
-	{"", 0},
-};
-MODULE_DEVICE_TABLE(acpi, container_device_ids);
-
-static struct acpi_driver acpi_container_driver = {
-	.name = "container",
-	.class = ACPI_CONTAINER_CLASS,
-	.ids = container_device_ids,
-	.ops = {
-		.add = acpi_container_add,
-		.remove = acpi_container_remove,
-		.hp_ops = &acpihp_container_ops,
-	},
-};
-
-static int acpi_container_add(struct acpi_device *device)
-{
-	if (!device) {
-		printk(KERN_ERR PREFIX "device is NULL\n");
-		return -EINVAL;
-	}
-
-	strcpy(acpi_device_name(device), ACPI_CONTAINER_DEVICE_NAME);
-	strcpy(acpi_device_class(device), ACPI_CONTAINER_CLASS);
-	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device <%s> bid <%s>\n",
-			  acpi_device_name(device), acpi_device_bid(device)));
-
-	return 0;
-}
-
-static int acpi_container_remove(struct acpi_device *device, int type)
-{
-	return AE_OK;
-}
-
-static int acpihp_container_get_devinfo(struct acpi_device *device,
-					struct acpihp_dev_info *info)
-{
-	info->type = ACPIHP_DEV_TYPE_CONTAINER;
-
-	return 0;
-}
-
-static int acpihp_container_configure(struct acpi_device *device,
-				      struct acpihp_cancel_context *argp)
-{
-	return 0;
-}
-
-static void acpihp_container_unconfigure(struct acpi_device *device)
-{
-}
-
-module_acpi_driver(acpi_container_driver);
diff --git a/drivers/acpi/hotplug/Makefile b/drivers/acpi/hotplug/Makefile
index 640a625..72a782f 100644
--- a/drivers/acpi/hotplug/Makefile
+++ b/drivers/acpi/hotplug/Makefile
@@ -18,3 +18,5 @@ acpihp_drv-y					+= configure.o
 acpihp_drv-y					+= state_machine.o
 acpihp_drv-y					+= sysfs.o
 acpihp_drv-y					+= event.o
+
+obj-$(CONFIG_ACPI_CONTAINER)			+= container.o
diff --git a/drivers/acpi/hotplug/container.c b/drivers/acpi/hotplug/container.c
new file mode 100644
index 0000000..ed1e59f
--- /dev/null
+++ b/drivers/acpi/hotplug/container.c
@@ -0,0 +1,124 @@
+/*
+ * acpi_container.c  - ACPI Generic Container Driver
+ * ($Revision: )
+ *
+ * Copyright (C) 2004 Anil S Keshavamurthy (anil.s.keshavamurthy@intel.com)
+ * Copyright (C) 2004 Keiichiro Tokunaga (tokunaga.keiich@jp.fujitsu.com)
+ * Copyright (C) 2004 Motoyuki Ito (motoyuki@soft.fujitsu.com)
+ * Copyright (C) 2004 Intel Corp.
+ * Copyright (C) 2004 FUJITSU LIMITED
+ * Copyright (C) 2012 Jiang Liu (jiang.liu@huawei.com)
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or (at
+ *  your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful, but
+ *  WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License along
+ *  with this program; if not, write to the Free Software Foundation, Inc.,
+ *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/acpi.h>
+#include <acpi/acpi_bus.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/acpi_hotplug.h>
+
+#define PREFIX "ACPI: "
+
+#define ACPI_CONTAINER_DEVICE_NAME	"ACPI container device"
+#define ACPI_CONTAINER_CLASS		"container"
+
+#define _COMPONENT			ACPI_CONTAINER_COMPONENT
+ACPI_MODULE_NAME("container");
+
+MODULE_AUTHOR("Anil S Keshavamurthy");
+MODULE_DESCRIPTION("ACPI container driver");
+MODULE_LICENSE("GPL");
+
+static int acpi_container_add(struct acpi_device *device);
+static int acpi_container_remove(struct acpi_device *device, int type);
+
+static int acpihp_container_get_devinfo(struct acpi_device *device,
+					struct acpihp_dev_info *info);
+static int acpihp_container_configure(struct acpi_device *device,
+				      struct acpihp_cancel_context *argp);
+static void acpihp_container_unconfigure(struct acpi_device *device);
+
+struct acpihp_dev_ops acpihp_container_ops = {
+	.get_info = acpihp_container_get_devinfo,
+	.configure = acpihp_container_configure,
+	.unconfigure = acpihp_container_unconfigure,
+};
+
+static const struct acpi_device_id container_device_ids[] = {
+	{"ACPI0004", 0},
+	{"PNP0A05", 0},
+	{"PNP0A06", 0},
+	{"", 0},
+};
+MODULE_DEVICE_TABLE(acpi, container_device_ids);
+
+static struct acpi_driver acpi_container_driver = {
+	.name = "container",
+	.class = ACPI_CONTAINER_CLASS,
+	.ids = container_device_ids,
+	.ops = {
+		.add = acpi_container_add,
+		.remove = acpi_container_remove,
+		.hp_ops = &acpihp_container_ops,
+	},
+};
+
+static int acpi_container_add(struct acpi_device *device)
+{
+	if (!device) {
+		printk(KERN_ERR PREFIX "device is NULL\n");
+		return -EINVAL;
+	}
+
+	strcpy(acpi_device_name(device), ACPI_CONTAINER_DEVICE_NAME);
+	strcpy(acpi_device_class(device), ACPI_CONTAINER_CLASS);
+	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device <%s> bid <%s>\n",
+			  acpi_device_name(device), acpi_device_bid(device)));
+
+	return 0;
+}
+
+static int acpi_container_remove(struct acpi_device *device, int type)
+{
+	return AE_OK;
+}
+
+static int acpihp_container_get_devinfo(struct acpi_device *device,
+					struct acpihp_dev_info *info)
+{
+	info->type = ACPIHP_DEV_TYPE_CONTAINER;
+
+	return 0;
+}
+
+static int acpihp_container_configure(struct acpi_device *device,
+				      struct acpihp_cancel_context *argp)
+{
+	return 0;
+}
+
+static void acpihp_container_unconfigure(struct acpi_device *device)
+{
+}
+
+module_acpi_driver(acpi_container_driver);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
