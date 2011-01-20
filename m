Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 761818D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:39:26 -0500 (EST)
Date: Thu, 20 Jan 2011 21:39:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: dirty throttling v5 for 2.6.37-rc7+
Message-ID: <20110120133920.GA18830@localhost>
References: <20101224170418.GA3405@gamma.logic.tuwien.ac.at>
 <20101225030019.GA25383@localhost>
 <20101225052736.GA5649@gamma.logic.tuwien.ac.at>
 <20101225073850.GA1626@localhost>
 <20110119043847.GF29887@gamma.logic.tuwien.ac.at>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <20110119043847.GF29887@gamma.logic.tuwien.ac.at>
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Norbert,

On Wed, Jan 19, 2011 at 12:38:47PM +0800, Norbert Preining wrote:
> Hi Fengguang,
> 
> On Sa, 25 Dez 2010, Wu Fengguang wrote:
> > > > I just created branch "dirty-throttling-v5" based on today's linux-2.6 head.
> 
> One request, please update for 38-rc1, thanks.

Sure, attached is the combined patch for 2.6.38-rc1. It's a simple
rebase from 2.6.37 and contains no functionality changes. (There are
some more changes actually, but unfortunately they are not in a clean
state.)

> > It's already a test to simply run it in your environment, thanks!
> > Whether it runs fine or not, they will make valuable feedbacks :)
> 
> It runs fine, and feels a bit better when I trash my hard disk with
> subversion. Still some times the whole computer is unresponsive,
> the mouse pointer when entering the terminal of the subversion process
> disappearing, but without it it is a bit worse.
> 
> Thanks and all the best

Glad to hear about that. Thanks for trying it out!

Thanks,
Fengguang

--9jxsPFA5p3P2qPhR
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="dirty-throttling-v5-2.6.38-rc1.patch"

--- linux-writeback.orig/fs/fs-writeback.c	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/fs/fs-writeback.c	2011-01-20 21:33:25.000000000 +0800
@@ -330,6 +330,8 @@ static int
 writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct address_space *mapping = inode->i_mapping;
+	long per_file_limit = wbc->per_file_limit;
+	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
 
@@ -349,7 +351,8 @@ writeback_single_inode(struct inode *ino
 		 */
 		if (wbc->sync_mode != WB_SYNC_ALL) {
 			requeue_io(inode);
-			return 0;
+			ret = 0;
+			goto out;
 		}
 
 		/*
@@ -365,8 +368,14 @@ writeback_single_inode(struct inode *ino
 	inode->i_state &= ~I_DIRTY_PAGES;
 	spin_unlock(&inode_lock);
 
+	if (per_file_limit)
+		wbc->nr_to_write = per_file_limit;
+
 	ret = do_writepages(mapping, wbc);
 
+	if (per_file_limit)
+		wbc->nr_to_write += nr_to_write - per_file_limit;
+
 	/*
 	 * Make sure to wait on the data before writing out the metadata.
 	 * This is important for filesystems that modify metadata on data
@@ -436,6 +445,9 @@ writeback_single_inode(struct inode *ino
 		}
 	}
 	inode_sync_complete(inode);
+out:
+	trace_writeback_single_inode(inode, wbc,
+				     nr_to_write - wbc->nr_to_write);
 	return ret;
 }
 
@@ -527,6 +539,12 @@ static int writeback_sb_inodes(struct su
 			 * buffers.  Skip this inode for now.
 			 */
 			redirty_tail(inode);
+			/*
+			 * There's no logic to retry skipped pages for sync(),
+			 * filesystems are assumed not to skip dirty pages on
+			 * temporal lock contentions or non fatal errors.
+			 */
+			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
 		}
 		spin_unlock(&inode_lock);
 		iput(inode);
@@ -584,23 +602,53 @@ static void __writeback_inodes_sb(struct
 	spin_unlock(&inode_lock);
 }
 
+static bool over_bground_thresh(struct backing_dev_info *bdi)
+{
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+	unsigned long bdi_thresh;
+
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+		return true;
+
+	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, dirty_thresh);
+
+	return bdi_stat(bdi, BDI_RECLAIMABLE) > bdi_thresh / 2;
+}
+
 /*
- * The maximum number of pages to writeout in a single bdi flush/kupdate
- * operation.  We do this so we don't hold I_SYNC against an inode for
- * enormous amounts of time, which would block a userspace task which has
- * been forced to throttle against that inode.  Also, the code reevaluates
- * the dirty each time it has written this many pages.
+ * Give each inode a nr_to_write that can complete within 1 second.
  */
-#define MAX_WRITEBACK_PAGES     1024
-
-static inline bool over_bground_thresh(void)
+static unsigned long writeback_chunk_size(struct backing_dev_info *bdi,
+					  int sync_mode)
 {
-	unsigned long background_thresh, dirty_thresh;
+	unsigned long pages;
 
-	global_dirty_limits(&background_thresh, &dirty_thresh);
+	/*
+	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
+	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
+	 * here avoids calling into writeback_inodes_wb() more than once.
+	 *
+	 * The intended call sequence for WB_SYNC_ALL writeback is:
+	 *
+	 *      wb_writeback()
+	 *          __writeback_inodes_sb()     <== called only once
+	 *              write_cache_pages()     <== called once for each inode
+	 *                  (quickly) tag currently dirty pages
+	 *                  (maybe slowly) sync all tagged pages
+	 */
+	if (sync_mode == WB_SYNC_ALL)
+		return LONG_MAX;
+
+	pages = bdi->write_bandwidth;
+
+	if (pages < MIN_WRITEBACK_PAGES)
+		return MIN_WRITEBACK_PAGES;
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	return rounddown_pow_of_two(pages);
 }
 
 /*
@@ -643,25 +691,9 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
-	/*
-	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
-	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
-	 * here avoids calling into writeback_inodes_wb() more than once.
-	 *
-	 * The intended call sequence for WB_SYNC_ALL writeback is:
-	 *
-	 *      wb_writeback()
-	 *          __writeback_inodes_sb()     <== called only once
-	 *              write_cache_pages()     <== called once for each inode
-	 *                   (quickly) tag currently dirty pages
-	 *                   (maybe slowly) sync all tagged pages
-	 */
-	if (wbc.sync_mode == WB_SYNC_NONE)
-		write_chunk = MAX_WRITEBACK_PAGES;
-	else
-		write_chunk = LONG_MAX;
-
 	wbc.wb_start = jiffies; /* livelock avoidance */
