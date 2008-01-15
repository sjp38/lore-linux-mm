Subject: [patch] Converting writeback linked lists to a tree based data structure
Message-Id: <20080115080921.70E3810653@localhost>
Date: Tue, 15 Jan 2008 00:09:21 -0800 (PST)
From: mrubin@google.com (Michael Rubin)
Sender: owner-linux-mm@kvack.org
From: Michael Rubin <mrubin@google.com>
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

For those of you who have waited so long. This is the third submission
of the first attempt at this patch. It is a trilogy.

Two changes are in this patch. They are dependant on each other.

In addition we get an unintended performance improvement. Syncing
1,000,000 inodes each with 4KB of dirty data takes the original kernel
83 seconds and with the change it take 77 seconds.

1) Adding a datastructure to guarantee fairness when writing
   inodes to disk and simplify the code base.

   When inodes are parked for writeback they are parked in the
   flush_tree. The flush tree is a data structure based on an rb tree.

   Duplicate keys are handled by making a list in the tree for each key
   value. The order of how we choose the next inode to flush is decided
   by two fields. First the earliest dirtied_when value. If there are
   duplicate dirtied_when values then the earliest i_flush_gen value
   determines who gets flushed next.

   The flush tree organizes the dirtied_when keys with the rb_tree. Any
   inodes with a duplicate dirtied_when value are link listed together. This
   link list is sorted by the inode's i_flush_gen. When both the
   dirtied_when and the i_flush_gen are identical the order in the
   linked list determines the order we flush the inodes.

2) Added an inode flag to allow inodes to be marked so that they
   are never written back to disk.

   The motivation behind this change is several fold. The first is
   to insure fairness in the writeback algorithm. The second is to
   deal with a bug where the writing to large files concurrently
   to smaller ones creates a situation where writeback cannot
   keep up with traffic and memory baloons until the we hit the
   threshold watermark. This can result in surprising long latency
   with respect to disk traffic. This latency can take minutes. The
   flush tree fixes this issue and fixes several other minor issues
   with fairness also.

Signed-off-by: Michael Rubin <mrubin@google.com>
---

