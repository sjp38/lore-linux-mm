Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id BCE396B0092
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 04:02:38 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/4] writeback: Refactor writeback_single_inode()
Date: Fri,  9 Mar 2012 10:02:27 +0100
Message-Id: <1331283748-12959-4-git-send-email-jack@suse.cz>
In-Reply-To: <1331283748-12959-1-git-send-email-jack@suse.cz>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

The code in writeback_single_inode() is relatively complex. The list
requeing logic makes sense only for flusher thread but not really for
sync_inode() or write_inode_now() callers. Also when we want to get
rid of inode references held by flusher thread, we will need a special
I_SYNC handling there.

So separate part of writeback_single_inode() which does the real writeback work
into __writeback_single_inode(). Make writeback_single_inode() do only stuff
necessary for callers writing only one inode, and move the special list
handling into writeback_sb_inodes() and a helper function inode_wb_requeue().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                |  264 +++++++++++++++++++++-----------------
 include/trace/events/writeback.h |   36 ++++-
 2 files changed, 174 insertions(+), 126 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index be84e28..1e8bf44 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -231,11 +231,7 @@ static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
 
 static void inode_sync_complete(struct inode *inode)
 {
-	/*
-	 * Prevent speculative execution through
-	 * spin_unlock(&wb->list_lock);
-	 */
-
+	inode->i_state &= ~I_SYNC;
 	smp_mb();
 	wake_up_bit(&inode->i_state, __I_SYNC);
 }
@@ -331,8 +327,7 @@ static int write_inode(struct inode *inode, struct writeback_control *wbc)
 /*
  * Wait for writeback on an inode to complete.
  */
-static void inode_wait_for_writeback(struct inode *inode,
-				     struct bdi_writeback *wb)
+static void inode_wait_for_writeback(struct inode *inode)
 {
 	DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
 	wait_queue_head_t *wqh;
@@ -340,70 +335,34 @@ static void inode_wait_for_writeback(struct inode *inode,
 	wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
 	while (inode->i_state & I_SYNC) {
 		spin_unlock(&inode->i_lock);
-		spin_unlock(&wb->list_lock);
 		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
-		spin_lock(&wb->list_lock);
 		spin_lock(&inode->i_lock);
 	}
 }
 
 /*
- * Write out an inode's dirty pages.  Called under wb->list_lock and
- * inode->i_lock.  Either the caller has an active reference on the inode or
- * the inode has I_WILL_FREE set.
- *
- * If `wait' is set, wait on the writeout.
+ * Do real work connected with writing out inode and its dirty pages.
  *
- * The whole writeout design is quite complex and fragile.  We want to avoid
- * starvation of particular inodes when others are being redirtied, prevent
- * livelocks, etc.
+ * The function must be called with i_lock held and drops it.
+ * I_SYNC flag of the inode must be clear on entry and the function returns
+ * with I_SYNC set. Caller must call inode_sync_complete() when it is done
+ * with postprocessing of the inode.
  */
 static int
-writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
-		       struct writeback_control *wbc)
+__writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
+			 struct writeback_control *wbc)
 {
 	struct address_space *mapping = inode->i_mapping;
 	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
 
-	assert_spin_locked(&wb->list_lock);
-	assert_spin_locked(&inode->i_lock);
-
-	if (!atomic_read(&inode->i_count))
-		WARN_ON(!(inode->i_state & (I_WILL_FREE|I_FREEING)));
-	else
-		WARN_ON(inode->i_state & I_WILL_FREE);
-
-	if (inode->i_state & I_SYNC) {
-		/*
-		 * If this inode is locked for writeback and we are not doing
-		 * writeback-for-data-integrity, move it to b_more_io so that
-		 * writeback can proceed with the other inodes on s_io.
-		 *
-		 * We'll have another go at writing back this inode when we
-		 * completed a full scan of b_io.
-		 */
-		if (wbc->sync_mode != WB_SYNC_ALL) {
-			requeue_io(inode, wb);
-			trace_writeback_single_inode_requeue(inode, wbc,
-							     nr_to_write);
-			return 0;
-		}
-
-		/*
-		 * It's a data-integrity sync.  We must wait.
-		 */
-		inode_wait_for_writeback(inode, wb);
-	}
-
 	BUG_ON(inode->i_state & I_SYNC);
-
+	assert_spin_locked(&inode->i_lock);
 	/* Set I_SYNC, reset I_DIRTY_PAGES */
 	inode->i_state |= I_SYNC;
 	inode->i_state &= ~I_DIRTY_PAGES;
 	spin_unlock(&inode->i_lock);
-	spin_unlock(&wb->list_lock);
 
 	ret = do_writepages(mapping, wbc);
 
@@ -424,6 +383,9 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 	 * write_inode()
 	 */
 	spin_lock(&inode->i_lock);
+	/* Didn't write out all pages or some became dirty? */
+	if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY))
+		inode->i_state |= I_DIRTY_PAGES;
 	dirty = inode->i_state & I_DIRTY;
 	inode->i_state &= ~(I_DIRTY_SYNC | I_DIRTY_DATASYNC);
 	spin_unlock(&inode->i_lock);
