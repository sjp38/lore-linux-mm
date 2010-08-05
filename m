From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/13] writeback: the kupdate expire timestamp should be a moving target
Date: Fri, 06 Aug 2010 00:11:00 +0800
Message-ID: <20100805162433.949062884@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3Jx-00031G-UI
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:30 +0200
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 45ACB6B02B0
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:39 -0400 (EDT)
Content-Disposition: inline; filename=writeback-remove-older_than_this.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Dynamically compute the dirty expire timestamp at queue_io() time.
Also remove writeback_control.older_than_this which is no longer used.

writeback_control.older_than_this used to be determined at entrance to
the kupdate writeback work. This _static_ timestamp may go stale if the
kupdate work runs on and on. The flusher may then stuck with some old
busy inodes, never considering newly expired inodes thereafter.

This has two possible problems:

- It is unfair for a large dirty inode to delay (for a long time) the
  writeback of small dirty inodes.

- As time goes by, the large and busy dirty inode may contain only
  _freshly_ dirtied pages. Ignoring newly expired dirty inodes risks
  delaying the expired dirty pages to the end of LRU lists, triggering
  the evil pageout(). Nevertheless this patch merely addresses part
  of the problem.

[kitayama@cl.bb4u.ne.jp] fix btrfs and ext4 references

Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Itaru Kitayama <kitayama@cl.bb4u.ne.jp>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/extent_io.c             |    2 --
 fs/fs-writeback.c                |   24 +++++++++---------------
 include/linux/writeback.h        |    2 --
 include/trace/events/writeback.h |    6 +-----
 mm/backing-dev.c                 |    1 -
 mm/page-writeback.c              |    1 -
 6 files changed, 10 insertions(+), 26 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-08-05 23:28:29.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-08-05 23:28:29.000000000 +0800
@@ -216,16 +216,23 @@ static void move_expired_inodes(struct l
 				struct list_head *dispatch_queue,
 				struct writeback_control *wbc)
 {
+	unsigned long expire_interval = 0;
+	unsigned long older_than_this;
 	LIST_HEAD(tmp);
 	struct list_head *pos, *node;
 	struct super_block *sb = NULL;
 	struct inode *inode;
 	int do_sb_sort = 0;
 
+	if (wbc->for_kupdate) {
+		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
+		older_than_this = jiffies - expire_interval;
+	}
+
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
-		if (wbc->older_than_this &&
-		    inode_dirtied_after(inode, *wbc->older_than_this))
+		if (expire_interval &&
+		    inode_dirtied_after(inode, older_than_this))
 			break;
 		if (sb && sb != inode->i_sb)
 			do_sb_sort = 1;
@@ -592,29 +599,19 @@ static inline bool over_bground_thresh(v
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
@@ -1007,9 +1004,6 @@ EXPORT_SYMBOL(__mark_inode_dirty);
  * Write out a superblock's list of dirty inodes.  A wait will be performed
  * upon no inodes, all inodes or the final one, depending upon sync_mode.
  *
- * If older_than_this is non-NULL, then only write out inodes which
- * had their first dirtying at a time earlier than *older_than_this.
- *
  * If `bdi' is non-zero then we're being asked to writeback a specific queue.
  * This function assumes that the blockdev superblock's inodes are backed by
  * a variety of queues, so all inodes are searched.  For other superblocks,
--- linux-next.orig/include/linux/writeback.h	2010-08-05 23:28:29.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-08-05 23:28:29.000000000 +0800
@@ -28,8 +28,6 @@ enum writeback_sync_modes {
  */
 struct writeback_control {
 	enum writeback_sync_modes sync_mode;
-	unsigned long *older_than_this;	/* If !NULL, only write back inodes
-					   older than this */
 	unsigned long wb_start;         /* Time writeback_inodes_wb was
 					   called. This is needed to avoid
 					   extra jobs and livelock */
--- linux-next.orig/include/trace/events/writeback.h	2010-08-05 23:28:17.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2010-08-05 23:28:29.000000000 +0800
@@ -101,7 +101,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__field(int, for_reclaim)
 		__field(int, range_cyclic)
 		__field(int, more_io)
-		__field(unsigned long, older_than_this)
 		__field(long, range_start)
 		__field(long, range_end)
 	),
@@ -116,14 +115,12 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_reclaim	= wbc->for_reclaim;
 		__entry->range_cyclic	= wbc->range_cyclic;
 		__entry->more_io	= wbc->more_io;
-		__entry->older_than_this = wbc->older_than_this ?
-						*wbc->older_than_this : 0;
 		__entry->range_start	= (long)wbc->range_start;
 		__entry->range_end	= (long)wbc->range_end;
 	),
 
 	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
-		"bgrd=%d reclm=%d cyclic=%d more=%d older=0x%lx "
+		"bgrd=%d reclm=%d cyclic=%d more=%d "
 		"start=0x%lx end=0x%lx",
 		__entry->name,
 		__entry->nr_to_write,
@@ -134,7 +131,6 @@ DECLARE_EVENT_CLASS(wbc_class,
 		__entry->for_reclaim,
 		__entry->range_cyclic,
 		__entry->more_io,
-		__entry->older_than_this,
 		__entry->range_start,
 		__entry->range_end)
 )
--- linux-next.orig/mm/page-writeback.c	2010-08-05 23:28:29.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-05 23:28:29.000000000 +0800
@@ -488,7 +488,6 @@ static void balance_dirty_pages(struct a
 	for (;;) {
 		struct writeback_control wbc = {
 			.sync_mode	= WB_SYNC_NONE,
-			.older_than_this = NULL,
 			.nr_to_write	= write_chunk,
 			.range_cyclic	= 1,
 		};
--- linux-next.orig/mm/backing-dev.c	2010-08-05 23:28:29.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-08-05 23:28:29.000000000 +0800
@@ -271,7 +271,6 @@ static void bdi_flush_io(struct backing_
 {
 	struct writeback_control wbc = {
 		.sync_mode		= WB_SYNC_NONE,
-		.older_than_this	= NULL,
 		.range_cyclic		= 1,
 		.nr_to_write		= 1024,
 	};
--- linux-next.orig/fs/btrfs/extent_io.c	2010-08-05 23:28:17.000000000 +0800
+++ linux-next/fs/btrfs/extent_io.c	2010-08-05 23:28:29.000000000 +0800
@@ -2595,7 +2595,6 @@ int extent_write_full_page(struct extent
 	};
 	struct writeback_control wbc_writepages = {
 		.sync_mode	= wbc->sync_mode,
-		.older_than_this = NULL,
 		.nr_to_write	= 64,
 		.range_start	= page_offset(page) + PAGE_CACHE_SIZE,
 		.range_end	= (loff_t)-1,
@@ -2628,7 +2627,6 @@ int extent_write_locked_range(struct ext
 	};
 	struct writeback_control wbc_writepages = {
 		.sync_mode	= mode,
-		.older_than_this = NULL,
 		.nr_to_write	= nr_pages * 2,
 		.range_start	= start,
 		.range_end	= end + 1,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
