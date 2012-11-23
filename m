Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 94F486B005A
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 12:50:49 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so4656099bkc.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:50:48 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH v3 1/3] acpi: Introduce prepare_remove operation in acpi_device_ops
Date: Fri, 23 Nov 2012 18:50:35 +0100
Message-Id: <1353693037-21704-2-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

This function should be registered for devices that need to execute some
non-acpi related action in order to be safely removed. If this function
returns zero, the acpi core can continue with removing the device.

Make acpi_bus_remove call the device-specific prepare_remove callback before
removing the device. If prepare_remove fails, the removal is aborted.

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/scan.c     |    9 ++++++++-
 include/acpi/acpi_bus.h |    2 ++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 8c4ac6d..e1c1d5d 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -1380,10 +1380,16 @@ static int acpi_device_set_context(struct acpi_device *device)
 
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
@@ -1702,7 +1708,8 @@ int acpi_bus_trim(struct acpi_device *start, int rmdevice)
 				err = acpi_bus_remove(child, rmdevice);
 			else
 				err = acpi_bus_remove(child, 1);
-
+			if (err)
+				return err;
 			continue;
 		}
 
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 7ced5dc..9d94a55 100644
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
