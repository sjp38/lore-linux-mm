Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77B336B026C
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:07:03 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d10-v6so10880306pll.22
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:07:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l63-v6si11594650plb.106.2018.07.31.02.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 02:07:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 1/6] mm, slab: combine kmalloc_caches and kmalloc_dma_caches
Date: Tue, 31 Jul 2018 11:06:44 +0200
Message-Id: <20180731090649.16028-2-vbabka@suse.cz>
In-Reply-To: <20180731090649.16028-1-vbabka@suse.cz>
References: <20180731090649.16028-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

The kmalloc caches currently mainain separate (optional) array
kmalloc_dma_caches for __GFP_DMA allocations. There are tests for __GFP_DMA in
the allocation hotpaths. We can avoid the branches by combining kmalloc_caches
and kmalloc_dma_caches into a single two-dimensional array where the outer
dimension is cache "type". This will also allow to add kmalloc-reclaimable
caches as a third type.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Roman Gushchin <guro@fb.com>
---
 include/linux/slab.h | 42 +++++++++++++++++++++++++++++++-----------
 mm/slab.c            |  4 ++--
 mm/slab_common.c     | 31 ++++++++++++-------------------
 mm/slub.c            | 13 +++++++------
 4 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 14e3fe4bd6a1..f35f2c1f37b9 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -295,12 +295,29 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
 #define SLAB_OBJ_MIN_SIZE      (KMALLOC_MIN_SIZE < 16 ? \
                                (KMALLOC_MIN_SIZE) : 16)
 
+enum kmalloc_cache_type {
+	KMALLOC_NORMAL = 0,
+#ifdef CONFIG_ZONE_DMA
+	KMALLOC_DMA,
+#endif
+	NR_KMALLOC_TYPES
+};
+
 #ifndef CONFIG_SLOB
-extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
+extern struct kmem_cache *
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
+
+static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
+{
+	int is_dma = 0;
+
 #ifdef CONFIG_ZONE_DMA
-extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
+	is_dma = !!(flags & __GFP_DMA);
 #endif
 
+	return is_dma;
+}
+
 /*
  * Figure out which kmalloc slab an allocation of a certain size
  * belongs to.
@@ -501,18 +518,20 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
+#ifndef CONFIG_SLOB
+		unsigned int index;
+#endif
 		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
 #ifndef CONFIG_SLOB
-		if (!(flags & GFP_DMA)) {
-			unsigned int index = kmalloc_index(size);
+		index = kmalloc_index(size);
 
-			if (!index)
-				return ZERO_SIZE_PTR;
+		if (!index)
+			return ZERO_SIZE_PTR;
 
-			return kmem_cache_alloc_trace(kmalloc_caches[index],
-					flags, size);
-		}
+		return kmem_cache_alloc_trace(
+				kmalloc_caches[kmalloc_type(flags)][index],
+				flags, size);
 #endif
 	}
 	return __kmalloc(size, flags);
@@ -542,13 +561,14 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
-		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
+		size <= KMALLOC_MAX_CACHE_SIZE) {
 		unsigned int i = kmalloc_index(size);
 
 		if (!i)
 			return ZERO_SIZE_PTR;
 
-		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
+		return kmem_cache_alloc_node_trace(
+				kmalloc_caches[kmalloc_type(flags)][i],
 						flags, node, size);
 	}
 #endif
diff --git a/mm/slab.c b/mm/slab.c
index aa76a70e087e..9515798f37b2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1288,7 +1288,7 @@ void __init kmem_cache_init(void)
 	 * Initialize the caches that provide memory for the  kmem_cache_node
 	 * structures first.  Without this, further allocations will bug.
 	 */
-	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
+	kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE] = create_kmalloc_cache(
 				kmalloc_info[INDEX_NODE].name,
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
 				0, kmalloc_size(INDEX_NODE));
