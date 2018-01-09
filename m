Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6FED6B0069
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 06:29:23 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c25so10353451pfi.11
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 03:29:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m72si249531pga.397.2018.01.09.03.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 03:29:21 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v21 1/5] xbitmap: Introduce xbitmap
Date: Tue,  9 Jan 2018 19:10:58 +0800
Message-Id: <1515496262-7533-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
References: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

From: Matthew Wilcox <mawilcox@microsoft.com>

The eXtensible Bitmap is a sparse bitmap representation which is
efficient for set bits which tend to cluster. It supports up to
'unsigned long' worth of bits.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/xbitmap.h                  |  48 ++++
 lib/Makefile                             |   2 +-
 lib/radix-tree.c                         |  38 ++-
 lib/xbitmap.c                            | 444 +++++++++++++++++++++++++++++++
 tools/include/linux/bitmap.h             |  34 +++
 tools/include/linux/kernel.h             |   2 +
 tools/testing/radix-tree/Makefile        |  17 +-
 tools/testing/radix-tree/linux/kernel.h  |   2 -
 tools/testing/radix-tree/linux/xbitmap.h |   1 +
 tools/testing/radix-tree/main.c          |   4 +
 tools/testing/radix-tree/test.h          |   1 +
 11 files changed, 583 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/xbitmap.h
 create mode 100644 lib/xbitmap.c
 create mode 100644 tools/testing/radix-tree/linux/xbitmap.h

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
new file mode 100644
index 0000000..c008309
--- /dev/null
+++ b/include/linux/xbitmap.h
@@ -0,0 +1,48 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
+/*
+ * eXtensible Bitmaps
+ * Copyright (c) 2017 Microsoft Corporation
+ * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ *
+ * eXtensible Bitmaps provide an unlimited-size sparse bitmap facility.
+ * All bits are initially zero.
+ *
+ * Locking is to be provided by the user.  No xb_ function is safe to
+ * call concurrently with any other xb_ function.
+ */
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
+void xb_zero(struct xb *xb, unsigned long min, unsigned long max);
+void xb_fill(struct xb *xb, unsigned long min, unsigned long max);
+bool xb_find_set(const struct xb *xb, unsigned long max, unsigned long *bit);
+bool xb_find_zero(const struct xb *xb, unsigned long max, unsigned long *bit);
+
+static inline bool xb_empty(const struct xb *xb)
+{
+	return radix_tree_empty(&xb->xbrt);
+}
+
+int __must_check xb_preload(gfp_t);
+
+static inline void xb_preload_end(void)
+{
+	preempt_enable();
+}
diff --git a/lib/Makefile b/lib/Makefile
index d11c48e..08a8183 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -19,7 +19,7 @@ KCOV_INSTRUMENT_dynamic_debug.o := n
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
-	 idr.o int_sqrt.o extable.o \
+	 idr.o xbitmap.o int_sqrt.o extable.o \
 	 sha1.o chacha20.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c8d5556..d2bd8fe 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -37,7 +37,7 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-
+#include <linux/xbitmap.h>
 
 /* Number of nodes in fully populated tree of given height */
 static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
@@ -77,6 +77,11 @@ static struct kmem_cache *radix_tree_node_cachep;
 						RADIX_TREE_MAP_SHIFT))
 #define IDA_PRELOAD_SIZE	(IDA_MAX_PATH * 2 - 1)
 
+#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
+#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
+						RADIX_TREE_MAP_SHIFT))
+#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
+
 /*
  * Per-cpu pool of preloaded nodes
  */
@@ -1781,7 +1786,7 @@ void __rcu **radix_tree_next_chunk(const struct radix_tree_root *root,
 			child = rcu_dereference_raw(node->slots[offset]);
 		}
 
-		if (!child)
+		if (!child && !is_idr(root))
 			goto restart;
 		if (child == RADIX_TREE_RETRY)
 			break;
