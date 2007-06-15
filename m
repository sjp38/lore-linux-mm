Date: Fri, 15 Jun 2007 17:22:37 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
Message-ID: <20070615082237.GA29917@linux-sh.org>
References: <20070615033412.GA28687@linux-sh.org> <20070615064445.GM11115@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070615064445.GM11115@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 15, 2007 at 01:44:45AM -0500, Matt Mackall wrote:
> On Fri, Jun 15, 2007 at 12:34:12PM +0900, Paul Mundt wrote:
> > Updated version of the SLOB NUMA support.
> > 
> > This version adds in a slob_def.h and reorders a bit of the slab.h
> > definitions. This should take in to account all of the outstanding
> > comments so far on the earlier versions.
> > 
> > Tested on all of SLOB/SLUB/SLAB with and without CONFIG_NUMA.
> > 
> > Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> 
> This is looking good. I concur with Christoph's comment comment.
> 
Ok, here's an updated copy. I've tried to tidy up the comments a bit, as
well as document some of the bits that were missing or that weren't
entirely obvious. Hopefully this addresses Christoph's concerns. slab.h
is at least a bit cleaner now.

I'll resubmit as a final patch once everyone is happy with it. 

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h     |  128 +++++++++++++++++++++++------------------------
 include/linux/slab_def.h |    4 +
 include/linux/slob_def.h |   46 ++++++++++++++++
 include/linux/slub_def.h |    6 +-
 mm/slob.c                |   72 ++++++++++++++++++++------
 5 files changed, 174 insertions(+), 82 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a015236..df1183c 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -44,7 +44,6 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *, struct kmem_cache *, unsigned long));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
@@ -63,16 +62,6 @@ int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL, NULL)
 
-#ifdef CONFIG_NUMA
-extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-#else
-static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
-					gfp_t flags, int node)
-{
-	return kmem_cache_alloc(cachep, flags);
-}
-#endif
-
 /*
  * The largest kmalloc size supported by the slab allocators is
  * 32 megabyte (2^25) or the maximum allocatable page order if that is
@@ -91,7 +80,6 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 /*
  * Common kmalloc functions provided by all allocators
  */
-void *__kmalloc(size_t, gfp_t);
 void *__kzalloc(size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
@@ -102,40 +90,6 @@ size_t ksize(const void *);
  * @n: number of elements.
  * @size: element size.
  * @flags: the type of memory to allocate.
- */
-static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
-{
-	if (n != 0 && size > ULONG_MAX / n)
-		return NULL;
-	return __kzalloc(n * size, flags);
-}
-
-/*
- * Allocator specific definitions. These are mainly used to establish optimized
- * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by selecting
- * the appropriate general cache at compile time.
- */
-
-#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
-#ifdef CONFIG_SLUB
-#include <linux/slub_def.h>
-#else
-#include <linux/slab_def.h>
-#endif /* !CONFIG_SLUB */
-#else
-
-/*
- * Fallback definitions for an allocator not wanting to provide
- * its own optimized kmalloc definitions (like SLOB).
- */
-
-/**
- * kmalloc - allocate memory
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * kmalloc is the normal method of allocating memory
- * in the kernel.
  *
  * The @flags argument may be one of:
  *
@@ -143,7 +97,7 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
  *
  * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
  *
- * %GFP_ATOMIC - Allocation will not sleep.
+ * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
  *   For example, use this inside interrupt handlers.
  *
  * %GFP_HIGHUSER - Allocate pages from high memory.
@@ -152,18 +106,22 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
  *
  * %GFP_NOFS - Do not make any fs calls while trying to get memory.
  *
+ * %GFP_NOWAIT - Allocation will not sleep.
+ *
+ * %GFP_THISNODE - Allocate node-local memory only.
+ *
+ * %GFP_DMA - Allocation suitable for DMA.
+ *
+ * %GFP_DMA32 - Large allocation suitable for DMA (depending on platform).
+ *
  * Also it is possible to set different flags by OR'ing
  * in one or more of the following additional @flags:
  *
  * %__GFP_COLD - Request cache-cold pages instead of
  *   trying to return cache-warm pages.
  *
- * %__GFP_DMA - Request memory from the DMA-capable zone.
- *
  * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
  *
- * %__GFP_HIGHMEM - Allocated memory may be from highmem.
- *
  * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
  *   (think twice before using).
  *
@@ -173,24 +131,59 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
  * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
  *
  * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ *
+ * %__GFP_ZERO - Zero the allocation on success.
+ *
+ * There are other flags available as well, but these are not intended
+ * for general use, and so are not documented here. For a full list of
+ * potential flags, always refer to linux/gfp.h.
  */
-static inline void *kmalloc(size_t size, gfp_t flags)
+static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
 {
-	return __kmalloc(size, flags);
+	if (n != 0 && size > ULONG_MAX / n)
+		return NULL;
+	return __kzalloc(n * size, flags);
 }
 
-/**
- * kzalloc - allocate memory. The memory is set to zero.
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kmalloc).
+/*
+ * Allocator specific definitions. These are mainly used to establish optimized
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
+ *
+ * Allocators must define at least:
+ *
+ *	kmem_cache_alloc()
+ *	__kmalloc()
+ *	kmalloc()
+ *	kzalloc()
+ *
+ * Those wishing to support NUMA must also define:
+ *
+ *	kmem_cache_alloc_node()
+ *	kmalloc_node()
+ *
+ * See each allocator definition file for additional comments and
+ * implementation notes.
  */
-static inline void *kzalloc(size_t size, gfp_t flags)
-{
-	return __kzalloc(size, flags);
-}
+#ifdef CONFIG_SLUB
+#include <linux/slub_def.h>
+#elif defined(CONFIG_SLOB)
+#include <linux/slob_def.h>
+#else
+#include <linux/slab_def.h>
 #endif
 
-#ifndef CONFIG_NUMA
+#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
+/**
+ * kmalloc_node - allocate memory from a specific node
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kcalloc).
+ * @node: node to allocate from.
+ *
+ * kmalloc() for non-local nodes, used to allocate from a specific node
+ * if available. Equivalent to kmalloc() in the non-NUMA single-node
+ * case.
+ */
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return kmalloc(size, flags);
@@ -200,7 +193,15 @@ static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return __kmalloc(size, flags);
 }
