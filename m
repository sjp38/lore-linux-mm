Date: Fri, 15 Jun 2007 12:34:12 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] slob: poor man's NUMA, take 5.
Message-ID: <20070615033412.GA28687@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Updated version of the SLOB NUMA support.

This version adds in a slob_def.h and reorders a bit of the slab.h
definitions. This should take in to account all of the outstanding
comments so far on the earlier versions.

Tested on all of SLOB/SLUB/SLAB with and without CONFIG_NUMA.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 include/linux/slab.h     |   85 ++++-------------------------------------------
 include/linux/slab_def.h |    4 ++
 include/linux/slob_def.h |   83 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/slub_def.h |    6 ++-
 mm/slob.c                |   51 ++++++++++++++++++++--------
 5 files changed, 137 insertions(+), 92 deletions(-)


diff --git a/include/linux/slab.h b/include/linux/slab.h
index a015236..09a05e4 100644
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
@@ -63,9 +62,9 @@ int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL, NULL)
 
-#ifdef CONFIG_NUMA
-extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-#else
+#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+
 static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 					gfp_t flags, int node)
 {
@@ -91,7 +90,6 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
 /*
  * Common kmalloc functions provided by all allocators
  */
-void *__kmalloc(size_t, gfp_t);
 void *__kzalloc(size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
@@ -112,85 +110,19 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
 
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
- * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by selecting
- * the appropriate general cache at compile time.
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
  */
 
-#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 #ifdef CONFIG_SLUB
 #include <linux/slub_def.h>
+#elif defined(CONFIG_SLOB)
+#include <linux/slob_def.h>
 #else
 #include <linux/slab_def.h>
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
- *
- * The @flags argument may be one of:
- *
- * %GFP_USER - Allocate memory on behalf of user.  May sleep.
- *
- * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
- *
- * %GFP_ATOMIC - Allocation will not sleep.
- *   For example, use this inside interrupt handlers.
- *
- * %GFP_HIGHUSER - Allocate pages from high memory.
- *
- * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
- *
- * %GFP_NOFS - Do not make any fs calls while trying to get memory.
- *
- * Also it is possible to set different flags by OR'ing
- * in one or more of the following additional @flags:
- *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
- * %__GFP_DMA - Request memory from the DMA-capable zone.
- *
- * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
- *
- * %__GFP_HIGHMEM - Allocated memory may be from highmem.
- *
- * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
- *   (think twice before using).
- *
- * %__GFP_NORETRY - If memory is not immediately available,
- *   then give up at once.
- *
- * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
- *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
- */
-static inline void *kmalloc(size_t size, gfp_t flags)
-{
-	return __kmalloc(size, flags);
-}
-
-/**
- * kzalloc - allocate memory. The memory is set to zero.
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kmalloc).
- */
-static inline void *kzalloc(size_t size, gfp_t flags)
-{
-	return __kzalloc(size, flags);
-}
 #endif
 
-#ifndef CONFIG_NUMA
+#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return kmalloc(size, flags);
@@ -247,4 +179,3 @@ extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
 
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
index 0000000..042fc56
--- /dev/null
+++ b/include/linux/slob_def.h
@@ -0,0 +1,83 @@
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
+static inline void *__kmalloc(size_t size, gfp_t flags)
+{
+	return __kmalloc_node(size, flags, -1);
+}
+
+/**
+ * kmalloc - allocate memory
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * kmalloc is the normal method of allocating memory
+ * in the kernel.
+ *
+ * The @flags argument may be one of:
+ *
+ * %GFP_USER - Allocate memory on behalf of user.  May sleep.
+ *
+ * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
+ *
+ * %GFP_ATOMIC - Allocation will not sleep.
+ *   For example, use this inside interrupt handlers.
+ *
+ * %GFP_HIGHUSER - Allocate pages from high memory.
+ *
+ * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
+ *
+ * %GFP_NOFS - Do not make any fs calls while trying to get memory.
+ *
+ * Also it is possible to set different flags by OR'ing
+ * in one or more of the following additional @flags:
+ *
+ * %__GFP_COLD - Request cache-cold pages instead of
+ *   trying to return cache-warm pages.
+ *
+ * %__GFP_DMA - Request memory from the DMA-capable zone.
+ *
+ * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
+ *
+ * %__GFP_HIGHMEM - Allocated memory may be from highmem.
+ *
+ * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
+ *   (think twice before using).
+ *
+ * %__GFP_NORETRY - If memory is not immediately available,
+ *   then give up at once.
+ *
+ * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
+ *
+ * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ */
+static inline void *kmalloc(size_t size, gfp_t flags)
+{
+	return __kmalloc(size, flags);
+}
+
+/**
+ * kzalloc - allocate memory. The memory is set to zero.
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kmalloc).
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
index 06e5e72..b08eca4 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -204,6 +204,23 @@ static int slob_last(slob_t *s)
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
@@ -258,7 +275,7 @@ static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
 	struct slob_page *sp;
 	slob_t *b = NULL;
@@ -267,6 +284,15 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
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
@@ -277,7 +303,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align)
 
 	/* Not enough space: must allocate a new page */
 	if (!b) {
-		b = (slob_t *)__get_free_page(gfp);
+		b = slob_new_page(gfp, 0, node);
 		if (!b)
 			return 0;
 		sp = (struct slob_page *)virt_to_page(b);
@@ -381,22 +407,20 @@ out:
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
@@ -405,7 +429,7 @@ void *__kmalloc(size_t size, gfp_t gfp)
 		return ret;
 	}
 }
-EXPORT_SYMBOL(__kmalloc);
+EXPORT_SYMBOL(__kmalloc_node);
 
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
@@ -455,7 +479,6 @@ void kfree(const void *block)
 	} else
 		put_page(&sp->page);
 }
-
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
@@ -487,7 +510,7 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *c;
 
-	c = slob_alloc(sizeof(struct kmem_cache), flags, 0);
+	c = slob_alloc(sizeof(struct kmem_cache), flags, 0, -1);
 
 	if (c) {
 		c->name = name;
@@ -517,21 +540,21 @@ void kmem_cache_destroy(struct kmem_cache *c)
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
