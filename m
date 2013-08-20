Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2334B6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 17:05:10 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] drivers: base: use standard device online/offline for state change
Date: Tue, 20 Aug 2013 16:05:05 -0500
Message-Id: <1377032705-13294-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

There are two ways to set the online/offline state for a memory block:
echo 0|1 > online and echo online|online_kernel|online_movable|offline >
state.

The state attribute can online a memory block with extra data, the
"online type", where the online attribute uses a default online type of
ONLINE_KEEP, same as echo online > state.

Currently there is a state_mutex that provides consistency between the
memory block state and the underlying memory.

The problem is that this code does a lot of things that the common
device layer can do for us, such as the serialization of the
online/offline handlers using the device lock, setting the dev->offline
field, and calling kobject_uevent().

This patch refactors the online/offline code to allow the common
device_[online|offline] functions to be used.  The result is a simpler
and more common code path for the two state setting mechanisms.  It also
removes the state_mutex from the struct memory_block as the memory block
device lock provides the state consistency.

No functional change is intended by this patch.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---

This is based on v3.11-rc6, not on my previous patchset.  However this patch
does apply cleanly on top of it.

 drivers/base/memory.c  | 127 +++++++++++++++++++++----------------------------
 include/linux/memory.h |  13 ++---
 2 files changed, 58 insertions(+), 82 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 2b7813e..577a0ed 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -16,7 +16,6 @@
 #include <linux/capability.h>
 #include <linux/device.h>
 #include <linux/memory.h>
-#include <linux/kobject.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
@@ -261,9 +260,8 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 	return ret;
 }
 
-static int __memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req,
-		int online_type)
+static int memory_block_change_state(struct memory_block *mem,
+		unsigned long to_state, unsigned long from_state_req)
 {
 	int ret = 0;
 
@@ -273,105 +271,91 @@ static int __memory_block_change_state(struct memory_block *mem,
 	if (to_state == MEM_OFFLINE)
 		mem->state = MEM_GOING_OFFLINE;
 
-	ret = memory_block_action(mem->start_section_nr, to_state, online_type);
+	ret = memory_block_action(mem->start_section_nr, to_state,
+				mem->online_type);
+
 	mem->state = ret ? from_state_req : to_state;
+
 	return ret;
 }
 
+/* The device lock serializes operations on memory_subsys_[online|offline] */
 static int memory_subsys_online(struct device *dev)
 {
 	struct memory_block *mem = container_of(dev, struct memory_block, dev);
 	int ret;
 
-	mutex_lock(&mem->state_mutex);
+	if (mem->state == MEM_ONLINE)
+		return 0;
 
-	ret = mem->state == MEM_ONLINE ? 0 :
-		__memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE,
-					    ONLINE_KEEP);
+	/*
+	 * If we are called from store_mem_state(), online_type will be
+	 * set >= 0 Otherwise we were called from the device online
+	 * attribute and need to set the online_type.
+	 */
+	if (mem->online_type < 0)
+		mem->online_type = ONLINE_KEEP;
+
+	ret = memory_block_change_state(mem, MEM_ONLINE, MEM_OFFLINE);
+
+	/* clear online_type */
+	mem->online_type = -1;
 
-	mutex_unlock(&mem->state_mutex);
 	return ret;
 }
 
 static int memory_subsys_offline(struct device *dev)
 {
 	struct memory_block *mem = container_of(dev, struct memory_block, dev);
-	int ret;
-
-	mutex_lock(&mem->state_mutex);
 
-	ret = mem->state == MEM_OFFLINE ? 0 :
-		__memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
+	if (mem->state == MEM_OFFLINE)
+		return 0;
 
-	mutex_unlock(&mem->state_mutex);
-	return ret;
+	return memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE);
 }
 