-#endif /* !CONFIG_NUMA */
+
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+
+static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
+					gfp_t flags, int node)
+{
+	return kmem_cache_alloc(cachep, flags);
+}
+#endif /* !CONFIG_NUMA && !CONFIG_SLOB */
 
 /*
  * kmalloc_track_caller is a special version of kmalloc that records the
@@ -247,4 +248,3 @@ extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
 
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SLAB_H */
-
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 8d81a60..365d036 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -25,6 +25,9 @@ struct cache_sizes {
 };
 extern struct cache_sizes malloc_sizes[];
 
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+void *__kmalloc(size_t size, gfp_t flags);
+
 static inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
@@ -79,6 +82,7 @@ found:
 
 #ifdef CONFIG_NUMA
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
new file mode 100644
index 0000000..a2daf2d
--- /dev/null
+++ b/include/linux/slob_def.h
@@ -0,0 +1,46 @@
+#ifndef __LINUX_SLOB_DEF_H
+#define __LINUX_SLOB_DEF_H
+
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+
+static inline void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	return kmem_cache_alloc_node(cachep, flags, -1);
+}
+
+void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc_node(size, flags, node);
+}
+
+/**
+ * kmalloc - allocate memory
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kcalloc).
+ *
+ * kmalloc is the normal method of allocating memory
+ * in the kernel.
+ */
+static inline void *kmalloc(size_t size, gfp_t flags)
+{
+	return __kmalloc_node(size, flags, -1);
+}
+
+static inline void *__kmalloc(size_t size, gfp_t flags)
+{
+	return kmalloc(size, flags);
+}
+
+/**
+ * kzalloc - allocate memory. The memory is set to zero.
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kcalloc).
+ */
+static inline void *kzalloc(size_t size, gfp_t flags)
+{
+	return __kzalloc(size, flags);
+}
+
+#endif /* __LINUX_SLOB_DEF_H */
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 0764c82..5b68505 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -153,6 +153,9 @@ static inline struct kmem_cache *kmalloc_slab(size_t size)
 #define SLUB_DMA 0
 #endif
 
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+void *__kmalloc(size_t size, gfp_t flags);
+
 static inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
@@ -180,7 +183,8 @@ static inline void *kzalloc(size_t size, gfp_t flags)
 }
 
 #ifdef CONFIG_NUMA
-extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
diff --git a/mm/slob.c b/mm/slob.c
index 06e5e72..b99b0ef 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -3,6 +3,8 @@
  *
  * Matt Mackall <mpm@selenic.com> 12/30/03
  *
+ * NUMA support by Paul Mundt, 2007.
+ *
  * How SLOB works:
  *
  * The core of SLOB is a traditional K&R style heap allocator, with
@@ -10,7 +12,7 @@
  * allocator is as little as 2 bytes, however typically most architectures
  * will require 4 bytes on 32-bit and 8 bytes on 64-bit.
  *
- * The slob heap is a linked list of pages from __get_free_page, and
+ * The slob heap is a linked list of pages from alloc_pages(), and
  * within each page, there is a singly-linked list of free blocks (slob_t).
  * The heap is grown on demand and allocation from the heap is currently
  * first-fit.
@@ -18,7 +20,7 @@
  * Above this is an implementation of kmalloc/kfree. Blocks returned
  * from kmalloc are prepended with a 4-byte header with the kmalloc size.
  * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
