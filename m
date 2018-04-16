Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4606B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:32:39 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id j80so10919123ywg.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:32:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f4si608471qkb.281.2018.04.16.12.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 12:32:37 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:32:35 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH RESEND] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <20180416144638.GA22484@redhat.com>
Message-ID: <alpine.LRH.2.02.1804161530360.19492@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz> <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com> <20180416144638.GA22484@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch introduces a flag SLAB_MINIMIZE_WASTE for slab and slub. This
flag causes allocation of larger slab caches in order to minimize wasted
space.

This is needed because we want to use dm-bufio for deduplication index and
there are existing installations with non-power-of-two block sizes (such
as 640KB). The performance of the whole solution depends on efficient
memory use, so we must waste as little memory as possible.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/md/dm-bufio.c |    2 +-
 include/linux/slab.h  |    7 +++++++
 mm/slab.c             |    4 ++--
 mm/slab.h             |    7 ++++---
 mm/slab_common.c      |    2 +-
 mm/slub.c             |   25 ++++++++++++++++++++-----
 6 files changed, 35 insertions(+), 12 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2018-04-16 21:10:45.000000000 +0200
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
--- linux-2.6.orig/mm/slab_common.c	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/mm/slab_common.c	2018-04-16 21:10:45.000000000 +0200
@@ -53,7 +53,7 @@ static DECLARE_WORK(slab_caches_to_rcu_d
 		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
-			 SLAB_ACCOUNT)
+			 SLAB_ACCOUNT | SLAB_MINIMIZE_WASTE)
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/mm/slub.c	2018-04-16 21:12:41.000000000 +0200
@@ -3249,7 +3249,7 @@ static inline unsigned int slab_order(un
 	return order;
 }
 
-static inline int calculate_order(unsigned int size, unsigned int reserved)
+static inline int calculate_order(unsigned int size, unsigned int reserved, slab_flags_t flags)
 {
 	unsigned int order;
 	unsigned int min_objects;
@@ -3277,7 +3277,7 @@ static inline int calculate_order(unsign
 			order = slab_order(size, min_objects,
 					slub_max_order, fraction, reserved);
 			if (order <= slub_max_order)
-				return order;
+				goto ret_order;
 			fraction /= 2;
 		}
 		min_objects--;
@@ -3289,15 +3289,30 @@ static inline int calculate_order(unsign
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
+			if (test_order_objects >= min(32, MAX_OBJS_PER_PAGE))
+				break;
+			if (test_order_objects > order_objects << (test_order - order))
+				order = test_order;
+		}
+	}
+	return order;
 }
 
 static void
@@ -3562,7 +3577,7 @@ static int calculate_sizes(struct kmem_c
 	if (forced_order >= 0)
 		order = forced_order;
 	else
-		order = calculate_order(size, s->reserved);
+		order = calculate_order(size, s->reserved, flags);
 
 	if ((int)order < 0)
 		return 0;
Index: linux-2.6/drivers/md/dm-bufio.c
===================================================================
--- linux-2.6.orig/drivers/md/dm-bufio.c	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/drivers/md/dm-bufio.c	2018-04-16 21:11:23.000000000 +0200
@@ -1683,7 +1683,7 @@ struct dm_bufio_client *dm_bufio_client_
 	    (block_size < PAGE_SIZE || !is_power_of_2(block_size))) {
 		snprintf(slab_name, sizeof slab_name, "dm_bufio_cache-%u", c->block_size);
 		c->slab_cache = kmem_cache_create(slab_name, c->block_size, ARCH_KMALLOC_MINALIGN,
-						  SLAB_RECLAIM_ACCOUNT, NULL);
+						  SLAB_RECLAIM_ACCOUNT | SLAB_MINIMIZE_WASTE, NULL);
 		if (!c->slab_cache) {
 			r = -ENOMEM;
 			goto bad;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/mm/slab.h	2018-04-16 21:10:45.000000000 +0200
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
 
 bool __kmem_cache_empty(struct kmem_cache *);
 int __kmem_cache_shutdown(struct kmem_cache *);
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2018-04-16 21:10:45.000000000 +0200
+++ linux-2.6/mm/slab.c	2018-04-16 21:10:45.000000000 +0200
@@ -1790,14 +1790,14 @@ static size_t calculate_slab_order(struc
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
