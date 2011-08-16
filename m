Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7698E6B016C
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 23:30:26 -0400 (EDT)
Message-Id: <20110816022328.937409855@intel.com>
Date: Tue, 16 Aug 2011 10:20:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] writeback: dirty rate control
References: <20110816022006.348714319@intel.com>
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
    	pos_rate = ratelimit_in_past_200ms
		 = bdi->dirty_ratelimit * bdi_position_ratio();

	balanced_rate = ratelimit_in_past_200ms * write_bw / dirty_rate;

        update bdi->dirty_ratelimit closer to balanced_rate and pos_rate
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

	ratelimit = write_bw						(1)

The fairness requirement gives us:

        task_ratelimit = write_bw / N					(2)

where N is the number of dd tasks.  We don't know N beforehand, but
still can estimate the balanced task_ratelimit within 200ms.

Start by throttling each dd task at rate

        task_ratelimit = task_ratelimit_0				(3)
 		  	 (any non-zero initial value is OK)

After 200ms, we measured

        dirty_rate = # of pages dirtied by all dd's / 200ms
        write_bw   = # of pages written to the disk / 200ms

For the aggressive dd dirtiers, the equality holds

	dirty_rate == N * task_rate
                   == N * task_ratelimit
                   == N * task_ratelimit_0            			(4)
Or
	task_ratelimit_0 = dirty_rate / N            			(5)

Now we conclude that the balanced task ratelimit can be estimated by

        task_ratelimit = task_ratelimit_0 * (write_bw / dirty_rate)	(6)

Because with (4) and (5) we can get the desired equality (1):

	task_ratelimit == (dirty_rate / N) * (write_bw / dirty_rate)
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

The dirty position control works by splitting (6) to

        task_ratelimit = balanced_rate					(7)
        balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)	(8)

and extend (7) to

        task_ratelimit = balanced_rate * pos_ratio			(9)

where pos_ratio is a negative feedback function that subjects to

1) f(setpoint) = 1.0
2) df/dx < 0

That is, if the dirty pages are ABOVE the setpoint, we throttle each
task a bit more HEAVY than balanced_rate, so that the dirty pages are
created less fast than they are cleaned, thus DROP to the setpoints
(and the reverse).

bdi->dirty_ratelimit update policy
----------------------------------

The balanced_rate calculated by (8) is not suitable for direct use (*).
For the reasons listed below, (9) is further transformed into

	task_ratelimit = dirty_ratelimit * pos_ratio			(10)

where dirty_ratelimit will be tracking balanced_rate _conservatively_.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
(*) There are some imperfections in balanced_rate, which make it not
suitable for direct use:

1) large fluctuations

The dirty_rate used for computing balanced_rate is merely averaged in
the past 200ms (very small comparing to the 3s estimation period for
write_bw), which makes rather dispersed distribution of balanced_rate.

It's pretty hard to average out the singular points by increasing the
estimation period. Considering that the averaging technique will
introduce very undesirable time lags, I give it up totally. (btw, the 3s
write_bw averaging time lag is much more acceptable because its impact
is one-way and therefore won't lead to oscillations.)

The more practical way is filtering -- most singular balanced_rate
points can be filtered out by remembering some prev_balanced_rate and
prev_prev_balanced_rate. However the more reliable way is to guard
balanced_rate with pos_rate.

2) due to truncates and fs redirties, the (write_bw <=> dirty_rate)
match could become unbalanced, which may lead to large systematical
errors in balanced_rate. The truncates, due to its possibly bumpy
nature, can hardly be compensated smoothly. So let's face it. When some
over-estimated balanced_rate brings dirty_ratelimit high, dirty pages
will go higher than the setpoint. pos_rate will in turn become lower
than dirty_ratelimit.  So if we consider both balanced_rate and pos_rate
and update dirty_ratelimit only when they are on the same side of
dirty_ratelimit, the systematical errors in balanced_rate won't be able
to bring dirty_ratelimit far away.

The balanced_rate estimation may also be inaccurate when near the max
pause and free run areas, however is less an issue.

3) since we ultimately want to

- keep the fluctuations of task ratelimit as small as possible
- keep the dirty pages around the setpoint as long time as possible

the update policy used for (2) also serves the above goals nicely:
if for some reason the dirty pages are high (pos_rate < dirty_ratelimit),
and dirty_ratelimit is low (dirty_ratelimit < balanced_rate), there is
no point to bring up dirty_ratelimit in a hurry only to hurt both the
above two goals.

In summary, the dirty_ratelimit update policy consists of two constraints:

1) avoid changing dirty rate when it's against the position control target
   (the adjusted rate will slow down the progress of dirty pages going
   back to setpoint).

