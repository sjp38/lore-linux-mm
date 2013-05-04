Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 096DA6B0302
	for <linux-mm@kvack.org>; Fri,  3 May 2013 20:58:57 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/3 RFC] Driver core: Introduce types of device "online"
Date: Sat, 04 May 2013 03:04:35 +0200
Message-ID: <2676830.j8c3BgZaWj@vostro.rjw.lan>
In-Reply-To: <1583356.7oqZ7gBy2q@vostro.rjw.lan>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <3166726.elbgrUIZ0L@vostro.rjw.lan> <1583356.7oqZ7gBy2q@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

For memory blocks there are multiple ways in which they can be
"online" that determine what can be done with the given block.

For this reason, to allow the generic device_offline() and
device_online() to be used for devices representing memory
blocks, introduce a second "online type" argument for
device_online() that will be interpreted by the bus type whose
.online() callback is executed by device_online().

Of course, that requires some changes to be made in struct device
and struct bus_type, and the code related to device_online()
and device_offline() needs to be changed as well.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/acpi/acpi_processor.c |    2 +-
 drivers/acpi/scan.c           |   14 ++++++++------
 drivers/base/core.c           |   36 ++++++++++++++++++++----------------
 drivers/base/cpu.c            |    5 ++++-
 include/acpi/acpi_bus.h       |    2 +-
 include/linux/device.h        |    8 ++++----
 6 files changed, 38 insertions(+), 29 deletions(-)

