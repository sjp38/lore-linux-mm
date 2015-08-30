Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 657CF6B0257
	for <linux-mm@kvack.org>; Sun, 30 Aug 2015 15:02:39 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so114677648pac.2
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 12:02:39 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ow9si20539596pdb.117.2015.08.30.12.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 12:02:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/2] mm/slub: do not bypass memcg reclaim for high-order page allocation
Date: Sun, 30 Aug 2015 22:02:18 +0300
Message-ID: <077206b884045ae9d82fd603fddde51d2eb630b5.1440960578.git.vdavydov@parallels.com>
In-Reply-To: <cover.1440960578.git.vdavydov@parallels.com>
References: <cover.1440960578.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 6af3142bed1f52 ("mm/slub: don't wait for high-order page
allocation") made allocate_slab() try to allocate high order slab pages
without __GFP_WAIT in order to avoid invoking reclaim/compaction when we
can fall back on low order pages. However, it broke memcg/memory.high
logic in case kmem accounting is enabled. The memory.high threshold
works as a soft limit: an allocation does not fail if it is breached,
but we call direct reclaim to compensate for the excess. Without
__GFP_WAIT we cannot invoke reclaimer and therefore we will go on
exceeding memory.high more and more until a normal __GFP_WAIT allocation
is issued.

Since memcg reclaim never triggers compaction, we can pass __GFP_WAIT to
memcg_charge_slab() even on high order page allocations w/o any
performance impact. So let us fix this problem by excluding __GFP_WAIT
only from alloc_pages() while still forwarding it to memcg_charge_slab()
if the context allows.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e180f8dcd06d..416a332277cb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1333,6 +1333,14 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (memcg_charge_slab(s, flags, order))
 		return NULL;
 
+	/*
+	 * Let the initial higher-order allocation fail under memory pressure
+	 * so we fall-back to the minimum order allocation.
+	 */
+	if (oo_order(oo) > oo_order(s->min))
+		flags = (flags | __GFP_NOWARN | __GFP_NOMEMALLOC) &
+					~(__GFP_NOFAIL | __GFP_WAIT);
+
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
@@ -1348,7 +1356,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
 	struct kmem_cache_order_objects oo = s->oo;
-	gfp_t alloc_gfp;
 	void *start, *p;
 	int idx, order;
 
@@ -1359,23 +1366,14 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	flags |= s->allocflags;
 
-	/*
-	 * Let the initial higher-order allocation fail under memory pressure
-	 * so we fall-back to the minimum order allocation.
-	 */
-	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
-	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
-		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~__GFP_WAIT;
-
-	page = alloc_slab_page(s, alloc_gfp, node, oo);
+	page = alloc_slab_page(s, flags, node, oo);
 	if (unlikely(!page)) {
 		oo = s->min;
-		alloc_gfp = flags;
 		/*
 		 * Allocation may have failed due to fragmentation.
 		 * Try a lower order alloc if possible
 		 */
-		page = alloc_slab_page(s, alloc_gfp, node, oo);
+		page = alloc_slab_page(s, flags, node, oo);
 		if (unlikely(!page))
 			goto out;
 		stat(s, ORDER_FALLBACK);
@@ -1385,7 +1383,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	    !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
 		int pages = 1 << oo_order(oo);
 
-		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
+		kmemcheck_alloc_shadow(page, oo_order(oo), flags, node);
 
 		/*
 		 * Objects from caches that have a constructor don't get
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
