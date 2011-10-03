Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8F0A29000D4
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:55 -0400 (EDT)
Message-Id: <20111003134536.755232554@intel.com>
Date: Mon, 03 Oct 2011 21:42:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/11] writeback: stabilize bdi->dirty_ratelimit
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=dirty-ratelimit-stablize
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

There are some imperfections in balanced_dirty_ratelimit.

1) large fluctuations

The dirty_rate used for computing balanced_dirty_ratelimit is merely
averaged in the past 200ms (very small comparing to the 3s estimation
period for write_bw), which makes rather dispersed distribution of
balanced_dirty_ratelimit.

It's pretty hard to average out the singular points by increasing the
estimation period. Considering that the averaging technique will
introduce very undesirable time lags, I give it up totally. (btw, the 3s
write_bw averaging time lag is much more acceptable because its impact
is one-way and therefore won't lead to oscillations.)

The more practical way is filtering -- most singular
balanced_dirty_ratelimit points can be filtered out by remembering some
prev_balanced_rate and prev_prev_balanced_rate. However the more
reliable way is to guard balanced_dirty_ratelimit with task_ratelimit.

2) due to truncates and fs redirties, the (write_bw <=> dirty_rate)
match could become unbalanced, which may lead to large systematical
errors in balanced_dirty_ratelimit. The truncates, due to its possibly
bumpy nature, can hardly be compensated smoothly. So let's face it. When
some over-estimated balanced_dirty_ratelimit brings dirty_ratelimit
high, dirty pages will go higher than the setpoint. task_ratelimit will
in turn become lower than dirty_ratelimit.  So if we consider both
balanced_dirty_ratelimit and task_ratelimit and update dirty_ratelimit
only when they are on the same side of dirty_ratelimit, the systematical
errors in balanced_dirty_ratelimit won't be able to bring
dirty_ratelimit far away.

The balanced_dirty_ratelimit estimation may also be inaccurate near
@limit or @freerun, however is less an issue.

3) since we ultimately want to

- keep the fluctuations of task ratelimit as small as possible
- keep the dirty pages around the setpoint as long time as possible

the update policy used for (2) also serves the above goals nicely:
if for some reason the dirty pages are high (task_ratelimit < dirty_ratelimit),
and dirty_ratelimit is low (dirty_ratelimit < balanced_dirty_ratelimit),
there is no point to bring up dirty_ratelimit in a hurry only to hurt
both the above two goals.

So, we make use of task_ratelimit to limit the update of dirty_ratelimit
in two ways:

1) avoid changing dirty rate when it's against the position control target
   (the adjusted rate will slow down the progress of dirty pages going
   back to setpoint).

2) limit the step size. task_ratelimit is changing values step by step,
   leaving a consistent trace comparing to the randomly jumping
   balanced_dirty_ratelimit. task_ratelimit also has the nice smaller
   errors in stable state and typically larger errors when there are big
   errors in rate.  So it's a pretty good limiting factor for the step
   size of dirty_ratelimit.

Note that bdi->dirty_ratelimit is always tracking balanced_dirty_ratelimit.
task_ratelimit is merely used as a limiting factor.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    3 +
 mm/backing-dev.c            |    1 
 mm/page-writeback.c         |   71 +++++++++++++++++++++++++++++++++-
 3 files changed, 74 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-10-02 10:28:27.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 11:18:20.000000000 +0800
