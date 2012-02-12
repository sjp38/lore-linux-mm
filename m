Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0155E6B13F1
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 19:23:32 -0500 (EST)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v5 1/3] kinterval: routines to manipulate generic intervals
Date: Sun, 12 Feb 2012 01:21:36 +0100
Message-Id: <1329006098-5454-2-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Add a generic infrastructure to efficiently keep track of intervals.

An interval is represented by a triplet (start, end, type). The values
(start, end) define the bounds of the range. The type is a generic
property associated to the interval. The interpretation of the type is
left to the user.

Multiple intervals associated to the same object are stored in an
interval tree (augmented rbtree) [1], with tree ordered on starting
address. The tree cannot contain multiple entries of different
interval types which overlap; in case of overlapping intervals new
inserted intervals overwrite the old ones (completely or in part, in the
second case the old interval is shrunk or split accordingly).

Reference:
 [1] "Introduction to Algorithms" by Cormen, Leiserson, Rivest and Stein

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 include/linux/kinterval.h |  126 ++++++++++++
 lib/Makefile              |    2 +-
 lib/kinterval.c           |  483 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 610 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/kinterval.h
 create mode 100644 lib/kinterval.c

diff --git a/include/linux/kinterval.h b/include/linux/kinterval.h
new file mode 100644
index 0000000..8152265
--- /dev/null
+++ b/include/linux/kinterval.h
@@ -0,0 +1,126 @@
+/*
+ * kinterval.h - Routines for manipulating generic intervals
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * Copyright (C) 2012 Andrea Righi <andrea@betterlinux.com>
+ */
+
+#ifndef _LINUX_KINTERVAL_H
+#define _LINUX_KINTERVAL_H
+
+#include <linux/types.h>
+#include <linux/rbtree.h>
+
+/**
+ * struct kinterval - define a range in an interval tree
+ * @start: address representing the start of the range.
+ * @end: address representing the end of the range.
+ * @subtree_max_end: augmented rbtree data to perform quick lookup of the
+ *                   overlapping ranges.
+ * @type: type of the interval (defined by the user).
+ * @rb: the rbtree node.
+ */
+struct kinterval {
+	u64 start;
+	u64 end;
+	u64 subtree_max_end;
+	unsigned long type;
+	struct rb_node rb;
+};
+
+/**
+ * DECLARE_KINTERVAL_TREE - macro to declare an interval tree
+ * @__name: name of the declared interval tree.
+ *
+ * The tree is an interval tree (augmented rbtree) with tree ordered
+ * on starting address. Tree cannot contain multiple entries for differnt
+ * ranges which overlap; in case of overlapping ranges new inserted intervals
+ * overwrite the old ones (completely or in part, in the second case the old
+ * interval is shrinked accordingly).
+ *
+ * NOTE: all locking issues are left to the caller.
+ *
+ * Reference:
+ * "Introduction to Algorithms" by Cormen, Leiserson, Rivest and Stein.
+ */
+#define DECLARE_KINTERVAL_TREE(__name) struct rb_root __name
+
+/**
+ * DEFINE_KINTERVAL_TREE - macro to define and initialize an interval tree
+ * @__name: name of the declared interval tree.
+ */
+#define DEFINE_KINTERVAL_TREE(__name) \
+		struct rb_root __name = RB_ROOT
+
+/**
+ * INIT_KINTERVAL_TREE_ROOT - macro to initialize an interval tree
+ * @__root: root of the declared interval tree.
+ */
+#define INIT_KINTERVAL_TREE_ROOT(__root)	\
+	do {					\
+		(__root)->rb_node = NULL;	\
+	} while (0)
+
+/**
+ * kinterval_add - define a new range into the interval tree
+ * @root: the root of the tree.
+ * @start: start of the range to define.
+ * @end: end of the range to define.
+ * @type: attribute assinged to the range.
+ * @flags: type of memory to allocate (see kcalloc).
+ */
+int kinterval_add(struct rb_root *root, u64 start, u64 end,
+			long type, gfp_t flags);
+
+/**
+ * kinterval_del - erase a range from the interval tree
+ * @root: the root of the tree.
+ * @start: start of the range to erase.
+ * @end: end of the range to erase.
+ * @flags: type of memory to allocate (see kcalloc).
+ */
+int kinterval_del(struct rb_root *root, u64 start, u64 end, gfp_t flags);
+
+/**
+ * kinterval_lookup_range - return the attribute of a range
+ * @root: the root of the tree.
+ * @start: start of the range to lookup.
+ * @end: end of the range to lookup.
+ *
+ * NOTE: return the type of the lowest match, if the range specified by the
+ * arguments overlaps multiple intervals only the type of the first one
+ * (lowest) is returned.
+ */
+long kinterval_lookup_range(struct rb_root *root, u64 start, u64 end);
+
+/**
+ * kinterval_lookup - return the attribute of an address
+ * @root: the root of the tree.
+ * @addr: address to lookup.
+ */
+static inline long kinterval_lookup(struct rb_root *root, u64 addr)
+{
+	return kinterval_lookup_range(root, addr, addr);
+}
+
+/**
+ * kinterval_clear - erase all intervals defined in an interval tree
+ * @root: the root of the tree.
+ */
+void kinterval_clear(struct rb_root *root);
+
+#endif /* _LINUX_KINTERVAL_H */
diff --git a/lib/Makefile b/lib/Makefile
index 18515f0..9a648ba 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -12,7 +12,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 idr.o int_sqrt.o extable.o prio_tree.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o prio_heap.o ratelimit.o show_mem.o \
-	 is_single_threaded.o plist.o decompress.o
+	 is_single_threaded.o plist.o decompress.o kinterval.o
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
diff --git a/lib/kinterval.c b/lib/kinterval.c
new file mode 100644
index 0000000..2a9d463
--- /dev/null
+++ b/lib/kinterval.c
@@ -0,0 +1,483 @@
+/*
+ * kinterval.c - Routines for manipulating generic intervals
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * Copyright (C) 2012 Andrea Righi <andrea@betterlinux.com>
+ */
+
+#include <linux/init.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/rbtree.h>
+#include <linux/kinterval.h>
+
+static struct kmem_cache *kinterval_cachep __read_mostly;
+
+static bool is_interval_overlapping(struct kinterval *node, u64 start, u64 end)
+{
+	return !(node->start > end || node->end < start);
+}
+
+static u64 get_subtree_max_end(struct rb_node *node)
+{
+	struct kinterval *range;
+
+	if (!node)
+		return 0;
+	range = rb_entry(node, struct kinterval, rb);
+
+	return range->subtree_max_end;
+}
+
+/* Update 'subtree_max_end' for a node, based on node and its children */
+static void kinterval_rb_augment_cb(struct rb_node *node, void *__unused)
+{
+	struct kinterval *range;
+	u64 max_end, child_max_end;
+
+	if (!node)
+		return;
+	range = rb_entry(node, struct kinterval, rb);
+	max_end = range->end;
+
+	child_max_end = get_subtree_max_end(node->rb_right);
+	if (child_max_end > max_end)
+		max_end = child_max_end;
+
+	child_max_end = get_subtree_max_end(node->rb_left);
+	if (child_max_end > max_end)
+		max_end = child_max_end;
+
+	range->subtree_max_end = max_end;
+}
+
+/*
+ * Find the lowest overlapping range from the tree.
+ *
+ * Return NULL if there is no overlap.
+ */
+static struct kinterval *
+kinterval_rb_lowest_match(struct rb_root *root, u64 start, u64 end)
+{
+	struct rb_node *node = root->rb_node;
+	struct kinterval *lower_range = NULL;
+
+	while (node) {
+		struct kinterval *range = rb_entry(node, struct kinterval, rb);
+
+		if (get_subtree_max_end(node->rb_left) > start) {
+			node = node->rb_left;
+		} else if (is_interval_overlapping(range, start, end)) {
+			lower_range = range;
+			break;
+		} else if (start >= range->start) {
+			node = node->rb_right;
+		} else {
+			break;
+		}
+	}
+	return lower_range;
+}
+
+static void
+kinterval_rb_insert(struct rb_root *root, struct kinterval *new)
+{
+	struct rb_node **node = &(root->rb_node);
+	struct rb_node *parent = NULL;
+
+	while (*node) {
+		struct kinterval *range = rb_entry(*node, struct kinterval, rb);
+
+		parent = *node;
+		if (new->start <= range->start)
+			node = &((*node)->rb_left);
+		else if (new->start > range->start)
+			node = &((*node)->rb_right);
+	}
+
+	rb_link_node(&new->rb, parent, node);
+	rb_insert_color(&new->rb, root);
+	rb_augment_insert(&new->rb, kinterval_rb_augment_cb, NULL);
+}
+
+/* Merge adjacent intervals */
+static void kinterval_rb_merge(struct rb_root *root)
+{
+	struct kinterval *next, *prev = NULL;
+	struct rb_node *node, *deepest;
+
+	node = rb_first(root);
+	while (node) {
+		next = rb_entry(node, struct kinterval, rb);
+		node = rb_next(&next->rb);
+
+		if (prev && prev->type == next->type &&
+				prev->end == (next->start - 1) &&
+				prev->end < next->start) {
+			prev->end = next->end;
+			deepest = rb_augment_erase_begin(&next->rb);
+			rb_erase(&next->rb, root);
+			rb_augment_erase_end(deepest,
+					kinterval_rb_augment_cb, NULL);
+			kmem_cache_free(kinterval_cachep, next);
+		} else {
+			prev = next;
+		}
+	}
+}
+
+static int kinterval_rb_check_add(struct rb_root *root,
+				struct kinterval *new, gfp_t flags)
+{
+	struct kinterval *old;
+	struct rb_node *node, *deepest;
+
+	node = rb_first(root);
+	while (node) {
+		old = rb_entry(node, struct kinterval, rb);
+		/* Check all the possible matches within the range */
+		if (old->start > new->end)
+			break;
+		node = rb_next(&old->rb);
+
+		if (!is_interval_overlapping(old, new->start, new->end))
+			continue;
+		/*
+		 * Interval is overlapping another one, shrink the old interval
+		 * accordingly.
+		 */
+		if (new->start == old->start && new->end == old->end) {
+			/*
+			 * Exact match, just update the type:
+			 *
+			 * old
+			 * |___________________|
+			 * new
+			 * |___________________|
+			 */
+			old->type = new->type;
+			kmem_cache_free(kinterval_cachep, new);
+			return 0;
+		} else if (new->start <= old->start && new->end >= old->end) {
+			/*
+			 * New range completely overwrites the old one:
+			 *
+			 *      old
+			 *      |________|
+			 * new
+			 * |___________________|
+			 *
+			 * Replace old with new.
+			 */
+			deepest = rb_augment_erase_begin(&old->rb);
+			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
+			kmem_cache_free(kinterval_cachep, old);
+		} else if (new->start <= old->start && new->end <= old->end) {
+			/*
+			 * Update the start of the interval:
+			 *
+			 * - before:
+			 *
+			 *       old
+			 *       |_____________|
+			 * new
+			 * |___________|
+			 *
+			 * - after:
+			 *
+			 * new         old
+			 * |___________|_______|
+			 */
+			rb_erase(&old->rb, root);
+			old->start = new->end + 1;
+			kinterval_rb_insert(root, old);
+			break;
+		} else if (new->start >= old->start && new->end >= old->end) {
+			/*
+			 * Update the end of the interval:
+			 *
+			 * - before:
+			 *
+			 * old
+			 * |_____________|
+			 *          new
+			 *          |___________|
+			 *
+			 * - after:
+			 *
+			 * old      new
+			 * |________|__________|
+			 */
+			deepest = rb_augment_erase_begin(&old->rb);
+			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
+			old->end = new->start - 1;
+			old->subtree_max_end = old->end;
+			kinterval_rb_insert(root, old);
+		} else if (new->start >= old->start && new->end <= old->end) {
+			struct kinterval *prev;
+
+			if (new->type == old->type) {
+				/* Same type, just drop the new element */
+				kmem_cache_free(kinterval_cachep, new);
+				return 0;
+			}
+			/*
+			 * Insert the new interval in the middle of another
+			 * one.
+			 *
+			 * - before:
+			 *
+			 * old
+			 * |___________________|
+			 *       new
+			 *       |_______|
+			 *
+			 * - after:
+			 *
+			 * prev  new     old
+			 * |_____|_______|_____|
+			 */
+			prev = kmem_cache_zalloc(kinterval_cachep, flags);
+			if (unlikely(!prev))
+				return -ENOMEM;
+
+			rb_erase(&old->rb, root);
+
+			prev->start = old->start;
+			old->start = new->end + 1;
+			prev->end = new->start - 1;
+			prev->type = old->type;
+
+			kinterval_rb_insert(root, old);
+
+			new->subtree_max_end = new->end;
+			kinterval_rb_insert(root, new);
+
+			prev->subtree_max_end = prev->end;
+			kinterval_rb_insert(root, prev);
+			return 0;
+		}
+	}
+	new->subtree_max_end = new->end;
+	kinterval_rb_insert(root, new);
+	kinterval_rb_merge(root);
+
+	return 0;
+}
+
+int kinterval_add(struct rb_root *root, u64 start, u64 end,
+			long type, gfp_t flags)
+{
+	struct kinterval *range;
+	int ret;
+
+	if (end < start)
+		return -EINVAL;
+	range = kmem_cache_zalloc(kinterval_cachep, flags);
+	if (unlikely(!range))
+		return -ENOMEM;
+	range->start = start;
+	range->end = end;
+	range->type = type;
+
+	ret = kinterval_rb_check_add(root, range, flags);
+	if (unlikely(ret < 0))
+		kmem_cache_free(kinterval_cachep, range);
+
+	return ret;
+}
+EXPORT_SYMBOL(kinterval_add);
+
+static int kinterval_rb_check_del(struct rb_root *root,
+				u64 start, u64 end, gfp_t flags)
+{
+	struct kinterval *old;
+	struct rb_node *node, *deepest;
+
+	node = rb_first(root);
+	while (node) {
+		old = rb_entry(node, struct kinterval, rb);
+		/* Check all the possible matches within the range */
+		if (old->start > end)
+			break;
+		node = rb_next(&old->rb);
+
+		if (!is_interval_overlapping(old, start, end))
+			continue;
+		if (start <= old->start && end >= old->end) {
+			/*
+			 * Completely erase the old range:
+			 *
+			 *      old
+			 *      |________|
+			 * erase
+			 * |___________________|
+			 */
+			deepest = rb_augment_erase_begin(&old->rb);
+			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
+			kmem_cache_free(kinterval_cachep, old);
+		} else if (start <= old->start && end <= old->end) {
+			/*
+			 * Trim the beginning of an interval:
+			 *
+			 * - before:
+			 *
+			 *       old
+			 *       |_____________|
+			 * erase
+			 * |___________|
+			 *
+			 * - after:
+			 *
+			 *             old
+			 *             |_______|
+			 */
+			rb_erase(&old->rb, root);
+			old->start = end + 1;
+			kinterval_rb_insert(root, old);
+			break;
+		} else if (start >= old->start && end >= old->end) {
+			/*
+			 * Trim the end of an interval:
+			 *
+			 * - before:
+			 *
+			 * old
+			 * |_____________|
+			 *          erase
+			 *          |___________|
+			 *
+			 * - after:
+			 *
+			 * old
+			 * |________|
+			 */
+			deepest = rb_augment_erase_begin(&old->rb);
+			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
+			old->end = start - 1;
+			old->subtree_max_end = old->end;
+			kinterval_rb_insert(root, old);
+		} else if (start >= old->start && end <= old->end) {
+			struct kinterval *prev;
+
+			/*
+			 * Trim the middle of an interval:
+			 *
+			 * - before:
+			 *
+			 * old
+			 * |___________________|
+			 *       erase
+			 *       |_______|
+			 *
+			 * - after:
+			 *
+			 * prev          old
+			 * |_____|       |_____|
+			 */
+			prev = kmem_cache_zalloc(kinterval_cachep, flags);
+			if (unlikely(!prev))
+				return -ENOMEM;
+
+			rb_erase(&old->rb, root);
+
+			prev->start = old->start;
+			old->start = end + 1;
+			prev->end = start - 1;
+			prev->type = old->type;
+
+			kinterval_rb_insert(root, old);
+
+			prev->subtree_max_end = prev->end;
+			kinterval_rb_insert(root, prev);
+			break;
+		}
+	}
+	return 0;
+}
+
+int kinterval_del(struct rb_root *root, u64 start, u64 end, gfp_t flags)
+{
+	if (end < start)
+		return -EINVAL;
+	return kinterval_rb_check_del(root, start, end, flags);
+}
+EXPORT_SYMBOL(kinterval_del);
+
+void kinterval_clear(struct rb_root *root)
+{
+	struct kinterval *range;
+	struct rb_node *node;
+
+	node = rb_first(root);
+	while (node) {
+		range = rb_entry(node, struct kinterval, rb);
+#ifdef DEBUG
+		printk(KERN_INFO "start=%llu end=%llu type=%lu\n",
+					range->start, range->end, range->type);
+#endif
+		node = rb_next(&range->rb);
+		rb_erase(&range->rb, root);
+		kmem_cache_free(kinterval_cachep, range);
+	}
+}
+EXPORT_SYMBOL(kinterval_clear);
+
+long kinterval_lookup_range(struct rb_root *root, u64 start, u64 end)
+{
+	struct kinterval *range;
+
+	if (end < start)
+		return -EINVAL;
+	range = kinterval_rb_lowest_match(root, start, end);
+	return range ? range->type : -ENOENT;
+}
+EXPORT_SYMBOL(kinterval_lookup_range);
+
+static int __init kinterval_init(void)
+{
+	kinterval_cachep = kmem_cache_create("kinterval_cache",
+					sizeof(struct kinterval),
+					0, 0, NULL);
+	if (unlikely(!kinterval_cachep)) {
+		printk(KERN_ERR "kinterval: failed to create slab cache\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void __exit kinterval_exit(void)
+{
+	kmem_cache_destroy(kinterval_cachep);
+}
+
+module_init(kinterval_init);
+module_exit(kinterval_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Generic interval ranges");
+MODULE_AUTHOR("Andrea Righi <andrea@betterlinux.com>");
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
