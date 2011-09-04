Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CC565900146
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020915.512367354@intel.com>
Date: Sun, 04 Sep 2011 09:53:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/18] writeback: dirty ratelimit - think time compensation
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=think-time-compensation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Compensate the task's think time when computing the final pause time,
so that ->dirty_ratelimit can be executed accurately.

        think time := time spend outside of balance_dirty_pages()

In the rare case that the task slept longer than the 200ms period time
(result in negative pause time), the sleep time will be compensated in
the following periods, too, if it's less than 1 second.

Accumulated errors are carefully avoided as long as the max pause area
is not hitted.

Pseudo code:

        period = pages_dirtied / task_ratelimit;
        think = jiffies - dirty_paused_when;
        pause = period - think;

1) normal case: period > think

        pause = period - think
        dirty_paused_when = jiffies + pause
        nr_dirtied = 0

                             period time
              |===============================>|
                  think time      pause time
              |===============>|==============>|
        ------|----------------|---------------|------------------------
        dirty_paused_when   jiffies


2) no pause case: period <= think

        don't pause; reduce future pause time by:
        dirty_paused_when += period
        nr_dirtied = 0

                           period time
              |===============================>|
                                  think time
              |===================================================>|
        ------|--------------------------------+-------------------|----
        dirty_paused_when                                       jiffies

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/sched.h |    1 +
 kernel/fork.c         |    1 +
 mm/page-writeback.c   |   34 +++++++++++++++++++++++++++++++---
 3 files changed, 33 insertions(+), 3 deletions(-)

--- linux-next.orig/include/linux/sched.h	2011-08-26 20:09:04.000000000 +0800
+++ linux-next/include/linux/sched.h	2011-08-26 20:09:19.000000000 +0800
@@ -1527,6 +1527,7 @@ struct task_struct {
 	 */
 	int nr_dirtied;
 	int nr_dirtied_pause;
+	unsigned long dirty_paused_when; /* start of a write-and-pause period */
 
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
--- linux-next.orig/mm/page-writeback.c	2011-08-26 20:09:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-26 20:09:19.000000000 +0800
@@ -958,6 +958,7 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	long period;
 	long pause = 0;
 	bool dirty_exceeded = false;
 	unsigned long task_ratelimit;
@@ -967,6 +968,8 @@ static void balance_dirty_pages(struct a
 	unsigned long start_time = jiffies;
 
 	for (;;) {
+		unsigned long now = jiffies;
+
 		/*
 		 * Unstable writes are a feature of certain networked
 		 * filesystems (i.e. NFS) in which data may have been
@@ -985,8 +988,11 @@ static void balance_dirty_pages(struct a
 		 * when the bdi limits are ramping up.
 		 */
 		if (nr_dirty <= dirty_freerun_ceiling(dirty_thresh,
-						      background_thresh))
+						      background_thresh)) {
+			current->dirty_paused_when = now;
+			current->nr_dirtied = 0;
 			break;
+		}
 
 		if (unlikely(!writeback_in_progress(bdi)))
 			bdi_start_background_writeback(bdi);
@@ -1037,18 +1043,41 @@ static void balance_dirty_pages(struct a
 					       background_thresh, nr_dirty,
 					       bdi_thresh, bdi_dirty);
 		if (unlikely(pos_ratio == 0)) {
+			period = MAX_PAUSE;
 			pause = MAX_PAUSE;
 			goto pause;
 		}
 		task_ratelimit = (u64)dirty_ratelimit *
 					pos_ratio >> RATELIMIT_CALC_SHIFT;
-		pause = (HZ * pages_dirtied) / (task_ratelimit | 1);
+		period = (HZ * pages_dirtied) / (task_ratelimit | 1);
+		pause = current->dirty_paused_when + period - now;
+		/*
+		 * For less than 1s think time (ext3/4 may block the dirtier
+		 * for up to 800ms from time to time on 1-HDD; so does xfs,
+		 * however at much less frequency), try to compensate it in
+		 * future periods by updating the virtual time; otherwise just
+		 * do a reset, as it may be a light dirtier.
+		 */
+		if (unlikely(pause <= 0)) {
+			if (pause < -HZ) {
+				current->dirty_paused_when = now;
+				current->nr_dirtied = 0;
+			} else if (period) {
+				current->dirty_paused_when += period;
+				current->nr_dirtied = 0;
+			}
+			pause = 1; /* avoid resetting nr_dirtied_pause below */
+			break;
+		}
 		pause = min_t(long, pause, MAX_PAUSE);
 
 pause:
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
 
+		current->dirty_paused_when = now + pause;
+		current->nr_dirtied = 0;
+
 		dirty_thresh = hard_dirty_limit(dirty_thresh);
 		/*
 		 * max-pause area. If dirty exceeded but still within this
@@ -1063,7 +1092,6 @@ pause:
 	if (!dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
-	current->nr_dirtied = 0;
 	current->nr_dirtied_pause = dirty_poll_interval(nr_dirty, dirty_thresh);
 
 	if (writeback_in_progress(bdi))
--- linux-next.orig/kernel/fork.c	2011-08-26 20:09:04.000000000 +0800
+++ linux-next/kernel/fork.c	2011-08-26 20:09:19.000000000 +0800
@@ -1331,6 +1331,7 @@ static struct task_struct *copy_process(
 
 	p->nr_dirtied = 0;
 	p->nr_dirtied_pause = 128 >> (PAGE_SHIFT - 10);
+	p->dirty_paused_when = 0;
 
 	/*
 	 * Ok, make it visible to the rest of the system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
