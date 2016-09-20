Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEDB86B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:58:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b71so11225418lfg.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:58:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r64si5835920wmf.68.2016.09.20.13.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:58:11 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 2/4] writeback: allow for dirty metadata accounting
Date: Tue, 20 Sep 2016 16:57:46 -0400
Message-ID: <1474405068-27841-3-git-send-email-jbacik@fb.com>
In-Reply-To: <1474405068-27841-1-git-send-email-jbacik@fb.com>
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

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

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 arch/tile/mm/pgtable.c           |   3 +-
 drivers/base/node.c              |   6 ++
 fs/fs-writeback.c                |   2 +
 fs/proc/meminfo.c                |   5 ++
 include/linux/backing-dev-defs.h |   2 +
 include/linux/mm.h               |   9 +++
 include/linux/mmzone.h           |   2 +
 include/trace/events/writeback.h |  13 +++-
 mm/backing-dev.c                 |   5 ++
 mm/page-writeback.c              | 157 +++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                  |  16 +++-
 mm/vmscan.c                      |   4 +-
 12 files changed, 200 insertions(+), 24 deletions(-)

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
index 5548f96..3615264 100644
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
@@ -99,7 +101,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d MetadataDirty:	%8lu kB\n"
 		       "Node %d Writeback:      %8lu kB\n"
+		       "Node %d MetaWriteback:  %8lu kB\n"
 		       "Node %d FilePages:      %8lu kB\n"
 		       "Node %d Mapped:         %8lu kB\n"
 		       "Node %d AnonPages:      %8lu kB\n"
@@ -119,7 +123,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       nid, BtoK(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
+		       nid, BtoK(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_PAGES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 56c8fda..aafdb11 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1801,6 +1801,7 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
 	return work;
 }
 
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 /*
  * Add in the number of potentially dirty inodes, because each inode
  * write can dirty pagecache in the underlying blockdev.
@@ -1809,6 +1810,7 @@ static unsigned long get_nr_dirty_pages(void)
 {
 	return global_node_page_state(NR_FILE_DIRTY) +
 		global_node_page_state(NR_UNSTABLE_NFS) +
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 09e18fd..95b0d8a 100644
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
@@ -80,7 +81,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"SwapTotal:      %8lu kB\n"
 		"SwapFree:       %8lu kB\n"
 		"Dirty:          %8lu kB\n"
+		"MetadataDirty:  %8lu kB\n"
 		"Writeback:      %8lu kB\n"
+		"MetaWriteback:  %8lu kB\n"
 		"AnonPages:      %8lu kB\n"
 		"Mapped:         %8lu kB\n"
 		"Shmem:          %8lu kB\n"
@@ -139,7 +142,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
index 3f10307..1a7c3c1 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -34,6 +34,8 @@ typedef int (congested_fn)(void *, int);
 enum wb_stat_item {
 	WB_RECLAIMABLE,
 	WB_WRITEBACK,
+	WB_METADATA_DIRTY_BYTES,
+	WB_METADATA_WRITEBACK_BYTES,
 	WB_DIRTIED,
 	WB_WRITTEN,
 	NR_WB_STAT_ITEMS
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53e..6d2e3e8 100644
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
index f2e4e90..5d4c443 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -167,6 +167,8 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_METADATA_DIRTY_BYTES,	/* Metadata dirty bytes */
+	NR_METADATA_WRITEBACK_BYTES,	/* Metadata writeback bytes */
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
index efe2377..d76f432 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -70,6 +70,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
+#define BtoK(x) ((x) >> 10)
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
@@ -78,6 +79,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
+		   "BdiMetadataDirty:   %10lu kB\n"
+		   "BdiMetaWriteback:	%10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -92,6 +95,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
 		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_DIRTY_BYTES)),
