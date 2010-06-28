Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABFFD600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 13:45:30 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH] Adding four read-only files to /proc/sys/vm
Date: Mon, 28 Jun 2010 10:44:59 -0700
Message-Id: <1277747099-12770-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Adding four read-only files to /proc/sys/vm

To help developers and applications gain visibility into writeback
behaviour adding four read only sysctl files into /proc/sys/vm.
These files allow user apps to understand writeback behaviour over time
and learn how it is impacting their performance.

    # cat /proc/sys/vm/pages_dirtied
    3747
    # cat /proc/sys/vm/pages_entered_writeback
    3618
    # cat /proc/sys/vm/dirty_threshold
    816673
    # cat /proc/sys/vm/dirty_background_threshold
    408336

Documentation/vm.txt has been updated.

In order to track the "cleaned" and "dirtied" counts we added two
vm_stat_items.  Per memory node stats have been added also. So we can
see per node granularity:

    # cat /sys/devices/system/node/node20/writebackstat
    Node 20 pages_writeback: 0 times
    Node 20 pages_dirtied: 0 times

A helper function, account_page_writeback, was added to encapsulate
incrementing vm stats from nilfs. ceph code was also changed to use a
mm helper routine.

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 Documentation/sysctl/vm.txt |   41 +++++++++++++++++++++++++---
 drivers/base/node.c         |   14 +++++++++
 fs/ceph/addr.c              |    8 +-----
 fs/nilfs2/segment.c         |    2 +-
 include/linux/mm.h          |    1 +
 include/linux/mmzone.h      |    2 +
 include/linux/writeback.h   |   17 ++++++++++++
 kernel/sysctl.c             |   28 +++++++++++++++++++
 mm/page-writeback.c         |   62 ++++++++++++++++++++++++++++++++++++++++--
 mm/vmstat.c                 |    2 +
 10 files changed, 162 insertions(+), 15 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 5fdbb61..d777462 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -22,9 +22,11 @@ Currently, these files are in /proc/sys/vm:
 - compact_memory
 - dirty_background_bytes
 - dirty_background_ratio
+- dirty_background_threshold
 - dirty_bytes
 - dirty_expire_centisecs
 - dirty_ratio
+- dirty_threshold
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
@@ -50,6 +52,8 @@ Currently, these files are in /proc/sys/vm:
 - overcommit_memory
 - overcommit_ratio
 - page-cluster
+- pages_dirtied
+- pages_entered_writeback
 - panic_on_oom
 - percpu_pagelist_fraction
 - stat_interval
@@ -92,6 +96,15 @@ the pdflush background writeback daemon will start writing out dirty data.
 
 ==============================================================
 
+dirty_background_threshold
+
+Contains the exact amount of dirty memory memory the kernel uses to trigger the
+background writeout daemon will start writing out dirty data. This value
+depends on memory state, dirty_background_ratio and/or
+dirty_background_bytes. This value is read-only.
+
+==============================================================
+
 dirty_bytes
 
 Contains the amount of dirty memory at which a process generating disk writes
@@ -123,6 +136,15 @@ data.
 
 ==============================================================
 
