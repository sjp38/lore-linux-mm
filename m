From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/6] writeback: pass writeback_control down to move_expired_inodes()
Date: Thu, 22 Jul 2010 13:09:29 +0800
Message-ID: <20100722061822.484666925@intel.com>
References: <20100722050928.653312535@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Obp7z-0003bw-PD
	for glkm-linux-mm-2@m.gmane.org; Thu, 22 Jul 2010 08:19:32 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F3326B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 02:19:27 -0400 (EDT)
Content-Disposition: inline; filename=writeback-pass-wbc-to-queue_io.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

This is to prepare for moving the dirty expire policy to move_expired_inodes().
No behavior change.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-21 20:12:38.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-21 20:14:38.000000000 +0800
@@ -213,8 +213,8 @@ static bool inode_dirtied_after(struct i
  * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
  */
 static void move_expired_inodes(struct list_head *delaying_queue,
-			       struct list_head *dispatch_queue,
-				unsigned long *older_than_this)
+				struct list_head *dispatch_queue,
+				struct writeback_control *wbc)
 {
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
@@ -224,8 +224,8 @@ static void move_expired_inodes(struct l
 
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
-		if (older_than_this &&
-		    inode_dirtied_after(inode, *older_than_this))
+		if (wbc->older_than_this &&
+		    inode_dirtied_after(inode, *wbc->older_than_this))
 			break;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
@@ -257,10 +257,10 @@ static void move_expired_inodes(struct l
  *                 => b_more_io inodes
  *                 => remaining inodes in b_io => (dequeue for sync)
  */
-static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
+static void queue_io(struct bdi_writeback *wb, struct writeback_control *wbc)
 {
 	list_splice_init(&wb->b_more_io, &wb->b_io);
-	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
+	move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -519,7 +519,7 @@ void writeback_inodes_wb(struct bdi_writ
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
 	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = list_entry(wb->b_io.prev,
@@ -548,7 +548,7 @@ static void __writeback_inodes_sb(struct
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
 	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
