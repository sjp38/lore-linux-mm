Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE4286B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 04:28:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c143so8429689wmd.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:28:26 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id c51si5328680wrc.313.2017.02.27.01.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 01:28:24 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u63so12396688wmu.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:28:24 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Date: Mon, 27 Feb 2017 10:28:17 +0100
Message-Id: <20170227092817.23571-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This knob has been added by 31bc3858ea3e ("memory-hotplug: add automatic
onlining policy for the newly added memory") mainly to cover memory
hotplug based balooning solutions currently implemented for HyperV
and Xen. Both of them want to online the memory as soon after
registering as possible otherwise they can register too much memory
which cannot be used and trigger the oom killer (we need ~1.5% of the
registered memory so a large increase can consume all the available
memory). hv_mem_hot_add even waits for the userspace to online the
memory if the auto onlining is disabled to mitigate that problem.

Adding yet another knob and a config option just doesn't make much sense
IMHO. How is a random user supposed to know when to enable this option?
Ballooning drivers know much better that they want to do an immediate
online rather than waiting for the userspace to do that. If the memory
is onlined for a different purpose then we already have a notification
for the userspace and udev can handle the onlining. So the knob as well
as the config option for the default behavior just doesn't make any
sense. Let's remove them and allow user of add_memory to request the
online status explicitly. Not only it makes more sense it also removes a
lot of clutter.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I am sending this as an RFC because this is a user visible change. Maybe
we won't be able to remove the sysfs knob which would be sad, especially
when it has been added without a wider discussion and IMHO it is just
wrong. Is there any reason why a kernel command line parameter wouldn't
work just fine?

Even in that case I believe that we should remove
CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE knob. It just adds to an already
messy config space. Does anybody depend on the policy during the early
boot before the userspace can set the sysfs knob? Or why those users cannot
simply use the kernel command line parameter.

I also believe that the wait-for-userspace in hyperV should just die. It
should do the unconditional onlining. Same as Xen. I do not see any
reason why those should depend on the userspace. This should be just
fixed regardless of the sysfs/config part. I can separate this out of course.

Thoughts/Concerns?

 drivers/acpi/acpi_memhotplug.c |  2 +-
 drivers/base/memory.c          | 33 +--------------------------------
 drivers/hv/hv_balloon.c        | 26 +-------------------------
 drivers/s390/char/sclp_cmd.c   |  2 +-
 drivers/xen/balloon.c          |  2 +-
 include/linux/memory_hotplug.h |  4 +---
 mm/Kconfig                     | 16 ----------------
 mm/memory_hotplug.c            | 22 ++--------------------
 8 files changed, 8 insertions(+), 99 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 6b0d3ef7309c..2b1c35fb36d1 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -228,7 +228,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = add_memory(node, info->start_addr, info->length);
+		result = add_memory(node, info->start_addr, info->length, false);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index fa26ffd25fa6..476c2c02f938 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -446,37 +446,6 @@ print_block_size(struct device *dev, struct device_attribute *attr,
 static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
 
 /*
- * Memory auto online policy.
- */
-
-static ssize_t
-show_auto_online_blocks(struct device *dev, struct device_attribute *attr,
-			char *buf)
-{
-	if (memhp_auto_online)
-		return sprintf(buf, "online\n");
-	else
-		return sprintf(buf, "offline\n");
-}
-
-static ssize_t
-store_auto_online_blocks(struct device *dev, struct device_attribute *attr,
-			 const char *buf, size_t count)
-{
-	if (sysfs_streq(buf, "online"))
-		memhp_auto_online = true;
-	else if (sysfs_streq(buf, "offline"))
-		memhp_auto_online = false;
-	else
-		return -EINVAL;
-
-	return count;
-}
-
-static DEVICE_ATTR(auto_online_blocks, 0644, show_auto_online_blocks,
-		   store_auto_online_blocks);
-
-/*
  * Some architectures will have custom drivers to do this, and
  * will not need to do it from userspace.  The fake hot-add code
  * as well as ppc64 will do all of their discovery in userspace
@@ -500,7 +469,7 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = add_memory(nid, phys_addr,
-			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+			 MIN_MEMORY_BLOCK_SIZE * sections_per_block, false);
 
 	if (ret)
 		goto out;
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 14c3dc4bd23c..3e052bedade5 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -535,11 +535,6 @@ struct hv_dynmem_device {
 	bool host_specified_ha_region;
 
 	/*
-	 * State to synchronize hot-add.
-	 */
-	struct completion  ol_waitevent;
-	bool ha_waiting;
-	/*
 	 * This thread handles hot-add
 	 * requests from the host as well as notifying
 	 * the host with regards to memory pressure in
@@ -587,11 +582,6 @@ static int hv_memory_notifier(struct notifier_block *nb, unsigned long val,
 		spin_lock_irqsave(&dm_device.ha_lock, flags);
 		dm_device.num_pages_onlined += mem->nr_pages;
 		spin_unlock_irqrestore(&dm_device.ha_lock, flags);
-	case MEM_CANCEL_ONLINE:
-		if (dm_device.ha_waiting) {
-			dm_device.ha_waiting = false;
-			complete(&dm_device.ol_waitevent);
-		}
 		break;
 
 	case MEM_OFFLINE:
@@ -683,12 +673,9 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 		has->covered_end_pfn +=  processed_pfn;
 		spin_unlock_irqrestore(&dm_device.ha_lock, flags);
 
-		init_completion(&dm_device.ol_waitevent);
-		dm_device.ha_waiting = !memhp_auto_online;
-
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
-				(HA_CHUNK << PAGE_SHIFT));
+				(HA_CHUNK << PAGE_SHIFT), true);
 
 		if (ret) {
 			pr_warn("hot_add memory failed error is %d\n", ret);
@@ -708,17 +695,6 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 			spin_unlock_irqrestore(&dm_device.ha_lock, flags);
 			break;
 		}
-
-		/*
-		 * Wait for the memory block to be onlined when memory onlining
-		 * is done outside of kernel (memhp_auto_online). Since the hot
-		 * add has succeeded, it is ok to proceed even if the pages in
-		 * the hot added region have not been "onlined" within the
-		 * allowed time.
-		 */
-		if (dm_device.ha_waiting)
-			wait_for_completion_timeout(&dm_device.ol_waitevent,
-						    5*HZ);
 		post_status(&dm_device);
 	}
 
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index b9c5522b8a68..f54c621195b6 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -404,7 +404,7 @@ static void __init add_memory_merged(u16 rn)
 	if (!size)
 		goto skip_add;
 	for (addr = start; addr < start + size; addr += block_size)
-		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size, false);
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index db107fa50ca1..fce961de8771 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -355,7 +355,7 @@ static enum bp_state reserve_additional_memory(void)
 	 * callers drop the mutex before trying again.
 	 */
 	mutex_unlock(&balloon_mutex);
