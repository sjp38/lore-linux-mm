Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6B44D6B02A5
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 20:43:37 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 2/2] writeback: Adding pages_dirtied and pages_entered_writeback
Date: Wed,  4 Aug 2010 17:43:24 -0700
Message-Id: <1280969004-29530-3-git-send-email-mrubin@google.com>
In-Reply-To: <1280969004-29530-1-git-send-email-mrubin@google.com>
References: <1280969004-29530-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

To help developers and applications gain visibility into writeback
behaviour adding four read only sysctl files into /proc/sys/vm.
These files allow user apps to understand writeback behaviour over time
and learn how it is impacting their performance.

   # cat /proc/sys/vm/pages_dirtied
   3747
   # cat /proc/sys/vm/pages_entered_writeback
   3618

Documentation/vm.txt has been updated.

In order to track the "cleaned" and "dirtied" counts we added two
vm_stat_items.  Per memory node stats have been added also. So we can
see per node granularity:

   # cat /sys/devices/system/node/node20/writebackstat
   Node 20 pages_writeback: 0 times
   Node 20 pages_dirtied: 0 times

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 Documentation/sysctl/vm.txt |   20 ++++++++++++++++----
 drivers/base/node.c         |   14 ++++++++++++++
 include/linux/mmzone.h      |    2 ++
 include/linux/writeback.h   |    9 +++++++++
 kernel/sysctl.c             |   14 ++++++++++++++
 mm/page-writeback.c         |   36 ++++++++++++++++++++++++++++++------
 mm/vmstat.c                 |    2 ++
 7 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 5fdbb61..de9ec6a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -50,6 +50,8 @@ Currently, these files are in /proc/sys/vm:
 - overcommit_memory
 - overcommit_ratio
 - page-cluster
+- pages_dirtied
+- pages_entered_writeback
 - panic_on_oom
 - percpu_pagelist_fraction
 - stat_interval
@@ -425,10 +427,7 @@ See Documentation/vm/hugetlbpage.txt
 nr_pdflush_threads
 
 The current number of pdflush threads.  This value is read-only.
-The value changes according to the number of dirty pages in the system.
-
-When necessary, additional pdflush threads are created, one per second, up to
-nr_pdflush_threads_max.
+This value is obsolete.
 
 ==============================================================
 
@@ -582,6 +581,19 @@ swap-intensive.
 
 =============================================================
 
+pages_dirtied
+
+Number of pages that have ever been dirtied since boot.
+This value is read-only.
+
+=============================================================
+
+pages_entered_writeback
+
+Number of pages that have been moved from dirty to writeback since boot.
+This is only a count of file pages. This value is read-only.
+
+=============================================================
 panic_on_oom
 
 This enables or disables panic on out-of-memory feature.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2bdd8a9..b321d32 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -160,6 +160,18 @@ static ssize_t node_read_numastat(struct sys_device * dev,
 }
 static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
