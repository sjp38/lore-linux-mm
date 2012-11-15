Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 629CF6B00C1
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 05:23:01 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so705843bkc.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 02:23:00 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH v2 2/3] acpi: Introduce prepare_remove operation in acpi_device_ops
Date: Thu, 15 Nov 2012 11:22:49 +0100
Message-Id: <1352974970-6643-3-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

This function should be registered for devices that need to execute some
non-driver core/acpi related action in order to be safely removed. If
the removal preparation is successful, the acpi/driver core can continue with
removing the device.

Make acpi_bus_remove call the device-specific prepare_remove callback before
removing the device. If prepare_remove fails, the removal is aborted.

Also introduce acpi_device_prepare_remove which will call the device-specific
prepare_remove callback on driver unbind or device reprobe requests from the
device-driver core.

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/scan.c     |   21 ++++++++++++++++++++-
 include/acpi/acpi_bus.h |    2 ++
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 95ff1e8..725b012 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -582,11 +582,23 @@ static int acpi_device_remove(struct device * dev)
 	return 0;
 }
 
+static int acpi_device_prepare_remove(struct device *dev)
+{
+	struct acpi_device *acpi_dev = to_acpi_device(dev);
+	struct acpi_driver *acpi_drv = acpi_dev->driver;
+	int ret = 0;
+
+	if (acpi_drv && acpi_drv->ops.prepare_remove)
+		ret = acpi_drv->ops.prepare_remove(acpi_dev);
+	return ret;
+}
+
 struct bus_type acpi_bus_type = {
 	.name		= "acpi",
 	.match		= acpi_bus_match,
 	.probe		= acpi_device_probe,
 	.remove		= acpi_device_remove,
+	.prepare_remove	= acpi_device_prepare_remove,
 	.uevent		= acpi_device_uevent,
 };
 
@@ -1349,10 +1361,16 @@ static int acpi_device_set_context(struct acpi_device *device)
 
 static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
+	int ret = 0;
 	if (!dev)
 		return -EINVAL;
 
 	dev->removal_type = ACPI_BUS_REMOVAL_EJECT;
+
+	if (dev->driver && dev->driver->ops.prepare_remove)
+		ret = dev->driver->ops.prepare_remove(dev);
+	if (ret)
+		return ret;
 	device_release_driver(&dev->dev);
 
 	if (!rmdevice)
@@ -1671,7 +1689,8 @@ int acpi_bus_trim(struct acpi_device *start, int rmdevice)
 				err = acpi_bus_remove(child, rmdevice);
 			else
 				err = acpi_bus_remove(child, 1);
-
+			if (err)
+				return err;
 			continue;
 		}
 
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index e04ce7b..1a13c82 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -94,6 +94,7 @@ typedef int (*acpi_op_start) (struct acpi_device * device);
 typedef int (*acpi_op_bind) (struct acpi_device * device);
 typedef int (*acpi_op_unbind) (struct acpi_device * device);
 typedef void (*acpi_op_notify) (struct acpi_device * device, u32 event);
+typedef int (*acpi_op_prepare_remove) (struct acpi_device *device);
 
 struct acpi_bus_ops {
 	u32 acpi_op_add:1;
@@ -107,6 +108,7 @@ struct acpi_device_ops {
 	acpi_op_bind bind;
 	acpi_op_unbind unbind;
 	acpi_op_notify notify;
+	acpi_op_prepare_remove prepare_remove;
 };
 
 #define ACPI_DRIVER_ALL_NOTIFY_EVENTS	0x1	/* system AND device events */
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
