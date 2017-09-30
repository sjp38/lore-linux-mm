Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 824856B025F
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:19:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so2568736pgb.3
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 21:19:28 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o7si4216505pgs.795.2017.09.29.21.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 21:19:27 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v16 2/5] radix tree test suite: add tests for xbitmap
Date: Sat, 30 Sep 2017 12:05:51 +0800
Message-Id: <1506744354-20979-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

From: Matthew Wilcox <mawilcox@microsoft.com>

Add the following tests for xbitmap:
1) single bit test: single bit set/clear/find;
2) bit range test: set/clear a range of bits and find a 0 or 1 bit in
the range.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 tools/include/linux/bitmap.h            |  34 ++++
 tools/include/linux/kernel.h            |   2 +
 tools/testing/radix-tree/Makefile       |   7 +-
 tools/testing/radix-tree/linux/kernel.h |   2 -
 tools/testing/radix-tree/main.c         |   5 +
 tools/testing/radix-tree/test.h         |   1 +
 tools/testing/radix-tree/xbitmap.c      | 269 ++++++++++++++++++++++++++++++++
 7 files changed, 317 insertions(+), 3 deletions(-)
 create mode 100644 tools/testing/radix-tree/xbitmap.c

diff --git a/tools/include/linux/bitmap.h b/tools/include/linux/bitmap.h
index e8b9f51..890dab2 100644
--- a/tools/include/linux/bitmap.h
+++ b/tools/include/linux/bitmap.h
@@ -36,6 +36,40 @@ static inline void bitmap_zero(unsigned long *dst, int nbits)
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
index 77d2e94..21e90ee 100644
--- a/tools/include/linux/kernel.h
+++ b/tools/include/linux/kernel.h
@@ -12,6 +12,8 @@
 #define UINT_MAX	(~0U)
 #endif
 
+#define IS_ALIGNED(x, a)	(((x) & ((typeof(x))(a) - 1)) == 0)
+
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 
 #define PERF_ALIGN(x, a)	__PERF_ALIGN_MASK(x, (typeof(x))(a)-1)
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 6a9480c..fc7cb422 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -5,7 +5,8 @@ LDLIBS+= -lpthread -lurcu
 TARGETS = main idr-test multiorder
 CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
-	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o
+	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o \
+	 xbitmap.o
 
 ifndef SHIFT
 	SHIFT=3
@@ -24,6 +25,9 @@ idr-test: idr-test.o $(CORE_OFILES)
 
 multiorder: multiorder.o $(CORE_OFILES)
 
+xbitmap: xbitmap.o $(CORE_OFILES)
+	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o xbitmap
+
 clean:
 	$(RM) $(TARGETS) *.o radix-tree.c idr.c generated/map-shift.h
 
@@ -33,6 +37,7 @@ $(OFILES): Makefile *.h */*.h generated/map-shift.h \
 	../../include/linux/*.h \
 	../../include/asm/*.h \
 	../../../include/linux/radix-tree.h \
+	../../../include/linux/xbitmap.h \
 	../../../include/linux/idr.h
 
 radix-tree.c: ../../../lib/radix-tree.c
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index b21a77f..c1e6088 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -16,6 +16,4 @@
 #define pr_debug printk
 #define pr_cont printk
 
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index bc9a784..6f4774e 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -337,6 +337,11 @@ static void single_thread_tests(bool long_run)
 	rcu_barrier();
 	printv(2, "after copy_tag_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
+
+	xbitmap_checks();
+	rcu_barrier();
+	printv(2, "after xbitmap_checks: %d allocated, preempt %d\n",
+			nr_allocated, preempt_count);
 }
 
 int main(int argc, char **argv)
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 0f8220c..f8dcdaa 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -36,6 +36,7 @@ void iteration_test(unsigned order, unsigned duration);
 void benchmark(void);
 void idr_checks(void);
 void ida_checks(void);
+void xbitmap_checks(void);
 void ida_thread_tests(void);
 
 struct item *
diff --git a/tools/testing/radix-tree/xbitmap.c b/tools/testing/radix-tree/xbitmap.c
new file mode 100644
index 0000000..2787cb2
--- /dev/null
+++ b/tools/testing/radix-tree/xbitmap.c
@@ -0,0 +1,269 @@
+#include <linux/bitmap.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include "../../../include/linux/xbitmap.h"
+
+static DEFINE_XB(xb1);
+
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
+
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
+
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
+
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
+unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
+				   unsigned long end)
+{
+	return xb_find_next_bit(xb, start, end, 1);
+}
+
+unsigned long xb_find_next_zero_bit(struct xb *xb, unsigned long start,
+				    unsigned long end)
+{
+	return xb_find_next_bit(xb, start, end, 0);
+}
+
+static void xbitmap_check_bit(unsigned long bit)
+{
+	xb_preload(GFP_KERNEL);
+
+	assert(!xb_test_bit(&xb1, bit));
+	assert(!xb_set_bit(&xb1, bit));
+	assert(xb_test_bit(&xb1, bit));
+	xb_clear_bit(&xb1, bit);
+	assert(xb_is_empty(&xb1));
+
+	xb_preload_end();
+}
+
+static void xbitmap_check_bit_range(void)
+{
+	xb_preload(GFP_KERNEL);
+
+	/* Set a range of bits */
+	assert(!xb_set_bit(&xb1, 1060));
+	assert(!xb_set_bit(&xb1, 1061));
+	assert(!xb_set_bit(&xb1, 1064));
+	assert(!xb_set_bit(&xb1, 1065));
+	assert(!xb_set_bit(&xb1, 8180));
+	assert(!xb_set_bit(&xb1, 8181));
+	assert(!xb_set_bit(&xb1, 8190));
+	assert(!xb_set_bit(&xb1, 8191));
+
+	/* Test a range of bits */
+	assert(xb_find_next_set_bit(&xb1, 0, 10000) == 1060);
+	assert(xb_find_next_zero_bit(&xb1, 1061, 10000) == 1062);
+	assert(xb_find_next_set_bit(&xb1, 1062, 10000) == 1064);
+	assert(xb_find_next_zero_bit(&xb1, 1065, 10000) == 1066);
+	assert(xb_find_next_set_bit(&xb1, 1066, 10000) == 8180);
+	assert(xb_find_next_zero_bit(&xb1, 8180, 10000) == 8182);
+	xb_clear_bit_range(&xb1, 0, 1000000);
+	assert(xb_find_next_set_bit(&xb1, 0, 10000) == 10001);
+
+	assert(xb_find_next_zero_bit(&xb1, 20000, 30000) == 20000);
+
+	xb_preload_end();
+}
+
+void xbitmap_checks(void)
+{
+	xb_init(&xb1);
+
+	xbitmap_check_bit(0);
+	xbitmap_check_bit(30);
+	xbitmap_check_bit(31);
+	xbitmap_check_bit(1023);
+	xbitmap_check_bit(1024);
+	xbitmap_check_bit(1025);
+	xbitmap_check_bit((1UL << 63) | (1UL << 24));
+	xbitmap_check_bit((1UL << 63) | (1UL << 24) | 70);
+
+	xbitmap_check_bit_range();
+}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