+	bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
+
 	for (;;) {
 		/*
 		 * Stop writeback when nr_pages has been consumed
@@ -683,11 +715,13 @@ static long wb_writeback(struct bdi_writ
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh())
+		if (work->for_background && !over_bground_thresh(wb->bdi))
 			break;
 
 		wbc.more_io = 0;
+		write_chunk = writeback_chunk_size(wb->bdi, wbc.sync_mode);
 		wbc.nr_to_write = write_chunk;
+		wbc.per_file_limit = write_chunk;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
@@ -697,6 +731,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
+		bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
+
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
 
@@ -720,6 +756,12 @@ static long wb_writeback(struct bdi_writ
 		 * become available for writeback. Otherwise
 		 * we'll just busyloop.
 		 */
+		if (list_empty(&wb->b_more_io)) {
+			trace_wbc_writeback_wait(&wbc, wb->bdi);
+			__set_current_state(TASK_UNINTERRUPTIBLE);
+			io_schedule_timeout(max(HZ/100, 1));
+			continue;
+		}
 		spin_lock(&inode_lock);
 		if (!list_empty(&wb->b_more_io))  {
 			inode = wb_inode(wb->b_more_io.prev);
@@ -763,7 +805,7 @@ static unsigned long get_nr_dirty_pages(
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh()) {
+	if (over_bground_thresh(wb->bdi)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,
--- linux-writeback.orig/mm/page-writeback.c	2011-01-20 21:21:34.000000000 +0800
+++ linux-writeback/mm/page-writeback.c	2011-01-20 21:33:25.000000000 +0800
@@ -37,24 +37,9 @@
 #include <trace/events/writeback.h>
 
 /*
- * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
- * will look to see if it needs to force writeback or throttling.
+ * Don't sleep more than 200ms at a time in balance_dirty_pages().
  */
-static long ratelimit_pages = 32;
-
-/*
- * When balance_dirty_pages decides that the caller needs to perform some
- * non-background writeback, this is how many pages it will attempt to write.
- * It should be somewhat larger than dirtied pages to ensure that reasonably
- * large amounts of I/O are submitted.
- */
-static inline long sync_writeback_pages(unsigned long dirtied)
-{
-	if (dirtied < ratelimit_pages)
-		dirtied = ratelimit_pages;
-
-	return dirtied + dirtied / 2;
-}
+#define MAX_PAUSE	max(HZ/5, 1)
 
 /* The following parameters are exported via /proc/sys/vm */
 
@@ -219,6 +204,7 @@ int dirty_bytes_handler(struct ctl_table
  */
 static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
+	__inc_bdi_stat(bdi, BDI_WRITTEN);
 	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
 			      bdi->max_prop_frac);
 }
@@ -244,13 +230,8 @@ void task_dirty_inc(struct task_struct *
 static void bdi_writeout_fraction(struct backing_dev_info *bdi,
 		long *numerator, long *denominator)
 {
-	if (bdi_cap_writeback_dirty(bdi)) {
-		prop_fraction_percpu(&vm_completions, &bdi->completions,
+	prop_fraction_percpu(&vm_completions, &bdi->completions,
 				numerator, denominator);
-	} else {
-		*numerator = 0;
-		*denominator = 1;
-	}
 }
 
 static inline void task_dirties_fraction(struct task_struct *tsk,
@@ -265,7 +246,7 @@ static inline void task_dirties_fraction
  *
  * task specific dirty limit:
  *
- *   dirty -= (dirty/8) * p_{t}
+ *   dirty -= (dirty/8) * log2(p_{t})
  *
  * To protect light/slow dirtying tasks from heavier/fast ones, we start
  * throttling individual tasks before reaching the bdi dirty limit.
@@ -275,19 +256,33 @@ static inline void task_dirties_fraction
  * dirty threshold may never get throttled.
  */
 static unsigned long task_dirty_limit(struct task_struct *tsk,
-				       unsigned long bdi_dirty)
+				      unsigned long thresh)
 {
 	long numerator, denominator;
-	unsigned long dirty = bdi_dirty;
-	u64 inv = dirty >> 3;
+	unsigned long t = thresh / (TASK_SOFT_DIRTY_LIMIT * 16);
+	u64 inv = t;
+	int shift;
 
 	task_dirties_fraction(tsk, &numerator, &denominator);
-	inv *= numerator;
+
+	shift = (numerator << 16) / denominator;
+	/*
+	 * The calculation is not applicable for weight 0, which will actually
+	 * slightly raise the threshold rather than to decrease it.
+	 */
+	if (unlikely(shift == 0))
+		return thresh;
+
+	shift = 16 - ilog2(shift);
+
+	inv *= numerator << shift;
 	do_div(inv, denominator);
+	inv -= t;
 
-	dirty -= inv;
+	thresh -= t * (16 - shift);
+	thresh -= inv;
 
-	return max(dirty, bdi_dirty/2);
+	return thresh;
 }
 
 /*
@@ -426,8 +421,15 @@ void global_dirty_limits(unsigned long *
 	else
 		background = (dirty_background_ratio * available_memory) / 100;
 
-	if (background >= dirty)
-		background = dirty / 2;
+	/*
+	 * Ensure at least 1/4 gap between background and dirty thresholds, so
+	 * that when dirty throttling starts at (background + dirty)/2, it's at
+	 * the entrance of bdi soft throttle threshold, so as to avoid being
+	 * hard throttled.
+	 */
+	if (background > dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT)
+		background = dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT;
+
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
 		background += background / 4;
@@ -435,24 +437,46 @@ void global_dirty_limits(unsigned long *
 	}
 	*pbackground = background;
 	*pdirty = dirty;
+	trace_global_dirty_state(background, dirty);
 }
+EXPORT_SYMBOL_GPL(global_dirty_limits);
 
-/*
+/**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
+ * @bdi: the backing_dev_info to query
+ * @dirty: global dirty limit in pages
+ * @dirty_pages: current number of dirty pages
+ *
+ * Returns @bdi's dirty limit in pages. The term "dirty" in the context of
+ * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
  *
- * Allocate high/low dirty limits to fast/slow devices, in order to prevent
+ * It allocates high/low dirty limits to fast/slow devices, in order to prevent
  * - starving fast devices
  * - piling up dirty pages (that will take long time to sync) on slow devices
  *
  * The bdi's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
- */
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
+ *
+ * There is a chicken and egg problem: when bdi A (eg. /pub) is heavy dirtied
+ * and bdi B (eg. /) is light dirtied hence has 0 dirty limit, tasks writing to
+ * B always get heavily throttled and bdi B's dirty limit might never be able
+ * to grow up from 0. So we do tricks to reserve some global margin and honour
+ * it to the bdi's that run low.
+ */
+unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
+			      unsigned long dirty,
+			      unsigned long dirty_pages)
 {
 	u64 bdi_dirty;
 	long numerator, denominator;
 
 	/*
+	 * try to prevent "global limit exceeded but bdi limit not exceeded"
+	 */
+	if (likely(dirty > bdi_stat_error(bdi)))
+		dirty -= bdi_stat_error(bdi);
+
+	/*
 	 * Calculate this BDI's share of the dirty ratio.
 	 */
 	bdi_writeout_fraction(bdi, &numerator, &denominator);
@@ -462,6 +486,15 @@ unsigned long bdi_dirty_limit(struct bac
 	do_div(bdi_dirty, denominator);
 
 	bdi_dirty += (dirty * bdi->min_ratio) / 100;
+
+	/*
+	 * If we can dirty N more pages globally, honour N/2 to the bdi that
+	 * runs low, so as to help it ramp up.
+	 */
+	if (unlikely(dirty > dirty_pages &&
+		     bdi_dirty < (dirty - dirty_pages) / 2))
+		bdi_dirty = (dirty - dirty_pages) / 2;
+
 	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
 		bdi_dirty = dirty * bdi->max_ratio / 100;
 
@@ -469,6 +502,211 @@ unsigned long bdi_dirty_limit(struct bac
 }
 
 /*
+ * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
+ * will look to see if it needs to start dirty throttling.
+ *
+ * If ratelimit_pages is too low then big NUMA machines will call the expensive
+ * global_page_state() too often. So scale it adaptively to the safety margin
+ * (the number of pages we may dirty without exceeding the dirty limits).
+ */
+static unsigned long ratelimit_pages(unsigned long dirty_thresh,
+				     unsigned long dirty_pages)
+{
+	return 1UL << (ilog2(dirty_thresh - dirty_pages) >> 1);
+}
+
+static void __bdi_update_dirty_smooth(struct backing_dev_info *bdi,
+				      unsigned long dirty,
+				      unsigned long thresh,
+				      unsigned long elapsed)
+{
+	unsigned long avg = bdi->avg_dirty;
+	unsigned long old = bdi->old_dirty;
+	unsigned long bw;
+	unsigned long gap = thresh / TASK_SOFT_DIRTY_LIMIT;
+
+	/* skip call from the flusher */
+	if (!thresh)
+		return;
+
+	if (unlikely(avg > thresh - gap / 4 || avg + gap * 4 < dirty)) {
+		avg = (avg * 3 + dirty) / 4;
+		goto update;
+	}
+
+	/* bdi_dirty is departing upwards, quickly follow up */
+	if (avg < old && old < dirty) {
+		avg += (dirty - avg) / 32;
+		goto update;
+	}
+
+	/*
+	 * bdi_dirty is departing downwards, raise it if drifting too away from
+	 * avg_dirty and bdi_thresh, or follow it if the workload goes light.
+	 */
+	if (avg > old && old > dirty && avg - old > gap / 2) {
+		avg -= (gap + avg - old) / 256;
+		goto update;
+	}
+
+	/*
+	 * bdi_dirty is growing too fast, curb it to prevent hitting/exceeding
+	 * the task/bdi limits after a while. This is particularly useful for
+	 * NFS/XFS which regularly clear PG_writeback in bursts of 32MB. It
+	 * converts the dirty-time curve from shape 'r' to shape '/'.
+	 */
+	bw = bdi->write_bandwidth * elapsed;
+	if (thresh - gap * 3 < old && old < dirty && dirty < avg &&
+	    (dirty - old) * HZ > bw) {
+		avg += min(gap / 128,
+			   gap * ((dirty - old) * HZ - bw) / (bw | 1));
+		goto update;
+	}
+
+	goto out;
+
+update:
+	bdi->avg_dirty = avg;
+out:
+	bdi->old_dirty = dirty;
+}
+
+static void __bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					 unsigned long elapsed,
+					 unsigned long written)
+{
+	const unsigned long period = roundup_pow_of_two(8 * HZ);
+	u64 bw;
+
+	bw = written - bdi->written_stamp;
+	bw *= HZ;
+	if (elapsed > period / 2) {
+		do_div(bw, elapsed);
+		elapsed = period / 2;
+		bw *= elapsed;
+	}
+	bw += (u64)bdi->write_bandwidth * (period - elapsed);
+	bdi->write_bandwidth = bw >> ilog2(period);
+}
+
+/*
+ * The bdi throttle bandwidth is introduced for resisting bdi_dirty from
+ * getting too close to task_thresh. It allows scaling up to 1000+ concurrent
+ * dirtier tasks while keeping the fluctuation level flat.
+ */
+static void __bdi_update_throttle_bandwidth(struct backing_dev_info *bdi,
+					    unsigned long dirty,
+					    unsigned long thresh)
+{
+	unsigned long gap = thresh / TASK_SOFT_DIRTY_LIMIT + 1;
+	unsigned long bw = bdi->throttle_bandwidth;
+	unsigned long wb = bdi->write_bandwidth;
+
+	if (dirty > thresh)
+		return;
+
+	/* adapt to concurrent dirtiers */
+	if (dirty > thresh - gap - gap / 2) {
+		bw -= bw >> (3 + 4 * (thresh - dirty) / gap);
+		goto out;
+	}
+
+	/*
+	 * Adapt to one single dirtier at workload startup time.
+	 * The "+- wb / 8" below is space reserved for fluctuations.
+	 */
+	if (dirty > thresh - gap * 2 + gap / 4 && bw > wb + wb / 8) {
+		bw -= bw >> (3 + 4 * (thresh - dirty - gap) / gap);
+		goto out;
+	}
+
+	/*
+	 * Adapt to lighter workload.
+	 * The '<=' here allows the flusher (which passes dirty = thresh = 0)
+	 * to slowly restore throttle_bandwidth when workload goes light.
+	 */
+	if (dirty <= thresh - gap * 2 - gap / 2 && bw < wb - wb / 8) {
+		bw += (bw >> 4) + 1;
+		goto out;
+	}
+
+	return;
+out:
+	bdi->throttle_bandwidth = bw;
+}
+
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long start_time,
+			  unsigned long bdi_dirty,
+			  unsigned long bdi_thresh)
+{
+	unsigned long elapsed;
+	unsigned long written;
+
+	if (!spin_trylock(&bdi->bw_lock))
+		return;
+
+	elapsed = jiffies - bdi->bw_time_stamp;
+	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+
+	/* skip quiet periods when disk bandwidth is under-utilized */
+	if (elapsed > HZ/2 &&
+	    elapsed > jiffies - start_time)
+		goto snapshot;
+
+	/* rate-limit, only update once every 100ms */
+	if (elapsed <= HZ/10)
+		goto unlock;
+
+	__bdi_update_dirty_smooth(bdi, bdi_dirty, bdi_thresh, elapsed);
+	__bdi_update_write_bandwidth(bdi, elapsed, written);
+	__bdi_update_throttle_bandwidth(bdi, bdi->avg_dirty, bdi_thresh);
+
+snapshot:
+	bdi->written_stamp = written;
+	bdi->bw_time_stamp = jiffies;
+unlock:
+	spin_unlock(&bdi->bw_lock);
+}
+
+/*
+ * Limit pause time for small memory systems. If sleeping for too long time,
+ * the small pool of dirty/writeback pages may go empty and disk go idle.
+ */
+static unsigned long max_pause(unsigned long bdi_thresh)
+{
+	unsigned long t;  /* jiffies */
+
+	/* 1ms for every 4MB */
+	t = bdi_thresh >> (32 - PAGE_CACHE_SHIFT -
+			   ilog2(roundup_pow_of_two(HZ)));
+	t += 2;
+
+	return min_t(unsigned long, t, MAX_PAUSE);
+}
+
+/*
+ * Scale up pause time for concurrent dirtiers in order to reduce CPU overheads.
+ * But ensure reasonably large [min_pause, max_pause] range size, so that
+ * nr_dirtied_pause (and hence future pause time) can stay reasonably stable.
+ */
+static unsigned long min_pause(struct backing_dev_info *bdi,
+			       unsigned long max)
+{
+	unsigned long hi = ilog2(bdi->write_bandwidth);
+	unsigned long lo = ilog2(bdi->throttle_bandwidth);
+	unsigned long t;  /* jiffies */
+
+	if (lo >= hi)
+		return 1;
+
+	/* (N * 10ms) on 2^N concurrent tasks */
+	t = (hi - lo) * (10 * HZ) / 1024;
+
+	return clamp_val(t, 1, max / 2);
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -476,43 +714,39 @@ unsigned long bdi_dirty_limit(struct bac
  * perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping,
-				unsigned long write_chunk)
+				unsigned long pages_dirtied)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+	long nr_reclaimable;
+	long nr_dirty;
+	long bdi_dirty;  /* = file_dirty + writeback + unstable_nfs */
+	long avg_dirty;  /* smoothed bdi_dirty */
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long pages_written = 0;
-	unsigned long pause = 1;
+	unsigned long task_thresh;
+	unsigned long long bw;
+	unsigned long period;
+	unsigned long pause = 0;
+	unsigned long pause_max;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	unsigned long start_time = jiffies;
 
 	for (;;) {
-		struct writeback_control wbc = {
-			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
-			.nr_to_write	= write_chunk,
-			.range_cyclic	= 1,
-		};
-
+		/*
+		 * Unstable writes are a feature of certain networked
+		 * filesystems (i.e. NFS) in which data may have been
+		 * written to the server's write cache, but has not yet
+		 * been flushed to permanent storage.
+		 */
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
-		/*
-		 * Throttle it only when the background writeback cannot
-		 * catch-up. This avoids (excessively) small writeouts
-		 * when the bdi limits are ramping up.
-		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
-			break;
-
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, nr_dirty);
+		task_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need
@@ -525,62 +759,133 @@ static void balance_dirty_pages(struct a
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+			bdi_dirty = bdi_stat_sum(bdi, BDI_RECLAIMABLE) +
+				    bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+			bdi_dirty = bdi_stat(bdi, BDI_RECLAIMABLE) +
+				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
 		/*
+		 * Throttle it only when the background writeback cannot
+		 * catch-up. This avoids (excessively) small writeouts
+		 * when the bdi limits are ramping up.
+		 */
+		if (nr_dirty <= (background_thresh + dirty_thresh) / 2 &&
+		    bdi_dirty <= bdi_thresh -
+				 bdi_thresh / (BDI_SOFT_DIRTY_LIMIT / 2)) {
+			current->paused_when = jiffies;
+			current->nr_dirtied = 0;
+			break;
+		}
+
+		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
+
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
+
+		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
 		 * global "hard" limit. The former helps to prevent heavy IO
 		 * bdi or process from holding back light ones; The latter is
 		 * the last resort safeguard.
 		 */
-		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
+		dirty_exceeded = bdi_dirty > bdi_thresh ||
+				  nr_dirty > dirty_thresh;
+		if (dirty_exceeded && !bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 1;
 
-		if (!dirty_exceeded)
-			break;
+		avg_dirty = bdi->avg_dirty;
+		if (avg_dirty < bdi_dirty)
+			avg_dirty = bdi_dirty;
+
+		pause_max = max_pause(bdi_thresh);
+
+		if (avg_dirty >= task_thresh || nr_dirty > dirty_thresh) {
+			bw = 0;
+			period = pause_max;
+			pause = pause_max;
+			current->nr_dirtied_pause =
+					current->nr_dirtied_pause / 2 + 1;
+			goto pause;
+		}
 
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
+		bw = bdi->throttle_bandwidth;
 
-		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
-		 * Unstable writes are a feature of certain networked
-		 * filesystems (i.e. NFS) in which data may have been
-		 * written to the server's write cache, but has not yet
-		 * been flushed to permanent storage.
-		 * Only move pages to writeback if this bdi is over its
-		 * threshold otherwise wait until the disk writes catch
-		 * up.
+		bw = bw * (task_thresh - avg_dirty);
+		do_div(bw, (bdi_thresh / TASK_SOFT_DIRTY_LIMIT) | 1);
+
+		period = HZ * pages_dirtied / ((unsigned long)bw | 1);
+		if (unlikely(period == 0)) {
+			current->nr_dirtied_pause <<= 1;
+			pause = 1;
+			break;
+		}
+		pause = current->paused_when + period - jiffies;
+		/*
+		 * Take it as long think time if pause falls into (-10s, 0).
+		 * If it's less than 100ms, try to compensate it in future by
+		 * updating the virtual time; otherwise just reset the time, as
+		 * it may be a light dirtier.
 		 */
-		trace_wbc_balance_dirty_start(&wbc, bdi);
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes_wb(&bdi->wb, &wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			trace_wbc_balance_dirty_written(&wbc, bdi);
-			if (pages_written >= write_chunk)
-				break;		/* We've done our duty */
+		if (unlikely(-pause < HZ*10)) {
+			trace_balance_dirty_pages(bdi,
+						  bdi_dirty,
+						  avg_dirty,
+						  bdi_thresh,
+						  task_thresh,
+						  pages_dirtied,
+						  bw,
+						  period,
+						  pause,
+						  start_time);
+			if (-pause <= HZ/10)
+				current->paused_when += period;
+			else
+				current->paused_when = jiffies;
+			pause = 1;
+			current->nr_dirtied = 0;
+			break;
 		}
-		trace_wbc_balance_dirty_wait(&wbc, bdi);
+		if (pause > pause_max)
+			pause = pause_max;
+
+pause:
+		trace_balance_dirty_pages(bdi,
+					  bdi_dirty,
+					  avg_dirty,
+					  bdi_thresh,
+					  task_thresh,
+					  pages_dirtied,
+					  bw,
+					  period,
+					  pause,
+					  start_time);
+		current->paused_when = jiffies;
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
+		current->paused_when += pause;
+		current->nr_dirtied = 0;
 
-		/*
-		 * Increase the delay for each loop, up to our previous
-		 * default of taking a 100ms nap.
-		 */
-		pause <<= 1;
-		if (pause > HZ / 10)
-			pause = HZ / 10;
+		if (!dirty_exceeded)
+			break;
 	}
 
 	if (!dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
+	if (pause == 0)
+		current->nr_dirtied_pause =
+				ratelimit_pages(bdi_thresh, bdi_dirty);
+	else if (pause <= min_pause(bdi, pause_max))
+		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
+	else if (pause >= pause_max)
+		/*
+		 * when repeated, writing 1 page per 100ms on slow devices,
+		 * i-(i+2)/4 will be able to reach 1 but never reduce to 0.
+		 */
+		current->nr_dirtied_pause -= (current->nr_dirtied_pause+2) >> 2;
+
 	if (writeback_in_progress(bdi))
 		return;
 
@@ -592,8 +897,10 @@ static void balance_dirty_pages(struct a
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
-	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
+	if (laptop_mode)
+		return;
+
+	if (nr_reclaimable > background_thresh)
 		bdi_start_background_writeback(bdi);
 }
 
@@ -607,8 +914,6 @@ void set_page_dirty_balance(struct page 
 	}
 }
 
-static DEFINE_PER_CPU(unsigned long, bdp_ratelimits) = 0;
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -618,36 +923,29 @@ static DEFINE_PER_CPU(unsigned long, bdp
  * which was newly dirtied.  The function will periodically check the system's
  * dirty state and will initiate writeback if needed.
  *
- * On really big machines, get_writeback_state is expensive, so try to avoid
+ * On really big machines, global_page_state() is expensive, so try to avoid
  * calling it too often (ratelimiting).  But once we're over the dirty memory
- * limit we decrease the ratelimiting by a lot, to prevent individual processes
- * from overshooting the limit by (ratelimit_pages) each.
+ * limit we disable the ratelimiting, to prevent individual processes from
+ * overshooting the limit by (ratelimit_pages) each.
  */
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied)
 {
-	unsigned long ratelimit;
-	unsigned long *p;
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+
+	if (!bdi_cap_account_dirty(bdi))
+		return;
 
-	ratelimit = ratelimit_pages;
-	if (mapping->backing_dev_info->dirty_exceeded)
-		ratelimit = 8;
+	current->nr_dirtied += nr_pages_dirtied;
 
 	/*
 	 * Check the rate limiting. Also, we do not want to throttle real-time
 	 * tasks in balance_dirty_pages(). Period.
 	 */
-	preempt_disable();
-	p =  &__get_cpu_var(bdp_ratelimits);
-	*p += nr_pages_dirtied;
-	if (unlikely(*p >= ratelimit)) {
-		ratelimit = sync_writeback_pages(*p);
-		*p = 0;
-		preempt_enable();
-		balance_dirty_pages(mapping, ratelimit);
-		return;
+	if (unlikely(current->nr_dirtied >= current->nr_dirtied_pause ||
+		     bdi->dirty_exceeded)) {
+		balance_dirty_pages(mapping, current->nr_dirtied);
 	}
-	preempt_enable();
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
@@ -735,44 +1033,6 @@ void laptop_sync_completion(void)
 #endif
 
 /*
- * If ratelimit_pages is too high then we can get into dirty-data overload
- * if a large number of processes all perform writes at the same time.
- * If it is too low then SMP machines will call the (expensive)
- * get_writeback_state too often.
- *
- * Here we set ratelimit_pages to a level which ensures that when all CPUs are
- * dirtying in parallel, we cannot go more than 3% (1/32) over the dirty memory
- * thresholds before writeback cuts in.
- *
- * But the limit should not be set too high.  Because it also controls the
- * amount of memory which the balance_dirty_pages() caller has to write back.
- * If this is too large then the caller will block on the IO queue all the
- * time.  So limit it to four megabytes - the balance_dirty_pages() caller
- * will write six megabyte chunks, max.
- */
-
-void writeback_set_ratelimit(void)
-{
-	ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
-	if (ratelimit_pages < 16)
-		ratelimit_pages = 16;
-	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
-		ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
-}
-
-static int __cpuinit
-ratelimit_handler(struct notifier_block *self, unsigned long u, void *v)
-{
-	writeback_set_ratelimit();
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block __cpuinitdata ratelimit_nb = {
-	.notifier_call	= ratelimit_handler,
-	.next		= NULL,
-};
-
-/*
  * Called early on to tune the page writeback dirty limits.
  *
  * We used to scale dirty pages according to how total memory
@@ -794,9 +1054,6 @@ void __init page_writeback_init(void)
 {
 	int shift;
 
-	writeback_set_ratelimit();
-	register_cpu_notifier(&ratelimit_nb);
-
 	shift = calc_period_shift();
 	prop_descriptor_init(&vm_completions, shift);
 	prop_descriptor_init(&vm_dirties, shift);
@@ -1134,7 +1391,6 @@ EXPORT_SYMBOL(account_page_dirtied);
 void account_page_writeback(struct page *page)
 {
 	inc_zone_page_state(page, NR_WRITEBACK);
-	inc_zone_page_state(page, NR_WRITTEN);
 }
 EXPORT_SYMBOL(account_page_writeback);
 
@@ -1341,8 +1597,10 @@ int test_clear_page_writeback(struct pag
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
-	if (ret)
+	if (ret) {
 		dec_zone_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_WRITTEN);
+	}
 	return ret;
 }
 
--- linux-writeback.orig/mm/backing-dev.c	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/mm/backing-dev.c	2011-01-20 21:33:25.000000000 +0800
@@ -83,24 +83,28 @@ static int bdi_debug_stats_show(struct s
 	spin_unlock(&inode_lock);
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
-		   "BdiWriteback:     %8lu kB\n"
-		   "BdiReclaimable:   %8lu kB\n"
-		   "BdiDirtyThresh:   %8lu kB\n"
-		   "DirtyThresh:      %8lu kB\n"
-		   "BackgroundThresh: %8lu kB\n"
-		   "b_dirty:          %8lu\n"
-		   "b_io:             %8lu\n"
-		   "b_more_io:        %8lu\n"
-		   "bdi_list:         %8u\n"
-		   "state:            %8lx\n",
+		   "BdiWriteback:       %10lu kB\n"
+		   "BdiReclaimable:     %10lu kB\n"
+		   "BdiDirtyThresh:     %10lu kB\n"
+		   "DirtyThresh:        %10lu kB\n"
+		   "BackgroundThresh:   %10lu kB\n"
+		   "BdiWritten:         %10lu kB\n"
+		   "BdiWriteBandwidth:  %10lu kBps\n"
+		   "b_dirty:            %10lu\n"
+		   "b_io:               %10lu\n"
+		   "b_more_io:          %10lu\n"
+		   "bdi_list:           %10u\n"
+		   "state:              %10lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
-		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
+		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
+		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   (unsigned long) K(bdi->write_bandwidth),
+		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
 
@@ -658,6 +662,17 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
+	spin_lock_init(&bdi->bw_lock);
+	bdi->bw_time_stamp = jiffies;
+	bdi->written_stamp = 0;
+
+	/* start from 50 MB/s */
+	bdi->write_bandwidth = 50 << (20 - PAGE_SHIFT);
+	bdi->throttle_bandwidth = 50 << (20 - PAGE_SHIFT);
+
+	bdi->avg_dirty = 0;
+	bdi->old_dirty = 0;
+
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
--- linux-writeback.orig/include/linux/writeback.h	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/include/linux/writeback.h	2011-01-20 21:33:14.000000000 +0800
@@ -12,6 +12,21 @@ struct backing_dev_info;
 extern spinlock_t inode_lock;
 
 /*
+ * The 1/8 region under the bdi dirty threshold is set aside for elastic
+ * throttling. In rare cases when the threshold is exceeded, more rigid
+ * throttling will be imposed, which will inevitably stall the dirtier task
+ * for seconds (or more) at _one_ time. The rare case could be a fork bomb
+ * where every new task dirties some more pages.
+ */
+#define BDI_SOFT_DIRTY_LIMIT	8
+#define TASK_SOFT_DIRTY_LIMIT	(BDI_SOFT_DIRTY_LIMIT * 2)
+
+/*
+ * 4MB minimal write chunk size
+ */
+#define MIN_WRITEBACK_PAGES     (4096UL >> (PAGE_CACHE_SHIFT - 10))
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {
@@ -33,6 +48,7 @@ struct writeback_control {
 					   extra jobs and livelock */
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */
+	long per_file_limit;		/* Write this many pages for one file */
 	long pages_skipped;		/* Pages which were not written */
 
 	/*
@@ -126,7 +142,18 @@ int dirty_writeback_centisecs_handler(st
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
-			       unsigned long dirty);
+			       unsigned long dirty,
+			       unsigned long dirty_pages);
+
+void bdi_update_bandwidth(struct backing_dev_info *bdi,
+			  unsigned long start_time,
+			  unsigned long bdi_dirty,
+			  unsigned long bdi_thresh);
+static inline void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+					      unsigned long start_time)
+{
+	bdi_update_bandwidth(bdi, start_time, 0, 0);
+}
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
--- linux-writeback.orig/mm/filemap.c	2011-01-20 21:21:34.000000000 +0800
+++ linux-writeback/mm/filemap.c	2011-01-20 21:33:14.000000000 +0800
@@ -2253,6 +2253,7 @@ static ssize_t generic_perform_write(str
 	long status = 0;
 	ssize_t written = 0;
 	unsigned int flags = 0;
+	unsigned int dirty;
 
 	/*
 	 * Copies from kernel address space cannot fail (NFSD is a big user).
@@ -2301,6 +2302,7 @@ again:
 		pagefault_enable();
 		flush_dcache_page(page);
 
+		dirty = PageDirty(page);
 		mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
@@ -2327,7 +2329,8 @@ again:
 		pos += copied;
 		written += copied;
 
-		balance_dirty_pages_ratelimited(mapping);
+		if (!dirty)
+			balance_dirty_pages_ratelimited(mapping);
 
 	} while (iov_iter_count(i));
 
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-writeback/Documentation/filesystems/writeback-throttling-design.txt	2011-01-20 21:33:14.000000000 +0800
@@ -0,0 +1,210 @@
+writeback throttling design
+---------------------------
+
+introduction to dirty throttling
+--------------------------------
+
+The write(2) is normally buffered write that creates dirty page cache pages
+for holding the data and return immediately. The dirty pages will eventually
+be written to disk, or be dropped by unlink()/truncate().
+
+The delayed writeback of dirty pages enables the kernel to optimize the IO:
+
+- turn IO into async ones, which avoids blocking the tasks
+- submit IO as a batch for better throughput
+- avoid IO at all for temp files
+
+However, there have to be some limits on the number of allowable dirty pages.
+Typically applications are able to dirty pages more quickly than storage
+devices can write them. When approaching the dirty limits, the dirtier tasks
+will be throttled (put to brief sleeps from time to time) by
+balance_dirty_pages() in order to balance the dirty speed and writeback speed.
+
+dirty limits
+------------
+
+The dirty limit defaults to 20% reclaimable memory, and can be tuned via one of
+the following sysctl interfaces:
+
+	/proc/sys/vm/dirty_ratio
+	/proc/sys/vm/dirty_bytes
+
+The ultimate goal of balance_dirty_pages() is to keep the global dirty pages
+under control.
+
+	dirty_limit = dirty_ratio * free_reclaimable_pages
+
+However a global threshold may create deadlock for stacked BDIs (loop, FUSE and
+local NFS mounts). When A writes to B, and A generates enough dirty pages to
+get throttled, B will never start writeback until the dirty pages go away.
+
+Another problem is inter device starvation. When there are concurrent writes to
+a slow device and a fast one, the latter may well be starved due to unnecessary
+throttling on its dirtier tasks, leading to big IO performance drop.
+
+The solution is to split the global dirty limit into per-bdi limits among all
+the backing devices and scale writeback cache per backing device, proportional
+to its writeout speed.
+
+	bdi_dirty_limit = bdi_weight * dirty_limit
+
+where bdi_weight (ranging from 0 to 1) reflects the recent writeout speed of
+the BDI.
+
+We further scale the bdi dirty limit inversly with the task's dirty rate.
+This makes heavy writers have a lower dirty limit than the occasional writer,
+to prevent a heavy dd from slowing down all other light writers in the system.
+
+	task_dirty_limit = bdi_dirty_limit - task_weight * bdi_dirty_limit/16
+
+pause time
+----------
+
+The main task of dirty throttling is to determine when and how long to pause
+the current dirtier task.  Basically we want to
+
+- avoid too small pause time (less than 1 jiffy, which burns CPU power)
+- avoid too large pause time (more than 200ms, which hurts responsiveness)
+- avoid big fluctuations of pause times
+
+To smoothly control the pause time, we do soft throttling in a small region
+under task_dirty_limit, starting from
+
+	task_throttle_thresh = task_dirty_limit - task_dirty_limit/16
+
+In fig.1, when bdi_dirty_pages falls into
+
+    [0, La]:    do nothing
+    [La, A]:    do soft throttling
+    [A, inf]:   do hard throttling
+
+Where hard throttling is to wait until bdi_dirty_pages falls more than
+task_dirtied_pages (the pages dirtied by the task since its last throttle
+time). It's "hard" because it may end up waiting for long time.
+
+Fig.1 dirty throttling regions
+                                              o
+                                                o
+                                                  o
+                                                    o
+                                                      o
+                                                        o
+                                                          o
+                                                            o
+----------------------------------------------+---------------o----------------|
+                                              La              A                T
+                no throttle                     soft throttle   hard throttle
+  T: bdi_dirty_limit
+  A: task_dirty_limit      = T - task_weight * T/16
+  La: task_throttle_thresh = A - A/16
+
+Soft dirty throttling is to pause the dirtier task for J:pause_time jiffies on
+every N:task_dirtied_pages pages it dirtied.  Let's call (N/J) the "throttle
+bandwidth". It is computed by the following formula:
+
+                                     task_dirty_limit - bdi_dirty_pages
+throttle_bandwidth = bdi_bandwidth * ----------------------------------
+                                           task_dirty_limit/16
+
+where bdi_bandwidth is the BDI's estimated write speed.
+
+Given the throttle_bandwidth for a task, we select a suitable N, so that when
+the task dirties so much pages, it enters balance_dirty_pages() to sleep for
+roughly J jiffies. N is adaptive to storage and task write speeds, so that the
+task always get suitable (not too long or small) pause time.
+
+dynamics
+--------
+
+When there is one heavy dirtier, bdi_dirty_pages will keep growing until
+exceeding the low threshold of the task's soft throttling region [La, A].
+At which point (La) the task will be controlled under speed
+throttle_bandwidth=bdi_bandwidth (fig.2) and remain stable there.
+
+Fig.2 one heavy dirtier
+
+    throttle_bandwidth ~= bdi_bandwidth  =>   o
+                                              | o
+                                              |   o
+                                              |     o
+                                              |       o
+                                              |         o
+                                              |           o
+                                            La|             o
+----------------------------------------------+---------------o----------------|
+                                              R               A                T
+  R: bdi_dirty_pages ~= La
+
+When there comes a new dd task B, task_weight_B will gradually grow from 0 to
+50% while task_weight_A will decrease from 100% to 50%.  When task_weight_B is
+still small, B is considered a light dirtier and is allowed to dirty pages much
+faster than the bdi write bandwidth. In fact initially it won't be throttled at
+all when R < Lb where Lb = B - B/16 and B ~= T.
+
+Fig.3 an old dd (A) + a newly started dd (B)
+
+                      throttle bandwidth  =>    *
+                                                | *
+                                                |   *
+                                                |     *
+                                                |       *
+                                                |         *
+                                                |           *
+                                                |             *
+                      throttle bandwidth  =>    o               *
+                                                | o               *
+                                                |   o               *
+                                                |     o               *
+                                                |       o               *
+                                                |         o               *
+                                                |           o               *
+------------------------------------------------+-------------o---------------*|
+                                                R             A               BT
+
+So R:bdi_dirty_pages will grow large. As task_weight_A and task_weight_B
+converge to 50%, the points A, B will go towards each other (fig.4) and
+eventually coincide with each other. R will stabilize around A-A/32 where
+A=B=T-0.5*T/16.  throttle_bandwidth will stabilize around bdi_bandwidth/2.
+
+Note that the application "think+dirty time" is ignored for simplicity in the
+above discussions. With non-zero user space think time, the balance point will
+slightly drift and not a big deal otherwise.
+
+Fig.4 the two dd's converging to the same bandwidth
+
+                                                         |
+                                 throttle bandwidth  =>  *
+                                                         | *
+                                 throttle bandwidth  =>  o   *
+                                                         | o   *
+                                                         |   o   *
+                                                         |     o   *
+                                                         |       o   *
+                                                         |         o   *
+---------------------------------------------------------+-----------o---*-----|
+                                                         R           A   B     T
+
+There won't be big oscillations between A and B, because as soon as A coincides
+with B, their throttle_bandwidth and hence dirty speed will be equal, A's
+weight will stop decreasing and B's weight will stop growing, so the two points
+won't keep moving and cross each other.
+
+Sure there are always oscillations of bdi_dirty_pages as long as the dirtier
+task alternatively do dirty and pause. But it will be bounded. When there is 1
+heavy dirtier, the error bound will be (pause_time * bdi_bandwidth). When there
+are 2 heavy dirtiers, the max error is 2 * (pause_time * bdi_bandwidth/2),
+which remains the same as 1 dirtier case (given the same pause time). In fact
+the more dirtier tasks, the less errors will be, since the dirtier tasks are
+not likely going to sleep at the same time.
+
+References
+----------
+
+Smarter write throttling
+http://lwn.net/Articles/245600/
+
+Flushing out pdflush
+http://lwn.net/Articles/326552/
+
+Dirty throttling slides
+http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling.pdf
--- linux-writeback.orig/include/linux/sched.h	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/include/linux/sched.h	2011-01-20 21:33:14.000000000 +0800
@@ -1487,6 +1487,14 @@ struct task_struct {
 	int make_it_fail;
 #endif
 	struct prop_local_single dirties;
+	/*
+	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
+	 * balance_dirty_pages() for some dirty throttling pause
+	 */
+	int nr_dirtied;
+	int nr_dirtied_pause;
+	unsigned long paused_when;	/* start of a write-and-pause period */
+
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
 	struct latency_record latency_record[LT_SAVECOUNT];
--- linux-writeback.orig/mm/memory_hotplug.c	2011-01-20 21:21:34.000000000 +0800
+++ linux-writeback/mm/memory_hotplug.c	2011-01-20 21:33:14.000000000 +0800
@@ -468,8 +468,6 @@ int online_pages(unsigned long pfn, unsi
 
 	vm_total_pages = nr_free_pagecache_pages();
 
-	writeback_set_ratelimit();
-
 	if (onlined_pages)
 		memory_notify(MEM_ONLINE, &arg);
 	unlock_memory_hotplug();
@@ -901,7 +899,6 @@ repeat:
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
-	writeback_set_ratelimit();
 
 	memory_notify(MEM_OFFLINE, &arg);
 	unlock_memory_hotplug();
--- linux-writeback.orig/include/linux/backing-dev.h	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/include/linux/backing-dev.h	2011-01-20 21:33:14.000000000 +0800
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
 
@@ -73,6 +74,14 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
+	spinlock_t bw_lock;
+	unsigned long bw_time_stamp;
+	unsigned long written_stamp;
+	unsigned long write_bandwidth;
+	unsigned long throttle_bandwidth;
+	unsigned long avg_dirty;
+	unsigned long old_dirty;
+
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
--- linux-writeback.orig/include/trace/events/writeback.h	2011-01-20 21:21:34.000000000 +0800
+++ linux-writeback/include/trace/events/writeback.h	2011-01-20 21:33:25.000000000 +0800
@@ -10,6 +10,19 @@
 
 struct wb_writeback_work;
 
+#define show_inode_state(state)					\
+	__print_flags(state, "|",				\
+		{I_DIRTY_SYNC,		"I_DIRTY_SYNC"},	\
+		{I_DIRTY_DATASYNC,	"I_DIRTY_DATASYNC"},	\
+		{I_DIRTY_PAGES,		"I_DIRTY_PAGES"},	\
+		{I_NEW,			"I_NEW"},		\
+		{I_WILL_FREE,		"I_WILL_FREE"},		\
+		{I_FREEING,		"I_FREEING"},		\
+		{I_CLEAR,		"I_CLEAR"},		\
+		{I_SYNC,		"I_SYNC"},		\
+		{I_REFERENCED,		"I_REFERENCED"}		\
+		)
+
 DECLARE_EVENT_CLASS(writeback_work_class,
 	TP_PROTO(struct backing_dev_info *bdi, struct wb_writeback_work *work),
 	TP_ARGS(bdi, work),
@@ -147,11 +160,187 @@ DEFINE_EVENT(wbc_class, name, \
 DEFINE_WBC_EVENT(wbc_writeback_start);
 DEFINE_WBC_EVENT(wbc_writeback_written);
 DEFINE_WBC_EVENT(wbc_writeback_wait);
-DEFINE_WBC_EVENT(wbc_balance_dirty_start);
-DEFINE_WBC_EVENT(wbc_balance_dirty_written);
-DEFINE_WBC_EVENT(wbc_balance_dirty_wait);
 DEFINE_WBC_EVENT(wbc_writepage);
 
+TRACE_EVENT(writeback_single_inode,
+
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 unsigned long wrote
+	),
+
+	TP_ARGS(inode, wbc, wrote),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, ino)
+		__field(unsigned long, state)
+		__field(unsigned long, age)
+		__field(unsigned long, wrote)
+		__field(long, nr_to_write)
+		__field(unsigned long, writeback_index)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->state		= inode->i_state;
+		__entry->age		= (jiffies - inode->dirtied_when) *
+								1000 / HZ;
+		__entry->wrote		= wrote;
+		__entry->nr_to_write	= wbc->nr_to_write;
+		__entry->writeback_index = inode->i_mapping->writeback_index;
+	),
+
+	TP_printk("bdi %s: ino=%lu state=%s age=%lu "
+		  "wrote=%lu to_write=%ld index=%lu",
+		  __entry->name,
+		  __entry->ino,
+		  show_inode_state(__entry->state),
+		  __entry->age,
+		  __entry->wrote,
+		  __entry->nr_to_write,
+		  __entry->writeback_index
+	)
+);
+
+TRACE_EVENT(global_dirty_state,
+
+	TP_PROTO(unsigned long background_thresh,
+		 unsigned long dirty_thresh
+	),
+
+	TP_ARGS(background_thresh,
+		dirty_thresh
+	),
+
+	TP_STRUCT__entry(
+		__field(unsigned long,	nr_dirty)
+		__field(unsigned long,	nr_writeback)
+		__field(unsigned long,	nr_unstable)
+		__field(unsigned long,	background_thresh)
+		__field(unsigned long,	dirty_thresh)
+		__field(unsigned long,	poll_thresh)
+		__field(unsigned long,	nr_dirtied)
+		__field(unsigned long,	nr_written)
+	),
+
+	TP_fast_assign(
+		__entry->nr_dirty	= global_page_state(NR_FILE_DIRTY);
+		__entry->nr_writeback	= global_page_state(NR_WRITEBACK);
+		__entry->nr_unstable	= global_page_state(NR_UNSTABLE_NFS);
+		__entry->nr_dirtied	= global_page_state(NR_DIRTIED);
+		__entry->nr_written	= global_page_state(NR_WRITTEN);
+		__entry->background_thresh	= background_thresh;
+		__entry->dirty_thresh		= dirty_thresh;
+		__entry->poll_thresh		= current->nr_dirtied_pause;
+	),
+
+	TP_printk("dirty=%lu writeback=%lu unstable=%lu "
+		  "bg_thresh=%lu thresh=%lu gap=%ld poll=%ld "
+		  "dirtied=%lu written=%lu",
+		  __entry->nr_dirty,
+		  __entry->nr_writeback,
+		  __entry->nr_unstable,
+		  __entry->background_thresh,
+		  __entry->dirty_thresh,
+		  __entry->dirty_thresh - __entry->nr_dirty -
+		  __entry->nr_writeback - __entry->nr_unstable,
+		  __entry->poll_thresh,
+		  __entry->nr_dirtied,
+		  __entry->nr_written
+	)
+);
+
+#define KBps(x)			((x) << (PAGE_SHIFT - 10))
+#define BDP_PERCENT(a, b, c)	(((__entry->a) - (__entry->b)) * 100 * (c) + \
+				  __entry->bdi_limit/2) / (__entry->bdi_limit|1)
+
+TRACE_EVENT(balance_dirty_pages,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 long bdi_dirty,
+		 long avg_dirty,
+		 long bdi_limit,
+		 long task_limit,
+		 long dirtied,
+		 long task_bw,
+		 long period,
+		 long pause,
+		 unsigned long start_time),
+
+	TP_ARGS(bdi, bdi_dirty, avg_dirty, bdi_limit, task_limit,
+		dirtied, task_bw, period, pause, start_time),
+
+	TP_STRUCT__entry(
+		__array(char,	bdi, 32)
+		__field(long,	bdi_dirty)
+		__field(long,	avg_dirty)
+		__field(long,	bdi_limit)
+		__field(long,	task_limit)
+		__field(long,	dirtied)
+		__field(long,	bdi_bw)
+		__field(long,	base_bw)
+		__field(long,	task_bw)
+		__field(long,	period)
+		__field(long,	think)
+		__field(long,	pause)
+		__field(long,	paused)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->bdi_dirty	= bdi_dirty;
+		__entry->avg_dirty	= avg_dirty;
+		__entry->bdi_limit	= bdi_limit;
+		__entry->task_limit	= task_limit;
+		__entry->dirtied	= dirtied;
+		__entry->bdi_bw		= KBps(bdi->write_bandwidth);
+		__entry->base_bw	= KBps(bdi->throttle_bandwidth);
+		__entry->task_bw	= KBps(task_bw);
+		__entry->think		= current->paused_when == 0 ? 0 :
+			 (long)(jiffies - current->paused_when) * 1000 / HZ;
+		__entry->period		= period * 1000 / HZ;
+		__entry->pause		= pause * 1000 / HZ;
+		__entry->paused		= (jiffies - start_time) * 1000 / HZ;
+	),
+
+
+	/*
+	 *            [..............soft throttling range............]
+	 *            ^               |<=========== bdi_gap =========>|
+	 * (background+dirty)/2       |<== task_gap ==>|
+	 * -------------------|-------+----------------|--------------|
+	 *   (bdi_limit * 7/8)^       ^bdi_dirty       ^task_limit    ^bdi_limit
+	 *
+	 * Reasonable large gaps help produce smooth pause times.
+	 */
+	TP_printk("bdi %s: "
+		  "bdi_limit=%lu task_limit=%lu bdi_dirty=%lu avg_dirty=%lu "
+		  "bdi_gap=%ld%% task_gap=%ld%% task_weight=%ld%% "
+		  "bdi_bw=%lu base_bw=%lu task_bw=%lu "
+		  "dirtied=%lu period=%lu think=%ld pause=%ld paused=%lu",
+		  __entry->bdi,
+		  __entry->bdi_limit,
+		  __entry->task_limit,
+		  __entry->bdi_dirty,
+		  __entry->avg_dirty,
+		  BDP_PERCENT(bdi_limit, bdi_dirty, BDI_SOFT_DIRTY_LIMIT),
+		  BDP_PERCENT(task_limit, avg_dirty, TASK_SOFT_DIRTY_LIMIT),
+		  /* task weight: proportion of recent dirtied pages */
+		  BDP_PERCENT(bdi_limit, task_limit, TASK_SOFT_DIRTY_LIMIT),
+		  __entry->bdi_bw,	/* bdi write bandwidth */
+		  __entry->base_bw,	/* bdi base throttle bandwidth */
+		  __entry->task_bw,	/* task throttle bandwidth */
+		  __entry->dirtied,
+		  __entry->period,	/* ms */
+		  __entry->think,	/* ms */
+		  __entry->pause,	/* ms */
+		  __entry->paused	/* ms */
+		  )
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
--- linux-writeback.orig/fs/btrfs/file.c	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/fs/btrfs/file.c	2011-01-20 21:33:14.000000000 +0800
@@ -769,7 +769,8 @@ out:
 static noinline int prepare_pages(struct btrfs_root *root, struct file *file,
 			 struct page **pages, size_t num_pages,
 			 loff_t pos, unsigned long first_index,
-			 unsigned long last_index, size_t write_bytes)
+			 unsigned long last_index, size_t write_bytes,
+			 int *nr_dirtied)
 {
 	struct extent_state *cached_state = NULL;
 	int i;
@@ -832,7 +833,8 @@ again:
 				     GFP_NOFS);
 	}
 	for (i = 0; i < num_pages; i++) {
-		clear_page_dirty_for_io(pages[i]);
+		if (!clear_page_dirty_for_io(pages[i]))
+			(*nr_dirtied)++;
 		set_page_extent_mapped(pages[i]);
 		WARN_ON(!PageLocked(pages[i]));
 	}
@@ -942,9 +944,8 @@ static ssize_t btrfs_file_aio_write(stru
 	}
 
 	iov_iter_init(&i, iov, nr_segs, count, num_written);
-	nrptrs = min((iov_iter_count(&i) + PAGE_CACHE_SIZE - 1) /
-		     PAGE_CACHE_SIZE, PAGE_CACHE_SIZE /
-		     (sizeof(struct page *)));
+	nrptrs = min(DIV_ROUND_UP(iov_iter_count(&i), PAGE_CACHE_SIZE),
+		     min(16UL, PAGE_CACHE_SIZE / (sizeof(struct page *))));
 	pages = kmalloc(nrptrs * sizeof(struct page *), GFP_KERNEL);
 
 	/* generic_write_checks can change our pos */
@@ -986,6 +987,7 @@ static ssize_t btrfs_file_aio_write(stru
 					 offset);
 		size_t num_pages = (write_bytes + PAGE_CACHE_SIZE - 1) >>
 					PAGE_CACHE_SHIFT;
+		int nr_dirtied = 0;
 
 		WARN_ON(num_pages > nrptrs);
 		memset(pages, 0, sizeof(struct page *) * nrptrs);
@@ -1006,7 +1008,7 @@ static ssize_t btrfs_file_aio_write(stru
 
 		ret = prepare_pages(root, file, pages, num_pages,
 				    pos, first_index, last_index,
-				    write_bytes);
+				    write_bytes, &nr_dirtied);
 		if (ret) {
 			btrfs_delalloc_release_space(inode,
 					num_pages << PAGE_CACHE_SHIFT);
@@ -1041,7 +1043,7 @@ static ssize_t btrfs_file_aio_write(stru
 			} else {
 				balance_dirty_pages_ratelimited_nr(
 							inode->i_mapping,
-							dirty_pages);
+							nr_dirtied);
 				if (dirty_pages <
 				(root->leafsize >> PAGE_CACHE_SHIFT) + 1)
 					btrfs_btree_balance_dirty(root, 1);
--- linux-writeback.orig/fs/btrfs/ioctl.c	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/fs/btrfs/ioctl.c	2011-01-20 21:33:14.000000000 +0800
@@ -654,6 +654,7 @@ static int btrfs_defrag_file(struct file
 	u64 skip = 0;
 	u64 defrag_end = 0;
 	unsigned long i;
+	int dirtied;
 	int ret;
 	int compress_type = BTRFS_COMPRESS_ZLIB;
 
@@ -766,7 +767,7 @@ again:
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
 		ClearPageChecked(page);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 		unlock_extent(io_tree, page_start, page_end, GFP_NOFS);
 
 loop_unlock:
@@ -774,7 +775,8 @@ loop_unlock:
 		page_cache_release(page);
 		mutex_unlock(&inode->i_mutex);
 
-		balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
+		if (dirtied)
+			balance_dirty_pages_ratelimited_nr(inode->i_mapping, 1);
 		i++;
 	}
 
--- linux-writeback.orig/fs/btrfs/relocation.c	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/fs/btrfs/relocation.c	2011-01-20 21:33:14.000000000 +0800
@@ -2894,6 +2894,7 @@ static int relocate_file_extent_cluster(
 	struct file_ra_state *ra;
 	int nr = 0;
 	int ret = 0;
+	int dirtied;
 
 	if (!cluster->nr)
 		return 0;
@@ -2970,7 +2971,7 @@ static int relocate_file_extent_cluster(
 		}
 
 		btrfs_set_extent_delalloc(inode, page_start, page_end, NULL);
-		set_page_dirty(page);
+		dirtied = set_page_dirty(page);
 
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end, GFP_NOFS);
@@ -2978,7 +2979,8 @@ static int relocate_file_extent_cluster(
 		page_cache_release(page);
 
 		index++;
-		balance_dirty_pages_ratelimited(inode->i_mapping);
+		if (dirtied)
+			balance_dirty_pages_ratelimited(inode->i_mapping);
 		btrfs_throttle(BTRFS_I(inode)->root);
 	}
 	WARN_ON(nr != cluster->nr);
--- linux-writeback.orig/fs/btrfs/disk-io.c	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/fs/btrfs/disk-io.c	2011-01-20 21:33:14.000000000 +0800
@@ -612,6 +612,7 @@ int btrfs_wq_submit_bio(struct btrfs_fs_
 			extent_submit_bio_hook_t *submit_bio_done)
 {
 	struct async_submit_bio *async;
+	int limit;
 
 	async = kmalloc(sizeof(*async), GFP_NOFS);
 	if (!async)
@@ -639,6 +640,12 @@ int btrfs_wq_submit_bio(struct btrfs_fs_
 
 	btrfs_queue_worker(&fs_info->workers, &async->work);
 
+	limit = btrfs_async_submit_limit(fs_info);
+
+	if (atomic_read(&fs_info->nr_async_bios) > limit)
+		wait_event(fs_info->async_submit_wait,
+			   (atomic_read(&fs_info->nr_async_bios) < limit));
+
 	while (atomic_read(&fs_info->async_submit_draining) &&
 	      atomic_read(&fs_info->nr_async_submits)) {
 		wait_event(fs_info->async_submit_wait,
--- linux-writeback.orig/fs/nfs/file.c	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/fs/nfs/file.c	2011-01-20 21:33:17.000000000 +0800
@@ -392,15 +392,6 @@ static int nfs_write_begin(struct file *
 			   IOMODE_RW);
 
 start:
-	/*
-	 * Prevent starvation issues if someone is doing a consistency
-	 * sync-to-disk
-	 */
-	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (ret)
-		return ret;
-
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
--- linux-writeback.orig/fs/nfs/write.c	2011-01-20 21:20:20.000000000 +0800
+++ linux-writeback/fs/nfs/write.c	2011-01-20 21:33:25.000000000 +0800
@@ -29,6 +29,9 @@
 #include "nfs4_fs.h"
 #include "fscache.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/nfs.h>
+
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 #define MIN_POOL_WRITE		(32)
@@ -185,11 +188,68 @@ static int wb_priority(struct writeback_
  * NFS congestion control
  */
 
+#define NFS_WAIT_PAGES	(1024L >> (PAGE_SHIFT - 10))
 int nfs_congestion_kb;
 
-#define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
-#define NFS_CONGESTION_OFF_THRESH	\
-	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
+/*
+ * SYNC requests will block on (2*limit) and wakeup on (2*limit-NFS_WAIT_PAGES)
+ * ASYNC requests will block on (limit) and wakeup on (limit - NFS_WAIT_PAGES)
+ * In this way SYNC writes will never be blocked by ASYNC ones.
+ */
+
+static void nfs_set_congested(long nr, struct backing_dev_info *bdi)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr > limit && !test_bit(BDI_async_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_ASYNC);
+	else if (nr > 2 * limit && !test_bit(BDI_sync_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_SYNC);
+}
+
+static void nfs_wait_contested(int is_sync,
+			       struct backing_dev_info *bdi,
+			       wait_queue_head_t *wqh)
+{
+	int waitbit = is_sync ? BDI_sync_congested : BDI_async_congested;
+	DEFINE_WAIT(wait);
+
+	if (!test_bit(waitbit, &bdi->state))
+		return;
+
+	for (;;) {
+		prepare_to_wait(&wqh[is_sync], &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(waitbit, &bdi->state))
+			break;
+
+		io_schedule();
+	}
+	finish_wait(&wqh[is_sync], &wait);
+}
+
+static void nfs_wakeup_congested(long nr,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_sync_congested, &bdi->state)) {
+			clear_bdi_congested(bdi, BLK_RW_SYNC);
+			smp_mb__after_clear_bit();
+		}
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+	}
+	if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_async_congested, &bdi->state)) {
+			clear_bdi_congested(bdi, BLK_RW_ASYNC);
+			smp_mb__after_clear_bit();
+		}
+		if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
+			wake_up(&wqh[BLK_RW_ASYNC]);
+	}
+}
 
 static int nfs_set_page_writeback(struct page *page)
 {
@@ -200,11 +260,8 @@ static int nfs_set_page_writeback(struct
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+		nfs_set_congested(atomic_long_inc_return(&nfss->writeback),
+				  &nfss->backing_dev_info);
 	}
 	return ret;
 }
@@ -216,8 +273,10 @@ static void nfs_end_page_writeback(struc
 
 	end_page_writeback(page);
 	page_cache_release(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_wakeup_congested(atomic_long_dec_return(&nfss->writeback),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
@@ -318,45 +377,49 @@ static int nfs_writepage_locked(struct p
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
+
+	nfs_wait_contested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
-static int nfs_writepages_callback(struct page *page, struct writeback_control *wbc, void *data)
+static int nfs_writepages_callback(struct page *page,
+				   struct writeback_control *wbc, void *data)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_do_writepage(page, wbc, data);
 	unlock_page(page);
+
+	nfs_wait_contested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	/* Stop dirtying of new pages while we sync */
-	err = wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (err)
-		goto out_err;
-
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
-	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
-	smp_mb__after_clear_bit();
-	wake_up_bit(bitlock, NFS_INO_FLUSHING);
-
 	if (err < 0)
 		goto out_err;
 	err = pgio.pg_error;
@@ -1244,7 +1307,7 @@ static void nfs_commitdata_release(void 
  */
 static int nfs_commit_rpcsetup(struct list_head *head,
 		struct nfs_write_data *data,
-		int how)
+		int how, pgoff_t offset, pgoff_t count)
 {
 	struct nfs_page *first = nfs_list_entry(head->next);
 	struct inode *inode = first->wb_context->path.dentry->d_inode;
@@ -1276,8 +1339,8 @@ static int nfs_commit_rpcsetup(struct li
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
-	data->args.offset = 0;
-	data->args.count  = 0;
+	data->args.offset = offset;
+	data->args.count  = count;
 	data->args.context = get_nfs_open_context(first->wb_context);
 	data->res.count   = 0;
 	data->res.fattr   = &data->fattr;
@@ -1300,7 +1363,8 @@ static int nfs_commit_rpcsetup(struct li
  * Commit dirty pages
  */
 static int
-nfs_commit_list(struct inode *inode, struct list_head *head, int how)
+nfs_commit_list(struct inode *inode, struct list_head *head, int how,
+		pgoff_t offset, pgoff_t count)
 {
 	struct nfs_write_data	*data;
 	struct nfs_page         *req;
@@ -1311,7 +1375,7 @@ nfs_commit_list(struct inode *inode, str
 		goto out_bad;
 
 	/* Set up the argument struct */
-	return nfs_commit_rpcsetup(head, data, how);
+	return nfs_commit_rpcsetup(head, data, how, offset, count);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -1379,6 +1443,9 @@ static void nfs_commit_release(void *cal
 		nfs_clear_page_tag_locked(req);
 	}
 	nfs_commit_clear_lock(NFS_I(data->inode));
+	trace_nfs_commit_release(data->inode,
+				 data->args.offset,
+				 data->args.count);
 	nfs_commitdata_release(calldata);
 }
 
@@ -1393,6 +1460,8 @@ static const struct rpc_call_ops nfs_com
 int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
+	pgoff_t first_index;
+	pgoff_t last_index;
 	int may_wait = how & FLUSH_SYNC;
 	int res = 0;
 
@@ -1400,9 +1469,14 @@ int nfs_commit_inode(struct inode *inode
 		goto out_mark_dirty;
 	spin_lock(&inode->i_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
+	if (res) {
+		first_index = nfs_list_entry(head.next)->wb_index;
+		last_index  = nfs_list_entry(head.prev)->wb_index;
+	}
 	spin_unlock(&inode->i_lock);
 	if (res) {
-		int error = nfs_commit_list(inode, &head, how);
+		int error = nfs_commit_list(inode, &head, how, first_index,
+					    last_index - first_index + 1);
 		if (error < 0)
 			return error;
 		if (may_wait)
@@ -1432,9 +1506,10 @@ static int nfs_commit_unstable_pages(str
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there
-		 * are a lot of outstanding writes for this mapping.
+		 * are a lot of outstanding writes for this mapping, until
+		 * collected enough pages to commit.
 		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (nfsi->ncommit <= nfsi->npages / TASK_SOFT_DIRTY_LIMIT)
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */
@@ -1443,17 +1518,15 @@ static int nfs_commit_unstable_pages(str
 
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0) {
-		if (wbc->sync_mode == WB_SYNC_NONE) {
-			if (ret < wbc->nr_to_write)
-				wbc->nr_to_write -= ret;
-			else
-				wbc->nr_to_write = 0;
-		}
-		return 0;
+		wbc->nr_to_write -= ret;
+		goto out;
 	}
+
 out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-	return ret;
+out:
+	trace_nfs_commit_unstable_pages(inode, wbc, flags, ret);
+	return ret >= 0 ? 0 : ret;
 }
 #else
 static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
@@ -1582,6 +1655,9 @@ out:
 
 int __init nfs_init_writepagecache(void)
 {
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1619,6 +1695,16 @@ int __init nfs_init_writepagecache(void)
 	if (nfs_congestion_kb > 256*1024)
 		nfs_congestion_kb = 256*1024;
 
+	/*
+	 * Limit to 1/8 dirty threshold, so that writeback+in_commit pages
+	 * won't overnumber dirty+to_commit pages.
+	 */
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	dirty_thresh <<= PAGE_SHIFT - 10;
+
+	if (nfs_congestion_kb > dirty_thresh / 8)
+		nfs_congestion_kb = dirty_thresh / 8;
+
 	return 0;
 }
 
--- linux-writeback.orig/include/linux/nfs_fs.h	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/include/linux/nfs_fs.h	2011-01-20 21:33:22.000000000 +0800
@@ -215,7 +215,6 @@ struct nfs_inode {
 #define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
-#define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
--- linux-writeback.orig/include/linux/nfs_fs_sb.h	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/include/linux/nfs_fs_sb.h	2011-01-20 21:33:24.000000000 +0800
@@ -102,6 +102,7 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-writeback.orig/fs/nfs/client.c	2011-01-20 21:21:33.000000000 +0800
+++ linux-writeback/fs/nfs/client.c	2011-01-20 21:33:24.000000000 +0800
@@ -1042,6 +1042,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->delegations);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-writeback/include/trace/events/nfs.h	2011-01-20 21:33:25.000000000 +0800
@@ -0,0 +1,88 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM nfs
+
+#if !defined(_TRACE_NFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NFS_H
+
+#include <linux/nfs_fs.h>
+
+
+TRACE_EVENT(nfs_commit_unstable_pages,
+
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 int sync,
+		 int ret
+	),
+
+	TP_ARGS(inode, wbc, sync, ret),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long,	ino)
+		__field(unsigned long,	npages)
+		__field(unsigned long,	to_commit)
+		__field(unsigned long,	write_chunk)
+		__field(int,		sync)
+		__field(int,		ret)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->npages		= NFS_I(inode)->npages;
+		__entry->to_commit	= NFS_I(inode)->ncommit;
+		__entry->write_chunk	= wbc->per_file_limit;
+		__entry->sync		= sync;
+		__entry->ret		= ret;
+	),
+
+	TP_printk("bdi %s: ino=%lu npages=%ld tocommit=%lu "
+		  "write_chunk=%lu sync=%d ret=%d",
+		  __entry->name,
+		  __entry->ino,
+		  __entry->npages,
+		  __entry->to_commit,
+		  __entry->write_chunk,
+		  __entry->sync,
+		  __entry->ret
+	)
+);
+
+TRACE_EVENT(nfs_commit_release,
+
+	TP_PROTO(struct inode *inode,
+		 unsigned long offset,
+		 unsigned long len),
+
+	TP_ARGS(inode, offset, len),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long,	ino)
+		__field(unsigned long,	offset)
+		__field(unsigned long,	len)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->offset		= offset;
+		__entry->len		= len;
+	),
+
+	TP_printk("bdi %s: ino=%lu offset=%lu len=%lu",
+		  __entry->name,
+		  __entry->ino,
+		  __entry->offset,
+		  __entry->len
+	)
+);
+
+
+#endif /* _TRACE_NFS_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
