Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 558AB6B02F3
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 23:38:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w187so90083987pgb.10
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:38:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o19si1353342pgk.231.2017.08.16.20.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 20:38:18 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v14 1/5] lib/xbitmap: Introduce xbitmap
Date: Thu, 17 Aug 2017 11:26:52 +0800
Message-Id: <1502940416-42944-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

From: Matthew Wilcox <mawilcox@microsoft.com>

The eXtensible Bitmap is a sparse bitmap representation which is
efficient for set bits which tend to cluster.  It supports up to
'unsigned long' worth of bits, and this commit adds the bare bones --
xb_set_bit(), xb_clear_bit() and xb_test_bit().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/radix-tree.h |   3 +
 include/linux/xbitmap.h    |  61 ++++++++++++++++
 lib/Makefile               |   2 +-
 lib/radix-tree.c           |  22 +++++-
 lib/xbitmap.c              | 176 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 260 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/xbitmap.h
 create mode 100644 lib/xbitmap.c

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e57350..e1203b1 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -309,6 +309,8 @@ void radix_tree_iter_replace(struct radix_tree_root *,
 		const struct radix_tree_iter *, void __rcu **slot, void *entry);
 void radix_tree_replace_slot(struct radix_tree_root *,
 			     void __rcu **slot, void *entry);
