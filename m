Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 37B5E6B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:24:44 -0400 (EDT)
Message-Id: <0000013a0e5680f0-cf79f92f-29f9-4035-8c9e-21a11c2fe593-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:24:41 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [14/15] Common Kmalloc cache determination
References: <20120928191715.368450474@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Extract the optimized lookup functions from slub and put them into
slab_common.c. Then make slab use these functions as well.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-28 13:23:51.907874005 -0500
+++ linux/mm/slab.c	2012-09-28 13:24:16.364384581 -0500
@@ -654,40 +654,6 @@ static inline struct array_cache *cpu_ca
 	return cachep->array[smp_processor_id()];
 }
 
-static inline struct kmem_cache *__find_general_cachep(size_t size,
-							gfp_t gfpflags)
-{
-	int i;
-
-#if DEBUG
-	/* This happens if someone tries to call
-	 * kmem_cache_create(), or __kmalloc(), before
-	 * the generic caches are initialized.
-	 */
-	BUG_ON(kmalloc_caches[INDEX_AC] == NULL);
-#endif
-	if (!size)
-		return ZERO_SIZE_PTR;
-
-	i = kmalloc_index(size);
-
-	/*
-	 * Really subtle: The last entry with cs->cs_size==ULONG_MAX
-	 * has cs_{dma,}cachep==NULL. Thus no special case
-	 * for large kmalloc calls required.
-	 */
-#ifdef CONFIG_ZONE_DMA
-	if (unlikely(gfpflags & GFP_DMA))
-		return kmalloc_dma_caches[i];
-#endif
-	return kmalloc_caches[i];
-}
-
-static struct kmem_cache *kmem_find_general_cachep(size_t size, gfp_t gfpflags)
-{
-	return __find_general_cachep(size, gfpflags);
-}
-
 static size_t slab_mgmt_size(size_t nr_objs, size_t align)
 {
 	return ALIGN(sizeof(struct slab)+nr_objs*sizeof(kmem_bufctl_t), align);
@@ -2430,7 +2396,7 @@ __kmem_cache_create (struct kmem_cache *
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
 	if (flags & CFLGS_OFF_SLAB) {
-		cachep->slabp_cache = kmem_find_general_cachep(slab_size, 0u);
+		cachep->slabp_cache = kmalloc_slab(slab_size, 0u);
 		/*
 		 * This is a possibility for one of the malloc_sizes caches.
 		 * But since we go off slab only for object size greater than
@@ -3729,7 +3695,7 @@ __do_kmalloc_node(size_t size, gfp_t fla
 {
 	struct kmem_cache *cachep;
 
-	cachep = kmem_find_general_cachep(size, flags);
+	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
 	return kmem_cache_alloc_node_trace(size, cachep, flags, node);
@@ -3775,7 +3741,7 @@ static __always_inline void *__do_kmallo
 	 * Then kmalloc uses the uninlined functions instead of the inline
 	 * functions.
 	 */
-	cachep = __find_general_cachep(size, flags);
+	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
 	ret = __cache_alloc(cachep, flags, caller);
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-28 13:24:08.000000000 -0500
+++ linux/mm/slab.h	2012-09-28 13:24:54.497180671 -0500
@@ -38,6 +38,9 @@ unsigned long calculate_alignment(unsign
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
 void create_kmalloc_caches(unsigned long);
+
+/* Find the kmalloc slab corresponding for a certain size */
+struct kmem_cache *kmalloc_slab(size_t, gfp_t);
 #endif
 
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-28 13:23:51.000000000 -0500
+++ linux/mm/slab_common.c	2012-09-28 13:24:16.364384581 -0500
@@ -260,6 +260,68 @@ EXPORT_SYMBOL(kmalloc_dma_caches);
 #endif
 
 /*
+ * Conversion table for small slabs sizes / 8 to the index in the
+ * kmalloc array. This is necessary for slabs < 192 since we have non power
+ * of two cache sizes there. The size of larger slabs can be determined using
+ * fls.
+ */
+static s8 size_index[24] = {
+	3,	/* 8 */
+	4,	/* 16 */
+	5,	/* 24 */
+	5,	/* 32 */
+	6,	/* 40 */
+	6,	/* 48 */
+	6,	/* 56 */
+	6,	/* 64 */
+	1,	/* 72 */
+	1,	/* 80 */
+	1,	/* 88 */
+	1,	/* 96 */
+	7,	/* 104 */
+	7,	/* 112 */
+	7,	/* 120 */
+	7,	/* 128 */
+	2,	/* 136 */
+	2,	/* 144 */
+	2,	/* 152 */
+	2,	/* 160 */
+	2,	/* 168 */
+	2,	/* 176 */
+	2,	/* 184 */
+	2	/* 192 */
+};
+
+static inline int size_index_elem(size_t bytes)
+{
+	return (bytes - 1) / 8;
+}
+
+/*
+ * Find the kmem_cache structure that serves a given size of
+ * allocation
+ */
+struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
+{
+	int index;
+
+	if (size <= 192) {
+		if (!size)
+			return ZERO_SIZE_PTR;
+
+		index = size_index[size_index_elem(size)];
+	} else
+		index = fls(size - 1);
+
+#ifdef CONFIG_ZONE_DMA
+	if (unlikely((flags & SLAB_CACHE_DMA)))
+		return kmalloc_dma_caches[index];
+
+#endif
+	return kmalloc_caches[index];
+}
+
+/*
  * Create the kmalloc array. Some of the regular kmalloc arrays
  * may already have been created because they were needed to
  * enable allocations for slab creation.
@@ -268,6 +330,47 @@ void __init create_kmalloc_caches(unsign
 {
 	int i;
 
+	/*
+	 * Patch up the size_index table if we have strange large alignment
+	 * requirements for the kmalloc array. This is only the case for
+	 * MIPS it seems. The standard arches will not generate any code here.
+	 *
+	 * Largest permitted alignment is 256 bytes due to the way we
+	 * handle the index determination for the smaller caches.
+	 *
+	 * Make sure that nothing crazy happens if someone starts tinkering
+	 * around with ARCH_KMALLOC_MINALIGN
+	 */
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
+		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
+
+	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8) {
+		int elem = size_index_elem(i);
+
+		if (elem >= ARRAY_SIZE(size_index))
+			break;
+		size_index[elem] = KMALLOC_SHIFT_LOW;
+	}
+
+	if (KMALLOC_MIN_SIZE >= 64) {
+		/*
+		 * The 96 byte size cache is not used if the alignment
+		 * is 64 byte.
+		 */
+		for (i = 64 + 8; i <= 96; i += 8)
+			size_index[size_index_elem(i)] = 7;
+
+	}
+
+	if (KMALLOC_MIN_SIZE >= 128) {
+		/*
+		 * The 192 byte sized cache is not used if the alignment
+		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
+		 * instead.
+		 */
+		for (i = 128 + 8; i <= 192; i += 8)
+			size_index[size_index_elem(i)] = 8;
+	}
 	/* Caches that are not of the two-to-the-power-of size */
 	if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1])
 		kmalloc_caches[1] = create_kmalloc_cache(NULL, 96, flags);
@@ -311,7 +414,5 @@ void __init create_kmalloc_caches(unsign
 	}
 #endif
 }
