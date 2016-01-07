Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E3419828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 12:23:50 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id o11so332683465qge.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 09:23:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e8si15238743qgf.2.2016.01.07.09.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 09:23:49 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v3] memory-hotplug: add automatic onlining policy for the newly added memory
Date: Thu,  7 Jan 2016 18:23:41 +0100
Message-Id: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Currently, all newly added memory blocks remain in 'offline' state unless
someone onlines them, some linux distributions carry special udev rules
like:

SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

to make this happen automatically. This is not a great solution for virtual
machines where memory hotplug is being used to address high memory pressure
situations as such onlining is slow and a userspace process doing this
(udev) has a chance of being killed by the OOM killer as it will probably
require to allocate some memory.

Introduce default policy for the newly added memory blocks in
/sys/devices/system/memory/auto_online_blocks file with two possible
values: "offline" which preserves the current behavior and "online" which
causes all newly added memory blocks to go online as soon as they're added.
The default is "offline".

Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Daniel Kiper <daniel.kiper@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Igor Mammedov <imammedo@redhat.com>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
- Changes since 'v2':
  - Remove config option, revert to 'offline' by default [Andrew Morton,
    David Rientjes]
  - Rename 'hotplug_autoonline' to 'auto_online_blocks' [David Rientjes]

- Changes since 'v1':
  Add 'online' parameter to add_memory_resource() as it is being used by
  xen ballon driver and it adds "empty" memory pages [David Vrabel].
  (I don't completely understand what prevents manual onlining in this
   case as we still have all newly added blocks in sysfs ... this is the
   discussion point.)

- Changes since 'RFC':
  It seems nobody is strongly opposed to the idea, thus non-RFC.
  Change memhp_autoonline to bool, we support only MMOP_ONLINE_KEEP
  and MMOP_OFFLINE for the auto-onlining policy, eliminate 'unknown'
  from show_memhp_autoonline(). [Daniel Kiper]
  Put everything under CONFIG_MEMORY_HOTPLUG_AUTOONLINE, enable the
  feature by default (when the config option is selected) and add
  kernel parameter (nomemhp_autoonline) to disable the functionality
  upon boot when needed.

- RFC:
  I was able to find previous attempts to fix the issue, e.g.:
  http://marc.info/?l=linux-kernel&m=137425951924598&w=2
  http://marc.info/?l=linux-acpi&m=127186488905382
  but I'm not completely sure why it didn't work out and the solution
  I suggest is not 'smart enough', thus 'RFC'.
---
 Documentation/memory-hotplug.txt | 19 +++++++++++++++----
 drivers/base/memory.c            | 32 ++++++++++++++++++++++++++++++++
 drivers/xen/balloon.c            |  2 +-
 include/linux/memory_hotplug.h   |  4 +++-
 mm/memory_hotplug.c              | 12 ++++++++++--
 5 files changed, 61 insertions(+), 8 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index ce2cfcf..ceaf40c 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -254,12 +254,23 @@ If the memory block is online, you'll read "online".
 If the memory block is offline, you'll read "offline".
 
 
-5.2. How to online memory
+5.2. Memory onlining
 ------------
-Even if the memory is hot-added, it is not at ready-to-use state.
-For using newly added memory, you have to "online" the memory block.
+When the memory is hot-added, the kernel decides whether or not to "online"
+it according to the policy which can be read from "auto_online_blocks" file:
 
-For onlining, you have to write "online" to the memory block's state file as:
+% cat /sys/devices/system/memory/auto_online_blocks
+
+The default is "offline" which means the newly added memory is not in a
+ready-to-use state and you have to "online" the newly added memory blocks
+manually. Automatic onlining can be requested by writing "online" to
+"auto_online_blocks" file:
+
+% echo online > /sys/devices/system/memory/auto_online_blocks
+
+If the automatic onlining wasn't requested or some memory block was offlined
+it is possible to change the individual block's state by writing to the "state"
+file:
 
 % echo online > /sys/devices/system/memory/memoryXXX/state
 
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 25425d3..44a618d 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -439,6 +439,37 @@ print_block_size(struct device *dev, struct device_attribute *attr,
 static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
 
 /*
+ * Memory auto online policy.
+ */
+
+static ssize_t
+show_auto_online_blocks(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	if (memhp_auto_online)
+		return sprintf(buf, "online\n");
+	else
+		return sprintf(buf, "offline\n");
+}
+
+static ssize_t
+store_auto_online_blocks(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	if (sysfs_streq(buf, "online"))
+		memhp_auto_online = true;
+	else if (sysfs_streq(buf, "offline"))
+		memhp_auto_online = false;
+	else
+		return -EINVAL;
+
+	return count;
+}
+
+static DEVICE_ATTR(auto_online_blocks, 0644, show_auto_online_blocks,
+		   store_auto_online_blocks);
+
+/*
  * Some architectures will have custom drivers to do this, and
  * will not need to do it from userspace.  The fake hot-add code
  * as well as ppc64 will do all of their discovery in userspace
@@ -737,6 +768,7 @@ static struct attribute *memory_root_attrs[] = {
 #endif
 
 	&dev_attr_block_size_bytes.attr,
+	&dev_attr_auto_online_blocks.attr,
 	NULL
 };
 
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 12eab50..890c3b5 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -338,7 +338,7 @@ static enum bp_state reserve_additional_memory(void)
 	}
 #endif
 
-	rc = add_memory_resource(nid, resource);
+	rc = add_memory_resource(nid, resource, false);
 	if (rc) {
 		pr_warn("Cannot add additional memory (%i)\n", rc);
 		goto err;
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2ea574f..4b7949a 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -99,6 +99,8 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
+extern bool memhp_auto_online;
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
@@ -267,7 +269,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource);
+extern int add_memory_resource(int nid, struct resource *resource, bool online);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 		bool for_device);
 extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a042a9d..0ecf860 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -76,6 +76,9 @@ static struct {
 #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
 #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
 
+bool memhp_auto_online;
+EXPORT_SYMBOL_GPL(memhp_auto_online);
+
 void get_online_mems(void)
 {
 	might_sleep();
@@ -1232,7 +1235,7 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
 }
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory_resource(int nid, struct resource *res)
+int __ref add_memory_resource(int nid, struct resource *res, bool online)
 {
 	u64 start, size;
 	pg_data_t *pgdat = NULL;
@@ -1292,6 +1295,11 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	/* create new memmap entry */
 	firmware_map_add_hotplug(start, start + size, "System RAM");
 
+	/* online pages if requested */
+	if (online)
+		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+			     MMOP_ONLINE_KEEP);
+
 	goto out;
 
 error:
@@ -1315,7 +1323,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	if (!res)
 		return -EEXIST;
 
-	ret = add_memory_resource(nid, res);
+	ret = add_memory_resource(nid, res, memhp_auto_online);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