-static int __memory_block_change_state_uevent(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req,
-		int online_type)
-{
-	int ret = __memory_block_change_state(mem, to_state, from_state_req,
-					      online_type);
-	if (!ret) {
-		switch (mem->state) {
-		case MEM_OFFLINE:
-			kobject_uevent(&mem->dev.kobj, KOBJ_OFFLINE);
-			break;
-		case MEM_ONLINE:
-			kobject_uevent(&mem->dev.kobj, KOBJ_ONLINE);
-			break;
-		default:
-			break;
-		}
-	}
-	return ret;
-}
-
-static int memory_block_change_state(struct memory_block *mem,
-		unsigned long to_state, unsigned long from_state_req,
-		int online_type)
-{
-	int ret;
-
-	mutex_lock(&mem->state_mutex);
-	ret = __memory_block_change_state_uevent(mem, to_state, from_state_req,
-						 online_type);
-	mutex_unlock(&mem->state_mutex);
-
-	return ret;
-}
 static ssize_t
 store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct memory_block *mem;
-	bool offline;
-	int ret = -EINVAL;
+	int ret, online_type;
 
 	mem = container_of(dev, struct memory_block, dev);
 
 	lock_device_hotplug();
 
-	if (!strncmp(buf, "online_kernel", min_t(int, count, 13))) {
-		offline = false;
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_KERNEL);
-	} else if (!strncmp(buf, "online_movable", min_t(int, count, 14))) {
-		offline = false;
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_MOVABLE);
-	} else if (!strncmp(buf, "online", min_t(int, count, 6))) {
-		offline = false;
-		ret = memory_block_change_state(mem, MEM_ONLINE,
-						MEM_OFFLINE, ONLINE_KEEP);
-	} else if(!strncmp(buf, "offline", min_t(int, count, 7))) {
-		offline = true;
-		ret = memory_block_change_state(mem, MEM_OFFLINE,
-						MEM_ONLINE, -1);
+	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
+		online_type = ONLINE_KERNEL;
+	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
+		online_type = ONLINE_MOVABLE;
+	else if (!strncmp(buf, "online", min_t(int, count, 6)))
+		online_type = ONLINE_KEEP;
+	else if (!strncmp(buf, "offline", min_t(int, count, 7)))
+		online_type = -1;
+	else
+		return -EINVAL;
+
+	switch (online_type) {
+	case ONLINE_KERNEL:
+	case ONLINE_MOVABLE:
+	case ONLINE_KEEP:
+		/*
+		 * mem->online_type is not protected so there can be a
+		 * race here.  However, when racing online, the first
+		 * will succeed and the second will just return as the
+		 * block will already be online.  The online type
+		 * could be either one, but that is expected.
+		 */
+		mem->online_type = online_type;
+		ret = device_online(&mem->dev);
+		break;
+	case -1:
+		ret = device_offline(&mem->dev);
+		break;
+	default:
+		ret = -EINVAL; /* should never happen */
 	}
-	if (!ret)
-		dev->offline = offline;
 
 	unlock_device_hotplug();
 
@@ -595,7 +579,6 @@ static int init_memory_block(struct memory_block **memory,
 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
 	mem->state = state;
 	mem->section_count++;
-	mutex_init(&mem->state_mutex);
 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
 	mem->phys_device = arch_get_memory_phys_device(start_pfn);
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 85c31a8..5383461 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -25,16 +25,9 @@
 struct memory_block {
 	unsigned long start_section_nr;
 	unsigned long end_section_nr;
-	unsigned long state;
-	int section_count;
-
-	/*
-	 * This serializes all state change requests.  It isn't
-	 * held during creation because the control files are
-	 * created long after the critical areas during
-	 * initialization.
-	 */
-	struct mutex state_mutex;
+	unsigned long state;		/* serialized by the dev->lock */
+	int section_count;		/* serialized by mem_sysfs_mutex */
+	int online_type;		/* for passing data to online routine */
 	int phys_device;		/* to which fru does this belong? */
 	void *hw;			/* optional pointer to fw/hw data */
 	int (*phys_callback)(struct memory_block *);
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