-	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	rc = add_memory_resource(nid, resource, true);
 	mutex_lock(&balloon_mutex);
 
 	if (rc) {
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 134a2f69c21a..a72f7f64ee26 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -100,8 +100,6 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
-extern bool memhp_auto_online;
-
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
@@ -272,7 +270,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
-extern int add_memory(int nid, u64 start, u64 size);
+extern int add_memory(int nid, u64 start, u64 size, bool online);
 extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb969dc..a64a3bca43d5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,22 +193,6 @@ config MEMORY_HOTPLUG_SPARSE
 	def_bool y
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
-config MEMORY_HOTPLUG_DEFAULT_ONLINE
-        bool "Online the newly added memory blocks by default"
-        default n
-        depends on MEMORY_HOTPLUG
-        help
-	  This option sets the default policy setting for memory hotplug
-	  onlining policy (/sys/devices/system/memory/auto_online_blocks) which
-	  determines what happens to newly added memory regions. Policy setting
-	  can always be changed at runtime.
-	  See Documentation/memory-hotplug.txt for more information.
-
-	  Say Y here if you want all hot-plugged memory blocks to appear in
-	  'online' state by default.
-	  Say N here if you want the default policy to keep all hot-plugged
-	  memory blocks in 'offline' state.
-
 config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
 	select MEMORY_ISOLATION
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c35dd1976574..8520c9166f47 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -78,24 +78,6 @@ static struct {
 #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
 #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
 
-#ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
-bool memhp_auto_online;
-#else
-bool memhp_auto_online = true;
-#endif
-EXPORT_SYMBOL_GPL(memhp_auto_online);
-
-static int __init setup_memhp_default_state(char *str)
-{
-	if (!strcmp(str, "online"))
-		memhp_auto_online = true;
-	else if (!strcmp(str, "offline"))
-		memhp_auto_online = false;
-
-	return 1;
-}
-__setup("memhp_default_state=", setup_memhp_default_state);
-
 void get_online_mems(void)
 {
 	might_sleep();
@@ -1420,7 +1402,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 }
 EXPORT_SYMBOL_GPL(add_memory_resource);
 
-int __ref add_memory(int nid, u64 start, u64 size)
+int __ref add_memory(int nid, u64 start, u64 size, bool online)
 {
 	struct resource *res;
 	int ret;
@@ -1429,7 +1411,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res, memhp_auto_online);
+	ret = add_memory_resource(nid, res, online);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
