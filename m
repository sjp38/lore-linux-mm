From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/35] writeback: adapt max balance pause time to memory size
Date: Mon, 13 Dec 2010 22:47:01 +0800
Message-ID: <20101213150328.166706725@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA26-00024A-4G
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:46 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C17586B00A4
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-max-pause-time-for-small-memory-system.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

For small memory systems, sleeping for 200ms at a time is an overkill.
Given 4MB dirty limit, all the dirty/writeback pages will be written to
a 80MB/s disk within 50ms. If the task goes sleep for 200ms after it
dirtied 4MB, the disk will go idle for 150ms without any new data feed.

So allow up to N milliseconds pause time for (4*N) MB bdi dirty limit.
On a typical 4GB desktop, the max pause time will be ~150ms.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:15.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
@@ -643,6 +643,22 @@ unlock:
 }
 
 /*
+ * Limit pause time for small memory systems. If sleeping for too long time,
+ * the small pool of dirty/writeback pages may go empty and disk go idle.
+ */
+static unsigned long max_pause(unsigned long bdi_thresh)
+{
+	unsigned long t;
+
+	/* 1ms for every 4MB */
+	t = bdi_thresh >> (32 - PAGE_CACHE_SHIFT -
+			   ilog2(roundup_pow_of_two(HZ)));
+	t += 2;
+
+	return min_t(unsigned long, t, MAX_PAUSE);
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -663,6 +679,7 @@ static void balance_dirty_pages(struct a
 	unsigned long long bw;
 	unsigned long period;
 	unsigned long pause = 0;
+	unsigned long pause_max;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
@@ -715,8 +732,10 @@ static void balance_dirty_pages(struct a
 		if (avg_dirty < bdi_dirty || avg_dirty > task_thresh)
 			avg_dirty = bdi_dirty;
 
+		pause_max = max_pause(bdi_thresh);
+
 		if (avg_dirty >= task_thresh || nr_dirty > dirty_thresh) {
-			pause = MAX_PAUSE;
+			pause = pause_max;
 			goto pause;
 		}
 
@@ -750,7 +769,7 @@ static void balance_dirty_pages(struct a
 			pause = 1;
 			break;
 		}
-		pause = clamp_val(pause, 1, MAX_PAUSE);
+		pause = clamp_val(pause, 1, pause_max);
 
 pause:
 		current->paused_when = jiffies;
@@ -781,7 +800,7 @@ pause:
 		current->nr_dirtied_pause = ratelimit_pages(bdi);
 	else if (pause == 1)
 		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
-	else if (pause >= MAX_PAUSE)
+	else if (pause >= pause_max)
 		/*
 		 * when repeated, writing 1 page per 100ms on slow devices,
 		 * i-(i+2)/4 will be able to reach 1 but never reduce to 0.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
