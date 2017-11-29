Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E670A6B0268
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:25 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 61so1294556plz.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:25 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:24 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 03/10] xbitmap: Introduce xbitmap
Date: Wed, 29 Nov 2017 21:55:19 +0800
Message-Id: <1511963726-34070-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

From: Matthew Wilcox <mawilcox@microsoft.com>

The eXtensible Bitmap is a sparse bitmap representation which is
efficient for set bits which tend to cluster.  It supports up to
'unsigned long' worth of bits, and this commit adds the bare bones --
xb_set_bit(), xb_clear_bit() and xb_test_bit().

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 include/linux/radix-tree.h               |   2 +
 include/linux/xbitmap.h                  |  52 +++++++++
 lib/Makefile                             |   2 +-
 lib/radix-tree.c                         |  26 ++++-
 lib/xbitmap.c                            | 179 +++++++++++++++++++++++++++++++
 tools/testing/radix-tree/Makefile        |  12 ++-
 tools/testing/radix-tree/linux/xbitmap.h |   1 +
 tools/testing/radix-tree/main.c          |   4 +
 tools/testing/radix-tree/test.h          |   1 +
 9 files changed, 275 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/xbitmap.h
 create mode 100644 lib/xbitmap.c
 create mode 100644 tools/testing/radix-tree/linux/xbitmap.h

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 23a9c89..fe44f4b 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -315,6 +315,8 @@ void radix_tree_iter_delete(struct radix_tree_root *,
 			struct radix_tree_iter *iter, void __rcu **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
+bool __radix_tree_delete(struct radix_tree_root *r, struct radix_tree_node *n,
+				void **slot);
 void radix_tree_clear_tags(struct radix_tree_root *, struct radix_tree_node *,
 			   void __rcu **slot);
 unsigned int radix_tree_gang_lookup(const struct radix_tree_root *,
diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
new file mode 100644
index 0000000..ed75d87
--- /dev/null
+++ b/include/linux/xbitmap.h
@@ -0,0 +1,52 @@
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
+int xb_clear_bit(struct xb *xb, unsigned long bit);
+
+int xb_zero(struct xb *xb, unsigned long start, unsigned long nbits);
+int xb_fill(struct xb *xb, unsigned long start, unsigned long nbits);
+
+static inline bool xb_empty(const struct xb *xb)
+{
+	return radix_tree_empty(&xb->xbrt);
+}
+
+void xb_preload(gfp_t);
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
index c8d5556..7000ad6 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -78,6 +78,14 @@ static struct kmem_cache *radix_tree_node_cachep;
 #define IDA_PRELOAD_SIZE	(IDA_MAX_PATH * 2 - 1)
 
 /*
+ * The XB can go up to unsigned long, but also uses a bitmap.
+ */
+#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
+#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
+						RADIX_TREE_MAP_SHIFT))
+#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
+
+/*
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
@@ -839,6 +847,8 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 							offset, 0, 0);
 			if (!child)
 				return -ENOMEM;
+			if (is_idr(root))
+				all_tag_set(child, IDR_FREE);
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -1982,7 +1992,7 @@ void __radix_tree_delete_node(struct radix_tree_root *root,
 	delete_node(root, node, update_node);
 }
 
-static bool __radix_tree_delete(struct radix_tree_root *root,
+bool __radix_tree_delete(struct radix_tree_root *root,
 				struct radix_tree_node *node, void __rcu **slot)
 {
 	void *old = rcu_dereference_raw(*slot);
@@ -2135,6 +2145,20 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
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
+
 void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
 			      struct radix_tree_iter *iter, gfp_t gfp,
 			      unsigned long max)
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
new file mode 100644
index 0000000..2b547a73
--- /dev/null
+++ b/lib/xbitmap.c
@@ -0,0 +1,179 @@
+#include <linux/export.h>
+#include <linux/xbitmap.h>
+#include <linux/bitmap.h>
+#include <linux/slab.h>
+
+/**
+ *  xb_set_bit - set a bit in the xbitmap
+ *  @xb: the xbitmap tree used to record the bit
+ *  @bit: index of the bit to set
+ *
+ * This function is used to set a bit in the xbitmap. If the bitmap that @bit
+ * resides in is not there, the per-cpu ida_bitmap will be taken.
+ *
+ * Returns: 0 on success. %-EAGAIN indicates that @bit was not set.
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
+			__radix_tree_replace(root, node, slot, bitmap, NULL);
+			return 0;
+		}
+		bitmap = this_cpu_xchg(ida_bitmap, NULL);
+		if (!bitmap)
+			return -EAGAIN;
+		memset(bitmap, 0, sizeof(*bitmap));
+		__radix_tree_replace(root, node, slot, bitmap, NULL);
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
+int xb_clear_bit(struct xb *xb, unsigned long bit)
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
+			return 0;
+		tmp &= ~(1UL << ebit);
+		if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
+			__radix_tree_delete(root, node, slot);
+		else
+			rcu_assign_pointer(*slot, (void *)tmp);
+		return 0;
+	}
+
+	if (!bitmap)
+		return 0;
+
+	__clear_bit(bit, bitmap->bitmap);
+	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+		kfree(bitmap);
+		__radix_tree_delete(root, node, slot);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(xb_clear_bit);
+
+/**
+ * xb_test_bit - test a bit in the xbitmap
+ * @xb: the xbitmap tree used to record the bit
+ * @bit: index of the bit to test
+ *
+ * This function is used to test a bit in the xbitmap.
+ *
+ * Returns: true if the bit is set, or false otherwise.
+ */
+bool xb_test_bit(const struct xb *xb, unsigned long bit)
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
+	return test_bit(bit, bitmap->bitmap);
+}
+EXPORT_SYMBOL(xb_test_bit);
+
+#ifndef __KERNEL__
+
+static DEFINE_XB(xb1);
+
+void xbitmap_check_bit(unsigned long bit)
+{
+	xb_preload(GFP_KERNEL);
+	assert(!xb_test_bit(&xb1, bit));
+	assert(xb_set_bit(&xb1, bit) == 0);
+	assert(xb_test_bit(&xb1, bit));
+	assert(xb_clear_bit(&xb1, bit) == 0);
+	assert(xb_empty(&xb1));
+	assert(xb_clear_bit(&xb1, bit) == 0);
+	assert(xb_empty(&xb1));
+	xb_preload_end();
+}
+
+void xbitmap_checks(void)
+{
+	xb_init(&xb1);
+	xbitmap_check_bit(0);
+	xbitmap_check_bit(30);
+	xbitmap_check_bit(31);
+	xbitmap_check_bit(1023);
+	xbitmap_check_bit(1024);
+	xbitmap_check_bit(1025);
+	xbitmap_check_bit((1UL << 63) | (1UL << 24));
+	xbitmap_check_bit((1UL << 63) | (1UL << 24) | 70);
+}
+
+int __weak main(void)
+{
+	radix_tree_init();
+	xbitmap_checks();
+}
+#endif
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index fa7ee36..34ece78 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -6,7 +6,8 @@ LDLIBS+= -lpthread -lurcu
 TARGETS = main idr-test multiorder
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
