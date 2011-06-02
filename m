Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A8BD88D003B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:48 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 09/12] inode: remove iprune_sem
Date: Thu,  2 Jun 2011 17:01:04 +1000
Message-Id: <1306998067-27659-10-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Now that we have per-sb shrinkers and they are unregistered before
evict_inode() is called, there is not longer any race condition for
the iprune_sem to protect against. Hence we can remove it.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/inode.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 890d95e..167adfd 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -68,17 +68,6 @@ __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_sb_list_lock);
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_wb_list_lock);
 
 /*
- * iprune_sem provides exclusion between the icache shrinking and the
- * umount path.
- *
- * We don't actually need it to protect anything in the umount path,
- * but only need to cycle through it to make sure any inode that
- * prune_icache_sb took off the LRU list has been fully torn down by the
- * time we are past evict_inodes.
- */
-static DECLARE_RWSEM(iprune_sem);
-
-/*
  * Empty aops. Can be used for the cases where the user does not
  * define any of the address_space operations.
  */
@@ -535,14 +524,6 @@ void evict_inodes(struct super_block *sb)
 	spin_unlock(&inode_sb_list_lock);
 
 	dispose_list(&dispose);
-
-	/*
-	 * Cycle through iprune_sem to make sure any inode that prune_icache_sb
-	 * moved off the list before we took the lock has been fully torn
-	 * down.
-	 */
-	down_write(&iprune_sem);
-	up_write(&iprune_sem);
 }
 
 /**
@@ -628,7 +609,6 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 	int nr_scanned;
 	unsigned long reap = 0;
 
-	down_read(&iprune_sem);
 	spin_lock(&sb->s_inode_lru_lock);
 	for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
 		struct inode *inode;
@@ -704,7 +684,6 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 	spin_unlock(&sb->s_inode_lru_lock);
 
 	dispose_list(&freeable);
-	up_read(&iprune_sem);
 }
 
 static void __wait_on_freeing_inode(struct inode *inode);
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
