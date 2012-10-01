Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 0460F6B002B
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 06:52:15 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2] slab: Ignore internal flags in cache creation
Date: Mon,  1 Oct 2012 14:47:38 +0400
Message-Id: <1349088458-3940-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

Some flags are used internally by the allocators for management
purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
to mark that the metadata for that cache is stored outside of the slab.

No cache should ever pass those as a creation flags. We can just ignore
this bit if it happens to be passed (such as when duplicating a cache in
the kmem memcg patches).

Because such flags can vary from allocator to allocator, we allow them
to make their own decisions on that. Those who want it, can define
CACHE_CREATE_MASK, with all flags that are valid at creation time.
Common code will mask out all flags not belonging to that set.

[ v2: leave the mask out decision up to the allocators ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 include/linux/slab_def.h | 19 +++++++++++++++++++
 mm/slab.c                | 22 ----------------------
 mm/slab_common.c         |  9 +++++++++
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 36d7031..f7ec03d 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -15,6 +15,25 @@
 #include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 #include <linux/compiler.h>
 
+/* Legal flag mask for kmem_cache_create(). */
+#ifdef CONFIG_DEBUG_SLAB 
+#define CACHE_CREATE_MASK (SLAB_RED_ZONE | 				\
+			SLAB_POISON | SLAB_HWCACHE_ALIGN | 		\
+			SLAB_CACHE_DMA | 				\
+			SLAB_STORE_USER | 				\
+			SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | 		\
+			SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD | 	\
+			SLAB_DEBUG_OBJECTS | SLAB_NOLEAKTRACE |	\
+			SLAB_NOTRACK)
+#else
+#define CACHE_CREATE_MASK (SLAB_HWCACHE_ALIGN | 			\
+			SLAB_CACHE_DMA | 				\
+			SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | 		\
+			SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD | 	\
+			SLAB_DEBUG_OBJECTS | SLAB_NOLEAKTRACE | 	\
+			SLAB_NOTRACK)
+#endif
+
 /*
  * struct kmem_cache
  *
diff --git a/mm/slab.c b/mm/slab.c
index 8524923..8c1d447 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -162,23 +162,6 @@
  */
 static bool pfmemalloc_active __read_mostly;
 
-/* Legal flag mask for kmem_cache_create(). */
-#if DEBUG
-# define CREATE_MASK	(SLAB_RED_ZONE | \
-			 SLAB_POISON | SLAB_HWCACHE_ALIGN | \
-			 SLAB_CACHE_DMA | \
-			 SLAB_STORE_USER | \
-			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD | \
-			 SLAB_DEBUG_OBJECTS | SLAB_NOLEAKTRACE | SLAB_NOTRACK)
-#else
-# define CREATE_MASK	(SLAB_HWCACHE_ALIGN | \
-			 SLAB_CACHE_DMA | \
-			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_MEM_SPREAD | \
-			 SLAB_DEBUG_OBJECTS | SLAB_NOLEAKTRACE | SLAB_NOTRACK)
-#endif
-
 /*
  * kmem_bufctl_t:
  *
@@ -2385,11 +2368,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (flags & SLAB_DESTROY_BY_RCU)
 		BUG_ON(flags & SLAB_POISON);
 #endif
-	/*
-	 * Always checks flags, a caller might be expecting debug support which
-	 * isn't available.
-	 */
-	BUG_ON(flags & ~CREATE_MASK);
 
 	/*
 	 * Check that size is in terms of words.  This is needed to avoid
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9c21725..f2682ee 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -107,6 +107,15 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	if (!kmem_cache_sanity_check(name, size) == 0)
 		goto out_locked;
 
+	/*
+	 * Some allocators will constraint the set of valid flags to a subset
+	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
+	 * case, and we'll just provide them with a sanitized version of the
+	 * passed flags.
+	 */
+#ifdef CACHE_CREATE_MASK
+	flags &= ~CACHE_CREATE_MASK;
+#endif
 
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
