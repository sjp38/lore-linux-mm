Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF8106B0185
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:26 -0400 (EDT)
Message-Id: <20110904020914.980576896@intel.com>
Date: Sun, 04 Sep 2011 09:53:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/18] writeback: dirty rate control
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=dirty-ratelimit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It's all about bdi->dirty_ratelimit, which aims to be (write_bw / N)
when there are N dd tasks.

On write() syscall, use bdi->dirty_ratelimit
============================================

    balance_dirty_pages(pages_dirtied)
    {
        task_ratelimit = bdi->dirty_ratelimit * bdi_position_ratio();
        pause = pages_dirtied / task_ratelimit;
        sleep(pause);
    }

On every 200ms, update bdi->dirty_ratelimit
===========================================

    bdi_update_dirty_ratelimit()
    {
        task_ratelimit = bdi->dirty_ratelimit * bdi_position_ratio();
        balanced_dirty_ratelimit = task_ratelimit * write_bw / dirty_rate;
        bdi->dirty_ratelimit = balanced_dirty_ratelimit
    }

Estimation of balanced bdi->dirty_ratelimit
===========================================

balanced task_ratelimit
-----------------------

balance_dirty_pages() needs to throttle tasks dirtying pages such that
the total amount of dirty pages stays below the specified dirty limit in
order to avoid memory deadlocks. Furthermore we desire fairness in that
tasks get throttled proportionally to the amount of pages they dirty.

IOW we want to throttle tasks such that we match the dirty rate to the
writeout bandwidth, this yields a stable amount of dirty pages:

        dirty_rate == write_bw                                          (1)

The fairness requirement gives us:

        task_ratelimit = balanced_dirty_ratelimit
                       == write_bw / N                                  (2)

where N is the number of dd tasks.  We don't know N beforehand, but
still can estimate balanced_dirty_ratelimit within 200ms.

Start by throttling each dd task at rate

        task_ratelimit = task_ratelimit_0                               (3)
                         (any non-zero initial value is OK)

After 200ms, we measured

        dirty_rate = # of pages dirtied by all dd's / 200ms
        write_bw   = # of pages written to the disk / 200ms

For the aggressive dd dirtiers, the equality holds

        dirty_rate == N * task_rate
                   == N * task_ratelimit_0                              (4)
Or
        task_ratelimit_0 == dirty_rate / N                              (5)

Now we conclude that the balanced task ratelimit can be estimated by

                                                      write_bw
        balanced_dirty_ratelimit = task_ratelimit_0 * ----------        (6)
                                                      dirty_rate

Because with (4) and (5) we can get the desired equality (1):

                                                       write_bw
        balanced_dirty_ratelimit == (dirty_rate / N) * ----------
                                                       dirty_rate
                                 == write_bw / N

Then using the balanced task ratelimit we can compute task pause times like:

        task_pause = task->nr_dirtied / task_ratelimit

task_ratelimit with position control
------------------------------------

However, while the above gives us means of matching the dirty rate to
the writeout bandwidth, it at best provides us with a stable dirty page
count (assuming a static system). In order to control the dirty page
count such that it is high enough to provide performance, but does not
exceed the specified limit we need another control.

The dirty position control works by extending (2) to

        task_ratelimit = balanced_dirty_ratelimit * pos_ratio           (7)

where pos_ratio is a negative feedback function that subjects to

1) f(setpoint) = 1.0
2) df/dx < 0

That is, if the dirty pages are ABOVE the setpoint, we throttle each
task a bit more HEAVY than balanced_dirty_ratelimit, so that the dirty
pages are created less fast than they are cleaned, thus DROP to the
setpoints (and the reverse).

Based on (7) and the assumption that both dirty_ratelimit and pos_ratio
remains CONSTANT for the past 200ms, we get

        task_ratelimit_0 = balanced_dirty_ratelimit * pos_ratio         (8)

Putting (8) into (6), we get the formula used in
bdi_update_dirty_ratelimit():

                                                write_bw
        balanced_dirty_ratelimit *= pos_ratio * ----------              (9)
                                                dirty_rate

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
---
 include/linux/backing-dev.h |    7 ++
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |   82 +++++++++++++++++++++++++++++++++-
 3 files changed, 88 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2011-08-26 13:53:40.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-08-26 13:54:13.000000000 +0800
