Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B0F5B6B016D
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 23:30:26 -0400 (EDT)
Message-Id: <20110816022328.811348370@intel.com>
Date: Tue, 16 Aug 2011 10:20:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/5] writeback: dirty position control
References: <20110816022006.348714319@intel.com>
Content-Disposition: inline; filename=writeback-control-algorithms.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

bdi_position_ratio() provides a scale factor to bdi->dirty_ratelimit, so
that the resulted task rate limit can drive the dirty pages back to the
global/bdi setpoints.

Old scheme is,
                                          |
                           free run area  |  throttle area
  ----------------------------------------+---------------------------->
                                    thresh^                  dirty pages

New scheme is,

  ^ task rate limit
  |
  |            *
  |             *
  |              *
  |[free run]      *      [smooth throttled]
  |                  *
  |                     *
  |                         *
  ..bdi->dirty_ratelimit..........*
  |                               .     *
  |                               .          *
  |                               .              *
  |                               .                 *
  |                               .                    *
  +-------------------------------.-----------------------*------------>
                          setpoint^                  limit^  dirty pages

The slope of the bdi control line should be

1) large enough to pull the dirty pages to setpoint reasonably fast

2) small enough to avoid big fluctuations in the resulted pos_ratio and
   hence task ratelimit

Since the fluctuation range of the bdi dirty pages is typically observed
to be within 1-second worth of data, the bdi control line's slope is
selected to be a linear function of bdi write bandwidth, so that it can
adapt to slow/fast storage devices well.

Assume the bdi control line

	pos_ratio = 1.0 + k * (dirty - setpoint)

where k is the negative slope.

If targeting for 12.5% fluctuation range in pos_ratio when dirty pages
are fluctuating in range [setpoint - write_bw/2, setpoint + write_bw/2],
we get slope

	k = - 1 / (8 * write_bw)

Let pos_ratio(x_intercept) = 0, we get the parameter used in code:

	x_intercept = setpoint + 8 * write_bw

The global/bdi slopes are nicely complementing each other when the
system has only one major bdi (indicated by bdi_thresh ~= thresh):

1) slope of global control line    => scaling to the control scope size
2) slope of main bdi control line  => scaling to the write bandwidth

so that

- in memory tight systems, (1) becomes strong enough to squeeze dirty
  pages inside the control scope

- in large memory systems where the "gravity" of (1) for pulling the
  dirty pages to setpoint is too weak, (2) can back (1) up and drive
  dirty pages to setpoint reasonably fast.

Unfortunately in JBOD setups, the fluctuation range of bdi threshold
is related to memory size due to the interferences between disks.  In
this case, the bdi slope will be weighted sum of write_bw and bdi_thresh.

peter: use 3rd order polynomial for the global control line

CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |    2 
 include/linux/writeback.h |    1 
 mm/page-writeback.c       |  196 +++++++++++++++++++++++++++++++++++-
 3 files changed, 193 insertions(+), 6 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-08-14 18:03:49.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-14 21:33:39.000000000 +0800
@@ -46,6 +46,8 @@
  */
 #define BANDWIDTH_INTERVAL	max(HZ/5, 1)
 
