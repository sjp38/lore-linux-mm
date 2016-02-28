Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 191766B0256
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 00:18:21 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p65so30215318wmp.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 21:18:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i192si13228052wmf.37.2016.02.27.21.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 21:18:19 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Sun, 28 Feb 2016 16:09:29 +1100
Subject: [PATCH 3/3] radix-tree: support locking of individual exception
 entries.
Message-ID: <145663616983.3865.11911049648442320016.stgit@notabene>
In-Reply-To: <145663588892.3865.9987439671424028216.stgit@notabene>
References: <145663588892.3865.9987439671424028216.stgit@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

The least significant bit of an exception entry is used as a lock flag.
A caller can:
 - create a locked entry by simply adding an entry with this flag set
 - lock an existing entry with radix_tree_lookup_lock().  This may return
    NULL if the entry doesn't exists, or was deleted while waiting for
    the lock.  It may return a non-exception entry if that is what is
    found.  If it returns a locked entry then it has exclusive rights
    to delete the entry.
 - unlock an entry that is already locked.  This will wake any waiters.
 - delete an entry that is locked.  This will wake waiters so that they
   return NULL without looking at the slot in the radix tree.

These must all be called with the radix tree locked (i.e. a spinlock held).
That spinlock is passed to radix_tree_lookup_lock() so that it can drop
the lock while waiting.

This is a "demonstration of concept".  I haven't actually tested, only compiled.
A possible use case is for the exception entries used by DAX.

It is possible that some of the lookups can be optimised away in some
cases by storing a slot pointer.  I wanted to keep it reasonable
simple until it was determined if it might be useful.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/radix-tree.h |    8 ++
 lib/radix-tree.c           |  158 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 166 insertions(+)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 450c12b546b7..8f579f66574b 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -308,6 +308,14 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag);
 unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item);
 
