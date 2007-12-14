Message-Id: <20071214154439.489413000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Date: Fri, 14 Dec 2007 16:39:11 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/29] mm: kmem_estimate_pages()
Content-Disposition: inline; filename=mm-kmem_estimate_pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Provide a method to get the upper bound on the pages needed to allocate
a given number of objects from a given kmem_cache.

This lays the foundation for a generic reserve framework as presented in
a later patch in this series. This framework needs to convert object demand
(kmalloc() bytes, kmem_cache_alloc() objects) to pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slab.h |    3 +
 mm/slab.c            |   74 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c            |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 159 insertions(+)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -60,6 +60,7 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+unsigned kmem_estimate_pages(struct kmem_cache *cachep, gfp_t flags, int objects);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -94,6 +95,8 @@ int kmem_ptr_validate(struct kmem_cache 
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 size_t ksize(const void *);
+unsigned kestimate_single(size_t, gfp_t, int);
+unsigned kestimate(gfp_t, size_t);
 
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -2446,6 +2446,37 @@ const char *kmem_cache_name(struct kmem_
 EXPORT_SYMBOL(kmem_cache_name);
 
 /*
+ * return the max number of pages required to allocated count
+ * objects from the given cache
+ */
+unsigned kmem_estimate_pages(struct kmem_cache *s, gfp_t flags, int objects)
+{
+	unsigned long slabs;
+
+	if (WARN_ON(!s) || WARN_ON(!s->objects))
+		return 0;
+
+	slabs = DIV_ROUND_UP(objects, s->objects);
+
+	/*
+	 * Account the possible additional overhead if the slab holds more that
+	 * one object.
+	 */
+	if (s->objects > 1) {
+		/*
+		 * Account the possible additional overhead if per cpu slabs
+		 * are currently empty and have to be allocated. This is very
+		 * unlikely but a possible scenario immediately after
+		 * kmem_cache_shrink.
+		 */
+		slabs += num_online_cpus();
+	}
+
+	return slabs << s->order;
+}
+EXPORT_SYMBOL_GPL(kmem_estimate_pages);
+
+/*
  * Attempt to free all slabs on a node. Return the number of slabs we
  * were unable to free.
  */
@@ -2800,6 +2831,57 @@ static unsigned long count_partial(struc
 }
 
 /*
+ * return the max number of pages required to allocate @count objects
+ * of @size bytes from kmalloc given @flags.
+ */
+unsigned kestimate_single(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = get_slab(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_estimate_pages(s, flags, count);
+
+}
+EXPORT_SYMBOL_GPL(kestimate_single);
+
+/*
+ * return the max number of pages required to allocate @bytes from kmalloc
+ * in an unspecified number of allocation of heterogeneous size.
+ */
+unsigned kestimate(gfp_t flags, size_t bytes)
+{
+	int i;
+	unsigned long pages;
+
+	/*
+	 * multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * add the kmem_cache overhead of each possible kmalloc cache
+	 */
+	for (i = 1; i < PAGE_SHIFT; i++) {
+		struct kmem_cache *s;
+
+#ifdef CONFIG_ZONE_DMA
+		if (unlikely(flags & SLUB_DMA))
+			s = dma_kmalloc_cache(i, flags);
+		else
+#endif
+			s = &kmalloc_caches[i];
+
+		if (s)
+			pages += kmem_estimate_pages(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kestimate);
+
+/*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
  * most items in use come first. New allocations will then fill those up
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -3844,6 +3844,80 @@ const char *kmem_cache_name(struct kmem_
 EXPORT_SYMBOL_GPL(kmem_cache_name);
 
 /*
+ * return the max number of pages required to allocated count
+ * objects from the given cache
+ */
+unsigned kmem_estimate_pages(struct kmem_cache *cachep, gfp_t flags, int objects)
+{
+	/*
+	 * (1) memory for objects,
+	 */
+	unsigned nr_slabs = DIV_ROUND_UP(objects, cachep->num);
+	unsigned nr_pages = nr_slabs << cachep->gfporder;
+
+	/*
+	 * (2) memory for each per-cpu queue (nr_cpu_ids),
+	 * (3) memory for each per-node alien queues (nr_cpu_ids), and
+	 * (4) some amount of memory for the slab management structures
+	 *
+	 * XXX: truely account these
+	 */
+	nr_pages += 1 + ilog2(nr_pages);
+
+	return nr_pages;
+}
+
+/*
+ * return the max number of pages required to allocate @count objects
+ * of @size bytes from kmalloc given @flags.
+ */
+unsigned kestimate_single(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = kmem_find_general_cachep(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_estimate_pages(s, flags, count);
+}
+EXPORT_SYMBOL_GPL(kestimate_single);
+
+/*
+ * return the max number of pages required to allocate @bytes from kmalloc
+ * in an unspecified number of allocation of heterogeneous size.
+ */
+unsigned kestimate(gfp_t flags, size_t bytes)
+{
+	unsigned long pages;
+	struct cache_sizes *csizep = malloc_sizes;
+
+	/*
+	 * multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * add the kmem_cache overhead of each possible kmalloc cache
+	 */
+	for (csizep = malloc_sizes; csizep->cs_cachep; csizep++) {
+		struct kmem_cache *s;
+
+#ifdef CONFIG_ZONE_DMA
+		if (unlikely(flags & __GFP_DMA))
+			s = csizep->cs_dmacachep;
+		else
+#endif
+			s = csizep->cs_cachep;
+
+		if (s)
+			pages += kmem_estimate_pages(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kestimate);
+
+/*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
