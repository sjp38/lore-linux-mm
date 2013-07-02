Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id B5B3D6B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 13:45:20 -0400 (EDT)
Subject: [PATCH] mm: strictlimit feature -v2
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Tue, 02 Jul 2013 21:44:47 +0400
Message-ID: <20130702174316.15075.84993.stgit@maximpc.sw.ru>
In-Reply-To: <20130629174706.20175.78184.stgit@maximpc.sw.ru>
References: <20130629174706.20175.78184.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Miklos Szeredi <mszeredi@suse.cz>

The feature prevents mistrusted filesystems to grow a large number of dirty
pages before throttling. For such filesystems balance_dirty_pages always
check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
"freerun", it's not allowed to skip bdi checks. The only use case for now is
fuse: it sets bdi max_ratio to 1% by default and system administrators are
supposed to expect that this limit won't be exceeded.

The feature is on if address space is marked by AS_STRICTLIMIT flag.
A filesystem may set the flag when it initializes a new inode.

Changed in v2 (thanks to Andrew Morton):
 - added a few explanatory comments
 - cleaned up the mess in backing_dev_info foo_stamp fields: now it's clearly
   stated that bw_time_stamp is measured in jiffies; renamed other foo_stamp
   fields to reflect that they are in units of number-of-pages.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fs-writeback.c           |    2 
 fs/fuse/file.c              |    3 +
 fs/fuse/inode.c             |    1 
 include/linux/backing-dev.h |   22 ++++-
 include/linux/pagemap.h     |    1 
 include/linux/writeback.h   |    3 -
 mm/backing-dev.c            |    5 +
 mm/page-writeback.c         |  176 +++++++++++++++++++++++++++++++++++--------
 8 files changed, 171 insertions(+), 42 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 3be5718..8c75277 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -762,7 +762,7 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
 static void wb_update_bandwidth(struct bdi_writeback *wb,
 				unsigned long start_time)
 {
-	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
+	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time, false);
 }
 
 /*
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 6d30db1..99b5c97 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1697,6 +1697,7 @@ static int fuse_writepage_locked(struct page *page,
 	req->inode = inode;
 
 	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
+	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITTEN_BACK);
 	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
 	end_page_writeback(page);
 
@@ -1766,6 +1767,7 @@ static int fuse_send_writepages(struct fuse_fill_wb_data *data)
 		if (tmp_page) {
 			copy_highpage(tmp_page, page);
 			inc_bdi_stat(bdi, BDI_WRITEBACK);
+			inc_bdi_stat(bdi, BDI_WRITTEN_BACK);
 			inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
 		} else
 			all_ok = 0;
@@ -1781,6 +1783,7 @@ static int fuse_send_writepages(struct fuse_fill_wb_data *data)
 			struct page *page = req->pages[i];
 			if (page) {
 				dec_bdi_stat(bdi, BDI_WRITEBACK);
+				dec_bdi_stat(bdi, BDI_WRITTEN_BACK);
 				dec_zone_page_state(page, NR_WRITEBACK_TEMP);
 				__free_page(page);
 				req->pages[i] = NULL;
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 4beb8e3..00a28af 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -305,6 +305,7 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
 			inode->i_flags |= S_NOCMTIME;
 		inode->i_generation = generation;
 		inode->i_data.backing_dev_info = &fc->bdi;
+		set_bit(AS_STRICTLIMIT, &inode->i_data.flags);
 		fuse_init_inode(inode, attr);
 		unlock_new_inode(inode);
 	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c388155..6b12d01 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -33,6 +33,8 @@ enum bdi_state {
 	BDI_sync_congested,	/* The sync queue is getting full */
 	BDI_registered,		/* bdi_register() was done */
 	BDI_writeback_running,	/* Writeback is in progress */
+	BDI_idle,		/* No pages under writeback at the moment of
+				 * last update of write bw */
 	BDI_unused,		/* Available bits start here */
 };
 
@@ -41,8 +43,15 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
-	BDI_DIRTIED,
-	BDI_WRITTEN,
+
+	/*
+	 * The three counters below reflects number of events of specific type
+	 * happened since bdi_init(). The type is defined in comments below:
+	 */
+	BDI_DIRTIED,	  /* a page was dirtied */
+	BDI_WRITTEN,	  /* writeout completed for a page */
+	BDI_WRITTEN_BACK, /* a page went to writeback */
+
 	NR_BDI_STAT_ITEMS
 };
 
