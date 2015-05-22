Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 51922829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:43 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so22236627qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:43 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id jz8si3710930qcb.35.2015.05.22.14.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:41 -0700 (PDT)
Received: by qkx62 with SMTP id 62so22137791qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:41 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 14/51] writeback: move bandwidth related fields from backing_dev_info into bdi_writeback
Date: Fri, 22 May 2015 17:13:28 -0400
Message-Id: <1432329245-5844-15-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Steven Whitehouse <swhiteho@redhat.com>

Currently, a bdi (backing_dev_info) embeds single wb (bdi_writeback)
and the role of the separation is unclear.  For cgroup support for
writeback IOs, a bdi will be updated to host multiple wb's where each
wb serves writeback IOs of a different cgroup on the bdi.  To achieve
that, a wb should carry all states necessary for servicing writeback
IOs for a cgroup independently.

This patch moves bandwidth related fields from backing_dev_info into
bdi_writeback.

* The moved fields are: bw_time_stamp, dirtied_stamp, written_stamp,
  write_bandwidth, avg_write_bandwidth, dirty_ratelimit,
  balanced_dirty_ratelimit, completions and dirty_exceeded.

* writeback_chunk_size() and over_bground_thresh() now take @wb
  instead of @bdi.

* bdi_writeout_fraction(bdi, ...)	-> wb_writeout_fraction(wb, ...)
  bdi_dirty_limit(bdi, ...)		-> wb_dirty_limit(wb, ...)
  bdi_position_ration(bdi, ...)		-> wb_position_ratio(wb, ...)
  bdi_update_writebandwidth(bdi, ...)	-> wb_update_write_bandwidth(wb, ...)
  [__]bdi_update_bandwidth(bdi, ...)	-> [__]wb_update_bandwidth(wb, ...)
  bdi_{max|min}_pause(bdi, ...)		-> wb_{max|min}_pause(wb, ...)
  bdi_dirty_limits(bdi, ...)		-> wb_dirty_limits(wb, ...)

* Init/exits of the relocated fields are moved to bdi_wb_init/exit()
  respectively.  Note that explicit zeroing is dropped in the process
  as wb's are cleared in entirety anyway.

* As there's still only one bdi_writeback per backing_dev_info, all
  uses of bdi->stat[] are mechanically replaced with bdi->wb.stat[]
  introducing no behavior changes.

v2: Typo in description fixed as suggested by Jan.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>
---
 fs/f2fs/node.c                   |   4 +-
 fs/f2fs/segment.h                |   2 +-
 fs/fs-writeback.c                |  17 ++-
 fs/gfs2/super.c                  |   2 +-
 include/linux/backing-dev.h      |  20 +--
 include/linux/writeback.h        |  19 ++-
 include/trace/events/writeback.h |   8 +-
 mm/backing-dev.c                 |  45 +++----
 mm/page-writeback.c              | 262 ++++++++++++++++++++-------------------
 9 files changed, 187 insertions(+), 192 deletions(-)

diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 8ab0cf1..d211602 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -53,7 +53,7 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 							PAGE_CACHE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 2);
 	} else if (type == DIRTY_DENTS) {
-		if (sbi->sb->s_bdi->dirty_exceeded)
+		if (sbi->sb->s_bdi->wb.dirty_exceeded)
 			return false;
 		mem_size = get_pages(sbi, F2FS_DIRTY_DENTS);
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
@@ -70,7 +70,7 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 				sizeof(struct extent_node)) >> PAGE_CACHE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
 	} else {
-		if (sbi->sb->s_bdi->dirty_exceeded)
+		if (sbi->sb->s_bdi->wb.dirty_exceeded)
 			return false;
 	}
 	return res;
diff --git a/fs/f2fs/segment.h b/fs/f2fs/segment.h
index 85d7fa7..6408989 100644
--- a/fs/f2fs/segment.h
+++ b/fs/f2fs/segment.h
@@ -713,7 +713,7 @@ static inline unsigned int max_hw_blocks(struct f2fs_sb_info *sbi)
  */
 static inline int nr_pages_to_skip(struct f2fs_sb_info *sbi, int type)
 {
-	if (sbi->sb->s_bdi->dirty_exceeded)
+	if (sbi->sb->s_bdi->wb.dirty_exceeded)
 		return 0;
 
 	if (type == DATA)
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 8873ecd..1945cb9 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -624,7 +624,7 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	return ret;
 }
 
