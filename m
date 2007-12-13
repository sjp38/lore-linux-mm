Subject: [patch] Converting writeback linked lists to a tree based data structure
Message-Id: <20071213003231.60C00106E6@localhost>
Date: Wed, 12 Dec 2007 16:32:31 -0800 (PST)
From: mrubin@google.com (Michael Rubin)
Sender: owner-linux-mm@kvack.org
From: Michael Rubin <mrubin@google.com>
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

This is an attempt to unify the writeback data structures. By adding an
rb tree we are able to have one consistent time ordering mechanism for
writeback. This should aid debugging and allow for future work with more
sophisticated time ordering methods. This is a proposal for 2.6.25.

The patch below includes the following changes.

1) Adding a data structure to guarantee fairness when writing inodes
to disk.  The flush_tree is based on an rbtree. with duplicate keys
being chained off the same rb_node.

2) Added a FS flag to mark file systems that are not disk backed so
we don't have to flush them. Not sure I marked all of them. But just
marking these improves writeback performance.

3) Added an inode flag to allow inodes to be marked so that they are
never written back to disk. See get_pipe_inode.

Under autotest this patch has passed: fsx, bonnie, and iozone. I am
currently writing more writeback focused tests (which so far have been
passed) to add into autotest.

Performance wise I ran a quick test.

a) I used sysctl to stop background writeback.
b) I ran the "sync" command.
c) Then I created 10,000,000 files in directories of 1000 files per directory.
d) Finally I timed the "sync" command for all the dirty inodes that had been parked.

I ran the perf test 5 times on each kernel. The average for the 2.6.24
kernel was 87.8 seconds. With this patch it was 69.3.
Signed-off-by: Michael Rubin <mrubin@google.com>
---

Index: 2624rc3_wb/fs/block_dev.c
===================================================================
--- 2624rc3_wb.orig/fs/block_dev.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/block_dev.c	2007-12-11 13:55:01.000000000 -0800
@@ -518,6 +518,7 @@ static struct file_system_type bd_type =
 	.name		= "bdev",
 	.get_sb		= bd_get_sb,
 	.kill_sb	= kill_anon_super,
+	.fs_flags	= FS_ANONYMOUS,
 };
 
 static struct vfsmount *bd_mnt __read_mostly;
Index: 2624rc3_wb/fs/fs-writeback.c
===================================================================
--- 2624rc3_wb.orig/fs/fs-writeback.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/fs-writeback.c	2007-12-11 14:19:33.000000000 -0800
@@ -23,8 +23,174 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/rbtree.h>
 #include "internal.h"
 