-
-
 #endif /* !CONFIG_SLOB */
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-28 13:23:51.907874005 -0500
+++ linux/mm/slub.c	2012-09-28 13:24:16.364384581 -0500
@@ -3210,64 +3210,6 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-/*
- * Conversion table for small slabs sizes / 8 to the index in the
- * kmalloc array. This is necessary for slabs < 192 since we have non power
- * of two cache sizes there. The size of larger slabs can be determined using
- * fls.
- */
-static s8 size_index[24] = {
-	3,	/* 8 */
-	4,	/* 16 */
-	5,	/* 24 */
-	5,	/* 32 */
-	6,	/* 40 */
-	6,	/* 48 */
-	6,	/* 56 */
-	6,	/* 64 */
-	1,	/* 72 */
-	1,	/* 80 */
-	1,	/* 88 */
-	1,	/* 96 */
-	7,	/* 104 */
-	7,	/* 112 */
-	7,	/* 120 */
-	7,	/* 128 */
-	2,	/* 136 */
-	2,	/* 144 */
-	2,	/* 152 */
-	2,	/* 160 */
-	2,	/* 168 */
-	2,	/* 176 */
-	2,	/* 184 */
-	2	/* 192 */
-};
-
-static inline int size_index_elem(size_t bytes)
-{
-	return (bytes - 1) / 8;
-}
-
-static struct kmem_cache *get_slab(size_t size, gfp_t flags)
-{
-	int index;
-
-	if (size <= 192) {
-		if (!size)
-			return ZERO_SIZE_PTR;
-
-		index = size_index[size_index_elem(size)];
-	} else
-		index = fls(size - 1);
-
-#ifdef CONFIG_ZONE_DMA
-	if (unlikely((flags & SLUB_DMA)))
-		return kmalloc_dma_caches[index];
-
-#endif
-	return kmalloc_caches[index];
-}
-
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
@@ -3276,7 +3218,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, flags);
 