@@ -73,9 +82,12 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
-	unsigned long bw_time_stamp;	/* last time write bw is updated */
-	unsigned long dirtied_stamp;
-	unsigned long written_stamp;	/* pages written at bw_time_stamp */
+	unsigned long bw_time_stamp;	/* last time (in jiffies) write bw
+					 * is updated */
+	unsigned long dirtied_nr_stamp;
+	unsigned long written_nr_stamp;	/* pages written at bw_time_stamp */
+	unsigned long writeback_nr_stamp; /* pages sent to writeback at
+					   * bw_time_stamp */
 	unsigned long write_bandwidth;	/* the estimated write bandwidth */
 	unsigned long avg_write_bandwidth; /* further smoothed write bw */
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..baac702 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,7 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
+	AS_STRICTLIMIT	= __GFP_BITS_SHIFT + 5, /* strict dirty limit */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 579a500..5144051 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -159,7 +159,8 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,
-			    unsigned long start_time);
+			    unsigned long start_time,
+			    bool strictlimit);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 5025174..acfeec7 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -94,6 +94,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
+		   "BdiWrittenBack:     %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -107,6 +108,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTIED)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN_BACK)),
 		   (unsigned long) K(bdi->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
@@ -454,7 +456,8 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->dirty_exceeded = 0;
 
 	bdi->bw_time_stamp = jiffies;
-	bdi->written_stamp = 0;
+	bdi->written_nr_stamp = 0;
+	bdi->writeback_nr_stamp = 0;
 
 	bdi->balanced_dirty_ratelimit = INIT_BW;
 	bdi->dirty_ratelimit = INIT_BW;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4514ad7..83c7434 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -585,6 +585,37 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 }
 
 /*
+ *                           setpoint - dirty 3
+ *        f(dirty) := 1.0 + (----------------)
+ *                           limit - setpoint
+ *
+ * it's a 3rd order polynomial that subjects to
+ *
+ * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
+ * (2) f(setpoint) = 1.0 => the balance point
+ * (3) f(limit)    = 0   => the hard limit
+ * (4) df/dx      <= 0	 => negative feedback control
+ * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
+ *     => fast response on large errors; small oscillation near setpoint
+ */
+static inline long long pos_ratio_polynom(unsigned long setpoint,
+					  unsigned long dirty,
+					  unsigned long limit)
+{
+	long long pos_ratio;
+	long x;
+
+	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
+		    limit - setpoint + 1);
+	pos_ratio = x;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
+
+	return pos_ratio;
+}
+
+/*
  * Dirty position control.
  *
  * (o) global/bdi setpoints
@@ -664,7 +695,8 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 					unsigned long bg_thresh,
 					unsigned long dirty,
 					unsigned long bdi_thresh,
-					unsigned long bdi_dirty)
+					unsigned long bdi_dirty,
+					bool strictlimit)
 {
 	unsigned long write_bw = bdi->avg_write_bandwidth;
 	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
@@ -680,28 +712,55 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 		return 0;
 
 	/*
-	 * global setpoint
+	 * The strictlimit feature is a tool preventing mistrusted filesystems
+	 * to grow a large number of dirty pages before throttling. For such
+	 * filesystems balance_dirty_pages always checks bdi counters against
+	 * bdi limits. Even if global "nr_dirty" is under "freerun". This is
+	 * especially important for fuse who sets bdi->max_ratio to 1% by
+	 * default. Without strictlimit feature, fuse writeback may consume
+	 * arbitrary amount of RAM because it is accounted in
+	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
 	 *
-	 *                           setpoint - dirty 3
-	 *        f(dirty) := 1.0 + (----------------)
-	 *                           limit - setpoint
+	 * Here, in bdi_position_ratio(), we calculate pos_ratio based on
+	 * two values: bdi_dirty and bdi_thresh. Let's consider an example:
+	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
+	 * limits are set by default to 10% and 20% (background and throttle).
+	 * Then bdi_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
+	 * bdi_dirty_limit(bdi, bg_thresh) is about ~4K pages. bdi_setpoint is
+	 * about ~6K pages (as the average of background and throttle bdi
+	 * limits). The 3rd order polynomial will provide positive feedback if
+	 * bdi_dirty is under bdi_setpoint and vice versa.
 	 *
-	 * it's a 3rd order polynomial that subjects to
+	 * Note, that we cannot use global counters in these calculations
+	 * because we want to throttle process writing to strictlimit address
+	 * space much earlier than global "freerun" is reached (~23MB vs.
+	 * ~2.3GB in the example above).
+	 */
+	if (unlikely(strictlimit)) {
+		if (bdi_dirty < 8)
+			return 2 << RATELIMIT_CALC_SHIFT;
+
+		if (bdi_dirty >= bdi_thresh)
+			return 0;
+
+		bdi_setpoint = bdi_thresh + bdi_dirty_limit(bdi, bg_thresh);
+		bdi_setpoint /= 2;
+
+		if (bdi_setpoint == 0 || bdi_setpoint == bdi_thresh)
+			return 0;
+
+		pos_ratio = pos_ratio_polynom(bdi_setpoint, bdi_dirty,
+					      bdi_thresh);
+		return min_t(long long, pos_ratio, 2 << RATELIMIT_CALC_SHIFT);
+	}
+
+	/*
+	 * global setpoint
 	 *
-	 * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
-	 * (2) f(setpoint) = 1.0 => the balance point
-	 * (3) f(limit)    = 0   => the hard limit
-	 * (4) df/dx      <= 0	 => negative feedback control
-	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
-	 *     => fast response on large errors; small oscillation near setpoint
+	 * See comment for pos_ratio_polynom().
 	 */
 	setpoint = (freerun + limit) / 2;
