From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/35] writeback: user space think time compensation
Date: Mon, 13 Dec 2010 22:46:54 +0800
Message-ID: <20101213150327.344665065@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA1l-0001tS-NI
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:26 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 752A96B0095
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-task-last-dirty-time.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Take the task's think time into account when computing the final pause time.
This will make accurate throttle bandwidth. In the rare case that the task
slept longer than the period time, the extra sleep time will also be
compensated in next period if it's not too big (<100ms).  Accumulated
errors are carefully avoided as long as the task don't sleep for too
long time.

case 1: period > think

		pause = period - think
		paused_when += pause

			     period time
	      |======================================>|
		  think time
	      |===============>|
	------|----------------|----------------------|-----------
	paused_when         jiffies


case 2: period <= think

		don't pause and reduce future pause time by:
		paused_when += period

		       period time
	      |=========================>|
			     think time
	      |======================================>|
	------|--------------------------+------------|-----------
	paused_when                                jiffies


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/sched.h |    1 +
 mm/page-writeback.c   |   22 ++++++++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/sched.h	2010-12-13 21:46:13.000000000 +0800
+++ linux-next/include/linux/sched.h	2010-12-13 21:46:13.000000000 +0800
@@ -1477,6 +1477,7 @@ struct task_struct {
 	 */
 	int nr_dirtied;
 	int nr_dirtied_pause;
+	unsigned long paused_when;	/* start of a write-and-pause period */
 
 #ifdef CONFIG_LATENCYTOP
 	int latency_record_count;
--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:13.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:13.000000000 +0800
@@ -537,6 +537,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	unsigned long bw;
+	unsigned long period;
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
@@ -583,7 +584,7 @@ static void balance_dirty_pages(struct a
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
-		if (bdi_dirty >= bdi_thresh) {
+		if (bdi_dirty >= bdi_thresh || nr_dirty > dirty_thresh) {
 			pause = MAX_PAUSE;
 			goto pause;
 		}
@@ -593,12 +594,29 @@ static void balance_dirty_pages(struct a
 		bw = bw * (bdi_thresh - bdi_dirty);
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
-		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		period = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1) + 1;
+		pause = current->paused_when + period - jiffies;
+		/*
+		 * Take it as long think time if pause falls into (-10s, 0).
+		 * If it's less than 100ms, try to compensate it in future by
+		 * updating the virtual time; otherwise just reset the time, as
+		 * it may be a light dirtier.
+		 */
+		if (unlikely(-pause < HZ*10)) {
+			if (-pause <= HZ/10)
+				current->paused_when += period;
+			else
+				current->paused_when = jiffies;
+			pause = 1;
+			break;
+		}
 		pause = clamp_val(pause, 1, MAX_PAUSE);
 
 pause:
+		current->paused_when = jiffies;
 		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
+		current->paused_when += pause;
 
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