@@ -434,59 +396,56 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 			ret = err;
 	}
 
-	spin_lock(&wb->list_lock);
+	trace_writeback_single_inode(inode, wbc, nr_to_write);
+	return ret;
+}
+
+/*
+ * Write out an inode's dirty pages. Either the caller has an active reference
+ * on the inode or the inode has I_WILL_FREE set.
+ *
+ * This function is designed to be called for writing back one inode which
+ * we go e.g. from filesystem. Flusher thread uses __writeback_single_inode()
+ * and does more profound writeback list handling in writeback_sb_inodes().
+ */
+static int
+writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
+		       struct writeback_control *wbc)
+{
+	int ret;
+
 	spin_lock(&inode->i_lock);
-	inode->i_state &= ~I_SYNC;
-	if (!(inode->i_state & I_FREEING)) {
-		/*
-		 * Sync livelock prevention. Each inode is tagged and synced in
-		 * one shot. If still dirty, it will be redirty_tail()'ed below.
-		 * Update the dirty time to prevent enqueue and sync it again.
-		 */
-		if ((inode->i_state & I_DIRTY) &&
-		    (wbc->sync_mode == WB_SYNC_ALL || wbc->tagged_writepages))
-			inode->dirtied_when = jiffies;
+	if (!atomic_read(&inode->i_count))
+		WARN_ON(!(inode->i_state & (I_WILL_FREE|I_FREEING)));
+	else
+		WARN_ON(inode->i_state & I_WILL_FREE);
 
-		if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
-			/*
-			 * We didn't write back all the pages.  nfs_writepages()
-			 * sometimes bales out without doing anything.
-			 */
-			inode->i_state |= I_DIRTY_PAGES;
-			if (wbc->nr_to_write <= 0) {
-				/*
-				 * slice used up: queue for next turn
-				 */
-				requeue_io(inode, wb);
-			} else {
-				/*
-				 * Writeback blocked by something other than
-				 * congestion. Delay the inode for some time to
-				 * avoid spinning on the CPU (100% iowait)
-				 * retrying writeback of the dirty page/inode
-				 * that cannot be performed immediately.
-				 */
-				redirty_tail(inode, wb);
-			}
-		} else if (inode->i_state & I_DIRTY) {
-			/*
-			 * Filesystems can dirty the inode during writeback
-			 * operations, such as delayed allocation during
-			 * submission or metadata updates after data IO
-			 * completion.
-			 */
-			redirty_tail(inode, wb);
-		} else {
-			/*
-			 * The inode is clean.  At this point we either have
-			 * a reference to the inode or it's on it's way out.
-			 * No need to add it back to the LRU.
-			 */
-			list_del_init(&inode->i_wb_list);
+	if (inode->i_state & I_SYNC) {
+		if (wbc->sync_mode != WB_SYNC_ALL) {
+			spin_unlock(&inode->i_lock);
+			return 0;
 		}
+		/*
+		 * It's a data-integrity sync.  We must wait.
+		 */
+		inode_wait_for_writeback(inode);
 	}
+
+	ret = __writeback_single_inode(inode, wb, wbc);
+
+	spin_lock(&wb->list_lock);
+	spin_lock(&inode->i_lock);
+	if (inode->i_state & I_FREEING)
+		goto out_unlock;
+	if (inode->i_state & I_DIRTY)
+		redirty_tail(inode, wb);
+	else
+		list_del_init(&inode->i_wb_list);
+out_unlock:
 	inode_sync_complete(inode);
-	trace_writeback_single_inode(inode, wbc, nr_to_write);
+	spin_unlock(&inode->i_lock);
+	spin_unlock(&wb->list_lock);
+
 	return ret;
 }
 
@@ -521,6 +480,54 @@ static long writeback_chunk_size(struct backing_dev_info *bdi,
 	return pages;
 }
 
+static void inode_wb_requeue(struct inode *inode, struct bdi_writeback *wb,
+			     struct writeback_control *wbc)
+{
+	if (wbc->pages_skipped) {
+		/*
+		 * Writeback is not making progress due to locked buffers.
+		 * Skip this inode for now.
+		 */
+		redirty_tail(inode, wb);
+		return;
+	}
+	if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
+		/*
+		 * We didn't write back all the pages.  nfs_writepages()
+		 * sometimes bales out without doing anything.
+		 */
+		if (wbc->nr_to_write <= 0) {
+			/*
+			 * slice used up: queue for next turn
+			 */
+			requeue_io(inode, wb);
+		} else {
+			/*
+			 * Writeback blocked by something other than
+			 * congestion. Delay the inode for some time to
+			 * avoid spinning on the CPU (100% iowait)
+			 * retrying writeback of the dirty page/inode
+			 * that cannot be performed immediately.
+			 */
+			redirty_tail(inode, wb);
+		}
+		return;
+	}
+	if (inode->i_state & I_DIRTY) {
+		/*
+		 * Filesystems can dirty the inode during writeback operations,
+		 * such as delayed allocation during submission or metadata
+		 * updates after data IO completion.
+		 */
+		redirty_tail(inode, wb);
+		return;
+	}
+	/*
+	 * The inode is clean.
+	 */
+	list_del_init(&inode->i_wb_list);
+}
+
 /*
  * Write a portion of b_io inodes which belong to @sb.
  *
@@ -580,24 +587,51 @@ static long writeback_sb_inodes(struct super_block *sb,
 			redirty_tail(inode, wb);
 			continue;
 		}
+		if (inode->i_state & I_SYNC && work->sync_mode != WB_SYNC_ALL) {
+			/*
+			 * If this inode is locked for writeback and we are not
+			 * doing writeback-for-data-integrity, move it to
+			 * b_more_io so that writeback can proceed with the
+			 * other inodes on s_io.
+			 *
+			 * We'll have another go at writing back this inode
+			 * when we completed a full scan of b_io.
+			 */
+			spin_unlock(&inode->i_lock);
+			requeue_io(inode, wb);
+			trace_writeback_sb_inodes_requeue(inode);
+			continue;
+		}
+		spin_unlock(&wb->list_lock);
+
 		__iget(inode);
