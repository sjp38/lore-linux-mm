Message-Id: <20070806103658.990602000@chello.nl>
References: <20070806102922.907530000@chello.nl>
Date: Mon, 06 Aug 2007 12:29:28 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/10] mm: kmem_estimate_pages()
Content-Disposition: inline; filename=mm-kmem_estimate_pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Provide a method to get the upper bound on the pages needed to allocate
a given number of objects from a given kmem_cache.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h |    3 +
 mm/slub.c            |   90 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 93 insertions(+)

Index: linux-2.6-2/include/linux/slab.h
===================================================================
--- linux-2.6-2.orig/include/linux/slab.h
+++ linux-2.6-2/include/linux/slab.h
@@ -58,6 +58,7 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+unsigned kmem_estimate_pages(struct kmem_cache *cachep, gfp_t flags, int objects);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -92,6 +93,8 @@ int kmem_ptr_validate(struct kmem_cache 
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 size_t ksize(const void *);
+unsigned kestimate_single(size_t, gfp_t, int);
+unsigned kestimate(gfp_t, size_t);
 
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
Index: linux-2.6-2/mm/slub.c
===================================================================
--- linux-2.6-2.orig/mm/slub.c
+++ linux-2.6-2/mm/slub.c
@@ -2206,6 +2206,45 @@ const char *kmem_cache_name(struct kmem_
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
+		if (!(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS)) {
+			/*
+			 * Account the possible additional overhead if per cpu
+			 * slabs are currently empty and have to be allocated.
+			 * This is very unlikely but a possible scenario
+			 * immediately after kmem_cache_shrink.
+			 */
+			slabs += num_online_cpus();
+		} else {
+			/*
+			 * when using the reserves there will be only a single
+			 * slab per kmem_cache.
+			 */
+			slabs += 1;
+		}
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
@@ -2508,6 +2547,57 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
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
+	for (i = 1; i < KMALLOC_SHIFT_HIGH; i++) {
+		struct kmem_cache *s;
+
+#ifdef CONFIG_ZONE_DMA
+		if (unlikely(flags & SLUB_DMA))
+			s = &dma_kmalloc_cache(i, flags);
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

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
