Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA3036B0253
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 13:35:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so207107809pfg.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 10:35:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id al5si26832673pad.16.2016.08.22.10.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 10:35:22 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 2/3] writeback: allow for dirty metadata accounting
Date: Mon, 22 Aug 2016 13:35:01 -0400
Message-ID: <1471887302-12730-3-git-send-email-jbacik@fb.com>
In-Reply-To: <1471887302-12730-1-git-send-email-jbacik@fb.com>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

Provide a mechanism for file systems to indicate how much dirty metadata they
are holding.  This introduces a few things

1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
2) WB stat for dirty metadata.  This way we know if we need to try and call into
the file system to write out metadata.  This could potentially be used in the
future to make balancing of dirty pages smarter.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 arch/tile/mm/pgtable.c           |   3 +-
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
 mm/vmscan.c                      |   3 +-
 12 files changed, 127 insertions(+), 9 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7cc6ee7..9543468 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -44,12 +44,13 @@ void show_mem(unsigned int filter)
 {
 	struct zone *zone;
 
-	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
+	pr_err("Active:%lu inactive:%lu dirty:%lu metadata_dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
 	       (global_node_page_state(NR_ACTIVE_ANON) +
 		global_node_page_state(NR_ACTIVE_FILE)),
 	       (global_node_page_state(NR_INACTIVE_ANON) +
 		global_node_page_state(NR_INACTIVE_FILE)),
 	       global_node_page_state(NR_FILE_DIRTY),
+	       global_node_page_state(NR_METADATA_DIRTY),
 	       global_node_page_state(NR_WRITEBACK),
 	       global_node_page_state(NR_UNSTABLE_NFS),
 	       global_page_state(NR_FREE_PAGES),
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..efc867b2 100644
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
index 56c8fda..d329f89 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1809,6 +1809,7 @@ static unsigned long get_nr_dirty_pages(void)
 {
 	return global_node_page_state(NR_FILE_DIRTY) +
 		global_node_page_state(NR_UNSTABLE_NFS) +
+		global_node_page_state(NR_METADATA_DIRTY) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 09e18fd..8ca094f 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -80,6 +80,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"SwapTotal:      %8lu kB\n"
 		"SwapFree:       %8lu kB\n"
 		"Dirty:          %8lu kB\n"
+		"MetadataDirty:  %8lu kB\n"
 		"Writeback:      %8lu kB\n"
 		"AnonPages:      %8lu kB\n"
 		"Mapped:         %8lu kB\n"
@@ -139,6 +140,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.totalswap),
 		K(i.freeswap),
 		K(global_node_page_state(NR_FILE_DIRTY)),
+		K(global_node_page_state(NR_METADATA_DIRTY)),
 		K(global_node_page_state(NR_WRITEBACK)),
 		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 3f10307..1200aae 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -34,6 +34,7 @@ typedef int (congested_fn)(void *, int);
 enum wb_stat_item {
 	WB_RECLAIMABLE,
 	WB_WRITEBACK,
+	WB_METADATA_DIRTY,
 	WB_DIRTIED,
 	WB_WRITTEN,
 	NR_WB_STAT_ITEMS
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53e..5a3f626 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -31,6 +31,7 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
+struct backing_dev_info;
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -1363,6 +1364,12 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
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
index f2e4e90..c4177ef 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -167,6 +167,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_METADATA_DIRTY,	/* Metadata dirty pages */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 2ccd9cc..c9f6427 100644
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
index efe2377..b48d4e4 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -78,6 +78,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
+		   "BdiMetadataDirty:   %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -92,6 +93,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
 		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) K(wb_stat(wb, WB_METADATA_DIRTY)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 121a6e3..6a52723 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -506,6 +506,7 @@ bool node_dirty_ok(struct pglist_data *pgdat)
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
 
@@ -1935,7 +1937,8 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	 */
 	gdtc->avail = global_dirtyable_memory();
 	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
-		      global_node_page_state(NR_UNSTABLE_NFS);
+		      global_node_page_state(NR_UNSTABLE_NFS) +
+		      global_node_page_state(NR_METADATA_DIRTY);
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
@@ -2009,7 +2012,8 @@ void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
 	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
+		global_node_page_state(NR_UNSTABLE_NFS) +
+		global_node_page_state(NR_METADATA_DIRTY);
 	struct bdi_writeback *wb;
 
 	/*
@@ -2473,6 +2477,96 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
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
+	__inc_wb_stat(&bdi->wb, WB_RECLAIMABLE);
+	__inc_wb_stat(&bdi->wb, WB_DIRTIED);
+	__inc_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
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
+	__dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
+	__dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
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
+	__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
+	__inc_node_page_state(page, NR_WRITEBACK);
+	__dec_node_page_state(page, NR_METADATA_DIRTY);
+	__dec_wb_stat(&bdi->wb, WB_METADATA_DIRTY);
+	__dec_wb_stat(&bdi->wb, WB_RECLAIMABLE);
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
+	__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
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
index 39a372a..bc3523e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4218,8 +4218,8 @@ void show_free_areas(unsigned int filter)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
-		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
+		" unevictable:%lu dirty:%lu metadata_dirty:%lu writeback:%lu\n"
+	        " unstable:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
@@ -4230,6 +4230,7 @@ void show_free_areas(unsigned int filter)
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
 		global_node_page_state(NR_FILE_DIRTY),
+		global_node_page_state(NR_METADATA_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_SLAB_RECLAIMABLE),
@@ -4253,6 +4254,7 @@ void show_free_areas(unsigned int filter)
 			" isolated(file):%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
+			" metadata_dirty:%lukB"
 			" writeback:%lukB"
 			" shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -4275,6 +4277,7 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			K(node_page_state(pgdat, NR_METADATA_DIRTY)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d..fb3eb62 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3714,7 +3714,8 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 
 	/* If we can't clean pages, remove dirty pages from consideration */
 	if (!(node_reclaim_mode & RECLAIM_WRITE))
-		delta += node_page_state(pgdat, NR_FILE_DIRTY);
+		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
+			node_page_state(pgdat, NR_METADATA_DIRTY);
 
 	/* Watch for any possible underflows due to delta */
 	if (unlikely(delta > nr_pagecache_reclaimable))
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
