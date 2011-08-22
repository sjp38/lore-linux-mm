Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F1F6D6B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 14:39:14 -0400 (EDT)
From: Curt Wohlgemuth <curtw@google.com>
Subject: [PATCH 1/3] writeback: send work item to queue_io, move_expired_inodes
Date: Mon, 22 Aug 2011 11:38:45 -0700
Message-Id: <1314038327-22645-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Curt Wohlgemuth <curtw@google.com>

Instead of sending ->older_than_this to queue_io() and
move_expired_inodes(), send the entire wb_writeback_work
structure.  There are other fields of a work item that are
useful in these routines and in tracepoints.

Signed-off-by: Curt Wohlgemuth <curtw@google.com>
---
 fs/fs-writeback.c                |   16 ++++++++--------
 include/trace/events/writeback.h |    5 +++--
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 04cf3b9..f1f5f65 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -251,7 +251,7 @@ static bool inode_dirtied_after(struct inode *inode, unsigned long t)
  */
 static int move_expired_inodes(struct list_head *delaying_queue,
 			       struct list_head *dispatch_queue,
-			       unsigned long *older_than_this)
+			       struct wb_writeback_work *work)
 {
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
@@ -262,8 +262,8 @@ static int move_expired_inodes(struct list_head *delaying_queue,
 
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
-		if (older_than_this &&
-		    inode_dirtied_after(inode, *older_than_this))
+		if (work->older_than_this &&
+		    inode_dirtied_after(inode, *work->older_than_this))
 			break;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
@@ -302,13 +302,13 @@ out:
  *                                           |
  *                                           +--> dequeue for IO
  */
-static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
+static void queue_io(struct bdi_writeback *wb, struct wb_writeback_work *work)
 {
 	int moved;
 	assert_spin_locked(&wb->list_lock);
 	list_splice_init(&wb->b_more_io, &wb->b_io);
-	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
-	trace_writeback_queue_io(wb, older_than_this, moved);
+	moved = move_expired_inodes(&wb->b_dirty, &wb->b_io, work);
+	trace_writeback_queue_io(wb, work, moved);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -651,7 +651,7 @@ long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
 
 	spin_lock(&wb->list_lock);
 	if (list_empty(&wb->b_io))
-		queue_io(wb, NULL);
+		queue_io(wb, &work);
 	__writeback_inodes_wb(wb, &work);
 	spin_unlock(&wb->list_lock);
 
@@ -738,7 +738,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 
 		trace_writeback_start(wb->bdi, work);
 		if (list_empty(&wb->b_io))
-			queue_io(wb, work->older_than_this);
+			queue_io(wb, work);
 		if (work->sb)
 			progress = writeback_sb_inodes(work->sb, wb, work);
 		else
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 6bca4cc..4565274 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -181,9 +181,9 @@ DEFINE_WBC_EVENT(wbc_writepage);
 
 TRACE_EVENT(writeback_queue_io,
 	TP_PROTO(struct bdi_writeback *wb,
-		 unsigned long *older_than_this,
+		 struct wb_writeback_work *work,
 		 int moved),
-	TP_ARGS(wb, older_than_this, moved),
+	TP_ARGS(wb, work, moved),
 	TP_STRUCT__entry(
 		__array(char,		name, 32)
 		__field(unsigned long,	older)
@@ -191,6 +191,7 @@ TRACE_EVENT(writeback_queue_io,
 		__field(int,		moved)
 	),
 	TP_fast_assign(
+		unsigned long *older_than_this = work->older_than_this;
 		strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
 		__entry->older	= older_than_this ?  *older_than_this : 0;
 		__entry->age	= older_than_this ?
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
