Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 65E818D004D
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:58 -0500 (EST)
Message-Id: <20110303074951.143474038@intel.com>
Date: Thu, 03 Mar 2011 14:45:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 19/27] writeback: dirty throttle bandwidth control
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-control-algorithms.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

balance_dirty_pages() has been using a very simple and robust threshold
based throttle scheme. It automatically limits the dirty rate down,
however in a very bumpy way that constantly block the dirtier tasks for
hundreds of milliseconds on a local ext4.

The new scheme is to expand the ON/OFF threshold to a larger scope in
which both the number of dirty pages and the dirty rate are explicitly
controlled. The basic ideas are

- position feedback control

  At the center of the control scope is the setpoint/goal. When the
  number of dirty pages go higher/lower than the goal, its dirty rate
  will be proportionally decreased/increased to prevent it from drifting
  away.

  When the dirty pages drops low to the bottom of the control scope, or
  rushes high to the upper limit, the dirty rate will quickly be scaled
  up/down, to the point of completely let go of or completely block the
  dirtier task.

- rate feedback control

  What's the balanced dirty rate if the dirty pages are exactly at the
  goal? If there are N tasks dirtying pages on 1 disk at rate task_bw MB/s,
  then task_bw should be balanced at write_bw/N where write_bw is the
  disk's write bandwidth. We call base_bw=write_bw/(N*sqrt(N)) the
  disk's base throttle bandwidth.  Each task will be allowed to dirty at
  rate task_bw=base_bw/sqrt(task_weight) where task_weight=1/N reflects
  how much dirty pages in the system are dirtied by the task. So the
  overall dirty rate dirty_bw=N*task_bw will match write_bw exactly.

  In practice we don't know base_bw beforehand. Because we don't know
  the exact number of N and cannot assume all tasks are equal weighted.
  So a reference bandwidth ref_bw is estimated as the target of base_bw.
  base_bw will be adjusted step by step towards ref_bw. In each step,
  ref_bw is calculated as (base_bw * pos_ratio * write_bw / dirty_bw):
  when the (unknown number of) tasks are rate limited based on previous
  (base_bw*pos_ratio*sqrt(task_weight)), if the overall dirty rate
  dirty_bw is M times write_bw, then the base_bw shall be scaled 1/M to
  match/balance dirty_bw <=> write_bw. Note that pos_ratio is the result
  of position control, it will be 1 if the dirty pages are exactly at
  the goal.

  The ref_bw estimation will be pretty accurate if without
  (1) noises
  (2) feedback delays between steps
  (3) the mismatch between the number of dirty and writeback events
      caused by user space truncate and file system redirty

  (1) can be smoothed out; (2) will decrease proportionally with the
  adjust size when base_bw gets close to ref_bw.

  (3) can be ultimitely fixed by accounting the truncate/redirty events.
  But for now we can rely on the robustness of base_bw update algorithms
  to deal with the mismatches: no obvious imbalance is observed in ext4
  workloads which have bursts of redirty and large dirtied:written=3:2
  ratio. In theory when the truncate/redirty makes (write_bw/dirty_bw <
  1), ref_bw and base_bw will go low, driving up the pos_ratio which
  then corrects (pos_ratio * write_bw / dirty_bw) back to 1, thus
  balance ref_bw at some point. What's more,
  bdi_update_throttle_bandwidth() dictates that base_bw will only be
  updated when ref_bw and pos_bw=base_bw*pos_ratio are both higher or
  lower than base_bw. So the higher pos_bw will effectively stop base_bw
  from approaching the lower ref_bw.

In general, it's pretty safe and robust.
- the upper/lower bounds in the position control provides ultimate
  safeguard: in case the algorithms fly away, the worst case would be
  the dirty pages continuously hitting the bounds with big fluctuates in
  dirty rate -- basically similiar to the current state.