+#define rb_to_inode(node) rb_entry((node), struct inode, i_flush_node)
+
+/*
+ * When inodes are parked for writeback they are parked in the
+ * flush_tree. The flush tree is a data structure based on an rb tree.
+ *
+ * Duplicate keys are handled by making a list in the tree for each key
+ * value. The order of how we choose the next inode to flush is decided
+ * by two fields. First the earliest dirtied_when value. If there are
+ * duplicate dirtied_when values then the earliest i_flushed_when value
+ * determines who gets flushed next.
+ *
+ * The flush tree organizes the dirtied_when keys with the rb_tree. Any
+ * inodes with a duplicate dirtied_when value are link listed together. This
+ * link list is sorted by the inode's i_flushed_when. When both the
+ * dirtied_when and the i_flushed_when are identical the order in the
+ * linked list determines the order we flush the inodes.
+ */
+
+/*
+ * Find a rb_node matching the key in the flush tree. There are no duplicate
+ * rb_nodes in the tree. Instead they are chained off the first node.
+ */
+static struct inode *flush_tree_search(struct super_block *sb,
+				       unsigned long ts)
+{
+	struct rb_node *n = sb->s_flush_root.rb_node;
+	assert_spin_locked(&inode_lock);
+	while (n) {
+		struct inode *inode = rb_to_inode(n);
+		if (time_before(ts, inode->dirtied_when)) {
+			n = n->rb_left;
+		} else if (time_after(ts, inode->dirtied_when)) {
+			n = n->rb_right;
+		} else {
+			return inode;
+		}
+	}
+	return NULL;
+}
+
+/*
+ * Inserting an inode into the flush tree. The tree is keyed by the
+ * dirtied_when member.
+ *
+ * If there is a duplicate key in the tree already the new inode is put
+ * on the tail of a list of the rb_node.
+ * All inserted inodes must have one of the I_DIRTY flags set.
+ */
+static void flush_tree_insert(struct super_block *sb, struct inode *inode)
+{
+	struct rb_node **new = &(sb->s_flush_root.rb_node);
+	struct rb_node *parent = NULL;
+
+	assert_spin_locked(&inode_lock);
+	BUG_ON((inode->i_state & I_DIRTY) == 0);
+	BUG_ON(inode->i_state & (I_FREEING|I_CLEAR));
+	BUG_ON(RB_LINKED_NODE(&inode->i_flush_node));
+
+	sb->s_flush_count++;
+
+	list_del_init(&inode->i_list);
+	while (*new) {
+		struct inode *this = rb_to_inode(*new);
+		parent = *new;
+		if (time_before(inode->dirtied_when, this->dirtied_when))
+			new = &((*new)->rb_left);
+		else if (time_after(inode->dirtied_when,
+				      this->dirtied_when)) {
+			new = &((*new)->rb_right);
+		} else {
+			list_add_tail(&inode->i_list, &this->i_list);
+			return;
+		}
+	}
+
+	/* Add in the new node and re-balance the tree */
+	rb_link_node(&inode->i_flush_node, parent, new);
+	rb_insert_color(&inode->i_flush_node, &sb->s_flush_root);
+}
+
+
+/*
+ * Here we return the inode that has the smallest key in the flush tree
+ * that is greater than the parameter "prev_time".
+ */
+static struct inode *flush_tree_min_greater(struct super_block *sb,
+					    unsigned long prev_time)
+{
+	struct rb_node *node = sb->s_flush_root.rb_node;
+	struct inode *bsf = NULL;
+	/* best so far */
+	assert_spin_locked(&inode_lock);
+	while (node) {
+		struct inode *data = rb_to_inode(node);
+		/* Just trying to get lucky */
+		if ((prev_time + 1) == data->dirtied_when)
+			return data;
+
+		/* If this value is greater than our prev_time and is
+		less than the best so far, this is our new best so far.*/
+		if ((data->dirtied_when > prev_time) &&
+		    (bsf ? bsf->dirtied_when > data->dirtied_when : 1))
+			bsf = data;
+
+		/* Search all the way down to the bottom of the tree */
+		if (time_before(prev_time, data->dirtied_when))
+			node = node->rb_left;
+		else if (time_after_eq(prev_time, data->dirtied_when))
+			node = node->rb_right;
+	}
+	return bsf;
+}
+
+/*
+ * Here is where we iterate to find the next inode to process. The
+ * strategy is to first look for any other inodes with the same dirtied_when
+ * value. If we have already processed that node then we need to find
+ * the next highest dirtied_when value in the tree.
+ */
+static struct inode *flush_tree_next(struct super_block *sb,
+				     unsigned long start_time,
+				     unsigned long prev_time)
+{
+	struct inode *inode = flush_tree_search(sb, prev_time);
+	assert_spin_locked(&inode_lock);
+	/* We have a duplicate timed inode as the last processed */
+	if (inode && (time_before(inode->i_flushed_when, start_time)))
+		return inode;
+
+	/* Now we have to find the oldest one next */
+	return flush_tree_min_greater(sb, prev_time);
+}
+
+/* Removing a node from the flushtree. */
+void flush_tree_remove(struct super_block *sb, struct inode *inode)
+{
+	struct rb_node *rb_node = &inode->i_flush_node;
+	struct rb_root *rb_root = &sb->s_flush_root;
+
+	assert_spin_locked(&inode_lock);
+	BUG_ON((inode->i_state & I_DIRTY) == 0);
+
+	sb->s_flush_count--;
+
+	/* There is no chain on this inode. Just remove it from the tree */
+	if (list_empty(&inode->i_list)) {
+		BUG_ON(!RB_LINKED_NODE(rb_node));
+		rb_erase(rb_node, rb_root);
+		memset(rb_node, 0, sizeof(*rb_node));
+		return;
+	}
+
+	/* This node is on a chain AND is in the rb_tree */
+	if (RB_LINKED_NODE(rb_node)) {
+		struct inode *new = list_entry(inode->i_list.next,
+					       struct inode, i_list);
+		rb_replace_node(rb_node, &new->i_flush_node, rb_root);
+		memset(rb_node, 0, sizeof(*rb_node));
+	}
+	/* Take it off the list */
+	list_del_init(&inode->i_list);
+}
+
+
 /**
  *	__mark_inode_dirty -	internal function
  *	@inode: inode to mark
@@ -32,7 +198,7 @@
  *	Mark an inode as dirty. Callers should use mark_inode_dirty or
  *  	mark_inode_dirty_sync.
  *
- * Put the inode on the super block's dirty list.
+ * Put the inode in the super block's flush_tree.
  *
  * CAREFUL! We mark it dirty unconditionally, but move it onto the
  * dirty list only if it is hashed or if it refers to a blockdev.
@@ -75,6 +241,13 @@ void __mark_inode_dirty(struct inode *in
 	if ((inode->i_state & flags) == flags)
 		return;
 
+	/* anonymous file systems do not write data back */
+	if (inode->i_sb->s_type->fs_flags & FS_ANONYMOUS)
+		return;
+
+	if (inode->i_state & I_DIRTY_NEVER)
+		return;
+
 	if (unlikely(block_dump)) {
 		struct dentry *dentry = NULL;
 		const char *name = "?";
@@ -97,14 +270,7 @@ void __mark_inode_dirty(struct inode *in
 	if ((inode->i_state & flags) != flags) {
 		const int was_dirty = inode->i_state & I_DIRTY;
 
-		inode->i_state |= flags;
-
-		/*
-		 * If the inode is being synced, just update its dirty state.
-		 * The unlocker will place the inode on the appropriate
-		 * superblock list, based upon its state.
-		 */
-		if (inode->i_state & I_SYNC)
+		if (inode->i_state & (I_FREEING|I_CLEAR))
 			goto out;
 
 		/*
@@ -115,16 +281,25 @@ void __mark_inode_dirty(struct inode *in
 			if (hlist_unhashed(&inode->i_hash))
 				goto out;
 		}
-		if (inode->i_state & (I_FREEING|I_CLEAR))
+
+		inode->i_state |= flags;
+
+		/*
+		 * If the inode is being synced, just update its dirty state.
+		 * The unlocker will place the inode on the appropriate
+		 * superblock list, based upon its state.
+		 */
+		if (inode->i_state & I_SYNC)
 			goto out;
 
 		/*
-		 * If the inode was already on s_dirty/s_io/s_more_io, don't
-		 * reposition it (that would break s_dirty time-ordering).
+		 * If the inode was already in the flushtree don't
+		 * re-insert it (that would break time-ordering).
 		 */
 		if (!was_dirty) {
 			inode->dirtied_when = jiffies;
-			list_move(&inode->i_list, &sb->s_dirty);
+			inode->i_flushed_when = jiffies;
+			flush_tree_insert(sb, inode);
 		}
 	}
 out:
@@ -140,38 +315,6 @@ static int write_inode(struct inode *ino
 	return 0;
 }
 
-/*
- * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
- * furthest end of its superblock's dirty-inode list.
- *
- * Before stamping the inode's ->dirtied_when, we check to see whether it is
- * already the most-recently-dirtied inode on the s_dirty list.  If that is
- * the case then the inode must have been redirtied while it was being written
- * out and we don't reset its dirtied_when.
- */
-static void redirty_tail(struct inode *inode)
-{
-	struct super_block *sb = inode->i_sb;
-
-	if (!list_empty(&sb->s_dirty)) {
-		struct inode *tail_inode;
-
-		tail_inode = list_entry(sb->s_dirty.next, struct inode, i_list);
-		if (!time_after_eq(inode->dirtied_when,
-				tail_inode->dirtied_when))
-			inode->dirtied_when = jiffies;
-	}
-	list_move(&inode->i_list, &sb->s_dirty);
-}
-
-/*
- * requeue inode for re-scanning after sb->s_io list is exhausted.
- */
-static void requeue_io(struct inode *inode)
-{
-	list_move(&inode->i_list, &inode->i_sb->s_more_io);
-}
-
 static void inode_sync_complete(struct inode *inode)
 {
 	/*
@@ -181,38 +324,9 @@ static void inode_sync_complete(struct i
 	wake_up_bit(&inode->i_state, __I_SYNC);
 }
 
-/*
- * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
- */
-static void move_expired_inodes(struct list_head *delaying_queue,
-			       struct list_head *dispatch_queue,
-				unsigned long *older_than_this)
-{
-	while (!list_empty(delaying_queue)) {
-		struct inode *inode = list_entry(delaying_queue->prev,
-						struct inode, i_list);
-		if (older_than_this &&
-			time_after(inode->dirtied_when, *older_than_this))
-			break;
-		list_move(&inode->i_list, dispatch_queue);
-	}
-}
-
-/*
- * Queue all expired dirty inodes for io, eldest first.
- */
-static void queue_io(struct super_block *sb,
-				unsigned long *older_than_this)
-{
-	list_splice_init(&sb->s_more_io, sb->s_io.prev);
-	move_expired_inodes(&sb->s_dirty, &sb->s_io, older_than_this);
-}
-
 int sb_has_dirty_inodes(struct super_block *sb)
 {
-	return !list_empty(&sb->s_dirty) ||
-	       !list_empty(&sb->s_io) ||
-	       !list_empty(&sb->s_more_io);
+	return !RB_EMPTY_ROOT(&sb->s_flush_root);
 }
 EXPORT_SYMBOL(sb_has_dirty_inodes);
 
@@ -221,7 +335,7 @@ EXPORT_SYMBOL(sb_has_dirty_inodes);
  * If `wait' is set, wait on the writeout.
  *
  * The whole writeout design is quite complex and fragile.  We want to avoid
- * starvation of particular inodes when others are being redirtied, prevent
+ * starvation of particular inodes when others are being re-dirtied, prevent
  * livelocks, etc.
  *
  * Called under inode_lock.
@@ -237,6 +351,7 @@ __sync_single_inode(struct inode *inode,
 	BUG_ON(inode->i_state & I_SYNC);
 
 	/* Set I_SYNC, reset I_DIRTY */
+	flush_tree_remove(inode->i_sb, inode);
 	dirty = inode->i_state & I_DIRTY;
 	inode->i_state |= I_SYNC;
 	inode->i_state &= ~I_DIRTY;
@@ -266,7 +381,7 @@ __sync_single_inode(struct inode *inode,
 			/*
 			 * We didn't write back all the pages.  nfs_writepages()
 			 * sometimes bales out without doing anything. Redirty
-			 * the inode; Move it from s_io onto s_more_io/s_dirty.
+			 * the inode;
 			 */
 			/*
 			 * akpm: if the caller was the kupdate function we put
@@ -279,29 +394,32 @@ __sync_single_inode(struct inode *inode,
 			 */
 			if (wbc->for_kupdate) {
 				/*
-				 * For the kupdate function we move the inode
-				 * to s_more_io so it will get more writeout as
-				 * soon as the queue becomes uncongested.
+				 * For the kupdate function we leave
+				 * dirtied_when field untouched and return
+				 * it to the flush_tree. The next iteration
+				 * of kupdate will flush more pages when
+				 * the queue is no longer congested.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				requeue_io(inode);
+				flush_tree_insert(inode->i_sb, inode);
 			} else {
 				/*
-				 * Otherwise fully redirty the inode so that
+				 * Otherwise fully re-dirty the inode so that
 				 * other inodes on this superblock will get some
 				 * writeout.  Otherwise heavy writing to one
 				 * file would indefinitely suspend writeout of
 				 * all the other files.
 				 */
 				inode->i_state |= I_DIRTY_PAGES;
-				redirty_tail(inode);
+				inode->dirtied_when = jiffies;
+				flush_tree_insert(inode->i_sb, inode);
 			}
 		} else if (inode->i_state & I_DIRTY) {
 			/*
-			 * Someone redirtied the inode while were writing back
+			 * Someone re-dirtied the inode while were writing back
 			 * the pages.
 			 */
-			redirty_tail(inode);
+			flush_tree_insert(inode->i_sb, inode);
 		} else if (atomic_read(&inode->i_count)) {
 			/*
 			 * The inode is clean, inuse
@@ -333,27 +451,20 @@ __writeback_single_inode(struct inode *i
 	else
 		WARN_ON(inode->i_state & I_WILL_FREE);
 
-	if ((wbc->sync_mode != WB_SYNC_ALL) && (inode->i_state & I_SYNC)) {
-		struct address_space *mapping = inode->i_mapping;
-		int ret;
+	BUG_ON((inode->i_state & I_DIRTY) == 0);
 
+	/*
+	 * If the inode is locked and we are not going to wait for it
+	 * to be unlocked then we can just exit the routine. Since the
+	 * inode is marked I_SYNC it will be inserted into the flush
+	 * tree by sync_single_inode when the I_SYNC is released.
+	 */
+	if ((wbc->sync_mode != WB_SYNC_ALL) && (inode->i_state & I_SYNC)) {
 		/*
 		 * We're skipping this inode because it's locked, and we're not
-		 * doing writeback-for-data-integrity.  Move it to s_more_io so
-		 * that writeback can proceed with the other inodes on s_io.
-		 * We'll have another go at writing back this inode when we
-		 * completed a full scan of s_io.
+		 * doing writeback-for-data-integrity.
 		 */
-		requeue_io(inode);
-
-		/*
-		 * Even if we don't actually write the inode itself here,
-		 * we can at least start some of the data writeout..
-		 */
-		spin_unlock(&inode_lock);
-		ret = do_writepages(mapping, wbc);
-		spin_lock(&inode_lock);
-		return ret;
+		return 0;
 	}
 
 	/*
@@ -380,11 +491,11 @@ __writeback_single_inode(struct inode *i
  * If older_than_this is non-NULL, then only write out inodes which
  * had their first dirtying at a time earlier than *older_than_this.
  *
- * If we're a pdlfush thread, then implement pdflush collision avoidance
+ * If we're a pdflush thread, then implement pdflush collision avoidance
  * against the entire list.
  *
- * WB_SYNC_HOLD is a hack for sys_sync(): reattach the inode to sb->s_dirty so
- * that it can be located for waiting on in __writeback_single_inode().
+ * WB_SYNC_HOLD is a hack for sys_sync(): so that it can be located for
+ * waiting on in __writeback_single_inode().
  *
  * Called under inode_lock.
  *
@@ -393,33 +504,34 @@ __writeback_single_inode(struct inode *i
  * a variety of queues, so all inodes are searched.  For other superblocks,
  * assume that all inodes are backed by the same queue.
  *
- * FIXME: this linear search could get expensive with many fileystems.  But
+ * FIXME: this linear search could get expensive with many filesystems.  But
  * how to fix?  We need to go from an address_space to all inodes which share
  * a queue with that address_space.  (Easy: have a global "dirty superblocks"
  * list).
  *
- * The inodes to be written are parked on sb->s_io.  They are moved back onto
- * sb->s_dirty as they are selected for writing.  This way, none can be missed
- * on the writer throttling path, and we get decent balancing between many
- * throttled threads: we don't want them all piling up on inode_sync_wait.
+ * The inodes to be written are inserted into the flush_tree.
  */
 static void
 sync_sb_inodes(struct super_block *sb, struct writeback_control *wbc)
 {
 	const unsigned long start = jiffies;	/* livelock avoidance */
+	struct inode *inode = NULL;
+	unsigned long prev_time = 0;
 
-	if (!wbc->for_kupdate || list_empty(&sb->s_io))
-		queue_io(sb, wbc->older_than_this);
+	if (sb->s_type->fs_flags & FS_ANONYMOUS)
+		return;
 
-	while (!list_empty(&sb->s_io)) {
-		struct inode *inode = list_entry(sb->s_io.prev,
-						struct inode, i_list);
+	mutex_lock(&sb->s_flush_lock);
+	spin_lock(&inode_lock);
+	while ((inode = flush_tree_next(sb, start, prev_time)) != NULL) {
 		struct address_space *mapping = inode->i_mapping;
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		long pages_skipped;
 
+		prev_time = inode->dirtied_when;
+		inode->i_flushed_when = start;
+
 		if (!bdi_cap_writeback_dirty(bdi)) {
-			redirty_tail(inode);
 			if (sb_is_blkdev_sb(sb)) {
 				/*
 				 * Dirty memory-backed blockdev: the ramdisk
@@ -439,14 +551,12 @@ sync_sb_inodes(struct super_block *sb, s
 			wbc->encountered_congestion = 1;
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* Skip a congested fs */
-			requeue_io(inode);
 			continue;		/* Skip a congested blockdev */
 		}
 
 		if (wbc->bdi && bdi != wbc->bdi) {
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* fs has the wrong queue */
-			requeue_io(inode);
 			continue;		/* blockdev has wrong queue */
 		}
 
@@ -454,6 +564,11 @@ sync_sb_inodes(struct super_block *sb, s
 		if (time_after(inode->dirtied_when, start))
 			break;
 
+		/* Was this inode dirtied too recently? */
+		if (wbc->older_than_this && time_after(inode->dirtied_when,
+						*wbc->older_than_this))
+			break;
+
 		/* Is another pdflush already flushing this queue? */
 		if (current_is_pdflush() && !writeback_acquire(bdi))
 			break;
@@ -462,19 +577,8 @@ sync_sb_inodes(struct super_block *sb, s
 		__iget(inode);
 		pages_skipped = wbc->pages_skipped;
 		__writeback_single_inode(inode, wbc);
-		if (wbc->sync_mode == WB_SYNC_HOLD) {
-			inode->dirtied_when = jiffies;
-			list_move(&inode->i_list, &sb->s_dirty);
-		}
 		if (current_is_pdflush())
 			writeback_release(bdi);
-		if (wbc->pages_skipped != pages_skipped) {
-			/*
-			 * writeback is not making progress due to locked
-			 * buffers.  Skip this inode for now.
-			 */
-			redirty_tail(inode);
-		}
 		spin_unlock(&inode_lock);
 		iput(inode);
 		cond_resched();
@@ -482,8 +586,8 @@ sync_sb_inodes(struct super_block *sb, s
 		if (wbc->nr_to_write <= 0)
 			break;
 	}
-	if (!list_empty(&sb->s_more_io))
-		wbc->more_io = 1;
+	spin_unlock(&inode_lock);
+	mutex_unlock(&sb->s_flush_lock);
 	return;		/* Leave any unwritten inodes on s_io */
 }
 
@@ -492,9 +596,9 @@ sync_sb_inodes(struct super_block *sb, s
  *
  * Note:
  * We don't need to grab a reference to superblock here. If it has non-empty
- * ->s_dirty it's hadn't been killed yet and kill_super() won't proceed
- * past sync_inodes_sb() until the ->s_dirty/s_io/s_more_io lists are all
- * empty. Since __sync_single_inode() regains inode_lock before it finally moves
+ * flush_tree it hasn't been killed yet and kill_super() won't proceed
+ * past sync_inodes_sb() until the flush_tree is empty.
+ * Since __sync_single_inode() regains inode_lock before it finally moves
  * inode from superblock lists we are OK.
  *
  * If `older_than_this' is non-zero then only flush inodes which have a
@@ -527,9 +631,7 @@ restart:
 			 */
 			if (down_read_trylock(&sb->s_umount)) {
 				if (sb->s_root) {
-					spin_lock(&inode_lock);
 					sync_sb_inodes(sb, wbc);
-					spin_unlock(&inode_lock);
 				}
 				up_read(&sb->s_umount);
 			}
@@ -546,7 +648,7 @@ restart:
 /*
  * writeback and wait upon the filesystem's dirty inodes.  The caller will
  * do this in two passes - one to write, and one to wait.  WB_SYNC_HOLD is
- * used to park the written inodes on sb->s_dirty for the wait pass.
+ * used to park the written inodes on the flush_tree for the wait pass.
  *
  * A finite limit is set on the number of pages which will be written.
  * To prevent infinite livelock of sys_sync().
@@ -568,9 +670,7 @@ void sync_inodes_sb(struct super_block *
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused) +
 			nr_dirty + nr_unstable;
 	wbc.nr_to_write += wbc.nr_to_write / 2;		/* Bit more for luck */
-	spin_lock(&inode_lock);
 	sync_sb_inodes(sb, &wbc);
-	spin_unlock(&inode_lock);
 }
 
 /*
Index: 2624rc3_wb/fs/inode.c
===================================================================
--- 2624rc3_wb.orig/fs/inode.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/inode.c	2007-12-11 13:55:01.000000000 -0800
@@ -143,6 +143,7 @@ static struct inode *alloc_inode(struct 
 		inode->i_cdev = NULL;
 		inode->i_rdev = 0;
 		inode->dirtied_when = 0;
+		memset(&inode->i_flush_node, 0, sizeof(inode->i_flush_node));
 		if (security_inode_alloc(inode)) {
 			if (inode->i_sb->s_op->destroy_inode)
 				inode->i_sb->s_op->destroy_inode(inode);
@@ -1044,6 +1045,10 @@ void generic_delete_inode(struct inode *
 {
 	const struct super_operations *op = inode->i_sb->s_op;
 
+	if ((inode->i_state & I_DIRTY)) {
+		flush_tree_remove(inode->i_sb, inode);
+		inode->i_state &= ~I_DIRTY;
+	}
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
Index: 2624rc3_wb/fs/pipe.c
===================================================================
--- 2624rc3_wb.orig/fs/pipe.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/pipe.c	2007-12-11 13:55:01.000000000 -0800
@@ -931,12 +931,10 @@ static struct inode * get_pipe_inode(voi
 	inode->i_fop = &rdwr_pipe_fops;
 
 	/*
-	 * Mark the inode dirty from the very beginning,
-	 * that way it will never be moved to the dirty
-	 * list because "mark_inode_dirty()" will think
-	 * that it already _is_ on the dirty list.
+	 * Mark the inode "never dirty" from the very beginning,
+	 * that way it will never be written back.
 	 */
-	inode->i_state = I_DIRTY;
+	inode->i_state = I_DIRTY_NEVER;
 	inode->i_mode = S_IFIFO | S_IRUSR | S_IWUSR;
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
Index: 2624rc3_wb/fs/proc/root.c
===================================================================
--- 2624rc3_wb.orig/fs/proc/root.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/proc/root.c	2007-12-11 13:55:01.000000000 -0800
@@ -102,6 +102,7 @@ struct file_system_type proc_fs_type = {
 	.name		= "proc",
 	.get_sb		= proc_get_sb,
 	.kill_sb	= proc_kill_sb,
+	.fs_flags	= FS_ANONYMOUS,
 };
 
 void __init proc_root_init(void)
Index: 2624rc3_wb/fs/super.c
===================================================================
--- 2624rc3_wb.orig/fs/super.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/super.c	2007-12-11 13:55:01.000000000 -0800
@@ -61,9 +61,8 @@ static struct super_block *alloc_super(s
 			s = NULL;
 			goto out;
 		}
-		INIT_LIST_HEAD(&s->s_dirty);
-		INIT_LIST_HEAD(&s->s_io);
-		INIT_LIST_HEAD(&s->s_more_io);
+		s->s_flush_root = RB_ROOT;
+		mutex_init(&s->s_flush_lock);
 		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
@@ -103,6 +102,7 @@ out:
  */
 static inline void destroy_super(struct super_block *s)
 {
+	mutex_destroy(&s->s_flush_lock);
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s);
Index: 2624rc3_wb/fs/sysfs/mount.c
===================================================================
--- 2624rc3_wb.orig/fs/sysfs/mount.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/fs/sysfs/mount.c	2007-12-11 13:55:01.000000000 -0800
@@ -80,6 +80,7 @@ static struct file_system_type sysfs_fs_
 	.name		= "sysfs",
 	.get_sb		= sysfs_get_sb,
 	.kill_sb	= kill_anon_super,
+	.fs_flags	= FS_ANONYMOUS,
 };
 
 int __init sysfs_init(void)
Index: 2624rc3_wb/include/linux/fs.h
===================================================================
--- 2624rc3_wb.orig/include/linux/fs.h	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/include/linux/fs.h	2007-12-11 13:55:01.000000000 -0800
@@ -90,9 +90,10 @@ extern int dir_notify_enable;
 #define SEL_EX		4
 
 /* public flags for file_system_type */
-#define FS_REQUIRES_DEV 1 
-#define FS_BINARY_MOUNTDATA 2
-#define FS_HAS_SUBTYPE 4
+#define FS_REQUIRES_DEV		1
+#define FS_BINARY_MOUNTDATA	2
+#define FS_HAS_SUBTYPE		4
+#define FS_ANONYMOUS		8
 #define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
@@ -285,6 +286,7 @@ extern int dir_notify_enable;
 #include <linux/pid.h>
 #include <linux/mutex.h>
 #include <linux/capability.h>
+#include <linux/rbtree.h>
 
 #include <asm/atomic.h>
 #include <asm/semaphore.h>
@@ -592,6 +594,8 @@ struct inode {
 	struct hlist_node	i_hash;
 	struct list_head	i_list;
 	struct list_head	i_sb_list;
+	struct rb_node		i_flush_node;
+	unsigned long		i_flushed_when;
 	struct list_head	i_dentry;
 	unsigned long		i_ino;
 	atomic_t		i_count;
@@ -1003,9 +1007,11 @@ struct super_block {
 	struct xattr_handler	**s_xattr;
 
 	struct list_head	s_inodes;	/* all inodes */
-	struct list_head	s_dirty;	/* dirty inodes */
-	struct list_head	s_io;		/* parked for writeback */
-	struct list_head	s_more_io;	/* parked for more writeback */
+
+	struct rb_root		s_flush_root;
+	unsigned long		s_flush_count;
+	struct mutex		s_flush_lock;
+
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
 	struct list_head	s_files;
 
@@ -1315,17 +1321,18 @@ struct super_operations {
  * Q: igrab() only checks on (I_FREEING|I_WILL_FREE).  Should it also check on
  *    I_CLEAR?  If not, why?
  */
-#define I_DIRTY_SYNC		1
-#define I_DIRTY_DATASYNC	2
-#define I_DIRTY_PAGES		4
-#define I_NEW			8
-#define I_WILL_FREE		16
-#define I_FREEING		32
-#define I_CLEAR			64
+#define I_DIRTY_SYNC		(1 << 0)
+#define I_DIRTY_DATASYNC	(1 << 1)
+#define I_DIRTY_PAGES		(1 << 2)
+#define I_NEW			(1 << 3)
+#define I_WILL_FREE		(1 << 4)
+#define I_FREEING		(1 << 5)
+#define I_CLEAR			(1 << 6)
 #define __I_LOCK		7
 #define I_LOCK			(1 << __I_LOCK)
 #define __I_SYNC		8
 #define I_SYNC			(1 << __I_SYNC)
+#define I_DIRTY_NEVER		(1 << 9)
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
Index: 2624rc3_wb/include/linux/rbtree.h
===================================================================
--- 2624rc3_wb.orig/include/linux/rbtree.h	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/include/linux/rbtree.h	2007-12-11 13:55:01.000000000 -0800
@@ -135,6 +135,8 @@ static inline void rb_set_color(struct r
 #define RB_EMPTY_ROOT(root)	((root)->rb_node == NULL)
 #define RB_EMPTY_NODE(node)	(rb_parent(node) == node)
 #define RB_CLEAR_NODE(node)	(rb_set_parent(node, node))
+#define RB_LINKED_NODE(node)	((node)->rb_parent_color || \
+				 (node)->rb_left || (node)->rb_right)
 
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
Index: 2624rc3_wb/include/linux/writeback.h
===================================================================
--- 2624rc3_wb.orig/include/linux/writeback.h	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/include/linux/writeback.h	2007-12-11 13:55:01.000000000 -0800
@@ -62,7 +62,6 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
-	unsigned more_io:1;		/* more io to be dispatched */
 };
 
 /*
@@ -72,6 +71,8 @@ void writeback_inodes(struct writeback_c
 int inode_wait(void *);
 void sync_inodes_sb(struct super_block *, int wait);
 void sync_inodes(int wait);
+void flush_tree_remove(struct super_block *sb, struct inode *inode);
+
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
Index: 2624rc3_wb/mm/shmem.c
===================================================================
--- 2624rc3_wb.orig/mm/shmem.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/mm/shmem.c	2007-12-11 13:55:01.000000000 -0800
@@ -2460,6 +2460,7 @@ static struct file_system_type tmpfs_fs_
 	.name		= "tmpfs",
 	.get_sb		= shmem_get_sb,
 	.kill_sb	= kill_litter_super,
+	.fs_flags	= FS_ANONYMOUS,
 };
 static struct vfsmount *shm_mnt;
 
Index: 2624rc3_wb/mm/tiny-shmem.c
===================================================================
--- 2624rc3_wb.orig/mm/tiny-shmem.c	2007-12-11 13:52:47.000000000 -0800
+++ 2624rc3_wb/mm/tiny-shmem.c	2007-12-11 13:55:01.000000000 -0800
@@ -24,6 +24,7 @@ static struct file_system_type tmpfs_fs_
 	.name		= "tmpfs",
 	.get_sb		= ramfs_get_sb,
 	.kill_sb	= kill_litter_super,
+	.fs_flags	= FS_ANONYMOUS,
 };
 
 static struct vfsmount *shm_mnt;
Index: 2624rc3_wb/mm/page-writeback.c
===================================================================
--- 2624rc3_wb.orig/mm/page-writeback.c	2007-12-11 13:54:53.000000000 -0800
+++ 2624rc3_wb/mm/page-writeback.c	2007-12-11 13:55:49.000000000 -0800
@@ -558,7 +558,6 @@ static void background_writeout(unsigned
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
 			break;
-		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
@@ -566,7 +565,7 @@ static void background_writeout(unsigned
 		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
 			/* Wrote less than expected */
-			if (wbc.encountered_congestion || wbc.more_io)
+			if (wbc.encountered_congestion)
 				congestion_wait(WRITE, HZ/10);
 			else
 				break;
@@ -633,12 +632,11 @@ static void wb_kupdate(unsigned long arg
 			global_page_state(NR_UNSTABLE_NFS) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
 	while (nr_to_write > 0) {
-		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		writeback_inodes(&wbc);
 		if (wbc.nr_to_write > 0) {
-			if (wbc.encountered_congestion || wbc.more_io)
+			if (wbc.encountered_congestion)
 				congestion_wait(WRITE, HZ/10);
 			else
 				break;	/* All the old data is written */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
