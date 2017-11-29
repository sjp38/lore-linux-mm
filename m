Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFF6D6B026B
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:32 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 33so1290400pll.9
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:31 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 05/10] xbitmap: add more operations
Date: Wed, 29 Nov 2017 21:55:21 +0800
Message-Id: <1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

This patch adds support to find next 1 or 0 bit in a xbmitmap range and
clear a range of bits.

More possible optimizations to add in the future:
1) xb_set_bit_range: set a range of bits.
2) when searching a bit, if the bit is not found in the slot, move on to
the next slot directly.
3) add tags to help searching.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Suggested-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xbitmap.h      |   8 +-
 lib/xbitmap.c                | 180 +++++++++++++++++++++++++++++++++++++++++++
 tools/include/linux/bitmap.h |  34 ++++++++
 tools/include/linux/kernel.h |   2 +
 4 files changed, 223 insertions(+), 1 deletion(-)

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
index b4d8375..eddf0d5e 100644
--- a/include/linux/xbitmap.h
+++ b/include/linux/xbitmap.h
@@ -33,8 +33,14 @@ static inline void xb_init(struct xb *xb)
 }
 
 int xb_set_bit(struct xb *xb, unsigned long bit);
+int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp);
 bool xb_test_bit(const struct xb *xb, unsigned long bit);
-int xb_clear_bit(struct xb *xb, unsigned long bit);
+void xb_clear_bit(struct xb *xb, unsigned long bit);
+unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
+				   unsigned long end);
+unsigned long xb_find_next_zero_bit(struct xb *xb, unsigned long start,
+				    unsigned long end);
+void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end);
 
 static inline bool xb_empty(const struct xb *xb)
 {
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index 182aa29..816dd3e 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -3,6 +3,13 @@
 #include <linux/bitmap.h>
 #include <linux/slab.h>
 
+/*
+ * Developer notes: locks are required to gurantee there is no concurrent
+ * calls of xb_set_bit, xb_clear_bit, xb_clear_bit_range, xb_test_bit,
+ * xb_find_next_set_bit, or xb_find_next_clear_bit to operate on the same
+ * ida bitamp.
+ */
+
 /**
  *  xb_set_bit - set a bit in the xbitmap
  *  @xb: the xbitmap tree used to record the bit
@@ -70,6 +77,28 @@ int xb_set_bit(struct xb *xb, unsigned long bit)
 EXPORT_SYMBOL(xb_set_bit);
 
 /**
+ *  xb_preload_and_set_bit - preload the memory and set a bit in the xbitmap
+ *  @xb: the xbitmap tree used to record the bit
+ *  @bit: index of the bit to set
+ *
+ * A wrapper of the xb_preload() and xb_set_bit().
+ * Returns: 0 on success; -EAGAIN or -ENOMEM on error.
+ */
+int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp)
+{
+	int ret = 0;
+
+	if (!xb_preload(gfp))
+		return -ENOMEM;
+
+	ret = xb_set_bit(xb, bit);
+	xb_preload_end();
+
+	return ret;
+}
+EXPORT_SYMBOL(xb_preload_and_set_bit);
+
+/**
  * xb_clear_bit - clear a bit in the xbitmap
  * @xb: the xbitmap tree used to record the bit
  * @bit: index of the bit to clear
@@ -115,6 +144,56 @@ void xb_clear_bit(struct xb *xb, unsigned long bit)
 EXPORT_SYMBOL(xb_clear_bit);
 
 /**
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
+			    bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+				kfree(bitmap);
+				__radix_tree_delete(root, node, slot);
+			}
+		}
+	}
+}
+EXPORT_SYMBOL(xb_clear_bit_range);
+
+/**
  * xb_test_bit - test a bit in the xbitmap
  * @xb: the xbitmap tree used to record the bit
  * @bit: index of the bit to test
@@ -143,6 +222,80 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit)
 }
 EXPORT_SYMBOL(xb_test_bit);
 
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
+
 #ifndef __KERNEL__
 
 static DEFINE_XB(xb1);
@@ -160,6 +313,31 @@ void xbitmap_check_bit(unsigned long bit)
 	xb_preload_end();
 }
 
+static void xbitmap_check_bit_range(void)
+{
+	/* Set a range of bits */
+	assert(!xb_preload_and_set_bit(&xb1, 1060, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 1061, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 1064, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 1065, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 8180, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 8181, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 8190, GFP_KERNEL));
+	assert(!xb_preload_and_set_bit(&xb1, 8191, GFP_KERNEL));
+
+	/* Test a range of bits */
+	assert(xb_find_next_set_bit(&xb1, 0, 10000) == 1060);
+	assert(xb_find_next_zero_bit(&xb1, 1061, 10000) == 1062);
+	assert(xb_find_next_set_bit(&xb1, 1062, 10000) == 1064);
+	assert(xb_find_next_zero_bit(&xb1, 1065, 10000) == 1066);
+	assert(xb_find_next_set_bit(&xb1, 1066, 10000) == 8180);
+	assert(xb_find_next_zero_bit(&xb1, 8180, 10000) == 8182);
+	xb_clear_bit_range(&xb1, 0, 20000);
+	assert(xb_find_next_set_bit(&xb1, 0, 10000) == 10001);
+
+	assert(xb_find_next_zero_bit(&xb1, 20000, 30000) == 20000);
+}
+
 void xbitmap_checks(void)
 {
 	xb_init(&xb1);
@@ -171,6 +349,8 @@ void xbitmap_checks(void)
 	xbitmap_check_bit(1025);
 	xbitmap_check_bit((1UL << 63) | (1UL << 24));
 	xbitmap_check_bit((1UL << 63) | (1UL << 24) | 70);
+
+	xbitmap_check_bit_range();
 }
 
 int __weak main(void)
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
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
