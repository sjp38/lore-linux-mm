Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 776056B0260
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:57:07 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id 8so17071072qtv.11
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:57:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y46sor2041149qtk.84.2017.11.14.13.57.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 13:57:05 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 06/10] writeback: add counters for metadata usage
Date: Tue, 14 Nov 2017 16:56:52 -0500
Message-Id: <1510696616-8489-6-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Btrfs has no bounds except memory on the amount of dirty memory that we have in
use for metadata.  Historically we have used a special inode so we could take
advantage of the balance_dirty_pages throttling that comes with using pagecache.
However as we'd like to support different blocksizes it would be nice to not
have to rely on pagecache, but still get the balance_dirty_pages throttling
without having to do it ourselves.

So introduce *METADATA_DIRTY_BYTES and *METADATA_WRITEBACK_BYTES.  These are
zone and bdi_writeback counters to keep track of how many bytes we have in
flight for METADATA.  We need to count in bytes as blocksizes could be
percentages of pagesize.  We simply convert the bytes to number of pages where
it is needed for the throttling.

Also introduce NR_METADATA_BYTES so we can keep track of the total amount of
pages used for metadata on the system.  This is also needed so things like dirty
throttling know that this is dirtyable memory as well and easily reclaimed.

Signed-off-by: Josef Bacik <jbacik@fb.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 drivers/base/node.c              |   8 +++
 fs/fs-writeback.c                |   2 +
 fs/proc/meminfo.c                |   8 +++
 include/linux/backing-dev-defs.h |   2 +
 include/linux/mm.h               |   9 +++
 include/linux/mmzone.h           |   3 +
 include/trace/events/writeback.h |  13 +++-
 mm/backing-dev.c                 |   4 ++
 mm/page-writeback.c              | 141 +++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                  |  20 ++++--
 mm/util.c                        |   1 +
 mm/vmscan.c                      |  19 +++++-
 mm/vmstat.c                      |   3 +
 13 files changed, 211 insertions(+), 22 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 3855902f2c5b..a39cecc8957a 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -51,6 +51,8 @@ static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