+#define RATELIMIT_CALC_SHIFT	10
+
 /*
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  * will look to see if it needs to force writeback or throttling.
@@ -411,6 +413,12 @@ unsigned long determine_dirtyable_memory
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+static unsigned long dirty_freerun_ceiling(unsigned long thresh,
+					   unsigned long bg_thresh)
+{
+	return (thresh + bg_thresh) / 2;
+}
+
 static unsigned long hard_dirty_limit(unsigned long thresh)
 {
 	return max(thresh, global_dirty_limit);
@@ -495,6 +503,180 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+/*
+ * Dirty position control.
+ *
+ * (o) global/bdi setpoints
+ *
+ * We want the dirty pages be balanced around the global/bdi setpoints.
+ * When the number of dirty pages is higher/lower than the setpoint, the
+ * dirty position control ratio (and hence task dirty ratelimit) will be
+ * decreased/increased to bring the dirty pages back to the setpoint.
+ *
+ *     pos_ratio = 1 << RATELIMIT_CALC_SHIFT
+ *
+ *     if (dirty < setpoint) scale up   pos_ratio
+ *     if (dirty > setpoint) scale down pos_ratio
+ *
+ *     if (bdi_dirty < bdi_setpoint) scale up   pos_ratio
+ *     if (bdi_dirty > bdi_setpoint) scale down pos_ratio
+ *
+ *     task_ratelimit = balanced_rate * pos_ratio >> RATELIMIT_CALC_SHIFT
+ *
+ * (o) global control line
+ *
+ *     ^ pos_ratio
+ *     |
+ *     |            |<===== global dirty control scope ======>|
+ * 2.0 .............*
+ *     |            .*
+ *     |            . *
+ *     |            .   *
+ *     |            .     *
+ *     |            .        *
+ *     |            .            *
+ * 1.0 ................................*
+ *     |            .                  .     *
+ *     |            .                  .          *
+ *     |            .                  .              *
+ *     |            .                  .                 *
+ *     |            .                  .                    *
+ *   0 +------------.------------------.----------------------*------------->
+ *           freerun^          setpoint^                 limit^   dirty pages
+ *
+ * (o) bdi control lines
+ *
+ * The control lines for the global/bdi setpoints both stretch up to @limit.
+ * The below figure illustrates the main bdi control line with an auxiliary
+ * line extending it to @limit.
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
+ *                       o--------------------- balance point, rate scale = 1
+ *                       | o
+ *                       |   o
+ *                       |     o
+ *                       |       o
+ *                       |         o
+ *                       |           o
+ *                       |             o------- connect point, rate scale = 1/2
+ *                       |               .*
+ *                       |                 .   *
+ *                       |                   .      *
+ *                       |                     .         *
+ *                       |                       .           *
+ *                       |                         .              *
+ *                       |                           .                 *
+ *  [--------------------+-----------------------------.--------------------*]
+ *  0                 setpoint                     x_intercept           limit
+ *
+ * The auxiliary control line allows smoothly throttling bdi_dirty down to
+ * normal if it starts high in situations like
+ * - start writing to a slow SD card and a fast disk at the same time. The SD
+ *   card's bdi_dirty may rush to many times higher than bdi setpoint.
+ * - the bdi dirty thresh drops quickly due to change of JBOD workload
+ */
+static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
+					unsigned long thresh,
+					unsigned long bg_thresh,
+					unsigned long dirty,
+					unsigned long bdi_thresh,
+					unsigned long bdi_dirty)
+{
+	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
+	unsigned long limit = hard_dirty_limit(thresh);
+	unsigned long x_intercept;
+	unsigned long setpoint;		/* the target balance point */
+	unsigned long span;
+	long long pos_ratio;		/* for scaling up/down the rate limit */
+	long x;
+
+	if (unlikely(dirty >= limit))
+		return 0;
+
+	/*
+	 * global setpoint
+	 *
+	 *                         setpoint - dirty 3
+	 *        f(dirty) := 1 + (----------------)
+	 *                         limit - setpoint
+	 *
+	 * it's a 3rd order polynomial that subjects to
+	 *
+	 * (1) f(freerun)  = 2.0 => rampup base_rate reasonably fast
+	 * (2) f(setpoint) = 1.0 => the balance point
+	 * (3) f(limit)    = 0   => the hard limit
+	 * (4) df/dx       < 0	 => negative feedback control
+	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
+	 *     => fast response on large errors; small oscillation near setpoint
+	 */
+	setpoint = (freerun + limit) / 2;
+	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
+		    limit - setpoint + 1);
+	pos_ratio = x;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
+
+	/*
+	 * bdi setpoint
+	 *
+	 *        f(dirty) := 1.0 + k * (dirty - setpoint)
+	 *
+	 * The main bdi control line is a linear function that subjects to
+	 *
+	 * (1) f(setpoint) = 1.0
+	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
+	 *     or equally: x_intercept = setpoint + 8 * write_bw
+	 *
+	 * For single bdi case, the dirty pages are observed to fluctuate
+	 * regularly within range
+	 *        [setpoint - write_bw/2, setpoint + write_bw/2]
+	 * for various filesystems, where (2) can yield in a reasonable 12.5%
+	 * fluctuation range for pos_ratio.
+	 *
+	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
+	 * own size, so move the slope over accordingly.
+	 */
+	if (unlikely(bdi_thresh > thresh))
+		bdi_thresh = thresh;
+	/*
+	 * scale global setpoint to bdi's:  setpoint *= bdi_thresh / thresh
+	 */
+	x = div_u64((u64)bdi_thresh << 16, thresh | 1);
+	setpoint = setpoint * (u64)x >> 16;
+	/*
+	 * Use span=(4*write_bw) in single bdi case as indicated by
+	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
+	 */
+	span = div_u64((u64)bdi_thresh * (thresh - bdi_thresh) +
+		       (u64)(4 * bdi->avg_write_bandwidth) * bdi_thresh,
+		       thresh + 1);
+	x_intercept = setpoint + 2 * span;
+
+	if (unlikely(bdi_dirty > setpoint + span)) {
+		if (unlikely(bdi_dirty > limit))
+			return 0;
+		if (x_intercept < limit) {
+			x_intercept = limit;	/* auxiliary control line */
+			setpoint += span;
+			pos_ratio >>= 1;
+		}
+	}
+	pos_ratio *= x_intercept - bdi_dirty;
+	do_div(pos_ratio, x_intercept - setpoint + 1);
+
+	return pos_ratio;
+}
+
 static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 				       unsigned long elapsed,
 				       unsigned long written)
