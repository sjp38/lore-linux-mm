Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7D1936B0069
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:24 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 14/16] slab: use struct page for slab management
Date: Thu, 22 Aug 2013 17:44:23 +0900
Message-Id: <1377161065-30552-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, there are a few field in struct slab, so we can overload these
over struct page. This will save some memory and reduce cache footprint.

After this change, slabp_cache and slab_size no longer related to
a struct slab, so rename them as freelist_cache and freelist_size.

These changes are just mechanical ones and there is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..66ee577 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -42,18 +42,22 @@ struct page {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	struct address_space *mapping;	/* If low bit clear, points to
-					 * inode address_space, or NULL.
-					 * If page mapped as anonymous
-					 * memory, low bit is set, and
-					 * it points to anon_vma object:
-					 * see PAGE_MAPPING_ANON below.
-					 */
+	union {
+		struct address_space *mapping;	/* If low bit clear, points to
+						 * inode address_space, or NULL.
+						 * If page mapped as anonymous
+						 * memory, low bit is set, and
+						 * it points to anon_vma object:
+						 * see PAGE_MAPPING_ANON below.
+						 */
+		void *s_mem;			/* slab first object */
+	};
+
 	/* Second double word */
 	struct {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
-			void *freelist;		/* slub/slob first free object */
+			void *freelist;		/* sl[aou]b first free object */
 			bool pfmemalloc;	/* If set by the page allocator,
 						 * ALLOC_NO_WATERMARKS was set
 						 * and the low watermark was not
@@ -109,6 +113,7 @@ struct page {
 				};
 				atomic_t _count;		/* Usage count, see below. */
 			};
+			unsigned int active;	/* SLAB */
 		};
 	};
 
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index cd40158..ca82e8f 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -41,8 +41,8 @@ struct kmem_cache {
 
 	size_t colour;			/* cache colouring range */
 	unsigned int colour_off;	/* colour offset */
-	struct kmem_cache *slabp_cache;
-	unsigned int slab_size;
+	struct kmem_cache *freelist_cache;
+	unsigned int freelist_size;
 
 	/* constructor func */
 	void (*ctor)(void *obj);
diff --git a/mm/slab.c b/mm/slab.c
index 9dcbb22..cf39309 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -164,21 +164,6 @@
 static bool pfmemalloc_active __read_mostly;
 
 /*
- * struct slab
- *
- * Manages the objs in a slab. Placed either at the beginning of mem allocated
- * for a slab, or allocated from an general cache.
- * Slabs are chained into three list: fully used, partial, fully free slabs.
- */
-struct slab {
-	struct {
-		struct list_head list;
-		void *s_mem;		/* including colour offset */
-		unsigned int active;	/* num of objs active in slab */
-	};
-};
-
-/*
  * struct array_cache
  *
  * Purpose:
@@ -405,18 +390,10 @@ static inline struct kmem_cache *virt_to_cache(const void *obj)
 	return page->slab_cache;
 }
 
-static inline struct slab *virt_to_slab(const void *obj)
-{
-	struct page *page = virt_to_head_page(obj);
-
-	VM_BUG_ON(!PageSlab(page));
-	return page->slab_page;
-}
-
-static inline void *index_to_obj(struct kmem_cache *cache, struct slab *slab,
+static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
 				 unsigned int idx)
 {
-	return slab->s_mem + cache->size * idx;
+	return page->s_mem + cache->size * idx;
 }
 
 /*
@@ -426,9 +403,9 @@ static inline void *index_to_obj(struct kmem_cache *cache, struct slab *slab,
  *   reciprocal_divide(offset, cache->reciprocal_buffer_size)
  */
 static inline unsigned int obj_to_index(const struct kmem_cache *cache,
-					const struct slab *slab, void *obj)
+					const struct page *page, void *obj)
 {
-	u32 offset = (obj - slab->s_mem);
+	u32 offset = (obj - page->s_mem);
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
 }
 