+		   (unsigned long) BtoK(wb_stat(wb, WB_METADATA_WRITEBACK_BYTES)),
 		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 121a6e3..423d2f5 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -380,6 +380,30 @@ static unsigned long global_dirtyable_memory(void)
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
@@ -506,6 +530,10 @@ bool node_dirty_ok(struct pglist_data *pgdat)
 	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
 	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
 	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
+	nr_pages += (node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) >>
+		     PAGE_SHIFT);
+	nr_pages += (node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES) >>
+		     PAGE_SHIFT);
 
 	return nr_pages <= limit;
 }
@@ -1514,7 +1542,7 @@ static long wb_min_pause(struct bdi_writeback *wb,
 static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
 {
 	struct bdi_writeback *wb = dtc->wb;
-	unsigned long wb_reclaimable;
+	unsigned long wb_reclaimable, wb_writeback;
 
 	/*
 	 * wb_thresh is not treated as some limiting factor as
@@ -1544,12 +1572,17 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
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
@@ -1594,10 +1627,9 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
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
 
@@ -1928,20 +1960,22 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
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
 
@@ -1956,7 +1990,7 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		if (mdtc->dirty > mdtc->bg_thresh)
 			return true;
 
-		if (wb_stat(wb, WB_RECLAIMABLE) >
+		if (wb_reclaimable >
 		    wb_calc_thresh(mdtc->wb, mdtc->bg_thresh))
 			return true;
 	}
@@ -1980,8 +2014,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
                 if (global_node_page_state(NR_UNSTABLE_NFS) +
-			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+		    global_writeback_memory() <= dirty_thresh)
+			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
@@ -2008,8 +2042,7 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
-		global_node_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_dirty_memory();
 	struct bdi_writeback *wb;
 
 	/*
@@ -2473,6 +2506,98 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
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
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(account_metadata_end_writeback);
+
+/*
  * Helper function for deaccounting dirty page without writeback.
  *
  * Caller must hold lock_page_memcg().
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 39a372a..978ae3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4164,6 +4164,8 @@ out:
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+#define BtoK(x) ((x) >> 10)
+#define BtoP(x) ((x) >> PAGE_SHIFT)
 
 static void show_migration_types(unsigned char type)
 {
@@ -4218,10 +4220,10 @@ void show_free_areas(unsigned int filter)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
-		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" unevictable:%lu dirty:%lu metadata_dirty:%lu writeback:%lu\n"
+	        " unstable:%lu metadata_writeback:%lu slab_reclaimable:%lu\n"
+	        " slab_unreclaimable:%lu mapped:%lu shmem:%lu pagetables:%lu\n"
+	        " bounce:%lu free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
 		global_node_page_state(NR_ISOLATED_ANON),
@@ -4230,8 +4232,10 @@ void show_free_areas(unsigned int filter)
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
 		global_node_page_state(NR_FILE_DIRTY),
+		BtoP(global_node_page_state(NR_METADATA_DIRTY_BYTES)),
 		global_node_page_state(NR_WRITEBACK),
 		global_node_page_state(NR_UNSTABLE_NFS),
+		BtoP(global_node_page_state(NR_METADATA_WRITEBACK_BYTES)),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
@@ -4253,7 +4257,9 @@ void show_free_areas(unsigned int filter)
 			" isolated(file):%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
+			" metadata_dirty:%lukB"
 			" writeback:%lukB"
+			" metadata_writeback:%lukB"
 			" shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			" shmem_thp: %lukB"
@@ -4275,7 +4281,9 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			BtoK(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
+			BtoK(node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 374d95d..c3be15c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3714,7 +3714,9 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 
 	/* If we can't clean pages, remove dirty pages from consideration */
 	if (!(node_reclaim_mode & RECLAIM_WRITE))
-		delta += node_page_state(pgdat, NR_FILE_DIRTY);
+		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
+			(node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) >>
+			 PAGE_SHIFT);
 
 	/* Watch for any possible underflows due to delta */
 	if (unlikely(delta > nr_pagecache_reclaimable))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
