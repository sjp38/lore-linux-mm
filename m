Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3DB6C6B0300
	for <linux-mm@kvack.org>; Fri,  3 May 2013 20:58:57 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/3 RFC] Driver core: Introduce offline/online callbacks for memory blocks
Date: Sat, 04 May 2013 03:06:24 +0200
Message-ID: <3831347.P78I4u6NFE@vostro.rjw.lan>
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

Introduce .offline() and .online() callbacks for memory_subsys
that will allow the generic device_offline() and device_online()
to be used with device objects representing memory blocks.  That,
in turn, allows the ACPI subsystem to use device_offline() to put
removable memory blocks offline, if possible, before removing
memory modules holding them.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/base/memory.c          |   84 ++++++++++++++++++++++++++++++-----------
 include/linux/memory_hotplug.h |    2 
 2 files changed, 64 insertions(+), 22 deletions(-)

Index: linux-pm/drivers/base/memory.c
===================================================================
--- linux-pm.orig/drivers/base/memory.c
+++ linux-pm/drivers/base/memory.c
@@ -37,9 +37,14 @@ static inline int base_memory_block_id(i
 	return section_nr / sections_per_block;
 }
 
+static int memory_subsys_online(struct device *dev, unsigned int type);
+static int memory_subsys_offline(struct device *dev);
+
 static struct bus_type memory_subsys = {
 	.name = MEMORY_CLASS_NAME,
 	.dev_name = MEMORY_CLASS_NAME,
+	.online = memory_subsys_online,
+	.offline = memory_subsys_offline,
 };
 
 static BLOCKING_NOTIFIER_HEAD(memory_chain);
@@ -294,16 +299,7 @@ static int __memory_block_change_state(s
 	}
 
 	mem->state = to_state;
-	switch (mem->state) {
-	case MEM_OFFLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
-		break;
-	case MEM_ONLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
-		break;
-	default:
-		break;
-	}
+
 out:
 	return ret;
 }
@@ -321,27 +317,66 @@ static int memory_block_change_state(str
 
 	return ret;
 }
+
+static int memory_subsys_online(struct device *dev, unsigned int type)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+
+	if (type < ONLINE_KEEP || type > ONLINE_KERNEL)
+		return -EINVAL;
+
+	return memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE, type);
+}
+
+static int memory_block_online(struct device *dev, unsigned int type)
+{
+	int ret = memory_subsys_online(dev, type);
+
+	if (!ret) {
+		dev->online_type = type;
+		kobject_uevent(&dev->kobj, KOBJ_ONLINE);
+	}
+
+	return ret;
+}
+
+static int memory_subsys_offline(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+
+	return memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+}
+
+static int memory_block_offline(struct device *dev)
+{
+	int ret = memory_subsys_offline(dev);
+
+	if (!ret) {
+		dev->online_type = 0;
+		kobject_uevent(&dev->kobj, KOBJ_OFFLINE);
+	}
+
+	return ret;
+}
+
 static ssize_t
 store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct memory_block *mem;
 	int ret = -EINVAL;
 
-	mem = container_of(dev, struct memory_block, dev);
+	lock_device_hotplug();
 
 	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_KERNEL);
+		ret = memory_block_online(dev, ONLINE_KERNEL);
 	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_MOVABLE);
+		ret = memory_block_online(dev, ONLINE_MOVABLE);
 	else if (!strncmp(buf, "online", min_t(int, count, 6)))
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_KEEP);
+		ret = memory_block_online(dev, ONLINE_KEEP);
 	else if(!strncmp(buf, "offline", min_t(int, count, 7)))
-		ret = memory_block_change_state(mem, MEM_OFFLINE,
-						MEM_ONLINE, -1);
+		ret = memory_block_offline(dev);
+
+	unlock_device_hotplug();
 
 	if (ret)
 		return ret;
@@ -686,10 +721,17 @@ int offline_memory_block(struct memory_b
 {
 	int ret = 0;
 
+	lock_device_hotplug();
 	mutex_lock(&mem->state_mutex);
-	if (mem->state != MEM_OFFLINE)
+	if (mem->state != MEM_OFFLINE) {
 		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+		if (!ret) {
+			mem->dev.online_type = 0;
+			kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
+		}
+	}
 	mutex_unlock(&mem->state_mutex);
+	unlock_device_hotplug();
 
 	return ret;
 }
Index: linux-pm/include/linux/memory_hotplug.h
===================================================================
--- linux-pm.orig/include/linux/memory_hotplug.h
+++ linux-pm/include/linux/memory_hotplug.h
@@ -28,7 +28,7 @@ enum {
 
 /* Types for control the zone type of onlined memory */
 enum {
-	ONLINE_KEEP,
+	ONLINE_KEEP = 1,
 	ONLINE_KERNEL,
 	ONLINE_MOVABLE,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
