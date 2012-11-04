Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 348D46B006C
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:50:47 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3650067pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:50:46 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 03/13] ACPIHP: add callbacks into acpi_device_ops to support new hotplug framework
Date: Sun,  4 Nov 2012 20:50:05 +0800
Message-Id: <1352033415-5606-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

Add new callbacks into struct acpi_device_ops to provide better error
handling, error recovery and cancellation for ACPI based system device
hotplug.

There are three major operations and each major operation is divided
into three minor steps.
1) pre_configure, configure, post_configure
	Add an ACPI device into running system and rollback if error
	happens or has been cancelled.
2) pre_release, release, post_release
	Reclaim an ACPI device from running system and rollback if error
	happens or has been cancelled. It's very important to privode a
	mechanism to cancel ongoing memory hot-removal operations
	because it's may take very long or even endless time to reclaim
	a memory device.
3) pre_unconfigure, unconfigure, post_unconfigure
	remove an ACPI device from running system and release all
	resources associated with it.

There's also another callback to query status and information about an
ACPI device.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
---
 drivers/acpi/hotplug/device.c |   93 +++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_bus.h       |    3 ++
 include/acpi/acpi_hotplug.h   |   64 ++++++++++++++++++++++++++++
 3 files changed, 160 insertions(+)

diff --git a/drivers/acpi/hotplug/device.c b/drivers/acpi/hotplug/device.c
index 2dcdd83..c9d550f 100644
--- a/drivers/acpi/hotplug/device.c
+++ b/drivers/acpi/hotplug/device.c
@@ -1,6 +1,7 @@
 /*
  * Copyright (C) 2012 Huawei Tech. Co., Ltd.
  * Copyright (C) 2012 Jiang Liu <jiang.liu@huawei.com>
+ * Copyright (C) 2012 Hanjun Guo <guohanjun@huawei.com>
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
@@ -27,6 +28,98 @@
 #include <acpi/acpi_hotplug.h>
 #include "acpihp.h"
 
+int acpihp_dev_get_info(struct acpi_device *device,
+			struct acpihp_dev_info *info)
+{
+	int ret = -ENOSYS;
+
+	acpihp_dev_get_type(device->handle, &info->type);
+
+	device_lock(&device->dev);
+	if (device->driver && device->driver->ops.hp_ops &&
+	    device->driver->ops.hp_ops->get_info)
+		ret = device->driver->ops.hp_ops->get_info(device, info);
+	else
+#if 0
+		/* Turn on this once all system devices have been converted
+		 * to the new hotplug framework
+		 */
+		info->status |= ACPIHP_DEV_STATUS_IRREMOVABLE;
+#else
+		ret = 0;
+#endif
+
+	if (device->driver)
+		info->status |= ACPIHP_DEV_STATUS_ATTACHED;
+	device_unlock(&device->dev);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(acpihp_dev_get_info);
+
+#define	ACPIHP_DEFINE_FUNC1(method, def, err, type) \
+int acpihp_dev_##method(struct acpi_device *device, type val) \
+{ \
+	int ret; \
+	BUG_ON(device == NULL); \
+	device_lock(&device->dev); \
+	if (!device->driver || !device->driver->ops.hp_ops) \
+		ret = (err); \
+	else if (!device->driver->ops.hp_ops->method) \
+		ret = (def); \
+	else \
+		ret = device->driver->ops.hp_ops->method(device, val); \
+	device_unlock(&device->dev); \
+	return ret; \
+} \
+EXPORT_SYMBOL_GPL(acpihp_dev_##method)
+
+#define	ACPIHP_DEFINE_FUNC2(method, def, err, type) \
+int acpihp_dev_##method(struct acpi_device *device, type val) \
+{ \
+	int ret = 0; \
+	BUG_ON(device == NULL); \
+	device_lock(&device->dev); \
+	if (!device->driver || !device->driver->ops.hp_ops) \
+		ret = (err); \
+	else if (!device->driver->ops.hp_ops->method) \
+		ret = (def); \
+	else \
+		device->driver->ops.hp_ops->method(device, val); \
+	device_unlock(&device->dev); \
+	return ret; \
+} \
+EXPORT_SYMBOL_GPL(acpihp_dev_##method)
+
+#define	ACPIHP_DEFINE_FUNC3(method, def, err) \
+int acpihp_dev_##method(struct acpi_device *device) \
+{ \
+	int ret = 0; \
+	BUG_ON(device == NULL); \
+	device_lock(&device->dev); \
+	if (!device->driver || !device->driver->ops.hp_ops) \
+		ret = (err); \
+	else if (!device->driver->ops.hp_ops->method) \
+		ret = (def); \
+	else \
+		device->driver->ops.hp_ops->method(device);\
+	device_unlock(&device->dev); \
+	return ret; \
+} \
+EXPORT_SYMBOL_GPL(acpihp_dev_##method)
+
+ACPIHP_DEFINE_FUNC1(pre_configure, 0, 0, struct acpihp_cancel_context *);
+ACPIHP_DEFINE_FUNC1(configure, 0, -ENOSYS, struct acpihp_cancel_context *);
+ACPIHP_DEFINE_FUNC2(post_configure, 0, 0, enum acpihp_dev_post_cmd);
+
+ACPIHP_DEFINE_FUNC1(pre_release, 0, 0, struct acpihp_cancel_context *);
+ACPIHP_DEFINE_FUNC1(release, 0, 0, struct acpihp_cancel_context *);
+ACPIHP_DEFINE_FUNC2(post_release, 0, 0, enum acpihp_dev_post_cmd);
+
+ACPIHP_DEFINE_FUNC3(pre_unconfigure, 0, 0);
+ACPIHP_DEFINE_FUNC3(unconfigure, 0, -ENOSYS);
+ACPIHP_DEFINE_FUNC3(post_unconfigure, 0, 0);
+
 /*
  * When creating ACPI devices for hot-added system devices connecting to
  * a slot, don't cross the slot boundary. Otherwise it will cause
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 361a5ea..7c15521 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -109,6 +109,9 @@ struct acpi_device_ops {
 	acpi_op_bind bind;
 	acpi_op_unbind unbind;
 	acpi_op_notify notify;
+#ifdef	CONFIG_ACPI_HOTPLUG
+	struct acpihp_dev_ops *hp_ops;
+#endif	/* CONFIG_ACPI_HOTPLUG */
 };
 
 #define ACPI_DRIVER_ALL_NOTIFY_EVENTS	0x1	/* system AND device events */
diff --git a/include/acpi/acpi_hotplug.h b/include/acpi/acpi_hotplug.h
index d733f7f..35f15a8 100644
--- a/include/acpi/acpi_hotplug.h
+++ b/include/acpi/acpi_hotplug.h
@@ -63,6 +63,51 @@ struct acpihp_dev_node {
 	struct klist_node	node;
 };
 
+/* Status of ACPI system devices. */
+#define	ACPIHP_DEV_STATUS_ATTACHED	0x1	/* Device driver attached */
+#define	ACPIHP_DEV_STATUS_STARTED	0x2	/* Device started */
+#define	ACPIHP_DEV_STATUS_IRREMOVABLE	0x10000 /* Device can't be removed */
+#define	ACPIHP_DEV_STATUS_FAULT		0x20000 /* Device in fault state */
+
+struct acpihp_dev_info {
+	enum acpihp_dev_type		type;
+	uint32_t			status;
+};
+
+/* Rollback or commit changes in post_{confiure|release} */
+enum acpihp_dev_post_cmd {
+	ACPIHP_DEV_POST_CMD_ROLLBACK,
+	ACPIHP_DEV_POST_CMD_COMMIT
+};
+
+/*
+ * ACPI system device drivers may check cancellations of hotplug operations
+ * by invoking the callback.
+ */
+struct acpihp_cancel_context {
+	int (*check_cancel)(struct acpihp_cancel_context *ctx);
+};
+
+/*
+ * Callback hooks provided by ACPI device drivers to support system device
+ * hotplug. To support hotplug, an ACPI system device driver should implement
+ * configure(), unconfigure() and get_info() at a minimal.
+ */
+struct acpihp_dev_ops {
+	int (*get_info)(struct acpi_device *, struct acpihp_dev_info *info);
+	int (*pre_configure)(struct acpi_device *,
+			     struct acpihp_cancel_context *);
+	int (*configure)(struct acpi_device *, struct acpihp_cancel_context *);
+	void (*post_configure)(struct acpi_device *, enum acpihp_dev_post_cmd);
+	int (*pre_release)(struct acpi_device *,
+			   struct acpihp_cancel_context *);
+	int (*release)(struct acpi_device *, struct acpihp_cancel_context *);
+	void (*post_release)(struct acpi_device *, enum acpihp_dev_post_cmd);
+	void (*pre_unconfigure)(struct acpi_device *);
+	void (*unconfigure)(struct acpi_device *);
+	void (*post_unconfigure)(struct acpi_device *);
+};
+
 /*
  * ACPI hotplug slot is an abstraction of receptacles where a group of
  * system devices could be attached, just like PCI slot in PCI hotplug.
@@ -173,6 +218,25 @@ extern int acpihp_core_init(void);
 /* Deinitialize the ACPI based system device hotplug core logic */
 extern void acpihp_core_fini(void);
 
+/* Interfaces to invoke ACPI device driver's hotplug callbacks. */
+extern int acpihp_dev_get_info(struct acpi_device *device,
+			       struct acpihp_dev_info *info);
+extern int acpihp_dev_pre_configure(struct acpi_device *device,
+				    struct acpihp_cancel_context *ctx);
+extern int acpihp_dev_configure(struct acpi_device *device,
+				struct acpihp_cancel_context *ctx);
+extern int acpihp_dev_post_configure(struct acpi_device *device,
+				     enum acpihp_dev_post_cmd cmd);
+extern int acpihp_dev_pre_release(struct acpi_device *device,
+				  struct acpihp_cancel_context *ctx);
+extern int acpihp_dev_release(struct acpi_device *device,
+			      struct acpihp_cancel_context *ctx);
+extern int acpihp_dev_post_release(struct acpi_device *device,
+				   enum acpihp_dev_post_cmd cmd);
+extern int acpihp_dev_pre_unconfigure(struct acpi_device *device);
+extern int acpihp_dev_unconfigure(struct acpi_device *device);
+extern int acpihp_dev_post_unconfigure(struct acpi_device *device);
+
 /* Utility routines */
 extern int acpihp_dev_get_type(acpi_handle handle, enum acpihp_dev_type *type);
 extern bool acpihp_dev_match_ids(struct acpi_device_info *infop, char **ids);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
