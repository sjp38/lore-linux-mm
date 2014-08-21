Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EDBF96B0037
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:11:33 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so13531066pdj.16
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:11:33 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id im2si35323798pbd.167.2014.08.21.01.11.31
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:11:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/3] mm/slab_common: commonize slab merge logic
Date: Thu, 21 Aug 2014 17:11:14 +0900
Message-Id: <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Slab merge is good feature to reduce fragmentation. Now, it is only
applied to SLUB, but, it would be good to apply it to SLAB. This patch
is preparation step to apply slab merge to SLAB by commonizing slab
merge logic.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.h        |   15 +++++++++
 mm/slab_common.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c        |   91 ++----------------------------------------------------
 3 files changed, 103 insertions(+), 89 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 5cb4649..7c6e1ed 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -85,15 +85,30 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
 			size_t size, unsigned long flags);
 
 struct mem_cgroup;
+
+int slab_unmergeable(struct kmem_cache *s);
+struct kmem_cache *find_mergeable(size_t size, size_t align,
+		unsigned long flags, const char *name, void (*ctor)(void *));
 #ifdef CONFIG_SLUB
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *));
+
+unsigned long kmem_cache_flags(unsigned long object_size,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *));
 #else
 static inline struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *))
 { return NULL; }
+
+static inline unsigned long kmem_cache_flags(unsigned long object_size,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *))
+{
+	return flags;
+}
 #endif
 
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2088904..65a5811 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -31,6 +31,29 @@ DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
 /*
+ * Set of flags that will prevent slab merging
+ */
+#define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
+		SLAB_FAILSLAB)
+
+#define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
+		SLAB_CACHE_DMA | SLAB_NOTRACK)
+
+/*
+ * Merge control. If this is set then no merging of slab caches will occur.
+ * (Could be removed. This was introduced to pacify the merge skeptics.)
+ */
+static int slab_nomerge;
+
+static int __init setup_slab_nomerge(char *str)
+{
+	slab_nomerge = 1;
+	return 1;
+}
+__setup("slub_nomerge", setup_slab_nomerge);
+
+/*
  * Determine the size of a slab object
  */
 unsigned int kmem_cache_size(struct kmem_cache *s)
@@ -115,6 +138,69 @@ out:
 #endif
 
 /*
+ * Find a mergeable slab cache
+ */
+int slab_unmergeable(struct kmem_cache *s)
+{
+	if (slab_nomerge || (s->flags & SLAB_NEVER_MERGE))
+		return 1;
+
+	if (!is_root_cache(s))
+		return 1;
+
+	if (s->ctor)
+		return 1;
+
+	/*
+	 * We may have set a slab to be unmergeable during bootstrap.
+	 */
+	if (s->refcount < 0)
+		return 1;
+
+	return 0;
+}
+
+struct kmem_cache *find_mergeable(size_t size, size_t align,
+		unsigned long flags, const char *name, void (*ctor)(void *))
+{
+	struct kmem_cache *s;
+
+	if (slab_nomerge || (flags & SLAB_NEVER_MERGE))
+		return NULL;
+
+	if (ctor)
+		return NULL;
+
+	size = ALIGN(size, sizeof(void *));
+	align = calculate_alignment(flags, align, size);
+	size = ALIGN(size, align);
+	flags = kmem_cache_flags(size, flags, name, NULL);
+
+	list_for_each_entry(s, &slab_caches, list) {
+		if (slab_unmergeable(s))
+			continue;
+
+		if (size > s->size)
+			continue;
+
+		if ((flags & SLAB_MERGE_SAME) != (s->flags & SLAB_MERGE_SAME))
+			continue;
+		/*
+		 * Check if alignment is compatible.
+		 * Courtesy of Adrian Drzewiecki
+		 */
+		if ((s->size & ~(align - 1)) != s->size)
+			continue;
+
+		if (s->size - size >= sizeof(void *))
+			continue;
+
+		return s;
+	}
+	return NULL;
+}
+
+/*
  * Figure out what the alignment of the objects will be given a set of
  * flags, a user specified alignment and the size of the objects.
  */
diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc..b29e835 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -169,16 +169,6 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
  */
 #define DEBUG_METADATA_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
 
-/*
- * Set of flags that will prevent slab merging
- */
-#define SLUB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB)
-
-#define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
-		SLAB_CACHE_DMA | SLAB_NOTRACK)
-
 #define OO_SHIFT	16
 #define OO_MASK		((1 << OO_SHIFT) - 1)
 #define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
@@ -1176,7 +1166,7 @@ out:
 
 __setup("slub_debug", setup_slub_debug);
 
-static unsigned long kmem_cache_flags(unsigned long object_size,
+unsigned long kmem_cache_flags(unsigned long object_size,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
 {
@@ -1208,7 +1198,7 @@ static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
 static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
-static inline unsigned long kmem_cache_flags(unsigned long object_size,
+unsigned long kmem_cache_flags(unsigned long object_size,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
 {
@@ -2707,12 +2697,6 @@ static int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
 static int slub_min_objects;
 
 /*
- * Merge control. If this is set then no merging of slab caches will occur.
- * (Could be removed. This was introduced to pacify the merge skeptics.)
- */
-static int slub_nomerge;
-
-/*
  * Calculate the order of allocation given an slab object size.
  *
  * The order of allocation has significant impact on performance and other
@@ -3240,14 +3224,6 @@ static int __init setup_slub_min_objects(char *str)
 
 __setup("slub_min_objects=", setup_slub_min_objects);
 
-static int __init setup_slub_nomerge(char *str)
-{
-	slub_nomerge = 1;
-	return 1;
-}
-
-__setup("slub_nomerge", setup_slub_nomerge);
-
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s;
@@ -3625,69 +3601,6 @@ void __init kmem_cache_init_late(void)
 {
 }
 
-/*
- * Find a mergeable slab cache
- */
-static int slab_unmergeable(struct kmem_cache *s)
-{
-	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
-		return 1;
-
-	if (!is_root_cache(s))
-		return 1;
-
-	if (s->ctor)
-		return 1;
-
-	/*
-	 * We may have set a slab to be unmergeable during bootstrap.
-	 */
-	if (s->refcount < 0)
-		return 1;
-
-	return 0;
-}
-
-static struct kmem_cache *find_mergeable(size_t size, size_t align,
-		unsigned long flags, const char *name, void (*ctor)(void *))
-{
-	struct kmem_cache *s;
-
-	if (slub_nomerge || (flags & SLUB_NEVER_MERGE))
-		return NULL;
-
-	if (ctor)
-		return NULL;
-
-	size = ALIGN(size, sizeof(void *));
-	align = calculate_alignment(flags, align, size);
-	size = ALIGN(size, align);
-	flags = kmem_cache_flags(size, flags, name, NULL);
-
-	list_for_each_entry(s, &slab_caches, list) {
-		if (slab_unmergeable(s))
-			continue;
-
-		if (size > s->size)
-			continue;
-
-		if ((flags & SLUB_MERGE_SAME) != (s->flags & SLUB_MERGE_SAME))
-			continue;
-		/*
-		 * Check if alignment is compatible.
-		 * Courtesy of Adrian Drzewiecki
-		 */
-		if ((s->size & ~(align - 1)) != s->size)
-			continue;
-
-		if (s->size - size >= sizeof(void *))
-			continue;
-
-		return s;
-	}
-	return NULL;
-}
-
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