@@ -1304,7 +1304,7 @@ void __init kmem_cache_init(void)
 		for_each_online_node(nid) {
 			init_list(kmem_cache, &init_kmem_cache_node[CACHE_CACHE + nid], nid);
 
-			init_list(kmalloc_caches[INDEX_NODE],
+			init_list(kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE],
 					  &init_kmem_cache_node[SIZE_NODE + nid], nid);
 		}
 	}
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2296caf87bfb..4572941440f3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -973,14 +973,10 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	return s;
 }
 
-struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
+struct kmem_cache *
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
 EXPORT_SYMBOL(kmalloc_caches);
 
-#ifdef CONFIG_ZONE_DMA
-struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
-EXPORT_SYMBOL(kmalloc_dma_caches);
-#endif
-
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
@@ -1040,12 +1036,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 	} else
 		index = fls(size - 1);
 
-#ifdef CONFIG_ZONE_DMA
-	if (unlikely((flags & GFP_DMA)))
-		return kmalloc_dma_caches[index];
-
-#endif
-	return kmalloc_caches[index];
+	return kmalloc_caches[kmalloc_type(flags)][index];
 }
 
 /*
@@ -1119,7 +1110,8 @@ void __init setup_kmalloc_cache_index_table(void)
 
 static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
 {
-	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
+	kmalloc_caches[KMALLOC_NORMAL][idx] = create_kmalloc_cache(
+					kmalloc_info[idx].name,
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
 }
@@ -1132,9 +1124,10 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
 	int i;
+	int type = KMALLOC_NORMAL;
 
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
-		if (!kmalloc_caches[i])
+		if (!kmalloc_caches[type][i])
 			new_kmalloc_cache(i, flags);
 
 		/*
@@ -1142,9 +1135,9 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 		 * These have to be created immediately after the
 		 * earlier power of two caches
 		 */
-		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1] && i == 6)
+		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[type][1] && i == 6)
 			new_kmalloc_cache(1, flags);
-		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2] && i == 7)
+		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[type][2] && i == 7)
 			new_kmalloc_cache(2, flags);
 	}
 
@@ -1153,7 +1146,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 
 #ifdef CONFIG_ZONE_DMA
 	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
-		struct kmem_cache *s = kmalloc_caches[i];
+		struct kmem_cache *s = kmalloc_caches[KMALLOC_NORMAL][i];
 
 		if (s) {
 			unsigned int size = kmalloc_size(i);
@@ -1161,8 +1154,8 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 				 "dma-kmalloc-%u", size);
 
 			BUG_ON(!n);
-			kmalloc_dma_caches[i] = create_kmalloc_cache(n,
-				size, SLAB_CACHE_DMA | flags, 0, 0);
+			kmalloc_caches[KMALLOC_DMA][i] = create_kmalloc_cache(
+				n, size, SLAB_CACHE_DMA | flags, 0, 0);
 		}
 	}
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 51258eff4178..a7b4657ea8e0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4659,6 +4659,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 static void __init resiliency_test(void)
 {
 	u8 *p;
+	int type = KMALLOC_NORMAL;
 
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || KMALLOC_SHIFT_HIGH < 10);
 
@@ -4671,7 +4672,7 @@ static void __init resiliency_test(void)
 	pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
 	       p + 16);
 
-	validate_slab_cache(kmalloc_caches[4]);
+	validate_slab_cache(kmalloc_caches[type][4]);
 
 	/* Hmmm... The next two are dangerous */
 	p = kzalloc(32, GFP_KERNEL);
@@ -4680,33 +4681,33 @@ static void __init resiliency_test(void)
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
 
-	validate_slab_cache(kmalloc_caches[5]);
+	validate_slab_cache(kmalloc_caches[type][5]);
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
 	pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches[6]);
+	validate_slab_cache(kmalloc_caches[type][6]);
 
 	pr_err("\nB. Corruption after free\n");
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
 	pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[7]);
+	validate_slab_cache(kmalloc_caches[type][7]);
 
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
 	pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[8]);
+	validate_slab_cache(kmalloc_caches[type][8]);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
 	pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[9]);
+	validate_slab_cache(kmalloc_caches[type][9]);
 }
 #else
 #ifdef CONFIG_SYSFS
-- 
2.18.0
