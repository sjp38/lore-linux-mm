Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 234469000DA
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:57 -0400 (EDT)
Message-Id: <20111003134536.342294003@intel.com>
Date: Mon, 03 Oct 2011 21:42:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/11] writeback: dirty position control
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=writeback-control-algorithms.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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

	pos_ratio = 1.0 + k * (dirty - bdi_setpoint)

where k is the negative slope.

If targeting for 12.5% fluctuation range in pos_ratio when dirty pages
are fluctuating in range

	[bdi_setpoint - write_bw/2, bdi_setpoint + write_bw/2],

we get slope

	k = - 1 / (8 * write_bw)

Let pos_ratio(x_intercept) = 0, we get the parameter used in code:

	x_intercept = bdi_setpoint + 8 * write_bw

The global/bdi slopes are nicely complementing each other when the
system has only one major bdi (indicated by bdi_thresh ~= thresh):

1) slope of global control line    => scaling to the control scope size
2) slope of main bdi control line  => scaling to the writeout bandwidth

so that

- in memory tight systems, (1) becomes strong enough to squeeze dirty
  pages inside the control scope

- in large memory systems where the "gravity" of (1) for pulling the
  dirty pages to setpoint is too weak, (2) can back (1) up and drive
  dirty pages to bdi_setpoint ~= setpoint reasonably fast.

Unfortunately in JBOD setups, the fluctuation range of bdi threshold
is related to memory size due to the interferences between disks.  In
this case, the bdi slope will be weighted sum of write_bw and bdi_thresh.

Given equations

        span = x_intercept - bdi_setpoint
        k = df/dx = - 1 / span

and the extremum values

        span = bdi_thresh
        dx = bdi_thresh

we get

        df = - dx / span = - 1.0

That means, when bdi_dirty deviates bdi_thresh up, pos_ratio and hence
task ratelimit will fluctuate by -100%.

peter: use 3rd order polynomial for the global control line

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |  191 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 190 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-10-03 11:28:31.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 21:05:10.000000000 +0800
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
@@ -495,6 +503,184 @@ unsigned long bdi_dirty_limit(struct bac
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
+ *     task_ratelimit = dirty_ratelimit * pos_ratio >> RATELIMIT_CALC_SHIFT
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
+ * (o) bdi control line
+ *
+ *     ^ pos_ratio
+ *     |
+ *     |            *
+ *     |              *
+ *     |                *
+ *     |                  *
+ *     |                    * |<=========== span ============>|
+ * 1.0 .......................*
+ *     |                      . *
+ *     |                      .   *
+ *     |                      .     *
+ *     |                      .       *
+ *     |                      .         *
+ *     |                      .           *
+ *     |                      .             *
+ *     |                      .               *
+ *     |                      .                 *
+ *     |                      .                   *
+ *     |                      .                     *
+ * 1/4 ...............................................* * * * * * * * * * * *
+ *     |                      .                         .
+ *     |                      .                           .
+ *     |                      .                             .
+ *   0 +----------------------.-------------------------------.------------->
+ *                bdi_setpoint^                    x_intercept^
+ *
+ * The bdi control line won't drop below pos_ratio=1/4, so that bdi_dirty can
+ * be smoothly throttled down to normal if it starts high in situations like
+ * - start writing to a slow SD card and a fast disk at the same time. The SD
+ *   card's bdi_dirty may rush to many times higher than bdi_setpoint.
+ * - the bdi dirty thresh drops quickly due to change of JBOD workload
+ */
+static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
+					unsigned long thresh,
+					unsigned long bg_thresh,
+					unsigned long dirty,
+					unsigned long bdi_thresh,
+					unsigned long bdi_dirty)
+{
+	unsigned long write_bw = bdi->avg_write_bandwidth;
+	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
+	unsigned long limit = hard_dirty_limit(thresh);
+	unsigned long x_intercept;
+	unsigned long setpoint;		/* dirty pages' target balance point */
+	unsigned long bdi_setpoint;
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
+	 *                           setpoint - dirty 3
+	 *        f(dirty) := 1.0 + (----------------)
+	 *                           limit - setpoint
+	 *
+	 * it's a 3rd order polynomial that subjects to
+	 *
+	 * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
+	 * (2) f(setpoint) = 1.0 => the balance point
+	 * (3) f(limit)    = 0   => the hard limit
+	 * (4) df/dx      <= 0	 => negative feedback control
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
+	 * We have computed basic pos_ratio above based on global situation. If
+	 * the bdi is over/under its share of dirty pages, we want to scale
+	 * pos_ratio further down/up. That is done by the following mechanism.
+	 */
+
+	/*
+	 * bdi setpoint
+	 *
+	 *        f(bdi_dirty) := 1.0 + k * (bdi_dirty - bdi_setpoint)
+	 *
+	 *                        x_intercept - bdi_dirty
+	 *                     := --------------------------
+	 *                        x_intercept - bdi_setpoint
+	 *
+	 * The main bdi control line is a linear function that subjects to
+	 *
+	 * (1) f(bdi_setpoint) = 1.0
+	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
+	 *     or equally: x_intercept = bdi_setpoint + 8 * write_bw
+	 *
+	 * For single bdi case, the dirty pages are observed to fluctuate
+	 * regularly within range
+	 *        [bdi_setpoint - write_bw/2, bdi_setpoint + write_bw/2]
+	 * for various filesystems, where (2) can yield in a reasonable 12.5%
+	 * fluctuation range for pos_ratio.
+	 *
+	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
+	 * own size, so move the slope over accordingly and choose a slope that
+	 * yields 100% pos_ratio fluctuation on suddenly doubled bdi_thresh.
+	 */
+	if (unlikely(bdi_thresh > thresh))
+		bdi_thresh = thresh;
+	/*
+	 * scale global setpoint to bdi's:
+	 *	bdi_setpoint = setpoint * bdi_thresh / thresh
+	 */
+	x = div_u64((u64)bdi_thresh << 16, thresh + 1);
+	bdi_setpoint = setpoint * (u64)x >> 16;
+	/*
+	 * Use span=(8*write_bw) in single bdi case as indicated by
+	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
+	 *
+	 *        bdi_thresh                    thresh - bdi_thresh
+	 * span = ---------- * (8 * write_bw) + ------------------- * bdi_thresh
+	 *          thresh                            thresh
+	 */
+	span = (thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16;
+	x_intercept = bdi_setpoint + span;
+
+	if (bdi_dirty < x_intercept - span / 4) {
+		pos_ratio *= x_intercept - bdi_dirty;
+		do_div(pos_ratio, x_intercept - bdi_setpoint + 1);
+	} else
+		pos_ratio /= 4;
+
+	return pos_ratio;
+}
+
 static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 				       unsigned long elapsed,
 				       unsigned long written)
@@ -655,6 +841,7 @@ static void balance_dirty_pages(struct a
 	unsigned long nr_reclaimable, bdi_nr_reclaimable;
 	unsigned long nr_dirty;  /* = file_dirty + writeback + unstable_nfs */
 	unsigned long bdi_dirty;
+	unsigned long freerun;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -679,7 +866,9 @@ static void balance_dirty_pages(struct a
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_dirty <= (background_thresh + dirty_thresh) / 2)
+		freerun = dirty_freerun_ceiling(dirty_thresh,
+						background_thresh);
+		if (nr_dirty <= freerun)
 			break;
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
