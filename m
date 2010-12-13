From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/35] writeback: scale down max throttle bandwidth on concurrent dirtiers
Date: Mon, 13 Dec 2010 22:46:58 +0800
Message-ID: <20101213150327.809762057@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA1a-0001mF-TM
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:15 +0100
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F3BE6B0099
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-adaptive-throttle-bandwidth.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This will noticeably reduce the fluctuaions of pause time when there are
100+ concurrent dirtiers.

The more parallel dirtiers (1 dirtier => 4 dirtiers), the smaller
bandwidth each dirtier will share (bdi_bandwidth => bdi_bandwidth/4),
the less gap to the dirty limit ((C-A) => (C-B)), the less stable the
pause time will be (given the same fluctuation of bdi_dirty).

For example, if A drifts to A', its pause time may drift from 5ms to
6ms, while B to B' may drift from 50ms to 90ms.  It's much larger
fluctuations in relative ratio as well as absolute time.

Fig.1 before patch, gap (C-B) is too low to get smooth pause time

throttle_bandwidth_A = bdi_bandwidth .........o
                                              | o <= A'
                                              |   o
                                              |     o
                                              |       o
                                              |         o
throttle_bandwidth_B = bdi_bandwidth / 4 .....|...........o
                                              |           | o <= B'
----------------------------------------------+-----------+---o
                                              A           B   C

The solution is to lower the slope of the throttle line accordingly,
which makes B stabilize at some point more far away from C.

Fig.2 after patch

throttle_bandwidth_A = bdi_bandwidth .........o
                                              | o <= A'
                                              |   o
                                              |     o
    lowered max throttle bandwidth for B ===> *       o
                                              |   *     o
throttle_bandwidth_B = bdi_bandwidth / 4 .............*   o
                                              |       |   * o
----------------------------------------------+-------+-------o
                                              A       B       C

Note that C is actually different points for 1-dirty and 4-dirtiers
cases, but for easy graphing, we move them together.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:14.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:15.000000000 +0800
@@ -587,6 +587,7 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	unsigned long task_thresh;
 	unsigned long long bw;
 	unsigned long period;
 	unsigned long pause = 0;
@@ -616,7 +617,7 @@ static void balance_dirty_pages(struct a
 			break;
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, nr_dirty);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+		task_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need
@@ -638,14 +639,23 @@ static void balance_dirty_pages(struct a
 
 		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
 
-		if (bdi_dirty >= bdi_thresh || nr_dirty > dirty_thresh) {
+		if (bdi_dirty >= task_thresh || nr_dirty > dirty_thresh) {
 			pause = MAX_PAUSE;
 			goto pause;
 		}
 
+		/*
+		 * When bdi_dirty grows closer to bdi_thresh, it indicates more
+		 * concurrent dirtiers. Proportionally lower the max throttle
+		 * bandwidth. This will resist bdi_dirty from approaching to
+		 * close to task_thresh, and help reduce fluctuations of pause
+		 * time when there are lots of dirtiers.
+		 */
 		bw = bdi->write_bandwidth;
-
 		bw = bw * (bdi_thresh - bdi_dirty);
+		do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
+
+		bw = bw * (task_thresh - bdi_dirty);
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
 		period = HZ * pages_dirtied / ((unsigned long)bw + 1) + 1;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