@@ -792,12 +792,17 @@ static void bdi_update_dirty_ratelimit(s
 				       unsigned long dirtied,
 				       unsigned long elapsed)
 {
+	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
+	unsigned long limit = hard_dirty_limit(thresh);
+	unsigned long setpoint = (freerun + limit) / 2;
 	unsigned long write_bw = bdi->avg_write_bandwidth;
 	unsigned long dirty_ratelimit = bdi->dirty_ratelimit;
 	unsigned long dirty_rate;
 	unsigned long task_ratelimit;
 	unsigned long balanced_dirty_ratelimit;
 	unsigned long pos_ratio;
+	unsigned long step;
+	unsigned long x;
 
 	/*
 	 * The dirty rate will match the writeout rate in long term, except
@@ -847,7 +852,71 @@ static void bdi_update_dirty_ratelimit(s
 	balanced_dirty_ratelimit = div_u64((u64)task_ratelimit * write_bw,
 					   dirty_rate | 1);
 
-	bdi->dirty_ratelimit = max(balanced_dirty_ratelimit, 1UL);
+	/*
+	 * We could safely do this and return immediately:
+	 *
+	 *	bdi->dirty_ratelimit = balanced_dirty_ratelimit;
+	 *
+	 * However to get a more stable dirty_ratelimit, the below elaborated
+	 * code makes use of task_ratelimit to filter out sigular points and
+	 * limit the step size.
+	 *
+	 * The below code essentially only uses the relative value of
+	 *
+	 *	task_ratelimit - dirty_ratelimit
+	 *	= (pos_ratio - 1) * dirty_ratelimit
+	 *
+	 * which reflects the direction and size of dirty position error.
+	 */
+
+	/*
+	 * dirty_ratelimit will follow balanced_dirty_ratelimit iff
+	 * task_ratelimit is on the same side of dirty_ratelimit, too.
+	 * For example, when
+	 * - dirty_ratelimit > balanced_dirty_ratelimit
+	 * - dirty_ratelimit > task_ratelimit (dirty pages are above setpoint)
+	 * lowering dirty_ratelimit will help meet both the position and rate
+	 * control targets. Otherwise, don't update dirty_ratelimit if it will
+	 * only help meet the rate target. After all, what the users ultimately
+	 * feel and care are stable dirty rate and small position error.
+	 *
+	 * |task_ratelimit - dirty_ratelimit| is used to limit the step size
+	 * and filter out the sigular points of balanced_dirty_ratelimit. Which
+	 * keeps jumping around randomly and can even leap far away at times
+	 * due to the small 200ms estimation period of dirty_rate (we want to
+	 * keep that period small to reduce time lags).
+	 */
+	step = 0;
+	if (dirty < setpoint) {
+		x = min(bdi->balanced_dirty_ratelimit,
+			 min(balanced_dirty_ratelimit, task_ratelimit));
+		if (dirty_ratelimit < x)
+			step = x - dirty_ratelimit;
+	} else {
+		x = max(bdi->balanced_dirty_ratelimit,
+			 max(balanced_dirty_ratelimit, task_ratelimit));
+		if (dirty_ratelimit > x)
+			step = dirty_ratelimit - x;
+	}
+
+	/*
+	 * Don't pursue 100% rate matching. It's impossible since the balanced
+	 * rate itself is constantly fluctuating. So decrease the track speed
+	 * when it gets close to the target. Helps eliminate pointless tremors.
+	 */
+	step >>= dirty_ratelimit / (2 * step + 1);
+	/*
+	 * Limit the tracking speed to avoid overshooting.
+	 */
+	step = (step + 7) / 8;
+
+	if (dirty_ratelimit < balanced_dirty_ratelimit)
+		dirty_ratelimit += step;
+	else
+		dirty_ratelimit -= step;
+
+	bdi->dirty_ratelimit = max(dirty_ratelimit, 1UL);
+	bdi->balanced_dirty_ratelimit = balanced_dirty_ratelimit;
 }
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
--- linux-next.orig/include/linux/backing-dev.h	2011-10-03 11:17:53.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-10-03 11:18:20.000000000 +0800
@@ -83,8 +83,11 @@ struct backing_dev_info {
 	/*
 	 * The base dirty throttle rate, re-calculated on every 200ms.
 	 * All the bdi tasks' dirty rate will be curbed under it.
+	 * @dirty_ratelimit tracks the estimated @balanced_dirty_ratelimit
+	 * in small steps and is much more smooth/stable than the latter.
 	 */
 	unsigned long dirty_ratelimit;
+	unsigned long balanced_dirty_ratelimit;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/backing-dev.c	2011-10-03 11:18:51.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-10-03 11:20:16.000000000 +0800
@@ -686,6 +686,7 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->bw_time_stamp = jiffies;
 	bdi->written_stamp = 0;
 
+	bdi->balanced_dirty_ratelimit = INIT_BW;
 	bdi->dirty_ratelimit = INIT_BW;
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
