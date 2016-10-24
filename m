Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33E7E6B0266
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:44:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so130096085pfj.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:44:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r15si17210304pfi.259.2016.10.24.13.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:44:38 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 3/5] writeback: add counters for metadata usage
Date: Mon, 24 Oct 2016 16:43:47 -0400
Message-ID: <1477341829-18673-4-git-send-email-jbacik@fb.com>
In-Reply-To: <1477341829-18673-1-git-send-email-jbacik@fb.com>
References: <1477341829-18673-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, kernel-team@fb.com, david@fromorbit.org, jack@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org, jweiner@fb.com

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
---
 arch/tile/mm/pgtable.c           |   5 +-
 drivers/base/node.c              |   8 ++
 fs/fs-writeback.c                |   2 +
 fs/proc/meminfo.c                |   7 ++
 include/linux/backing-dev-defs.h |   2 +
 include/linux/mm.h               |   9 +++
 include/linux/mmzone.h           |   3 +
 include/trace/events/writeback.h |  13 +++-
 mm/backing-dev.c                 |   4 +
 mm/page-writeback.c              | 157 +++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                  |  20 ++++-
 mm/util.c                        |   2 +
 mm/vmscan.c                      |  19 ++++-
 mm/vmstat.c                      |   3 +
 14 files changed, 229 insertions(+), 25 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7cc6ee7..a159459 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -44,13 +44,16 @@ void show_mem(unsigned int filter)
 {
 	struct zone *zone;
 
-	pr_err("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
+	pr_err("Active:%lu inactive:%lu dirty:%lu metadata:%lu metadata_dirty:%lu writeback:%lu metadata_writeback:%lu unstable:%lu free:%lu\n slab:%lu mapped:%lu pagetables:%lu bounce:%lu pagecache:%lu swap:%lu\n",
 	       (global_node_page_state(NR_ACTIVE_ANON) +
 		global_node_page_state(NR_ACTIVE_FILE)),
 	       (global_node_page_state(NR_INACTIVE_ANON) +
 		global_node_page_state(NR_INACTIVE_FILE)),
 	       global_node_page_state(NR_FILE_DIRTY),
+	       global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT,
+	       global_node_page_state(NR_METADATA_DIRTY_BYTES) >> PAGE_SHIFT,
 	       global_node_page_state(NR_WRITEBACK),
+	       global_node_page_state(NR_METADATA_WRITEBACK_BYTES) >> PAGE_SHIFT,
 	       global_node_page_state(NR_UNSTABLE_NFS),
 	       global_page_state(NR_FREE_PAGES),
 	       (global_page_state(NR_SLAB_RECLAIMABLE) +
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..9d6c239 100644
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
index 05713a5..a5cb1dd 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1802,6 +1802,7 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 	return work;
 }
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 /*
  * Add in the number of potentially dirty inodes, because each inode
  * write can dirty pagecache in the underlying blockdev.
@@ -1810,6 +1811,7 @@ static unsigned long get_nr_dirty_pages(void)
 {
 	return global_node_page_state(NR_FILE_DIRTY) +
 		global_node_page_state(NR_UNSTABLE_NFS) +
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index b9a8c81..72da154 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -36,6 +36,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
  * display in kilobytes.
  */
 #define K(x) ((x) << (PAGE_SHIFT - 10))
+#define BtoK(x) ((x) >> 10)
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
@@ -60,6 +61,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"Buffers:        %8lu kB\n"
 		"Cached:         %8lu kB\n"
 		"SwapCached:     %8lu kB\n"
+		"Metadata:       %8lu kB\n"
 		"Active:         %8lu kB\n"
 		"Inactive:       %8lu kB\n"
 		"Active(anon):   %8lu kB\n"
@@ -80,7 +82,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"SwapTotal:      %8lu kB\n"
 		"SwapFree:       %8lu kB\n"
 		"Dirty:          %8lu kB\n"
+		"MetadataDirty:  %8lu kB\n"
 		"Writeback:      %8lu kB\n"
+		"MetaWriteback:  %8lu kB\n"
 		"AnonPages:      %8lu kB\n"
 		"Mapped:         %8lu kB\n"
 		"Shmem:          %8lu kB\n"
@@ -119,6 +123,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.bufferram),
 		K(cached),
 		K(total_swapcache_pages()),
+		BtoK(global_node_page_state(NR_METADATA_BYTES)),
 		K(pages[LRU_ACTIVE_ANON]   + pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_ANON] + pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_ACTIVE_ANON]),
@@ -139,7 +144,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.totalswap),
 		K(i.freeswap),
 		K(global_node_page_state(NR_FILE_DIRTY)),
+		BtoK(global_node_page_state(NR_METADATA_DIRTY_BYTES)),
 		K(global_node_page_state(NR_WRITEBACK)),
+		BtoK(global_node_page_state(NR_METADATA_WRITEBACK_BYTES)),
 		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 71ea5a6..b1f8f70 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -36,6 +36,8 @@ enum wb_stat_item {
 	WB_WRITEBACK,
 	WB_DIRTIED_BYTES,
 	WB_WRITTEN_BYTES,
+	WB_METADATA_DIRTY_BYTES,
+	WB_METADATA_WRITEBACK_BYTES,
 	NR_WB_STAT_ITEMS
 };
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9..8b425ae 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -31,6 +31,7 @@ struct file_ra_state;
 struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
