Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 55D6E6B007E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 04:02:38 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/4] writeback: Remove outdated comment
Date: Fri,  9 Mar 2012 10:02:26 +0100
Message-Id: <1331283748-12959-3-git-send-email-jack@suse.cz>
In-Reply-To: <1331283748-12959-1-git-send-email-jack@suse.cz>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

The comment is hopelessly outdated and misplaced. We no longer have 'bdi'
part of writeback work, the comment about blockdev super is outdated,
comment about throttling as well. Information about list handling is in
more detail at queue_io(). So just move the bit about older_than_this to
close to move_expired_inodes() and remove the rest.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index f60297b..be84e28 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -256,7 +256,8 @@ static bool inode_dirtied_after(struct inode *inode, unsigned long t)
 }
 
 /*
- * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
+ * Move expired (dirtied after work->older_than_this) dirty inodes from
+ * @delaying_queue to @dispatch_queue.
  */
 static int move_expired_inodes(struct list_head *delaying_queue,
 			       struct list_head *dispatch_queue,
@@ -1148,23 +1149,6 @@ out_unlock_inode:
 }
 EXPORT_SYMBOL(__mark_inode_dirty);
 
-/*
- * Write out a superblock's list of dirty inodes.  A wait will be performed
- * upon no inodes, all inodes or the final one, depending upon sync_mode.
- *
- * If older_than_this is non-NULL, then only write out inodes which
- * had their first dirtying at a time earlier than *older_than_this.
- *
- * If `bdi' is non-zero then we're being asked to writeback a specific queue.
- * This function assumes that the blockdev superblock's inodes are backed by
- * a variety of queues, so all inodes are searched.  For other superblocks,
- * assume that all inodes are backed by the same queue.
- *
- * The inodes to be written are parked on bdi->b_io.  They are moved back onto
- * bdi->b_dirty as they are selected for writing.  This way, none can be missed
- * on the writer throttling path, and we get decent balancing between many
- * throttled threads: we don't want them all piling up on inode_sync_wait.
- */
 static void wait_sb_inodes(struct super_block *sb)
 {
 	struct inode *inode, *old_inode = NULL;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
