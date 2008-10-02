Message-Id: <20081002131608.162932309@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:13 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/32] mm: kmem_alloc_estimate()
Content-Disposition: inline; filename=mm-kmem_estimate_pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Provide a method to get the upper bound on the pages needed to allocate
a given number of objects from a given kmem_cache.

This lays the foundation for a generic reserve framework as presented in
a later patch in this series. This framework needs to convert object demand
(kmalloc() bytes, kmem_cache_alloc() objects) to pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slab.h |    4 ++
 mm/slab.c            |   75 +++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c            |   67 +++++++++++++++++++++++++++++++++++++++
 mm/slub.c            |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 233 insertions(+)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -72,6 +72,8 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+unsigned kmem_alloc_estimate(struct kmem_cache *cachep,
+			gfp_t flags, int objects);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -107,6 +109,8 @@ void * __must_check __krealloc(const voi
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 size_t ksize(const void *);
+unsigned kmalloc_estimate_objs(size_t, gfp_t, int);
+unsigned kmalloc_estimate_bytes(gfp_t, size_t);
 
 /*
  * Function prototypes passed to kmem_cache_defrag() to enable defragmentation
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -2452,6 +2452,42 @@ const char *kmem_cache_name(struct kmem_
 }
 EXPORT_SYMBOL(kmem_cache_name);
 
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ *
+ * We should use s->min_objects because those are the least efficient.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *s, gfp_t flags, int objects)
+{
+	unsigned long pages;
+	struct kmem_cache_order_objects x;
+
+	if (WARN_ON(!s) || WARN_ON(!oo_objects(s->min)))
+		return 0;
+
+	x = s->min;
+	pages = DIV_ROUND_UP(objects, oo_objects(x)) << oo_order(x);
+
+	/*
+	 * Account the possible additional overhead if the slab holds more that
+	 * one object. Use s->max_objects because that's the worst case.
+	 */
+	x = s->oo;
+	if (oo_objects(x) > 1) {
+		/*
+		 * Account the possible additional overhead if per cpu slabs
+		 * are currently empty and have to be allocated. This is very
+		 * unlikely but a possible scenario immediately after
+		 * kmem_cache_shrink.
+		 */
+		pages += num_possible_cpus() << oo_order(x);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmem_alloc_estimate);
+
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
@@ -2852,6 +2888,57 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
 /*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = get_slab(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_alloc_estimate(s, flags, count);
+
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
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
+			pages += kmem_alloc_estimate(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);
+
+/*
  * Allocate a slab scratch space that is sufficient to keep at least
  * max_defrag_slab_objects pointers to individual objects and also a bitmap
  * for max_defrag_slab_objects.
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -3849,6 +3849,81 @@ const char *kmem_cache_name(struct kmem_
 EXPORT_SYMBOL_GPL(kmem_cache_name);
 
 /*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *cachep,
+		gfp_t flags, int objects)
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
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = kmem_find_general_cachep(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_alloc_estimate(s, flags, count);
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
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
+			pages += kmem_alloc_estimate(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);
+
+/*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep)
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -682,3 +682,70 @@ void __init kmem_cache_init(void)
 {
 	slob_ready = 1;
 }
+
+static __slob_estimate(unsigned size, unsigned align, unsigned objects)
+{
+	unsigned nr_pages;
+
+	size = SLOB_UNIT * SLOB_UNITS(size + align - 1);
+
+	if (size <= PAGE_SIZE) {
+		nr_pages = DIV_ROUND_UP(objects, PAGE_SIZE / size);
+	} else {
+		nr_pages = objects << get_order(size);
+	}
+
+	return nr_pages;
+}
+
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *c, gfp_t flags, int objects)
+{
+	unsigned size = c->size;
+
+	if (c->flags & SLAB_DESTROY_BY_RCU)
+		size += sizeof(struct slob_rcu);
+
+	return __slob_estimate(size, c->align, objects);
+}
+
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	unsigned align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+
+	return __slob_estimate(size, align, count);
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
+{
+	unsigned long pages;
+
+	/*
+	 * Multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 *
+	 * While not true for slob, it cannot do worse than that for sequential
+	 * allocations.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * Our power of two series starts at PAGE_SIZE, so add one page.
+	 */
+	pages++;
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
