Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 44C6C6B0085
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:42:56 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 01/19] slab: Ignore internal flags in cache creation
Date: Fri, 12 Oct 2012 17:40:55 +0400
Message-Id: <1350049273-17213-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1350049273-17213-1-git-send-email-glommer@parallels.com>
References: <1350049273-17213-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Some flags are used internally by the allocators for management
purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
to mark that the metadata for that cache is stored outside of the slab.

No cache should ever pass those as a creation flags. We can just ignore
this bit if it happens to be passed (such as when duplicating a cache in
the kmem memcg patches).

Because such flags can vary from allocator to allocator, we allow them
to make their own decisions on that, defining SLAB_AVAILABLE_FLAGS with
all flags that are valid at creation time.  Allocators that doesn't have
any specific flag requirement should define that to mean all flags.

Common code will mask out all flags not belonging to that set.

[ v2: leave the mask out decision up to the allocators ]
[ v3: define flags for all allocators ]
[ v4: move all definitions to slab.h ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/slab.c        | 22 ----------------------
 mm/slab.h        | 25 +++++++++++++++++++++++++
 mm/slab_common.c |  7 +++++++
 mm/slub.c        |  3 ---
 4 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 87569af..eafef58 100644
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
diff --git a/mm/slab.h b/mm/slab.h
index 7deeb44..35b60b7 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -45,6 +45,31 @@ static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t siz
 #endif
 
 
+/* Legal flag mask for kmem_cache_create(), for various configurations */
+#define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
+			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
+
+#if defined(CONFIG_DEBUG_SLAB)
+#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
+#elif defined(CONFIG_SLUB_DEBUG)
+#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+			  SLAB_TRACE | SLAB_DEBUG_FREE)
+#else
+#define SLAB_DEBUG_FLAGS (0)
+#endif
+
+#if defined(CONFIG_SLAB)
+#define SLAB_CACHE_FLAGS (SLAB_MEM_SPREAD | SLAB_NOLEAKTRACE | \
+			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | SLAB_NOTRACK)
+#elif defined(CONFIG_SLUB)
+#define SLAB_CACHE_FLAGS (SLAB_NOLEAKTRACE | SLAB_RECLAIM_ACCOUNT | \
+			  SLAB_TEMPORARY | SLAB_NOTRACK)
+#else
+#define SLAB_CACHE_FLAGS (0)
+#endif
+
+#define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
+
 int __kmem_cache_shutdown(struct kmem_cache *);
 
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9c21725..0e2b8e3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -107,6 +107,13 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	if (!kmem_cache_sanity_check(name, size) == 0)
 		goto out_locked;
 
+	/*
+	 * Some allocators will constraint the set of valid flags to a subset
+	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
+	 * case, and we'll just provide them with a sanitized version of the
+	 * passed flags.
+	 */
+	flags &= CACHE_CREATE_MASK;
 
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
 	if (s)
diff --git a/mm/slub.c b/mm/slub.c
index 628a261..f50c5b2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -112,9 +112,6 @@
  * 			the fast path and disables lockless freelists.
  */
 
-#define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DEBUG_FREE)
-
 static inline int kmem_cache_debug(struct kmem_cache *s)
 {
 #ifdef CONFIG_SLUB_DEBUG
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