Index: linux-pm/include/linux/device.h
===================================================================
--- linux-pm.orig/include/linux/device.h
+++ linux-pm/include/linux/device.h
@@ -108,7 +108,7 @@ struct bus_type {
 	int (*remove)(struct device *dev);
 	void (*shutdown)(struct device *dev);
 
-	int (*online)(struct device *dev);
+	int (*online)(struct device *dev, unsigned int type);
 	int (*offline)(struct device *dev);
 
 	int (*suspend)(struct device *dev, pm_message_t state);
@@ -656,7 +656,7 @@ struct acpi_dev_node {
  * 		gone away. This should be set by the allocator of the
  * 		device (i.e. the bus driver that discovered the device).
  * @offline_disabled: If set, the device is permanently online.
- * @offline:	Set after successful invocation of bus type's .offline().
+ * @online_type: 0 if the device is offline, otherwise bus type dependent.
  *
  * At the lowest level, every device in a Linux system is represented by an
  * instance of struct device. The device structure contains the information
@@ -730,8 +730,8 @@ struct device {
 	void	(*release)(struct device *dev);
 	struct iommu_group	*iommu_group;
 
+	unsigned int 		online_type;
 	bool			offline_disabled:1;
-	bool			offline:1;
 };
 
 static inline struct device *kobj_to_dev(struct kobject *kobj)
@@ -876,7 +876,7 @@ static inline bool device_supports_offli
 extern void lock_device_hotplug(void);
 extern void unlock_device_hotplug(void);
 extern int device_offline(struct device *dev);
-extern int device_online(struct device *dev);
+extern int device_online(struct device *dev, unsigned int type);
 /*
  * Root device objects for grouping under /sys/devices
  */
Index: linux-pm/drivers/base/core.c
===================================================================
--- linux-pm.orig/drivers/base/core.c
+++ linux-pm/drivers/base/core.c
@@ -406,10 +406,10 @@ static struct device_attribute uevent_at
 static ssize_t show_online(struct device *dev, struct device_attribute *attr,
 			   char *buf)
 {
-	bool val;
+	unsigned int val;
 
 	lock_device_hotplug();
-	val = !dev->offline;
+	val = dev->online_type;
 	unlock_device_hotplug();
 	return sprintf(buf, "%u\n", val);
 }
@@ -417,15 +417,15 @@ static ssize_t show_online(struct device
 static ssize_t store_online(struct device *dev, struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	bool val;
+	unsigned int val;
 	int ret;
 
-	ret = strtobool(buf, &val);
+	ret = kstrtouint(buf, 10, &val);
 	if (ret < 0)
 		return ret;
 
 	lock_device_hotplug();
-	ret = val ? device_online(dev) : device_offline(dev);
+	ret = val ? device_online(dev, val) : device_offline(dev);
 	unlock_device_hotplug();
 	return ret < 0 ? ret : count;
 }
@@ -1488,7 +1488,7 @@ static int device_check_offline(struct d
 	if (ret)
 		return ret;
 
-	return device_supports_offline(dev) && !dev->offline ? -EBUSY : 0;
+	return device_supports_offline(dev) && !!dev->online_type ? -EBUSY : 0;
 }
 
 /**
@@ -1515,14 +1515,14 @@ int device_offline(struct device *dev)
 
 	device_lock(dev);
 	if (device_supports_offline(dev)) {
-		if (dev->offline) {
-			ret = 1;
-		} else {
+		if (dev->online_type) {
 			ret = dev->bus->offline(dev);
 			if (!ret) {
 				kobject_uevent(&dev->kobj, KOBJ_OFFLINE);
-				dev->offline = true;
+				dev->online_type = 0;
 			}
+		} else {
+			ret = 1;
 		}
 	}
 	device_unlock(dev);
@@ -1533,6 +1533,7 @@ int device_offline(struct device *dev)
 /**
  * device_online - Put the device back online after successful device_offline().
  * @dev: Device to be put back online.
+ * @type: Interpreted by the bus type, must be nonzero.
  *
  * If device_offline() has been successfully executed for @dev, but the device
  * has not been removed subsequently, execute its bus type's .online() callback
@@ -1540,20 +1541,23 @@ int device_offline(struct device *dev)
  *
  * Call under device_hotplug_lock.
  */
-int device_online(struct device *dev)
+int device_online(struct device *dev, unsigned int type)
 {
 	int ret = 0;
 
+	if (!type)
+		return -EINVAL;
+
 	device_lock(dev);
 	if (device_supports_offline(dev)) {
-		if (dev->offline) {
-			ret = dev->bus->online(dev);
+		if (dev->online_type) {
+			ret = 1;
+		} else {
+			ret = dev->bus->online(dev, type);
 			if (!ret) {
 				kobject_uevent(&dev->kobj, KOBJ_ONLINE);
-				dev->offline = false;
+				dev->online_type = type;
 			}
-		} else {
-			ret = 1;
 		}
 	}
 	device_unlock(dev);
Index: linux-pm/include/acpi/acpi_bus.h
===================================================================
--- linux-pm.orig/include/acpi/acpi_bus.h
+++ linux-pm/include/acpi/acpi_bus.h
@@ -286,7 +286,7 @@ struct acpi_device_physical_node {
 	u8 node_id;
 	struct list_head node;
 	struct device *dev;
-	bool put_online:1;
+	unsigned int online_type;
 };
 
 /* set maximum of physical nodes to 32 for expansibility */
Index: linux-pm/drivers/acpi/scan.c
===================================================================
--- linux-pm.orig/drivers/acpi/scan.c
+++ linux-pm/drivers/acpi/scan.c
@@ -141,15 +141,17 @@ static acpi_status acpi_bus_offline_comp
 	list_for_each_entry(pn, &device->physical_node_list, node) {
 		int ret;
 
+		pn->online_type = pn->dev->online_type;
 		ret = device_offline(pn->dev);
-		if (acpi_force_hot_remove)
+		if (acpi_force_hot_remove) {
+			pn->online_type = 0;
 			continue;
-
+		}
 		if (ret < 0) {
+			pn->online_type = 0;
 			status = AE_ERROR;
 			break;
 		}
-		pn->put_online = !ret;
 	}
 
 	mutex_unlock(&device->physical_node_lock);
@@ -169,9 +171,9 @@ static acpi_status acpi_bus_online_compa
 	mutex_lock(&device->physical_node_lock);
 
 	list_for_each_entry(pn, &device->physical_node_list, node)
-		if (pn->put_online) {
-			device_online(pn->dev);
-			pn->put_online = false;
+		if (pn->online_type) {
+			device_online(pn->dev, pn->online_type);
+			pn->online_type = 0;
 		}
 
 	mutex_unlock(&device->physical_node_lock);
Index: linux-pm/drivers/acpi/acpi_processor.c
===================================================================
--- linux-pm.orig/drivers/acpi/acpi_processor.c
+++ linux-pm/drivers/acpi/acpi_processor.c
@@ -395,7 +395,7 @@ static int __cpuinit acpi_processor_add(
 		goto err;
 
 	pr->dev = dev;
-	dev->offline = pr->flags.need_hotplug_init;
+	dev->online_type = !pr->flags.need_hotplug_init;
 
 	/* Trigger the processor driver's .probe() if present. */
 	if (device_attach(dev) >= 0)
Index: linux-pm/drivers/base/cpu.c
===================================================================
--- linux-pm.orig/drivers/base/cpu.c
+++ linux-pm/drivers/base/cpu.c
@@ -38,13 +38,16 @@ static void change_cpu_under_node(struct
 	cpu->node_id = to_nid;
 }
 
-static int __ref cpu_subsys_online(struct device *dev)
+static int __ref cpu_subsys_online(struct device *dev, unsigned int type)
 {
 	struct cpu *cpu = container_of(dev, struct cpu, dev);
 	int cpuid = dev->id;
 	int from_nid, to_nid;
 	int ret;
 
+	if (type > 1)
+		return -EINVAL;
+
 	cpu_hotplug_driver_lock();
 
 	from_nid = cpu_to_node(cpuid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
