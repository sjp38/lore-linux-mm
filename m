Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD8C6B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:26:01 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so5474873pde.33
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:26:01 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id f5si21066987pat.14.2014.09.14.23.25.59
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 23:26:00 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 1/3] mm/slab_common: commonize slab merge logic
Date: Mon, 15 Sep 2014 15:25:55 +0900
Message-Id: <1410762357-7787-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Randy Dunlap <rdunlap@infradead.org>

Slab merge is good feature to reduce fragmentation. Now, it is only
applied to SLUB, but, it would be good to apply it to SLAB. This patch
is preparation step to apply slab merge to SLAB by commonizing slab
merge logic.

v2: add slab_nomerge kernel parameter and document for it.

Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 Documentation/kernel-parameters.txt |   14 ++++--
 mm/slab.h                           |   15 ++++++
 mm/slab_common.c                    |   91 +++++++++++++++++++++++++++++++++++
 mm/slub.c                           |   91 +----------------------------------
 4 files changed, 117 insertions(+), 94 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9344d83..a4543cf 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3112,6 +3112,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	slram=		[HW,MTD]
 
+	slab_nomerge	[MM]
+			Disable merging of slabs with similar size. May be
+			necessary if there is some reason to distinguish
+			allocs to different slabs. Debug options disable
+			merging on their own.
+			For more information see Documentation/vm/slub.txt.
+
 	slab_max_order=	[MM, SLAB]
 			Determines the maximum allowed order for slabs.
 			A high setting may cause OOMs due to memory
@@ -3147,11 +3154,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			For more information see Documentation/vm/slub.txt.
 
 	slub_nomerge	[MM, SLUB]
-			Disable merging of slabs with similar size. May be
-			necessary if there is some reason to distinguish
-			allocs to different slabs. Debug options disable
-			merging on their own.
-			For more information see Documentation/vm/slub.txt.
+			Same with slab_nomerge. This is supported for legacy.
+			See slab_nomerge for more information.
 
 	smart2=		[HW]
 			Format: <io1>[,<io2>[,...,<io8>]]
diff --git a/mm/slab.h b/mm/slab.h
index bd1c54a..857758b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -86,15 +86,30 @@ extern void create_boot_cache(struct kmem_cache *, const char *name,
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
index 2088904..f4468c0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -31,6 +31,34 @@ DEFINE_MUTEX(slab_mutex);
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
+
+#ifdef CONFIG_SLUB
+__setup("slub_nomerge", setup_slab_nomerge);
+#endif
+
+__setup("slab_nomerge", setup_slab_nomerge);
+
+/*
  * Determine the size of a slab object
  */
 unsigned int kmem_cache_size(struct kmem_cache *s)
@@ -115,6 +143,69 @@ out:
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
