Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0CA208D0048
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:46:14 -0400 (EDT)
Message-Id: <20110420080917.759855316@intel.com>
Date: Wed, 20 Apr 2011 16:03:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/6] writeback: pass writeback_control down to move_expired_inodes()
References: <20110420080336.441157866@intel.com>
Content-Disposition: inline; filename=writeback-pass-wbc-to-queue_io.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

No behavior change. This will add debug visibility to the code, for
example, to dump the wbc contents when kprobing queue_io().

Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-19 10:18:17.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-19 10:18:28.000000000 +0800
@@ -251,8 +251,8 @@ static bool inode_dirtied_after(struct i
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
@@ -262,8 +262,8 @@ static void move_expired_inodes(struct l
 
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
-		if (older_than_this &&
-		    inode_dirtied_after(inode, *older_than_this))
+		if (wbc->older_than_this &&
+		    inode_dirtied_after(inode, *wbc->older_than_this))
 			break;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
@@ -299,11 +299,11 @@ static void move_expired_inodes(struct l
  *                                           |
  *                                           +--> dequeue for IO
  */
-static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
+static void queue_io(struct bdi_writeback *wb, struct writeback_control *wbc)
 {
 	assert_spin_locked(&inode_wb_list_lock);
 	list_splice_init(&wb->b_more_io, &wb->b_io);
-	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
+	move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -579,7 +579,7 @@ void writeback_inodes_wb(struct bdi_writ
 		wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_wb_list_lock);
 	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
@@ -606,7 +606,7 @@ static void __writeback_inodes_sb(struct
 
 	spin_lock(&inode_wb_list_lock);
 	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_wb_list_lock);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
