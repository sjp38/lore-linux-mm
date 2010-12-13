From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 24/47] writeback: increase pause time on concurrent dirtiers
Date: Mon, 13 Dec 2010 14:43:13 +0800
Message-ID: <20101213064839.907210153@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2F4-0005iK-OY
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:39 +0100
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B7D466B00A3
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:41 -0500 (EST)
Content-Disposition: inline; filename=writeback-200ms-pause-time.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Increase max pause time to 200ms, and make it work for (HZ < 5).

The larger 200ms will help reduce overheads in server workloads with
lots of concurrent dirtier tasks.

CC: Dave Chinner <david@fromorbit.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-09 11:52:05.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-09 11:54:05.000000000 +0800
@@ -36,6 +36,11 @@
 #include <linux/pagevec.h>
 #include <trace/events/writeback.h>
 
+/*
+ * Don't sleep more than 200ms at a time in balance_dirty_pages().
+ */
+#define MAX_PAUSE	max(HZ/5, 1)
+
 /* The following parameters are exported via /proc/sys/vm */
 
 /*
@@ -660,7 +665,7 @@ static void balance_dirty_pages(struct a
 		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
 
 		if (bdi_dirty >= task_thresh) {
-			pause = HZ/10;
+			pause = MAX_PAUSE;
 			goto pause;
 		}
 
@@ -679,7 +684,7 @@ static void balance_dirty_pages(struct a
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
 		pause = HZ * pages_dirtied / ((unsigned long)bw + 1);
-		pause = clamp_val(pause, 1, HZ/10);
+		pause = clamp_val(pause, 1, MAX_PAUSE);
 
 pause:
 		trace_balance_dirty_pages(bdi,
@@ -714,7 +719,7 @@ pause:
 		current->nr_dirtied_pause = ratelimit_pages(bdi);
 	else if (pause == 1)
 		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
-	else if (pause >= HZ/10)
+	else if (pause >= MAX_PAUSE)
 		/*
 		 * when repeated, writing 1 page per 100ms on slow devices,
 		 * i-(i+2)/4 will be able to reach 1 but never reduce to 0.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