2) limit the step size. pos_rate is changing values step by step,
   leaving a consistent trace comparing to the randomly jumping
   balanced_rate. pos_rate also has the nice smaller errors in stable
   state and typically larger errors when there are big errors in rate.
   So it's a pretty good limiting factor for the step size of dirty_ratelimit.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
---
 include/linux/backing-dev.h |    7 ++
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |  108 +++++++++++++++++++++++++++++++++-
 3 files changed, 114 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2011-08-16 10:07:22.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-08-16 10:07:23.000000000 +0800
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
 
--- linux-next.orig/mm/backing-dev.c	2011-08-16 10:07:22.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-08-16 10:07:23.000000000 +0800
@@ -674,6 +674,7 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->bw_time_stamp = jiffies;
 	bdi->written_stamp = 0;
 
+	bdi->dirty_ratelimit = INIT_BW;
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
--- linux-next.orig/mm/page-writeback.c	2011-08-16 10:07:22.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-16 10:13:33.000000000 +0800
@@ -773,6 +773,104 @@ static void global_update_bandwidth(unsi
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
+	unsigned long base_rate = bdi->dirty_ratelimit;
+	unsigned long dirty_rate;
+	unsigned long executed_rate;
+	unsigned long balanced_rate;
+	unsigned long pos_rate;
+	unsigned long delta;
+	unsigned long pos_ratio;
+
+	/*
+	 * The dirty rate will match the writeback rate in long term, except
+	 * when dirty pages are truncated by userspace or re-dirtied by FS.
+	 */
+	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+
+	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
+				       bdi_thresh, bdi_dirty);
+	/*
+	 * executed_rate reflects each dd's dirty rate for the past 200ms.
+	 */
+	executed_rate = (u64)base_rate * pos_ratio >> RATELIMIT_CALC_SHIFT;
+
+	/*
+	 * A linear estimation of the "balanced" throttle bandwidth.
+	 */
+	balanced_rate = div_u64((u64)executed_rate * bdi->avg_write_bandwidth,
+				dirty_rate | 1);
+
+	/*
+	 * Use a different name for the same value to distinguish the concepts.
+	 * Only the relative value of
+	 *     (pos_rate - base_rate) = (pos_ratio - 1) * base_rate
+	 * will be used below, which reflects the direction and size of dirty
+	 * position error.
+	 */
+	pos_rate = executed_rate;
+
+	/*
+	 * dirty_ratelimit will follow balanced_rate iff pos_rate is on the
+	 * same side of dirty_ratelimit, too.
+	 * For example,
+	 * - (base_rate > balanced_rate) => dirty rate is too high
+	 * - (base_rate > pos_rate)      => dirty pages are above setpoint
+	 * so lowering base_rate will help meet both the position and rate
+	 * control targets. Otherwise, don't update base_rate if it will only
+	 * help meet the rate target. After all, what the users ultimately feel
+	 * and care are stable dirty rate and small position error.  This
+	 * update policy can also prevent dirty_ratelimit from being driven
+	 * away by possible systematic errors in balanced_rate.
+	 *
+	 * |base_rate - pos_rate| is also used to limit the step size for
+	 * filtering out the sigular points of balanced_rate, which keeps
+	 * jumping around randomly and can even leap far away at times due to
+	 * the small 200ms estimation period of dirty_rate (we want to keep
+	 * that period small to reduce time lags).
+	 */
+	delta = 0;
+	if (base_rate < balanced_rate) {
+		if (base_rate < pos_rate)
+			delta = min(balanced_rate, pos_rate) - base_rate;
+	} else {
+		if (base_rate > pos_rate)
+			delta = base_rate - max(balanced_rate, pos_rate);
+	}
+
+	/*
+	 * Don't pursue 100% rate matching. It's impossible since the balanced
+	 * rate itself is constantly fluctuating. So decrease the track speed
+	 * when it gets close to the target. Helps eliminate pointless tremors.
+	 */
+	delta >>= base_rate / (8 * delta + 1);
+	/*
+	 * Limit the tracking speed to avoid overshooting.
+	 */
+	delta = (delta + 7) / 8;
+
+	if (base_rate < balanced_rate)
+		base_rate += delta;
+	else
+		base_rate -= delta;
+
+	bdi->dirty_ratelimit = max(base_rate, 1);
+}
+
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
 			    unsigned long bg_thresh,
@@ -783,6 +881,7 @@ void __bdi_update_bandwidth(struct backi
 {
 	unsigned long now = jiffies;
 	unsigned long elapsed = now - bdi->bw_time_stamp;
+	unsigned long dirtied;
 	unsigned long written;
 
 	/*
@@ -791,6 +890,7 @@ void __bdi_update_bandwidth(struct backi
 	if (elapsed < BANDWIDTH_INTERVAL)
 		return;
 
+	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
 
 	/*
@@ -800,12 +900,16 @@ void __bdi_update_bandwidth(struct backi
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
