From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/47] writeback: scale down max throttle bandwidth on concurrent dirtiers
Date: Mon, 13 Dec 2010 14:43:02 +0800
Message-ID: <20101213064838.530772251@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-adaptive-throttle-bandwidth.patch
Sender: linux-kernel-owner@vger.kernel.org
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

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:25.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:26.000000000 +0800
@@ -574,6 +574,7 @@ static void balance_dirty_pages(struct a
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	unsigned long task_thresh;
 	unsigned long bw;
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
@@ -603,7 +604,7 @@ static void balance_dirty_pages(struct a
 			break;
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, nr_dirty);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+		task_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need
@@ -642,14 +643,23 @@ static void balance_dirty_pages(struct a
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
-		if (bdi_dirty >= bdi_thresh) {
+		if (bdi_dirty >= task_thresh) {
 			pause = HZ/10;
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
+		bw = bw / (bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
+
+		bw = bw * (task_thresh - bdi_dirty);
 		bw = bw / (bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
 		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
