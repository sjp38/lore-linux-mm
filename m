Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 574ED6B0083
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 04:02:38 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/4] writeback: Avoid iput() from flusher thread
Date: Fri,  9 Mar 2012 10:02:28 +0100
Message-Id: <1331283748-12959-5-git-send-email-jack@suse.cz>
In-Reply-To: <1331283748-12959-1-git-send-email-jack@suse.cz>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

Doing iput() from flusher thread (writeback_sb_inodes()) can create problems
because iput() can do a lot of work - for example truncate the inode if it's
the last iput on unlinked file. Some filesystems (e.g. ubifs) may need to
allocate blocks during truncate (due to their COW nature) and in some cases
they thus need to flush dirty data from truncate to reduce uncertainty in the
amount of free space. This effectively creates a deadlock.

We get rid of iput() in flusher thread by using the fact that I_SYNC inode
flag effectively pins the inode in memory. So if we take care to either hold
i_lock or have I_SYNC set, we can get away without taking inode reference
in writeback_sb_inodes().

As a side effect, we also fix possible use-after-free in wb_writeback() because
inode_wait_for_writeback() call could try to reacquire i_lock on the inode that
was already free.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c         |   38 ++++++++++++++++++++++++--------------
 fs/inode.c                |   11 ++++++++++-
 include/linux/fs.h        |    7 ++++---
 include/linux/writeback.h |    7 +------
 4 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1e8bf44..f9f9b61 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -325,19 +325,21 @@ static int write_inode(struct inode *inode, struct writeback_control *wbc)
 }
 
 /*
- * Wait for writeback on an inode to complete.
+ * Wait for writeback on an inode to complete. Called with i_lock held.
+ * Return 1 if we dropped i_lock and waited, 0 is returned otherwise.
  */
-static void inode_wait_for_writeback(struct inode *inode)
+int __must_check inode_wait_for_writeback(struct inode *inode)
 {
 	DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
 	wait_queue_head_t *wqh;
 
 	wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
-	while (inode->i_state & I_SYNC) {
+	if (inode->i_state & I_SYNC) {
 		spin_unlock(&inode->i_lock);
 		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
-		spin_lock(&inode->i_lock);
+		return 1;
 	}
+	return 0;
 }
 
 /*
@@ -426,9 +428,12 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 			return 0;
 		}
 		/*
-		 * It's a data-integrity sync.  We must wait.
+		 * It's a data-integrity sync. We must wait. Since callers hold
+		 * inode reference or inode has I_WILL_FREE set, it cannot go
+		 * away under us.
 		 */
-		inode_wait_for_writeback(inode);
+		while (inode_wait_for_writeback(inode))
+			spin_lock(&inode->i_lock);
 	}
 
 	ret = __writeback_single_inode(inode, wb, wbc);
@@ -604,12 +609,20 @@ static long writeback_sb_inodes(struct super_block *sb,
 		}
 		spin_unlock(&wb->list_lock);
 
-		__iget(inode);
-		inode_wait_for_writeback(inode);
+		/* Did we drop i_lock to wait for I_SYNC? */
+		if (inode_wait_for_writeback(inode)) {
+			/* Inode may be gone, start again */
+			spin_lock(&wb->list_lock);
+			continue;
+		}
 		write_chunk = writeback_chunk_size(wb->bdi, work);
 		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
+		/*
+		 * We use I_SYNC to pin the inode in memory. While it is set
+		 * end_writeback() will wait so the inode cannot be freed.
+		 */
 		__writeback_single_inode(inode, wb, &wbc);
 
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
@@ -633,10 +646,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 continue_unlock:
 		inode_sync_complete(inode);
 		spin_unlock(&inode->i_lock);
-		spin_unlock(&wb->list_lock);
-		iput(inode);
-		cond_resched();
-		spin_lock(&wb->list_lock);
+		cond_resched_lock(&wb->list_lock);
 		/*
 		 * bail out to wb_writeback() often enough to check
 		 * background threshold and other termination conditions.
@@ -831,8 +841,8 @@ static long wb_writeback(struct bdi_writeback *wb,
 			inode = wb_inode(wb->b_more_io.prev);
 			spin_lock(&inode->i_lock);
 			spin_unlock(&wb->list_lock);
-			inode_wait_for_writeback(inode);
-			spin_unlock(&inode->i_lock);
+			if (!inode_wait_for_writeback(inode))
+				spin_unlock(&inode->i_lock);
 			spin_lock(&wb->list_lock);
 		}
 	}
diff --git a/fs/inode.c b/fs/inode.c
index d3ebdbe..b64e2fe 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -510,7 +510,16 @@ void end_writeback(struct inode *inode)
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
-	inode_sync_wait(inode);
+	/*
+	 * Wait for flusher thread to be done with the inode. Since the inode
+	 * has I_FREEING set, flusher thread won't start new work on the inode.
+	 * We just have to wait for running writeback to finish. We must use
+	 * i_lock here because flusher thread might be working with the inode
+	 * without I_SYNC set but under i_lock.
+	 */
+	spin_lock(&inode->i_lock);
+	if (!inode_wait_for_writeback(inode))
+		spin_unlock(&inode->i_lock);
 	/* don't need i_lock here, no concurrent mods to i_state */
 	inode->i_state = I_FREEING | I_CLEAR;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 69cd5bb..e1f0f5a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1742,9 +1742,10 @@ struct super_operations {
  *			anew.  Other functions will just ignore such inodes,
  *			if appropriate.  I_NEW is used for waiting.
  *
- * I_SYNC		Synchonized write of dirty inode data.  The bits is
- *			set during data writeback, and cleared with a wakeup
- *			on the bit address once it is done.
+ * I_SYNC		Writeback of inode is running. The bits is set during
+ *			data writeback, and cleared with a wakeup on the bit
+ *			address once it is done. The bit is also used to pin
+ *			the inode in memory for flusher thread.
  *
  * I_REFERENCED		Marks the inode as recently references on the LRU list.
  *
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 995b8bf..3a34dc0 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -94,6 +94,7 @@ long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 				enum wb_reason reason);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+int __must_check inode_wait_for_writeback(struct inode *inode);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
@@ -101,12 +102,6 @@ static inline void wait_on_inode(struct inode *inode)
 	might_sleep();
 	wait_on_bit(&inode->i_state, __I_NEW, inode_wait, TASK_UNINTERRUPTIBLE);
 }
-static inline void inode_sync_wait(struct inode *inode)
-{
-	might_sleep();
-	wait_on_bit(&inode->i_state, __I_SYNC, inode_wait,
-							TASK_UNINTERRUPTIBLE);
-}
 
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
