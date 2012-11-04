Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 218466B0062
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 07:50:40 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3667633pad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 04:50:39 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part2 02/13] ACPIHP: use klist to manage ACPI devices attached to a slot
Date: Sun,  4 Nov 2012 20:50:04 +0800
Message-Id: <1352033415-5606-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
References: <1352033415-5606-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

To achieve best performance for hot-adding and resolve dependencies when
hot-removing, system devices should be configured/unconfigured in
specific order. The optimal order for hot-adding should be "container ->
memory -> CPU -> PCI host bridge" and it should be in reverse order for
hot-removing.

So classify system devices into groups according to types of devices,
and use klist to manage devices belonging to the same group.

Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 drivers/acpi/hotplug/core.c |  116 +++++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_hotplug.h |   26 ++++++++++
 2 files changed, 142 insertions(+)

diff --git a/drivers/acpi/hotplug/core.c b/drivers/acpi/hotplug/core.c
index c835a97..7ef8f9b 100644
--- a/drivers/acpi/hotplug/core.c
+++ b/drivers/acpi/hotplug/core.c
@@ -96,6 +96,23 @@ static char *acpihp_dev_pcihb_ids[] = {
 	NULL
 };
 
+static void acpihp_dev_node_get(struct klist_node *lp)
+{
+	struct acpihp_dev_node *dp;
+
+	dp = container_of(lp, struct acpihp_dev_node, node);
+	get_device(dp->dev);
+}
+
+static void acpihp_dev_node_put(struct klist_node *lp)
+{
+	struct acpihp_dev_node *dp;
+
+	dp = container_of(lp, struct acpihp_dev_node, node);
+	put_device(dp->dev);
+	kfree(dp);
+}
+
 static void acpihp_slot_release(struct device *dev)
 {
 	struct acpihp_slot *slot = to_acpihp_slot(dev);
@@ -113,6 +130,7 @@ static void acpihp_slot_release(struct device *dev)
  */
 struct acpihp_slot *acpihp_alloc_slot(acpi_handle handle, char *name)
 {
+	int i;
 	struct acpihp_slot *slot;
 
 	if (name && strlen(name) >= ACPIHP_SLOT_NAME_MAX_SIZE) {
@@ -129,6 +147,9 @@ struct acpihp_slot *acpihp_alloc_slot(acpi_handle handle, char *name)
 	slot->handle = handle;
 	INIT_LIST_HEAD(&slot->slot_list);
 	INIT_LIST_HEAD(&slot->drvdata_list);
+	for (i = ACPIHP_DEV_TYPE_UNKNOWN; i < ACPIHP_DEV_TYPE_MAX; i++)
+		klist_init(&slot->dev_lists[i],
+			   &acpihp_dev_node_get, &acpihp_dev_node_put);
 	if (name)
 		strncpy(slot->name, name, sizeof(slot->name) - 1);
 	mutex_init(&slot->slot_mutex);
@@ -387,6 +408,101 @@ acpi_status acpihp_slot_poweroff(struct acpihp_slot *slot)
 }
 EXPORT_SYMBOL_GPL(acpihp_slot_poweroff);
 
+/* Insert an ACPI device onto a hotplug slot's device list. */
+int acpihp_slot_add_device(struct acpihp_slot *slot, enum acpihp_dev_type type,
+			   enum acpihp_dev_state state, struct device *dev)
+{
+	struct acpihp_dev_node *np;
+
+	if (slot == NULL) {
+		ACPIHP_DEBUG("invalid parameter, slot is NULL.\n");
+		return -EINVAL;
+	} else if (dev == NULL) {
+		ACPIHP_SLOT_DEBUG(slot, "invalid parameter, dev is NULL.\n");
+		return -EINVAL;
+	} else if (type < ACPIHP_DEV_TYPE_UNKNOWN ||
+		   type >= ACPIHP_DEV_TYPE_MAX) {
+		ACPIHP_SLOT_DEBUG(slot, "device type %d is invalid.\n", type);
+		return -EINVAL;
+	}
+
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
+	if (np == NULL) {
+		ACPIHP_SLOT_WARN(slot, "fails to allocate memory.\n");
+		return -ENOMEM;
+	}
+
+	np->dev = dev;
+	np->state = state;
+	klist_add_tail(&np->node, &slot->dev_lists[type]);
+	ACPIHP_SLOT_DEBUG(slot, "add device %s to klist.\n", dev_name(dev));
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_add_device);
+
+/* Remove an ACPI device from a hotplug slot's device list. */
+int acpihp_slot_remove_device(struct acpihp_slot *slot,
+			      enum acpihp_dev_type type, struct device *dev)
+{
+	int ret = -ENOENT;
+	struct klist_iter iter;
+	struct klist_node *ip;
+	struct acpihp_dev_node *np;
+
+	if (slot == NULL) {
+		ACPIHP_DEBUG("invalid parameter, slot is NULL.\n");
+		return -EINVAL;
+	} else if (dev == NULL) {
+		ACPIHP_SLOT_DEBUG(slot, "invalid parameter, dev is NULL.\n");
+		return -EINVAL;
+	} else if (type < ACPIHP_DEV_TYPE_UNKNOWN ||
+		   type >= ACPIHP_DEV_TYPE_MAX) {
+		ACPIHP_SLOT_DEBUG(slot, "device type %d is invalid.\n", type);
+		return -EINVAL;
+	}
+
+	klist_iter_init(&slot->dev_lists[type], &iter);
+	while ((ip = klist_next(&iter)) != NULL) {
+		np = container_of(ip, struct acpihp_dev_node, node);
+		if (np->dev == dev) {
+			ACPIHP_SLOT_DEBUG(slot,
+					  "remove device %s from klist.\n",
+					  dev_name(dev));
+			klist_del(&np->node);
+			ret = 0;
+			break;
+		}
+	}
+	klist_iter_exit(&iter);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(acpihp_slot_remove_device);
+
+/* Remove all ACPI devices from the list */
+int acpihp_remove_device_list(struct klist *dev_list)
+{
+	struct klist_iter iter;
+	struct klist_node *ip;
+	struct acpihp_dev_node *np;
+
+	if (dev_list == NULL) {
+		ACPIHP_DEBUG("invalid parameter, dev_list is NULL.\n");
+		return -EINVAL;
+	}
+
+	klist_iter_init(dev_list, &iter);
+	while ((ip = klist_next(&iter)) != NULL) {
+		np = container_of(ip, struct acpihp_dev_node, node);
+		klist_del(&np->node);
+	}
+	klist_iter_exit(&iter);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(acpihp_remove_device_list);
+
 /* SYSFS interfaces */
 static ssize_t acpihp_slot_object_show(struct device *d,
 		struct device_attribute *attr, char *buf)
diff --git a/include/acpi/acpi_hotplug.h b/include/acpi/acpi_hotplug.h
index d39dece..d733f7f 100644
--- a/include/acpi/acpi_hotplug.h
+++ b/include/acpi/acpi_hotplug.h
@@ -46,6 +46,23 @@ enum acpihp_dev_type {
 	ACPIHP_DEV_TYPE_MAX
 };
 
+enum acpihp_dev_state {
+	DEVICE_STATE_UNKOWN = 0x00,
+	DEVICE_STATE_CONNECTED,
+	DEVICE_STATE_PRE_CONFIGURE,
+	DEVICE_STATE_CONFIGURED,
+	DEVICE_STATE_PRE_RELEASE,
+	DEVICE_STATE_RELEASED,
+	DEVICE_STATE_PRE_UNCONFIGURE,
+	DEVICE_STATE_MAX
+};
+
+struct acpihp_dev_node {
+	struct device		*dev;
+	enum acpihp_dev_state	state;
+	struct klist_node	node;
+};
+
 /*
  * ACPI hotplug slot is an abstraction of receptacles where a group of
  * system devices could be attached, just like PCI slot in PCI hotplug.
@@ -198,6 +215,15 @@ typedef acpi_status (*acpihp_walk_device_cb)(struct acpi_device *acpi_device,
 extern int acpihp_walk_devices(acpi_handle handle,
 			       acpihp_walk_device_cb cb, void *argp);
 
+extern int acpihp_slot_add_device(struct acpihp_slot *slot,
+				  enum acpihp_dev_type type,
+				  enum acpihp_dev_state state,
+				  struct device *dev);
+extern int acpihp_slot_remove_device(struct acpihp_slot *slot,
+				     enum acpihp_dev_type type,
+				     struct device *dev);
+extern int acpihp_remove_device_list(struct klist *dev_list);
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
