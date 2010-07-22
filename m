From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/6] writeback: sync expired inodes first in background writeback
Date: Thu, 22 Jul 2010 13:09:32 +0800
Message-ID: <20100722061822.906037624@intel.com>
References: <20100722050928.653312535@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=writeback-expired-for-background.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

A background flush work may run for ever. So it's reasonable for it to
mimic the kupdate behavior of syncing old/expired inodes first.

The policy is
- enqueue all newly expired inodes at each queue_io() time
- retry with halfed expire interval until get some inodes to sync

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-22 12:56:42.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-22 13:07:51.000000000 +0800
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
@@ -232,8 +232,15 @@ static void move_expired_inodes(struct l
 	while (!list_empty(delaying_queue)) {
 		inode = list_entry(delaying_queue->prev, struct inode, i_list);
 		if (expire_interval &&
-		    inode_dirtied_after(inode, older_than_this))
-			break;
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
@@ -521,7 +528,8 @@ void writeback_inodes_wb(struct bdi_writ
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -550,7 +558,7 @@ static void __writeback_inodes_sb(struct
 
 	wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_lock);


