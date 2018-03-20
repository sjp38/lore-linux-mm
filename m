Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC216B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:25:15 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y9so1461085qtf.7
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:25:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g73si3325762qka.136.2018.03.20.10.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 10:25:13 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:25:09 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
Message-ID: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

Hi

I'm submitting this patch for the slab allocator. The patch adds a new 
flag SLAB_MINIMIZE_WASTE. When this flag is present, the slab subsystem 
will use higher-order allocations to minimize wasted space (it will not 
use higher-order allocations when there's no benefit, such as if the 
object size is a power of two).

The reason why we need this is that we are going to merge code that does 
block device deduplication (it was developed separatedly and sold as a 
commercial product), and the code uses block sizes that are not a power of 
two (block sizes 192K, 448K, 640K, 832K are used in the wild). The slab 
allocator rounds up the allocation to the nearest power of two, but that 
wastes a lot of memory. Performance of the solution depends on efficient 
memory usage, so we should minimize wasted as much as possible.

Larger-order allocations are unreliable (they may fail at any time if the 
memory is fragmented), but it is not an issue here - the code preallocates 
a few buffers with vmalloc and then allocates buffers from the slab cache. 
If the allocation fails due to memory fragmentation, we throw away and 
reuse some existing buffer, so there is no functionality loss.

Mikulas


From: Mikulas Patocka <mpatocka@redhat.com>

This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
flag causes allocation of larger slab caches in order to minimize wasted
space.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 include/linux/slab.h  |    7 +++++++
 mm/slab.c             |    4 ++--
 mm/slab.h             |    7 ++++---
 mm/slab_common.c      |    2 +-
 mm/slub.c             |   25 ++++++++++++++++++++-----
 6 files changed, 35 insertions(+), 12 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2018-03-20 14:59:20.528030000 +0100
+++ linux-2.6/include/linux/slab.h	2018-03-20 14:59:20.518030000 +0100
@@ -108,6 +108,13 @@
 #define SLAB_KASAN		0
 #endif
 
+/*
+ * Use higer order allocations to minimize wasted space.
+ * Note: the allocation is unreliable if this flag is used, the caller
+ * must handle allocation failures gracefully.
+ */
+#define SLAB_MINIMIZE_WASTE	((slab_flags_t __force)0x10000000U)
+
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2018-03-20 14:59:20.528030000 +0100
+++ linux-2.6/mm/slab_common.c	2018-03-20 14:59:20.518030000 +0100
@@ -52,7 +52,7 @@ static DECLARE_WORK(slab_caches_to_rcu_d
 		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
-			 SLAB_ACCOUNT)
+			 SLAB_ACCOUNT | SLAB_MINIMIZE_WASTE)
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-03-20 14:59:20.528030000 +0100
+++ linux-2.6/mm/slub.c	2018-03-20 14:59:20.518030000 +0100
@@ -3234,7 +3234,7 @@ static inline int slab_order(int size, i
 	return order;
 }
 
-static inline int calculate_order(int size, int reserved)
+static inline int calculate_order(int size, int reserved, slab_flags_t flags)
 {
 	int order;
 	int min_objects;
@@ -3261,7 +3261,7 @@ static inline int calculate_order(int si
 			order = slab_order(size, min_objects,
 					slub_max_order, fraction, reserved);
 			if (order <= slub_max_order)
-				return order;
+				goto ret_order;
 			fraction /= 2;
 		}
 		min_objects--;
@@ -3273,15 +3273,30 @@ static inline int calculate_order(int si
 	 */
 	order = slab_order(size, 1, slub_max_order, 1, reserved);
 	if (order <= slub_max_order)
-		return order;
+		goto ret_order;
 
 	/*
 	 * Doh this slab cannot be placed using slub_max_order.
 	 */
 	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
 	if (order < MAX_ORDER)
-		return order;
+		goto ret_order;
 	return -ENOSYS;
+
+ret_order:
+	if (flags & SLAB_MINIMIZE_WASTE) {
+		/* Increase the order if it decreases waste */
+		int test_order;
+		for (test_order = order + 1; test_order < MAX_ORDER; test_order++) {
+			unsigned long order_objects = ((PAGE_SIZE << order) - reserved) / size;
+			unsigned long test_order_objects = ((PAGE_SIZE << test_order) - reserved) / size;
+			if (test_order_objects >= min(64, MAX_OBJS_PER_PAGE))
+				break;
+			if (test_order_objects > order_objects << (test_order - order))
+				order = test_order;
+		}
+	}
+	return order;
 }
 
 static void
@@ -3546,7 +3561,7 @@ static int calculate_sizes(struct kmem_c
 	if (forced_order >= 0)
 		order = forced_order;
 	else
-		order = calculate_order(size, s->reserved);
+		order = calculate_order(size, s->reserved, flags);
 
 	if (order < 0)
 		return 0;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2018-03-20 14:59:20.528030000 +0100
+++ linux-2.6/mm/slab.h	2018-03-20 14:59:20.518030000 +0100
@@ -142,10 +142,10 @@ static inline slab_flags_t kmem_cache_fl
 #if defined(CONFIG_SLAB)
 #define SLAB_CACHE_FLAGS (SLAB_MEM_SPREAD | SLAB_NOLEAKTRACE | \
 			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | \
-			  SLAB_ACCOUNT)
+			  SLAB_ACCOUNT | SLAB_MINIMIZE_WASTE)
 #elif defined(CONFIG_SLUB)
 #define SLAB_CACHE_FLAGS (SLAB_NOLEAKTRACE | SLAB_RECLAIM_ACCOUNT | \
-			  SLAB_TEMPORARY | SLAB_ACCOUNT)
+			  SLAB_TEMPORARY | SLAB_ACCOUNT | SLAB_MINIMIZE_WASTE)
 #else
 #define SLAB_CACHE_FLAGS (0)
 #endif
@@ -164,7 +164,8 @@ static inline slab_flags_t kmem_cache_fl
 			      SLAB_NOLEAKTRACE | \
 			      SLAB_RECLAIM_ACCOUNT | \
 			      SLAB_TEMPORARY | \
-			      SLAB_ACCOUNT)
+			      SLAB_ACCOUNT | \
+			      SLAB_MINIMIZE_WASTE)
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2018-03-20 14:59:20.528030000 +0100
+++ linux-2.6/mm/slab.c	2018-03-20 14:59:20.518030000 +0100
@@ -1789,14 +1789,14 @@ static size_t calculate_slab_order(struc
 		 * as GFP_NOFS and we really don't want to have to be allocating
 		 * higher-order pages when we are unable to shrink dcache.
 		 */
-		if (flags & SLAB_RECLAIM_ACCOUNT)
+		if (flags & SLAB_RECLAIM_ACCOUNT && !(flags & SLAB_MINIMIZE_WASTE))
 			break;
 
 		/*
 		 * Large number of objects is good, but very large slabs are
 		 * currently bad for the gfp()s.
 		 */
-		if (gfporder >= slab_max_order)
+		if (gfporder >= slab_max_order && !(flags & SLAB_MINIMIZE_WASTE))
 			break;
 
 		/*