@@ -2135,6 +2140,35 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
+/**
+ *  xb_preload - preload for xb_set_bit()
+ *  @gfp_mask: allocation mask to use for preloading
+ *
+ * Preallocate memory to use for the next call to xb_set_bit(). On success,
+ * return zero, with preemption disabled. On error, return -ENOMEM with
+ * preemption not disabled.
+ */
+int xb_preload(gfp_t gfp)
+{
+	if (!this_cpu_read(ida_bitmap)) {
+		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
+
+		if (!bitmap)
+			return -ENOMEM;
+		/*
+		 * The per-CPU variable is updated with preemption enabled.
+		 * If the calling task is unlucky to be scheduled to another
+		 * CPU which has no ida_bitmap allocation, it will be detected
+		 * when setting a bit (i.e. xb_set_bit()).
+		 */
+		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
+		kfree(bitmap);
+	}
+
+	return __radix_tree_preload(gfp, XB_PRELOAD_SIZE);
+}
+EXPORT_SYMBOL(xb_preload);
+
 void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
 			      struct radix_tree_iter *iter, gfp_t gfp,
 			      unsigned long max)
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
new file mode 100644
index 0000000..62b2211
--- /dev/null
+++ b/lib/xbitmap.c
@@ -0,0 +1,444 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
+/*
+ * XBitmap implementation
+ * Copyright (c) 2017 Microsoft Corporation
+ * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ */
+
+#include <linux/bitmap.h>
+#include <linux/export.h>
+#include <linux/slab.h>
+#include <linux/xbitmap.h>
+
+/**
+ * xb_set_bit() - Set a bit in the XBitmap.
+ * @xb: The XBitmap.
+ * @bit: Index of the bit to set.
+ *
+ * This function is used to set a bit in the xbitmap.
+ *
+ * Return: 0 on success. -ENOMEM if memory could not be allocated.
+ */
+int xb_set_bit(struct xb *xb, unsigned long bit)
+{
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+
+	bit %= IDA_BITMAP_BITS;
+	radix_tree_iter_init(&iter, index);
+	slot = idr_get_free_cmn(root, &iter, GFP_NOWAIT | __GFP_NOWARN, index);
+	if (IS_ERR(slot)) {
+		if (slot == ERR_PTR(-ENOSPC))
+			return 0;	/* Already set */
+		return -ENOMEM;
+	}
+	bitmap = rcu_dereference_raw(*slot);
+	if (!bitmap) {
+		bitmap = this_cpu_xchg(ida_bitmap, NULL);
+		if (!bitmap)
+			return -ENOMEM;
+		memset(bitmap, 0, sizeof(*bitmap));
+		radix_tree_iter_replace(root, &iter, slot, bitmap);
+	}
+
+	__set_bit(bit, bitmap->bitmap);
+	if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
+		radix_tree_iter_tag_clear(root, &iter, IDR_FREE);
+	return 0;
+}
+EXPORT_SYMBOL(xb_set_bit);
+
+/**
+ * xb_clear_bit() - Clear a bit in the XBitmap.
+ * @xb: The XBitmap.
+ * @bit: Index of the bit to clear.
+ *
+ * This function is used to clear a bit in the xbitmap.
+ */
+void xb_clear_bit(struct xb *xb, unsigned long bit)
+{
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+
+	bit %= IDA_BITMAP_BITS;
+	slot = radix_tree_iter_lookup(root, &iter, index);
+	if (!slot)
+		return;
+	bitmap = radix_tree_deref_slot(slot);
+	if (!bitmap)
+		return;
+
+	radix_tree_iter_tag_set(root, &iter, IDR_FREE);
+	__clear_bit(bit, bitmap->bitmap);
+	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+		kfree(bitmap);
+		radix_tree_iter_delete(root, &iter, slot);
+	}
+}
+EXPORT_SYMBOL(xb_clear_bit);
+
+/**
+ * xb_zero() - Clear a range of bits in the XBitmap.
+ * @xb: The XBitmap.
+ * @min: The first bit to clear.
+ * @max: The last bit to clear.
+ *
+ * This function is used to clear a range of bits in the xbitmap.
+ */
+void xb_zero(struct xb *xb, unsigned long min, unsigned long max)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = min / IDA_BITMAP_BITS;
+	unsigned long first = min % IDA_BITMAP_BITS;
+	unsigned long maxindex = max / IDA_BITMAP_BITS;
+
+	radix_tree_for_each_slot(slot, root, &iter, index) {
+		unsigned long nbits = IDA_BITMAP_BITS;
+
+		if (index > maxindex)
+			break;
+		bitmap = radix_tree_deref_slot(slot);
+		if (!bitmap)
+			continue;
+		radix_tree_iter_tag_set(root, &iter, IDR_FREE);
+
+		if (!first && iter.index < maxindex)
+			goto delete;
+		if (iter.index == maxindex)
+			nbits = max % IDA_BITMAP_BITS + 1;
+		bitmap_clear(bitmap->bitmap, first, nbits - first);
+		first = 0;
+		if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS))
+			goto delete;
+		continue;
+delete:
+		kfree(bitmap);
+		radix_tree_iter_delete(root, &iter, slot);
+	}
+}
+EXPORT_SYMBOL(xb_zero);
+
+/**
+ * xb_test_bit() - Test a bit in the xbitmap.
+ * @xb: The XBitmap.
+ * @bit: Index of the bit to test.
+ *
+ * This function is used to test a bit in the xbitmap.
+ *
+ * Return: %true if the bit is set.
+ */
+bool xb_test_bit(const struct xb *xb, unsigned long bit)
+{
+	unsigned long index = bit / IDA_BITMAP_BITS;
+	struct ida_bitmap *bitmap = radix_tree_lookup(&xb->xbrt, index);
+
+	bit %= IDA_BITMAP_BITS;
+
+	if (!bitmap)
+		return false;
+	return test_bit(bit, bitmap->bitmap);
+}
+EXPORT_SYMBOL(xb_test_bit);
+
+/**
+ * xb_find_set() - Find the next set bit in a range of bits.
+ * @xb: The XBitmap.
+ * @max: The maximum position to search.
+ * @bit: The first bit to examine, and on exit, the found bit.
+ *
+ * On entry, @bit points to the index of the first bit to search.  On exit,
+ * if this function returns %true, @bit will be updated to the index of the
+ * first found bit.  It will not be updated if this function returns %false.
+ *
+ * Return: %true if a set bit was found.
+ */
+bool xb_find_set(const struct xb *xb, unsigned long max, unsigned long *bit)
+{
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = *bit / IDA_BITMAP_BITS;
+	unsigned int first = *bit % IDA_BITMAP_BITS;
+	unsigned long maxindex = max / IDA_BITMAP_BITS;
+
+	radix_tree_for_each_slot(slot, &xb->xbrt, &iter, index) {
+		if (iter.index > maxindex)
+			break;
+		bitmap = radix_tree_deref_slot(slot);
+		if (bitmap) {
+			unsigned int nbits = IDA_BITMAP_BITS;
+
+			if (iter.index == maxindex)
+				nbits = max % IDA_BITMAP_BITS + 1;
+			first = find_next_bit(bitmap->bitmap, nbits, first);
+			if (first != nbits) {
+				*bit = first + iter.index * IDA_BITMAP_BITS;
+				return true;
+			}
+		}
+		first = 0;
+	}
+
+	return false;
+}
+EXPORT_SYMBOL(xb_find_set);
+
+/**
+ * xb_find_zero() - Find the next zero bit in a range of bits
+ * @xb: The XBitmap.
+ * @max: The maximum index to search.
+ * @bit: Pointer to an index.
+ *
+ * On entry, @bit points to the index of the first bit to search.  On exit,
+ * if this function returns %true, @bit will be updated to the index of the
+ * first found bit.  It will not be updated if this function returns %false.
+ *
+ * Return: %true if a clear bit was found.
+ */
+bool xb_find_zero(const struct xb *xb, unsigned long max, unsigned long *bit)
+{
+	void __rcu **slot;
+	struct radix_tree_iter iter;
+	struct ida_bitmap *bitmap;
+	unsigned long index = *bit / IDA_BITMAP_BITS;
+	unsigned long first = *bit % IDA_BITMAP_BITS;
+	unsigned long maxindex = max / IDA_BITMAP_BITS;
+
+	radix_tree_for_each_tagged(slot, &xb->xbrt, &iter, index, IDR_FREE) {
+		unsigned int nbits = IDA_BITMAP_BITS;
+
+		if (iter.index > maxindex)
+			return false;
+		bitmap = radix_tree_deref_slot(slot);
+		if (!bitmap)
+			break;
+		if (iter.index == maxindex)
+			nbits = max % IDA_BITMAP_BITS + 1;
+		first = find_next_zero_bit(bitmap->bitmap, nbits, first);
+		if (first != nbits)
+			break;
+		first = 0;
+	}
+
+	*bit = first + iter.index * IDA_BITMAP_BITS;
+	return true;
+}
+EXPORT_SYMBOL(xb_find_zero);
+
+#ifndef __KERNEL__
+
+static DEFINE_XB(xb1);
+
+static void xbitmap_check_bit(unsigned long bit)
+{
+	unsigned long nbit = 0;
+
+	xb_preload(GFP_KERNEL);
+	assert(!xb_test_bit(&xb1, bit));
+	assert(xb_set_bit(&xb1, bit) == 0);
+	assert(xb_test_bit(&xb1, bit));
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == bit);
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == bit);
+	nbit++;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == bit + 1);
+	xb_clear_bit(&xb1, bit);
+	assert(xb_empty(&xb1));
+	xb_clear_bit(&xb1, bit);
+	assert(xb_empty(&xb1));
+	nbit = 0;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == 0);
+	xb_preload_end();
+}
+
+/*
+ * In the following tests, preload is called once when all the bits to set
+ * locate in the same ida bitmap. Otherwise, it is recommended to call
+ * preload for each xb_set_bit.
+ */
+static void xbitmap_check_bit_range(void)
+{
+	unsigned long nbit = 0;
+
+	/* Regular test1: node = NULL */
+	xb_preload(GFP_KERNEL);
+	xb_set_bit(&xb1, 700);
+	xb_preload_end();
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == 700);
+	nbit++;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == 701);
+	xb_zero(&xb1, 0, 1023);
+
+	/*
+	 * Regular test2
+	 * set bit 2000, 2001, 2040
+	 * Next 1 in [0, 2048]		--> 2000
+	 * Next 1 in [2000, 2002]	--> 2000
+	 * Next 1 in [2002, 2040]	--> 2040
+	 * Next 1 in [2002, 2039]	--> none
+	 * Next 0 in [2000, 2048]	--> 2002
+	 * Next 0 in [2048, 2060]	--> 2048
+	 */
+	xb_preload(GFP_KERNEL);
+	assert(!xb_set_bit(&xb1, 2000));
+	assert(!xb_set_bit(&xb1, 2001));
+	assert(!xb_set_bit(&xb1, 2040));
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2048, &nbit) == true);
+	assert(nbit == 2000);
+	assert(xb_find_set(&xb1, 2002, &nbit) == true);
+	assert(nbit == 2000);
+	nbit = 2002;
+	assert(xb_find_set(&xb1, 2040, &nbit) == true);
+	assert(nbit == 2040);
+	nbit = 2002;
+	assert(xb_find_set(&xb1, 2039, &nbit) == false);
+	assert(nbit == 2002);
+	nbit = 2000;
+	assert(xb_find_zero(&xb1, 2048, &nbit) == true);
+	assert(nbit == 2002);
+	nbit = 2048;
+	assert(xb_find_zero(&xb1, 2060, &nbit) == true);
+	assert(nbit == 2048);
+	xb_zero(&xb1, 0, 2048);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2048, &nbit) == false);
+	assert(nbit == 0);
+	xb_preload_end();
+
+	/*
+	 * Overflow tests:
+	 * Set bit 1 and ULONG_MAX - 4
+	 * Next 1 in [0, ULONG_MAX]			--> 1
+	 * Next 1 in [1, ULONG_MAX]			--> 1
+	 * Next 1 in [2, ULONG_MAX]			--> ULONG_MAX - 4
+	 * Next 1 in [ULONG_MAX - 3, 2]			--> none
+	 * Next 0 in [ULONG_MAX - 4, ULONG_MAX]		--> ULONG_MAX - 3
+	 * Zero [ULONG_MAX - 4, ULONG_MAX]
+	 * Next 1 in [ULONG_MAX - 10, ULONG_MAX]	--> none
+	 * Next 1 in [ULONG_MAX - 1, 2]			--> none
+	 * Zero [0, 1]
+	 * Next 1 in [0, 2]				--> none
+	 */
+	xb_preload(GFP_KERNEL);
+	assert(!xb_set_bit(&xb1, 1));
+	xb_preload_end();
+	xb_preload(GFP_KERNEL);
+	assert(!xb_set_bit(&xb1, ULONG_MAX - 4));
+	nbit = 0;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == 1);
+	nbit = 1;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == 1);
+	nbit = 2;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == ULONG_MAX - 4);
+	nbit++;
+	assert(xb_find_set(&xb1, 2, &nbit) == false);
+	assert(nbit == ULONG_MAX - 3);
+	nbit--;
+	assert(xb_find_zero(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == ULONG_MAX - 3);
+	xb_zero(&xb1, ULONG_MAX - 4, ULONG_MAX);
+	nbit = ULONG_MAX - 10;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == ULONG_MAX - 10);
+	nbit = ULONG_MAX - 1;
+	assert(xb_find_set(&xb1, 2, &nbit) == false);
+	xb_zero(&xb1, 0, 1);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2, &nbit) == false);
+	assert(nbit == 0);
+	xb_preload_end();
+	assert(xb_empty(&xb1));
+}
+
+static void xbitmap_check_zero_bits(void)
+{
+	assert(xb_empty(&xb1));
+
+	/* Zero an empty xbitmap should work though no real work to do */
+	xb_zero(&xb1, 0, ULONG_MAX);
+	assert(xb_empty(&xb1));
+
+	xb_preload(GFP_KERNEL);
+	assert(xb_set_bit(&xb1, 0) == 0);
+	xb_preload_end();
+
+	/* Overflow test */
+	xb_zero(&xb1, ULONG_MAX - 10, ULONG_MAX);
+	assert(xb_test_bit(&xb1, 0));
+
+	xb_preload(GFP_KERNEL);
+	assert(xb_set_bit(&xb1, ULONG_MAX) == 0);
+	xb_preload_end();
+
+	xb_zero(&xb1, 0, ULONG_MAX);
+	assert(xb_empty(&xb1));
+}
+
+/* Check that setting an already-full bitmap works */
+static void xbitmap_check_set(unsigned long base)
+{
+	unsigned long i;
+
+	assert(xb_empty(&xb1));
+
+	for (i = 0; i < 64 * 1024; i++) {
+		xb_preload(GFP_KERNEL);
+		assert(xb_set_bit(&xb1, base + i) == 0);
+		xb_preload_end();
+	}
+	for (i = 0; i < 64 * 1024; i++)
+		assert(xb_set_bit(&xb1, base + i) == 0);
+
+	for (i = 0; i < 64 * 1024; i++)
+		xb_clear_bit(&xb1, base + i);
+
+	assert(xb_empty(&xb1));
+}
+
+static void xbitmap_checks(void)
+{
+	xb_init(&xb1);
+	xbitmap_check_bit(0);
+	xbitmap_check_bit(30);
+	xbitmap_check_bit(31);
+	xbitmap_check_bit(62);
+	xbitmap_check_bit(63);
+	xbitmap_check_bit(64);
+	xbitmap_check_bit(700);
+	xbitmap_check_bit(1023);
+	xbitmap_check_bit(1024);
+	xbitmap_check_bit(1025);
+	xbitmap_check_bit((1UL << 63) | (1UL << 24));
+	xbitmap_check_bit((1UL << 63) | (1UL << 24) | 70);
+
+	xbitmap_check_bit_range();
+	xbitmap_check_zero_bits();
+	xbitmap_check_set(0);
+	xbitmap_check_set(1024);
+	xbitmap_check_set(1024 * 64);
+}
+
+int __weak main(void)
+{
+	radix_tree_init();
+	xbitmap_checks();
+}
+#endif
diff --git a/tools/include/linux/bitmap.h b/tools/include/linux/bitmap.h
index ca16027..8d0bc1b 100644
--- a/tools/include/linux/bitmap.h
+++ b/tools/include/linux/bitmap.h
@@ -37,6 +37,40 @@ static inline void bitmap_zero(unsigned long *dst, int nbits)
 	}
 }
 
