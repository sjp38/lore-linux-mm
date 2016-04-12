Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B27F6B0266
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:52:03 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ot11so6107604pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:52:03 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id 7si7654779pfm.127.2016.04.11.21.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:52:02 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id e128so6197204pfe.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:52:02 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 10/11] mm/slab: refill cpu cache through a new slab without holding a node lock
Date: Tue, 12 Apr 2016 13:51:05 +0900
Message-Id: <1460436666-20462-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, cache growing makes a free slab on node's slab list and then we
can allocate free objects from it.  This necessarily requires to hold a
node lock which is very contended.  If we refill cpu cache before
attaching it to node's slab list, we can avoid holding a node lock as much
as possible because this newly allocated slab is only visible to the
current task.  This will reduce lock contention.

Below is the result of concurrent allocation/free in slab allocation
benchmark made by Christoph a long time ago.  I make the output simpler.
The number shows cycle count during alloc/free respectively so less is
better.

* Before
Kmalloc N*alloc N*free(32): Average=355/750
Kmalloc N*alloc N*free(64): Average=452/812
Kmalloc N*alloc N*free(128): Average=559/1070
Kmalloc N*alloc N*free(256): Average=1176/980
Kmalloc N*alloc N*free(512): Average=1939/1189
Kmalloc N*alloc N*free(1024): Average=3521/1278
Kmalloc N*alloc N*free(2048): Average=7152/1838
Kmalloc N*alloc N*free(4096): Average=13438/2013

* After
Kmalloc N*alloc N*free(32): Average=248/966
Kmalloc N*alloc N*free(64): Average=261/949
Kmalloc N*alloc N*free(128): Average=314/1016
Kmalloc N*alloc N*free(256): Average=741/1061
Kmalloc N*alloc N*free(512): Average=1246/1152
Kmalloc N*alloc N*free(1024): Average=2437/1259
Kmalloc N*alloc N*free(2048): Average=4980/1800
Kmalloc N*alloc N*free(4096): Average=9000/2078

It shows that contention is reduced for all the object sizes and
performance increases by 30 ~ 40%.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 68 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 36 insertions(+), 32 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2c28ad5..cf12fbd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2852,6 +2852,30 @@ static noinline void *cache_alloc_pfmemalloc(struct kmem_cache *cachep,
 	return obj;
 }
 
+/*
+ * Slab list should be fixed up by fixup_slab_list() for existing slab
+ * or cache_grow_end() for new slab
+ */
+static __always_inline int alloc_block(struct kmem_cache *cachep,
+		struct array_cache *ac, struct page *page, int batchcount)
+{
+	/*
+	 * There must be at least one object available for
+	 * allocation.
+	 */
+	BUG_ON(page->active >= cachep->num);
+
+	while (page->active < cachep->num && batchcount--) {
+		STATS_INC_ALLOCED(cachep);
+		STATS_INC_ACTIVE(cachep);
+		STATS_SET_HIGH(cachep);
+
+		ac->entry[ac->avail++] = slab_get_obj(cachep, page);
+	}
+
+	return batchcount;
+}
+
 static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 {
 	int batchcount;
@@ -2864,7 +2888,6 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 	check_irq_off();
 	node = numa_mem_id();
 
-retry:
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -2894,21 +2917,7 @@ retry:
 
 		check_spinlock_acquired(cachep);
 
-		/*
-		 * The slab was either on partial or free list so
-		 * there must be at least one object available for
-		 * allocation.
-		 */
-		BUG_ON(page->active >= cachep->num);
-
-		while (page->active < cachep->num && batchcount--) {
-			STATS_INC_ALLOCED(cachep);
-			STATS_INC_ACTIVE(cachep);
-			STATS_SET_HIGH(cachep);
-
-			ac->entry[ac->avail++] = slab_get_obj(cachep, page);
-		}
-
+		batchcount = alloc_block(cachep, ac, page, batchcount);
 		fixup_slab_list(cachep, n, page, &list);
 	}
 
@@ -2928,21 +2937,18 @@ alloc_done:
 		}
 
 		page = cache_grow_begin(cachep, gfp_exact_node(flags), node);
-		cache_grow_end(cachep, page);
 
 		/*
 		 * cache_grow_begin() can reenable interrupts,
 		 * then ac could change.
 		 */
 		ac = cpu_cache_get(cachep);
-		node = numa_mem_id();
+		if (!ac->avail && page)
+			alloc_block(cachep, ac, page, batchcount);
+		cache_grow_end(cachep, page);
 
-		/* no objects in sight? abort */
-		if (!page && ac->avail == 0)
+		if (!ac->avail)
 			return NULL;
-
-		if (!ac->avail)		/* objects refilled by interrupt? */
-			goto retry;
 	}
 	ac->touched = 1;
 
@@ -3136,14 +3142,13 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 {
 	struct page *page;
 	struct kmem_cache_node *n;
-	void *obj;
+	void *obj = NULL;
 	void *list = NULL;
 
 	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
 	n = get_node(cachep, nodeid);
 	BUG_ON(!n);
 
-retry:
 	check_irq_off();
 	spin_lock(&n->list_lock);
 	page = get_first_slab(n, false);
@@ -3165,19 +3170,18 @@ retry:
 
 	spin_unlock(&n->list_lock);
 	fixup_objfreelist_debug(cachep, &list);
-	goto done;
+	return obj;
 
 must_grow:
 	spin_unlock(&n->list_lock);
 	page = cache_grow_begin(cachep, gfp_exact_node(flags), nodeid);
+	if (page) {
+		/* This slab isn't counted yet so don't update free_objects */
+		obj = slab_get_obj(cachep, page);
+	}
 	cache_grow_end(cachep, page);
-	if (page)
-		goto retry;
 
-	return fallback_alloc(cachep, flags);
-
-done:
-	return obj;
+	return obj ? obj : fallback_alloc(cachep, flags);
 }
 
 static __always_inline void *
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