-static long writeback_chunk_size(struct backing_dev_info *bdi,
+static long writeback_chunk_size(struct bdi_writeback *wb,
 				 struct wb_writeback_work *work)
 {
 	long pages;
@@ -645,7 +645,7 @@ static long writeback_chunk_size(struct backing_dev_info *bdi,
 	if (work->sync_mode == WB_SYNC_ALL || work->tagged_writepages)
 		pages = LONG_MAX;
 	else {
-		pages = min(bdi->avg_write_bandwidth / 2,
+		pages = min(wb->avg_write_bandwidth / 2,
 			    global_dirty_limit / DIRTY_SCOPE);
 		pages = min(pages, work->nr_pages);
 		pages = round_down(pages + MIN_WRITEBACK_PAGES,
@@ -743,7 +743,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 		inode->i_state |= I_SYNC;
 		spin_unlock(&inode->i_lock);
 
-		write_chunk = writeback_chunk_size(wb->bdi, work);
+		write_chunk = writeback_chunk_size(wb, work);
 		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
@@ -830,7 +830,7 @@ static long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 	return nr_pages - work.nr_pages;
 }
 
-static bool over_bground_thresh(struct backing_dev_info *bdi)
+static bool over_bground_thresh(struct bdi_writeback *wb)
 {
 	unsigned long background_thresh, dirty_thresh;
 
@@ -840,8 +840,7 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
 	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
 		return true;
 
-	if (wb_stat(&bdi->wb, WB_RECLAIMABLE) >
-				bdi_dirty_limit(bdi, background_thresh))
+	if (wb_stat(wb, WB_RECLAIMABLE) > wb_dirty_limit(wb, background_thresh))
 		return true;
 
 	return false;
@@ -854,7 +853,7 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
 static void wb_update_bandwidth(struct bdi_writeback *wb,
 				unsigned long start_time)
 {
-	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
+	__wb_update_bandwidth(wb, 0, 0, 0, 0, 0, start_time);
 }
 
 /*
@@ -906,7 +905,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh(wb->bdi))
+		if (work->for_background && !over_bground_thresh(wb))
 			break;
 
 		/*
@@ -998,7 +997,7 @@ static unsigned long get_nr_dirty_pages(void)
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh(wb->bdi)) {
+	if (over_bground_thresh(wb)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 859c6ed..2982445 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -748,7 +748,7 @@ static int gfs2_write_inode(struct inode *inode, struct writeback_control *wbc)
 
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		gfs2_log_flush(GFS2_SB(inode), ip->i_gl, NORMAL_FLUSH);
-	if (bdi->dirty_exceeded)
+	if (bdi->wb.dirty_exceeded)
 		gfs2_ail1_flush(sdp, wbc);
 	else
 		filemap_fdatawrite(metamapping);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index fe7a907..2ab0604 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -60,16 +60,6 @@ struct bdi_writeback {
 	spinlock_t list_lock;		/* protects the b_* lists */
 
 	struct percpu_counter stat[NR_WB_STAT_ITEMS];
-};
-
-struct backing_dev_info {
-	struct list_head bdi_list;
-	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
-	unsigned int capabilities; /* Device capabilities */
-	congested_fn *congested_fn; /* Function pointer if device is md/dm */
-	void *congested_data;	/* Pointer to aux data for congested func */
-
-	char *name;
 
 	unsigned long bw_time_stamp;	/* last time write bw is updated */
 	unsigned long dirtied_stamp;
@@ -88,6 +78,16 @@ struct backing_dev_info {
 
 	struct fprop_local_percpu completions;
 	int dirty_exceeded;
+};
+
+struct backing_dev_info {
+	struct list_head bdi_list;
+	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
+	unsigned int capabilities; /* Device capabilities */
+	congested_fn *congested_fn; /* Function pointer if device is md/dm */
+	void *congested_data;	/* Pointer to aux data for congested func */
+
+	char *name;
 
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index b2dd371e..a6b9db7 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -155,16 +155,15 @@ int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
-			       unsigned long dirty);
-
-void __bdi_update_bandwidth(struct backing_dev_info *bdi,
-			    unsigned long thresh,
-			    unsigned long bg_thresh,
-			    unsigned long dirty,
-			    unsigned long bdi_thresh,
-			    unsigned long bdi_dirty,
-			    unsigned long start_time);
+unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty);
+
+void __wb_update_bandwidth(struct bdi_writeback *wb,
+			   unsigned long thresh,
+			   unsigned long bg_thresh,
+			   unsigned long dirty,
+			   unsigned long bdi_thresh,
+			   unsigned long bdi_dirty,
+			   unsigned long start_time);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 880dd74..9b876f6 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -400,13 +400,13 @@ TRACE_EVENT(bdi_dirty_ratelimit,
 
 	TP_fast_assign(
 		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
-		__entry->write_bw	= KBps(bdi->write_bandwidth);
-		__entry->avg_write_bw	= KBps(bdi->avg_write_bandwidth);
+		__entry->write_bw	= KBps(bdi->wb.write_bandwidth);
+		__entry->avg_write_bw	= KBps(bdi->wb.avg_write_bandwidth);
 		__entry->dirty_rate	= KBps(dirty_rate);
-		__entry->dirty_ratelimit = KBps(bdi->dirty_ratelimit);
+		__entry->dirty_ratelimit = KBps(bdi->wb.dirty_ratelimit);
 		__entry->task_ratelimit	= KBps(task_ratelimit);
 		__entry->balanced_dirty_ratelimit =
-					  KBps(bdi->balanced_dirty_ratelimit);
+					KBps(bdi->wb.balanced_dirty_ratelimit);
 	),
 
 	TP_printk("bdi %s: "
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7b1d191..9a6c472 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -66,7 +66,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	spin_unlock(&wb->list_lock);
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	bdi_thresh = wb_dirty_limit(wb, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
@@ -91,7 +91,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
 		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
-		   (unsigned long) K(bdi->write_bandwidth),
+		   (unsigned long) K(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
 		   nr_more_io,
@@ -376,6 +376,11 @@ void bdi_unregister(struct backing_dev_info *bdi)
 }
 EXPORT_SYMBOL(bdi_unregister);
 
+/*
+ * Initial write bandwidth: 100 MB/s
+ */
+#define INIT_BW		(100 << (20 - PAGE_SHIFT))
+
 static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 {
 	int i, err;
@@ -391,11 +396,22 @@ static int bdi_wb_init(struct bdi_writeback *wb, struct backing_dev_info *bdi)
 	spin_lock_init(&wb->list_lock);
 	INIT_DELAYED_WORK(&wb->dwork, bdi_writeback_workfn);
 
+	wb->bw_time_stamp = jiffies;
+	wb->balanced_dirty_ratelimit = INIT_BW;
+	wb->dirty_ratelimit = INIT_BW;
+	wb->write_bandwidth = INIT_BW;
+	wb->avg_write_bandwidth = INIT_BW;
+
+	err = fprop_local_init_percpu(&wb->completions, GFP_KERNEL);
+	if (err)
+		return err;
+
 	for (i = 0; i < NR_WB_STAT_ITEMS; i++) {
 		err = percpu_counter_init(&wb->stat[i], 0, GFP_KERNEL);
 		if (err) {
 			while (--i)
 				percpu_counter_destroy(&wb->stat[i]);
+			fprop_local_destroy_percpu(&wb->completions);
 			return err;
 		}
 	}
@@ -411,12 +427,9 @@ static void bdi_wb_exit(struct bdi_writeback *wb)
 
 	for (i = 0; i < NR_WB_STAT_ITEMS; i++)
 		percpu_counter_destroy(&wb->stat[i]);
-}
 
-/*
- * Initial write bandwidth: 100 MB/s
- */
-#define INIT_BW		(100 << (20 - PAGE_SHIFT))
+	fprop_local_destroy_percpu(&wb->completions);
+}
 
 int bdi_init(struct backing_dev_info *bdi)
 {
@@ -435,22 +448,6 @@ int bdi_init(struct backing_dev_info *bdi)
 	if (err)
 		return err;
 
-	bdi->dirty_exceeded = 0;
-
-	bdi->bw_time_stamp = jiffies;
-	bdi->written_stamp = 0;
-
-	bdi->balanced_dirty_ratelimit = INIT_BW;
-	bdi->dirty_ratelimit = INIT_BW;
-	bdi->write_bandwidth = INIT_BW;
-	bdi->avg_write_bandwidth = INIT_BW;
-
-	err = fprop_local_init_percpu(&bdi->completions, GFP_KERNEL);
-	if (err) {
-		bdi_wb_exit(&bdi->wb);
-		return err;
-	}
-
 	return 0;
 }
 EXPORT_SYMBOL(bdi_init);
@@ -468,8 +465,6 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	}
 
 	bdi_wb_exit(&bdi->wb);
-
-	fprop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index dc673a0..cd39ee9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -399,7 +399,7 @@ static unsigned long wp_next_time(unsigned long cur_time)
 static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 {
 	__inc_wb_stat(wb, WB_WRITTEN);
-	__fprop_inc_percpu_max(&writeout_completions, &wb->bdi->completions,
+	__fprop_inc_percpu_max(&writeout_completions, &wb->completions,
 			       wb->bdi->max_prop_frac);
 	/* First event after period switching was turned off? */
 	if (!unlikely(writeout_period_time)) {
@@ -427,10 +427,10 @@ EXPORT_SYMBOL_GPL(wb_writeout_inc);
 /*
  * Obtain an accurate fraction of the BDI's portion.
  */
-static void bdi_writeout_fraction(struct backing_dev_info *bdi,
-		long *numerator, long *denominator)
+static void wb_writeout_fraction(struct bdi_writeback *wb,
+				 long *numerator, long *denominator)
 {
-	fprop_fraction_percpu(&writeout_completions, &bdi->completions,
+	fprop_fraction_percpu(&writeout_completions, &wb->completions,
 				numerator, denominator);
 }
 
@@ -516,11 +516,11 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
 }
 
 /**
- * bdi_dirty_limit - @bdi's share of dirty throttling threshold
- * @bdi: the backing_dev_info to query
+ * wb_dirty_limit - @wb's share of dirty throttling threshold
+ * @wb: bdi_writeback to query
  * @dirty: global dirty limit in pages
  *
- * Returns @bdi's dirty limit in pages. The term "dirty" in the context of
+ * Returns @wb's dirty limit in pages. The term "dirty" in the context of
  * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
  *
  * Note that balance_dirty_pages() will only seriously take it as a hard limit
@@ -528,34 +528,35 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  * control. For example, when the device is completely stalled due to some error
  * conditions, or when there are 1000 dd tasks writing to a slow 10MB/s USB key.
  * In the other normal situations, it acts more gently by throttling the tasks
- * more (rather than completely block them) when the bdi dirty pages go high.
+ * more (rather than completely block them) when the wb dirty pages go high.
  *
  * It allocates high/low dirty limits to fast/slow devices, in order to prevent
  * - starving fast devices
  * - piling up dirty pages (that will take long time to sync) on slow devices
  *
- * The bdi's share of dirty limit will be adapting to its throughput and
+ * The wb's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
  */
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
+unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
 {
-	u64 bdi_dirty;
+	struct backing_dev_info *bdi = wb->bdi;
+	u64 wb_dirty;
 	long numerator, denominator;
 
 	/*
 	 * Calculate this BDI's share of the dirty ratio.
 	 */
-	bdi_writeout_fraction(bdi, &numerator, &denominator);
+	wb_writeout_fraction(wb, &numerator, &denominator);
 
-	bdi_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
-	bdi_dirty *= numerator;
-	do_div(bdi_dirty, denominator);
+	wb_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
+	wb_dirty *= numerator;
+	do_div(wb_dirty, denominator);
 
-	bdi_dirty += (dirty * bdi->min_ratio) / 100;
-	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
-		bdi_dirty = dirty * bdi->max_ratio / 100;
+	wb_dirty += (dirty * bdi->min_ratio) / 100;
+	if (wb_dirty > (dirty * bdi->max_ratio) / 100)
+		wb_dirty = dirty * bdi->max_ratio / 100;
 
-	return bdi_dirty;
+	return wb_dirty;
 }
 
 /*
@@ -664,14 +665,14 @@ static long long pos_ratio_polynom(unsigned long setpoint,
  *   card's bdi_dirty may rush to many times higher than bdi_setpoint.
  * - the bdi dirty thresh drops quickly due to change of JBOD workload
  */
-static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
-					unsigned long thresh,
-					unsigned long bg_thresh,
-					unsigned long dirty,
-					unsigned long bdi_thresh,
-					unsigned long bdi_dirty)
+static unsigned long wb_position_ratio(struct bdi_writeback *wb,
+				       unsigned long thresh,
+				       unsigned long bg_thresh,
+				       unsigned long dirty,
+				       unsigned long bdi_thresh,
+				       unsigned long bdi_dirty)
 {
-	unsigned long write_bw = bdi->avg_write_bandwidth;
+	unsigned long write_bw = wb->avg_write_bandwidth;
 	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
 	unsigned long limit = hard_dirty_limit(thresh);
 	unsigned long x_intercept;
@@ -702,12 +703,12 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	 * consume arbitrary amount of RAM because it is accounted in
 	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
 	 *
-	 * Here, in bdi_position_ratio(), we calculate pos_ratio based on
+	 * Here, in wb_position_ratio(), we calculate pos_ratio based on
 	 * two values: bdi_dirty and bdi_thresh. Let's consider an example:
 	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
 	 * limits are set by default to 10% and 20% (background and throttle).
 	 * Then bdi_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
-	 * bdi_dirty_limit(bdi, bg_thresh) is about ~4K pages. bdi_setpoint is
+	 * wb_dirty_limit(wb, bg_thresh) is about ~4K pages. bdi_setpoint is
 	 * about ~6K pages (as the average of background and throttle bdi
 	 * limits). The 3rd order polynomial will provide positive feedback if
 	 * bdi_dirty is under bdi_setpoint and vice versa.
@@ -717,7 +718,7 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	 * much earlier than global "freerun" is reached (~23MB vs. ~2.3GB
 	 * in the example above).
 	 */
-	if (unlikely(bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
+	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		long long bdi_pos_ratio;
 		unsigned long bdi_bg_thresh;
 
@@ -842,13 +843,13 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	return pos_ratio;
 }
 
-static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
-				       unsigned long elapsed,
-				       unsigned long written)
+static void wb_update_write_bandwidth(struct bdi_writeback *wb,
+				      unsigned long elapsed,
+				      unsigned long written)
 {
 	const unsigned long period = roundup_pow_of_two(3 * HZ);
-	unsigned long avg = bdi->avg_write_bandwidth;
-	unsigned long old = bdi->write_bandwidth;
+	unsigned long avg = wb->avg_write_bandwidth;
+	unsigned long old = wb->write_bandwidth;
 	u64 bw;
 
 	/*
@@ -861,14 +862,14 @@ static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 	 * @written may have decreased due to account_page_redirty().
 	 * Avoid underflowing @bw calculation.
 	 */
-	bw = written - min(written, bdi->written_stamp);
+	bw = written - min(written, wb->written_stamp);
 	bw *= HZ;
 	if (unlikely(elapsed > period)) {
 		do_div(bw, elapsed);
 		avg = bw;
 		goto out;
 	}
-	bw += (u64)bdi->write_bandwidth * (period - elapsed);
+	bw += (u64)wb->write_bandwidth * (period - elapsed);
 	bw >>= ilog2(period);
 
 	/*
@@ -881,8 +882,8 @@ static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 		avg += (old - avg) >> 3;
 
 out:
-	bdi->write_bandwidth = bw;
-	bdi->avg_write_bandwidth = avg;
+	wb->write_bandwidth = bw;
+	wb->avg_write_bandwidth = avg;
 }
 
 /*
@@ -947,20 +948,20 @@ static void global_update_bandwidth(unsigned long thresh,
  * Normal bdi tasks will be curbed at or below it in long term.
  * Obviously it should be around (write_bw / N) when there are N dd tasks.
  */
-static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
-				       unsigned long thresh,
-				       unsigned long bg_thresh,
-				       unsigned long dirty,
-				       unsigned long bdi_thresh,
-				       unsigned long bdi_dirty,
-				       unsigned long dirtied,
-				       unsigned long elapsed)
+static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
+				      unsigned long thresh,
+				      unsigned long bg_thresh,
+				      unsigned long dirty,
+				      unsigned long bdi_thresh,
+				      unsigned long bdi_dirty,
+				      unsigned long dirtied,
+				      unsigned long elapsed)
 {
 	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
 	unsigned long limit = hard_dirty_limit(thresh);
 	unsigned long setpoint = (freerun + limit) / 2;
-	unsigned long write_bw = bdi->avg_write_bandwidth;
-	unsigned long dirty_ratelimit = bdi->dirty_ratelimit;
+	unsigned long write_bw = wb->avg_write_bandwidth;
+	unsigned long dirty_ratelimit = wb->dirty_ratelimit;
 	unsigned long dirty_rate;
 	unsigned long task_ratelimit;
 	unsigned long balanced_dirty_ratelimit;
@@ -972,10 +973,10 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * The dirty rate will match the writeout rate in long term, except
 	 * when dirty pages are truncated by userspace or re-dirtied by FS.
 	 */
-	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+	dirty_rate = (dirtied - wb->dirtied_stamp) * HZ / elapsed;
 
-	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
-				       bdi_thresh, bdi_dirty);
+	pos_ratio = wb_position_ratio(wb, thresh, bg_thresh, dirty,
+				      bdi_thresh, bdi_dirty);
 	/*
 	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
 	 */
@@ -1059,31 +1060,31 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 
 	/*
 	 * For strictlimit case, calculations above were based on bdi counters
-	 * and limits (starting from pos_ratio = bdi_position_ratio() and up to
+	 * and limits (starting from pos_ratio = wb_position_ratio() and up to
 	 * balanced_dirty_ratelimit = task_ratelimit * write_bw / dirty_rate).
 	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
 	 * "dirty" and bdi_setpoint as "setpoint".
 	 *
 	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
 	 * it's possible that bdi_thresh is close to zero due to inactivity
-	 * of backing device (see the implementation of bdi_dirty_limit()).
+	 * of backing device (see the implementation of wb_dirty_limit()).
 	 */
-	if (unlikely(bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
+	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
 		dirty = bdi_dirty;
 		if (bdi_dirty < 8)
 			setpoint = bdi_dirty + 1;
 		else
 			setpoint = (bdi_thresh +
-				    bdi_dirty_limit(bdi, bg_thresh)) / 2;
+				    wb_dirty_limit(wb, bg_thresh)) / 2;
 	}
 
 	if (dirty < setpoint) {
-		x = min3(bdi->balanced_dirty_ratelimit,
+		x = min3(wb->balanced_dirty_ratelimit,
 			 balanced_dirty_ratelimit, task_ratelimit);
 		if (dirty_ratelimit < x)
 			step = x - dirty_ratelimit;
 	} else {
-		x = max3(bdi->balanced_dirty_ratelimit,
+		x = max3(wb->balanced_dirty_ratelimit,
 			 balanced_dirty_ratelimit, task_ratelimit);
 		if (dirty_ratelimit > x)
 			step = dirty_ratelimit - x;
@@ -1105,22 +1106,22 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	else
 		dirty_ratelimit -= step;
 
-	bdi->dirty_ratelimit = max(dirty_ratelimit, 1UL);
-	bdi->balanced_dirty_ratelimit = balanced_dirty_ratelimit;
+	wb->dirty_ratelimit = max(dirty_ratelimit, 1UL);
+	wb->balanced_dirty_ratelimit = balanced_dirty_ratelimit;
 
-	trace_bdi_dirty_ratelimit(bdi, dirty_rate, task_ratelimit);
+	trace_bdi_dirty_ratelimit(wb->bdi, dirty_rate, task_ratelimit);
 }
 
-void __bdi_update_bandwidth(struct backing_dev_info *bdi,
-			    unsigned long thresh,
-			    unsigned long bg_thresh,
-			    unsigned long dirty,
-			    unsigned long bdi_thresh,
-			    unsigned long bdi_dirty,
-			    unsigned long start_time)
+void __wb_update_bandwidth(struct bdi_writeback *wb,
+			   unsigned long thresh,
+			   unsigned long bg_thresh,
+			   unsigned long dirty,
+			   unsigned long bdi_thresh,
+			   unsigned long bdi_dirty,
+			   unsigned long start_time)
 {
 	unsigned long now = jiffies;
-	unsigned long elapsed = now - bdi->bw_time_stamp;
+	unsigned long elapsed = now - wb->bw_time_stamp;
 	unsigned long dirtied;
 	unsigned long written;
 
@@ -1130,44 +1131,44 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
-	dirtied = percpu_counter_read(&bdi->wb.stat[WB_DIRTIED]);
-	written = percpu_counter_read(&bdi->wb.stat[WB_WRITTEN]);
+	dirtied = percpu_counter_read(&wb->stat[WB_DIRTIED]);
+	written = percpu_counter_read(&wb->stat[WB_WRITTEN]);
 
 	/*
 	 * Skip quiet periods when disk bandwidth is under-utilized.
 	 * (at least 1s idle time between two flusher runs)
 	 */
-	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
+	if (elapsed > HZ && time_before(wb->bw_time_stamp, start_time))
 		goto snapshot;
 
 	if (thresh) {
 		global_update_bandwidth(thresh, dirty, now);
-		bdi_update_dirty_ratelimit(bdi, thresh, bg_thresh, dirty,
-					   bdi_thresh, bdi_dirty,
-					   dirtied, elapsed);
+		wb_update_dirty_ratelimit(wb, thresh, bg_thresh, dirty,
+					  bdi_thresh, bdi_dirty,
+					  dirtied, elapsed);
 	}
-	bdi_update_write_bandwidth(bdi, elapsed, written);
+	wb_update_write_bandwidth(wb, elapsed, written);
 
 snapshot:
-	bdi->dirtied_stamp = dirtied;
-	bdi->written_stamp = written;
-	bdi->bw_time_stamp = now;
+	wb->dirtied_stamp = dirtied;
+	wb->written_stamp = written;
+	wb->bw_time_stamp = now;
 }
 
-static void bdi_update_bandwidth(struct backing_dev_info *bdi,
-				 unsigned long thresh,
-				 unsigned long bg_thresh,
-				 unsigned long dirty,
-				 unsigned long bdi_thresh,
-				 unsigned long bdi_dirty,
-				 unsigned long start_time)
+static void wb_update_bandwidth(struct bdi_writeback *wb,
+				unsigned long thresh,
+				unsigned long bg_thresh,
+				unsigned long dirty,
+				unsigned long bdi_thresh,
+				unsigned long bdi_dirty,
+				unsigned long start_time)
 {
-	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
+	if (time_is_after_eq_jiffies(wb->bw_time_stamp + BANDWIDTH_INTERVAL))
 		return;
-	spin_lock(&bdi->wb.list_lock);
-	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
-			       bdi_thresh, bdi_dirty, start_time);
-	spin_unlock(&bdi->wb.list_lock);
+	spin_lock(&wb->list_lock);
+	__wb_update_bandwidth(wb, thresh, bg_thresh, dirty,
+			      bdi_thresh, bdi_dirty, start_time);
+	spin_unlock(&wb->list_lock);
 }
 
 /*
@@ -1187,10 +1188,10 @@ static unsigned long dirty_poll_interval(unsigned long dirty,
 	return 1;
 }
 
-static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
-				   unsigned long bdi_dirty)
+static unsigned long wb_max_pause(struct bdi_writeback *wb,
+				      unsigned long bdi_dirty)
 {
-	unsigned long bw = bdi->avg_write_bandwidth;
+	unsigned long bw = wb->avg_write_bandwidth;
 	unsigned long t;
 
 	/*
@@ -1206,14 +1207,14 @@ static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
 	return min_t(unsigned long, t, MAX_PAUSE);
 }
 
-static long bdi_min_pause(struct backing_dev_info *bdi,
-			  long max_pause,
-			  unsigned long task_ratelimit,
-			  unsigned long dirty_ratelimit,
-			  int *nr_dirtied_pause)
+static long wb_min_pause(struct bdi_writeback *wb,
+			 long max_pause,
+			 unsigned long task_ratelimit,
+			 unsigned long dirty_ratelimit,
+			 int *nr_dirtied_pause)
 {
-	long hi = ilog2(bdi->avg_write_bandwidth);
-	long lo = ilog2(bdi->dirty_ratelimit);
+	long hi = ilog2(wb->avg_write_bandwidth);
+	long lo = ilog2(wb->dirty_ratelimit);
 	long t;		/* target pause */
 	long pause;	/* estimated next pause */
 	int pages;	/* target nr_dirtied_pause */
@@ -1281,14 +1282,13 @@ static long bdi_min_pause(struct backing_dev_info *bdi,
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
-static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
-				    unsigned long dirty_thresh,
-				    unsigned long background_thresh,
-				    unsigned long *bdi_dirty,
-				    unsigned long *bdi_thresh,
-				    unsigned long *bdi_bg_thresh)
+static inline void wb_dirty_limits(struct bdi_writeback *wb,
+				   unsigned long dirty_thresh,
+				   unsigned long background_thresh,
+				   unsigned long *bdi_dirty,
+				   unsigned long *bdi_thresh,
+				   unsigned long *bdi_bg_thresh)
 {
-	struct bdi_writeback *wb = &bdi->wb;
 	unsigned long wb_reclaimable;
 
 	/*
@@ -1301,10 +1301,10 @@ static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
 	 *   In this case we don't want to hard throttle the USB key
 	 *   dirtiers for 100 seconds until bdi_dirty drops under
 	 *   bdi_thresh. Instead the auxiliary bdi control line in
-	 *   bdi_position_ratio() will let the dirtier task progress
+	 *   wb_position_ratio() will let the dirtier task progress
 	 *   at some rate <= (write_bw / 2) for bringing down bdi_dirty.
 	 */
-	*bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	*bdi_thresh = wb_dirty_limit(wb, dirty_thresh);
 
 	if (bdi_bg_thresh)
 		*bdi_bg_thresh = dirty_thresh ? div_u64((u64)*bdi_thresh *
@@ -1354,6 +1354,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+	struct bdi_writeback *wb = &bdi->wb;
 	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
 
@@ -1378,8 +1379,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
 		if (unlikely(strictlimit)) {
-			bdi_dirty_limits(bdi, dirty_thresh, background_thresh,
-					 &bdi_dirty, &bdi_thresh, &bg_thresh);
+			wb_dirty_limits(wb, dirty_thresh, background_thresh,
+					&bdi_dirty, &bdi_thresh, &bg_thresh);
 
 			dirty = bdi_dirty;
 			thresh = bdi_thresh;
@@ -1410,28 +1411,28 @@ static void balance_dirty_pages(struct address_space *mapping,
 			bdi_start_background_writeback(bdi);
 
 		if (!strictlimit)
-			bdi_dirty_limits(bdi, dirty_thresh, background_thresh,
-					 &bdi_dirty, &bdi_thresh, NULL);
+			wb_dirty_limits(wb, dirty_thresh, background_thresh,
+					&bdi_dirty, &bdi_thresh, NULL);
 
 		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
 				 ((nr_dirty > dirty_thresh) || strictlimit);
-		if (dirty_exceeded && !bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
+		if (dirty_exceeded && !wb->dirty_exceeded)
+			wb->dirty_exceeded = 1;
 
-		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
-				     nr_dirty, bdi_thresh, bdi_dirty,
-				     start_time);
+		wb_update_bandwidth(wb, dirty_thresh, background_thresh,
+				    nr_dirty, bdi_thresh, bdi_dirty,
+				    start_time);
 
-		dirty_ratelimit = bdi->dirty_ratelimit;
-		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
-					       background_thresh, nr_dirty,
-					       bdi_thresh, bdi_dirty);
+		dirty_ratelimit = wb->dirty_ratelimit;
+		pos_ratio = wb_position_ratio(wb, dirty_thresh,
+					      background_thresh, nr_dirty,
+					      bdi_thresh, bdi_dirty);
 		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
-		max_pause = bdi_max_pause(bdi, bdi_dirty);
-		min_pause = bdi_min_pause(bdi, max_pause,
-					  task_ratelimit, dirty_ratelimit,
-					  &nr_dirtied_pause);
+		max_pause = wb_max_pause(wb, bdi_dirty);
+		min_pause = wb_min_pause(wb, max_pause,
+					 task_ratelimit, dirty_ratelimit,
+					 &nr_dirtied_pause);
 
 		if (unlikely(task_ratelimit == 0)) {
 			period = max_pause;
@@ -1515,15 +1516,15 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * more page. However bdi_dirty has accounting errors.  So use
 		 * the larger and more IO friendly wb_stat_error.
 		 */
-		if (bdi_dirty <= wb_stat_error(&bdi->wb))
+		if (bdi_dirty <= wb_stat_error(wb))
 			break;
 
 		if (fatal_signal_pending(current))
 			break;
 	}
 
-	if (!dirty_exceeded && bdi->dirty_exceeded)
-		bdi->dirty_exceeded = 0;
+	if (!dirty_exceeded && wb->dirty_exceeded)
+		wb->dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
 		return;
@@ -1577,6 +1578,7 @@ DEFINE_PER_CPU(int, dirty_throttle_leaks) = 0;
 void balance_dirty_pages_ratelimited(struct address_space *mapping)
 {
 	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+	struct bdi_writeback *wb = &bdi->wb;
 	int ratelimit;
 	int *p;
 
@@ -1584,7 +1586,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 		return;
 
 	ratelimit = current->nr_dirtied_pause;
-	if (bdi->dirty_exceeded)
+	if (wb->dirty_exceeded)
 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
 
 	preempt_disable();
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
