Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F20F6B0253
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 07:12:48 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id k1so15671243pgq.2
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 04:12:48 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y188si11340031pgb.829.2017.12.12.04.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 04:12:46 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v19 2/7] xbitmap: potential improvement
Date: Tue, 12 Dec 2017 19:55:54 +0800
Message-Id: <1513079759-14169-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

This patch made some changes to the original xbitmap implementation from
the linux-dax tree:

- remove xb_fill() and xb_zero() from xbitmap.h since they are not
  implemented;

- xb_test_bit: changed "ebit > BITS_PER_LONG" to "ebit >= BITS_PER_LONG",
  because bit 64 beyonds the "unsigned long" exceptional entry (0 to 63);

- xb_set_bit: delete the new inserted radix_tree_node when failing to
  get the per cpu ida bitmap, this avoids the kind of memory leak of the
  unused radix tree node left in the tree.

- xb_clear_bit: change it to be a void function, since the original
  implementation reurns nothing than a 0.

- remove the comment above "#define XB_INDEX_BITS", because it causes
  confusion based on the feedbacks from the previous discussion;

- xb_preload: with the original implementation, the CPU that successfully
  do __radix_tree_preload() may get into sleep by kmalloc(), which has a
  risk of getting the caller of xb_preload() scheduled to another CPU
  after waken up, and the new CPU may not have radix_tree_node
  pre-allocated there, this will be a problem when inserting a node to
  the tree later. This patch moves __radix_tree_preload() after kmalloc()
  and returns a boolean to indicate the success or failure. Also, add the
  __must_check annotation to xb_preload for prudence purpose.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/xbitmap.h |  5 +----
 lib/radix-tree.c        | 27 +++++++++++++++++++++------
 lib/xbitmap.c           | 24 +++++++++++++-----------
 3 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
index ed75d87..b4d8375 100644
--- a/include/linux/xbitmap.h
+++ b/include/linux/xbitmap.h
@@ -36,15 +36,12 @@ int xb_set_bit(struct xb *xb, unsigned long bit);
 bool xb_test_bit(const struct xb *xb, unsigned long bit);
 int xb_clear_bit(struct xb *xb, unsigned long bit);
 
-int xb_zero(struct xb *xb, unsigned long start, unsigned long nbits);
-int xb_fill(struct xb *xb, unsigned long start, unsigned long nbits);
-
 static inline bool xb_empty(const struct xb *xb)
 {
 	return radix_tree_empty(&xb->xbrt);
 }
 
-void xb_preload(gfp_t);
+bool xb_preload(gfp_t);
 
 static inline void xb_preload_end(void)
 {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7000ad6..a039588 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -77,9 +77,6 @@ static struct kmem_cache *radix_tree_node_cachep;
 						RADIX_TREE_MAP_SHIFT))
 #define IDA_PRELOAD_SIZE	(IDA_MAX_PATH * 2 - 1)
 
-/*
- * The XB can go up to unsigned long, but also uses a bitmap.
- */
 #define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
 #define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
 						RADIX_TREE_MAP_SHIFT))
@@ -2145,17 +2142,35 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
-void xb_preload(gfp_t gfp)
+/**
+ *  xb_preload - preload for xb_set_bit()
+ *  @gfp_mask: allocation mask to use for preloading
+ *
+ * Preallocate memory to use for the next call to xb_set_bit(). On success,
+ * return true, with preemption disabled. On error, return false with
+ * preemption not disabled.
+ */
+__must_check bool xb_preload(gfp_t gfp)
 {
-	__radix_tree_preload(gfp, XB_PRELOAD_SIZE);
 	if (!this_cpu_read(ida_bitmap)) {
 		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
 
 		if (!bitmap)
-			return;
+			return false;
+		/*
+		 * The per-CPU variable is updated with preemption enabled.
+		 * If the calling task is unlucky to be scheduled to another
+		 * CPU which has no ida_bitmap allocation, it will be detected
+		 * when setting a bit (i.e. __xb_set_bit()).
+		 */
 		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
 		kfree(bitmap);
 	}
+
+	if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
+		return false;
+
+	return true;
 }
 EXPORT_SYMBOL(xb_preload);
 
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index 2b547a73..182aa29 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -39,8 +39,10 @@ int xb_set_bit(struct xb *xb, unsigned long bit)
 			return 0;
 		}
 		bitmap = this_cpu_xchg(ida_bitmap, NULL);
-		if (!bitmap)
+		if (!bitmap) {
+			__radix_tree_delete(root, node, slot);
 			return -EAGAIN;
+		}
 		memset(bitmap, 0, sizeof(*bitmap));
 		bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
 		rcu_assign_pointer(*slot, bitmap);
@@ -54,8 +56,10 @@ int xb_set_bit(struct xb *xb, unsigned long bit)
 			return 0;
 		}
 		bitmap = this_cpu_xchg(ida_bitmap, NULL);
-		if (!bitmap)
+		if (!bitmap) {
+			__radix_tree_delete(root, node, slot);
 			return -EAGAIN;
+		}
 		memset(bitmap, 0, sizeof(*bitmap));
 		__radix_tree_replace(root, node, slot, bitmap, NULL);
 	}
@@ -73,7 +77,7 @@ EXPORT_SYMBOL(xb_set_bit);
  * This function is used to clear a bit in the xbitmap. If all the bits of the
  * bitmap are 0, the bitmap will be freed.
  */
-int xb_clear_bit(struct xb *xb, unsigned long bit)
+void xb_clear_bit(struct xb *xb, unsigned long bit)
 {
 	unsigned long index = bit / IDA_BITMAP_BITS;
 	struct radix_tree_root *root = &xb->xbrt;
@@ -90,25 +94,23 @@ int xb_clear_bit(struct xb *xb, unsigned long bit)
 		unsigned long tmp = (unsigned long)bitmap;
 
 		if (ebit >= BITS_PER_LONG)
-			return 0;
+			return;
 		tmp &= ~(1UL << ebit);
 		if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
 			__radix_tree_delete(root, node, slot);
 		else
 			rcu_assign_pointer(*slot, (void *)tmp);
-		return 0;
+		return;
 	}
 
 	if (!bitmap)
-		return 0;
+		return;
 
 	__clear_bit(bit, bitmap->bitmap);
 	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
 		kfree(bitmap);
 		__radix_tree_delete(root, node, slot);
 	}
-
-	return 0;
 }
 EXPORT_SYMBOL(xb_clear_bit);
 
@@ -133,7 +135,7 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit)
 		return false;
 	if (radix_tree_exception(bitmap)) {
 		bit += RADIX_TREE_EXCEPTIONAL_SHIFT;
-		if (bit > BITS_PER_LONG)
+		if (bit >= BITS_PER_LONG)
 			return false;
 		return (unsigned long)bitmap & (1UL << bit);
 	}
@@ -151,9 +153,9 @@ void xbitmap_check_bit(unsigned long bit)
 	assert(!xb_test_bit(&xb1, bit));
 	assert(xb_set_bit(&xb1, bit) == 0);
 	assert(xb_test_bit(&xb1, bit));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
 	xb_preload_end();
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