+bool __radix_tree_delete(struct radix_tree_root *root,
+			 struct radix_tree_node *node, void __rcu **slot);
 void __radix_tree_delete_node(struct radix_tree_root *,
 			      struct radix_tree_node *,
 			      radix_tree_update_node_t update_node,
@@ -325,6 +327,7 @@ unsigned int radix_tree_gang_lookup(const struct radix_tree_root *,
 unsigned int radix_tree_gang_lookup_slot(const struct radix_tree_root *,
 			void __rcu ***results, unsigned long *indices,
 			unsigned long first_index, unsigned int max_items);
+int __radix_tree_preload(gfp_t gfp_mask, unsigned int nr);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
new file mode 100644
index 0000000..5edbf84
--- /dev/null
+++ b/include/linux/xbitmap.h
@@ -0,0 +1,61 @@
+/*
+ * eXtensible Bitmaps
+ * Copyright (c) 2017 Microsoft Corporation <mawilcox@microsoft.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * eXtensible Bitmaps provide an unlimited-size sparse bitmap facility.
+ * All bits are initially zero.
+ */
+
+#ifndef __XBITMAP_H__
+#define __XBITMAP_H__
+
+#include <linux/idr.h>
+
+struct xb {
+	struct radix_tree_root xbrt;
+};
+
+#define XB_INIT {							\
+	.xbrt = RADIX_TREE_INIT(IDR_RT_MARKER | GFP_NOWAIT),		\
+}
+#define DEFINE_XB(name)		struct xb name = XB_INIT
+
+static inline void xb_init(struct xb *xb)
+{
+	INIT_RADIX_TREE(&xb->xbrt, IDR_RT_MARKER | GFP_NOWAIT);
+}
+
+int xb_set_bit(struct xb *xb, unsigned long bit);
+bool xb_test_bit(const struct xb *xb, unsigned long bit);
+void xb_clear_bit(struct xb *xb, unsigned long bit);
+
+/* Check if the xb tree is empty */
+static inline bool xb_is_empty(const struct xb *xb)
+{
+	return radix_tree_empty(&xb->xbrt);
+}
+
+void xb_preload(gfp_t gfp);
+
+/**
+ * xb_preload_end - end preload section started with xb_preload()
+ *
+ * Each xb_preload() should be matched with an invocation of this
+ * function. See xb_preload() for details.
+ */
+static inline void xb_preload_end(void)
+{
+	preempt_enable();
+}
+
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 40c1837..ea50496 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -18,7 +18,7 @@ KCOV_INSTRUMENT_dynamic_debug.o := n
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
-	 idr.o int_sqrt.o extable.o \
+	 idr.o xbitmap.o int_sqrt.o extable.o \
 	 sha1.o chacha20.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 898e879..ee72e2c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -463,7 +463,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
+int __radix_tree_preload(gfp_t gfp_mask, unsigned int nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -496,6 +496,7 @@ static int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
 out:
 	return ret;
 }
+EXPORT_SYMBOL(__radix_tree_preload);
 
 /*
  * Load up this CPU's radix_tree_node buffer with sufficient objects to
@@ -840,6 +841,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 							offset, 0, 0);
 			if (!child)
 				return -ENOMEM;
+			if (is_idr(root))
+				all_tag_set(child, IDR_FREE);
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -1986,8 +1989,20 @@ void __radix_tree_delete_node(struct radix_tree_root *root,
 	delete_node(root, node, update_node, private);
 }
 
-static bool __radix_tree_delete(struct radix_tree_root *root,
-				struct radix_tree_node *node, void __rcu **slot)
+/**
+ * __radix_tree_delete - delete a slot from a radix tree
+ * @root: radix tree root
+ * @node: node containing the slot
+ * @slot: pointer to the slot to delete
+ *
+ * Clear @slot from @node of the radix tree. This may cause the current node to
+ * be freed. This function may be called without any locking if there are no
+ * other threads which can access this tree.
+ *
+ * Return: the node or NULL if the node is freed.
+ */
+bool __radix_tree_delete(struct radix_tree_root *root,
+			 struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
 	int exceptional = radix_tree_exceptional_entry(old) ? -1 : 0;
@@ -2003,6 +2018,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 	replace_slot(slot, NULL, node, -1, exceptional);
 	return node && delete_node(root, node, NULL, NULL);
 }
+EXPORT_SYMBOL(__radix_tree_delete);
 
 /**
  * radix_tree_iter_delete - delete the entry at this iterator position
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
new file mode 100644
index 0000000..cc766d9
--- /dev/null
+++ b/lib/xbitmap.c
@@ -0,0 +1,176 @@
+#include <linux/slab.h>
+#include <linux/xbitmap.h>
+
+/*
+ * The xbitmap implementation supports up to ULONG_MAX bits, and it is
+ * implemented based on ida bitmaps. So, given an unsigned long index,
+ * the high order XB_INDEX_BITS bits of the index is used to find the
+ * corresponding iteam (i.e. ida bitmap) from the radix tree, and the low
+ * order (i.e. ilog2(IDA_BITMAP_BITS)) bits of the index are indexed into
+ * the ida bitmap to find the bit.
+ */
+#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
+#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
+					      RADIX_TREE_MAP_SHIFT))
+#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
+
+enum xb_ops {
+	XB_SET,
+	XB_CLEAR,
+	XB_TEST
+};
+
+static int xb_bit_ops(struct xb *xb, unsigned long bit, enum xb_ops ops)
+{
+	int ret = 0;
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long ebit, tmp;
+
+	bit %= IDA_BITMAP_BITS;
+	ebit = bit + RADIX_TREE_EXCEPTIONAL_SHIFT;
+
+	switch (ops) {
+	case XB_SET:
+		ret = __radix_tree_create(root, index, 0, &node, &slot);
+		if (ret)
+			return ret;
+		bitmap = rcu_dereference_raw(*slot);
+		if (radix_tree_exception(bitmap)) {
+			tmp = (unsigned long)bitmap;
+			if (ebit < BITS_PER_LONG) {
+				tmp |= 1UL << ebit;
+				rcu_assign_pointer(*slot, (void *)tmp);
+				return 0;
+			}
+			bitmap = this_cpu_xchg(ida_bitmap, NULL);
+			if (!bitmap)
+				return -EAGAIN;
+			memset(bitmap, 0, sizeof(*bitmap));
+			bitmap->bitmap[0] =
+					tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+			rcu_assign_pointer(*slot, bitmap);
+		}
+		if (!bitmap) {
+			if (ebit < BITS_PER_LONG) {
+				bitmap = (void *)((1UL << ebit) |
+					RADIX_TREE_EXCEPTIONAL_ENTRY);
+				__radix_tree_replace(root, node, slot, bitmap,
+						     NULL, NULL);
+				return 0;
+			}
+			bitmap = this_cpu_xchg(ida_bitmap, NULL);
+			if (!bitmap)
+				return -EAGAIN;
+			memset(bitmap, 0, sizeof(*bitmap));
+			__radix_tree_replace(root, node, slot, bitmap, NULL,
+					     NULL);
+		}
+		__set_bit(bit, bitmap->bitmap);
+		break;
+	case XB_CLEAR:
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (radix_tree_exception(bitmap)) {
+			tmp = (unsigned long)bitmap;
+			if (ebit >= BITS_PER_LONG)
+				return 0;
+			tmp &= ~(1UL << ebit);
+			if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
+				__radix_tree_delete(root, node, slot);
+			else
+				rcu_assign_pointer(*slot, (void *)tmp);
+			return 0;
+		}
+		if (!bitmap)
+			return 0;
+		__clear_bit(bit, bitmap->bitmap);
+		if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+			kfree(bitmap);
+			__radix_tree_delete(root, node, slot);
+		}
+		break;
+	case XB_TEST:
+		bitmap = radix_tree_lookup(root, index);
+		if (!bitmap)
+			return 0;
+		if (radix_tree_exception(bitmap)) {
+			if (ebit > BITS_PER_LONG)
+				return 0;
+			return (unsigned long)bitmap & (1UL << bit);
+		}
+		ret = test_bit(bit, bitmap->bitmap);
+		break;
+	default:
+		return -EINVAL;
+	}
+	return ret;
+}
+
+/**
+ *  xb_set_bit - set a bit in the xbitmap
+ *  @xb: the xbitmap tree used to record the bit
+ *  @bit: index of the bit to set
+ *
+ * This function is used to set a bit in the xbitmap. If the bitmap that @bit
+ * resides in is not there, it will be allocated.
+ *
+ * Returns: 0 on success. %-EAGAIN indicates that @bit was not set. The caller
+ * may want to call the function again.
+ */
+int xb_set_bit(struct xb *xb, unsigned long bit)
+{
+	return xb_bit_ops(xb, bit, XB_SET);
+}
+EXPORT_SYMBOL(xb_set_bit);
+
+/**
+ * xb_clear_bit - clear a bit in the xbitmap
+ * @xb: the xbitmap tree used to record the bit
+ * @bit: index of the bit to set
+ *
+ * This function is used to clear a bit in the xbitmap. If all the bits of the
+ * bitmap are 0, the bitmap will be freed.
+ */
+void xb_clear_bit(struct xb *xb, unsigned long bit)
+{
+	xb_bit_ops(xb, bit, XB_CLEAR);
+}
+EXPORT_SYMBOL(xb_clear_bit);
+
+/**
+ * xb_test_bit - test a bit in the xbitmap
+ * @xb: the xbitmap tree used to record the bit
+ * @bit: index of the bit to set
+ *
+ * This function is used to test a bit in the xbitmap.
+ * Returns: 1 if the bit is set, or 0 otherwise.
+ */
+bool xb_test_bit(const struct xb *xb, unsigned long bit)
+{
+	return (bool)xb_bit_ops(xb, bit, XB_TEST);
+}
+EXPORT_SYMBOL(xb_test_bit);
+
+/**
+ *  xb_preload - preload for xb_set_bit()
+ *  @gfp_mask: allocation mask to use for preloading
+ *
+ * Preallocate memory to use for the next call to xb_set_bit(). This function
+ * returns with preemption disabled. It will be enabled by xb_preload_end().
+ */
+void xb_preload(gfp_t gfp)
+{
+	__radix_tree_preload(gfp, XB_PRELOAD_SIZE);
+	if (!this_cpu_read(ida_bitmap)) {
+		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
+
+		if (!bitmap)
+			return;
+		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
+		kfree(bitmap);
+	}
+}
+EXPORT_SYMBOL(xb_preload);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