@@ -75,10 +75,17 @@ struct backing_dev_info {
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
 	unsigned long bw_time_stamp;	/* last time write bw is updated */
+	unsigned long dirtied_stamp;
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
 	unsigned long write_bandwidth;	/* the estimated write bandwidth */
 	unsigned long avg_write_bandwidth; /* further smoothed write bw */
 
+	/*
+	 * The base dirty throttle rate, re-calculated on every 200ms.
+	 * All the bdi tasks' dirty rate will be curbed under it.
+	 */
+	unsigned long dirty_ratelimit;
+
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
--- linux-next.orig/mm/backing-dev.c	2011-08-26 13:53:40.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-08-26 13:54:13.000000000 +0800
@@ -670,6 +670,7 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->bw_time_stamp = jiffies;
 	bdi->written_stamp = 0;
 
+	bdi->dirty_ratelimit = INIT_BW;
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
--- linux-next.orig/mm/page-writeback.c	2011-08-26 13:52:42.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-26 15:52:42.000000000 +0800
@@ -787,6 +787,78 @@ static void global_update_bandwidth(unsi
 	spin_unlock(&dirty_lock);
 }
 
+/*
+ * Maintain bdi->dirty_ratelimit, the base dirty throttle rate.
+ *
+ * Normal bdi tasks will be curbed at or below it in long term.
+ * Obviously it should be around (write_bw / N) when there are N dd tasks.
+ */
+static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
+				       unsigned long thresh,
+				       unsigned long bg_thresh,
+				       unsigned long dirty,
+				       unsigned long bdi_thresh,
+				       unsigned long bdi_dirty,
+				       unsigned long dirtied,
+				       unsigned long elapsed)
+{
+	unsigned long write_bw = bdi->avg_write_bandwidth;
+	unsigned long dirty_ratelimit = bdi->dirty_ratelimit;
+	unsigned long dirty_rate;
+	unsigned long task_ratelimit;
+	unsigned long balanced_dirty_ratelimit;
+	unsigned long pos_ratio;
+
+	/*
+	 * The dirty rate will match the writeout rate in long term, except
+	 * when dirty pages are truncated by userspace or re-dirtied by FS.
+	 */
+	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+
+	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
+				       bdi_thresh, bdi_dirty);
+	/*
+	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
+	 */
+	task_ratelimit = (u64)dirty_ratelimit *
+					pos_ratio >> RATELIMIT_CALC_SHIFT;
+
+	/*
+	 * A linear estimation of the "balanced" throttle rate. The theory is,
+	 * if there are N dd tasks, each throttled at task_ratelimit, the bdi's
+	 * dirty_rate will be measured to be (N * task_ratelimit). So the below
+	 * formula will yield the balanced rate limit (write_bw / N).
+	 *
+	 * Note that the expanded form is not a pure rate feedback:
+	 *	rate_(i+1) = rate_(i) * (write_bw / dirty_rate)		     (1)
+	 * but also takes pos_ratio into account:
+	 *	rate_(i+1) = rate_(i) * (write_bw / dirty_rate) * pos_ratio  (2)
+	 *
+	 * (1) is not realistic because pos_ratio also takes part in balancing
+	 * the dirty rate.  Consider the state
+	 *	pos_ratio = 0.5						     (3)
+	 *	rate = 2 * (write_bw / N)				     (4)
+	 * If (1) is used, it will stuck in that state! Because each dd will
+	 * be throttled at
+	 *	task_ratelimit = pos_ratio * rate = (write_bw / N)	     (5)
+	 * yielding
+	 *	dirty_rate = N * task_ratelimit = write_bw		     (6)
+	 * put (6) into (1) we get
+	 *	rate_(i+1) = rate_(i)					     (7)
+	 *
+	 * So we end up using (2) to always keep
+	 *	rate_(i+1) ~= (write_bw / N)				     (8)
+	 * regardless of the value of pos_ratio. As long as (8) is satisfied,
+	 * pos_ratio is able to drive itself to 1.0, which is not only where
+	 * the dirty count meet the setpoint, but also where the slope of
+	 * pos_ratio is most flat and hence task_ratelimit is least fluctuated.
+	 */
+	balanced_dirty_ratelimit = div_u64((u64)task_ratelimit * write_bw,
+					   dirty_rate | 1);
+
+	bdi->dirty_ratelimit = max(balanced_dirty_ratelimit, 1UL);
+}
+
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
 			    unsigned long bg_thresh,
@@ -797,6 +869,7 @@ void __bdi_update_bandwidth(struct backi
 {
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - bdi->bw_time_stamp;
+	unsigned long dirtied;
 	unsigned long written;
 
 	/*
@@ -805,6 +878,7 @@ void __bdi_update_bandwidth(struct backi
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
+	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
 
 	/*
@@ -814,12 +888,16 @@ void __bdi_update_bandwidth(struct backi
 	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
 		goto snapshot;
 
-	if (thresh)
+	if (thresh) {
 		global_update_bandwidth(thresh, dirty, now);
-
+		bdi_update_dirty_ratelimit(bdi, thresh, bg_thresh, dirty,
+					   bdi_thresh, bdi_dirty,
+					   dirtied, elapsed);
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