Index: 2624rc7_wb/fs/anon_inodes.c
===================================================================
--- 2624rc7_wb.orig/fs/anon_inodes.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/anon_inodes.c	2008-01-08 13:46:59.000000000 -0800
@@ -154,13 +154,7 @@ static struct inode *anon_inode_mkinode(
 
 	inode->i_fop = &anon_inode_fops;
 
-	/*
-	 * Mark the inode dirty from the very beginning,
-	 * that way it will never be moved to the dirty
-	 * list because mark_inode_dirty() will think
-	 * that it already _is_ on the dirty list.
-	 */
-	inode->i_state = I_DIRTY;
+	inode->i_state = I_WRITEBACK_NEVER;
 	inode->i_mode = S_IRUSR | S_IWUSR;
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
Index: 2624rc7_wb/fs/fs-writeback.c
===================================================================
--- 2624rc7_wb.orig/fs/fs-writeback.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/fs-writeback.c	2008-01-14 18:53:54.000000000 -0800
@@ -23,8 +23,185 @@
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
+ * duplicate dirtied_when values then the earliest i_flush_gen value
+ * determines who gets flushed next.
+ *
+ * The flush tree organizes the dirtied_when keys with the rb_tree. Any
+ * inodes with a duplicate dirtied_when value are link listed together. This
+ * link list is sorted by the inode's i_flush_gen. When both the
+ * dirtied_when and the i_flush_gen are identical the order in the
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
+	inode->i_flush_gen = sb->s_flush_gen;
+
+	list_del_init(&inode->i_list);
+	while (*new) {
+		struct inode *this = rb_to_inode(*new);
+		parent = *new;
+		if (time_before(inode->dirtied_when, this->dirtied_when))
+			new = &((*new)->rb_left);
+		else if (time_after(inode->dirtied_when, this->dirtied_when))
+			new = &((*new)->rb_right);
+		else {
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
+		/*
+		 * If this value is greater than our prev_time and is
+		 * less than the best so far, this is our new best so far.
+		 */
+		if (time_after(data->dirtied_when, prev_time) &&
+		    (bsf ? time_after(bsf->dirtied_when, data->dirtied_when):1))
+			bsf = data;
+
+		/* Search all the way down to the bottom of the tree */
+		if (time_before(prev_time, data->dirtied_when)) {
+			node = node->rb_left;
+		} else if (time_after_eq(prev_time, data->dirtied_when)) {
+			node = node->rb_right;
+		}
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
+				     struct inode *prev_inode,
+				     unsigned long prev_dirtied,
+				     unsigned long long flush_gen)
+{
+	struct inode *inode;
+	assert_spin_locked(&inode_lock);
+
+	/*
+	 * First we look to see if there is an inode with the same
+	 * dirtied_time as our previous processed inode.
+	 */
+	inode = flush_tree_search(sb, prev_dirtied);
+
+	/*
+	 * If there is and if it's not the same one as we just processed
+	 * and the i_flush_gen is later than our start.
+	 */
+	if (inode && (inode->i_flush_gen < flush_gen))
+		return inode;
+
+	/* If not we find the next inode that has been dirtied after this one */
+	return flush_tree_min_greater(sb, prev_dirtied);
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
 /**
  *	__mark_inode_dirty -	internal function
  *	@inode: inode to mark
@@ -32,11 +209,11 @@
  *	Mark an inode as dirty. Callers should use mark_inode_dirty or
  *  	mark_inode_dirty_sync.
  *
- * Put the inode on the super block's dirty list.
+ * Put the inode on the super block's flush_tree.
  *
  * CAREFUL! We mark it dirty unconditionally, but move it onto the
  * dirty list only if it is hashed or if it refers to a blockdev.
- * If it was not hashed, it will never be added to the dirty list
+ * If it was not hashed, it will never be added to the flush_tree
  * even if it is later hashed, as it will have been marked dirty already.
  *
  * In short, make sure you hash any inodes _before_ you start marking
@@ -75,6 +252,10 @@ void __mark_inode_dirty(struct inode *in
 	if ((inode->i_state & flags) == flags)
 		return;
 
+	if (inode->i_state & I_WRITEBACK_NEVER)
+		return;
+
+
 	if (unlikely(block_dump)) {
 		struct dentry *dentry = NULL;
 		const char *name = "?";
@@ -97,34 +278,36 @@ void __mark_inode_dirty(struct inode *in
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
+		/* If we are freeing this inode we cannot mark it dirty. */
+		if (inode->i_state & (I_FREEING|I_CLEAR))
 			goto out;
 
 		/*
-		 * Only add valid (hashed) inodes to the superblock's
-		 * dirty list.  Add blockdev inodes as well.
+		 * Only add valid (hashed) inodes to the flush_tree
+		 * Add blockdev inodes as well.
 		 */
 		if (!S_ISBLK(inode->i_mode)) {
 			if (hlist_unhashed(&inode->i_hash))
 				goto out;
 		}
-		if (inode->i_state & (I_FREEING|I_CLEAR))
+
+		inode->i_state |= flags;
+
+		/*
+		 * If the inode is locked, just update its dirty state.
+		 * The unlocker will place the inode into the flush_tree
+		 * based upon its state.
+		 */
+		if (inode->i_state & I_SYNC)
 			goto out;
 
 		/*
-		 * If the inode was already on s_dirty/s_io/s_more_io, don't
-		 * reposition it (that would break s_dirty time-ordering).
+		 * If the inode was already in the flush_tree, don't
+		 * reposition it (that would break flush_tree time-ordering).
 		 */
 		if (!was_dirty) {
 			inode->dirtied_when = jiffies;
-			list_move(&inode->i_list, &sb->s_dirty);
+			flush_tree_insert(sb, inode);
 		}
 	}
 out:
@@ -140,38 +323,6 @@ static int write_inode(struct inode *ino
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
@@ -181,38 +332,9 @@ static void inode_sync_complete(struct i
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
 
@@ -221,7 +343,7 @@ EXPORT_SYMBOL(sb_has_dirty_inodes);
  * If `wait' is set, wait on the writeout.
  *
  * The whole writeout design is quite complex and fragile.  We want to avoid
- * starvation of particular inodes when others are being redirtied, prevent
+ * starvation of particular inodes when others are being re-dirtied, prevent
  * livelocks, etc.
  *
  * Called under inode_lock.
@@ -231,10 +353,13 @@ __sync_single_inode(struct inode *inode,
 {
 	unsigned dirty;
 	struct address_space *mapping = inode->i_mapping;
+	struct super_block *sb = inode->i_sb;
 	int wait = wbc->sync_mode == WB_SYNC_ALL;
 	int ret;
+	long pages_skipped = wbc->pages_skipped;
 
 	BUG_ON(inode->i_state & I_SYNC);
+	BUG_ON(RB_LINKED_NODE(&inode->i_flush_node));
 
 	/* Set I_SYNC, reset I_DIRTY */
 	dirty = inode->i_state & I_DIRTY;
@@ -260,60 +385,63 @@ __sync_single_inode(struct inode *inode,
 
 	spin_lock(&inode_lock);
 	inode->i_state &= ~I_SYNC;
-	if (!(inode->i_state & I_FREEING)) {
-		if (!(inode->i_state & I_DIRTY) &&
+	if (inode->i_state & I_FREEING)
+		goto out;
+
+	if (wbc->pages_skipped != pages_skipped) {
+		/*
+		 * writeback is not making progress due to locked
+		 *  buffers.  Skip this inode for now.
+		*/
+		inode->i_state |= I_DIRTY_PAGES;
+		flush_tree_insert(sb, inode);
+	} else if (!(inode->i_state & I_DIRTY) &&
 		    mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
+		/*
+		 * We didn't write back all the pages.  nfs_writepages()
+		 * sometimes bales out without doing anything. Redirty
+		 * the inode; then put it into the flush_tree.
+		 */
+		if (wbc->for_kupdate) {
 			/*
-			 * We didn't write back all the pages.  nfs_writepages()
-			 * sometimes bales out without doing anything. Redirty
-			 * the inode; Move it from s_io onto s_more_io/s_dirty.
-			 */
-			/*
-			 * akpm: if the caller was the kupdate function we put
-			 * this inode at the head of s_dirty so it gets first
-			 * consideration.  Otherwise, move it to the tail, for
-			 * the reasons described there.  I'm not really sure
-			 * how much sense this makes.  Presumably I had a good
-			 * reasons for doing it this way, and I'd rather not
-			 * muck with it at present.
-			 */
-			if (wbc->for_kupdate) {
-				/*
-				 * For the kupdate function we move the inode
-				 * to s_more_io so it will get more writeout as
-				 * soon as the queue becomes uncongested.
-				 */
-				inode->i_state |= I_DIRTY_PAGES;
-				requeue_io(inode);
-			} else {
-				/*
-				 * Otherwise fully redirty the inode so that
-				 * other inodes on this superblock will get some
-				 * writeout.  Otherwise heavy writing to one
-				 * file would indefinitely suspend writeout of
-				 * all the other files.
-				 */
-				inode->i_state |= I_DIRTY_PAGES;
-				redirty_tail(inode);
-			}
-		} else if (inode->i_state & I_DIRTY) {
-			/*
-			 * Someone redirtied the inode while were writing back
-			 * the pages.
-			 */
-			redirty_tail(inode);
-		} else if (atomic_read(&inode->i_count)) {
-			/*
-			 * The inode is clean, inuse
+			 * For the kupdate function we leave
+			 * dirtied_when field untouched and return
+			 * it to the flush_tree. The next iteration
+			 * of kupdate will flush more pages when
+			 * the queue is no longer congested.
 			 */
-			list_move(&inode->i_list, &inode_in_use);
+			inode->i_state |= I_DIRTY_PAGES;
+			flush_tree_insert(sb, inode);
 		} else {
 			/*
-			 * The inode is clean, unused
+			 * Otherwise fully redirty the inode so that
+			 * other inodes on this superblock will get some
+			 * writeout.  Otherwise heavy writing to one
+			 * file would indefinitely suspend writeout of
+			 * all the other files.
 			 */
-			list_move(&inode->i_list, &inode_unused);
+			inode->i_state |= I_DIRTY_PAGES;
+			inode->dirtied_when = jiffies;
+			flush_tree_insert(sb, inode);
 		}
+	} else if (inode->i_state & I_DIRTY) {
+		/*
+		 * Someone redirtied the inode while were writing back
+		 * the pages.
+		 */
+		flush_tree_insert(inode->i_sb, inode);
+	} else if (atomic_read(&inode->i_count)) {
+		/*
+		 * The inode is clean, inuse
+		 */
+		list_move(&inode->i_list, &inode_in_use);
+	} else {
+		/*
+		 * The inode is clean, unused
+		 */
+		list_move(&inode->i_list, &inode_unused);
 	}
+out:
 	inode_sync_complete(inode);
 	return ret;
 }
@@ -333,27 +461,14 @@ __writeback_single_inode(struct inode *i
 	else
 		WARN_ON(inode->i_state & I_WILL_FREE);
 
+	/*
+	 * If the inode is locked and we are not going to wait for it
+	 * to be unlocked then we can just exit the routine. Since the
+	 * inode is marked I_DIRTY it will be inserted into the flush
+	 * tree by sync_single_inode when the I_SYNC is released.
+	 */
 	if ((wbc->sync_mode != WB_SYNC_ALL) && (inode->i_state & I_SYNC)) {
-		struct address_space *mapping = inode->i_mapping;
-		int ret;
-
-		/*
-		 * We're skipping this inode because it's locked, and we're not
-		 * doing writeback-for-data-integrity.  Move it to s_more_io so
-		 * that writeback can proceed with the other inodes on s_io.
-		 * We'll have another go at writing back this inode when we
-		 * completed a full scan of s_io.
-		 */
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
@@ -380,12 +495,9 @@ __writeback_single_inode(struct inode *i
  * If older_than_this is non-NULL, then only write out inodes which
  * had their first dirtying at a time earlier than *older_than_this.
  *
- * If we're a pdlfush thread, then implement pdflush collision avoidance
+ * If we're a pdflush thread, then implement pdflush collision avoidance
  * against the entire list.
  *
- * WB_SYNC_HOLD is a hack for sys_sync(): reattach the inode to sb->s_dirty so
- * that it can be located for waiting on in __writeback_single_inode().
- *
  * Called under inode_lock.
  *
  * If `bdi' is non-zero then we're being asked to writeback a specific queue.
@@ -398,33 +510,35 @@ __writeback_single_inode(struct inode *i
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
+	unsigned long prev_dirtied = 0;
+	unsigned long long flush_gen;
+
+	spin_lock(&inode_lock);
 
-	if (!wbc->for_kupdate || list_empty(&sb->s_io))
-		queue_io(sb, wbc->older_than_this);
+	flush_gen = ++sb->s_flush_gen;
 
-	while (!list_empty(&sb->s_io)) {
-		struct inode *inode = list_entry(sb->s_io.prev,
-						struct inode, i_list);
+	while ((inode = flush_tree_next(sb, inode,
+		prev_dirtied, flush_gen)) != NULL) {
 		struct address_space *mapping = inode->i_mapping;
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
-		long pages_skipped;
+
+		flush_tree_remove(sb , inode);
+		prev_dirtied = inode->dirtied_when;
 
 		if (!bdi_cap_writeback_dirty(bdi)) {
-			redirty_tail(inode);
 			if (sb_is_blkdev_sb(sb)) {
 				/*
 				 * Dirty memory-backed blockdev: the ramdisk
 				 * driver does this.  Skip just this inode
 				 */
+				flush_tree_insert(sb, inode);
 				continue;
 			}
 			/*
@@ -439,14 +553,14 @@ sync_sb_inodes(struct super_block *sb, s
 			wbc->encountered_congestion = 1;
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* Skip a congested fs */
-			requeue_io(inode);
+			flush_tree_insert(sb, inode);
 			continue;		/* Skip a congested blockdev */
 		}
 
 		if (wbc->bdi && bdi != wbc->bdi) {
 			if (!sb_is_blkdev_sb(sb))
 				break;		/* fs has the wrong queue */
-			requeue_io(inode);
+			flush_tree_insert(sb, inode);
 			continue;		/* blockdev has wrong queue */
 		}
 
@@ -454,36 +568,33 @@ sync_sb_inodes(struct super_block *sb, s
 		if (time_after(inode->dirtied_when, start))
 			break;
 
+		/* Was this inode dirtied too recently? */
+		if (wbc->older_than_this && time_after(inode->dirtied_when,
+						       *wbc->older_than_this))
+			break;
+
+
 		/* Is another pdflush already flushing this queue? */
 		if (current_is_pdflush() && !writeback_acquire(bdi))
 			break;
 
 		BUG_ON(inode->i_state & I_FREEING);
 		__iget(inode);
-		pages_skipped = wbc->pages_skipped;
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
 		spin_lock(&inode_lock);
-		if (wbc->nr_to_write <= 0)
+		if (wbc->nr_to_write <= 0) {
+			inode = NULL;
 			break;
+		}
 	}
-	if (!list_empty(&sb->s_more_io))
-		wbc->more_io = 1;
+	if (inode)
+		flush_tree_insert(sb, inode);
+	spin_unlock(&inode_lock);
 	return;		/* Leave any unwritten inodes on s_io */
 }
 
@@ -492,9 +603,9 @@ sync_sb_inodes(struct super_block *sb, s
  *
  * Note:
  * We don't need to grab a reference to superblock here. If it has non-empty
- * ->s_dirty it's hadn't been killed yet and kill_super() won't proceed
- * past sync_inodes_sb() until the ->s_dirty/s_io/s_more_io lists are all
- * empty. Since __sync_single_inode() regains inode_lock before it finally moves
+ * flush_tree it's hadn't been killed yet and kill_super() won't proceed
+ * past sync_inodes_sb() until the flush_tree is empty. Since
+ * __sync_single_inode() regains inode_lock before it finally moves
  * inode from superblock lists we are OK.
  *
  * If `older_than_this' is non-zero then only flush inodes which have a
@@ -527,9 +638,7 @@ restart:
 			 */
 			if (down_read_trylock(&sb->s_umount)) {
 				if (sb->s_root) {
-					spin_lock(&inode_lock);
 					sync_sb_inodes(sb, wbc);
-					spin_unlock(&inode_lock);
 				}
 				up_read(&sb->s_umount);
 			}
@@ -545,8 +654,7 @@ restart:
 
 /*
  * writeback and wait upon the filesystem's dirty inodes.  The caller will
- * do this in two passes - one to write, and one to wait.  WB_SYNC_HOLD is
- * used to park the written inodes on sb->s_dirty for the wait pass.
+ * do this in two passes - one to write, and one to wait.
  *
  * A finite limit is set on the number of pages which will be written.
  * To prevent infinite livelock of sys_sync().
@@ -557,7 +665,7 @@ restart:
 void sync_inodes_sb(struct super_block *sb, int wait)
 {
 	struct writeback_control wbc = {
-		.sync_mode	= wait ? WB_SYNC_ALL : WB_SYNC_HOLD,
+		.sync_mode	= wait ? WB_SYNC_ALL : WB_SYNC_NONE,
 		.range_start	= 0,
 		.range_end	= LLONG_MAX,
 	};
@@ -568,9 +676,7 @@ void sync_inodes_sb(struct super_block *
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused) +
 			nr_dirty + nr_unstable;
 	wbc.nr_to_write += wbc.nr_to_write / 2;		/* Bit more for luck */
-	spin_lock(&inode_lock);
 	sync_sb_inodes(sb, &wbc);
-	spin_unlock(&inode_lock);
 }
 
 /*
@@ -654,7 +760,7 @@ void sync_inodes(int wait)
  */
 int write_inode_now(struct inode *inode, int sync)
 {
-	int ret;
+	int ret = 0;
 	struct writeback_control wbc = {
 		.nr_to_write = LONG_MAX,
 		.sync_mode = WB_SYNC_ALL,
@@ -666,9 +772,7 @@ int write_inode_now(struct inode *inode,
 		wbc.nr_to_write = 0;
 
 	might_sleep();
-	spin_lock(&inode_lock);
-	ret = __writeback_single_inode(inode, &wbc);
-	spin_unlock(&inode_lock);
+	sync_inode(inode, &wbc);
 	if (sync)
 		inode_sync_wait(inode);
 	return ret;
@@ -688,10 +792,13 @@ EXPORT_SYMBOL(write_inode_now);
  */
 int sync_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	int ret;
+	int ret = 0;
 
 	spin_lock(&inode_lock);
-	ret = __writeback_single_inode(inode, wbc);
+	if (inode->i_state & I_DIRTY) {
+		flush_tree_remove(inode->i_sb, inode);
+		ret = __writeback_single_inode(inode, wbc);
+	}
 	spin_unlock(&inode_lock);
 	return ret;
 }
Index: 2624rc7_wb/fs/hugetlbfs/inode.c
===================================================================
--- 2624rc7_wb.orig/fs/hugetlbfs/inode.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/hugetlbfs/inode.c	2008-01-08 13:47:38.000000000 -0800
@@ -383,7 +383,7 @@ static void hugetlbfs_forget_inode(struc
 	struct super_block *sb = inode->i_sb;
 
 	if (!hlist_unhashed(&inode->i_hash)) {
-		if (!(inode->i_state & (I_DIRTY|I_SYNC)))
+		if (!(inode->i_state & (I_DIRTY|I_SYNC|I_WRITEBACK_NEVER)))
 			list_move(&inode->i_list, &inode_unused);
 		inodes_stat.nr_unused++;
 		if (!sb || (sb->s_flags & MS_ACTIVE)) {
Index: 2624rc7_wb/fs/inode.c
===================================================================
--- 2624rc7_wb.orig/fs/inode.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/inode.c	2008-01-08 13:54:07.000000000 -0800
@@ -143,6 +143,7 @@ static struct inode *alloc_inode(struct 
 		inode->i_cdev = NULL;
 		inode->i_rdev = 0;
 		inode->dirtied_when = 0;
+		memset(&inode->i_flush_node, 0, sizeof(inode->i_flush_node));
 		if (security_inode_alloc(inode)) {
 			if (inode->i_sb->s_op->destroy_inode)
 				inode->i_sb->s_op->destroy_inode(inode);
@@ -337,6 +338,10 @@ static int invalidate_list(struct list_h
 		inode = list_entry(tmp, struct inode, i_sb_list);
 		invalidate_inode_buffers(inode);
 		if (!atomic_read(&inode->i_count)) {
+			if (inode->i_state & I_DIRTY) {
+				flush_tree_remove(inode->i_sb, inode);
+				inode->i_state &= ~I_DIRTY;
+			}
 			list_move(&inode->i_list, dispose);
 			inode->i_state |= I_FREEING;
 			count++;
@@ -1043,7 +1048,10 @@ EXPORT_SYMBOL(remove_inode_hash);
 void generic_delete_inode(struct inode *inode)
 {
 	const struct super_operations *op = inode->i_sb->s_op;
-
+	if ((inode->i_state & I_DIRTY)) {
+		flush_tree_remove(inode->i_sb, inode);
+		inode->i_state &= ~I_DIRTY;
+	}
 	list_del_init(&inode->i_list);
 	list_del_init(&inode->i_sb_list);
 	inode->i_state |= I_FREEING;
@@ -1080,7 +1088,7 @@ static void generic_forget_inode(struct 
 	struct super_block *sb = inode->i_sb;
 
 	if (!hlist_unhashed(&inode->i_hash)) {
-		if (!(inode->i_state & (I_DIRTY|I_SYNC)))
+		if (!(inode->i_state & (I_DIRTY|I_SYNC|I_WRITEBACK_NEVER)))
 			list_move(&inode->i_list, &inode_unused);
 		inodes_stat.nr_unused++;
 		if (sb->s_flags & MS_ACTIVE) {
Index: 2624rc7_wb/fs/pipe.c
===================================================================
--- 2624rc7_wb.orig/fs/pipe.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/pipe.c	2008-01-08 13:55:15.000000000 -0800
@@ -930,13 +930,7 @@ static struct inode * get_pipe_inode(voi
 	pipe->readers = pipe->writers = 1;
 	inode->i_fop = &rdwr_pipe_fops;
 
-	/*
-	 * Mark the inode dirty from the very beginning,
-	 * that way it will never be moved to the dirty
-	 * list because "mark_inode_dirty()" will think
-	 * that it already _is_ on the dirty list.
-	 */
-	inode->i_state = I_DIRTY;
+	inode->i_state = I_WRITEBACK_NEVER;
 	inode->i_mode = S_IFIFO | S_IRUSR | S_IWUSR;
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
Index: 2624rc7_wb/fs/super.c
===================================================================
--- 2624rc7_wb.orig/fs/super.c	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/fs/super.c	2008-01-08 15:04:11.000000000 -0800
@@ -61,9 +61,7 @@ static struct super_block *alloc_super(s
 			s = NULL;
 			goto out;
 		}
-		INIT_LIST_HEAD(&s->s_dirty);
-		INIT_LIST_HEAD(&s->s_io);
-		INIT_LIST_HEAD(&s->s_more_io);
+		s->s_flush_root = RB_ROOT;
 		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_HLIST_HEAD(&s->s_anon);
@@ -103,6 +101,7 @@ out:
  */
 static inline void destroy_super(struct super_block *s)
 {
+	mutex_destroy(&s->s_flush_lock);
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s);
Index: 2624rc7_wb/include/linux/fs.h
===================================================================
--- 2624rc7_wb.orig/include/linux/fs.h	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/include/linux/fs.h	2008-01-08 14:57:42.000000000 -0800
@@ -280,6 +280,7 @@ extern int dir_notify_enable;
 #include <linux/kobject.h>
 #include <linux/list.h>
 #include <linux/radix-tree.h>
+#include <linux/rbtree.h>
 #include <linux/prio_tree.h>
 #include <linux/init.h>
 #include <linux/pid.h>
@@ -592,6 +593,8 @@ struct inode {
 	struct hlist_node	i_hash;
 	struct list_head	i_list;
 	struct list_head	i_sb_list;
+	struct rb_node		i_flush_node;
+	unsigned long long	i_flush_gen;
 	struct list_head	i_dentry;
 	unsigned long		i_ino;
 	atomic_t		i_count;
@@ -1003,9 +1006,10 @@ struct super_block {
 	struct xattr_handler	**s_xattr;
 
 	struct list_head	s_inodes;	/* all inodes */
-	struct list_head	s_dirty;	/* dirty inodes */
-	struct list_head	s_io;		/* parked for writeback */
-	struct list_head	s_more_io;	/* parked for more writeback */
+	struct rb_root		s_flush_root;
+	unsigned long		s_flush_count;
+	unsigned long long	s_flush_gen;
+
 	struct hlist_head	s_anon;		/* anonymous dentries for (nfs) exporting */
 	struct list_head	s_files;
 
@@ -1308,6 +1312,8 @@ struct super_operations {
  *			of inode dirty data.  Having a seperate lock for this
  *			purpose reduces latency and prevents some filesystem-
  *			specific deadlocks.
+ *I_WRITEBACK_NEVER	For inodes that we may dirty data to but never
+ *			want written back.
  *
  * Q: Why does I_DIRTY_DATASYNC exist?  It appears as if it could be replaced
  *    by (I_DIRTY_SYNC|I_DIRTY_PAGES).
@@ -1326,6 +1332,7 @@ struct super_operations {
 #define I_LOCK			(1 << __I_LOCK)
 #define __I_SYNC		8
 #define I_SYNC			(1 << __I_SYNC)
+#define I_WRITEBACK_NEVER	512
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
Index: 2624rc7_wb/include/linux/rbtree.h
===================================================================
--- 2624rc7_wb.orig/include/linux/rbtree.h	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/include/linux/rbtree.h	2008-01-09 01:41:30.000000000 -0800
@@ -135,6 +135,9 @@ static inline void rb_set_color(struct r
 #define RB_EMPTY_ROOT(root)	((root)->rb_node == NULL)
 #define RB_EMPTY_NODE(node)	(rb_parent(node) == node)
 #define RB_CLEAR_NODE(node)	(rb_set_parent(node, node))
+#define RB_LINKED_NODE(node)	((node)->rb_parent_color || \
+				 (node)->rb_left || (node)->rb_right)
+
 
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
Index: 2624rc7_wb/include/linux/writeback.h
===================================================================
--- 2624rc7_wb.orig/include/linux/writeback.h	2008-01-06 13:45:38.000000000 -0800
+++ 2624rc7_wb/include/linux/writeback.h	2008-01-08 14:04:38.000000000 -0800
@@ -30,7 +30,6 @@ static inline int task_is_pdflush(struct
 enum writeback_sync_modes {
 	WB_SYNC_NONE,	/* Don't wait on anything */
 	WB_SYNC_ALL,	/* Wait on every mapping */
-	WB_SYNC_HOLD,	/* Hold the inode on sb_dirty for sys_sync() */
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
