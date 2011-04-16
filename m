Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5D77690008F
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:38 -0400 (EDT)
Message-Id: <20110416134333.308712791@intel.com>
Date: Sat, 16 Apr 2011 21:25:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/12] writeback: base throttle bandwidth and position ratio
References: <20110416132546.765212221@intel.com>
Content-Disposition: inline; filename=writeback-control-algorithms.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

balance_dirty_pages() has been using a very simple and robust threshold
based throttle scheme. It implicitly limits the dirty rate down, however
in a rather bumpy way that constantly block one dirtier task for hundreds
of milliseconds on a local ext4, and multiple dirtier tasks for seconds.

The new scheme is to expand the ON/OFF threshold to a larger scope in
which both the number of dirty pages and the dirty rate are explicitly
controlled.

PSEUDO CODE
===========

on write() syscall, calculate pause time
----------------------------------------

    balance_dirty_pages(pages_dirtied)
    {
        task_ratelimit = bdi->dirty_ratelimit * bdi_position_ratio();
        pause = pages_dirtied / task_ratelimit;
        sleep(pause);
    }

on every 200ms, update base throttle bandwidth
----------------------------------------------

    bdi_update_dirty_ratelimit()
    {
        bw = bdi->dirty_ratelimit;
        ref_bw = bw * bdi_position_ratio() * write_bw / dirty_bw;
        if (dirty pages unbalanced)
             bdi->dirty_ratelimit = (bw * 3 + ref_bw) / 4;
    }

position control ratio
----------------------

    bdi_position_ratio()
    {
        pos_ratio = 1.0

        // gentle negative feedback control
        pos_ratio -= (nr_dirty - goal) / SCALE;
        pos_ratio -= (bdi_dirty - bdi_goal) / BDI_SCALE;

        // sharp boundary control
        if (near global limit)  scale down   pos_ratio
        if (bdi queue runs low) scale up     pos_ratio

        return pos_ratio;
    }

BALANCED POSITION AND RATE
==========================

position feedback control
-------------------------

  At the center of the control scope is the setpoint/goal. When the
  number of dirty pages go higher/lower than the goal, its dirty rate
  will be proportionally decreased/increased to prevent it from drifting
  away.

  When the dirty pages drops low to the bottom of the control scope, or
  rushes high to the upper limit, the dirty rate will quickly be scaled
  up/down, to the point of completely let go of or completely block the
  dirtier task.

rate estimation
---------------

  What's the balanced dirty rate if the dirty pages are exactly at the
  goal? When doing N dd's on 1 disk at rate task_bw MB/s, then task_bw
  should be balanced at write_bw/N where write_bw is the disk's write
  bandwidth. We call base_bw==write_bw/N the disk's base throttle
  bandwidth (ie. bdi->dirty_ratelimit in the code).  Each task will be
  allowed to dirty at rate task_bw=base_bw*pos_ratio where pos_ratio is
  the result of position control, it will be 1 if the dirty pages are
  exactly at the goal.

  In practice we don't know base_bw beforehand. Because we don't know
  the exact number of N and cannot assume all tasks are equal weighted.
  So a reference bandwidth ref_bw is estimated as the target for base_bw
  to track.  base_bw will be adjusted step by step towards ref_bw. In
  each step, ref_bw is calculated as

	  base_bw * pos_ratio * write_bw / dirty_bw

  That is, when the (unknown number of) tasks are rate limited based
  on previous (base_bw*pos_ratio), if the overall dirty rate dirty_bw is
  M times write_bw, then the base_bw shall be scaled 1/M to balance
  dirty_bw and write_bw.

  The ref_bw estimation will be pretty accurate if without
  (1) noises
  (2) feedback delays between steps
  (3) the mismatch between the number of dirty and writeback events
      caused by user space truncate and file system redirty

  (1) can be smoothed out; (2) will decrease proportionally with the
  adjust size when base_bw gets close to ref_bw.

  (3) can be ultimately fixed by accounting the truncate/redirty events.
  But for now we can rely on the robustness of base_bw update algorithms
  to deal with the mismatches: no obvious imbalance is observed in ext4
  workloads which have bursts of redirty and large dirtied:written=3:2
  ratio. In theory when the truncate/redirty makes (write_bw < dirty_bw)
  in long term, ref_bw and base_bw will go low, driving up the pos_ratio
  which then corrects (pos_ratio * write_bw / dirty_bw) back to 1, thus
  balance ref_bw at some point. What's more, bdi_update_dirty_ratelimit()
  dictates that base_bw will only be updated when ref_bw and
  pos_bw=base_bw*pos_ratio are both higher (or lower) than base_bw. So
  the higher pos_bw will effectively stop base_bw from approaching the
  lower ref_bw.