+dirty_threshold
+
+Contains the exact amount of dirty memory the kernel uses to decide when
+a process which is generating disk writes will itself start writing
+out data. This value depends on memory state, dirty_ratio and/or
+dirty_bytes. This value is read-only.
+
+==============================================================
+
 dirty_writeback_centisecs
 
 The pdflush writeback daemons will periodically wake up and write `old' data
@@ -425,10 +447,7 @@ See Documentation/vm/hugetlbpage.txt
 nr_pdflush_threads
 
 The current number of pdflush threads.  This value is read-only.
-The value changes according to the number of dirty pages in the system.
-
-When necessary, additional pdflush threads are created, one per second, up to
-nr_pdflush_threads_max.
+This value is obsolete.
 
 ==============================================================
 
@@ -580,8 +599,22 @@ The default value is three (eight pages at a time).  There may be some
 small benefits in tuning this to a different value if your workload is
 swap-intensive.
 
+
+=============================================================
+
+pages_dirtied
+
+Number of pages that have ever been dirtied since boot.
+This value is read-only.
+
 =============================================================
 
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
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index d9c60b8..88c1d6e 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -105,13 +105,7 @@ static int ceph_set_page_dirty(struct page *page)
 	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(!PageUptodate(page));
-
-		if (mapping_cap_account_dirty(mapping)) {
-			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			__inc_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			task_io_account_write(PAGE_CACHE_SIZE);
-		}
+		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index c920164..5166e34 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1599,7 +1599,7 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
 	kunmap_atomic(kaddr, KM_USER0);
 
 	if (!TestSetPageWriteback(clone_page))
-		inc_zone_page_state(clone_page, NR_WRITEBACK);
+		account_page_writeback(page, page_mapping(page));
 	unlock_page(clone_page);
 
 	return 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b969efb..b951082 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -855,6 +855,7 @@ int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
 void account_page_dirtied(struct page *page, struct address_space *mapping);
+void account_page_writeback(struct page *page, struct address_space *mapping);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
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
index f641346..8bb9908 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -111,6 +111,10 @@ extern int dirty_background_ratio;
 extern unsigned long dirty_background_bytes;
 extern int vm_dirty_ratio;
 extern unsigned long vm_dirty_bytes;
+extern unsigned long vm_pages_dirtied;
+extern unsigned long vm_pages_entered_writeback;
+extern unsigned long vm_dirty_threshold;
+extern unsigned long vm_bg_threshold;
 extern unsigned int dirty_writeback_interval;
 extern unsigned int dirty_expire_interval;
 extern int vm_highmem_is_dirtyable;
@@ -132,6 +136,19 @@ extern int dirty_bytes_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 
+extern int pages_dirtied_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+extern int pages_entered_writeback_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+extern int dirty_threshold_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+extern int bg_threshold_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+
 struct ctl_table;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d24f761..55cdec9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1053,6 +1053,34 @@ static struct ctl_table vm_table[] = {
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
+		.procname	= "dirty_threshold",
+		.data		= &vm_dirty_threshold,
+		.maxlen		= sizeof(vm_dirty_threshold),
+		.mode		= 0444 /* read-only */,
+		.proc_handler	= dirty_threshold_handler,
+	},
+	{
+		.procname	= "dirty_background_threshold",
+		.data		= &vm_bg_threshold,
+		.maxlen		= sizeof(vm_bg_threshold),
+		.mode		= 0444 /* read-only */,
+		.proc_handler	= bg_threshold_handler,
+	},
+	{
 		.procname	= "nr_pdflush_threads",
 		.data		= &nr_pdflush_threads,
 		.maxlen		= sizeof nr_pdflush_threads,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 5fa63bd..dbd32b0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -95,6 +95,20 @@ unsigned int dirty_writeback_interval = 5 * 100; /* centiseconds */
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
+/*
+ * Dirty thresholds for export
+ */
+unsigned long vm_dirty_threshold;
+unsigned long vm_bg_threshold;
+
 /*
  * Flag that makes the machine dump writes/reads and block dirtyings.
  */
@@ -196,7 +210,6 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
-
 int dirty_bytes_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
@@ -212,6 +225,41 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
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
+int dirty_threshold_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	unsigned long bg_thresh;
+	get_dirty_limits(&bg_thresh, &vm_dirty_threshold, NULL, NULL);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+}
+
+int bg_threshold_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	unsigned long dirty_thresh;
+	get_dirty_limits(&vm_bg_threshold, &dirty_thresh, NULL, NULL);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+}
+
 /*
  * Increment the BDI's writeout completion count and the global writeout
  * completion count. Called from test_clear_page_writeback().
@@ -1083,12 +1131,21 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_FILE_PAGES_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
 }
 
+void account_page_writeback(struct page *page, struct address_space *mapping)
+{
+	if (mapping_cap_account_dirty(mapping)) {
+		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_PAGES_ENTERED_WRITEBACK);
+	}
+}
+
 /*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
@@ -1324,9 +1381,8 @@ int test_set_page_writeback(struct page *page)
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