+static ssize_t node_read_writebackstat(struct sys_device *dev,
+				struct sysdev_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	return sprintf(buf,
+		"Node %d pages_writeback: %lu times\n"
+		"Node %d pages_dirtied: %lu times\n",
+		nid, node_page_state(nid, NR_PAGES_ENTERED_WRITEBACK),
+		nid, node_page_state(nid, NR_FILE_PAGES_DIRTIED));
+}
+static SYSDEV_ATTR(writebackstat, S_IRUGO, node_read_writebackstat, NULL);
+
 static ssize_t node_read_distance(struct sys_device * dev,
 			struct sysdev_attribute *attr, char * buf)
 {
@@ -243,6 +255,7 @@ int register_node(struct node *node, int num, struct node *parent)
 		sysdev_create_file(&node->sysdev, &attr_meminfo);
 		sysdev_create_file(&node->sysdev, &attr_numastat);
 		sysdev_create_file(&node->sysdev, &attr_distance);
+		sysdev_create_file(&node->sysdev, &attr_writebackstat);
 
 		scan_unevictable_register_node(node);
 
@@ -267,6 +280,7 @@ void unregister_node(struct node *node)
 	sysdev_remove_file(&node->sysdev, &attr_meminfo);
 	sysdev_remove_file(&node->sysdev, &attr_numastat);
 	sysdev_remove_file(&node->sysdev, &attr_distance);
+	sysdev_remove_file(&node->sysdev, &attr_writebackstat);
 
 	scan_unevictable_unregister_node(node);
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b4d109e..c0cd2bd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -112,6 +112,8 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	NR_PAGES_ENTERED_WRITEBACK, /* number of times pages enter writeback */
+	NR_FILE_PAGES_DIRTIED,    /* number of times pages get dirtied */
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c24eca7..2d47afb 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -99,6 +99,8 @@ extern int dirty_background_ratio;
 extern unsigned long dirty_background_bytes;
 extern int vm_dirty_ratio;
 extern unsigned long vm_dirty_bytes;
+extern unsigned long vm_pages_dirtied;
+extern unsigned long vm_pages_entered_writeback;
 extern unsigned int dirty_writeback_interval;
 extern unsigned int dirty_expire_interval;
 extern int vm_highmem_is_dirtyable;
@@ -120,6 +122,13 @@ extern int dirty_bytes_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 
+extern int pages_dirtied_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+extern int pages_entered_writeback_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+
 struct ctl_table;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d24f761..33c3589 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1053,6 +1053,20 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "pages_dirtied",
+		.data		= &vm_pages_dirtied,
+		.maxlen		= sizeof(vm_pages_dirtied),
+		.mode		= 0444 /* read-only */,
+		.proc_handler	= pages_dirtied_handler,
+	},
+	{
+		.procname	= "pages_entered_writeback",
+		.data		= &vm_pages_entered_writeback,
+		.maxlen		= sizeof(vm_pages_entered_writeback),
+		.mode		= 0444 /* read-only */,
+		.proc_handler	= pages_entered_writeback_handler,
+	},
+	{
 		.procname	= "nr_pdflush_threads",
 		.data		= &nr_pdflush_threads,
 		.maxlen		= sizeof nr_pdflush_threads,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b8e7b3b..4ed5dec 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -95,6 +95,14 @@ unsigned int dirty_writeback_interval = 5 * 100; /* centiseconds */
  */
 unsigned int dirty_expire_interval = 30 * 100; /* centiseconds */
 
+
+/*
+ * Number of pages dirtied and entered writeback state
+ */
+
+unsigned long vm_pages_dirtied;
+unsigned long vm_pages_entered_writeback;
+
 /*
  * Flag that makes the machine dump writes/reads and block dirtyings.
  */
@@ -196,7 +204,6 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
-
 int dirty_bytes_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
@@ -212,6 +219,23 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
+int pages_dirtied_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	vm_pages_dirtied = global_page_state(NR_FILE_PAGES_DIRTIED);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+}
+
+int pages_entered_writeback_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	vm_pages_entered_writeback =
+		global_page_state(NR_PAGES_ENTERED_WRITEBACK);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+}
+
 /*
  * Increment the BDI's writeout completion count and the global writeout
  * completion count. Called from test_clear_page_writeback().
@@ -1091,6 +1115,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_FILE_PAGES_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -1103,15 +1128,15 @@ EXPORT_SYMBOL(account_page_dirtied);
  * NOTE: Unlike account_page_dirtied this does not rely on being atomic
  * wrt interrupts.
  */
-
 void account_page_writeback(struct page *page, struct address_space *mapping)
 {
-	if (mapping_cap_account_dirty(mapping))
+	if (mapping_cap_account_dirty(mapping)) {
 		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_PAGES_ENTERED_WRITEBACK);
+	}
 }
 EXPORT_SYMBOL(account_page_writeback);
 
-
 /*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
@@ -1347,9 +1372,8 @@ int test_set_page_writeback(struct page *page)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret)
-		inc_zone_page_state(page, NR_WRITEBACK);
+		account_page_writeback(page, mapping);
 	return ret;
-
 }
 EXPORT_SYMBOL(test_set_page_writeback);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..e177a40 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -740,6 +740,8 @@ static const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
+	"nr_pages_entered_writeback",
+	"nr_file_pages_dirtied",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
