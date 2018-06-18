Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8726B0008
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:18:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x6-v6so11355677wrl.6
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:18:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h48-v6si8848199ede.163.2018.06.18.02.18.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:18:28 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/7] mm, slab/slub: introduce kmalloc-reclaimable caches
Date: Mon, 18 Jun 2018 11:18:03 +0200
Message-Id: <20180618091808.4419-3-vbabka@suse.cz>
In-Reply-To: <20180618091808.4419-1-vbabka@suse.cz>
References: <20180618091808.4419-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

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
SLAB_RECLAIM_ACCOUNT variants of kmalloc caches, named kmalloc-rcl-X.
They are used whenever the kmalloc() call passes __GFP_RECLAIMABLE among gfp
flags. They are added to the kmalloc_caches array as a new type. Allocations
with both __GFP_DMA and __GFP_RECLAIMABLE will use a dma type cache.

This change only applies to SLAB and SLUB, not SLOB. This is fine, since SLOB's
target are tiny system and this patch does add some overhead of kmem management
objects.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/slab.h | 16 +++++++++++----
 mm/slab_common.c     | 48 ++++++++++++++++++++++++++++----------------
 2 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 4299c59353a1..d89e934e0d8b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -296,11 +296,12 @@ static inline void __check_heap_object(const void *ptr, unsigned long n,
                                (KMALLOC_MIN_SIZE) : 16)
 
 #define KMALLOC_NORMAL	0
+#define KMALLOC_RECLAIM	1
 #ifdef CONFIG_ZONE_DMA
-#define KMALLOC_DMA	1
-#define KMALLOC_TYPES	2
+#define KMALLOC_DMA	2
+#define KMALLOC_TYPES	3
 #else
-#define KMALLOC_TYPES	1
+#define KMALLOC_TYPES	2
 #endif
 
 #ifndef CONFIG_SLOB
@@ -309,12 +310,19 @@ extern struct kmem_cache *kmalloc_caches[KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
 static __always_inline unsigned int kmalloc_type(gfp_t flags)
 {
 	int is_dma = 0;
+	int is_reclaimable;
 
 #ifdef CONFIG_ZONE_DMA
 	is_dma = !!(flags & __GFP_DMA);
 #endif
 
-	return is_dma;
+	is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
+
+	/*
+	 * If an allocation is botth __GFP_DMA and __GFP_RECLAIMABLE, return
+	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
+	 */
+	return (is_dma * 2) + (is_reclaimable & !is_dma);
 }
 
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 635f2d8d0198..8a30d6979936 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1103,10 +1103,21 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
 
-static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
+static void __init
+new_kmalloc_cache(int idx, int type, slab_flags_t flags)
 {
-	kmalloc_caches[KMALLOC_NORMAL][idx] = create_kmalloc_cache(
-					kmalloc_info[idx].name,
+	const char *name;
+
+	if (type == KMALLOC_RECLAIM) {
+		flags |= SLAB_RECLAIM_ACCOUNT;
+		name = kasprintf(GFP_NOWAIT, "kmalloc-rcl-%u",
+						kmalloc_info[idx].size);
+		BUG_ON(!name);
+	} else {
+		name = kmalloc_info[idx].name;
+	}
+
+	kmalloc_caches[type][idx] = create_kmalloc_cache(name,
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
 }
@@ -1118,22 +1129,25 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
  */
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
-	int i;
-	int type = KMALLOC_NORMAL;
+	int i, type;
 
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
-		if (!kmalloc_caches[type][i])
-			new_kmalloc_cache(i, flags);
+	for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
+		for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+			if (!kmalloc_caches[type][i])
+				new_kmalloc_cache(i, type, flags);
 
-		/*
-		 * Caches that are not of the two-to-the-power-of size.
-		 * These have to be created immediately after the
-		 * earlier power of two caches
-		 */
-		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[type][1] && i == 6)
-			new_kmalloc_cache(1, flags);
-		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[type][2] && i == 7)
-			new_kmalloc_cache(2, flags);
+			/*
+			 * Caches that are not of the two-to-the-power-of size.
+			 * These have to be created immediately after the
+			 * earlier power of two caches
+			 */
+			if (KMALLOC_MIN_SIZE <= 32 && i == 6 &&
+					!kmalloc_caches[type][1])
+				new_kmalloc_cache(1, type, flags);
+			if (KMALLOC_MIN_SIZE <= 64 && i == 7 &&
+					!kmalloc_caches[type][2])
+				new_kmalloc_cache(2, type, flags);
+		}
 	}
 
 	/* Kmalloc array is now usable */
-- 
2.17.1
