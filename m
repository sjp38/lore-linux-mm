Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4DF440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:31:06 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id y45so5011178qty.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:31:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor5305292qtq.15.2017.11.09.11.31.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 11:31:05 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 2/6] writeback: allow for dirty metadata accounting
Date: Thu,  9 Nov 2017 14:30:57 -0500
Message-Id: <1510255861-8020-2-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
References: <1510255861-8020-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Provide a mechanism for file systems to indicate how much dirty metadata they
are holding.  This introduces a few things

1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
2) WB stat for dirty metadata.  This way we know if we need to try and call into
the file system to write out metadata.  This could potentially be used in the
future to make balancing of dirty pages smarter.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 drivers/base/node.c              |   2 +
 fs/fs-writeback.c                |   1 +
 fs/proc/meminfo.c                |   2 +
 include/linux/backing-dev-defs.h |   1 +
 include/linux/mm.h               |   7 +++
 include/linux/mmzone.h           |   1 +
 include/trace/events/writeback.h |   7 ++-
 mm/backing-dev.c                 |   2 +
 mm/page-writeback.c              | 100 +++++++++++++++++++++++++++++++++++++--
 mm/page_alloc.c                  |   7 ++-
 10 files changed, 123 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 3855902f2c5b..39c031f44d4b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -99,6 +99,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d MetadataDirty:	%8lu kB\n"
 		       "Node %d Writeback:      %8lu kB\n"
 		       "Node %d FilePages:      %8lu kB\n"
 		       "Node %d Mapped:         %8lu kB\n"