+void *radix_tree_lookup_lock(struct radix_tree_root *root, wait_queue_head_t *wq,
+			     unsigned long index, spinlock_t *lock);
+void radix_tree_unlock(struct radix_tree_root *root, wait_queue_head_t *wq,
+		       unsigned long index);
+void radix_tree_delete_unlock(struct radix_tree_root *root, wait_queue_head_t *wq,
+			      unsigned long index);
+
+
 static inline void radix_tree_preload_end(void)
 {
 	preempt_enable();
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 37d4643ab5c0..a24ea002f3eb 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1500,3 +1500,161 @@ void __init radix_tree_init(void)
 	radix_tree_init_maxindex();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
+
+/* Exception entry locking.
+ * The least significant bit of an exception entry can be used as a
+ * "locked" flag.  Supported locking operations are:
+ * radix_tree_lookup_lock() - if the indexed entry exists, lock it and
+ *         return the value, else return NULL.  If the indexed entry is not
+ *         exceptional it is returned without locking.
+ * radix_tree_unlock() - release the lock on the indexed entry
+ * radix_tree_delete_unlock() - the entry must be locked.  It will be atomically
+ *     unlocked and removed.  Any threads sleeping in lookup_lock() will return.
+ * Each of these take a radix_tree_root, a wait_queue_head_t, and an index.
+ * The '*lock' function also takes a spinlock_t which must be held when any
+ * of the functions is called.  *lock will drop the spinlock while waiting for
+ * the entry lock.
+ *
+ * As delete_unlock could free the radix_tree_node, waiters much not touch it
+ * when woken.  We provide a wake function for the waitq which records when the
+ * item has been deleted.
+ *
+ * The wait_queue_head passed should be one that is used for bit_wait, such
+ * as zone->wait_table.  We re-use the 'flags' and 'timeout' fields of the
+ * wait_bit_key to store the root and index that we are waiting for.
+ * __wake_up may only be called on one of these keys while the radix tree
+ * is locked.  The wakeup function will take the lock itself if appropriate, or
+ * may record that the radix tree entry has been deleted.  In either case
+ * the waiting function just looks at the status reported by the wakeup function
+ * and doesn't look at the radix tree itself.
+ *
+ * There is no function for locking an entry while inserting it.  Simply
+ * insert an entry that is already marked as 'locked' - lsb set.
+ *
+ */
+
+struct wait_slot_queue {
+	struct radix_tree_root	*root;
+	unsigned long		index;
+	wait_queue_t		wait;
+	enum {SLOT_WAITING, SLOT_LOCKED, SLOT_GONE} state;
+	void			*ret;
+};
+
+static inline int slot_locked(void *v)
+{
+	unsigned long l = (unsigned long)v;
+	return l & 1;
+}
+
+static inline void *lock_slot(void **v)
+{
+	unsigned long *l = (unsigned long *)v;
+	return (void*)(*l |= 1);
+}
+
+static inline void * unlock_slot(void **v)
+{
+	unsigned long *l = (unsigned long *)v;
+	return (void*)(*l &= ~1UL);
+}
+
+static int wake_slot_function(wait_queue_t *wait, unsigned mode, int sync,
+			      void *arg)
+{
+	struct wait_bit_key *key = arg;
+	struct wait_slot_queue *wait_slot =
+		container_of(wait, struct wait_slot_queue, wait);
+	void **slot;
+
+	if (wait_slot->root != key->flags ||
+	    wait_slot->index != key->timeout)
+		/* Not waking this waiter */
+		return 0;
+	if (wait_slot->state != SLOT_WAITING)
+		/* Should be impossible.... */
+		return 1;
+	if (key->bit_nr == -3)
+		/* Was just deleted, no point in doing a lookup */
+		wait_slot = NULL;
+	else
+		wait_slot->ret = __radix_tree_lookup(
+			wait_slot->root, wait_slot->index, NULL, &slot);
+	if (!wait_slot->ret || !radix_tree_exceptional_entry(wait_slot->ret)) {
+		wait_slot->state = SLOT_GONE;
+		return 1;
+	}
+	if (slot_locked(slot))
+		/* still locked */
+		return 0;
+	wait_slot->ret = lock_slot(slot);
+	wait_slot->state = SLOT_LOCKED;
+	return 1;
+}
+
+void *radix_tree_lookup_lock(struct radix_tree_root *root, wait_queue_head_t *wq,
+			     unsigned long index, spinlock_t *lock)
+{
+	void *ret, **slot;
+	struct wait_slot_queue wait;
+
+	ret = __radix_tree_lookup(root, index, NULL, &slot);
+	if (!ret || !radix_tree_exceptional_entry(ret))
+		return ret;
+	if (!slot_locked(slot))
+		return lock_slot(slot);
+
+	wait.wait.private = current;
+	wait.wait.func = wake_slot_function;
+	INIT_LIST_HEAD(&wait.wait.task_list);
+	wait.state = SLOT_WAITING;
+	wait.root = root;
+	wait.index = index;
+	wait.ret = NULL;
+	for (;;) {
+		prepare_to_wait(wq, &wait.wait,
+				TASK_UNINTERRUPTIBLE);
+		if (wait.state != SLOT_WAITING)
+			break;
+
+		spin_unlock(lock);
+		schedule();
+		spin_lock(lock);
+	}
+	finish_wait(wq, &wait.wait);
+	return wait.ret;
+}
+EXPORT_SYMBOL(radix_tree_lookup_lock);
+
+void radix_tree_unlock(struct radix_tree_root *root, wait_queue_head_t *wq,
+			unsigned long index)
+{
+	void *ret, **slot;
+
+	ret = __radix_tree_lookup(root, index, NULL, &slot);
+	if (WARN_ON_ONCE(!ret || !radix_tree_exceptional_entry(ret)))
+		return;
+	if (WARN_ON_ONCE(!slot_locked(slot)))
+		return;
+	unlock_slot(slot);
+
+	if (waitqueue_active(wq)) {
+		struct wait_bit_key key = {.flags = root, .bit_nr = -2,
+					   .timeout = index};
+		__wake_up(wq, TASK_NORMAL, 1, &key);
+	}
+}
+EXPORT_SYMBOL(radix_tree_unlock);
+
+void radix_tree_delete_unlock(struct radix_tree_root *root, wait_queue_head_t *wq,
+			      unsigned long index)
+{
+	radix_tree_delete(root, index);
+	if (waitqueue_active(wq)) {
+		/* -3 here indicates deletion */
+		struct wait_bit_key key = {.flags = root, .bit_nr = -3,
+					   .timeout = index};
+		__wake_up(wq, TASK_NORMAL, 1, &key);
+	}
+}
+EXPORT_SYMBOL(radix_tree_delete_unlock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
