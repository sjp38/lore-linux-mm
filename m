Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3E8F36B005D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:51:57 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3668022pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:51:56 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 11/13] ACPIHP: block ACPI device driver from unloading when doing hotplug
Date: Sun,  4 Nov 2012 20:50:13 +0800
Message-Id: <1352033415-5606-12-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

The ACPI hotplug driver depends on ACPI device drivers to configure or
unconfigure ACPI devices. The hotplug driver will be confused if ACPI
device drivers are unloaded when there are ongoing hotplug operations.
So block ACPI device driver unbinding/unloading by holding the device
lock when executing hotplug operations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/hotplug/configure.c |   18 ++++++++++++++++--
 drivers/acpi/hotplug/device.c    |    6 ------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/hotplug/configure.c b/drivers/acpi/hotplug/configure.c
index 3209d14b..9f3ea97 100644
--- a/drivers/acpi/hotplug/configure.c
+++ b/drivers/acpi/hotplug/configure.c
@@ -37,7 +37,9 @@ enum config_op_code {
 	DRV_OP_POST_RELEASE,
 	DRV_OP_PRE_UNCONFIGURE,
 	DRV_OP_UNCONFIGURE,
-	DRV_OP_POST_UNCONFIGURE
+	DRV_OP_POST_UNCONFIGURE,
+	DRV_OP_LOCK_DEVICE,
+	DRV_OP_UNLOCK_DEVICE,
 };
 
 /* All devices will be configured in following order. */
@@ -98,6 +100,12 @@ static int acpihp_drv_invoke_method(enum config_op_code  opcode,
 		return acpihp_dev_unconfigure(dev);
 	case DRV_OP_POST_UNCONFIGURE:
 		return acpihp_dev_post_unconfigure(dev);
+	case DRV_OP_LOCK_DEVICE:
+		device_lock(&dev->dev);
+		return 0;
+	case DRV_OP_UNLOCK_DEVICE:
+		device_unlock(&dev->dev);
+		return 0;
 	default:
 		BUG_ON(opcode);
 		return -ENOSYS;
@@ -122,7 +130,9 @@ static int acpihp_drv_call_method(enum config_op_code opcode,
 		result = acpihp_drv_invoke_method(opcode, slot, acpi_dev, 0);
 		if (result)
 			break;
-		acpihp_drv_update_dev_state(np, state);
+		if (opcode != DRV_OP_LOCK_DEVICE &&
+		    opcode != DRV_OP_UNLOCK_DEVICE)
+			acpihp_drv_update_dev_state(np, state);
 	}
 	klist_iter_exit(&iter);
 
@@ -249,6 +259,7 @@ int acpihp_drv_configure(struct list_head *list)
 		acpihp_slot_change_state(dep->slot,
 					 ACPIHP_SLOT_STATE_CONFIGURING);
 
+	acpihp_drv_walk_devs(&head, DRV_OP_LOCK_DEVICE, 0, false);
 	result = acpihp_drv_walk_devs(&head, DRV_OP_PRE_CONFIGURE,
 				      DEVICE_STATE_PRE_CONFIGURE, false);
 	if (!result)
@@ -258,6 +269,7 @@ int acpihp_drv_configure(struct list_head *list)
 		post = ACPIHP_DEV_POST_CMD_ROLLBACK;
 	acpihp_drv_walk_devs_post(&head, DRV_OP_POST_CONFIGURE,
 				  DEVICE_STATE_CONNECTED, post, false);
+	acpihp_drv_walk_devs(&head, DRV_OP_UNLOCK_DEVICE, 0, false);
 
 	list_for_each_entry(dep, &head, node)
 		acpihp_drv_update_slot_state(dep->slot);
@@ -328,9 +340,11 @@ int acpihp_drv_unconfigure(struct list_head *list)
 		acpihp_slot_change_state(dep->slot,
 					 ACPIHP_SLOT_STATE_UNCONFIGURING);
 
+	acpihp_drv_walk_devs(&head, DRV_OP_LOCK_DEVICE, 0, false);
 	result = acpihp_drv_release(&head);
 	if (!result)
 		__acpihp_drv_unconfigure(&head);
+	acpihp_drv_walk_devs(&head, DRV_OP_UNLOCK_DEVICE, 0, false);
 
 	list_for_each_entry(dep, &head, node)
 		acpihp_drv_update_slot_state(dep->slot);
diff --git a/drivers/acpi/hotplug/device.c b/drivers/acpi/hotplug/device.c
index c9d550f..6d60bb0 100644
--- a/drivers/acpi/hotplug/device.c
+++ b/drivers/acpi/hotplug/device.c
@@ -62,14 +62,12 @@ int acpihp_dev_##method(struct acpi_device *device, type val) \
 { \
 	int ret; \
 	BUG_ON(device == NULL); \
-	device_lock(&device->dev); \
 	if (!device->driver || !device->driver->ops.hp_ops) \
 		ret = (err); \
 	else if (!device->driver->ops.hp_ops->method) \
 		ret = (def); \
 	else \
 		ret = device->driver->ops.hp_ops->method(device, val); \
-	device_unlock(&device->dev); \
 	return ret; \
 } \
 EXPORT_SYMBOL_GPL(acpihp_dev_##method)
@@ -79,14 +77,12 @@ int acpihp_dev_##method(struct acpi_device *device, type val) \
 { \
 	int ret = 0; \
 	BUG_ON(device == NULL); \
-	device_lock(&device->dev); \
 	if (!device->driver || !device->driver->ops.hp_ops) \
 		ret = (err); \
 	else if (!device->driver->ops.hp_ops->method) \
 		ret = (def); \
 	else \
 		device->driver->ops.hp_ops->method(device, val); \
-	device_unlock(&device->dev); \
 	return ret; \
 } \
 EXPORT_SYMBOL_GPL(acpihp_dev_##method)
@@ -96,14 +92,12 @@ int acpihp_dev_##method(struct acpi_device *device) \
 { \
 	int ret = 0; \
 	BUG_ON(device == NULL); \
-	device_lock(&device->dev); \
 	if (!device->driver || !device->driver->ops.hp_ops) \
 		ret = (err); \
 	else if (!device->driver->ops.hp_ops->method) \
 		ret = (def); \
 	else \
 		device->driver->ops.hp_ops->method(device);\
-	device_unlock(&device->dev); \
 	return ret; \
 } \
 EXPORT_SYMBOL_GPL(acpihp_dev_##method)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
