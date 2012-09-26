Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 364B56B0069
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:18:15 -0400 (EDT)
Message-Id: <0000013a043aca15-00293133-8d9b-469d-afa7-b00ac0bf1015-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:18:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [07/13] slab: Use common kmalloc_index/kmalloc_size functions
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Make slab use the common functions. We can get rid of a lot
of old ugly stuff as a results. Among them the sizes
array and the weird include/linux/kmalloc_sizes file and
some pretty bad #include statements in slab_def.h.

The one thing that is different in slab is that the 32 byte
cache will also be created for arches that have page sizes
larger than 4K. There are numerous smaller allocations that
SLOB and SLUB can handle better because of their support for
smaller allocation sizes so lets keep the 32 byte slab also
for arches with > 4K pages.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-19 09:21:21.399115971 -0500
+++ linux/mm/slab.c	2012-09-19 09:21:32.531347320 -0500
@@ -291,6 +291,11 @@ static inline void clear_obj_pfmemalloc(
 	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
 }
 
+struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
+EXPORT_SYMBOL(cs_cachep);
+struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
+EXPORT_SYMBOL(cs_dmacachep);
+
 /*
  * bootstrap: The caches do not work without cpuarrays anymore, but the
  * cpuarrays are allocated from the generic caches...
@@ -334,34 +339,10 @@ static void free_block(struct kmem_cache
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
-/*
- * This function must be completely optimized away if a constant is passed to
- * it.  Mostly the same as what is in linux/slab.h except it returns an index.
- */
-static __always_inline int index_of(const size_t size)
-{
-	extern void __bad_size(void);
-
-	if (__builtin_constant_p(size)) {
-		int i = 0;
-
-#define CACHE(x) \
-	if (size <=x) \
-		return i; \
-	else \
-		i++;
-#include <linux/kmalloc_sizes.h>
-#undef CACHE
-		__bad_size();
-	} else
-		__bad_size();
-	return 0;
-}
-
 static int slab_early_init = 1;
 
