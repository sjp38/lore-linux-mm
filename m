Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 243B36B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:03:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k1so16432375pgq.2
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 13:03:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q63si15551627pfk.189.2017.12.21.13.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 13:03:32 -0800 (PST)
Date: Thu, 21 Dec 2017 13:03:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
Message-ID: <20171221210327.GB25009@bombadil.infradead.org>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, penguin-kernel@I-love.SAKURA.ne.jp


OK, here's a rewrite of xbitmap.

Compared to the version you sent:
 - xb_find_set() is the rewrite I sent out yesterday.
 - xb_find_clear() is a new implementation.  I use the IDR_FREE tag to find
   clear bits.  This led to me finding a bug in radix_tree_for_each_tagged().
 - xb_zero() is also a new implementation (replacing xb_clear_bit_range).
   It should also be more efficient in deep trees.
 - Did not accept your change to xb_set_bit(); I think it's important to
   leave the radix tree node in place, so we're guaranteed to make progress
   in low-memory situations.  We're expecting the caller to retry, so the
   memory should not leak.
 - Redid a lot of the kernel-doc.  Thanks for adding it!  I removed mentions
   of implementation details, leaving only information useful to those who
   are using it.

Compared to the version I put out back in February:
 - Accepted your change to xb_preload(); I think it's an improvement.
 - Rewrote xb_set_bit() to use the radix_tree_iter_ family of functions.
   Should improve performance for deep trees.
 - Rewrote xb_clear_bit() for the same reason.
 - Left out the use of radix tree exceptional entries.  Thanks for taking
   them out!  Keeps it clearer for now; if they prove useful, we can put
   them back in.
 - Removed the use of __radix_tree_delete and __radix_tree_create, so drop
   the changes to those functions.

Other miscellaneous notes
 - I left xb_fill() in the header file, even though there's no implementation
   yet.  Wouldn't be hard to add once we have a user.
 - Used SPDX tags instead of a license notice.

I think we need more test cases ... in reviewing this to send out,
I found a bug in xb_zero(), which I've only fixed because I don't have
time to write a test case for it.

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
new file mode 100644
index 000000000000..c008309a9494
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
index d11c48ec8ffd..08a8183c390b 100644
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
index c8d55565fafa..d2bd8feb7b85 100644
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
index 000000000000..d596ba247b45
--- /dev/null
+++ b/lib/xbitmap.c
@@ -0,0 +1,396 @@
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
+		bitmap_clear(bitmap->bitmap, first, nbits);
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
+	 * Regular test 2
+	 * set bit 2000, 2001, 2040
+	 * Next 1 in [0, 2048)		--> 2000
+	 * Next 1 in [2000, 2002)	--> 2000
+	 * Next 1 in [2002, 2041)	--> 2040
+	 * Next 1 in [2002, 2040)	--> none
+	 * Next 0 in [2000, 2048)	--> 2002
+	 * Next 0 in [2048, 2060)	--> 2048
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
+	assert(xb_find_set(&xb1, 2041, &nbit) == true);
+	assert(nbit == 2040);
+	nbit = 2002;
+	assert(xb_find_set(&xb1, 2040, &nbit) == true);
+	assert(nbit == 2040);
+	nbit = 2000;
+	assert(xb_find_zero(&xb1, 2048, &nbit) == true);
+	assert(nbit == 2002);
+	nbit = 2048;
+	assert(xb_find_zero(&xb1, 2060, &nbit) == true);
+	assert(nbit == 2048);
+	xb_zero(&xb1, 0, 2047);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2048, &nbit) == false);
+	assert(nbit == 0);
+	xb_preload_end();
+
+	/*
+	 * Overflow tests:
+	 * Set bit 1 and ULONG_MAX - 4
+	 * Next 1 in [ULONG_MAX - 4, ULONG_MAX)		--> ULONG_MAX - 4
+	 * Next 1 [ULONG_MAX - 3, ULONG_MAX + 4)	--> none
+	 * Next 0 [ULONG_MAX - 4, ULONG_MAX + 4)	--> none
+	 */
+	xb_preload(GFP_KERNEL);
+	assert(!xb_set_bit(&xb1, 1));
+	xb_preload_end();
+	xb_preload(GFP_KERNEL);
+	assert(!xb_set_bit(&xb1, ULONG_MAX - 4));
+	nbit = ULONG_MAX - 4;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == ULONG_MAX - 4);
+	nbit++;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == ULONG_MAX - 3);
+	nbit--;
+	assert(xb_find_zero(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == ULONG_MAX - 3);
+	xb_zero(&xb1, ULONG_MAX - 4, ULONG_MAX);
+	nbit = ULONG_MAX - 10;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == ULONG_MAX - 10);
+	xb_zero(&xb1, 0, 1);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2, &nbit) == false);
+	assert(nbit == 0);
+	xb_preload_end();
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
+
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
index ca160270fdfa..6b559ee25def 100644
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
+	else if (__builtin_constant_p(start) && IS_ALIGNED(start, 8) &&
+		 __builtin_constant_p(nbits) && IS_ALIGNED(nbits, 8))
+		memset((char *)map + start / 8, 0, nbits / 8);
+	else
+		__bitmap_clear(map, start, nbits);
+}
+
 static inline void bitmap_fill(unsigned long *dst, unsigned int nbits)
 {
 	unsigned int nlongs = BITS_TO_LONGS(nbits);
diff --git a/tools/include/linux/kernel.h b/tools/include/linux/kernel.h
index 0ad884452c5c..3c992ae15440 100644
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
index fa7ee369b3c9..adf36e34dd77 100644
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
@@ -25,8 +26,11 @@ idr-test: idr-test.o $(CORE_OFILES)
 
 multiorder: multiorder.o $(CORE_OFILES)
 
+xbitmap: xbitmap.o $(CORE_OFILES)
+	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o xbitmap
+
 clean:
-	$(RM) $(TARGETS) *.o radix-tree.c idr.c generated/map-shift.h
+	$(RM) $(TARGETS) *.o radix-tree.c idr.c xbitmap.c generated/map-shift.h
 
 vpath %.c ../../lib
 
@@ -34,6 +38,7 @@ $(OFILES): Makefile *.h */*.h generated/map-shift.h \
 	../../include/linux/*.h \
 	../../include/asm/*.h \
 	../../../include/linux/radix-tree.h \
+	../../../include/linux/xbitmap.h \
 	../../../include/linux/idr.h
 
 radix-tree.c: ../../../lib/radix-tree.c
@@ -42,6 +47,9 @@ radix-tree.c: ../../../lib/radix-tree.c
 idr.c: ../../../lib/idr.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
 
+xbitmap.c: ../../../lib/xbitmap.c
+	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
+
 .PHONY: mapshift
 
 mapshift:
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index c3bc3f364f68..426f32f28547 100644
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
index 000000000000..61de214542e7
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xbitmap.h
@@ -0,0 +1 @@
+#include "../../../../include/linux/xbitmap.h"
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 257f3f8aacaa..d112363262ae 100644
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
index d9c031dbeb1a..8175d6b23b32 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