@@ -593,6 +775,7 @@ static void global_update_bandwidth(unsi
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
+			    unsigned long bg_thresh,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,
@@ -629,6 +812,7 @@ snapshot:
 
 static void bdi_update_bandwidth(struct backing_dev_info *bdi,
 				 unsigned long thresh,
+				 unsigned long bg_thresh,
 				 unsigned long dirty,
 				 unsigned long bdi_thresh,
 				 unsigned long bdi_dirty,
@@ -637,8 +821,8 @@ static void bdi_update_bandwidth(struct 
 	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
 		return;
 	spin_lock(&bdi->wb.list_lock);
-	__bdi_update_bandwidth(bdi, thresh, dirty, bdi_thresh, bdi_dirty,
-			       start_time);
+	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
+			       bdi_thresh, bdi_dirty, start_time);
 	spin_unlock(&bdi->wb.list_lock);
 }
 
@@ -679,7 +863,8 @@ static void balance_dirty_pages(struct a
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_dirty <= (background_thresh + dirty_thresh) / 2)
+		if (nr_dirty <= dirty_freerun_ceiling(dirty_thresh,
+						      background_thresh))
 			break;
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
@@ -723,8 +908,9 @@ static void balance_dirty_pages(struct a
 		if (!bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 
-		bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
-				     bdi_thresh, bdi_dirty, start_time);
+		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
+				     nr_dirty, bdi_thresh, bdi_dirty,
+				     start_time);
 
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked
--- linux-next.orig/fs/fs-writeback.c	2011-08-14 18:03:45.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-08-14 18:03:50.000000000 +0800
@@ -670,7 +670,7 @@ static inline bool over_bground_thresh(v
 static void wb_update_bandwidth(struct bdi_writeback *wb,
 				unsigned long start_time)
 {
-	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, start_time);
+	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
 }
 
 /*
--- linux-next.orig/include/linux/writeback.h	2011-08-14 18:03:45.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-08-14 18:03:50.000000000 +0800
@@ -154,6 +154,7 @@ unsigned long bdi_dirty_limit(struct bac
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
+			    unsigned long bg_thresh,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