+struct backing_dev_info;
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -1363,6 +1364,14 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
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
index 7f2ae99..89db46c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -169,6 +169,9 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_METADATA_DIRTY_BYTES,	/* Metadata dirty bytes */
+	NR_METADATA_WRITEBACK_BYTES,	/* Metadata writeback bytes */
+	NR_METADATA_BYTES,	/* total metadata bytes in use. */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 2ccd9cc..f97c8de 100644
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
index 433db42..da3f68b 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -79,6 +79,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtiedBytes:    %10lu kB\n"
 		   "BdiWrittenBytes:    %10lu kB\n"
+		   "BdiMetadataDirty:   %10lu kB\n"
+		   "BdiMetaWriteback:	%10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -93,6 +95,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) BtoK(wb_stat(wb, WB_DIRTIED_BYTES)),
 		   (unsigned long) BtoK(wb_stat(wb, WB_WRITTEN_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_DIRTY_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e09b3ad..48faf1b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -296,6 +296,7 @@ static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 
 	nr_pages += node_page_state(pgdat, NR_INACTIVE_FILE);
 	nr_pages += node_page_state(pgdat, NR_ACTIVE_FILE);
+	nr_pages += node_page_state(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT;
 
 	return nr_pages;
 }
@@ -372,6 +373,7 @@ static unsigned long global_dirtyable_memory(void)
 
 	x += global_node_page_state(NR_INACTIVE_FILE);
 	x += global_node_page_state(NR_ACTIVE_FILE);
+	x += global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
@@ -380,6 +382,30 @@ static unsigned long global_dirtyable_memory(void)
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
@@ -1514,7 +1540,7 @@ static long wb_min_pause(struct bdi_writeback *wb,
 static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 {
 	struct bdi_writeback *wb = dtc->wb;
-	unsigned long wb_reclaimable;
+	unsigned long wb_reclaimable, wb_writeback;
 
 	/*
 	 * wb_thresh is not treated as some limiting factor as
@@ -1544,12 +1570,17 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
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
@@ -1594,10 +1625,9 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
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
 
@@ -1928,20 +1958,22 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
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
 
@@ -1956,7 +1988,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		if (mdtc->dirty > mdtc->bg_thresh)
 			return true;
 
-		if (wb_stat(wb, WB_RECLAIMABLE) >
+		if (wb_reclaimable >
 		    wb_calc_thresh(mdtc->wb, mdtc->bg_thresh))
 			return true;
 	}
@@ -1980,8 +2012,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
                 if (global_node_page_state(NR_UNSTABLE_NFS) +
-			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+		    global_writeback_memory() <= dirty_thresh)
+			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
@@ -2008,8 +2040,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_dirty_memory();
 	struct bdi_writeback *wb;
 
 	/*
@@ -2473,6 +2504,100 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
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
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+			      bytes);
+	__add_wb_stat(&bdi->wb, WB_DIRTIED_BYTES, bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, bytes);
+	current->nr_dirtied++;
+	task_io_account_write(bytes);
+	this_cpu_inc(bdp_ratelimits);
+	local_irq_restore(flags);
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
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+			      -bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, -bytes);
+	task_io_account_cancelled_write(bytes);
+	local_irq_restore(flags);
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
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__add_wb_stat(&bdi->wb, WB_METADATA_DIRTY_BYTES, -bytes);
+	__mod_node_page_state(page_pgdat(page), NR_METADATA_DIRTY_BYTES,
+					 -bytes);
+	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, bytes);
+	__mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
+					 bytes);
+	local_irq_restore(flags);
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
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__add_wb_stat(&bdi->wb, WB_METADATA_WRITEBACK_BYTES, -bytes);
+	__mod_node_page_state(page_pgdat(page), NR_METADATA_WRITEBACK_BYTES,
+					 -bytes);
+	__wb_writeout_inc(&bdi->wb, bytes);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_end_writeback);
+
+/*
  * Helper function for deaccounting dirty page without writeback.
  *
  * Caller must hold lock_page_memcg().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c6..b8c9d93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4113,6 +4113,8 @@ out:
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+#define BtoK(x) ((x) >> 10)
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 
 static void show_migration_types(unsigned char type)
 {
@@ -4167,10 +4169,11 @@ void show_free_areas(unsigned int filter)
 
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
@@ -4178,9 +4181,12 @@ void show_free_areas(unsigned int filter)
 		global_node_page_state(NR_INACTIVE_FILE),
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
+		BtoP(global_node_page_state(NR_METADATA_BYTES)),
 		global_node_page_state(NR_FILE_DIRTY),
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
+		BtoP(global_node_page_state(NR_METADATA_WRITEBACK_BYTES)),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
@@ -4200,9 +4206,12 @@ void show_free_areas(unsigned int filter)
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
@@ -4222,9 +4231,12 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			BtoK(node_page_state(pgdat, NR_METADATA_BYTES)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			BtoK(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
+			BtoK(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
diff --git a/mm/util.c b/mm/util.c
index 662cddf..e8b8b7f 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -548,6 +548,8 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 */
 		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
+		free += global_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;
+
 		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
 		 */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0fe8b71..322d6d4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -218,7 +218,8 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 
 	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
 	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
+	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE) +
+	     (node_page_state_snapshot(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT);
 
 	if (get_nr_swap_pages() > 0)
 		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
@@ -3680,6 +3681,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
 static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 {
 	unsigned long nr_pagecache_reclaimable;
+	unsigned long nr_metadata_reclaimable;
 	unsigned long delta = 0;
 
 	/*
@@ -3701,7 +3703,20 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
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
index 89cec42..b762e39 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -973,6 +973,9 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
+	"nr_metadata_dirty_bytes",
+	"nr_metadata_writeback_bytes",
+	"nr_metadata_bytes",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
