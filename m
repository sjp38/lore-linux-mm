Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id C691B6B0006
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:46:03 -0500 (EST)
Received: by mail-qk0-f181.google.com with SMTP id p187so113380113qkd.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 08:46:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r190si16831996qhb.108.2015.12.18.08.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 08:46:02 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH] memory-hotplug: add automatic onlining policy for the newly added memory
Date: Fri, 18 Dec 2015 17:45:55 +0100
Message-Id: <1450457155-31234-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>

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
/sys/devices/system/memory/hotplug_autoonline file with two possible
values: "offline" which preserves the current behavior and "online" which
causes all newly added memory blocks to go online as soon as they're added.
The default is "online" when MEMORY_HOTPLUG_AUTOONLINE kernel config option
is selected.

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
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
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
 Documentation/kernel-parameters.txt |  2 ++
 Documentation/memory-hotplug.txt    | 26 ++++++++++++++++++++------
 drivers/base/memory.c               | 36 ++++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h      |  4 ++++
 mm/Kconfig                          |  9 +++++++++
 mm/memory_hotplug.c                 | 18 ++++++++++++++++++
 6 files changed, 89 insertions(+), 6 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 742f69d..652efe1 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2537,6 +2537,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			shutdown the other cpus.  Instead use the REBOOT_VECTOR
 			irq.
 
+	nomemhp_autoonline	Don't automatically online newly added memory.
+
 	nomodule	Disable module load
 
 	nopat		[X86] Disable PAT (page attribute table extension of
diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index ce2cfcf..041efac 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -111,8 +111,9 @@ To use memory hotplug feature, kernel must be compiled with following
 config options.
 
 - For all memory hotplug
-    Memory model -> Sparse Memory  (CONFIG_SPARSEMEM)
-    Allow for memory hot-add       (CONFIG_MEMORY_HOTPLUG)
+    Memory model -> Sparse Memory         (CONFIG_SPARSEMEM)
+    Allow for memory hot-add              (CONFIG_MEMORY_HOTPLUG)
+    Automatically online hot-added memory (CONFIG_MEMORY_HOTPLUG_AUTOONLINE)
 
 - To enable memory removal, the followings are also necessary
     Allow for memory hot remove    (CONFIG_MEMORY_HOTREMOVE)
@@ -254,12 +255,25 @@ If the memory block is online, you'll read "online".
 If the memory block is offline, you'll read "offline".
 
 
-5.2. How to online memory
+5.2. Memory onlining
 ------------
-Even if the memory is hot-added, it is not at ready-to-use state.
-For using newly added memory, you have to "online" the memory block.
+When the memory is hot-added, the kernel decides whether or not to "online"
+it according to the policy which can be read from "hotplug_autoonline" file
+(requires CONFIG_MEMORY_HOTPLUG_AUTOONLINE):
 
-For onlining, you have to write "online" to the memory block's state file as:
+% cat /sys/devices/system/memory/hotplug_autoonline
+
+The default is "online" which means the newly added memory will be onlined
+after adding. Automatic onlining can be disabled by writing "offline" to the
+"hotplug_autoonline" file:
+
+% echo offline > /sys/devices/system/memory/hotplug_autoonline
+
+or by booting the kernel with "nomemhp_autoonline" parameter.
+
+If the automatic onlining wasn't requested or some memory block was offlined
+it is possible to change the individual block's state by writing to the "state"
+file:
 
 % echo online > /sys/devices/system/memory/memoryXXX/state
 
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 25425d3..6f9ce3a 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -438,6 +438,39 @@ print_block_size(struct device *dev, struct device_attribute *attr,
 
 static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
 
+#ifdef CONFIG_MEMORY_HOTPLUG_AUTOONLINE
+/*
+ * Memory auto online policy.
+ */
+
+static ssize_t
+show_memhp_autoonline(struct device *dev, struct device_attribute *attr,
+		      char *buf)
+{
+	if (memhp_autoonline)
+		return sprintf(buf, "online\n");
+	else
+		return sprintf(buf, "offline\n");
+}
+
+static ssize_t
+store_memhp_autoonline(struct device *dev, struct device_attribute *attr,
+		       const char *buf, size_t count)
+{
+	if (sysfs_streq(buf, "online"))
+		memhp_autoonline = true;
+	else if (sysfs_streq(buf, "offline"))
+		memhp_autoonline = false;
+	else
+		return -EINVAL;
+
+	return count;
+}
+
+static DEVICE_ATTR(hotplug_autoonline, 0644, show_memhp_autoonline,
+		   store_memhp_autoonline);
+#endif
+
 /*
  * Some architectures will have custom drivers to do this, and
  * will not need to do it from userspace.  The fake hot-add code
@@ -737,6 +770,9 @@ static struct attribute *memory_root_attrs[] = {
 #endif
 
 	&dev_attr_block_size_bytes.attr,
+#ifdef CONFIG_MEMORY_HOTPLUG_AUTOONLINE
+	&dev_attr_hotplug_autoonline.attr,
+#endif
 	NULL
 };
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2ea574f..a384078 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -99,6 +99,10 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
+#ifdef CONFIG_MEMORY_HOTPLUG_AUTOONLINE
+extern bool memhp_autoonline;
+#endif
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern bool is_pageblock_removable_nolock(struct page *page);
 extern int arch_remove_memory(u64 start, u64 size);
diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06..dd1b8ea 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -200,6 +200,15 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config MEMORY_HOTPLUG_AUTOONLINE
+	bool "Automatically online hot-added memory"
+	depends on MEMORY_HOTPLUG_SPARSE
+	help
+	  When memory is hot-added, it is not at ready-to-use state, a special
+	  userspace action is required to online the newly added blocks. With
+	  this option enabled, the kernel will try to online all newly added
+	  memory automatically.
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 67d488a..fb7a47c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -76,6 +76,18 @@ static struct {
 #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
 #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
 
+#ifdef CONFIG_MEMORY_HOTPLUG_AUTOONLINE
+bool memhp_autoonline = true;
+EXPORT_SYMBOL_GPL(memhp_autoonline);
+
+static int __init setup_memhp_autoonline(char *str)
+{
+	memhp_autoonline = false;
+	return 0;
+}
+__setup("nomemhp_autoonline", setup_memhp_autoonline);
+#endif
+
 void get_online_mems(void)
 {
 	might_sleep();
@@ -1292,6 +1304,12 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	/* create new memmap entry */
 	firmware_map_add_hotplug(start, start + size, "System RAM");
 
+#ifdef CONFIG_MEMORY_HOTPLUG_AUTOONLINE
+	/* online the region if it is requested by current policy */
+	if (memhp_autoonline)
+		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+			     MMOP_ONLINE_KEEP);
+#endif
 	goto out;
 
 error:
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
