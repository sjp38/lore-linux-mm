Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4CA6007FC
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:27:30 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 7/9] writeback: Roll up of writeback: try to write older pages first
Date: Wed, 28 Jul 2010 11:27:21 +0100
Message-Id: <1280312843-11789-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

This is a roll-up of the series entitled "[RFC] writeback: try to write
older pages first".

No signoff required
---
 fs/fs-writeback.c                |   83 ++++++++++++++++++++------------------
 include/linux/writeback.h        |    4 +-
 include/trace/events/writeback.h |    9 +----
 mm/backing-dev.c                 |    1 -
 mm/page-writeback.c              |    1 -
 5 files changed, 46 insertions(+), 52 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 10f939a..5a3c764 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -213,20 +213,34 @@ static bool inode_dirtied_after(struct inode *inode, unsigned long t)
  * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
  */
 static void move_expired_inodes(struct list_head *delaying_queue,
-			       struct list_head *dispatch_queue,
-				unsigned long *older_than_this)
+				struct list_head *dispatch_queue,
+				struct writeback_control *wbc)
 {
+	unsigned long expire_interval = 0;
+	unsigned long older_than_this = 0; /* reset to kill gcc warning */
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
 
+	if (wbc->for_kupdate || wbc->for_background) {
+		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
+		older_than_this = jiffies - expire_interval;
+	}
+
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
-		if (older_than_this &&
-		    inode_dirtied_after(inode, *older_than_this))
-			break;
+		if (expire_interval &&
+		    inode_dirtied_after(inode, older_than_this)) {
+			if (wbc->for_background &&
+			    list_empty(dispatch_queue) && list_empty(&tmp)) {
+				expire_interval >>= 1;
+				older_than_this = jiffies - expire_interval;
+				continue;
+			} else
+				break;
+		}
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
 		sb = inode->i_sb;
@@ -254,10 +268,10 @@ static void move_expired_inodes(struct list_head *delaying_queue,
 /*
  * Queue all expired dirty inodes for io, eldest first.
  */
-static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
+static void queue_io(struct bdi_writeback *wb, struct writeback_control *wbc)
 {
 	list_splice_init(&wb->b_more_io, wb->b_io.prev);
-	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
+	move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
 }
 
 static int write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -362,6 +376,8 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 		int err = write_inode(inode, wbc);
 		if (ret == 0)
 			ret = err;
+		if (!err)
+			wbc->inodes_written++;
 	}
 
 	spin_lock(&inode_lock);
@@ -528,12 +544,8 @@ static int writeback_sb_inodes(struct super_block *sb, struct bdi_writeback *wb,
 		iput(inode);
 		cond_resched();
 		spin_lock(&inode_lock);
-		if (wbc->nr_to_write <= 0) {
-			wbc->more_io = 1;
+		if (wbc->nr_to_write <= 0)
 			return 1;
-		}
-		if (!list_empty(&wb->b_more_io))
-			wbc->more_io = 1;
 	}
 	/* b_io is empty */
 	return 1;
@@ -546,8 +558,9 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
+		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = list_entry(wb->b_io.prev,
@@ -575,8 +588,8 @@ static void __writeback_inodes_sb(struct super_block *sb,
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
-		queue_io(wb, wbc->older_than_this);
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
+		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);
 }
@@ -611,29 +624,19 @@ static inline bool over_bground_thresh(void)
  * Try to run once per dirty_writeback_interval.  But if a writeback event
  * takes longer than a dirty_writeback_interval interval, then leave a
  * one-second gap.
- *
- * older_than_this takes precedence over nr_to_write.  So we'll only write back
- * all dirty pages if they are all attached to "old" mappings.
  */
 static long wb_writeback(struct bdi_writeback *wb,
 			 struct wb_writeback_work *work)
 {
 	struct writeback_control wbc = {
 		.sync_mode		= work->sync_mode,
-		.older_than_this	= NULL,
 		.for_kupdate		= work->for_kupdate,
 		.for_background		= work->for_background,
 		.range_cyclic		= work->range_cyclic,
 	};
-	unsigned long oldest_jif;
 	long wrote = 0;
 	struct inode *inode;
 
-	if (wbc.for_kupdate) {
-		wbc.older_than_this = &oldest_jif;
-		oldest_jif = jiffies -
-				msecs_to_jiffies(dirty_expire_interval * 10);
-	}
 	if (!wbc.range_cyclic) {
 		wbc.range_start = 0;
 		wbc.range_end = LLONG_MAX;
@@ -653,9 +656,9 @@ static long wb_writeback(struct bdi_writeback *wb,
 		if (work->for_background && !over_bground_thresh())
 			break;
 
-		wbc.more_io = 0;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
+		wbc.inodes_written = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
 		if (work->sb)
@@ -668,20 +671,25 @@ static long wb_writeback(struct bdi_writeback *wb,
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
+			continue;
+		if (wbc.inodes_written)
 			continue;
+
 		/*
-		 * Didn't write everything and we don't have more IO, bail
+		 * Nothing written and no more inodes for IO, bail
 		 */
-		if (!wbc.more_io)
+		if (list_empty(&wb->b_more_io))
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
@@ -1026,9 +1034,6 @@ EXPORT_SYMBOL(__mark_inode_dirty);
  * Write out a superblock's list of dirty inodes.  A wait will be performed
  * upon no inodes, all inodes or the final one, depending upon sync_mode.
  *
- * If older_than_this is non-NULL, then only write out inodes which
- * had their first dirtying at a time earlier than *older_than_this.
- *
  * If `bdi' is non-zero then we're being asked to writeback a specific queue.
  * This function assumes that the blockdev superblock's inodes are backed by
  * a variety of queues, so all inodes are searched.  For other superblocks,
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c24eca7..494edd6 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -28,14 +28,13 @@ enum writeback_sync_modes {
  */
 struct writeback_control {
 	enum writeback_sync_modes sync_mode;
-	unsigned long *older_than_this;	/* If !NULL, only write back inodes
-					   older than this */
 	unsigned long wb_start;         /* Time writeback_inodes_wb was
 					   called. This is needed to avoid
 					   extra jobs and livelock */
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */
 	long pages_skipped;		/* Pages which were not written */
+	long inodes_written;		/* Number of inodes(metadata) synced */
 
 	/*
 	 * For a_ops->writepages(): is start or end are non-zero then this is
@@ -51,7 +50,6 @@ struct writeback_control {
 	unsigned for_background:1;	/* A background writeback */
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
-	unsigned more_io:1;		/* more io to be dispatched */
 };
 
 /*
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 0be26ac..dc8001f 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -99,8 +99,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__field(int, for_background)
 		__field(int, for_reclaim)
 		__field(int, range_cyclic)
-		__field(int, more_io)
-		__field(unsigned long, older_than_this)
 		__field(long, range_start)
 		__field(long, range_end)
 	),
@@ -114,15 +112,12 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_background	= wbc->for_background;
 		__entry->for_reclaim	= wbc->for_reclaim;
 		__entry->range_cyclic	= wbc->range_cyclic;
-		__entry->more_io	= wbc->more_io;
-		__entry->older_than_this = wbc->older_than_this ?
-						*wbc->older_than_this : 0;
 		__entry->range_start	= (long)wbc->range_start;
 		__entry->range_end	= (long)wbc->range_end;
 	),
 
 	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
-		"bgrd=%d reclm=%d cyclic=%d more=%d older=0x%lx "
+		"bgrd=%d reclm=%d cyclic=%d "
 		"start=0x%lx end=0x%lx",
 		__entry->name,
 		__entry->nr_to_write,
@@ -132,8 +127,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_background,
 		__entry->for_reclaim,
 		__entry->range_cyclic,
-		__entry->more_io,
-		__entry->older_than_this,
 		__entry->range_start,
 		__entry->range_end)
 )
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ac78a33..eaea7e0 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -270,7 +270,6 @@ static void bdi_flush_io(struct backing_dev_info *bdi)
 {
 	struct writeback_control wbc = {
 		.sync_mode		= WB_SYNC_NONE,
-		.older_than_this	= NULL,
 		.range_cyclic		= 1,
 		.nr_to_write		= 1024,
 	};
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d556cd8..d4a9e3d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -497,7 +497,6 @@ static void balance_dirty_pages(struct address_space *mapping,
 	for (;;) {
 		struct writeback_control wbc = {
 			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
 			.nr_to_write	= write_chunk,
 			.range_cyclic	= 1,
 		};
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
