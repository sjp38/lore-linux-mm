Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 69F146B00EE
	for <linux-mm@kvack.org>; Sat,  6 Aug 2011 08:20:03 -0400 (EDT)
Message-Id: <20110806094526.878435971@intel.com>
Date: Sat, 06 Aug 2011 16:44:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] writeback: dirty rate control
References: <20110806084447.388624428@intel.com>
Content-Disposition: inline; filename=dirty-ratelimit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It's all about bdi->dirty_ratelimit, which aims to be (write_bw / N)
when there are N dd tasks.

On write() syscall, use bdi->dirty_ratelimit
============================================

    balance_dirty_pages(pages_dirtied)
    {
        pos_bw = bdi->dirty_ratelimit * bdi_position_ratio();
        pause = pages_dirtied / pos_bw;
        sleep(pause);
    }

On every 200ms, update bdi->dirty_ratelimit
===========================================

    bdi_update_dirty_ratelimit()
    {
        bw = bdi->dirty_ratelimit;
        ref_bw = bw * bdi_position_ratio() * write_bw / dirty_bw;
        if (dirty pages unbalanced)
             bdi->dirty_ratelimit = (bw * 3 + ref_bw) / 4;
    }

Estimation of balanced bdi->dirty_ratelimit
===========================================

When started N dd, throttle each dd at

         task_ratelimit = pos_bw (any non-zero initial value is OK)

After 200ms, we got

         dirty_bw = # of pages dirtied by app / 200ms
         write_bw = # of pages written to disk / 200ms

For aggressive dirtiers, the equality holds

         dirty_bw == N * task_ratelimit
                  == N * pos_bw                      	(1)

The balanced throttle bandwidth can be estimated by

         ref_bw = pos_bw * write_bw / dirty_bw       	(2)

>From (1) and (2), we get equality

         ref_bw == write_bw / N                      	(3)

If the N dd's are all throttled at ref_bw, the dirty/writeback rates
will match. So ref_bw is the balanced dirty rate.

In practice, the ref_bw calculated by (2) may fluctuate and have
estimation errors. So the bdi->dirty_ratelimit update policy is to
follow it only when both pos_bw and ref_bw point to the same direction
(indicating not only the dirty position has deviated from the global/bdi
setpoints, but also it's still departing away).

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    7 +++
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |   69 +++++++++++++++++++++++++++++++++-
 3 files changed, 75 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2011-08-05 18:05:36.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-08-05 18:05:36.000000000 +0800
@@ -75,10 +75,17 @@ struct backing_dev_info {
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
 	unsigned long bw_time_stamp;	/* last time write bw is updated */
+	unsigned long dirtied_stamp;
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
 	unsigned long write_bandwidth;	/* the estimated write bandwidth */
 	unsigned long avg_write_bandwidth; /* further smoothed write bw */
 
+	/*
+	 * The base throttle bandwidth, re-calculated on every 200ms.
+	 * All the bdi tasks' dirty rate will be curbed under it.
+	 */
+	unsigned long dirty_ratelimit;
+
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
--- linux-next.orig/mm/backing-dev.c	2011-08-05 18:05:36.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-08-05 18:05:36.000000000 +0800
@@ -674,6 +674,7 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->bw_time_stamp = jiffies;
 	bdi->written_stamp = 0;
 
+	bdi->dirty_ratelimit = INIT_BW;
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
--- linux-next.orig/mm/page-writeback.c	2011-08-05 18:05:36.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-06 09:08:35.000000000 +0800
@@ -736,6 +736,66 @@ static void global_update_bandwidth(unsi
 	spin_unlock(&dirty_lock);
 }
 
+/*
+ * Maintain bdi->dirty_ratelimit, the base throttle bandwidth.
+ *
+ * Normal bdi tasks will be curbed at or below it in long term.
+ * Obviously it should be around (write_bw / N) when there are N dd tasks.
+ */
+static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
+				       unsigned long thresh,
+				       unsigned long dirty,
+				       unsigned long bdi_thresh,
+				       unsigned long bdi_dirty,
+				       unsigned long dirtied,
+				       unsigned long elapsed)
+{
+	unsigned long bw = bdi->dirty_ratelimit;
+	unsigned long dirty_bw;
+	unsigned long pos_bw;
+	unsigned long ref_bw;
+	unsigned long long pos_ratio;
+
+	/*
+	 * The dirty rate will match the writeback rate in long term, except
+	 * when dirty pages are truncated by userspace or re-dirtied by FS.
+	 */
+	dirty_bw = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+
+	pos_ratio = bdi_position_ratio(bdi, thresh, dirty,
+				       bdi_thresh, bdi_dirty);
+	/*
+	 * pos_bw reflects each dd's dirty rate enforced for the past 200ms.
+	 */
+	pos_bw = bw * pos_ratio >> BANDWIDTH_CALC_SHIFT;
+	pos_bw++;  /* this avoids bdi->dirty_ratelimit get stuck in 0 */
+
+	/*
+	 * ref_bw = pos_bw * write_bw / dirty_bw
+	 *
+	 * It's a linear estimation of the "balanced" throttle bandwidth.
+	 */
+	pos_ratio *= bdi->avg_write_bandwidth;
+	do_div(pos_ratio, dirty_bw | 1);
+	ref_bw = bw * pos_ratio >> BANDWIDTH_CALC_SHIFT;
+
+	/*
+	 * dirty_ratelimit will follow ref_bw/pos_bw conservatively iff they
+	 * are on the same side of dirty_ratelimit. Which not only makes it
+	 * more stable, but also is essential for preventing it being driven
+	 * away by possible systematic errors in ref_bw.
+	 */
+	if (pos_bw < bw) {
+		if (ref_bw < bw)
+			bw = max(ref_bw, pos_bw);
+	} else {
+		if (ref_bw > bw)
+			bw = min(ref_bw, pos_bw);
+	}
+
+	bdi->dirty_ratelimit = bw;
+}
+
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
 			    unsigned long dirty,
@@ -745,6 +805,7 @@ void __bdi_update_bandwidth(struct backi
 {
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - bdi->bw_time_stamp;
+	unsigned long dirtied;
 	unsigned long written;
 
 	/*
@@ -753,6 +814,7 @@ void __bdi_update_bandwidth(struct backi
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
+	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
 
 	/*
@@ -762,12 +824,15 @@ void __bdi_update_bandwidth(struct backi
 	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
 		goto snapshot;
 
-	if (thresh)
+	if (thresh) {
 		global_update_bandwidth(thresh, dirty, now);
-
+		bdi_update_dirty_ratelimit(bdi, thresh, dirty, bdi_thresh,
+					   bdi_dirty, dirtied, elapsed);
+	}
 	bdi_update_write_bandwidth(bdi, elapsed, written);
 
 snapshot:
+	bdi->dirtied_stamp = dirtied;
 	bdi->written_stamp = written;
 	bdi->bw_time_stamp = now;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