-#define INDEX_AC index_of(sizeof(struct arraycache_init))
-#define INDEX_L3 index_of(sizeof(struct kmem_list3))
+#define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
+#define INDEX_L3 kmalloc_index(sizeof(struct kmem_list3))
 
 static void kmem_list3_init(struct kmem_list3 *parent)
 {
@@ -548,30 +529,6 @@ static inline unsigned int obj_to_index(
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
 }
 
-/*
- * These are the default caches for kmalloc. Custom caches can have other sizes.
- */
-struct cache_sizes malloc_sizes[] = {
-#define CACHE(x) { .cs_size = (x) },
-#include <linux/kmalloc_sizes.h>
-	CACHE(ULONG_MAX)
-#undef CACHE
-};
-EXPORT_SYMBOL(malloc_sizes);
-
-/* Must match cache_sizes above. Out of line to keep cache footprint low. */
-struct cache_names {
-	char *name;
-	char *name_dma;
-};
-
-static struct cache_names __initdata cache_names[] = {
-#define CACHE(x) { .name = "size-" #x, .name_dma = "size-" #x "(DMA)" },
-#include <linux/kmalloc_sizes.h>
-	{NULL,}
-#undef CACHE
-};
-
 static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
@@ -649,19 +606,23 @@ static void slab_set_debugobj_lock_class
 
 static void init_node_lock_keys(int q)
 {
-	struct cache_sizes *s = malloc_sizes;
+	int i;
 
 	if (slab_state < UP)
 		return;
 
-	for (s = malloc_sizes; s->cs_size != ULONG_MAX; s++) {
+	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
 		struct kmem_list3 *l3;
+		struct kmem_cache *cache = cs_cachep[i];
 
-		l3 = s->cs_cachep->nodelists[q];
-		if (!l3 || OFF_SLAB(s->cs_cachep))
+		if (!cache)
 			continue;
 
-		slab_set_lock_classes(s->cs_cachep, &on_slab_l3_key,
+		l3 = cache->nodelists[q];
+		if (!l3 || OFF_SLAB(cache))
+			continue;
+
+		slab_set_lock_classes(cache, &on_slab_l3_key,
 				&on_slab_alc_key, q);
 	}
 }
@@ -701,20 +662,19 @@ static inline struct array_cache *cpu_ca
 static inline struct kmem_cache *__find_general_cachep(size_t size,
 							gfp_t gfpflags)
 {
-	struct cache_sizes *csizep = malloc_sizes;
+	int i;
 
 #if DEBUG
 	/* This happens if someone tries to call
 	 * kmem_cache_create(), or __kmalloc(), before
 	 * the generic caches are initialized.
 	 */
-	BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
+	BUG_ON(cs_cachep[INDEX_AC] == NULL);
 #endif
 	if (!size)
 		return ZERO_SIZE_PTR;
 
-	while (size > csizep->cs_size)
-		csizep++;
+	i = kmalloc_index(size);
 
 	/*
 	 * Really subtle: The last entry with cs->cs_size==ULONG_MAX
@@ -723,9 +683,9 @@ static inline struct kmem_cache *__find_
 	 */
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely(gfpflags & GFP_DMA))
-		return csizep->cs_dmacachep;
+		return cs_dmacachep[i];
 #endif
-	return csizep->cs_cachep;
+	return cs_cachep[i];
 }
 
 static struct kmem_cache *kmem_find_general_cachep(size_t size, gfp_t gfpflags)
@@ -1594,8 +1554,6 @@ static void setup_nodelists_pointer(stru
  */
 void __init kmem_cache_init(void)
 {
-	struct cache_sizes *sizes;
-	struct cache_names *names;
 	int i;
 
 	kmem_cache = &kmem_cache_boot;
@@ -1653,8 +1611,6 @@ void __init kmem_cache_init(void)
 	slab_state = PARTIAL;
 
 	/* 2+3) create the kmalloc caches */
-	sizes = malloc_sizes;
-	names = cache_names;
 
 	/*
 	 * Initialize the caches that provide memory for the array cache and the
@@ -1662,35 +1618,39 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = create_kmalloc_cache(names[INDEX_AC].name,
-					sizes[INDEX_AC].cs_size, ARCH_KMALLOC_FLAGS);
+	cs_cachep[INDEX_AC] = create_kmalloc_cache("kmalloc-ac",
+					kmalloc_size(INDEX_AC), ARCH_KMALLOC_FLAGS);
 
 	if (INDEX_AC != INDEX_L3)
-		sizes[INDEX_L3].cs_cachep =
-			create_kmalloc_cache(names[INDEX_L3].name,
-				sizes[INDEX_L3].cs_size, ARCH_KMALLOC_FLAGS);
+		cs_cachep[INDEX_L3] =
+			create_kmalloc_cache("kmalloc-l3",
+				kmalloc_size(INDEX_L3), ARCH_KMALLOC_FLAGS);
 
 	slab_early_init = 0;
 
-	while (sizes->cs_size != ULONG_MAX) {
-		/*
-		 * For performance, all the general caches are L1 aligned.
-		 * This should be particularly beneficial on SMP boxes, as it
-		 * eliminates "false sharing".
-		 * Note for systems short on memory removing the alignment will
-		 * allow tighter packing of the smaller caches.
-		 */
-		if (!sizes->cs_cachep)
-			sizes->cs_cachep = create_kmalloc_cache(names->name,
-					sizes->cs_size, ARCH_KMALLOC_FLAGS);
+	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
+		size_t cs_size = kmalloc_size(i);
+
+		if (cs_size < KMALLOC_MIN_SIZE)
+			continue;
+
+		if (!cs_cachep[i]) {
+			/*
+			 * For performance, all the general caches are L1 aligned.
+			 * This should be particularly beneficial on SMP boxes, as it
+			 * eliminates "false sharing".
+			 * Note for systems short on memory removing the alignment will
+			 * allow tighter packing of the smaller caches.
+			 */
+			cs_cachep[i] = create_kmalloc_cache("kmalloc",
+					cs_size, ARCH_KMALLOC_FLAGS);
+		}
 
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = create_kmalloc_cache(
-			names->name_dma, sizes->cs_size,
+		cs_dmacachep[i] = create_kmalloc_cache(
+			"kmalloc-dma", cs_size,
 			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
 #endif
-		sizes++;
-		names++;
 	}
 	/* 4) Replace the bootstrap head arrays */
 	{
@@ -1709,17 +1669,16 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep)
+		BUG_ON(cpu_cache_get(cs_cachep[INDEX_AC])
 		       != &initarray_generic.cache);
-		memcpy(ptr, cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep),
+		memcpy(ptr, cpu_cache_get(cs_cachep[INDEX_AC]),
 		       sizeof(struct arraycache_init));
 		/*
 		 * Do not assume that spinlocks can be initialized via memcpy:
 		 */
 		spin_lock_init(&ptr->lock);
 
-		malloc_sizes[INDEX_AC].cs_cachep->array[smp_processor_id()] =
-		    ptr;
+		cs_cachep[INDEX_AC]->array[smp_processor_id()] = ptr;
 	}
 	/* 5) Replace the bootstrap kmem_list3's */
 	{
@@ -1728,17 +1687,39 @@ void __init kmem_cache_init(void)
 		for_each_online_node(nid) {
 			init_list(kmem_cache, &initkmem_list3[CACHE_CACHE + nid], nid);
 
-			init_list(malloc_sizes[INDEX_AC].cs_cachep,
+			init_list(cs_cachep[INDEX_AC],
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
 			if (INDEX_AC != INDEX_L3) {
-				init_list(malloc_sizes[INDEX_L3].cs_cachep,
+				init_list(cs_cachep[INDEX_L3],
 					  &initkmem_list3[SIZE_L3 + nid], nid);
 			}
 		}
 	}
 
 	slab_state = UP;
+
+	/* Create the proper names */
+	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
+		char *s;
+		struct kmem_cache *c = cs_cachep[i];
+
+		if (!c)
+			continue;
+
+		s = kasprintf(GFP_NOWAIT, "kmalloc-%d", kmalloc_size(i));
+
+		BUG_ON(!s);
+		c->name = s;
+		
+#ifdef CONFIG_ZONE_DMA
+		c = cs_dmacachep[i];
+		BUG_ON(!c);
+		s = kasprintf(GFP_NOWAIT, "dma-kmalloc-%d", kmalloc_size(i));
+		BUG_ON(!s);
+		c->name = s;
+#endif
+	}
 }
 
 void __init kmem_cache_init_late(void)
Index: linux/include/linux/kmalloc_sizes.h
===================================================================
--- linux.orig/include/linux/kmalloc_sizes.h	2012-09-19 09:19:33.496874231 -0500
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,45 +0,0 @@
-#if (PAGE_SIZE == 4096)
-	CACHE(32)
-#endif
-	CACHE(64)
-#if L1_CACHE_BYTES < 64
-	CACHE(96)
-#endif
-	CACHE(128)
-#if L1_CACHE_BYTES < 128
-	CACHE(192)
-#endif
-	CACHE(256)
-	CACHE(512)
-	CACHE(1024)
-	CACHE(2048)
-	CACHE(4096)
-	CACHE(8192)
-	CACHE(16384)
-	CACHE(32768)
-	CACHE(65536)
-	CACHE(131072)
-#if KMALLOC_MAX_SIZE >= 262144
-	CACHE(262144)
-#endif
-#if KMALLOC_MAX_SIZE >= 524288
-	CACHE(524288)
-#endif
-#if KMALLOC_MAX_SIZE >= 1048576
-	CACHE(1048576)
-#endif
-#if KMALLOC_MAX_SIZE >= 2097152
-	CACHE(2097152)
-#endif
-#if KMALLOC_MAX_SIZE >= 4194304
-	CACHE(4194304)
-#endif
-#if KMALLOC_MAX_SIZE >= 8388608
-	CACHE(8388608)
-#endif
-#if KMALLOC_MAX_SIZE >= 16777216
-	CACHE(16777216)
-#endif
-#if KMALLOC_MAX_SIZE >= 33554432
-	CACHE(33554432)
-#endif
Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-09-19 09:21:00.602683885 -0500
+++ linux/include/linux/slab_def.h	2012-09-19 09:21:32.535347400 -0500
@@ -11,8 +11,6 @@
  */
 
 #include <linux/init.h>
-#include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
-#include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 #include <linux/compiler.h>
 
 /*
@@ -97,15 +95,8 @@ struct kmem_cache {
 	 */
 };
 
-/* Size description struct for general caches. */
-struct cache_sizes {
-	size_t		 	cs_size;
-	struct kmem_cache	*cs_cachep;
-#ifdef CONFIG_ZONE_DMA
-	struct kmem_cache	*cs_dmacachep;
-#endif
-};
-extern struct cache_sizes malloc_sizes[];
+extern struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
+extern struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
 
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
@@ -132,26 +123,19 @@ static __always_inline void *kmalloc(siz
 	void *ret;
 
 	if (__builtin_constant_p(size)) {
-		int i = 0;
+		int i;
 
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include <linux/kmalloc_sizes.h>
-#undef CACHE
-		return NULL;
-found:
+		i = kmalloc_index(size);
+
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			cachep = malloc_sizes[i].cs_dmacachep;
+			cachep = cs_dmacachep[i];
 		else
 #endif
-			cachep = malloc_sizes[i].cs_cachep;
+			cachep = cs_cachep[i];
 
 		ret = kmem_cache_alloc_trace(size, cachep, flags);
 
@@ -185,26 +169,19 @@ static __always_inline void *kmalloc_nod
 	struct kmem_cache *cachep;
 
 	if (__builtin_constant_p(size)) {
-		int i = 0;
+		int i;
 
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include <linux/kmalloc_sizes.h>
-#undef CACHE
-		return NULL;
-found:
+		i = kmalloc_index(size);
+
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			cachep = malloc_sizes[i].cs_dmacachep;
+			cachep = cs_dmacachep[i];
 		else
 #endif
-			cachep = malloc_sizes[i].cs_cachep;
+			cachep = cs_cachep[i];
 
 		return kmem_cache_alloc_node_trace(size, cachep, flags, node);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
