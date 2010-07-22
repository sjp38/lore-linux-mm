From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/6] writeback: try more writeback as long as something was written
Date: Thu, 22 Jul 2010 13:09:33 +0800
Message-ID: <20100722061823.050523298@intel.com>
References: <20100722050928.653312535@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Obp8D-0003gp-CS
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Jul 2010 08:19:45 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A0A8600365
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 02:19:33 -0400 (EDT)
Content-Disposition: inline; filename=writeback-background-retry.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

writeback_inodes_wb()/__writeback_inodes_sb() are not agressive in that
they only populate b_io when necessary at entrance time. When the queued
set of inodes are all synced, they just return, possibly with
wbc.nr_to_write > 0.

For kupdate and background writeback, there may be more eligible inodes
sitting in b_dirty when the current set of b_io inodes are completed. So
it is necessary to try another round of writeback as long as we made some
progress in this round. When there are no more eligible inodes, no more
inodes will be enqueued in queue_io(), hence nothing could/will be
synced and we may safely bail.

This will livelock sync when there are heavy dirtiers. However in that case
sync will already be livelocked w/o this patch, as the current livelock
avoidance code is virtually a no-op (for one thing, wb_time should be
set statically at sync start time and be used in move_expired_inodes()).
The sync livelock problem will be addressed in other patches.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-22 13:07:51.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-22 13:07:54.000000000 +0800
@@ -640,20 +640,23 @@ static long wb_writeback(struct bdi_writ
 		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 
 		/*
-		 * If we consumed everything, see if we have more
+		 * Did we write something? Try for more
+		 *
+		 * This is needed _before_ the b_more_io test because the
+		 * background writeback moves inodes to b_io and works on
+		 * them in batches (in order to sync old pages first).  The
+		 * completion of the current batch does not necessarily mean
+		 * the overall work is done.
 		 */
-		if (wbc.nr_to_write <= 0)
+		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
 			continue;
+
 		/*
-		 * Didn't write everything and we don't have more IO, bail
+		 * Nothing written and no more inodes for IO, bail
 		 */
 		if (list_empty(&wb->b_more_io))
 			break;
-		/*
-		 * Did we write something? Try for more
-		 */
-		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
-			continue;
+
 		/*
 		 * Nothing written. Wait for some inode to
 		 * become available for writeback. Otherwise


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
