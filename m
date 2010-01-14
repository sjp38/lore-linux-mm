Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C50306B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 07:05:01 -0500 (EST)
Date: Thu, 14 Jan 2010 20:04:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] sysdev: fix prototype for memory_sysdev_class show/store
	functions
Message-ID: <20100114120419.GA3538@localhost>
References: <20100114115956.GA2512@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114115956.GA2512@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The function prototype mismatches in call stack:

                [<ffffffff81494268>] print_block_size+0x58/0x60
                [<ffffffff81487e3f>] sysdev_class_show+0x1f/0x30
                [<ffffffff811d629b>] sysfs_read_file+0xcb/0x1f0
                [<ffffffff81176328>] vfs_read+0xc8/0x180

Due to prototype mismatch, print_block_size() will sprintf() into
*attribute instead of *buf, hence user space will read the initial
zeros from *buf:
	$ hexdump /sys/devices/system/memory/block_size_bytes
	0000000 0000 0000 0000 0000
	0000008

After patch:
	cat /sys/devices/system/memory/block_size_bytes
	0x8000000

This complements commits c29af9636 and 4a0b2b4dbe.

CC: Andi Kleen <andi@firstfloor.org> 
CC: Greg Kroah-Hartman <gregkh@suse.de> 
CC: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/base/memory.c |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

--- linux-mm.orig/drivers/base/memory.c	2010-01-14 20:03:00.000000000 +0800
+++ linux-mm/drivers/base/memory.c	2010-01-14 20:03:01.000000000 +0800
@@ -309,17 +309,19 @@ static SYSDEV_ATTR(removable, 0444, show
  * Block size attribute stuff
  */
 static ssize_t
-print_block_size(struct class *class, char *buf)
+print_block_size(struct sysdev_class *class,
+		 struct sysdev_class_attribute *class_attr,
+		 char *buf)
 {
 	return sprintf(buf, "%#lx\n", (unsigned long)PAGES_PER_SECTION * PAGE_SIZE);
 }
 
-static CLASS_ATTR(block_size_bytes, 0444, print_block_size, NULL);
+static SYSDEV_CLASS_ATTR(block_size_bytes, 0444, print_block_size, NULL);
 
 static int block_size_init(void)
 {
 	return sysfs_create_file(&memory_sysdev_class.kset.kobj,
-				&class_attr_block_size_bytes.attr);
+				&attr_block_size_bytes.attr);
 }
 
 /*
@@ -330,7 +332,9 @@ static int block_size_init(void)
  */
 #ifdef CONFIG_ARCH_MEMORY_PROBE
 static ssize_t
-memory_probe_store(struct class *class, const char *buf, size_t count)
+memory_probe_store(struct sysdev_class *class,
+		   struct sysdev_class_attribute *class_attr,
+		   const char *buf, size_t count)
 {
 	u64 phys_addr;
 	int nid;
@@ -346,12 +350,12 @@ memory_probe_store(struct class *class, 
 
 	return count;
 }
-static CLASS_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
+static SYSDEV_CLASS_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
 
 static int memory_probe_init(void)
 {
 	return sysfs_create_file(&memory_sysdev_class.kset.kobj,
-				&class_attr_probe.attr);
+				&attr_probe.attr);
 }
 #else
 static inline int memory_probe_init(void)
@@ -367,7 +371,9 @@ static inline int memory_probe_init(void
 
 /* Soft offline a page */
 static ssize_t
-store_soft_offline_page(struct class *class, const char *buf, size_t count)
+store_soft_offline_page(struct sysdev_class *class,
+			struct sysdev_class_attribute *class_attr,
+			const char *buf, size_t count)
 {
 	int ret;
 	u64 pfn;
@@ -384,7 +390,9 @@ store_soft_offline_page(struct class *cl
 
 /* Forcibly offline a page, including killing processes. */
 static ssize_t
-store_hard_offline_page(struct class *class, const char *buf, size_t count)
+store_hard_offline_page(struct sysdev_class *class,
+			struct sysdev_class_attribute *class_attr,
+			const char *buf, size_t count)
 {
 	int ret;
 	u64 pfn;
@@ -397,18 +405,18 @@ store_hard_offline_page(struct class *cl
 	return ret ? ret : count;
 }
 
-static CLASS_ATTR(soft_offline_page, 0644, NULL, store_soft_offline_page);
-static CLASS_ATTR(hard_offline_page, 0644, NULL, store_hard_offline_page);
+static SYSDEV_CLASS_ATTR(soft_offline_page, 0644, NULL, store_soft_offline_page);
+static SYSDEV_CLASS_ATTR(hard_offline_page, 0644, NULL, store_hard_offline_page);
 
 static __init int memory_fail_init(void)
 {
 	int err;
 
 	err = sysfs_create_file(&memory_sysdev_class.kset.kobj,
-				&class_attr_soft_offline_page.attr);
+				&attr_soft_offline_page.attr);
 	if (!err)
 		err = sysfs_create_file(&memory_sysdev_class.kset.kobj,
-				&class_attr_hard_offline_page.attr);
+				&attr_hard_offline_page.attr);
 	return err;
 }
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