@@ -119,6 +120,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       nid, K(node_page_state(pgdat, NR_METADATA_DIRTY)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
 		       nid, K(node_page_state(pgdat, NR_FILE_PAGES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 245c430a2e41..c5374a4fb982 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1822,6 +1822,7 @@ static unsigned long get_nr_dirty_pages(void)
 {
 	return global_node_page_state(NR_FILE_DIRTY) +
 		global_node_page_state(NR_UNSTABLE_NFS) +
+		global_node_page_state(NR_METADATA_DIRTY) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index cdd979724c74..f1cafc2aaade 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -98,6 +98,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "SwapFree:       ", i.freeswap);
 	show_val_kb(m, "Dirty:          ",
 		    global_node_page_state(NR_FILE_DIRTY));
+	seq_printf(m, "MetadataDirty:  %8lu kB\n",
+		   global_node_page_state(NR_METADATA_DIRTY));
 	show_val_kb(m, "Writeback:      ",
 		    global_node_page_state(NR_WRITEBACK));
 	show_val_kb(m, "AnonPages:      ",
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 866c433e7d32..013e764d4b30 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -36,6 +36,7 @@ typedef int (congested_fn)(void *, int);
 enum wb_stat_item {
 	WB_RECLAIMABLE,
 	WB_WRITEBACK,
+	WB_METADATA_DIRTY,
 	WB_DIRTIED,
 	WB_WRITTEN,
 	NR_WB_STAT_ITEMS
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d336e42..c6b4a6a62cc2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -32,6 +32,7 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
+struct backing_dev_info;
 
 void init_mm_internals(void);
 
@@ -1428,6 +1429,12 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
+void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi);
+void account_metadata_cleaned(struct page *page, struct backing_dev_info *bdi);
+void account_metadata_writeback(struct page *page,
+				struct backing_dev_info *bdi);
+void account_metadata_end_writeback(struct page *page,
+				    struct backing_dev_info *bdi);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 void cancel_dirty_page(struct page *page);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 356a814e7c8e..090fce6b1195 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -179,6 +179,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_METADATA_DIRTY,	/* Metadata dirty pages */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 9b57f014d79d..dd1564b5eab3 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -402,6 +402,7 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_STRUCT__entry(
 		__field(unsigned long,	nr_dirty)
+		__field(unsigned long,	nr_metadata_dirty)
 		__field(unsigned long,	nr_writeback)
 		__field(unsigned long,	nr_unstable)
 		__field(unsigned long,	background_thresh)
@@ -413,6 +414,7 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_fast_assign(
 		__entry->nr_dirty	= global_node_page_state(NR_FILE_DIRTY);
+		__entry->nr_metadata_dirty = global_node_page_state(NR_METADATA_DIRTY);
 		__entry->nr_writeback	= global_node_page_state(NR_WRITEBACK);
 		__entry->nr_unstable	= global_node_page_state(NR_UNSTABLE_NFS);
 		__entry->nr_dirtied	= global_node_page_state(NR_DIRTIED);
@@ -424,7 +426,7 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
 		  "bg_thresh=%lu thresh=%lu limit=%lu "
-		  "dirtied=%lu written=%lu",
+		  "dirtied=%lu written=%lu metadata_dirty=%lu",
 		  __entry->nr_dirty,
 		  __entry->nr_writeback,
 		  __entry->nr_unstable,
@@ -432,7 +434,8 @@ TRACE_EVENT(global_dirty_state,
 		  __entry->dirty_thresh,
 		  __entry->dirty_limit,
 		  __entry->nr_dirtied,
-		  __entry->nr_written
+		  __entry->nr_written,
+		  __entry->nr_metadata_dirty
 	)
 );
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606bb41a0..57f1dbc41f7e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -76,6 +76,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
+		   "BdiMetadataDirty:   %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -90,6 +91,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
 		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) K(wb_stat(wb, WB_METADATA_DIRTY)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 1a47d4296750..9539eae4f088 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -507,6 +507,7 @@ bool node_dirty_ok(struct pglist_data *pgdat)
 	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
 	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
 	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
+	nr_pages += node_page_state(pgdat, NR_METADATA_DIRTY);
 
 	return nr_pages <= limit;
 }
@@ -1595,7 +1596,8 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 		 * been flushed to permanent storage.
 		 */
 		nr_reclaimable = global_node_page_state(NR_FILE_DIRTY) +
-					global_node_page_state(NR_UNSTABLE_NFS);
+				global_node_page_state(NR_UNSTABLE_NFS) +
+				global_node_page_state(NR_METADATA_DIRTY);
 		gdtc->avail = global_dirtyable_memory();
 		gdtc->dirty = nr_reclaimable + global_node_page_state(NR_WRITEBACK);
 
@@ -1936,7 +1938,8 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	 */
 	gdtc->avail = global_dirtyable_memory();
 	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
-		      global_node_page_state(NR_UNSTABLE_NFS);
+		      global_node_page_state(NR_UNSTABLE_NFS) +
+		      global_node_page_state(NR_METADATA_DIRTY);
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
@@ -1980,7 +1983,8 @@ void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
 	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
+		global_node_page_state(NR_UNSTABLE_NFS) +
+		global_node_page_state(NR_METADATA_DIRTY);
 	struct bdi_writeback *wb;
 
 	/*
@@ -2444,6 +2448,96 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 EXPORT_SYMBOL(account_page_dirtied);
 
 /*
+ * account_metadata_dirtied
+ * @page - the page being dirited
+ * @bdi - the bdi that owns this page
+ *
+ * Do the dirty page accounting for metadata pages that aren't backed by an
+ * address_space.
+ */
+void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_node_page_state(page, NR_METADATA_DIRTY);
+	__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
+	__inc_node_page_state(page, NR_DIRTIED);
+	inc_wb_stat(&bdi->wb, WB_RECLAIMABLE);
+	inc_wb_stat(&bdi->wb, WB_DIRTIED);
+	inc_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
+	current->nr_dirtied++;
+	task_io_account_write(PAGE_SIZE);
+	this_cpu_inc(bdp_ratelimits);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_dirtied);
+
+/*
+ * account_metadata_cleaned
+ * @page - the page being cleaned
+ * @bdi - the bdi that owns this page
+ *
+ * Called on a no longer dirty metadata page.
+ */
+void account_metadata_cleaned(struct page *page, struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__dec_node_page_state(page, NR_METADATA_DIRTY);
+	__dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
+	dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
+	dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
+	task_io_account_cancelled_write(PAGE_SIZE);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_cleaned);
+
+/*
+ * account_metadata_writeback
+ * @page - the page being marked as writeback
+ * @bdi - the bdi that owns this page
+ *
+ * Called on a metadata page that has been marked writeback.
+ */
+void account_metadata_writeback(struct page *page,
+				struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	inc_wb_stat(&bdi->wb, WB_WRITEBACK);
+	__inc_node_page_state(page, NR_WRITEBACK);
+	__dec_node_page_state(page, NR_METADATA_DIRTY);
+	dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
+	dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_writeback);
+
+/*
+ * account_metadata_end_writeback
+ * @page - the page we are ending writeback on
+ * @bdi - the bdi that owns this page
+ *
+ * Called on a metadata page that has completed writeback.
+ */
+void account_metadata_end_writeback(struct page *page,
+				    struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	dec_wb_stat(&bdi->wb, WB_WRITEBACK);
+	__dec_node_page_state(page, NR_WRITEBACK);
+	__dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
+	__inc_node_page_state(page, NR_WRITTEN);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_end_writeback);
+
+/*
  * Helper function for deaccounting dirty page without writeback.
  *
  * Caller must hold lock_page_memcg().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c841af88836a..7f8eb1f861e5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4694,8 +4694,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
-		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
+		" unevictable:%lu dirty:%lu metadata_dirty:%lu writeback:%lu\n"
+	        " unstable:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
@@ -4706,6 +4706,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
 		global_node_page_state(NR_FILE_DIRTY),
+		global_node_page_state(NR_METADATA_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
 		global_node_page_state(NR_SLAB_RECLAIMABLE),
@@ -4732,6 +4733,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" isolated(file):%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
+			" metadata_dirty:%lukB"
 			" writeback:%lukB"
 			" shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -4753,6 +4755,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			K(node_page_state(pgdat, NR_METADATA_DIRTY)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
 			K(node_page_state(pgdat, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
