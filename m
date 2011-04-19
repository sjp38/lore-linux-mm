Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 783D7900087
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:10:22 -0400 (EDT)
Message-Id: <20110419030532.515923886@intel.com>
Date: Tue, 19 Apr 2011 11:00:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/6] writeback: sync expired inodes first in background writeback
References: <20110419030003.108796967@intel.com>
Content-Disposition: inline; filename=writeback-expired-for-background.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

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

Side effects: it will reduce the batch size and hence reduce
inode_wb_list_lock hold time, but also make the cluster-by-partition
logic in the same function less effective on reducing disk seeks.

CC: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-19 10:18:29.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-19 10:18:30.000000000 +0800
@@ -255,14 +255,14 @@ static void move_expired_inodes(struct l
 				struct writeback_control *wbc)
 {
 	unsigned long expire_interval = 0;
-	unsigned long older_than_this;
+	unsigned long uninitialized_var(older_than_this);
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
@@ -270,8 +270,20 @@ static void move_expired_inodes(struct l
 	while (!list_empty(delaying_queue)) {
 		inode = wb_inode(delaying_queue->prev);
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
@@ -585,7 +597,8 @@ void writeback_inodes_wb(struct bdi_writ
 	if (!wbc->wb_start)
 		wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_wb_list_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -612,7 +625,7 @@ static void __writeback_inodes_sb(struct
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
 	spin_lock(&inode_wb_list_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_wb_list_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
