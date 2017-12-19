Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 865456B0274
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:34:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g8so12572700pgs.14
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:34:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v8si9119558plg.831.2017.12.19.04.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 04:34:53 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v20 3/7] xbitmap: add more operations
Date: Tue, 19 Dec 2017 20:17:55 +0800
Message-Id: <1513685879-21823-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

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
 include/linux/xbitmap.h      |   6 ++
 lib/xbitmap.c                | 198 +++++++++++++++++++++++++++++++++++++++++++
 tools/include/linux/bitmap.h |  34 ++++++++
 tools/include/linux/kernel.h |   2 +
 4 files changed, 240 insertions(+)

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
index 108f929..ede1029 100644
--- a/include/linux/xbitmap.h
+++ b/include/linux/xbitmap.h
@@ -35,6 +35,12 @@ static inline void xb_init(struct xb *xb)
 int xb_set_bit(struct xb *xb, unsigned long bit);
 bool xb_test_bit(const struct xb *xb, unsigned long bit);
 void xb_clear_bit(struct xb *xb, unsigned long bit);
+void xb_clear_bit_range(struct xb *xb, unsigned long start,
+			unsigned long nbits);
+unsigned long xb_find_set(struct xb *xb, unsigned long size,
+			  unsigned long offset);
+unsigned long xb_find_zero(struct xb *xb, unsigned long size,
+			   unsigned long offset);
 
 static inline bool xb_empty(const struct xb *xb)
 {
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index 2dcfad5..bb0a5b2 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -3,6 +3,16 @@
 #include <linux/bitmap.h>
 #include <linux/slab.h>
 
+/*
+ * Developer notes:
+ * - locks are required to gurantee there is no concurrent
+ *   calls of xb_set_bit, xb_clear_bit, xb_clear_bit_range, xb_test_bit,
+ *   xb_find_set, or xb_find_clear to operate on the same ida bitmap.
+ * - The current implementation of xb_clear_bit_range, xb_find_set and
+ *   xb_find_clear may cause long latency when the bit range to operate
+ *   on is super large (e.g. [0, ULONG_MAX)).
+ */
+
 /**
  *  xb_set_bit - set a bit in the xbitmap
  *  @xb: the xbitmap tree used to record the bit
@@ -72,6 +82,49 @@ void xb_clear_bit(struct xb *xb, unsigned long bit)
 EXPORT_SYMBOL(xb_clear_bit);
 
 /**
+ * xb_clear_bit_range - clear a range of bits in the xbitmap
+ * @start: the start of the bit range, inclusive
+ * @nbits: number of bits to clear
+ *
+ * This function is used to clear a range of bits in the xbitmap. If all the
+ * bits in the bitmap are 0, the bitmap will be freed.
+ */
+void xb_clear_bit_range(struct xb *xb, unsigned long start,
+			unsigned long nbits)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = start / IDA_BITMAP_BITS;
+	unsigned long bit = start % IDA_BITMAP_BITS;
+
+	if (nbits > ULONG_MAX - start)
+		nbits = ULONG_MAX - start;
+
+	while (nbits) {
+		unsigned int __nbits = min(nbits,
+					(unsigned long)IDA_BITMAP_BITS - bit);
+
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (bitmap) {
+			if (__nbits != IDA_BITMAP_BITS)
+				bitmap_clear(bitmap->bitmap, bit, __nbits);
+
+			if (__nbits == IDA_BITMAP_BITS ||
+			    bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+				kfree(bitmap);
+				__radix_tree_delete(root, node, slot);
+			}
+		}
+		bit = 0;
+		index++;
+		nbits -= __nbits;
+	}
+}
+EXPORT_SYMBOL(xb_clear_bit_range);
+
+/**
  * xb_test_bit - test a bit in the xbitmap
  * @xb: the xbitmap tree used to record the bit
  * @bit: index of the bit to test
@@ -94,6 +147,99 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit)
 }
 EXPORT_SYMBOL(xb_test_bit);
 
+/**
+ * xb_find_set - find the next set bit in a range of bits
+ * @xb: the xbitmap to search from
+ * @offset: the offset in the range to start searching
+ * @size: the size of the range
+ *
+ * Returns: the found bit or, @size if no set bit is found.
+ */
+unsigned long xb_find_set(struct xb *xb, unsigned long size,
+			  unsigned long offset)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = offset / IDA_BITMAP_BITS;
+	unsigned long index_end = size / IDA_BITMAP_BITS;
+	unsigned long bit = offset % IDA_BITMAP_BITS;
+
+	if (unlikely(offset >= size))
+		return size;
+
+	while (index <= index_end) {
+		unsigned long ret;
+		unsigned int nbits = size - index * IDA_BITMAP_BITS;
+
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (!node) {
+			index = (index | RADIX_TREE_MAP_MASK) + 1;
+			continue;
+		}
+
+		if (bitmap) {
+			if (nbits > IDA_BITMAP_BITS)
+				nbits = IDA_BITMAP_BITS;
+
+			ret = find_next_bit(bitmap->bitmap, nbits, bit);
+			if (ret != nbits)
+				return ret + index * IDA_BITMAP_BITS;
+		}
+		bit = 0;
+		index++;
+	}
+
+	return size;
+}
+EXPORT_SYMBOL(xb_find_set);
+
+/**
+ * xb_find_zero - find the next zero bit in a range of bits
+ * @xb: the xbitmap to search from
+ * @offset: the offset in the range to start searching
+ * @size: the size of the range
+ *
+ * Returns: the found bit or, @size if no zero bit is found.
+ */
+unsigned long xb_find_zero(struct xb *xb, unsigned long size,
+			   unsigned long offset)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = offset / IDA_BITMAP_BITS;
+	unsigned long index_end = size / IDA_BITMAP_BITS;
+	unsigned long bit = offset % IDA_BITMAP_BITS;
+
+	if (unlikely(offset >= size))
+		return size;
+
+	while (index <= index_end) {
+		unsigned long ret;
+		unsigned int nbits = size - index * IDA_BITMAP_BITS;
+
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+		if (bitmap) {
+			if (nbits > IDA_BITMAP_BITS)
+				nbits = IDA_BITMAP_BITS;
+
+			ret = find_next_zero_bit(bitmap->bitmap, nbits, bit);
+			if (ret != nbits)
+				return ret + index * IDA_BITMAP_BITS;
+		} else {
+			return bit + index * IDA_BITMAP_BITS;
+		}
+		bit = 0;
+		index++;
+	}
+
+	return size;
+}
+EXPORT_SYMBOL(xb_find_zero);
+
 #ifndef __KERNEL__
 
 static DEFINE_XB(xb1);
