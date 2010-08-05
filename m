From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/13] writeback: sync expired inodes first in background writeback
Date: Fri, 06 Aug 2010 00:11:02 +0800
Message-ID: <20100805162434.234246269@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3Jf-0002of-Nu
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:12 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43C436B02A5
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:34 -0400 (EDT)
Content-Disposition: inline; filename=writeback-expired-for-background.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

A background flush work may run for ever. So it's reasonable for it to
mimic the kupdate behavior of syncing old/expired inodes first.

The policy is
- enqueue all newly expired inodes at each queue_io() time
- enqueue all dirty inodes if there are no more expired inodes to sync

This will help reduce the number of dirty pages encountered by page
reclaim, eg. the pageout() calls. Normally older inodes contain older
dirty pages, which are more close to the end of the LRU lists. So
syncing older inodes first helps reducing the dirty pages reached by
the page reclaim code.

CC: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-08-05 23:28:35.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-08-05 23:30:27.000000000 +0800
@@ -217,14 +217,14 @@ static void move_expired_inodes(struct l
 				struct writeback_control *wbc)
 {
 	unsigned long expire_interval = 0;
-	unsigned long older_than_this;
+	unsigned long older_than_this = 0; /* reset to kill gcc warning */
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
 
-	if (wbc->for_kupdate) {
+	if (wbc->for_kupdate || wbc->for_background) {
 		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
 		older_than_this = jiffies - expire_interval;
 	}
@@ -232,8 +232,20 @@ static void move_expired_inodes(struct l
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
 		if (expire_interval &&
-		    inode_dirtied_after(inode, older_than_this))
+		    inode_dirtied_after(inode, older_than_this)) {
+			/*
+			 * background writeback will start with expired inodes,
+			 * and then fresh inodes. This order helps reduce the
+			 * number of dirty pages reaching the end of LRU lists
+			 * and cause trouble to the page reclaim.
+			 */
+			if (wbc->for_background &&
+			    list_empty(dispatch_queue) && list_empty(&tmp)) {
+				expire_interval = 0;
+				continue;
+			}
 			break;
+		}
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
 		sb = inode->i_sb;
@@ -530,7 +542,8 @@ void writeback_inodes_wb(struct bdi_writ
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -559,7 +572,7 @@ static void __writeback_inodes_sb(struct
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
