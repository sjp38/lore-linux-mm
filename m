Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A9F426B006C
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:20:31 -0400 (EDT)
Message-Id: <0000013a043cda02-623c9725-157c-4cdd-aada-3dfa87ec4182-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:20:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [11/13] Common constants for kmalloc boundaries
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Standardize the constants that describe the smallest and largest
object kept in the kmalloc arrays for SLAB and SLUB.

Differentiate between the maximum size for which a slab cache is used
(KMALLOC_MAX_CACHE_SIZE) and the maximum allocatable size
(KMALLOC_MAX_SIZE, KMALLOC_MAX_ORDER).

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-09-19 09:21:54.283799310 -0500
+++ linux/include/linux/slab.h	2012-09-19 09:21:58.859894391 -0500
@@ -162,8 +162,9 @@ unsigned int kmem_cache_size(struct kmem
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
+#ifdef CONFIG_SLAB
 /*
- * The largest kmalloc size supported by the slab allocators is
+ * The largest kmalloc size supported by the SLAB allocators is
  * 32 megabyte (2^25) or the maximum allocatable page order if that is
  * less than 32 MB.
  *
@@ -173,9 +174,24 @@ unsigned int kmem_cache_size(struct kmem
  */
 #define KMALLOC_SHIFT_HIGH	((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
 				(MAX_ORDER + PAGE_SHIFT - 1) : 25)
+#define KMALLOC_SHIFT_MAX	KMALLOC_SHIFT_HIGH
+#define KMALLOC_SHIFT_LOW	5
+#else
+/*
+ * SLUB allocates up to order 2 pages directly and otherwise
+ * passes the request to the page allocator.
+ */
+#define KMALLOC_SHIFT_HIGH	(PAGE_SHIFT + 1)
+#define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT)
+#define KMALLOC_SHIFT_LOW	3
+#endif
 
-#define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
-#define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)
+/* Maximum allocatable size */
+#define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
+/* Maximum size for which we actually use a slab cache */
+#define KMALLOC_MAX_CACHE_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
+/* Maximum order allocatable via the slab allocagtor */
+#define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_MAX - PAGE_SHIFT)
 
 /*
  * Kmalloc subsystem.
@@ -184,14 +200,8 @@ unsigned int kmem_cache_size(struct kmem
 #if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
 #define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
 #else
-#ifdef CONFIG_SLAB
-#define KMALLOC_MIN_SIZE 32
-#else
-#define KMALLOC_MIN_SIZE 8
+#define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif
-#endif
-
-#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
 
 /*
  * Figure out which kmalloc slab an allocation of a certain size
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2012-09-19 09:21:27.307238804 -0500
+++ linux/include/linux/slub_def.h	2012-09-19 09:21:58.863894464 -0500
@@ -111,19 +111,6 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-/*
- * Maximum kmalloc object size handled by SLUB. Larger object allocations
- * are passed through to the page allocator. The page allocator "fastpath"
- * is relatively slow so we need this value sufficiently high so that
- * performance critical objects are allocated through the SLUB fastpath.
- *
- * This should be dropped to PAGE_SIZE / 2 once the page allocator
- * "fastpath" becomes competitive with the slab allocator fastpaths.
- */
-#define SLUB_MAX_SIZE (2 * PAGE_SIZE)
-
-#define SLUB_PAGE_SHIFT (PAGE_SHIFT + 2)
-
 #ifdef CONFIG_ZONE_DMA
 #define SLUB_DMA __GFP_DMA
 #else
@@ -135,7 +122,7 @@ struct kmem_cache {
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
+extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 
 /*
  * Find the slab cache for a given combination of allocation flags and size.
@@ -204,7 +191,7 @@ static __always_inline void *kmalloc_lar
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-		if (size > SLUB_MAX_SIZE)
+		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
@@ -240,7 +227,7 @@ kmem_cache_alloc_node_trace(struct kmem_
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	if (__builtin_constant_p(size) &&
-		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
+		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
 
 		if (!s)
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-19 09:21:24.239174845 -0500
+++ linux/mm/slub.c	2012-09-19 09:21:58.863894464 -0500
@@ -2777,7 +2777,7 @@ init_kmem_cache_node(struct kmem_cache_n
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 {
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
-			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
+			KMALLOC_SHIFT_HIGH * sizeof(struct kmem_cache_cpu));
 
 	/*
 	 * Must align to double word boundary for the double cmpxchg
@@ -3174,11 +3174,11 @@ int __kmem_cache_shutdown(struct kmem_ca
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
+struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 EXPORT_SYMBOL(kmalloc_caches);
 
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_dma_caches[SLUB_PAGE_SHIFT];
+static struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
 #endif
 
 static int __init setup_slub_min_order(char *str)
@@ -3280,7 +3280,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	struct kmem_cache *s;
 	void *ret;
 
-	if (unlikely(size > SLUB_MAX_SIZE))
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, flags);
 
 	s = get_slab(size, flags);
@@ -3316,7 +3316,7 @@ void *__kmalloc_node(size_t size, gfp_t
 	struct kmem_cache *s;
 	void *ret;
 
-	if (unlikely(size > SLUB_MAX_SIZE)) {
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
 		ret = kmalloc_large_node(size, flags, node);
 
 		trace_kmalloc_node(_RET_IP_, ret,
@@ -3721,7 +3721,7 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		kmalloc_caches[i] = create_kmalloc_cache("kmalloc", 1 << i, 0);
 		caches++;
 	}
@@ -3739,7 +3739,7 @@ void __init kmem_cache_init(void)
 		BUG_ON(!kmalloc_caches[2]->name);
 	}
 
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
 
 		BUG_ON(!s);
@@ -3751,7 +3751,7 @@ void __init kmem_cache_init(void)
 #endif
 
 #ifdef CONFIG_ZONE_DMA
-	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
+	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
 		struct kmem_cache *s = kmalloc_caches[i];
 
 		if (s && s->size) {
@@ -3925,7 +3925,7 @@ void *__kmalloc_track_caller(size_t size
 	struct kmem_cache *s;
 	void *ret;
 
-	if (unlikely(size > SLUB_MAX_SIZE))
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, gfpflags);
 
 	s = get_slab(size, gfpflags);
@@ -3948,7 +3948,7 @@ void *__kmalloc_node_track_caller(size_t
 	struct kmem_cache *s;
 	void *ret;
 
-	if (unlikely(size > SLUB_MAX_SIZE)) {
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
 		ret = kmalloc_large_node(size, gfpflags, node);
 
 		trace_kmalloc_node(caller, ret,
@@ -4307,7 +4307,7 @@ static void resiliency_test(void)
 {
 	u8 *p;
 
-	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || SLUB_PAGE_SHIFT < 10);
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || KMALLOC_SHIFT_HIGH < 10);
 
 	printk(KERN_ERR "SLUB resiliency testing\n");
 	printk(KERN_ERR "-----------------------\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