- the base bandwidth update rules are accurate and robust enough for
  base_bw to quickly adapt to new workload and remain stable thereafter
  This is confirmed by a wide range of tests: base_bw only goes less
  stable when the control scope is smaller than the write bandwidth,
  in which case the pos_ratio is already fluctuating much more.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |   10 
 include/linux/writeback.h   |    7 
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |  478 ++++++++++++++++++++++++++++++++++
 4 files changed, 495 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:22.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:27.000000000 +0800
@@ -76,18 +76,26 @@ struct backing_dev_info {
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
 	unsigned long bw_time_stamp;
+	unsigned long dirtied_stamp;
 	unsigned long written_stamp;
 	unsigned long write_bandwidth;
 	unsigned long avg_bandwidth;
+	unsigned long long throttle_bandwidth;
+	unsigned long long reference_bandwidth;
+	unsigned long long old_ref_bandwidth;
 	unsigned long avg_dirty;
 	unsigned long old_dirty;
 	unsigned long dirty_threshold;
 	unsigned long old_dirty_threshold;
 
-
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
+	/* last time exceeded (limit - limit/DIRTY_MARGIN) */
+	unsigned long dirty_exceed_time;
+	/* last time dropped below (background_thresh + dirty_thresh) / 2 */
+	unsigned long dirty_free_run;
+
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
--- linux-next.orig/include/linux/writeback.h	2011-03-03 14:44:22.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-03-03 14:44:23.000000000 +0800
@@ -46,6 +46,13 @@ extern spinlock_t inode_lock;
 #define DIRTY_MARGIN		(DIRTY_SCOPE * 4)
 
 /*
+ * The base throttle bandwidth will be 1000 times smaller than write bandwidth
+ * when there are 100 concurrent heavy dirtiers. This shift can work with up to
+ * 40 bits dirty size and 2^16 concurrent dirtiers.
+ */
+#define BASE_BW_SHIFT		24
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:23.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:27.000000000 +0800
@@ -496,6 +496,255 @@ static unsigned long dirty_rampup_size(u
 	return MIN_WRITEBACK_PAGES / 8;
 }
 
+/*
+ * last time exceeded (limit - limit/DIRTY_MARGIN)
+ */
+static bool dirty_exceeded_recently(struct backing_dev_info *bdi,
+				    unsigned long time_window)
+{
+	return jiffies - bdi->dirty_exceed_time <= time_window;
+}
+
+/*
+ * last time dropped below (thresh - 2*thresh/DIRTY_SCOPE + thresh/DIRTY_MARGIN)
+ */
+static bool dirty_free_run_recently(struct backing_dev_info *bdi,
+				    unsigned long time_window)
+{
+	return jiffies - bdi->dirty_free_run <= time_window;
+}
+
+/*
+ * Position based bandwidth control.
+ *
+ * (1) hard dirty limiting areas
+ *
+ * The block area is required to stop large number of slow dirtiers, because
+ * the max pause area is only able to throttle a task at 1page/200ms=20KB/s.
+ *
+ * The max pause area is sufficient for normal workloads, and has the virtue
+ * of bounded latency for light dirtiers.
+ *
+ * The brake area is typically enough to hold off the dirtiers as long as the
+ * dirtyable memory is not so tight.
+ *
+ * The block area and max pause area are enforced inside the loop of
+ * balance_dirty_pages(). Others can be found in dirty_throttle_bandwidth().
+ *
+ *         block area,  loop until drop below the area  -------------------|<===
+ *     max pause area,  sleep(max_pause) and return     -----------|<=====>|
+ *         brake area,  bw scaled from 1 down to 0      ---|<=====>|
+ * --------------------------------------------------------o-------o-------o----
+ *                                                         ^       ^       ^
+ *                          limit - limit/DIRTY_MARGIN  ---'       |       |
+ *                          limit                       -----------'       |
+ *                          limit + limit/DIRTY_MARGIN  -------------------'
+ *
+ * (2) global control areas
+ *
+ * The rampup area is for ramping up the base bandwidth whereas the above brake
+ * area is for scaling down the base bandwidth.
+ *
+ * The global thresh is typically equal to the above global limit. The
+ * difference is, @thresh is real-time computed from global_dirty_limits() and
+ * @limit is tracking @thresh at 100ms intervals in update_dirty_limit(). The
+ * point is to track @thresh slowly if it dropped below the number of dirty
+ * pages, so as to avoid unnecessarily entering the three areas in (1).
+ *
+ *rampup area                 setpoint/goal
+ *|<=======>|                      v
+ * |-------------------------------*-------------------------------|------------
+ * ^                               ^                               ^
+ * thresh - 2*thresh/DIRTY_SCOPE   thresh - thresh/DIRTY_SCOPE     thresh
+ *
+ * (3) bdi control areas
+ *
+ * The bdi reserve area tries to keep a reasonable number of dirty pages for
+ * preventing block queue underrun.
+ *
+ * reserve area, scale up bw as dirty pages drop low  bdi_setpoint
+ * |<=============================================>|       v
+ * |-------------------------------------------------------*-------|----------
+ * 0                    bdi_thresh - bdi_thresh/DIRTY_SCOPE^       ^bdi_thresh
+ *
+ * (4) global/bdi control lines
+ *
+ * dirty_throttle_bandwidth() applies 2 main and 3 regional control lines for
+ * scaling up/down the base bandwidth based on the position of dirty pages.
+ *
+ * The two main control lines for the global/bdi control scopes do not end at
+ * thresh/bdi_thresh.  They are centered at setpoint/bdi_setpoint and cover the
+ * whole [0, limit].  If the control line drops below 0 before reaching @limit,
+ * an auxiliary line will be setup to connect them. The below figure illustrates
+ * the main bdi control line with an auxiliary line extending it to @limit.
+ *
+ * This allows smoothly throttling down bdi_dirty back to normal if it starts
+ * high in situations like
+ * - start writing to a slow SD card and a fast disk at the same time. The SD
+ *   card's bdi_dirty may rush to 5 times higher than bdi_setpoint.
+ * - the global/bdi dirty thresh/goal may be knocked down suddenly either on
+ *   user request or on increased memory consumption.
+ *
+ *   o
+ *     o
+ *       o                                      [o] main control line
+ *         o                                    [*] auxiliary control line
+ *           o
+ *             o
+ *               o
+ *                 o
+ *                   o
+ *                     o
+ *                       o--------------------- balance point, bw scale = 1
+ *                       | o
+ *                       |   o
+ *                       |     o
+ *                       |       o
+ *                       |         o
+ *                       |           o
+ *                       |             o------- connect point, bw scale = 1/2
+ *                       |               .*
+ *                       |                 .   *
+ *                       |                   .      *
+ *                       |                     .         *
+ *                       |                       .           *
+ *                       |                         .              *
+ *                       |                           .                 *
+ *  [--------------------*-----------------------------.--------------------*]
+ *  0                 bdi_setpoint                  bdi_origin           limit
+ *
+ * The bdi control line: if (bdi_origin < limit), an auxiliary control line (*)
+ * will be setup to extend the main control line (o) to @limit.
+ */
+static unsigned long dirty_throttle_bandwidth(struct backing_dev_info *bdi,
+					      unsigned long thresh,
+					      unsigned long dirty,
+					      unsigned long bdi_dirty,
+					      struct task_struct *tsk)
+{
+	unsigned long limit = default_backing_dev_info.dirty_threshold;
+	unsigned long bdi_thresh = bdi->dirty_threshold;
+	unsigned long origin;
+	unsigned long goal;
+	unsigned long long span;
+	unsigned long long bw;
+
+	if (unlikely(dirty >= limit))
+		return 0;
+
+	/*
+	 * global setpoint
+	 */
+	origin = 2 * thresh;
+	goal = thresh - thresh / DIRTY_SCOPE;
+
+	if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
+		origin = limit;
+		goal = (goal + origin) / 2;
+		bw >>= 1;
+	}
+	bw = origin - dirty;
+	bw <<= BASE_BW_SHIFT;
+	do_div(bw, origin - goal + 1);
+
+	/*
+	 * brake area to prevent global dirty exceeding
+	 */
+	if (dirty > limit - limit / DIRTY_MARGIN) {
+		bw *= limit - dirty;
+		do_div(bw, limit / DIRTY_MARGIN + 1);
+	}
+
+	/*
+	 * rampup area, immediately above the unthrottled free-run region.
+	 * It's setup mainly to get an estimation of ref_bw for reliably
+	 * ramping up the base bandwidth.
+	 */
+	dirty = default_backing_dev_info.avg_dirty;
+	origin = thresh - thresh / (DIRTY_SCOPE/2) + thresh / DIRTY_MARGIN;
+	if (dirty < origin) {
+		span = (origin - dirty) * bw;
+		do_div(span, thresh / (8 * DIRTY_MARGIN) + 1);
+		bw += span;
+	}
+
+	/*
+	 * bdi setpoint
+	 */
+	if (unlikely(bdi_thresh > thresh))
+		bdi_thresh = thresh;
+	goal = bdi_thresh - bdi_thresh / DIRTY_SCOPE;
+	/*
+	 * In JBOD case, bdi_thresh could fluctuate proportional to its own
+	 * size. Otherwise the bdi write bandwidth is good for limiting the
+	 * floating area, to compensate for the global control line being too
+	 * flat in large memory systems.
+	 */
+	span = (u64) bdi_thresh * (thresh - bdi_thresh) +
+		(2 * bdi->avg_bandwidth) * bdi_thresh;
+	do_div(span, thresh + 1);
+	origin = goal + 2 * span;
+
+	dirty = bdi->avg_dirty;
+	if (unlikely(dirty > goal + span)) {
+		if (dirty > limit)
+			return 0;
+		if (origin < limit) {
+			origin = limit;
+			goal += span;
+			bw >>= 1;
+		}
+	}
+	bw *= origin - dirty;
+	do_div(bw, origin - goal + 1);
+
+	/*
+	 * bdi reserve area, safeguard against bdi dirty underflow and disk idle
+	 */
+	origin = bdi_thresh - bdi_thresh / (DIRTY_SCOPE / 2);
+	if (bdi_dirty < origin)
+		bw = bw * origin / (bdi_dirty | 1);
+
+	/*
+	 * honour light dirtiers higher bandwidth:
+	 *
+	 *	bw *= sqrt(1 / task_dirty_weight);
+	 */
+	if (tsk) {
+		unsigned long numerator, denominator;
+		const unsigned long priority_base = 1024;
+		unsigned long priority = priority_base;
+
+		/*
+		 * Double the bandwidth for PF_LESS_THROTTLE (ie. nfsd) and
+		 * real-time tasks.
+		 */
+		if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk))
+			priority *= 2;
+
+		task_dirties_fraction(tsk, &numerator, &denominator);
+
+		denominator <<= 10;
+		denominator = denominator * priority / priority_base;
+		bw *= int_sqrt(denominator / (numerator + 1)) *
+					    priority / priority_base;
+		bw >>= 5 + BASE_BW_SHIFT / 2;
+		bw = (unsigned long)bw * bdi->throttle_bandwidth;
+		bw >>= 2 * BASE_BW_SHIFT - BASE_BW_SHIFT / 2;
+
+		/*
+		 * The avg_bandwidth bound is necessary because
+		 * bdi_update_throttle_bandwidth() blindly sets base bandwidth
+		 * to avg_bandwidth for more stable estimation, when it
+		 * believes the current task is the only dirtier.
+		 */
+		if (priority > priority_base)
+			return min((unsigned long)bw, bdi->avg_bandwidth);
+	}
+
+	return bw;
+}
+
 static void bdi_update_dirty_smooth(struct backing_dev_info *bdi,
 				    unsigned long dirty)
 {
@@ -631,6 +880,230 @@ static void bdi_update_dirty_threshold(s
 	bdi->old_dirty_threshold = thresh;
 }
 
+/*
+ * ref_bw typically fluctuates within a small range, with large isolated points
+ * from time to time. The smoothed reference_bandwidth can effectively filter
+ * out 1 such standalone point. When there comes 2+ isolated points together --
+ * observed in ext4 on sudden redirty -- reference_bandwidth may surge high and
+ * take long time to return to normal, which can mostly be counteracted by
+ * xref_bw and other update restrictions in bdi_update_throttle_bandwidth().
+ */
+static void bdi_update_reference_bandwidth(struct backing_dev_info *bdi,
+					   unsigned long ref_bw)
+{
+	unsigned long old = bdi->old_ref_bandwidth;
+	unsigned long avg = bdi->reference_bandwidth;
+
+	if (avg > old && old >= ref_bw && avg - old >= old - ref_bw)
+		avg -= (avg - old) >> 3;
+
+	if (avg < old && old <= ref_bw && old - avg >= ref_bw - old)
+		avg += (old - avg) >> 3;
+
+	bdi->reference_bandwidth = avg;
+	bdi->old_ref_bandwidth = ref_bw;
+}
+
+/*
+ * Base throttle bandwidth.
+ */
+static void bdi_update_throttle_bandwidth(struct backing_dev_info *bdi,
+					  unsigned long thresh,
+					  unsigned long dirty,
+					  unsigned long bdi_dirty,
+					  unsigned long dirtied,
+					  unsigned long elapsed)
+{
+	unsigned long limit = default_backing_dev_info.dirty_threshold;
+	unsigned long margin = limit / DIRTY_MARGIN;
+	unsigned long goal = thresh - thresh / DIRTY_SCOPE;
+	unsigned long bdi_thresh = bdi->dirty_threshold;
+	unsigned long bdi_goal = bdi_thresh - bdi_thresh / DIRTY_SCOPE;
+	unsigned long long bw = bdi->throttle_bandwidth;
+	unsigned long long dirty_bw;
+	unsigned long long pos_bw;
+	unsigned long long delta;
+	unsigned long long ref_bw = 0;
+	unsigned long long xref_bw;
+	unsigned long pos_ratio;
+	unsigned long spread;
+
+	if (dirty > limit - margin)
+		bdi->dirty_exceed_time = jiffies;
+
+	if (dirty < thresh - thresh / (DIRTY_SCOPE/2) + margin)
+		bdi->dirty_free_run = jiffies;
+
+	/*
+	 * The dirty rate should match the writeback rate exactly, except when
+	 * dirty pages are truncated before IO submission. The mismatches are
+	 * hopefully small and hence ignored. So a continuous stream of dirty
+	 * page trucates will result in errors in ref_bw, fortunately pos_bw
+	 * can effectively stop the base bw from being driven away endlessly
+	 * by the errors.
+	 *
+	 * It'd be nicer for the filesystems to not redirty too much pages
+	 * either on IO or lock contention, or on sub-page writes.  ext4 is
+	 * known to redirty pages in big bursts, leading to
+	 *   - surges of dirty_bw, which can be mostly safeguarded by the
+	 *     min/max'ed xref_bw
+	 *   - the temporary drop of task weight and hence surge of task bw
+	 * It could possibly be fixed in the FS.
+	 */
+	dirty_bw = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+
+	pos_ratio = dirty_throttle_bandwidth(bdi, thresh, dirty,
+					     bdi_dirty, NULL);
+	/*
+	 * pos_bw = task_bw, assuming 100% task dirty weight
+	 *
+	 * (pos_bw > bw) means the position of the number of dirty pages is
+	 * lower than the global and/or bdi setpoints. It does not necessarily
+	 * mean the base throttle bandwidth is larger than its balanced value.
+	 * The latter is likely only when
+	 * - (position) the dirty pages are at some distance from the setpoint,
+	 * - (speed) and either stands still or is departing from the setpoint.
+	 */
+	pos_bw = (bw >> (BASE_BW_SHIFT/2)) * pos_ratio >>
+			(BASE_BW_SHIFT/2);
+
+	/*
+	 * A typical desktop has only 1 task writing to 1 disk, in which case
+	 * the dirtier task should be throttled at the disk's write bandwidth.
+	 * Note that we ignore minor dirty/writeback mismatches such as
+	 * redirties and truncated dirty pages.
+	 */
+	if (bdi_thresh > thresh - thresh / 16) {
+		unsigned long numerator, denominator;
+
+		task_dirties_fraction(current, &numerator, &denominator);
+		if (numerator > denominator - denominator / 16)
+			ref_bw = bdi->avg_bandwidth << BASE_BW_SHIFT;
+	}
+	/*
+	 * Otherwise there may be
+	 * 1) N dd tasks writing to the current disk, or
+	 * 2) X dd tasks and Y "rsync --bwlimit" tasks.
+	 * The below estimation is accurate enough for (1). For (2), where not
+	 * all task's dirty rate can be changed proportionally by adjusting the
+	 * base throttle bandwidth, it would require multiple adjust-reestimate
+	 * cycles to approach the rate matching point. Which is not a big
+	 * concern as we always do small steps to approach the target. The
+	 * un-controllable tasks may only slow down the progress.
+	 */
+	if (!ref_bw) {
+		ref_bw = pos_ratio * bdi->avg_bandwidth;
+		do_div(ref_bw, dirty_bw | 1);
+		ref_bw = (bw >> (BASE_BW_SHIFT/2)) * (unsigned long)ref_bw >>
+				(BASE_BW_SHIFT/2);
+	}
+
+	/*
+	 * The average dirty pages typically fluctuates within this scope.
+	 */
+	spread = min(bdi->write_bandwidth / 8, bdi_thresh / DIRTY_MARGIN);
+
+	/*
+	 * Update the base throttle bandwidth rigidly: eg. only try lowering it
+	 * when both the global/bdi dirty pages are away from their setpoints,
+	 * and are either standing still or continue departing away.
+	 *
+	 * The "+ avg_dirty / 256" tricks mainly help btrfs, which behaves
+	 * amazingly smoothly.  Its average dirty pages simply tracks more and
+	 * more close to the number of dirty pages without any overshooting,
+	 * thus its dirty pages may be ever moving towards the setpoint and
+	 * @avg_dirty ever approaching @dirty, slower and slower, but very hard
+	 * to cross it to trigger a base bandwidth update. What the trick does
+	 * is "when @avg_dirty is _close enough_ to @dirty, it indicates slowed
+	 * down @dirty change rate, hence the other inequalities are now a good
+	 * indication of something unbalanced in the current bdi".
+	 *
+	 * In the cases of hitting the upper/lower margins, it's obviously
+	 * necessary to adjust the (possibly very unbalanced) base bandwidth,
+	 * unless the opposite margin was also been hit recently, which
+	 * indicates that the dirty control scope may be smaller than the bdi
+	 * write bandwidth and hence the dirty pages are quickly fluctuating
+	 * between the upper/lower margins.
+	 */
+	if (bw < pos_bw) {
+		if (dirty < goal &&
+		    dirty <= default_backing_dev_info.avg_dirty +
+			     (default_backing_dev_info.avg_dirty >> 8) &&
+		    bdi->avg_dirty + spread < bdi_goal &&
+		    bdi_dirty <= bdi->avg_dirty + (bdi->avg_dirty >> 8) &&
+		    bdi_dirty <= bdi->old_dirty)
+			goto adjust;
+		if (dirty < thresh - thresh / (DIRTY_SCOPE/2) + margin &&
+		    !dirty_exceeded_recently(bdi, HZ))
+			goto adjust;
+	}
+
+	if (bw > pos_bw) {
+		if (dirty > goal &&
+		    dirty >= default_backing_dev_info.avg_dirty -
+			     (default_backing_dev_info.avg_dirty >> 8) &&
+		    bdi->avg_dirty > bdi_goal + spread &&
+		    bdi_dirty >= bdi->avg_dirty - (bdi->avg_dirty >> 8) &&
+		    bdi_dirty >= bdi->old_dirty)
+			goto adjust;
+		if (dirty > limit - margin &&
+		    !dirty_free_run_recently(bdi, HZ))
+			goto adjust;
+	}
+
+	goto out;
+
+adjust:
+	/*
+	 * The min/max'ed xref_bw is an effective safeguard. The most dangerous
+	 * case that could unnecessarily disturb the base bandwith is: when the
+	 * control scope is roughly equal to the write bandwidth, the dirty
+	 * pages may rush into the upper/lower margins regularly. It typically
+	 * hits the upper margin in a blink, making a sudden drop of pos_bw and
+	 * ref_bw. Assume 5 points A, b, c, D, E, where b, c have the dropped
+	 * down number of pages, and A, D, E are at normal level.  At point b,
+	 * the xref_bw will be the good A; at c, the xref_bw will be the
+	 * dragged-down-by-b reference_bandwidth which is bad; at D and E, the
+	 * still-low reference_bandwidth will no longer bring the base
+	 * bandwidth down, as xref_bw will take the larger values from D and E.
+	 */
+	if (pos_bw > bw) {
+		xref_bw = min(ref_bw, bdi->old_ref_bandwidth);
+		xref_bw = min(xref_bw, bdi->reference_bandwidth);
+		if (xref_bw > bw)
+			delta = xref_bw - bw;
+		else
+			delta = 0;
+	} else {
+		xref_bw = max(ref_bw, bdi->reference_bandwidth);
+		xref_bw = max(xref_bw, bdi->reference_bandwidth);
+		if (xref_bw < bw)
+			delta = bw - xref_bw;
+		else
+			delta = 0;
+	}
+
+	/*
+	 * Don't pursue 100% rate matching. It's impossible since the balanced
+	 * rate itself is constantly fluctuating. So decrease the track speed
+	 * when it gets close to the target. Also limit the step size in
+	 * various ways to avoid overshooting.
+	 */
+	delta >>= bw / (2 * delta + 1);
+	delta = min(delta, (u64)abs64(pos_bw - bw));
+	delta >>= 1;
+	delta = min(delta, bw / 8);
+
+	if (pos_bw > bw)
+		bw += delta;
+	else
+		bw -= delta;
+
+	bdi->throttle_bandwidth = bw;
+out:
+	bdi_update_reference_bandwidth(bdi, ref_bw);
+}
+
 void bdi_update_bandwidth(struct backing_dev_info *bdi,
 			  unsigned long thresh,
 			  unsigned long dirty,
@@ -640,12 +1113,14 @@ void bdi_update_bandwidth(struct backing
 	static DEFINE_SPINLOCK(dirty_lock);
 	unsigned long now = jiffies;
 	unsigned long elapsed;
+	unsigned long dirtied;
 	unsigned long written;
 
 	if (!spin_trylock(&dirty_lock))
 		return;
 
 	elapsed = now - bdi->bw_time_stamp;
+	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
 
 	/* skip quiet periods when disk bandwidth is under-utilized */
@@ -665,6 +1140,8 @@ void bdi_update_bandwidth(struct backing
 	if (thresh) {
 		update_dirty_limit(thresh, dirty);
 		bdi_update_dirty_threshold(bdi, thresh, dirty);
+		bdi_update_throttle_bandwidth(bdi, thresh, dirty,
+					      bdi_dirty, dirtied, elapsed);
 	}
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
 	if (thresh) {
@@ -673,6 +1150,7 @@ void bdi_update_bandwidth(struct backing
 	}
 
 snapshot:
+	bdi->dirtied_stamp = dirtied;
 	bdi->written_stamp = written;
 	bdi->bw_time_stamp = now;
 unlock:
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:22.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:27.000000000 +0800
@@ -674,6 +674,7 @@ int bdi_init(struct backing_dev_info *bd
 
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_bandwidth = INIT_BW;
+	bdi->throttle_bandwidth = (u64)INIT_BW << BASE_BW_SHIFT;
 
 	bdi->avg_dirty = 0;
 	bdi->old_dirty = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
