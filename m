Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1AC6B0269
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so1035934wrg.11
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si583396edj.54.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 1/5] mm, slab/slub: introduce kmalloc-reclaimable caches
Date: Thu, 24 May 2018 13:00:07 +0200
Message-Id: <20180524110011.1940-2-vbabka@suse.cz>
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
References: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

Kmem caches can be created with a SLAB_RECLAIM_ACCOUNT flag, which indicates
they contain objects which can be reclaimed under memory pressure (typically
through a shrinker). This makes the slab pages accounted as NR_SLAB_RECLAIMABLE
in vmstat, which is reflected also the MemAvailable meminfo counter and in
overcommit decisions. The slab pages are also allocated with __GFP_RECLAIMABLE,
which is good for anti-fragmentation through grouping pages by mobility.

The generic kmalloc-X caches are created without this flag, but sometimes are
used also for objects that can be reclaimed, which due to varying size cannot
have a dedicated kmem cache with SLAB_RECLAIM_ACCOUNT flag. A prominent example
are dcache external names, which prompted the creation of a new, manually
managed vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES in commit f1782c9bc547
("dcache: account external names as indirectly reclaimable memory").

To better handle this and any other similar cases, this patch introduces
SLAB_RECLAIM_ACCOUNT variants of kmalloc caches, named kmalloc-reclaimable-X.
They are used whenever the kmalloc() call passes __GFP_RECLAIMABLE among gfp
flags. The kmalloc_caches[size_idx] array is extended to a two-dimensional
array kmalloc_caches[reclaimable][size_idx] to avoid an extra branch testing
for the flag.

This change only applies to SLAB and SLUB, not SLOB. This is fine, since SLOB's
target are tiny system and this patch does add some overhead of kmem management
objects.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/slab.h | 17 ++++++++++----
 mm/slab.c            |  4 ++--
 mm/slab_common.c     | 56 ++++++++++++++++++++++++++++++--------------
 mm/slub.c            | 12 +++++-----
 4 files changed, 58 insertions(+), 31 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9ebe659bd4a5..5bff0571b360 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -296,11 +296,16 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
                                (KMALLOC_MIN_SIZE) : 16)
 
 #ifndef CONFIG_SLOB
-extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
+extern struct kmem_cache *kmalloc_caches[2][KMALLOC_SHIFT_HIGH + 1];
 #ifdef CONFIG_ZONE_DMA
 extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
 #endif
 
+static __always_inline unsigned int kmalloc_reclaimable(gfp_t flags)
+{
+	return !!(flags & __GFP_RECLAIMABLE);
+}
+
 /*
  * Figure out which kmalloc slab an allocation of a certain size
  * belongs to.
@@ -536,12 +541,13 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 #ifndef CONFIG_SLOB
 		if (!(flags & GFP_DMA)) {
 			unsigned int index = kmalloc_index(size);
+			unsigned int recl = kmalloc_reclaimable(flags);
 
 			if (!index)
 				return ZERO_SIZE_PTR;
 
-			return kmem_cache_alloc_trace(kmalloc_caches[index],
-					flags, size);
+			return kmem_cache_alloc_trace(
+				kmalloc_caches[recl][index], flags, size);
 		}
 #endif
 	}
@@ -588,12 +594,13 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
 		unsigned int i = kmalloc_index(size);
+		unsigned int recl = kmalloc_reclaimable(flags);
 
 		if (!i)
 			return ZERO_SIZE_PTR;
 
-		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
-						flags, node, size);
+		return kmem_cache_alloc_node_trace(
+			kmalloc_caches[recl][i], flags, node, size);
 	}
 #endif
 	return __kmalloc_node(size, flags, node);
diff --git a/mm/slab.c b/mm/slab.c
index c1fe8099b3cd..8d7e1f06127b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1290,7 +1290,7 @@ void __init kmem_cache_init(void)
 	 * Initialize the caches that provide memory for the  kmem_cache_node
 	 * structures first.  Without this, further allocations will bug.
 	 */
-	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
+	kmalloc_caches[0][INDEX_NODE] = create_kmalloc_cache(
 				kmalloc_info[INDEX_NODE].name,
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
 				0, kmalloc_size(INDEX_NODE));
@@ -1306,7 +1306,7 @@ void __init kmem_cache_init(void)
 		for_each_online_node(nid) {
 			init_list(kmem_cache, &init_kmem_cache_node[CACHE_CACHE + nid], nid);
 
-			init_list(kmalloc_caches[INDEX_NODE],
+			init_list(kmalloc_caches[0][INDEX_NODE],
 					  &init_kmem_cache_node[SIZE_NODE + nid], nid);
 		}
 	}
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b0dd9db1eb2f..d9a66095de0d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -938,7 +938,11 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 	return s;
 }
 
-struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
+/*
+ * kmalloc_caches[0][] - kmalloc caches for non-reclaimable allocations
+ * kmalloc_caches[1][] - kmalloc caches for __GFP_RECLAIMABLE allocations
+ */
+struct kmem_cache *kmalloc_caches[2][KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
 EXPORT_SYMBOL(kmalloc_caches);
 
 #ifdef CONFIG_ZONE_DMA
@@ -1010,7 +1014,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 		return kmalloc_dma_caches[index];
 
 #endif
-	return kmalloc_caches[index];
+	return kmalloc_caches[kmalloc_reclaimable(flags)][index];
 }
 
 /*
@@ -1082,9 +1086,21 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
 
-static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
+static void __init
+new_kmalloc_cache(int idx, int reclaimable, slab_flags_t flags)
 {
-	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
+	const char * name;
+
+	if (reclaimable) {
+		flags |= SLAB_RECLAIM_ACCOUNT;
+		name = kasprintf(GFP_NOWAIT, "kmalloc-reclaimable-%u",
+						kmalloc_info[idx].size);
+		BUG_ON(!name);
+	} else {
+		name = kmalloc_info[idx].name;
+	}
+
+	kmalloc_caches[reclaimable][idx] = create_kmalloc_cache(name,
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
 }
@@ -1096,21 +1112,25 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
  */
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
-	int i;
+	int i, reclaimable;
 
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
-		if (!kmalloc_caches[i])
-			new_kmalloc_cache(i, flags);
+	for (reclaimable = 0; reclaimable <= 1; reclaimable++) {
+		for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+			if (!kmalloc_caches[reclaimable][i])
+				new_kmalloc_cache(i, reclaimable, flags);
 
-		/*
-		 * Caches that are not of the two-to-the-power-of size.
-		 * These have to be created immediately after the
-		 * earlier power of two caches
-		 */
-		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1] && i == 6)
-			new_kmalloc_cache(1, flags);
-		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2] && i == 7)
-			new_kmalloc_cache(2, flags);
+			/*
+			 * Caches that are not of the two-to-the-power-of size.
+			 * These have to be created immediately after the
+			 * earlier power of two caches
+			 */
+			if (KMALLOC_MIN_SIZE <= 32 && i == 6 &&
+						!kmalloc_caches[reclaimable][1])
+				new_kmalloc_cache(1, reclaimable, flags);
+			if (KMALLOC_MIN_SIZE <= 64 && i == 7 &&
+						!kmalloc_caches[reclaimable][2])
+				new_kmalloc_cache(2, reclaimable, flags);
+		}
 	}
 
 	/* Kmalloc array is now usable */
@@ -1118,7 +1138,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 
 #ifdef CONFIG_ZONE_DMA
 	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
-		struct kmem_cache *s = kmalloc_caches[i];
+		struct kmem_cache *s = kmalloc_caches[0][i];
 
 		if (s) {
 			unsigned int size = kmalloc_size(i);
diff --git a/mm/slub.c b/mm/slub.c
index 48f75872c356..c7d7b83f20c2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4707,7 +4707,7 @@ static void __init resiliency_test(void)
 	pr_err("\n1. kmalloc-16: Clobber Redzone/next pointer 0x12->0x%p\n\n",
 	       p + 16);
 
-	validate_slab_cache(kmalloc_caches[4]);
+	validate_slab_cache(kmalloc_caches[0][4]);
 
 	/* Hmmm... The next two are dangerous */
 	p = kzalloc(32, GFP_KERNEL);
@@ -4716,33 +4716,33 @@ static void __init resiliency_test(void)
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
 
-	validate_slab_cache(kmalloc_caches[5]);
+	validate_slab_cache(kmalloc_caches[0][5]);
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
 	pr_err("\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 	       p);
 	pr_err("If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches[6]);
+	validate_slab_cache(kmalloc_caches[0][6]);
 
 	pr_err("\nB. Corruption after free\n");
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
 	pr_err("1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[7]);
+	validate_slab_cache(kmalloc_caches[0][7]);
 
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
 	pr_err("\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[8]);
+	validate_slab_cache(kmalloc_caches[0][8]);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
 	pr_err("\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches[9]);
+	validate_slab_cache(kmalloc_caches[0][9]);
 }
 #else
 #ifdef CONFIG_SYSFS
-- 
2.17.0