In general, it's pretty safe and robust.

- the upper/lower bounds in the position control provides ultimate
  safeguard: in case the algorithms fly away, the dirty pages
  will be guarded by the control bounds with larger fluctuates in dirty
  rate -- but still much better than the current threshold based approach.

- the base bandwidth update rules are accurate and robust enough for
  base_bw to quickly adapt to new workload and remain stable thereafter
  This is confirmed by a wide range of tests: base_bw only goes a bit
  less stable when the control scope is smaller than the write bandwidth,
  in which case the pos_ratio is already fluctuating much more.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |   11 
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |  411 ++++++++++++++++++++++++++++++++++
 3 files changed, 423 insertions(+)

--- linux-next.orig/include/linux/backing-dev.h	2011-04-16 17:54:02.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-04-16 17:54:09.000000000 +0800
@@ -74,9 +74,15 @@ struct backing_dev_info {
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
 	unsigned long bw_time_stamp;
+	unsigned long dirtied_stamp;
 	unsigned long written_stamp;
 	unsigned long write_bandwidth;
 	unsigned long avg_write_bandwidth;
+	/* the base bandwidth, the task's dirty rate will be curbed under it */
+	unsigned long dirty_ratelimit;
+	/* the estimated balance point, base bw will follow it step by step */
+	unsigned long reference_ratelimit;
+	unsigned long old_ref_ratelimit;
 	unsigned long avg_dirty;
 	unsigned long old_dirty;
 	unsigned long dirty_threshold;
@@ -85,6 +91,11 @@ struct backing_dev_info {
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
+	/* last time exceeded (limit - limit/DIRTY_BRAKE) */
+	unsigned long dirty_exceed_time;
+	/* last time dropped to the rampup area or even the unthrottled area */
+	unsigned long dirty_free_run;
+
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
--- linux-next.orig/mm/page-writeback.c	2011-04-16 17:54:08.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-16 17:54:09.000000000 +0800
@@ -36,6 +36,8 @@
 #include <linux/pagevec.h>
 #include <trace/events/writeback.h>
 
+#define RATIO_SHIFT	10
+
 /*
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  * will look to see if it needs to force writeback or throttling.
@@ -393,6 +395,12 @@ unsigned long determine_dirtyable_memory
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+static unsigned long hard_dirty_limit(unsigned long thresh)
+{
+	return max(thresh + thresh / DIRTY_BRAKE,
+		   default_backing_dev_info.dirty_threshold);
+}
+
 /*
  * global_dirty_limits - background-writeback and dirty-throttling thresholds
  *
@@ -477,6 +485,232 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+/*
+ * last time exceeded (limit - limit/DIRTY_BRAKE)
+ */
+static bool dirty_exceeded_recently(struct backing_dev_info *bdi,
+				    unsigned long time_window)
+{
+	return jiffies - bdi->dirty_exceed_time <= time_window;
+}
+
+/*
+ * last time dropped below (thresh - 2*thresh/DIRTY_SCOPE + thresh/DIRTY_RAMPUP)
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
+ * (1) boundary guarding areas
+ *
+ * The loop area is required to stop large number of slow dirtiers, because
+ * the max-pause area is only able to throttle a task at 1page/200ms=20KB/s.
+ *
+ * The pass-good region can stop a slow UKEY with 100+ slow dirtiers, while
+ * still avoid looping for the other good disk, so that their performance won't
+ * be impacted.
+ *
+ * The max-pause area can safeguard unknown bugs in the control algorithms
+ * as well as the possible surges in small memory boxes.
+ *
+ * The brake area is a good leeway for holding off the dirty pages in sudden
+ * workload change, or when some bdi dirty goal is excessively exceeded.
+ *
+ * The loop, pass-good and max-pause areas are enforced inside the loop of
+ * balance_dirty_pages(). Others can be found in bdi_position_ratio().
+ *
+ *      loop area,  loop until drop below the area  ----------------------|<===
+ * pass-good area,  dirty exceeded bdi's will loop  -----------------|<==>|
+ * max-pause area,  sleep(max_pause) and return     ------------|<==>|
+ *     brake area,  bw scaled from 1 down to 0      ---|<======>|
+ * ----------------------------------------------------o--------*----o----o----
+ *                                                     ^        ^    ^    ^
+ *                    limit - limit/DIRTY_BRAKE     ---'        |    |    |
+ *                    limit                         ------------'    |    |
+ *                    limit + limit/DIRTY_MAXPAUSE  -----------------'    |
+ *                    limit + limit/DIRTY_PASSGOOD  ----------------------'
+ *
+ * (2) global control areas
+ *
+ * The rampup area is for ramping up the base bandwidth whereas the above brake
+ * area is for scaling down the base bandwidth.
+ *
+ * The global thresh typically lies at the bottom of the brake area. @thresh
+ * is real-time computed from global_dirty_limits() and @limit is tracking
+ * (thresh + thresh/DIRTY_BRAKE) at 200ms intervals in update_dirty_limit().
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
+ * 0         bdi_goal = bdi_thresh - bdi_thresh/DIRTY_SCOPE^       ^bdi_thresh
+ *
+ * (4) global/bdi control lines
+ *
+ * bdi_position_ratio() applies 2 main and 3 regional control lines for
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
+static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
+					unsigned long thresh,
+					unsigned long dirty,
+					unsigned long bdi_dirty)
+{
+	unsigned long limit = hard_dirty_limit(thresh);
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
+	goal = thresh - thresh / DIRTY_SCOPE;
+	origin = goal + 2 * thresh;
+
+	if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
+		origin = limit;
+		goal = (goal + origin) / 2;
+		bw >>= 1;
+	}
+	bw = origin - dirty;
+	bw <<= RATIO_SHIFT;
+	do_div(bw, origin - goal + 1);
+
+	/*
+	 * brake area, hold off dirtiers when the estimated dirty_ratelimit
+	 * and/or write_bandwidth are adapting to sudden workload changes.
+	 * It also balances the pressure to push global pages high when some
+	 * bdi dirty pages are over-committed (eg. a UKEY's bdi goal could be
+	 * exceeded a lot in the free run area; an unresponsing server may make
+	 * an NFS bdi's dirty goal drop much lower than its dirty pages).
+	 */
+	if (dirty > limit - limit / DIRTY_BRAKE) {
+		bw *= limit - dirty;
+		do_div(bw, limit / DIRTY_BRAKE + 1);
+	}
+
+	/*
+	 * rampup area, immediately above the unthrottled free-run region.
+	 * It's setup mainly to get an estimation of ref_bw for reliably
+	 * ramping up the base bandwidth.
+	 */
+	dirty = default_backing_dev_info.avg_dirty;
+	origin = thresh - thresh / DIRTY_FULL_SCOPE + thresh / DIRTY_RAMPUP;
+	if (dirty < origin) {
+		span = (origin - dirty) * bw;
+		do_div(span, thresh / (4 * DIRTY_RAMPUP) + 1);
+		bw += min(span, 4 * bw);
+	}
+
+	/*
+	 * bdi reserve area, safeguard against bdi dirty underflow and disk idle
+	 */
+	origin = bdi->avg_write_bandwidth + 2 * MIN_WRITEBACK_PAGES;
+	origin = min(origin, thresh - thresh / DIRTY_FULL_SCOPE);
+	if (bdi_dirty < origin) {
+		if (bdi_dirty > origin / 4)
+			bw = bw * origin / bdi_dirty;
+		else
+			bw = bw * 4;
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
+		(2 * bdi->avg_write_bandwidth) * bdi_thresh;
+	do_div(span, thresh + 1);
+	origin = goal + 2 * span;
+
+	if (likely(bdi->avg_dirty))
+		bdi_dirty = bdi->avg_dirty;
+	if (unlikely(bdi_dirty > goal + span)) {
+		if (bdi_dirty > limit)
+			return 0;
+		if (origin < limit) {
+			origin = limit;
+			goal += span;
+			bw >>= 1;
+		}
+	}
+	bw *= origin - bdi_dirty;
+	do_div(bw, origin - goal + 1);
+
+	return bw;
+}
+
 static void bdi_update_dirty_smooth(struct backing_dev_info *bdi,
 				    unsigned long dirty)
 {
@@ -611,6 +845,178 @@ static void bdi_update_dirty_threshold(s
 	bdi->old_dirty_threshold = thresh;
 }
 
+/*
+ * ref_bw typically fluctuates within a small range, with large isolated points
+ * from time to time. The smoothed reference_ratelimit can effectively filter
+ * out 1 such standalone point. When there comes 2+ isolated points together --
+ * observed in ext4 on sudden redirty -- reference_ratelimit may surge high and
+ * take long time to return to normal, which can mostly be counteracted by
+ * xref_bw and other update restrictions in bdi_update_dirty_ratelimit().
+ */
+static void bdi_update_reference_ratelimit(struct backing_dev_info *bdi,
+					   unsigned long ref_bw)
+{
+	unsigned long old = bdi->old_ref_ratelimit;
+	unsigned long avg = bdi->reference_ratelimit;
+
+	if (avg > old && old >= ref_bw && avg - old >= old - ref_bw)
+		avg -= (avg - old) >> 2;
+
+	if (avg < old && old <= ref_bw && old - avg >= ref_bw - old)
+		avg += (old - avg) >> 2;
+
+	bdi->reference_ratelimit = avg;
+	bdi->old_ref_ratelimit = ref_bw;
+}
+
+/*
+ * Base throttle bandwidth.
+ */
+static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
+				       unsigned long thresh,
+				       unsigned long dirty,
+				       unsigned long bdi_dirty,
+				       unsigned long dirtied,
+				       unsigned long elapsed)
+{
+	unsigned long limit = default_backing_dev_info.dirty_threshold;
+	unsigned long goal = thresh - thresh / DIRTY_SCOPE;
+	unsigned long bw = bdi->dirty_ratelimit;
+	unsigned long dirty_bw;
+	unsigned long pos_bw;
+	unsigned long delta;
+	unsigned long ref_bw;
+	unsigned long xref_bw;
+	unsigned long long pos_ratio;
+
+	if (dirty > limit - limit / DIRTY_BRAKE)
+		bdi->dirty_exceed_time = jiffies;
+
+	if (dirty < thresh - thresh / DIRTY_FULL_SCOPE + thresh / DIRTY_RAMPUP)
+		bdi->dirty_free_run = jiffies;
+
+	/*
+	 * The dirty rate will match the writeback rate in long term, except
+	 * when dirty pages are truncated by userspace before IO submission, or
+	 * re-dirtied when the FS finds it not suitable to do IO at the time.
+	 */
+	dirty_bw = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+
+	pos_ratio = bdi_position_ratio(bdi, thresh, dirty, bdi_dirty);
+	/*
+	 * (pos_bw > bw) means the position of the number of dirty pages is
+	 * lower than the global and/or bdi setpoints. It does not necessarily
+	 * mean the base throttle bandwidth is larger than its balanced value.
+	 * The latter is likely only when
+	 * - (position) the dirty pages are at some distance from the setpoint,
+	 * - (speed) and either stands still or is departing from the setpoint.
+	 */
+	pos_bw = bw * pos_ratio >> RATIO_SHIFT;
+
+	/*
+	 * There may be
+	 * 1) X dd tasks writing to the current disk, and/or
+	 * 2) Y "rsync --bwlimit" tasks.
+	 * The below estimation is accurate enough for (1). For (2), where not
+	 * all task's dirty rate can be changed proportionally by adjusting the
+	 * base throttle bandwidth, it would require multiple adjust-reestimate
+	 * cycles to approach the rate balance point. That is not a big concern
+	 * as we do small steps anyway for the sake of other unknown noises.
+	 * The un-controllable tasks may only slow down the approximating
+	 * progress and is harmless otherwise.
+	 */
+	pos_ratio *= bdi->avg_write_bandwidth;
+	do_div(pos_ratio, dirty_bw | 1);
+	ref_bw = bw * pos_ratio >> RATIO_SHIFT;
+	ref_bw = min(ref_bw, bdi->avg_write_bandwidth);
+
+	/*
+	 * Update the base throttle bandwidth rigidly: eg. only try lowering it
+	 * when both the global/bdi dirty pages are away from their setpoints,
+	 * and are either standing still or continue departing away.
+	 *
+	 * The "+ (avg_dirty >> 8)" margin mainly help btrfs, which behaves
+	 * amazingly smoothly. Its @avg_dirty is ever approaching @dirty,
+	 * slower and slower, but very hard to cross it to trigger a base
+	 * bandwidth update. The added margin says "when @avg_dirty is _close
+	 * enough_ to @dirty, it indicates slowed down @dirty change rate,
+	 * hence the other inequalities are now a good indication of something
+	 * unbalanced in the current bdi".
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
+		    bdi_dirty <= bdi->avg_dirty + (bdi->avg_dirty >> 8) &&
+		    bdi_dirty <= bdi->old_dirty)
+			goto adjust;
+		if (dirty < thresh - thresh / DIRTY_FULL_SCOPE
+				   + thresh / DIRTY_RAMPUP &&
+		    !dirty_exceeded_recently(bdi, HZ))
+			goto adjust;
+	}
+
+	if (bw > pos_bw) {
+		if (dirty > goal &&
+		    dirty >= default_backing_dev_info.avg_dirty -
+			     (default_backing_dev_info.avg_dirty >> 8) &&
+		    bdi_dirty >= bdi->avg_dirty - (bdi->avg_dirty >> 8) &&
+		    bdi_dirty >= bdi->old_dirty)
+			goto adjust;
+		if (dirty > limit - limit / DIRTY_BRAKE &&
+		    !dirty_free_run_recently(bdi, HZ))
+			goto adjust;
+	}
+
+	goto out;
+
+adjust:
+	/*
+	 * The min/max'ed xref_bw is an effective safeguard against transient
+	 * large deviations. By considering not only the current ref_bw value,
+	 * but also the old/avg values, the sudden drop can be filtered out.
+	 */
+	if (pos_bw > bw) {
+		xref_bw = min(ref_bw, bdi->old_ref_ratelimit);
+		xref_bw = min(xref_bw, bdi->reference_ratelimit);
+		if (xref_bw > bw)
+			delta = xref_bw - bw;
+		else
+			delta = 0;
+	} else {
+		xref_bw = max(ref_bw, bdi->old_ref_ratelimit);
+		xref_bw = max(xref_bw, bdi->reference_ratelimit);
+		if (xref_bw < bw)
+			delta = bw - xref_bw;
+		else
+			delta = 0;
+	}
+
+	/*
+	 * Don't pursue 100% rate matching. It's impossible since the balanced
+	 * rate itself is constantly fluctuating. So decrease the track speed
+	 * when it gets close to the target. This avoids possible oscillations.
+	 * Also limit the step size to avoid overshooting.
+	 */
+	delta >>= bw / (8 * delta + 1);
+
+	if (pos_bw > bw)
+		bw += min(delta, pos_bw - bw) >> 2;
+	else
+		bw -= min(delta, bw - pos_bw) >> 2;
+
+	bdi->dirty_ratelimit = bw;
+out:
+	bdi_update_reference_ratelimit(bdi, ref_bw);
+}
+
 void bdi_update_bandwidth(struct backing_dev_info *bdi,
 			  unsigned long thresh,
 			  unsigned long dirty,
@@ -620,12 +1026,14 @@ void bdi_update_bandwidth(struct backing
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
@@ -649,12 +1057,15 @@ void bdi_update_bandwidth(struct backing
 		default_backing_dev_info.bw_time_stamp = now;
 	}
 	if (thresh) {
+		bdi_update_dirty_ratelimit(bdi, thresh, dirty,
+					   bdi_dirty, dirtied, elapsed);
 		bdi_update_dirty_threshold(bdi, thresh, dirty);
 		bdi_update_dirty_smooth(bdi, bdi_dirty);
 	}
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
 
 snapshot:
+	bdi->dirtied_stamp = dirtied;
 	bdi->written_stamp = written;
 	bdi->bw_time_stamp = now;
 unlock:
--- linux-next.orig/mm/backing-dev.c	2011-04-16 17:54:02.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-04-16 17:54:09.000000000 +0800
@@ -668,6 +668,7 @@ int bdi_init(struct backing_dev_info *bd
 
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
+	bdi->dirty_ratelimit = INIT_BW;
 
 	bdi->avg_dirty = 0;
 	bdi->old_dirty = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
