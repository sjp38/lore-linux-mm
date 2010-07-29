From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] writeback: prevent sync livelock with the sync_after timestamp
Date: Thu, 29 Jul 2010 19:51:45 +0800
Message-ID: <20100729121423.471866750@intel.com>
References: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS95-0006NW-2l
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:31 +0200
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 65C886B02A7
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:21 -0400 (EDT)
Content-Disposition: inline; filename=writeback-sync-pending-start_time.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

The start time in writeback_inodes_wb() is not very useful because it
slips at each invocation time. Preferrably one _constant_ time shall be
used at the beginning to cover the whole sync() work.

The newly dirtied inodes are now guarded at the queue_io() time instead
of the b_io walk time. This is more natural: non-empty b_io/b_more_io
means "more work pending".

The timestamp is now grabbed the sync work submission time, and may be
further optimized to the initial sync() call time.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |   16 ++++++----------
 include/linux/writeback.h |    4 ++--
 2 files changed, 8 insertions(+), 12 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-29 17:13:49.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-29 17:13:58.000000000 +0800
@@ -228,6 +228,10 @@ static void move_expired_inodes(struct l
 	struct inode *inode;
 	int do_sb_sort = 0;
 
+	if (wbc->for_sync) {
+		expire_interval = 1;
+		older_than_this = wbc->sync_after;
+	}
 	if (wbc->for_kupdate || wbc->for_background) {
 		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
 		older_than_this = jiffies - expire_interval;
@@ -507,12 +511,6 @@ static int writeback_sb_inodes(struct su
 			requeue_io(inode);
 			continue;
 		}
-		/*
-		 * Was this inode dirtied after sync_sb_inodes was called?
-		 * This keeps sync from extra jobs and livelock.
-		 */
-		if (inode_dirtied_after(inode, wbc->wb_start))
-			return 1;
 
 		BUG_ON(inode->i_state & I_FREEING);
 		__iget(inode);
@@ -541,10 +539,9 @@ void writeback_inodes_wb(struct bdi_writ
 {
 	int ret = 0;
 
-	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
 
-	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -571,9 +568,8 @@ static void __writeback_inodes_sb(struct
 {
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
-	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);
--- linux-next.orig/include/linux/writeback.h	2010-07-29 17:13:18.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-07-29 17:13:58.000000000 +0800
@@ -28,8 +28,8 @@ enum writeback_sync_modes {
  */
 struct writeback_control {
 	enum writeback_sync_modes sync_mode;
-	unsigned long wb_start;         /* Time writeback_inodes_wb was
-					   called. This is needed to avoid
+	unsigned long sync_after;	/* Only sync inodes dirtied after this
+					   timestamp. This is needed to avoid
 					   extra jobs and livelock */
 	long nr_to_write;		/* Write this many pages, and decrement
 					   this for each page written */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