+		inode_wait_for_writeback(inode);
 		write_chunk = writeback_chunk_size(wb->bdi, work);
 		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
-		writeback_single_inode(inode, wb, &wbc);
+		__writeback_single_inode(inode, wb, &wbc);
 
 		work->nr_pages -= write_chunk - wbc.nr_to_write;
 		wrote += write_chunk - wbc.nr_to_write;
+		spin_lock(&wb->list_lock);
+		spin_lock(&inode->i_lock);
 		if (!(inode->i_state & I_DIRTY))
 			wrote++;
-		if (wbc.pages_skipped) {
-			/*
-			 * writeback is not making progress due to locked
-			 * buffers.  Skip this inode for now.
-			 */
-			redirty_tail(inode, wb);
-		}
+		if (inode->i_state & I_FREEING)
+			goto continue_unlock;
+		/*
+		 * Sync livelock prevention. Each inode is tagged and synced in
+		 * one shot. If still dirty, it will be redirty_tail()'ed in
+		 * inode_wb_requeue(). We update the dirty time to prevent
+		 * queueing and syncing it again.
+		 */
+		if ((inode->i_state & I_DIRTY) &&
+		    (wbc.sync_mode == WB_SYNC_ALL || wbc.tagged_writepages))
+			inode->dirtied_when = jiffies;
+		inode_wb_requeue(inode, wb, &wbc);
+continue_unlock:
+		inode_sync_complete(inode);
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&wb->list_lock);
 		iput(inode);
