Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E45576B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 11:14:32 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so29016929pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 08:14:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id cg6si5866605pad.123.2015.08.10.08.14.31
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 08:14:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 1/2] lib: Implement range locks
Date: Mon, 10 Aug 2015 18:14:23 +0300
Message-Id: <1439219664-88088-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: Jan Kara <jack@suse.cz>

Implement range locking using interval tree.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/gpu/drm/Kconfig      |  1 -
 drivers/gpu/drm/i915/Kconfig |  1 -
 include/linux/range_lock.h   | 51 +++++++++++++++++++++++++++++
 lib/Kconfig                  | 14 --------
 lib/Kconfig.debug            |  1 -
 lib/Makefile                 |  3 +-
 lib/range_lock.c             | 78 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 130 insertions(+), 19 deletions(-)
 create mode 100644 include/linux/range_lock.h
 create mode 100644 lib/range_lock.c

diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
index 06ae5008c5ed..1e02f73891fd 100644
--- a/drivers/gpu/drm/Kconfig
+++ b/drivers/gpu/drm/Kconfig
@@ -130,7 +130,6 @@ config DRM_RADEON
 	select POWER_SUPPLY
 	select HWMON
 	select BACKLIGHT_CLASS_DEVICE
-	select INTERVAL_TREE
 	help
 	  Choose this option if you have an ATI Radeon graphics card.  There
 	  are both PCI and AGP versions.  You don't need to choose this to
diff --git a/drivers/gpu/drm/i915/Kconfig b/drivers/gpu/drm/i915/Kconfig
index eb87e2538861..c76525f8cbe9 100644
--- a/drivers/gpu/drm/i915/Kconfig
+++ b/drivers/gpu/drm/i915/Kconfig
@@ -5,7 +5,6 @@ config DRM_I915
 	depends on (AGP || AGP=n)
 	select INTEL_GTT
 	select AGP_INTEL if AGP
-	select INTERVAL_TREE
 	# we need shmfs for the swappable backing store, and in particular
 	# the shmem_readpage() which depends upon tmpfs
 	select SHMEM
diff --git a/include/linux/range_lock.h b/include/linux/range_lock.h
new file mode 100644
index 000000000000..fe258a599676
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
diff --git a/lib/Kconfig b/lib/Kconfig
index a4766fee0017..29802dfd51de 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -355,20 +355,6 @@ config TEXTSEARCH_FSM
 config BTREE
 	bool
 
-config INTERVAL_TREE
-	bool
-	help
-	  Simple, embeddable, interval-tree. Can find the start of an
-	  overlapping range in log(n) time and then iterate over all
-	  overlapping nodes. The algorithm is implemented as an
-	  augmented rbtree.
-
-	  See:
-
-		Documentation/rbtree.txt
-
-	  for more information.
-
 config ASSOCIATIVE_ARRAY
 	bool
 	help
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index f7dd8f1d4075..deb14201b3c1 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1643,7 +1643,6 @@ config RBTREE_TEST
 config INTERVAL_TREE_TEST
 	tristate "Interval tree test"
 	depends on m && DEBUG_KERNEL
-	select INTERVAL_TREE
 	help
 	  A benchmark measuring the performance of the interval tree library
 
diff --git a/lib/Makefile b/lib/Makefile
index 51e1d761f0b9..7eafc7567306 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 sha1.o md5.o irq_regs.o argv_split.o \
 	 proportions.o flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
-	 earlycpio.o seq_buf.o nmi_backtrace.o
+	 earlycpio.o seq_buf.o nmi_backtrace.o interval_tree.o range_lock.o
 
 obj-$(CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS) += usercopy.o
 lib-$(CONFIG_MMU) += ioremap.o
@@ -63,7 +63,6 @@ CFLAGS_hweight.o = $(subst $(quote),,$(CONFIG_ARCH_HWEIGHT_CFLAGS))
 obj-$(CONFIG_GENERIC_HWEIGHT) += hweight.o
 
 obj-$(CONFIG_BTREE) += btree.o
-obj-$(CONFIG_INTERVAL_TREE) += interval_tree.o
 obj-$(CONFIG_ASSOCIATIVE_ARRAY) += assoc_array.o
 obj-$(CONFIG_DEBUG_PREEMPT) += smp_processor_id.o
 obj-$(CONFIG_DEBUG_LIST) += list_debug.o
diff --git a/lib/range_lock.c b/lib/range_lock.c
new file mode 100644
index 000000000000..1cb119ba6d1a
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
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