-	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
-		    limit - setpoint + 1);
-	pos_ratio = x;
-	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
-	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
-	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
+	pos_ratio = pos_ratio_polynom(setpoint, dirty, limit);
 
 	/*
 	 * We have computed basic pos_ratio above based on global situation. If
@@ -799,7 +858,7 @@ static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 	 * write_bandwidth = ---------------------------------------------------
 	 *                                          period
 	 */
-	bw = written - bdi->written_stamp;
+	bw = written - bdi->written_nr_stamp;
 	bw *= HZ;
 	if (unlikely(elapsed > period)) {
 		do_div(bw, elapsed);
@@ -892,7 +951,8 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 				       unsigned long bdi_thresh,
 				       unsigned long bdi_dirty,
 				       unsigned long dirtied,
-				       unsigned long elapsed)
+				       unsigned long elapsed,
+				       bool strictlimit)
 {
 	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
 	unsigned long limit = hard_dirty_limit(thresh);
@@ -910,10 +970,10 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * The dirty rate will match the writeout rate in long term, except
 	 * when dirty pages are truncated by userspace or re-dirtied by FS.
 	 */
-	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+	dirty_rate = (dirtied - bdi->dirtied_nr_stamp) * HZ / elapsed;
 
 	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
-				       bdi_thresh, bdi_dirty);
+				       bdi_thresh, bdi_dirty, strictlimit);
 	/*
 	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
 	 */
@@ -994,6 +1054,26 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * keep that period small to reduce time lags).
 	 */
 	step = 0;
+
+	/*
+	 * For strictlimit case, balanced_dirty_ratelimit was calculated
+	 * above based on bdi counters and limits (see bdi_position_ratio()).
+	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
+	 * "dirty" and bdi_setpoint as "setpoint".
+	 *
+	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
+	 * it's possible that bdi_thresh is close to zero due to inactivity
+	 * of backing device (see the implementation of bdi_dirty_limit()).
+	 */
+	if (unlikely(strictlimit)) {
+		dirty = bdi_dirty;
+		if (bdi_dirty < 8)
+			setpoint = bdi_dirty + 1;
+		else
+			setpoint = (bdi_thresh +
+				    bdi_dirty_limit(bdi, bg_thresh)) / 2;
+	}
+
 	if (dirty < setpoint) {
 		x = min(bdi->balanced_dirty_ratelimit,
 			 min(balanced_dirty_ratelimit, task_ratelimit));
@@ -1034,12 +1114,14 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,
-			    unsigned long start_time)
+			    unsigned long start_time,
+			    bool strictlimit)
 {
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - bdi->bw_time_stamp;
 	unsigned long dirtied;
 	unsigned long written;
+	unsigned long writeback;
 
 	/*
 	 * rate-limit, only update once every 200ms.
@@ -1049,6 +1131,7 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 
 	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+	writeback = bdi_stat_sum(bdi, BDI_WRITTEN_BACK);
 
 	/*
 	 * Skip quiet periods when disk bandwidth is under-utilized.
@@ -1057,18 +1140,32 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
 		goto snapshot;
 
+	/*
+	 * Skip periods when backing dev was idle due to abscence of pages
+	 * under writeback (when over_bground_thresh() returns false)
+	 */
+	if (test_bit(BDI_idle, &bdi->state) &&
+	    bdi->writeback_nr_stamp == writeback)
+		goto snapshot;
+
 	if (thresh) {
 		global_update_bandwidth(thresh, dirty, now);
 		bdi_update_dirty_ratelimit(bdi, thresh, bg_thresh, dirty,
 					   bdi_thresh, bdi_dirty,
-					   dirtied, elapsed);
+					   dirtied, elapsed, strictlimit);
 	}
 	bdi_update_write_bandwidth(bdi, elapsed, written);
 
 snapshot:
