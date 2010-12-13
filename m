From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/47] writeback: quit throttling when bdi dirty pages dropped low
Date: Mon, 13 Dec 2010 14:42:59 +0800
Message-ID: <20101213064838.170617763@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2ET-0005Ui-0x
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:01 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 38E826B0098
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-bdi-throttle-break.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Tests show that bdi_thresh may take minutes to ramp up on a typical
desktop. The time should be improvable but cannot be eliminated totally.
So when (background_thresh + dirty_thresh)/2 is reached and
balance_dirty_pages() starts to throttle the task, it will suddenly find
the (still low and ramping up) bdi_thresh is exceeded _excessively_. Here
we definitely don't want to stall the task for one minute (when it's
writing to USB stick). So introduce an alternative way to break out of
the loop when the bdi dirty/write pages has dropped by a reasonable
amount.

When dirty_background_ratio is set close to dirty_ratio, bdi_thresh may
also be constantly exceeded due to the task_dirty_limit() gap. This is
addressed by another patch to lower the background threshold when
necessary.

It will take at least 100ms before trying to break out.

Note that this opens the chance that during normal operation, a huge
number of slow dirtiers writing to a really slow device might manage to
outrun bdi_thresh. But the risk is pretty low. It takes at least one
100ms sleep loop to break out, and the global limit is still enforced.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:24.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:25.000000000 +0800
@@ -563,6 +563,7 @@ static void balance_dirty_pages(struct a
 	long nr_reclaimable;
 	long nr_dirty;
 	long bdi_dirty;  /* = file_dirty + writeback + unstable_nfs */
+	long bdi_prev_dirty = 0;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -615,6 +616,25 @@ static void balance_dirty_pages(struct a
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		/*
+		 * bdi_thresh takes time to ramp up from the initial 0,
+		 * especially for slow devices.
+		 *
+		 * It's possible that at the moment dirty throttling starts,
+		 *	bdi_dirty = nr_dirty
+		 *		  = (background_thresh + dirty_thresh) / 2
+		 *		  >> bdi_thresh
+		 * Then the task could be blocked for a dozen second to flush
+		 * all the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
+		 * complementary way to break out of the loop when 250ms worth
+		 * of dirty pages have been cleaned during our pause time.
+		 */
+		if (nr_dirty < dirty_thresh &&
+		    bdi_prev_dirty - bdi_dirty >
+		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
+			break;
+		bdi_prev_dirty = bdi_dirty;
+
 		if (bdi_dirty >= bdi_thresh) {
 			pause = HZ/10;
 			goto pause;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