- * __get_free_pages directly, allocating compound pages so the page order
+ * alloc_pages() directly, allocating compound pages so the page order
  * does not have to be separately tracked, and also stores the exact
  * allocation size in page->private so that it can be used to accurately
  * provide ksize(). These objects are detected in kfree() because slob_page()
@@ -29,10 +31,23 @@
  * 4-byte alignment unless the SLAB_HWCACHE_ALIGN flag is set, in which
  * case the low-level allocator will fragment blocks to create the proper
  * alignment. Again, objects of page-size or greater are allocated by
- * calling __get_free_pages. As SLAB objects know their size, no separate
+ * calling alloc_pages(). As SLAB objects know their size, no separate
  * size bookkeeping is necessary and there is essentially no allocation
  * space overhead, and compound pages aren't needed for multi-page
  * allocations.
+ *
+ * NUMA support in SLOB is fairly simplistic, pushing most of the real
+ * logic down to the page allocator, and simply doing the node accounting
+ * on the upper levels. In the event that a node id is explicitly
+ * provided, alloc_pages_node() with the specified node id is used
+ * instead. The common case (or when the node id isn't explicitly provided)
+ * will default to the current node, as per numa_node_id().
+ *
+ * Node aware pages are still inserted in to the global freelist, and
+ * these are scanned for by matching against the node id encoded in the
+ * page flags. As a result, block allocations that can be satisfied from
+ * the freelist will only be done so on pages residing on the same node,
+ * in order to prevent random node placement.
  */
 
 #include <linux/kernel.h>
@@ -204,6 +219,23 @@ static int slob_last(slob_t *s)
 	return !((unsigned long)slob_next(s) & ~PAGE_MASK);
 }
 
+static void *slob_new_page(gfp_t gfp, int order, int node)
+{
+	void *page;
+
+#ifdef CONFIG_NUMA
+	if (node != -1)
+		page = alloc_pages_node(node, gfp, order);
+	else
+#endif
+		page = alloc_pages(gfp, order);
+
+	if (!page)
+		return NULL;
+
+	return page_address(page);
+}
+
 /*
  * Allocate a slob block within a given slob_page sp.
  */
@@ -258,7 +290,7 @@ static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
 	struct slob_page *sp;
 	slob_t *b = NULL;
@@ -267,6 +299,15 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
 	list_for_each_entry(sp, &free_slob_pages, list) {
+#ifdef CONFIG_NUMA
+		/*
+		 * If there's a node specification, search for a partial
+		 * page with a matching node id in the freelist.
+		 */
+		if (node != -1 && page_to_nid(&sp->page) != node)
+			continue;
+#endif
+
 		if (sp->units >= SLOB_UNITS(size)) {
 			b = slob_page_alloc(sp, size, align);
 			if (b)
@@ -277,7 +318,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 
 	/* Not enough space: must allocate a new page */
 	if (!b) {
-		b = (slob_t *)__get_free_page(gfp);
+		b = slob_new_page(gfp, 0, node);
 		if (!b)
 			return 0;
 		sp = (struct slob_page *)virt_to_page(b);
@@ -381,22 +422,20 @@ out:
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long)
 #endif
 
-
-void *__kmalloc(size_t size, gfp_t gfp)
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 {
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 
 	if (size < PAGE_SIZE - align) {
 		unsigned int *m;
-		m = slob_alloc(size + align, gfp, align);
+		m = slob_alloc(size + align, gfp, align, node);
 		if (m)
 			*m = size;
 		return (void *)m + align;
 	} else {
 		void *ret;
 
-		ret = (void *) __get_free_pages(gfp | __GFP_COMP,
-						get_order(size));
+		ret = slob_new_page(gfp | __GFP_COMP, get_order(size), node);
 		if (ret) {
 			struct page *page;
 			page = virt_to_page(ret);
@@ -405,7 +444,7 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return ret;
 	}
 }
-EXPORT_SYMBOL(__kmalloc);
+EXPORT_SYMBOL(__kmalloc_node);
 
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
@@ -455,7 +494,6 @@ void kfree(const void *block)
 	} else
 		put_page(&sp->page);
 }
-
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
@@ -487,7 +525,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -517,21 +555,21 @@ void kmem_cache_destroy(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
+void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
 	if (c->size < PAGE_SIZE)
-		b = slob_alloc(c->size, flags, c->align);
+		b = slob_alloc(c->size, flags, c->align, node);
 	else
-		b = (void *)__get_free_pages(flags, get_order(c->size));
+		b = slob_new_page(flags, get_order(c->size), node);
 
 	if (c->ctor)
 		c->ctor(b, c, 0);
 
 	return b;
 }
-EXPORT_SYMBOL(kmem_cache_alloc);
+EXPORT_SYMBOL(kmem_cache_alloc_node);
 
 void *kmem_cache_zalloc(struct kmem_cache *c, gfp_t flags)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
