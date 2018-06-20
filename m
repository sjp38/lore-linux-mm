Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A127C6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:42:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 31-v6so553646plf.19
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:42:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10-v6sor924304pfl.108.2018.06.20.15.42.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 15:42:03 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] slub: track number of slabs irrespective of CONFIG_SLUB_DEBUG
Date: Wed, 20 Jun 2018 15:41:47 -0700
Message-Id: <20180620224147.23777-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org

For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
allocated per node for a kmem_cache. Thus, slabs_node() in
__kmem_cache_empty(), __kmem_cache_shrink() and __kmem_cache_destroy()
will always return 0 for such config. This is wrong and can cause issues
for all users of these functions.

Infact in [1] Jason has reported a system crash while using SLUB without
CONFIG_SLUB_DEBUG. The reason was the usage of slabs_node() by
__kmem_cache_empty().

The right solution is to make slabs_node() work even for
!CONFIG_SLUB_DEBUG. The commit 0f389ec63077 ("slub: No need for per node
slab counters if !SLUB_DEBUG") had put the per node slab counter under
CONFIG_SLUB_DEBUG because it was only read through sysfs API and the
sysfs API was disabled on !CONFIG_SLUB_DEBUG. However the users of the
per node slab counter assumed that it will work in the absence of
CONFIG_SLUB_DEBUG. So, make the counter work for !CONFIG_SLUB_DEBUG.

Please note that commit f9e13c0a5a33 ("slab, slub: skip unnecessary
kasan_cache_shutdown()") exposed this issue but it is present even
before.

[1] http://lkml.kernel.org/r/CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com

Fixes: f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Suggested-by: David Rientjes <rientjes@google.com>
Reported-by: Jason A . Donenfeld <Jason@zx2c4.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: <stable@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: <linux-kernel@vger.kernel.org>
---
 mm/slab.h |  2 +-
 mm/slub.c | 80 +++++++++++++++++++++++++------------------------------
 2 files changed, 38 insertions(+), 44 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 68bdf498da3b..a6545332cc86 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -473,8 +473,8 @@ struct kmem_cache_node {
 #ifdef CONFIG_SLUB
 	unsigned long nr_partial;
 	struct list_head partial;
-#ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
+#ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t total_objects;
 	struct list_head full;
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index a3b8467c14af..c9c190d54687 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1030,42 +1030,6 @@ static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct
 	list_del(&page->lru);
 }
 
-/* Tracking of the number of slabs for debugging purposes */
-static inline unsigned long slabs_node(struct kmem_cache *s, int node)
-{
-	struct kmem_cache_node *n = get_node(s, node);
-
-	return atomic_long_read(&n->nr_slabs);
-}
-
-static inline unsigned long node_nr_slabs(struct kmem_cache_node *n)
-{
-	return atomic_long_read(&n->nr_slabs);
-}
-
-static inline void inc_slabs_node(struct kmem_cache *s, int node, int objects)
-{
-	struct kmem_cache_node *n = get_node(s, node);
-
-	/*
-	 * May be called early in order to allocate a slab for the
-	 * kmem_cache_node structure. Solve the chicken-egg
-	 * dilemma by deferring the increment of the count during
-	 * bootstrap (see early_kmem_cache_node_alloc).
-	 */
-	if (likely(n)) {
-		atomic_long_inc(&n->nr_slabs);
-		atomic_long_add(objects, &n->total_objects);
-	}
-}
-static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects)
-{
-	struct kmem_cache_node *n = get_node(s, node);
-
-	atomic_long_dec(&n->nr_slabs);
-	atomic_long_sub(objects, &n->total_objects);
-}
-
 /* Object debug checks for alloc/free paths */
 static void setup_object_debug(struct kmem_cache *s, struct page *page,
 								void *object)
@@ -1321,16 +1285,46 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 
 #define disable_higher_order_debug 0
 
+#endif /* CONFIG_SLUB_DEBUG */
+
 static inline unsigned long slabs_node(struct kmem_cache *s, int node)
-							{ return 0; }
+{
+	struct kmem_cache_node *n = get_node(s, node);
+
+	return atomic_long_read(&n->nr_slabs);
+}
+
 static inline unsigned long node_nr_slabs(struct kmem_cache_node *n)
-							{ return 0; }
-static inline void inc_slabs_node(struct kmem_cache *s, int node,
-							int objects) {}
-static inline void dec_slabs_node(struct kmem_cache *s, int node,
-							int objects) {}
+{
+	return atomic_long_read(&n->nr_slabs);
+}
 
-#endif /* CONFIG_SLUB_DEBUG */
+static inline void inc_slabs_node(struct kmem_cache *s, int node, int objects)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+
+	/*
+	 * May be called early in order to allocate a slab for the
+	 * kmem_cache_node structure. Solve the chicken-egg
+	 * dilemma by deferring the increment of the count during
+	 * bootstrap (see early_kmem_cache_node_alloc).
+	 */
+	if (likely(n)) {
+		atomic_long_inc(&n->nr_slabs);
+#ifdef CONFIG_SLUB_DEBUG
+		atomic_long_add(objects, &n->total_objects);
+#endif
+	}
+}
+static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+
+	atomic_long_dec(&n->nr_slabs);
+#ifdef CONFIG_SLUB_DEBUG
+	atomic_long_sub(objects, &n->total_objects);
+#endif
+}
 
 /*
  * Hooks for other subsystems that check memory allocations. In a typical
-- 
2.18.0.rc1.244.gcf134e6275-goog
