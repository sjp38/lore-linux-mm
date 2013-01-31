Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1C41C6B0008
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:50:31 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/6] lib: Implement range locks
Date: Thu, 31 Jan 2013 22:49:49 +0100
Message-Id: <1359668994-13433-2-git-send-email-jack@suse.cz>
In-Reply-To: <1359668994-13433-1-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Implement range locking using interval tree.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/range_lock.h |   51 ++++++++++++++++++++++++++++
 lib/Makefile               |    4 +-
 lib/range_lock.c           |   78 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 131 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/range_lock.h
 create mode 100644 lib/range_lock.c

diff --git a/include/linux/range_lock.h b/include/linux/range_lock.h
new file mode 100644
index 0000000..fe258a5
--- /dev/null
+++ b/include/linux/range_lock.h
@@ -0,0 +1,51 @@
+/*
+ * Range locking
+ *
+ * We allow exclusive locking of arbitrary ranges. We guarantee that each
+ * range is locked only after all conflicting range locks requested previously
+ * have been unlocked. Thus we achieve fairness and avoid livelocks.
+ *
+ * The cost of lock and unlock of a range is O(log(R_all)+R_int) where R_all is
+ * total number of ranges and R_int is the number of ranges intersecting the
+ * operated range.
+ */
+#ifndef _LINUX_RANGE_LOCK_H
+#define _LINUX_RANGE_LOCK_H
+
+#include <linux/rbtree.h>
+#include <linux/interval_tree.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+
+struct task_struct;
+
+struct range_lock {
+	struct interval_tree_node node;
+	struct task_struct *task;
+	/* Number of ranges which are blocking acquisition of the lock */
+	unsigned int blocking_ranges;
+};
+
+struct range_lock_tree {
+	struct rb_root root;
+	spinlock_t lock;
+};
+
+#define RANGE_LOCK_INITIALIZER(start, end) {\
+	.node = {\
+		.start = (start),\
+		.end = (end)\
+	}\
+}
+
+static inline void range_lock_tree_init(struct range_lock_tree *tree)
+{
+	tree->root = RB_ROOT;
+	spin_lock_init(&tree->lock);
+}
+void range_lock_init(struct range_lock *lock, unsigned long start,
+		     unsigned long end);
+void range_lock(struct range_lock_tree *tree, struct range_lock *lock);
+void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 02ed6c0..04a9caa 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
-	 earlycpio.o
+	 earlycpio.o interval_tree.o range_lock.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
@@ -144,7 +144,7 @@ lib-$(CONFIG_LIBFDT) += $(libfdt_files)
 obj-$(CONFIG_RBTREE_TEST) += rbtree_test.o
 obj-$(CONFIG_INTERVAL_TREE_TEST) += interval_tree_test.o
 
-interval_tree_test-objs := interval_tree_test_main.o interval_tree.o
+interval_tree_test-objs := interval_tree_test_main.o
 
 obj-$(CONFIG_ASN1) += asn1_decoder.o
 
diff --git a/lib/range_lock.c b/lib/range_lock.c
new file mode 100644
index 0000000..1cb119b
--- /dev/null
+++ b/lib/range_lock.c
@@ -0,0 +1,78 @@
+/*
+ * Implementation of range locks.
+ *
+ * We keep interval tree of locked and to-be-locked ranges. When new range lock
+ * is requested, we add its interval to the tree and store number of intervals
+ * intersecting it to 'blocking_ranges'.
+ *
+ * When a range is unlocked, we again walk intervals that intersect with the
+ * unlocked one and decrement their 'blocking_ranges'.  We wake up owner of any
+ * range lock whose 'blocking_ranges' drops to 0.
+ */
+#include <linux/list.h>
+#include <linux/rbtree.h>
+#include <linux/interval_tree.h>
+#include <linux/spinlock.h>
+#include <linux/range_lock.h>
+#include <linux/sched.h>
+#include <linux/export.h>
+
+void range_lock_init(struct range_lock *lock, unsigned long start,
+		     unsigned long end)
+{
+	lock->node.start = start;
+	lock->node.last = end;
+	RB_CLEAR_NODE(&lock->node.rb);
+	lock->blocking_ranges = 0;
+}
+EXPORT_SYMBOL(range_lock_init);
+
+void range_lock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+	node = interval_tree_iter_first(&tree->root, lock->node.start,
+					lock->node.last);
+	while (node) {
+		lock->blocking_ranges++;
+		node = interval_tree_iter_next(node, lock->node.start,
+					       lock->node.last);
+	}
+	interval_tree_insert(&lock->node, &tree->root);
+	/* Do we need to go to sleep? */
+	while (lock->blocking_ranges) {
+		lock->task = current;
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+		spin_unlock_irqrestore(&tree->lock, flags);
+		schedule();
+		spin_lock_irqsave(&tree->lock, flags);
+	}
+	spin_unlock_irqrestore(&tree->lock, flags);
+}
+EXPORT_SYMBOL(range_lock);
+
+static void range_lock_unblock(struct range_lock *lock)
+{
+	if (!--lock->blocking_ranges)
+		wake_up_process(lock->task);
+}
+
+void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
+{
+	struct interval_tree_node *node;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tree->lock, flags);
+	interval_tree_remove(&lock->node, &tree->root);
+	node = interval_tree_iter_first(&tree->root, lock->node.start,
+					lock->node.last);
+	while (node) {
+		range_lock_unblock((struct range_lock *)node);
+		node = interval_tree_iter_next(node, lock->node.start,
+					       lock->node.last);
+	}
+	spin_unlock_irqrestore(&tree->lock, flags);
+}
+EXPORT_SYMBOL(range_unlock);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