-	s = get_slab(size, flags);
+	s = kmalloc_slab(size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3319,7 +3261,7 @@ void *__kmalloc_node(size_t size, gfp_t
 		return ret;
 	}
 
-	s = get_slab(size, flags);
+	s = kmalloc_slab(size, flags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3627,8 +3569,6 @@ static __initdata struct kmem_cache boot
 
 void __init kmem_cache_init(void)
 {
-	int i;
-
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
 
@@ -3663,45 +3603,6 @@ void __init kmem_cache_init(void)
 	kmem_cache_bootstrap_fixup(kmem_cache);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
-
-	/*
-	 * Patch up the size_index table if we have strange large alignment
-	 * requirements for the kmalloc array. This is only the case for
-	 * MIPS it seems. The standard arches will not generate any code here.
-	 *
-	 * Largest permitted alignment is 256 bytes due to the way we
-	 * handle the index determination for the smaller caches.
-	 *
-	 * Make sure that nothing crazy happens if someone starts tinkering
-	 * around with ARCH_KMALLOC_MINALIGN
-	 */
-	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
-		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
-
-	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8) {
-		int elem = size_index_elem(i);
-		if (elem >= ARRAY_SIZE(size_index))
-			break;
-		size_index[elem] = KMALLOC_SHIFT_LOW;
-	}
-
-	if (KMALLOC_MIN_SIZE == 64) {
-		/*
-		 * The 96 byte size cache is not used if the alignment
-		 * is 64 byte.
-		 */
-		for (i = 64 + 8; i <= 96; i += 8)
-			size_index[size_index_elem(i)] = 7;
-	} else if (KMALLOC_MIN_SIZE == 128) {
-		/*
-		 * The 192 byte sized cache is not used if the alignment
-		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
-		 * instead.
-		 */
-		for (i = 128 + 8; i <= 192; i += 8)
-			size_index[size_index_elem(i)] = 8;
-	}
-
 	create_kmalloc_caches(0);
 
 #ifdef CONFIG_SMP
@@ -3872,7 +3773,7 @@ void *__kmalloc_track_caller(size_t size
 	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return kmalloc_large(size, gfpflags);
 
-	s = get_slab(size, gfpflags);
+	s = kmalloc_slab(size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
@@ -3902,7 +3803,7 @@ void *__kmalloc_node_track_caller(size_t
 		return ret;
 	}
 
-	s = get_slab(size, gfpflags);
+	s = kmalloc_slab(size, gfpflags);
 
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2012-09-28 13:23:34.000000000 -0500
+++ linux/include/linux/slub_def.h	2012-09-28 13:24:16.364384581 -0500
@@ -124,7 +124,7 @@ struct kmem_cache {
  * This ought to end up with a global pointer to the right cache
  * in kmalloc_caches.
  */
-static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
+static __always_inline struct kmem_cache *kmalloc_slab_inline(size_t size)
 {
 	int index = kmalloc_index(size);
 
@@ -189,7 +189,7 @@ static __always_inline void *kmalloc(siz
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
-			struct kmem_cache *s = kmalloc_slab(size);
+			struct kmem_cache *s = kmalloc_slab_inline(size);
 
 			if (!s)
 				return ZERO_SIZE_PTR;
@@ -222,7 +222,7 @@ static __always_inline void *kmalloc_nod
 {
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLUB_DMA)) {
-			struct kmem_cache *s = kmalloc_slab(size);
+			struct kmem_cache *s = kmalloc_slab_inline(size);
 
 		if (!s)
 			return ZERO_SIZE_PTR;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