@@ -590,7 +567,7 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 
 static size_t slab_mgmt_size(size_t nr_objs, size_t align)
 {
-	return ALIGN(sizeof(struct slab)+nr_objs*sizeof(unsigned int), align);
+	return ALIGN(nr_objs * sizeof(unsigned int), align);
 }
 
 /*
@@ -609,7 +586,6 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * on it. For the latter case, the memory allocated for a
 	 * slab is used for:
 	 *
-	 * - The struct slab
 	 * - One unsigned int for each object
 	 * - Padding to respect alignment of @align
 	 * - @buffer_size bytes for each object
@@ -632,8 +608,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 		 * into the memory allocation when taking the padding
 		 * into account.
 		 */
-		nr_objs = (slab_size - sizeof(struct slab)) /
-			  (buffer_size + sizeof(unsigned int));
+		nr_objs = (slab_size) / (buffer_size + sizeof(unsigned int));
 
 		/*
 		 * This calculated number will be either the right
@@ -773,11 +748,11 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	return nc;
 }
 
-static inline bool is_slab_pfmemalloc(struct slab *slabp)
+static inline bool is_slab_pfmemalloc(struct page *page)
 {
-	struct page *page = virt_to_page(slabp->s_mem);
+	struct page *mem_page = virt_to_page(page->s_mem);
 
-	return PageSlabPfmemalloc(page);
+	return PageSlabPfmemalloc(mem_page);
 }
 
 /* Clears pfmemalloc_active if no slabs have pfmalloc set */
@@ -785,23 +760,23 @@ static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
 	struct kmem_cache_node *n = cachep->node[numa_mem_id()];
-	struct slab *slabp;
+	struct page *page;
 	unsigned long flags;
 
 	if (!pfmemalloc_active)
 		return;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(slabp, &n->slabs_full, list)
-		if (is_slab_pfmemalloc(slabp))
+	list_for_each_entry(page, &n->slabs_full, lru)
+		if (is_slab_pfmemalloc(page))
 			goto out;
 
-	list_for_each_entry(slabp, &n->slabs_partial, list)
-		if (is_slab_pfmemalloc(slabp))
+	list_for_each_entry(page, &n->slabs_partial, lru)
+		if (is_slab_pfmemalloc(page))
 			goto out;
 
-	list_for_each_entry(slabp, &n->slabs_free, list)
-		if (is_slab_pfmemalloc(slabp))
+	list_for_each_entry(page, &n->slabs_free, lru)
+		if (is_slab_pfmemalloc(page))
 			goto out;
 
 	pfmemalloc_active = false;