@@ -796,8 +830,10 @@ static long wb_writeback(struct bdi_writeback *wb,
 			trace_writeback_wait(wb->bdi, work);
 			inode = wb_inode(wb->b_more_io.prev);
 			spin_lock(&inode->i_lock);
-			inode_wait_for_writeback(inode, wb);
+			spin_unlock(&wb->list_lock);
+			inode_wait_for_writeback(inode);
 			spin_unlock(&inode->i_lock);
+			spin_lock(&wb->list_lock);
 		}
 	}
 	spin_unlock(&wb->list_lock);
@@ -1343,11 +1379,7 @@ int write_inode_now(struct inode *inode, int sync)
 		wbc.nr_to_write = 0;
 
 	might_sleep();
-	spin_lock(&wb->list_lock);
-	spin_lock(&inode->i_lock);
 	ret = writeback_single_inode(inode, wb, &wbc);
-	spin_unlock(&inode->i_lock);
-	spin_unlock(&wb->list_lock);
 	return ret;
 }
 EXPORT_SYMBOL(write_inode_now);
@@ -1366,14 +1398,8 @@ EXPORT_SYMBOL(write_inode_now);
 int sync_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
-	int ret;
 
-	spin_lock(&wb->list_lock);
-	spin_lock(&inode->i_lock);
-	ret = writeback_single_inode(inode, wb, wbc);
-	spin_unlock(&inode->i_lock);
-	spin_unlock(&wb->list_lock);
-	return ret;
+	return writeback_single_inode(inode, wb, wbc);
 }
 EXPORT_SYMBOL(sync_inode);
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 5973410..ec0a2b8 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -373,6 +373,35 @@ TRACE_EVENT(balance_dirty_pages,
 	  )
 );
 
+TRACE_EVENT(writeback_sb_inodes_requeue,
+
+	TP_PROTO(struct inode *inode),
+	TP_ARGS(inode),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long, ino)
+		__field(unsigned long, state)
+		__field(unsigned long, dirtied_when)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode_to_bdi(inode)->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->state		= inode->i_state;
+		__entry->dirtied_when	= inode->dirtied_when;
+	),
+
+	TP_printk("bdi %s: ino=%lu state=%s dirtied_when=%lu age=%lu",
+		  __entry->name,
+		  __entry->ino,
+		  show_inode_state(__entry->state),
+		  __entry->dirtied_when,
+		  (jiffies - __entry->dirtied_when) / HZ
+	)
+);
+
 DECLARE_EVENT_CLASS(writeback_congest_waited_template,
 
 	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
@@ -451,13 +480,6 @@ DECLARE_EVENT_CLASS(writeback_single_inode_template,
 	)
 );
 
-DEFINE_EVENT(writeback_single_inode_template, writeback_single_inode_requeue,
-	TP_PROTO(struct inode *inode,
-		 struct writeback_control *wbc,
-		 unsigned long nr_to_write),
-	TP_ARGS(inode, wbc, nr_to_write)
-);
-
 DEFINE_EVENT(writeback_single_inode_template, writeback_single_inode,
 	TP_PROTO(struct inode *inode,
 		 struct writeback_control *wbc,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