-	bdi->dirtied_stamp = dirtied;
-	bdi->written_stamp = written;
+	bdi->dirtied_nr_stamp = dirtied;
+	bdi->written_nr_stamp = written;
 	bdi->bw_time_stamp = now;
+
+	bdi->writeback_nr_stamp = writeback;
+	if (bdi_stat_sum(bdi, BDI_WRITEBACK) == 0)
+		set_bit(BDI_idle, &bdi->state);
+	else
+		clear_bit(BDI_idle, &bdi->state);
 }
 
 static void bdi_update_bandwidth(struct backing_dev_info *bdi,
@@ -1077,13 +1174,14 @@ static void bdi_update_bandwidth(struct backing_dev_info *bdi,
 				 unsigned long dirty,
 				 unsigned long bdi_thresh,
 				 unsigned long bdi_dirty,
-				 unsigned long start_time)
+				 unsigned long start_time,
+				 bool strictlimit)
 {
 	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
 		return;
 	spin_lock(&bdi->wb.list_lock);
 	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
-			       bdi_thresh, bdi_dirty, start_time);
+			       bdi_thresh, bdi_dirty, start_time, strictlimit);
 	spin_unlock(&bdi->wb.list_lock);
 }
 
@@ -1226,6 +1324,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	bool strictlimit = test_bit(AS_STRICTLIMIT, &mapping->flags);
 	unsigned long start_time = jiffies;
 
 	for (;;) {
@@ -1250,7 +1349,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		freerun = dirty_freerun_ceiling(dirty_thresh,
 						background_thresh);
-		if (nr_dirty <= freerun) {
+		if (nr_dirty <= freerun  && !strictlimit) {
 			current->dirty_paused_when = now;
 			current->nr_dirtied = 0;
 			current->nr_dirtied_pause =
@@ -1258,7 +1357,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 		}
 
-		if (unlikely(!writeback_in_progress(bdi)))
+		if (unlikely(!writeback_in_progress(bdi)) && !strictlimit)
 			bdi_start_background_writeback(bdi);
 
 		/*
@@ -1296,19 +1395,24 @@ static void balance_dirty_pages(struct address_space *mapping,
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		if (unlikely(!writeback_in_progress(bdi)) &&
+		    bdi_dirty > bdi_thresh / 4)
+			bdi_start_background_writeback(bdi);
+
 		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
-				  (nr_dirty > dirty_thresh);
+				 ((nr_dirty > dirty_thresh) || strictlimit);
 		if (dirty_exceeded && !bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 
 		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
 				     nr_dirty, bdi_thresh, bdi_dirty,
-				     start_time);
+				     start_time, strictlimit);
 
 		dirty_ratelimit = bdi->dirty_ratelimit;
 		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
 					       background_thresh, nr_dirty,
-					       bdi_thresh, bdi_dirty);
+					       bdi_thresh, bdi_dirty,
+					       strictlimit);
 		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
 		max_pause = bdi_max_pause(bdi, bdi_dirty);
@@ -1362,6 +1466,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 		}
 
 pause:
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
 		trace_balance_dirty_pages(bdi,
 					  dirty_thresh,
 					  background_thresh,
@@ -2265,8 +2371,10 @@ int test_set_page_writeback(struct page *page)
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			if (bdi_cap_account_writeback(bdi))
+			if (bdi_cap_account_writeback(bdi)) {
 				__inc_bdi_stat(bdi, BDI_WRITEBACK);
+				__inc_bdi_stat(bdi, BDI_WRITTEN_BACK);
+			}
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
