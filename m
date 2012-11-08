Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 8FD996B005D
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 13:29:42 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jm1so1587964bkc.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 10:29:41 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH 2/3] acpi: Make acpi_bus_trim handle device removal preparation
Date: Thu,  8 Nov 2012 19:29:30 +0100
Message-Id: <1352399371-8015-3-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com
Cc: rjw@sisk.pl, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

A new argument is added to acpi_bus_trim, which indicates if we are preparing
for removal or performing the actual ACPI removal. This is needed for safe
removal of memory devices.

The argument change would not be needed if the existing argument rmdevice of
acpi_bus_trim could be used instead. What is the role of rmdevice argument? As
far as I can tell the rmdevice argument is never used at the moment
(acpi_bus_trim is called with rmdevice=1 from all its call sites. It is never
called with rmdevice=0)

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/acpi_memhotplug.c     |    2 +-
 drivers/acpi/dock.c                |    2 +-
 drivers/acpi/scan.c                |   32 +++++++++++++++++++++++++++++---
 drivers/pci/hotplug/acpiphp_glue.c |    4 ++--
 drivers/pci/hotplug/sgi_hotplug.c  |    2 +-
 include/acpi/acpi_bus.h            |    2 +-
 6 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 92c973a..7fcc844 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -427,7 +427,7 @@ static void acpi_memory_device_notify(acpi_handle handle, u32 event, void *data)
 		/*
 		 * Invoke acpi_bus_trim() to remove memory device
 		 */
-		acpi_bus_trim(device, 1);
+		acpi_bus_trim(device, 1, 0);
 
 		/* _EJ0 succeeded; _OST is not necessary */
 		return;
diff --git a/drivers/acpi/dock.c b/drivers/acpi/dock.c
index ae4ebf2..9e37b49 100644
--- a/drivers/acpi/dock.c
+++ b/drivers/acpi/dock.c
@@ -345,7 +345,7 @@ static void dock_remove_acpi_device(acpi_handle handle)
 	int ret;
 
 	if (!acpi_bus_get_device(handle, &device)) {
-		ret = acpi_bus_trim(device, 1);
+		ret = acpi_bus_trim(device, 1, 0);
 		if (ret)
 			pr_debug("error removing bus, %x\n", -ret);
 	}
diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 95ff1e8..b1001a4 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -121,7 +121,12 @@ void acpi_bus_hot_remove_device(void *context)
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO,
 		"Hot-removing device %s...\n", dev_name(&device->dev)));
 
-	if (acpi_bus_trim(device, 1)) {
+	if (acpi_bus_trim(device, 1, 1)) {
+		pr_err("Preparing to removing device failed\n");
+		goto err_out;
+	}
+
+	if (acpi_bus_trim(device, 1, 0)) {
 		printk(KERN_ERR PREFIX
 				"Removing device failed\n");
 		goto err_out;
@@ -1347,6 +1352,19 @@ static int acpi_device_set_context(struct acpi_device *device)
 	return -ENODEV;
 }
 
+static int acpi_bus_prepare_remove(struct acpi_device *dev)
+{
+	int ret = 0;
+
+	if (!dev)
+		return -EINVAL;
+
+	if (dev->driver && dev->driver->ops.prepare_remove)
+		ret = dev->driver->ops.prepare_remove(dev);
+
+	return ret;
+}
+
 static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
 	if (!dev)
@@ -1640,7 +1658,11 @@ int acpi_bus_start(struct acpi_device *device)
 }
 EXPORT_SYMBOL(acpi_bus_start);
 
-int acpi_bus_trim(struct acpi_device *start, int rmdevice)
+/* acpi_bus_trim: Remove or prepare to remove a device and its children.
+ * @device: the device to remove or prepare to remove from.
+ * @prepare: If 1, prepare for removal. If 0, perform actual removal.
+ */
+int acpi_bus_trim(struct acpi_device *start, int rmdevice, int prepare)
 {
 	acpi_status status;
 	struct acpi_device *parent, *child;
@@ -1667,7 +1689,11 @@ int acpi_bus_trim(struct acpi_device *start, int rmdevice)
 			child = parent;
 			parent = parent->parent;
 
-			if (level == 0)
+			if (prepare) {
+				err = acpi_bus_prepare_remove(child);
+				if (err)
+					return err;
+			} else if (level == 0)
 				err = acpi_bus_remove(child, rmdevice);
 			else
 				err = acpi_bus_remove(child, 1);
diff --git a/drivers/pci/hotplug/acpiphp_glue.c b/drivers/pci/hotplug/acpiphp_glue.c
index 3d6d4fd..bc10b61 100644
--- a/drivers/pci/hotplug/acpiphp_glue.c
+++ b/drivers/pci/hotplug/acpiphp_glue.c
@@ -748,7 +748,7 @@ static int acpiphp_bus_add(struct acpiphp_func *func)
 		/* this shouldn't be in here, so remove
 		 * the bus then re-add it...
 		 */
-		ret_val = acpi_bus_trim(device, 1);
+		ret_val = acpi_bus_trim(device, 1, 0);
 		dbg("acpi_bus_trim return %x\n", ret_val);
 	}
 
@@ -781,7 +781,7 @@ static int acpiphp_bus_trim(acpi_handle handle)
 		return retval;
 	}
 
-	retval = acpi_bus_trim(device, 1);
+	retval = acpi_bus_trim(device, 1, 0);
 	if (retval)
 		err("cannot remove from acpi list\n");
 
diff --git a/drivers/pci/hotplug/sgi_hotplug.c b/drivers/pci/hotplug/sgi_hotplug.c
index f64ca92..3655de3 100644
--- a/drivers/pci/hotplug/sgi_hotplug.c
+++ b/drivers/pci/hotplug/sgi_hotplug.c
@@ -539,7 +539,7 @@ static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
 				ret = acpi_bus_get_device(chandle,
 							  &device);
 				if (ACPI_SUCCESS(ret))
-					acpi_bus_trim(device, 1);
+					acpi_bus_trim(device, 1, 0);
 			}
 		}
 
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 6ef1692..063c470 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -359,7 +359,7 @@ void acpi_bus_unregister_driver(struct acpi_driver *driver);
 int acpi_bus_add(struct acpi_device **child, struct acpi_device *parent,
 		 acpi_handle handle, int type);
 void acpi_bus_hot_remove_device(void *context);
-int acpi_bus_trim(struct acpi_device *start, int rmdevice);
+int acpi_bus_trim(struct acpi_device *start, int rmdevice, int prepare);
 int acpi_bus_start(struct acpi_device *device);
 acpi_status acpi_bus_get_ejd(acpi_handle handle, acpi_handle * ejd);
 int acpi_match_device_ids(struct acpi_device *device,
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
