Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD15B6B025E
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:19:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so2568545pgb.3
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 21:19:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o7si4216505pgs.795.2017.09.29.21.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 21:19:23 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v16 1/5] lib/xbitmap: Introduce xbitmap
Date: Sat, 30 Sep 2017 12:05:50 +0800
Message-Id: <1506744354-20979-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

From: Matthew Wilcox <mawilcox@microsoft.com>

The eXtensible Bitmap is a sparse bitmap representation which is
efficient for set bits which tend to cluster.  It supports up to
'unsigned long' worth of bits, and this commit adds the bare bones --
xb_set_bit(), xb_clear_bit() and xb_test_bit().

More possible optimizations to add in the futurei 1/4 ?
1) xb_set_bit_range: set a range of bits
2) when searching a bit, if the bit is not found in the slot, move on to
the next slot directly.
3) add Tags to help searching

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>

v15->v16 ChangeLog:
1) coding style - separate small functions for bit set/clear/test;
2) Clear a range of bits in a more efficient way:
   A) clear a range of bits from the same ida bitmap directly rather than
      search the bitmap again for each bit;
   B) when the range of bits to clear covers the whole ida bitmap,
      directly free the bitmap - no need to zero the bitmap first.
3) more efficient bit searching, like 2.A.
---
 include/linux/radix-tree.h |   2 +
 include/linux/xbitmap.h    |  66 ++++++++++++
 lib/Makefile               |   2 +-
 lib/radix-tree.c           |  42 +++++++-
 lib/xbitmap.c              | 264 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 373 insertions(+), 3 deletions(-)
 create mode 100644 include/linux/xbitmap.h
 create mode 100644 lib/xbitmap.c

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e57350..1cffeb3 100644
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
diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
new file mode 100644
index 0000000..f634bd9
--- /dev/null
+++ b/include/linux/xbitmap.h
@@ -0,0 +1,66 @@
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
+bool xb_test_bit(struct xb *xb, unsigned long bit);
+void xb_clear_bit(struct xb *xb, unsigned long bit);
+unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
+				   unsigned long end);
+unsigned long xb_find_next_zero_bit(struct xb *xb, unsigned long start,
+				    unsigned long end);
+void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end);
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
index 898e879..1e15e30 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -78,6 +78,19 @@ static struct kmem_cache *radix_tree_node_cachep;
 #define IDA_PRELOAD_SIZE	(IDA_MAX_PATH * 2 - 1)
 
 /*
+ * The xbitmap implementation supports up to ULONG_MAX bits, and it is
+ * implemented based on ida bitmaps. So, given an unsigned long index,
+ * the high order XB_INDEX_BITS bits of the index is used to find the
+ * corresponding item (i.e. ida bitmap) from the radix tree, and the low
+ * order (i.e. ilog2(IDA_BITMAP_BITS)) bits of the index are indexed into
+ * the ida bitmap to find the bit.
+ */
+#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
+#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
+					      RADIX_TREE_MAP_SHIFT))
+#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
+
+/*
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
@@ -840,6 +853,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 							offset, 0, 0);
 			if (!child)
 				return -ENOMEM;
+			if (is_idr(root))
+				all_tag_set(child, IDR_FREE);
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -1986,8 +2001,8 @@ void __radix_tree_delete_node(struct radix_tree_root *root,
 	delete_node(root, node, update_node, private);
 }
 
-static bool __radix_tree_delete(struct radix_tree_root *root,
-				struct radix_tree_node *node, void __rcu **slot)
+bool __radix_tree_delete(struct radix_tree_root *root,
+			 struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
 	int exceptional = radix_tree_exceptional_entry(old) ? -1 : 0;
@@ -2005,6 +2020,29 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 }
 
 /**
+ *  xb_preload - preload for xb_set_bit()
+ *  @gfp_mask: allocation mask to use for preloading
+ *
+ * Preallocate memory to use for the next call to xb_set_bit(). This function
+ * returns with preemption disabled. It will be enabled by xb_preload_end().
+ */
+void xb_preload(gfp_t gfp)
+{
+	if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
+		preempt_disable();
+
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
+
+/**
  * radix_tree_iter_delete - delete the entry at this iterator position
  * @root: radix tree root
  * @iter: iterator state
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
new file mode 100644
index 0000000..4ab9ac2
--- /dev/null
+++ b/lib/xbitmap.c
@@ -0,0 +1,264 @@
+#include <linux/slab.h>
+#include <linux/xbitmap.h>
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
+	int err;
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long ebit;
+
+	bit %= IDA_BITMAP_BITS;
+	ebit = bit + 2;
+
+	err = __radix_tree_create(root, index, 0, &node, &slot);
+	if (err)
+		return err;
+	bitmap = rcu_dereference_raw(*slot);
+	if (radix_tree_exception(bitmap)) {
+		unsigned long tmp = (unsigned long)bitmap;
+
+		if (ebit < BITS_PER_LONG) {
+			tmp |= 1UL << ebit;
+			rcu_assign_pointer(*slot, (void *)tmp);
+			return 0;
+		}
+		bitmap = this_cpu_xchg(ida_bitmap, NULL);
+		if (!bitmap)
+			return -EAGAIN;
+		memset(bitmap, 0, sizeof(*bitmap));
+		bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
+		rcu_assign_pointer(*slot, bitmap);
+	}
+
+	if (!bitmap) {
+		if (ebit < BITS_PER_LONG) {
+			bitmap = (void *)((1UL << ebit) |
+					RADIX_TREE_EXCEPTIONAL_ENTRY);
+			__radix_tree_replace(root, node, slot, bitmap, NULL,
+						NULL);
+			return 0;
+		}
+		bitmap = this_cpu_xchg(ida_bitmap, NULL);
+		if (!bitmap)
+			return -EAGAIN;
+		memset(bitmap, 0, sizeof(*bitmap));
+		__radix_tree_replace(root, node, slot, bitmap, NULL, NULL);
+	}
+
+	__set_bit(bit, bitmap->bitmap);
+	return 0;
+}
+EXPORT_SYMBOL(xb_set_bit);
+
+/**
+ * xb_clear_bit - clear a bit in the xbitmap
+ * @xb: the xbitmap tree used to record the bit
+ * @bit: index of the bit to clear
+ *
+ * This function is used to clear a bit in the xbitmap. If all the bits of the
+ * bitmap are 0, the bitmap will be freed.
+ */
+void xb_clear_bit(struct xb *xb, unsigned long bit)
+{
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long ebit;
+
+	bit %= IDA_BITMAP_BITS;
+	ebit = bit + 2;
+
+	bitmap = __radix_tree_lookup(root, index, &node, &slot);
+	if (radix_tree_exception(bitmap)) {
+		unsigned long tmp = (unsigned long)bitmap;
+
+		if (ebit >= BITS_PER_LONG)
+			return;
+		tmp &= ~(1UL << ebit);
+		if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
+			__radix_tree_delete(root, node, slot);
+		else
+			rcu_assign_pointer(*slot, (void *)tmp);
+		return;
+	}
+
+	if (!bitmap)
+		return;
+
+	__clear_bit(bit, bitmap->bitmap);
+	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+		kfree(bitmap);
+		__radix_tree_delete(root, node, slot);
+	}
+}
+EXPORT_SYMBOL(xb_clear_bit);
+
+/**
+ * xb_clear_bit - clear a range of bits in the xbitmap
+ * @start: the start of the bit range, inclusive
+ * @end: the end of the bit range, inclusive
+ *
+ * This function is used to clear a bit in the xbitmap. If all the bits of the
+ * bitmap are 0, the bitmap will be freed.
+ */
+void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void **slot;
+	struct ida_bitmap *bitmap;
+	unsigned int nbits;
+
+	for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
+		unsigned long index = start / IDA_BITMAP_BITS;
+		unsigned long bit = start % IDA_BITMAP_BITS;
+
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (radix_tree_exception(bitmap)) {
+			unsigned long ebit = bit + 2;
+			unsigned long tmp = (unsigned long)bitmap;
+
+			nbits = min(end - start + 1, BITS_PER_LONG - ebit);
+
+			if (ebit >= BITS_PER_LONG)
+				continue;
+			bitmap_clear(&tmp, ebit, nbits);
+			if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
+				__radix_tree_delete(root, node, slot);
+			else
+				rcu_assign_pointer(*slot, (void *)tmp);
+		} else if (bitmap) {
+			nbits = min(end - start + 1, IDA_BITMAP_BITS - bit);
+
+			if (nbits != IDA_BITMAP_BITS)
+				bitmap_clear(bitmap->bitmap, bit, nbits);
+
+			if (nbits == IDA_BITMAP_BITS ||
+				bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+				kfree(bitmap);
+				__radix_tree_delete(root, node, slot);
+			}
+		}
+	}
+}
+EXPORT_SYMBOL(xb_clear_bit_range);
+
+/**
+ * xb_test_bit - test a bit in the xbitmap
+ * @xb: the xbitmap tree used to record the bit
+ * @bit: index of the bit to test
+ *
+ * This function is used to test a bit in the xbitmap.
+ * Returns: 1 if the bit is set, or 0 otherwise.
+ */
+bool xb_test_bit(struct xb *xb, unsigned long bit)
+{
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	const struct radix_tree_root *root = &xb->xbrt;
+	struct ida_bitmap *bitmap = radix_tree_lookup(root, index);
+
+	bit %= IDA_BITMAP_BITS;
+
+	if (!bitmap)
+		return false;
+	if (radix_tree_exception(bitmap)) {
+		bit += RADIX_TREE_EXCEPTIONAL_SHIFT;
+		if (bit > BITS_PER_LONG)
+			return false;
+		return (unsigned long)bitmap & (1UL << bit);
+	}
+
+	return test_bit(bit, bitmap->bitmap);
+}
+EXPORT_SYMBOL(xb_test_bit);
+
+static unsigned long xb_find_next_bit(struct xb *xb, unsigned long start,
+				      unsigned long end, bool set)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void **slot;
+	struct ida_bitmap *bmap;
+	unsigned long ret = end + 1;
+
+	for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
+		unsigned long index = start / IDA_BITMAP_BITS;
+		unsigned long bit = start % IDA_BITMAP_BITS;
+
+		bmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (radix_tree_exception(bmap)) {
+			unsigned long tmp = (unsigned long)bmap;
+			unsigned long ebit = bit + 2;
+
+			if (ebit >= BITS_PER_LONG)
+				continue;
+			if (set)
+				ret = find_next_bit(&tmp, BITS_PER_LONG, ebit);
+			else
+				ret = find_next_zero_bit(&tmp, BITS_PER_LONG,
+							 ebit);
+			if (ret < BITS_PER_LONG)
+				return ret - 2 + IDA_BITMAP_BITS * index;
+		} else if (bmap) {
+			if (set)
+				ret = find_next_bit(bmap->bitmap,
+						    IDA_BITMAP_BITS, bit);
+			else
+				ret = find_next_zero_bit(bmap->bitmap,
+							 IDA_BITMAP_BITS, bit);
+			if (ret < IDA_BITMAP_BITS)
+				return ret + index * IDA_BITMAP_BITS;
+		} else if (!bmap && !set) {
+			return start;
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * xb_find_next_set_bit - find the next set bit in a range
+ * @xb: the xbitmap to search
+ * @start: the start of the range, inclusive
+ * @end: the end of the range, inclusive
+ *
+ * Returns: the index of the found bit, or @end + 1 if no such bit is found.
+ */
+unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
+				   unsigned long end)
+{
+	return xb_find_next_bit(xb, start, end, 1);
+}
+EXPORT_SYMBOL(xb_find_next_set_bit);
+
+/**
+ * xb_find_next_zero_bit - find the next zero bit in a range
+ * @xb: the xbitmap to search
+ * @start: the start of the range, inclusive
+ * @end: the end of the range, inclusive
+ *
+ * Returns: the index of the found bit, or @end + 1 if no such bit is found.
+ */
+unsigned long xb_find_next_zero_bit(struct xb *xb, unsigned long start,
+				    unsigned long end)
+{
+	return xb_find_next_bit(xb, start, end, 0);
+}
+EXPORT_SYMBOL(xb_find_next_zero_bit);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
