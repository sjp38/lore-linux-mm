Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1C2F06B0082
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:01 -0400 (EDT)
Message-Id: <20100912155203.206486412@intel.com>
Date: Sun, 12 Sep 2010 23:49:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/17] writeback: quit throttling when bdi dirty/writeback pages go down
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-bdi-throttle-break.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Tests show that bdi_thresh may take minutes to ramp up on a typical
desktop. The time should be improvable but cannot be eliminated totally.
So when (background_thresh + dirty_thresh)/2 is reached and
balance_dirty_pages() starts to throttle the task, it will suddenly find
the (still low and ramping up) bdi_thresh is exceeded _excessively_. Here
we definitely don't want to stall the task for one minute. So introduce
an alternative way to break out of the loop when the bdi dirty/write
pages has dropped by a reasonable amount.

When dirty_background_ratio is set close to dirty_ratio, bdi_thresh may
also be constantly exceeded due to the task_dirty_limit() gap.

It will take at least 200ms before trying to break out.

(pages_dirtied * 8) is used because in this situation pages_dirtied will
typically be small numbers (eg. 3 pages) due to the fast back off logic.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-09-09 15:51:38.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-12 13:10:02.000000000 +0800
@@ -463,6 +463,7 @@ static void balance_dirty_pages(struct a
 {
 	long nr_reclaimable, bdi_nr_reclaimable;
 	long nr_writeback, bdi_nr_writeback;
+	long bdi_prev_dirty3 = 0;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -516,6 +517,20 @@ static void balance_dirty_pages(struct a
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		/*
+		 * bdi_thresh could get exceeded for long time:
+		 * - bdi_thresh takes some time to ramp up from the initial 0
+		 * - users may set dirty_background_ratio close to dirty_ratio
+		 *   (at least 1/8 gap is preferred)
+		 * So offer a complementary way to break out of the loop when
+		 * enough bdi pages have been cleaned during our pause time.
+		 */
+		if (nr_reclaimable + nr_writeback <= dirty_thresh &&
+		    bdi_prev_dirty3 - (bdi_nr_reclaimable + bdi_nr_writeback) >
+							(long)pages_dirtied * 8)
+			break;
+		bdi_prev_dirty3 = bdi_nr_reclaimable + bdi_nr_writeback;
+
 		if (bdi_nr_reclaimable + bdi_nr_writeback <=
 			bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO)
 			goto check_exceeded;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
