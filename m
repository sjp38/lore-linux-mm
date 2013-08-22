Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D46226B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:19 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 02/16] slab: change return type of kmem_getpages() to struct page
Date: Thu, 22 Aug 2013 17:44:11 +0900
Message-Id: <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is more understandable that kmem_getpages() return struct page.
And, with this, we can reduce one translation from virt addr to page and
makes better code than before. Below is a change of this patch.

* Before
   text	   data	    bss	    dec	    hex	filename
  22123	  23434	      4	  45561	   b1f9	mm/slab.o

* After
   text	   data	    bss	    dec	    hex	filename
  22074	  23434	      4	  45512	   b1c8	mm/slab.o

And this help following patch to remove struct slab's colouroff.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index d9eae39..180f532 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -205,7 +205,7 @@ typedef unsigned int kmem_bufctl_t;
 struct slab_rcu {
 	struct rcu_head head;
 	struct kmem_cache *cachep;
-	void *addr;
+	struct page *page;
 };
 
 /*
@@ -1731,7 +1731,8 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
+								int nodeid)
 {
 	struct page *page;
 	int nr_pages;
@@ -1784,16 +1785,15 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 			kmemcheck_mark_unallocated_pages(page, nr_pages);
 	}
 
-	return page_address(page);
+	return page;
 }
 
 /*
  * Interface to system's page release.
  */
-static void kmem_freepages(struct kmem_cache *cachep, void *addr)
+static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 {
 	unsigned long i = (1 << cachep->gfporder);
-	struct page *page = virt_to_page(addr);
 	const unsigned long nr_freed = i;
 
 	kmemcheck_free_shadow(page, cachep->gfporder);
@@ -1815,7 +1815,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	free_memcg_kmem_pages((unsigned long)addr, cachep->gfporder);
+	__free_memcg_kmem_pages(page, cachep->gfporder);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
@@ -1823,7 +1823,7 @@ static void kmem_rcu_free(struct rcu_head *head)
 	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
 	struct kmem_cache *cachep = slab_rcu->cachep;
 
-	kmem_freepages(cachep, slab_rcu->addr);
+	kmem_freepages(cachep, slab_rcu->page);
 	if (OFF_SLAB(cachep))
 		kmem_cache_free(cachep->slabp_cache, slab_rcu);
 }
@@ -2042,7 +2042,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
  */
 static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 {
-	void *addr = slabp->s_mem - slabp->colouroff;
+	struct page *page = virt_to_head_page(slabp->s_mem);
 
 	slab_destroy_debugcheck(cachep, slabp);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
@@ -2050,10 +2050,10 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 
 		slab_rcu = (struct slab_rcu *)slabp;
 		slab_rcu->cachep = cachep;
-		slab_rcu->addr = addr;
+		slab_rcu->page = page;
 		call_rcu(&slab_rcu->head, kmem_rcu_free);
 	} else {
-		kmem_freepages(cachep, addr);
+		kmem_freepages(cachep, page);
 		if (OFF_SLAB(cachep))
 			kmem_cache_free(cachep->slabp_cache, slabp);
 	}
@@ -2598,11 +2598,12 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
  * kmem_find_general_cachep till the initialization is complete.
  * Hence we cannot have slabp_cache same as the original cache.
  */
-static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
-				   int colour_off, gfp_t local_flags,
-				   int nodeid)
+static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
+				   struct page *page, int colour_off,
+				   gfp_t local_flags, int nodeid)
 {
 	struct slab *slabp;
+	void *addr = page_address(page);
 
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
@@ -2619,12 +2620,12 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 		if (!slabp)
 			return NULL;
 	} else {
-		slabp = objp + colour_off;
+		slabp = addr + colour_off;
 		colour_off += cachep->slab_size;
 	}
 	slabp->inuse = 0;
 	slabp->colouroff = colour_off;
-	slabp->s_mem = objp + colour_off;
+	slabp->s_mem = addr + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
 	return slabp;
@@ -2735,12 +2736,9 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
  * virtual address for kfree, ksize, and slab debugging.
  */
 static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
-			   void *addr)
+			   struct page *page)
 {
 	int nr_pages;
-	struct page *page;
-
-	page = virt_to_page(addr);
 
 	nr_pages = 1;
 	if (likely(!PageCompound(page)))
@@ -2758,7 +2756,7 @@ static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
 static int cache_grow(struct kmem_cache *cachep,
-		gfp_t flags, int nodeid, void *objp)
+		gfp_t flags, int nodeid, struct page *page)
 {
 	struct slab *slabp;
 	size_t offset;
@@ -2801,18 +2799,18 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * Get mem for the objs.  Attempt to allocate a physical page from
 	 * 'nodeid'.
 	 */
-	if (!objp)
-		objp = kmem_getpages(cachep, local_flags, nodeid);
-	if (!objp)
+	if (!page)
+		page = kmem_getpages(cachep, local_flags, nodeid);
+	if (!page)
 		goto failed;
 
 	/* Get slab management. */
-	slabp = alloc_slabmgmt(cachep, objp, offset,
+	slabp = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
 	if (!slabp)
 		goto opps1;
 
-	slab_map_pages(cachep, slabp, objp);
+	slab_map_pages(cachep, slabp, page);
 
 	cache_init_objs(cachep, slabp);
 
@@ -2828,7 +2826,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	spin_unlock(&n->list_lock);
 	return 1;
 opps1:
-	kmem_freepages(cachep, objp);
+	kmem_freepages(cachep, page);
 failed:
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
@@ -3244,18 +3242,20 @@ retry:
 		 * We may trigger various forms of reclaim on the allowed
 		 * set and go into memory reserves if necessary.
 		 */
+		struct page *page;
+
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_mem_id());
+		page = kmem_getpages(cache, local_flags, numa_mem_id());
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
-		if (obj) {
+		if (page) {
 			/*
 			 * Insert into the appropriate per node queues
 			 */
-			nid = page_to_nid(virt_to_page(obj));
-			if (cache_grow(cache, flags, nid, obj)) {
+			nid = page_to_nid(page);
+			if (cache_grow(cache, flags, nid, page)) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
 				if (!obj)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