+#define BtoK(x) ((x) >> 10)
+
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
 {
@@ -99,7 +101,10 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d MetadataDirty:	%8lu kB\n"
 		       "Node %d Writeback:      %8lu kB\n"
+		       "Node %d MetaWriteback:  %8lu kB\n"
+		       "Node %d Metadata:       %8lu kB\n"
 		       "Node %d FilePages:      %8lu kB\n"
 		       "Node %d Mapped:         %8lu kB\n"
 		       "Node %d AnonPages:      %8lu kB\n"
@@ -119,8 +124,11 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       nid, BtoK(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
+		       nid, BtoK(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_PAGES)),
+		       nid, BtoK(node_page_state(pgdat, NR_METADATA_BYTES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
 		       nid, K(i.sharedram),
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 245c430a2e41..987448ed7698 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1814,6 +1814,7 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 	return work;
 }
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 /*
  * Add in the number of potentially dirty inodes, because each inode
  * write can dirty pagecache in the underlying blockdev.
@@ -1822,6 +1823,7 @@ static unsigned long get_nr_dirty_pages(void)
 {
 	return global_node_page_state(NR_FILE_DIRTY) +
 		global_node_page_state(NR_UNSTABLE_NFS) +
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index cdd979724c74..fa1fd24a4d99 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -42,6 +42,8 @@ static void show_val_kb(struct seq_file *m, const char *s, unsigned long num)
 	seq_write(m, " kB\n", 4);
 }
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
+
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
@@ -71,6 +73,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Buffers:        ", i.bufferram);
 	show_val_kb(m, "Cached:         ", cached);
 	show_val_kb(m, "SwapCached:     ", total_swapcache_pages());
+	show_val_kb(m, "Metadata:       ",
+		    BtoP(global_node_page_state(NR_METADATA_BYTES)));
 	show_val_kb(m, "Active:         ", pages[LRU_ACTIVE_ANON] +
 					   pages[LRU_ACTIVE_FILE]);
 	show_val_kb(m, "Inactive:       ", pages[LRU_INACTIVE_ANON] +
@@ -98,8 +102,12 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "SwapFree:       ", i.freeswap);
 	show_val_kb(m, "Dirty:          ",
 		    global_node_page_state(NR_FILE_DIRTY));
+	show_val_kb(m, "MetadataDirty:  ",
+		    BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)));
 	show_val_kb(m, "Writeback:      ",
 		    global_node_page_state(NR_WRITEBACK));
+	show_val_kb(m, "MetaWriteback:  ",
+		    BtoP(global_node_page_state(NR_METADATA_WRITEBACK_BYTES)));
 	show_val_kb(m, "AnonPages:      ",
 		    global_node_page_state(NR_ANON_MAPPED));
 	show_val_kb(m, "Mapped:         ",
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index ded45ac2cec7..78c65e2910dc 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -38,6 +38,8 @@ enum wb_stat_item {
 	WB_WRITEBACK,
 	WB_DIRTIED_BYTES,
 	WB_WRITTEN_BYTES,
+	WB_METADATA_DIRTY_BYTES,
+	WB_METADATA_WRITEBACK_BYTES,
 	NR_WB_STAT_ITEMS
 };
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d336e42..e14ada96af25 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -32,6 +32,7 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
+struct backing_dev_info;
 
 void init_mm_internals(void);
 
@@ -1428,6 +1429,14 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb);
+void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi,
+			      long bytes);
+void account_metadata_cleaned(struct page *page, struct backing_dev_info *bdi,
+			      long bytes);
+void account_metadata_writeback(struct page *page,
+				struct backing_dev_info *bdi, long bytes);
+void account_metadata_end_writeback(struct page *page,
+				    struct backing_dev_info *bdi, long bytes);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 void cancel_dirty_page(struct page *page);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 356a814e7c8e..fd516a0f0bfe 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -179,6 +179,9 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_METADATA_DIRTY_BYTES,	/* Metadata dirty bytes */
+	NR_METADATA_WRITEBACK_BYTES,	/* Metadata writeback bytes */
+	NR_METADATA_BYTES,	/* total metadata bytes in use. */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 9b57f014d79d..989cdae363db 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -390,6 +390,8 @@ TRACE_EVENT(writeback_queue_io,
 	)
 );
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
+
 TRACE_EVENT(global_dirty_state,
 
 	TP_PROTO(unsigned long background_thresh,
@@ -402,7 +404,9 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_STRUCT__entry(
 		__field(unsigned long,	nr_dirty)
+		__field(unsigned long,	nr_metadata_dirty)
 		__field(unsigned long,	nr_writeback)
+		__field(unsigned long,	nr_metadata_writeback)
 		__field(unsigned long,	nr_unstable)
 		__field(unsigned long,	background_thresh)
 		__field(unsigned long,	dirty_thresh)
@@ -413,7 +417,9 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_fast_assign(
 		__entry->nr_dirty	= global_node_page_state(NR_FILE_DIRTY);
+		__entry->nr_metadata_dirty = BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES));
 		__entry->nr_writeback	= global_node_page_state(NR_WRITEBACK);
+		__entry->nr_metadata_dirty = BtoP(global_node_page_state(NR_METADATA_WRITEBACK_BYTES));
 		__entry->nr_unstable	= global_node_page_state(NR_UNSTABLE_NFS);
 		__entry->nr_dirtied	= global_node_page_state(NR_DIRTIED);
 		__entry->nr_written	= global_node_page_state(NR_WRITTEN);
@@ -424,7 +430,8 @@ TRACE_EVENT(global_dirty_state,
 
 	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
 		  "bg_thresh=%lu thresh=%lu limit=%lu "
-		  "dirtied=%lu written=%lu",
+		  "dirtied=%lu written=%lu metadata_dirty=%lu "
+		  "metadata_writeback=%lu",
 		  __entry->nr_dirty,
 		  __entry->nr_writeback,
 		  __entry->nr_unstable,
@@ -432,7 +439,9 @@ TRACE_EVENT(global_dirty_state,
 		  __entry->dirty_thresh,
 		  __entry->dirty_limit,
 		  __entry->nr_dirtied,
-		  __entry->nr_written
+		  __entry->nr_written,
+		  __entry->nr_metadata_dirty,
+		  __entry->nr_metadata_writeback
 	)
 );
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e0d7c62dc0ad..8961ac364f06 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -77,6 +77,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtiedBytes:    %10lu kB\n"
 		   "BdiWrittenBytes:    %10lu kB\n"
+		   "BdiMetadataDirty:   %10lu kB\n"
+		   "BdiMetaWriteback:	%10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -91,6 +93,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) BtoK(wb_stat(wb, WB_DIRTIED_BYTES)),
 		   (unsigned long) BtoK(wb_stat(wb, WB_WRITTEN_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_DIRTY_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c491dee711a8..d16703e6bde8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -297,6 +297,7 @@ static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 
 	nr_pages += node_page_state(pgdat, NR_INACTIVE_FILE);
 	nr_pages += node_page_state(pgdat, NR_ACTIVE_FILE);
+	nr_pages += node_page_state(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT;
 
 	return nr_pages;
 }
@@ -373,6 +374,7 @@ static unsigned long global_dirtyable_memory(void)
 
 	x += global_node_page_state(NR_INACTIVE_FILE);
 	x += global_node_page_state(NR_ACTIVE_FILE);
+	x += global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
@@ -381,6 +383,30 @@ static unsigned long global_dirtyable_memory(void)
 }
 
 /**
+ * global_dirty_memory - the number of globally dirty pages
+ *
+ * Returns the global number of pages that are dirty in pagecache and metadata.
+ */
+static unsigned long global_dirty_memory(void)
+{
+	return global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS) +
+		(global_node_page_state(NR_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
+}
+
+/**
+ * global_writeback_memory - the number of pages under writeback globally
+ *
+ * Returns the global number of pages under writeback both in pagecache and in
+ * metadata.
+ */
+static unsigned long global_writeback_memory(void)
+{
+	return global_node_page_state(NR_WRITEBACK) +
+		(global_node_page_state(NR_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT);
+}
+
+/**
  * domain_dirty_limits - calculate thresh and bg_thresh for a wb_domain
  * @dtc: dirty_throttle_control of interest
  *
@@ -492,6 +518,8 @@ static unsigned long node_dirty_limit(struct pglist_data *pgdat)
 	return dirty;
 }
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
+
 /**
  * node_dirty_ok - tells whether a node is within its dirty limits
  * @pgdat: the node to check
@@ -507,6 +535,8 @@ bool node_dirty_ok(struct pglist_data *pgdat)
 	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
 	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
 	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
+	nr_pages += BtoP(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES));
+	nr_pages += BtoP(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES));
 
 	return nr_pages <= limit;
 }
@@ -1519,7 +1549,7 @@ static long wb_min_pause(struct bdi_writeback *wb,
 static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 {
 	struct bdi_writeback *wb = dtc->wb;
-	unsigned long wb_reclaimable;
+	unsigned long wb_reclaimable, wb_writeback;
 
 	/*
 	 * wb_thresh is not treated as some limiting factor as
@@ -1549,12 +1579,17 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 	 * deltas.
 	 */
 	if (dtc->wb_thresh < 2 * wb_stat_error(wb)) {
-		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
-		dtc->wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
+		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE) +
+			(wb_stat_sum(wb, WB_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
+		wb_writeback = wb_stat_sum(wb, WB_WRITEBACK) +
+			(wb_stat_sum(wb, WB_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT);
 	} else {
-		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE);
-		dtc->wb_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
+		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE) +
+			(wb_stat(wb, WB_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
+		wb_writeback = wb_stat(wb, WB_WRITEBACK) +
+			(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT);
 	}
+	dtc->wb_dirty = wb_reclaimable + wb_writeback;
 }
 
 /*
@@ -1599,10 +1634,9 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		nr_reclaimable = global_node_page_state(NR_FILE_DIRTY) +
-					global_node_page_state(NR_UNSTABLE_NFS);
+		nr_reclaimable = global_dirty_memory();
 		gdtc->avail = global_dirtyable_memory();
-		gdtc->dirty = nr_reclaimable + global_node_page_state(NR_WRITEBACK);
+		gdtc->dirty = nr_reclaimable + global_writeback_memory();
 
 		domain_dirty_limits(gdtc);
 
@@ -1934,20 +1968,22 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	struct dirty_throttle_control * const gdtc = &gdtc_stor;
 	struct dirty_throttle_control * const mdtc = mdtc_valid(&mdtc_stor) ?
 						     &mdtc_stor : NULL;
+	unsigned long wb_reclaimable;
 
 	/*
 	 * Similar to balance_dirty_pages() but ignores pages being written
 	 * as we're trying to decide whether to put more under writeback.
 	 */
 	gdtc->avail = global_dirtyable_memory();
-	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
-		      global_node_page_state(NR_UNSTABLE_NFS);
+	gdtc->dirty = global_dirty_memory();
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
 		return true;
 
-	if (wb_stat(wb, WB_RECLAIMABLE) >
+	wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE) +
+		(wb_stat(wb, WB_METADATA_DIRTY_BYTES) >> PAGE_SHIFT);
+	if (wb_reclaimable >
 	    wb_calc_thresh(gdtc->wb, gdtc->bg_thresh))
 		return true;
 
@@ -1962,7 +1998,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		if (mdtc->dirty > mdtc->bg_thresh)
 			return true;
 
-		if (wb_stat(wb, WB_RECLAIMABLE) >
+		if (wb_reclaimable >
 		    wb_calc_thresh(mdtc->wb, mdtc->bg_thresh))
 			return true;
 	}
@@ -1984,8 +2020,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_dirty_memory();
 	struct bdi_writeback *wb;
 
 	/*
@@ -2449,6 +2484,84 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 EXPORT_SYMBOL(account_page_dirtied);
 
 /*
+ * account_metadata_dirtied
+ * @page - the page being dirited
+ * @bdi - the bdi that owns this page
+ * @bytes - the number of bytes being dirtied
+ *
+ * Do the dirty page accounting for metadata pages that aren't backed by an
+ * address_space.
+ */
+void account_metadata_dirtied(struct page *page, struct backing_dev_info *bdi,
+			      long bytes)
+{
+	mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+			    bytes);
+	__add_wb_stat(&bdi->wb, WB_DIRTIED_BYTES, bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, bytes);
+	current->nr_dirtied++;
+	task_io_account_write(bytes);
+	this_cpu_inc(bdp_ratelimits);
+}
+EXPORT_SYMBOL(account_metadata_dirtied);
+
+/*
+ * account_metadata_cleaned
+ * @page - the page being cleaned
+ * @bdi - the bdi that owns this page
+ * @bytes - the number of bytes cleaned
+ *
+ * Called on a no longer dirty metadata page.
+ */
+void account_metadata_cleaned(struct page *page, struct backing_dev_info *bdi,
+			      long bytes)
+{
+	mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+			    -bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, -bytes);
+	task_io_account_cancelled_write(bytes);
+}
+EXPORT_SYMBOL(account_metadata_cleaned);
+
+/*
+ * account_metadata_writeback
+ * @page - the page being marked as writeback
+ * @bdi - the bdi that owns this page
+ * @bytes - the number of bytes we are submitting for writeback
+ *
+ * Called on a metadata page that has been marked writeback.
+ */
+void account_metadata_writeback(struct page *page,
+				struct backing_dev_info *bdi, long bytes)
+{
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, -bytes);
+	mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+					 -bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, bytes);
+	mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
+					 bytes);
+}
+EXPORT_SYMBOL(account_metadata_writeback);
+
+/*
+ * account_metadata_end_writeback
+ * @page - the page we are ending writeback on
+ * @bdi - the bdi that owns this page
+ * @bytes - the number of bytes that just ended writeback
+ *
+ * Called on a metadata page that has completed writeback.
+ */
+void account_metadata_end_writeback(struct page *page,
+				    struct backing_dev_info *bdi, long bytes)
+{
+	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, -bytes);
+	mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
+			    -bytes);
+	__wb_writeout_add(&bdi->wb, bytes);
+}
+EXPORT_SYMBOL(account_metadata_end_writeback);
+
+/*
  * Helper function for deaccounting dirty page without writeback.
  *
  * Caller must hold lock_page_memcg().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c841af88836a..aab0dd6aa8d7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4640,6 +4640,8 @@ static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+#define BtoK(x) ((x) >> 10)
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 
 static void show_migration_types(unsigned char type)
 {
@@ -4694,10 +4696,11 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
-		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" unevictable:%lu metadata:%lu dirty:%lu metadata_dirty:%lu\n"
+		" writeback:%lu unstable:%lu metadata_writeback:%lu\n"
+		" slab_reclaimable:%lu slab_unreclaimable:%lu mapped:%lu\n"
+		" shmem:%lu pagetables:%lu bounce:%lu free:%lu free_pcp:%lu\n"
+	        " free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
 		global_node_page_state(NR_ISOLATED_ANON),
@@ -4705,9 +4708,12 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_INACTIVE_FILE),
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
+		BtoP(global_node_page_state(NR_METADATA_BYTES)),
 		global_node_page_state(NR_FILE_DIRTY),
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
+		BtoP(global_node_page_state(NR_METADATA_WRITEBACK_BYTES)),
 		global_node_page_state(NR_SLAB_RECLAIMABLE),
 		global_node_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
@@ -4730,9 +4736,12 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" metadata:%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
+			" metadata_dirty:%lukB"
 			" writeback:%lukB"
+			" metadata_writeback:%lukB"
 			" shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			" shmem_thp: %lukB"
@@ -4751,9 +4760,12 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			BtoK(node_page_state(pgdat, NR_METADATA_BYTES)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			BtoK(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
+			BtoK(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES)),
 			K(node_page_state(pgdat, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
diff --git a/mm/util.c b/mm/util.c
index 34e57fae959d..681d62631ee0 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -616,6 +616,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_zone_page_state(NR_FREE_PAGES);
 		free += global_node_page_state(NR_FILE_PAGES);
+		free += global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d711dd8776..415b003e475c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -225,7 +225,8 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 
 	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
 	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
+	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE) +
+	     (node_page_state_snapshot(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT);
 
 	if (get_nr_swap_pages() > 0)
 		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
@@ -3812,6 +3813,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
 static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 {
 	unsigned long nr_pagecache_reclaimable;
+	unsigned long nr_metadata_reclaimable;
 	unsigned long delta = 0;
 
 	/*
@@ -3833,7 +3835,20 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 	if (unlikely(delta > nr_pagecache_reclaimable))
 		delta = nr_pagecache_reclaimable;
 
-	return nr_pagecache_reclaimable - delta;
+	nr_metadata_reclaimable =
+		node_page_state(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT;
+	/*
+	 * We don't do writeout through the shrinkers so subtract any
+	 * dirty/writeback metadata bytes from the reclaimable count.
+	 */
+	if (nr_metadata_reclaimable) {
+		unsigned long unreclaimable =
+			node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) +
+			node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES);
+		unreclaimable >>= PAGE_SHIFT;
+		nr_metadata_reclaimable -= unreclaimable;
+	}
+	return nr_metadata_reclaimable + nr_pagecache_reclaimable - delta;
 }
 
 /*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4bb13e72ac97..1d8c93ec486e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1090,6 +1090,9 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
+	"nr_metadata_dirty_bytes",
+	"nr_metadata_writeback_bytes",
+	"nr_metadata_bytes",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