@@ -841,8 +816,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		 */
 		n = cachep->node[numa_mem_id()];
 		if (!list_empty(&n->slabs_free) && force_refill) {
-			struct slab *slabp = virt_to_slab(objp);
-			ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
+			struct page *page = virt_to_head_page(objp);
+			ClearPageSlabPfmemalloc(virt_to_head_page(page->s_mem));
 			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
 			return objp;
@@ -874,9 +849,9 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 {
 	if (unlikely(pfmemalloc_active)) {
 		/* Some pfmemalloc slabs exist, check if this is one */
-		struct slab *slabp = virt_to_slab(objp);
-		struct page *page = virt_to_head_page(slabp->s_mem);
-		if (PageSlabPfmemalloc(page))
+		struct page *page = virt_to_head_page(objp);
+		struct page *mem_page = virt_to_head_page(page->s_mem);
+		if (PageSlabPfmemalloc(mem_page))
 			set_obj_pfmemalloc(&objp);
 	}
 
@@ -1627,7 +1602,7 @@ static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
 	struct kmem_cache_node *n;
-	struct slab *slabp;
+	struct page *page;
 	unsigned long flags;
 	int node;
 
@@ -1646,15 +1621,15 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(slabp, &n->slabs_full, list) {
+		list_for_each_entry(page, &n->slabs_full, lru) {
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &n->slabs_partial, list) {
-			active_objs += slabp->active;
+		list_for_each_entry(page, &n->slabs_partial, lru) {
+			active_objs += page->active;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &n->slabs_free, list)
+		list_for_each_entry(page, &n->slabs_free, lru)
 			num_slabs++;
 
 		free_objects += n->free_objects;
@@ -1740,6 +1715,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
+	page_mapcount_reset(page);
+	page->mapping = NULL;
 
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
@@ -1904,19 +1881,19 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 		/* Print some data about the neighboring objects, if they
 		 * exist:
 		 */
-		struct slab *slabp = virt_to_slab(objp);
+		struct page *page = virt_to_head_page(objp);
 		unsigned int objnr;
 
-		objnr = obj_to_index(cachep, slabp, objp);
+		objnr = obj_to_index(cachep, page, objp);
 		if (objnr) {
-			objp = index_to_obj(cachep, slabp, objnr - 1);
+			objp = index_to_obj(cachep, page, objnr - 1);
 			realobj = (char *)objp + obj_offset(cachep);
 			printk(KERN_ERR "Prev obj: start=%p, len=%d\n",
 			       realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 		if (objnr + 1 < cachep->num) {
-			objp = index_to_obj(cachep, slabp, objnr + 1);
+			objp = index_to_obj(cachep, page, objnr + 1);
 			realobj = (char *)objp + obj_offset(cachep);
 			printk(KERN_ERR "Next obj: start=%p, len=%d\n",
 			       realobj, size);
@@ -1927,11 +1904,12 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 #endif
 
 #if DEBUG
-static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slabp)
+static void slab_destroy_debugcheck(struct kmem_cache *cachep,
+						struct page *page)
 {
 	int i;
 	for (i = 0; i < cachep->num; i++) {
-		void *objp = index_to_obj(cachep, slabp, i);
+		void *objp = index_to_obj(cachep, page, i);
 
 		if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -1956,7 +1934,8 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
 	}
 }
 #else
-static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slabp)
+static void slab_destroy_debugcheck(struct kmem_cache *cachep,
+						struct page *page)
 {
 }
 #endif
@@ -1970,11 +1949,12 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
  * Before calling the slab must have been unlinked from the cache.  The
  * cache-lock is not held/needed.
  */
-static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
+static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 {
-	struct page *page = virt_to_head_page(slabp->s_mem);
+	struct freelist *freelist;
 
-	slab_destroy_debugcheck(cachep, slabp);
+	freelist = page->freelist;
+	slab_destroy_debugcheck(cachep, page);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
 		struct rcu_head *head;
 
@@ -1986,11 +1966,11 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 		kmem_freepages(cachep, page);
 
 	/*
-	 * From now on, we don't use slab management
+	 * From now on, we don't use freelist
 	 * although actual page will be freed in rcu context.
 	 */
 	if (OFF_SLAB(cachep))
-		kmem_cache_free(cachep->slabp_cache, slabp);
+		kmem_cache_free(cachep->freelist_cache, freelist);
 }
 
 /**
@@ -2027,7 +2007,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			 * use off-slab slabs. Needed to avoid a possible
 			 * looping condition in cache_grow().
 			 */
-			offslab_limit = size - sizeof(struct slab);
+			offslab_limit = size;
 			offslab_limit /= sizeof(unsigned int);
 
  			if (num > offslab_limit)
@@ -2150,7 +2130,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 int
 __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
-	size_t left_over, slab_size, ralign;
+	size_t left_over, freelist_size, ralign;
 	gfp_t gfp;
 	int err;
 	size_t size = cachep->size;
@@ -2269,22 +2249,21 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (!cachep->num)
 		return -E2BIG;
 
-	slab_size = ALIGN(cachep->num * sizeof(unsigned int)
-			  + sizeof(struct slab), cachep->align);
+	freelist_size =
+		ALIGN(cachep->num * sizeof(unsigned int), cachep->align);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
 	 * move it on-slab. This is at the expense of any extra colouring.
 	 */
-	if (flags & CFLGS_OFF_SLAB && left_over >= slab_size) {
+	if (flags & CFLGS_OFF_SLAB && left_over >= freelist_size) {
 		flags &= ~CFLGS_OFF_SLAB;
-		left_over -= slab_size;
+		left_over -= freelist_size;
 	}
 
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
-		slab_size =
-		    cachep->num * sizeof(unsigned int) + sizeof(struct slab);
+		freelist_size = cachep->num * sizeof(unsigned int);
 
 #ifdef CONFIG_PAGE_POISONING
 		/* If we're going to use the generic kernel_map_pages()
@@ -2301,7 +2280,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (cachep->colour_off < cachep->align)
 		cachep->colour_off = cachep->align;
 	cachep->colour = left_over / cachep->colour_off;
-	cachep->slab_size = slab_size;
+	cachep->freelist_size = freelist_size;
 	cachep->flags = flags;
 	cachep->allocflags = __GFP_COMP;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
@@ -2310,7 +2289,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
 	if (flags & CFLGS_OFF_SLAB) {
-		cachep->slabp_cache = kmalloc_slab(slab_size, 0u);
+		cachep->freelist_cache = kmalloc_slab(freelist_size, 0u);
 		/*
 		 * This is a possibility for one of the malloc_sizes caches.
 		 * But since we go off slab only for object size greater than
@@ -2318,7 +2297,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		 * this should not happen at all.
 		 * But leave a BUG_ON for some lucky dude.
 		 */
-		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
+		BUG_ON(ZERO_OR_NULL_PTR(cachep->freelist_cache));
 	}
 
 	err = setup_cpu_cache(cachep, gfp);
@@ -2424,7 +2403,7 @@ static int drain_freelist(struct kmem_cache *cache,
 {
 	struct list_head *p;
 	int nr_freed;
-	struct slab *slabp;
+	struct page *page;
 
 	nr_freed = 0;
 	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
@@ -2436,18 +2415,18 @@ static int drain_freelist(struct kmem_cache *cache,
 			goto out;
 		}
 
-		slabp = list_entry(p, struct slab, list);
+		page = list_entry(p, struct page, lru);
 #if DEBUG
-		BUG_ON(slabp->active);
+		BUG_ON(page->active);
 #endif
-		list_del(&slabp->list);
+		list_del(&page->lru);
 		/*
 		 * Safe to drop the lock. The slab is no longer linked
 		 * to the cache.
 		 */
 		n->free_objects -= cache->num;
 		spin_unlock_irq(&n->list_lock);
-		slab_destroy(cache, slabp);
+		slab_destroy(cache, page);
 		nr_freed++;
 	}
 out:
@@ -2530,18 +2509,18 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
  * descriptors in kmem_cache_create, we search through the malloc_sizes array.
  * If we are creating a malloc_sizes cache here it would not be visible to
  * kmem_find_general_cachep till the initialization is complete.
- * Hence we cannot have slabp_cache same as the original cache.
+ * Hence we cannot have freelist_cache same as the original cache.
  */
-static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
+static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 				   struct page *page, int colour_off,
 				   gfp_t local_flags, int nodeid)
 {
-	struct slab *slabp;
+	struct freelist *freelist;
 	void *addr = page_address(page);
 
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
-		slabp = kmem_cache_alloc_node(cachep->slabp_cache,
+		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
 		/*
 		 * If the first object in the slab is leaked (it's allocated
@@ -2549,31 +2528,31 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
 		 * kmemleak does not treat the ->s_mem pointer as a reference
 		 * to the object. Otherwise we will not report the leak.
 		 */
-		kmemleak_scan_area(&slabp->list, sizeof(struct list_head),
+		kmemleak_scan_area(&page->lru, sizeof(struct list_head),
 				   local_flags);
-		if (!slabp)
+		if (!freelist)
 			return NULL;
 	} else {
-		slabp = addr + colour_off;
-		colour_off += cachep->slab_size;
+		freelist = addr + colour_off;
+		colour_off += cachep->freelist_size;
 	}
-	slabp->active = 0;
-	slabp->s_mem = addr + colour_off;
-	return slabp;
+	page->active = 0;
+	page->s_mem = addr + colour_off;
+	return freelist;
 }
 
-static inline unsigned int *slab_bufctl(struct slab *slabp)
+static inline unsigned int *slab_bufctl(struct page *page)
 {
-	return (unsigned int *) (slabp + 1);
+	return (unsigned int *)(page->freelist);
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
-			    struct slab *slabp)
+			    struct page *page)
 {
 	int i;
 
 	for (i = 0; i < cachep->num; i++) {
-		void *objp = index_to_obj(cachep, slabp, i);
+		void *objp = index_to_obj(cachep, page, i);
 #if DEBUG
 		/* need to poison the objs? */
 		if (cachep->flags & SLAB_POISON)
@@ -2609,7 +2588,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		slab_bufctl(slabp)[i] = i;
+		slab_bufctl(page)[i] = i;
 	}
 }
 
@@ -2623,13 +2602,13 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 	}
 }
 
-static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
+static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
 				int nodeid)
 {
 	void *objp;
 
-	objp = index_to_obj(cachep, slabp, slab_bufctl(slabp)[slabp->active]);
-	slabp->active++;
+	objp = index_to_obj(cachep, page, slab_bufctl(page)[page->active]);
+	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 #endif
@@ -2637,10 +2616,10 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
 	return objp;
 }
 
-static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
+static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 				void *objp, int nodeid)
 {
-	unsigned int objnr = obj_to_index(cachep, slabp, objp);
+	unsigned int objnr = obj_to_index(cachep, page, objp);
 #if DEBUG
 	unsigned int i;
 
@@ -2648,16 +2627,16 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 
 	/* Verify double free bug */
-	for (i = slabp->active; i < cachep->num; i++) {
-		if (slab_bufctl(slabp)[i] == objnr) {
+	for (i = page->active; i < cachep->num; i++) {
+		if (slab_bufctl(page)[i] == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
 		}
 	}
 #endif
-	slabp->active--;
-	slab_bufctl(slabp)[slabp->active] = objnr;
+	page->active--;
+	slab_bufctl(page)[page->active] = objnr;
 }
 
 /*
@@ -2665,11 +2644,11 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
  * for the slab allocator to be able to lookup the cache and slab of a
  * virtual address for kfree, ksize, and slab debugging.
  */
-static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
-			   struct page *page)
+static void slab_map_pages(struct kmem_cache *cache, struct page *page,
+			   struct freelist *freelist)
 {
 	page->slab_cache = cache;
-	page->slab_page = slab;
+	page->freelist = freelist;
 }
 
 /*
@@ -2679,7 +2658,7 @@ static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
 static int cache_grow(struct kmem_cache *cachep,
 		gfp_t flags, int nodeid, struct page *page)
 {
-	struct slab *slabp;
+	struct freelist *freelist;
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_cache_node *n;
@@ -2726,14 +2705,14 @@ static int cache_grow(struct kmem_cache *cachep,
 		goto failed;
 
 	/* Get slab management. */
-	slabp = alloc_slabmgmt(cachep, page, offset,
+	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
-	if (!slabp)
+	if (!freelist)
 		goto opps1;
 
-	slab_map_pages(cachep, slabp, page);
+	slab_map_pages(cachep, page, freelist);
 
-	cache_init_objs(cachep, slabp);
+	cache_init_objs(cachep, page);
 
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
@@ -2741,7 +2720,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	spin_lock(&n->list_lock);
 
 	/* Make slab active. */
-	list_add_tail(&slabp->list, &(n->slabs_free));
+	list_add_tail(&page->lru, &(n->slabs_free));
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num;
 	spin_unlock(&n->list_lock);
@@ -2796,13 +2775,13 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 				   unsigned long caller)
 {
 	unsigned int objnr;
-	struct slab *slabp;
+	struct page *page;
 
 	BUG_ON(virt_to_cache(objp) != cachep);
 
 	objp -= obj_offset(cachep);
 	kfree_debugcheck(objp);
-	slabp = virt_to_slab(objp);
+	page = virt_to_head_page(objp);
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		verify_redzone_free(cachep, objp);
@@ -2812,10 +2791,10 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	if (cachep->flags & SLAB_STORE_USER)
 		*dbg_userword(cachep, objp) = (void *)caller;
 
-	objnr = obj_to_index(cachep, slabp, objp);
+	objnr = obj_to_index(cachep, page, objp);
 
 	BUG_ON(objnr >= cachep->num);
-	BUG_ON(objp != index_to_obj(cachep, slabp, objnr));
+	BUG_ON(objp != index_to_obj(cachep, page, objnr));
 
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -2874,7 +2853,7 @@ retry:
 
 	while (batchcount > 0) {
 		struct list_head *entry;
-		struct slab *slabp;
+		struct page *page;
 		/* Get slab alloc is to come from. */
 		entry = n->slabs_partial.next;
 		if (entry == &n->slabs_partial) {
@@ -2884,7 +2863,7 @@ retry:
 				goto must_grow;
 		}
 
-		slabp = list_entry(entry, struct slab, list);
+		page = list_entry(entry, struct page, lru);
 		check_spinlock_acquired(cachep);
 
 		/*
@@ -2892,23 +2871,23 @@ retry:
 		 * there must be at least one object available for
 		 * allocation.
 		 */
-		BUG_ON(slabp->active >= cachep->num);
+		BUG_ON(page->active >= cachep->num);
 
-		while (slabp->active < cachep->num && batchcount--) {
+		while (page->active < cachep->num && batchcount--) {
 			STATS_INC_ALLOCED(cachep);
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac_put_obj(cachep, ac, slab_get_obj(cachep, slabp,
+			ac_put_obj(cachep, ac, slab_get_obj(cachep, page,
 									node));
 		}
 
 		/* move slabp to correct slabp list: */
-		list_del(&slabp->list);
-		if (slabp->active == cachep->num)
-			list_add(&slabp->list, &n->slabs_full);
+		list_del(&page->lru);
+		if (page->active == cachep->num)
+			list_add(&page->list, &n->slabs_full);
 		else
-			list_add(&slabp->list, &n->slabs_partial);
+			list_add(&page->list, &n->slabs_partial);
 	}
 
 must_grow:
@@ -3163,7 +3142,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 				int nodeid)
 {
 	struct list_head *entry;
-	struct slab *slabp;
+	struct page *page;
 	struct kmem_cache_node *n;
 	void *obj;
 	int x;
@@ -3183,24 +3162,24 @@ retry:
 			goto must_grow;
 	}
 
-	slabp = list_entry(entry, struct slab, list);
+	page = list_entry(entry, struct page, lru);
 	check_spinlock_acquired_node(cachep, nodeid);
 
 	STATS_INC_NODEALLOCS(cachep);
 	STATS_INC_ACTIVE(cachep);
 	STATS_SET_HIGH(cachep);
 
-	BUG_ON(slabp->active == cachep->num);
+	BUG_ON(page->active == cachep->num);
 
-	obj = slab_get_obj(cachep, slabp, nodeid);
+	obj = slab_get_obj(cachep, page, nodeid);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
-	list_del(&slabp->list);
+	list_del(&page->lru);
 
-	if (slabp->active == cachep->num)
-		list_add(&slabp->list, &n->slabs_full);
+	if (page->active == cachep->num)
+		list_add(&page->lru, &n->slabs_full);
 	else
-		list_add(&slabp->list, &n->slabs_partial);
+		list_add(&page->lru, &n->slabs_partial);
 
 	spin_unlock(&n->list_lock);
 	goto done;
@@ -3362,21 +3341,21 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
-		struct slab *slabp;
+		struct page *page;
 
 		clear_obj_pfmemalloc(&objpp[i]);
 		objp = objpp[i];
 
-		slabp = virt_to_slab(objp);
+		page = virt_to_head_page(objp);
 		n = cachep->node[node];
-		list_del(&slabp->list);
+		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
-		slab_put_obj(cachep, slabp, objp, node);
+		slab_put_obj(cachep, page, objp, node);
 		STATS_DEC_ACTIVE(cachep);
 		n->free_objects++;
 
 		/* fixup slab chains */
-		if (slabp->active == 0) {
+		if (page->active == 0) {
 			if (n->free_objects > n->free_limit) {
 				n->free_objects -= cachep->num;
 				/* No need to drop any previously held
@@ -3385,16 +3364,16 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 				 * a different cache, refer to comments before
 				 * alloc_slabmgmt.
 				 */
-				slab_destroy(cachep, slabp);
+				slab_destroy(cachep, page);
 			} else {
-				list_add(&slabp->list, &n->slabs_free);
+				list_add(&page->lru, &n->slabs_free);
 			}
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
-			list_add_tail(&slabp->list, &n->slabs_partial);
+			list_add_tail(&page->lru, &n->slabs_partial);
 		}
 	}
 }
@@ -3434,10 +3413,10 @@ free_done:
 
 		p = n->slabs_free.next;
 		while (p != &(n->slabs_free)) {
-			struct slab *slabp;
+			struct page *page;
 
-			slabp = list_entry(p, struct slab, list);
-			BUG_ON(slabp->active);
+			page = list_entry(p, struct page, lru);
+			BUG_ON(page->active);
 
 			i++;
 			p = p->next;
@@ -4030,7 +4009,7 @@ out:
 #ifdef CONFIG_SLABINFO
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 {
-	struct slab *slabp;
+	struct page *page;
 	unsigned long active_objs;
 	unsigned long num_objs;
 	unsigned long active_slabs = 0;
@@ -4050,22 +4029,22 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(slabp, &n->slabs_full, list) {
-			if (slabp->active != cachep->num && !error)
+		list_for_each_entry(page, &n->slabs_full, lru) {
+			if (page->active != cachep->num && !error)
 				error = "slabs_full accounting error";
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &n->slabs_partial, list) {
-			if (slabp->active == cachep->num && !error)
+		list_for_each_entry(page, &n->slabs_partial, lru) {
+			if (page->active == cachep->num && !error)
 				error = "slabs_partial accounting error";
-			if (!slabp->active && !error)
+			if (!page->active && !error)
 				error = "slabs_partial accounting error";
-			active_objs += slabp->active;
+			active_objs += page->active;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &n->slabs_free, list) {
-			if (slabp->active && !error)
+		list_for_each_entry(page, &n->slabs_free, lru) {
+			if (page->active && !error)
 				error = "slabs_free accounting error";
 			num_slabs++;
 		}
@@ -4218,19 +4197,20 @@ static inline int add_caller(unsigned long *n, unsigned long v)
 	return 1;
 }
 
-static void handle_slab(unsigned long *n, struct kmem_cache *c, struct slab *s)
+static void handle_slab(unsigned long *n, struct kmem_cache *c,
+						struct page *page)
 {
 	void *p;
 	int i, j;
 
 	if (n[0] == n[1])
 		return;
-	for (i = 0, p = s->s_mem; i < c->num; i++, p += c->size) {
+	for (i = 0, p = page->s_mem; i < c->num; i++, p += c->size) {
 		bool active = true;
 
-		for (j = s->active; j < c->num; j++) {
+		for (j = page->active; j < c->num; j++) {
 			/* Skip freed item */
-			if (slab_bufctl(s)[j] == i) {
+			if (slab_bufctl(page)[j] == i) {
 				active = false;
 				break;
 			}
@@ -4262,7 +4242,7 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 static int leaks_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
-	struct slab *slabp;
+	struct page *page;
 	struct kmem_cache_node *n;
 	const char *name;
 	unsigned long *x = m->private;
@@ -4286,10 +4266,10 @@ static int leaks_show(struct seq_file *m, void *p)
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(slabp, &n->slabs_full, list)
-			handle_slab(x, cachep, slabp);
-		list_for_each_entry(slabp, &n->slabs_partial, list)
-			handle_slab(x, cachep, slabp);
+		list_for_each_entry(page, &n->slabs_full, lru)
+			handle_slab(x, cachep, page);
+		list_for_each_entry(page, &n->slabs_partial, lru)
+			handle_slab(x, cachep, page);
 		spin_unlock_irq(&n->list_lock);
 	}
 	name = cachep->name;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