@@ -111,6 +257,56 @@ void xbitmap_check_bit(unsigned long bit)
 	xb_preload_end();
 }
 
+static void xbitmap_check_bit_range(void)
+{
+	/*
+	 * Regular tests
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
+	assert(xb_find_set(&xb1, 2048, 0) == 2000);
+	assert(xb_find_set(&xb1, 2002, 2000) == 2000);
+	assert(xb_find_set(&xb1, 2041, 2002) == 2040);
+	assert(xb_find_set(&xb1, 2040, 2002) == 2040);
+	assert(xb_find_zero(&xb1, 2048, 2000) == 2002);
+	assert(xb_find_zero(&xb1, 2060, 2048) == 2048);
+	xb_clear_bit_range(&xb1, 0, 2048);
+	assert(xb_find_set(&xb1, 2048, 0) == 2048);
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
+	assert(xb_find_set(&xb1, ULONG_MAX, ULONG_MAX - 4) == ULONG_MAX - 4);
+	assert(xb_find_set(&xb1, ULONG_MAX + 4, ULONG_MAX - 3) ==
+	       ULONG_MAX + 4);
+	assert(xb_find_zero(&xb1, ULONG_MAX + 4, ULONG_MAX - 4) ==
+	       ULONG_MAX + 4);
+	xb_clear_bit_range(&xb1, ULONG_MAX - 4, 4);
+	assert(xb_find_set(&xb1, ULONG_MAX, ULONG_MAX - 10) == ULONG_MAX);
+	xb_clear_bit_range(&xb1, 0, 2);
+	assert(xb_find_set(&xb1, 2, 0) == 2);
+	xb_preload_end();
+}
+
 void xbitmap_checks(void)
 {
 	xb_init(&xb1);
@@ -122,6 +318,8 @@ void xbitmap_checks(void)
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