+static inline void __bitmap_clear(unsigned long *map, unsigned int start,
+				  int len)
+{
+	unsigned long *p = map + BIT_WORD(start);
+	const unsigned int size = start + len;
+	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
+	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);
+
+	while (len - bits_to_clear >= 0) {
+		*p &= ~mask_to_clear;
+		len -= bits_to_clear;
+		bits_to_clear = BITS_PER_LONG;
+		mask_to_clear = ~0UL;
+		p++;
+	}
+	if (len) {
+		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
+		*p &= ~mask_to_clear;
+	}
+}
+
+static inline __always_inline void bitmap_clear(unsigned long *map,
+						unsigned int start,
+						unsigned int nbits)
+{
+	if (__builtin_constant_p(nbits) && nbits == 1)
+		__clear_bit(start, map);
+	else if (__builtin_constant_p(start & 7) && IS_ALIGNED(start, 8) &&
+		 __builtin_constant_p(nbits & 7) && IS_ALIGNED(nbits, 8))
+		memset((char *)map + start / 8, 0, nbits / 8);
+	else
+		__bitmap_clear(map, start, nbits);
+}
+
 static inline void bitmap_fill(unsigned long *dst, unsigned int nbits)
 {
 	unsigned int nlongs = BITS_TO_LONGS(nbits);
diff --git a/tools/include/linux/kernel.h b/tools/include/linux/kernel.h
index 0ad8844..3c992ae 100644
--- a/tools/include/linux/kernel.h
+++ b/tools/include/linux/kernel.h
@@ -13,6 +13,8 @@
 #define UINT_MAX	(~0U)
 #endif
 
+#define IS_ALIGNED(x, a)	(((x) & ((typeof(x))(a) - 1)) == 0)
+
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 
 #define PERF_ALIGN(x, a)	__PERF_ALIGN_MASK(x, (typeof(x))(a)-1)
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index fa7ee36..788e526 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,12 +1,13 @@
 # SPDX-License-Identifier: GPL-2.0
 
 CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
-LDFLAGS += -fsanitize=address
-LDLIBS+= -lpthread -lurcu
-TARGETS = main idr-test multiorder
+LDFLAGS += -fsanitize=address $(LDLIBS)
+LDLIBS := -lpthread -lurcu
+TARGETS = main idr-test multiorder xbitmap
 CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
-	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o
+	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o \
+	 xbitmap.o
 
 ifndef SHIFT
 	SHIFT=3
@@ -25,8 +26,10 @@ idr-test: idr-test.o $(CORE_OFILES)
 
 multiorder: multiorder.o $(CORE_OFILES)
 
+xbitmap: xbitmap.o $(CORE_OFILES)
+
 clean:
-	$(RM) $(TARGETS) *.o radix-tree.c idr.c generated/map-shift.h
+	$(RM) $(TARGETS) *.o radix-tree.c idr.c xbitmap.c generated/map-shift.h
 
 vpath %.c ../../lib
 
@@ -34,6 +37,7 @@ $(OFILES): Makefile *.h */*.h generated/map-shift.h \
 	../../include/linux/*.h \
 	../../include/asm/*.h \
 	../../../include/linux/radix-tree.h \
+	../../../include/linux/xbitmap.h \
 	../../../include/linux/idr.h
 
 radix-tree.c: ../../../lib/radix-tree.c
@@ -42,6 +46,9 @@ radix-tree.c: ../../../lib/radix-tree.c
 idr.c: ../../../lib/idr.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
 
+xbitmap.c: ../../../lib/xbitmap.c
+	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
+
 .PHONY: mapshift
 
 mapshift:
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index c3bc3f3..426f32f 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -17,6 +17,4 @@
 #define pr_debug printk
 #define pr_cont printk
 
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/linux/xbitmap.h b/tools/testing/radix-tree/linux/xbitmap.h
new file mode 100644
index 0000000..61de214
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xbitmap.h
@@ -0,0 +1 @@
+#include "../../../../include/linux/xbitmap.h"
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 257f3f8..d112363 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -326,6 +326,10 @@ static void single_thread_tests(bool long_run)
 	rcu_barrier();
 	printv(2, "after idr_checks: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
+	xbitmap_checks();
+	rcu_barrier();
+	printv(2, "after xbitmap_checks: %d allocated, preempt %d\n",
+			nr_allocated, preempt_count);
 	big_gang_check(long_run);
 	rcu_barrier();
 	printv(2, "after big_gang_check: %d allocated, preempt %d\n",
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index d9c031d..8175d6b 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -38,6 +38,7 @@ void benchmark(void);
 void idr_checks(void);
 void ida_checks(void);
 void ida_thread_tests(void);
+void xbitmap_checks(void);
 
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
