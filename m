Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AC5696B030D
	for <linux-mm@kvack.org>; Sat,  4 May 2013 07:13:11 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online callbacks for memory blocks
Date: Sat, 04 May 2013 13:21:16 +0200
Message-ID: <19540491.PRsM4lKIYM@vostro.rjw.lan>
In-Reply-To: <2376818.CRj1BTLk0Y@vostro.rjw.lan>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1583356.7oqZ7gBy2q@vostro.rjw.lan> <2376818.CRj1BTLk0Y@vostro.rjw.lan>
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

The 'online' sysfs attribute of memory block devices will attempt to
put them offline if 0 is written to it and will attempt to apply the
previously used online type when onlining them (i.e. when 1 is
written to it).

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
 include/linux/memory.h |    1 
 2 files changed, 81 insertions(+), 25 deletions(-)

Index: linux-pm/drivers/base/memory.c
===================================================================
--- linux-pm.orig/drivers/base/memory.c
+++ linux-pm/drivers/base/memory.c
@@ -37,9 +37,14 @@ static inline int base_memory_block_id(i
 	return section_nr / sections_per_block;
 }
 
+static int memory_subsys_online(struct device *dev);
+static int memory_subsys_offline(struct device *dev);
+
 static struct bus_type memory_subsys = {
 	.name = MEMORY_CLASS_NAME,
 	.dev_name = MEMORY_CLASS_NAME,
+	.online = memory_subsys_online,
+	.offline = memory_subsys_offline,
 };
 
 static BLOCKING_NOTIFIER_HEAD(memory_chain);
@@ -278,33 +283,64 @@ static int __memory_block_change_state(s
 {
 	int ret = 0;
 
-	if (mem->state != from_state_req) {
-		ret = -EINVAL;
-		goto out;
-	}
+	if (mem->state != from_state_req)
+		return -EINVAL;
 
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
 	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
-
 	if (ret) {
 		mem->state = from_state_req;
-		goto out;
+	} else {
+		mem->state = to_state;
+		if (to_state == MEM_ONLINE)
+			mem->last_online = online_type;
 	}
+	return ret;
+}
 
-	mem->state = to_state;
-	switch (mem->state) {
-	case MEM_OFFLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
-		break;
-	case MEM_ONLINE:
-		kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
-		break;
-	default:
-		break;
+static int memory_subsys_online(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+	int ret;
+
+	mutex_lock(&mem->state_mutex);
+	ret = __memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE,
+					  mem->last_online);
+	mutex_unlock(&mem->state_mutex);
+	return ret;
+}
+
+static int memory_subsys_offline(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+	int ret;
+
+	mutex_lock(&mem->state_mutex);
+	ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+	mutex_unlock(&mem->state_mutex);
+	return ret;
+}
+
+static int __memory_block_change_state_uevent(struct memory_block *mem,
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type)
+{
+	int ret = __memory_block_change_state(mem, to_state, from_state_req,
+					      online_type);
+	if (!ret) {
+		switch (mem->state) {
+		case MEM_OFFLINE:
+			kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
+			break;
+		case MEM_ONLINE:
+			kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
+			break;
+		default:
+			break;
+		}
 	}
-out:
 	return ret;
 }
 
@@ -315,8 +351,8 @@ static int memory_block_change_state(str
 	int ret;
 
 	mutex_lock(&mem->state_mutex);
-	ret = __memory_block_change_state(mem, to_state, from_state_req,
-					  online_type);
+	ret = __memory_block_change_state_uevent(mem, to_state, from_state_req,
+						 online_type);
 	mutex_unlock(&mem->state_mutex);
 
 	return ret;
@@ -326,22 +362,34 @@ store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct memory_block *mem;
+	bool offline;
 	int ret = -EINVAL;
 
 	mem = container_of(dev, struct memory_block, dev);
 
-	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
+	lock_device_hotplug();
+
+	if (!strncmp(buf, "online_kernel", min_t(int, count, 13))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_KERNEL);
-	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
+	} else if (!strncmp(buf, "online_movable", min_t(int, count, 14))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_MOVABLE);
-	else if (!strncmp(buf, "online", min_t(int, count, 6)))
+	} else if (!strncmp(buf, "online", min_t(int, count, 6))) {
+		offline = false;
 		ret = memory_block_change_state(mem, MEM_ONLINE,
 						MEM_OFFLINE, ONLINE_KEEP);
-	else if(!strncmp(buf, "offline", min_t(int, count, 7)))
+	} else if(!strncmp(buf, "offline", min_t(int, count, 7))) {
+		offline = true;
 		ret = memory_block_change_state(mem, MEM_OFFLINE,
 						MEM_ONLINE, -1);
+	}
+	if (!ret)
+		dev->offline = offline;
+
+	unlock_device_hotplug();
 
 	if (ret)
 		return ret;
@@ -563,6 +611,7 @@ static int init_memory_block(struct memo
 			base_memory_block_id(scn_nr) * sections_per_block;
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
+	mem->last_online = ONLINE_KEEP;
 	mem->section_count++;
 	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
@@ -686,10 +735,16 @@ int offline_memory_block(struct memory_b
 {
 	int ret = 0;
 
+	lock_device_hotplug();
 	mutex_lock(&mem->state_mutex);
-	if (mem->state != MEM_OFFLINE)
-		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+	if (mem->state != MEM_OFFLINE) {
+		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
+							 MEM_ONLINE, -1);
+		if (!ret)
+			mem->dev.offline = true;
+	}
 	mutex_unlock(&mem->state_mutex);
+	unlock_device_hotplug();
 
 	return ret;
 }
Index: linux-pm/include/linux/memory.h
===================================================================
--- linux-pm.orig/include/linux/memory.h
+++ linux-pm/include/linux/memory.h
@@ -26,6 +26,7 @@ struct memory_block {
 	unsigned long start_section_nr;
 	unsigned long end_section_nr;
 	unsigned long state;
+	int last_online;
 	int section_count;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
