Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2CB4A6B016A
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 08:20:03 -0400 (EDT)
Message-Id: <20110806094526.733282037@intel.com>
Date: Sat, 06 Aug 2011 16:44:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/5] writeback: dirty position control
References: <20110806084447.388624428@intel.com>
Content-Disposition: inline; filename=writeback-control-algorithms.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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

For simplicity, only the global/bdi setpoint control lines are
implemented here, so the [*] curve is more straight than the ideal one
showed in the above figure.

bdi_position_ratio() provides a scale factor to bdi->dirty_ratelimit, so
that the resulted task rate limit can drive the dirty pages back to the
global/bdi setpoints.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |  143 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 143 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-06 10:31:32.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-06 11:17:07.000000000 +0800
@@ -46,6 +46,8 @@
  */
 #define BANDWIDTH_INTERVAL	max(HZ/5, 1)
 
+#define BANDWIDTH_CALC_SHIFT	10
+
 /*
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  * will look to see if it needs to force writeback or throttling.
@@ -495,6 +497,147 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+/*
+ * Dirty position control.
+ *
+ * (o) global/bdi setpoints
+ *
+ *  When the number of dirty pages go higher/lower than the setpoint, the dirty
+ *  position ratio (and hence dirty rate limit) will be decreased/increased to
+ *  bring the dirty pages back to the setpoint.
+ *
+ *                              setpoint
+ *                                 v
+ * |-------------------------------*-------------------------------|-----------|
+ * ^                               ^                               ^           ^
+ * (thresh + background_thresh)/2  thresh - thresh/DIRTY_SCOPE     thresh  limit
+ *
+ *                          bdi setpoint
+ *                                 v
+ * |-------------------------------*-------------------------------------------|
+ * ^                               ^                                           ^
+ * 0                               bdi_thresh - bdi_thresh/DIRTY_SCOPE     limit
+ *
+ * (o) pseudo code
+ *
+ *     pos_ratio = 1 << BANDWIDTH_CALC_SHIFT
+ *
+ *     if (dirty < thresh) scale up   pos_ratio
+ *     if (dirty > thresh) scale down pos_ratio
+ *
+ *     if (bdi_dirty < bdi_thresh) scale up   pos_ratio
+ *     if (bdi_dirty > bdi_thresh) scale down pos_ratio
+ *
+ * (o) global/bdi control lines
+ *
+ * Based on the number of dirty pages (the X), pos_ratio (the Y) is scaled by
+ * several control lines in turn.
+ *
+ * The control lines for the global/bdi setpoints both stretch up to @limit.
+ * If any control line drops below Y=0 before reaching @limit, an auxiliary
+ * line will be setup to connect them. The below figure illustrates the main
+ * bdi control line with an auxiliary line extending it to @limit.
+ *
+ * This allows smoothly throttling bdi_dirty down to normal if it starts high
+ * in situations like
+ * - start writing to a slow SD card and a fast disk at the same time. The SD
+ *   card's bdi_dirty may rush to 5 times higher than bdi setpoint.
+ * - the bdi dirty thresh goes down quickly due to change of JBOD workload
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
+ *  [--------------------+-----------------------------.--------------------*]
+ *  0                 bdi setpoint                 bdi origin            limit
+ *
+ * The bdi control line: if (origin < limit), an auxiliary control line (*)
+ * will be setup to extend the main control line (o) to @limit.
+ */
+static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
+					unsigned long thresh,
+					unsigned long dirty,
+					unsigned long bdi_thresh,
+					unsigned long bdi_dirty)
+{
+	unsigned long limit = hard_dirty_limit(thresh);
+	unsigned long origin;
+	unsigned long goal;
+	unsigned long long span;
+	unsigned long long pos_ratio;	/* for scaling up/down the rate limit */
+
+	if (unlikely(dirty >= limit))
+		return 0;
+
+	/*
+	 * global setpoint
+	 */
+	goal = thresh - thresh / DIRTY_SCOPE;
+	origin = 4 * thresh;
+
+	if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
+		origin = limit;			/* auxiliary control line */
+		goal = (goal + origin) / 2;
+		pos_ratio >>= 1;
+	}
+	pos_ratio = origin - dirty;
+	pos_ratio <<= BANDWIDTH_CALC_SHIFT;
+	do_div(pos_ratio, origin - goal + 1);
+
+	/*
+	 * bdi setpoint
+	 */
+	if (unlikely(bdi_thresh > thresh))
+		bdi_thresh = thresh;
+	goal = bdi_thresh - bdi_thresh / DIRTY_SCOPE;
+	/*
+	 * Use span=(4*bw) in single disk case and transit to bdi_thresh in
+	 * JBOD case.  For JBOD, bdi_thresh could fluctuate up to its own size.
+	 * Otherwise the bdi write bandwidth is good for limiting the floating
+	 * area, which makes the bdi control line a good backup when the global
+	 * control line is too flat/weak in large memory systems.
+	 */
+	span = (u64) bdi_thresh * (thresh - bdi_thresh) +
+		(4 * bdi->avg_write_bandwidth) * bdi_thresh;
+	do_div(span, thresh + 1);
+	origin = goal + 2 * span;
+
+	if (unlikely(bdi_dirty > goal + span)) {
+		if (bdi_dirty > limit)
+			return 0;
+		if (origin < limit) {
+			origin = limit;		/* auxiliary control line */
+			goal += span;
+			pos_ratio >>= 1;
+		}
+	}
+	pos_ratio *= origin - bdi_dirty;
+	do_div(pos_ratio, origin - goal + 1);
+
+	return pos_ratio;
+}
+
 static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 				       unsigned long elapsed,
 				       unsigned long written)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
