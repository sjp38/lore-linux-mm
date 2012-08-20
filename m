Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E019E6B0088
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:44 -0400 (EDT)
Message-Id: <0000013945cd3467-ab9b2d3c-e7e6-457a-afa8-9f5d27a41fb7-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:39 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [08/19] Get rid of __kmem_cache_destroy
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

What is done there can be done in __kmem_cache_shutdown.

This affects RCU handling somewhat. On rcu free all slab allocators
do not refer to other management structures than the kmem_cache structure.
Therefore these other structures can be freed before the rcu deferred
free to the page allocator occurs.

Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   46 +++++++++++++++++++++-------------------------
 mm/slab.h        |    1 -
 mm/slab_common.c |    1 -
 mm/slob.c        |    4 ----
 mm/slub.c        |   10 +++++-----
 5 files changed, 26 insertions(+), 36 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 814cfc9..9449e7e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2198,26 +2198,6 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 	}
 }
 
-void __kmem_cache_destroy(struct kmem_cache *cachep)
-{
-	int i;
-	struct kmem_list3 *l3;
-
-	for_each_online_cpu(i)
-	    kfree(cachep->array[i]);
-
-	/* NUMA: free the list3 structures */
-	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
-		if (l3) {
-			kfree(l3->shared);
-			free_alien_cache(l3->alien);
-			kfree(l3);
-		}
-	}
-}
-
-
 /**
  * calculate_slab_order - calculate size (page order) of slabs
  * @cachep: pointer to the cache that is being created
@@ -2354,9 +2334,6 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
  * Cannot be called within a int, but can be interrupted.
  * The @ctor is run when new pages are allocated by the cache.
  *
- * @name must be valid until the cache is destroyed. This implies that
- * the module calling this has to destroy the cache before getting unloaded.
- *
  * The flags are
  *
  * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
@@ -2581,7 +2558,7 @@ __kmem_cache_create (const char *name, size_t size, size_t align,
 	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
-		__kmem_cache_destroy(cachep);
+		__kmem_cache_shutdown(cachep);
 		return NULL;
 	}
 
@@ -2756,7 +2733,26 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	return __cache_shrink(cachep);
+	int i;
+	struct kmem_list3 *l3;
+	int rc = __cache_shrink(cachep);
+
+	if (rc)
+		return rc;
+
+	for_each_online_cpu(i)
+	    kfree(cachep->array[i]);
+
+	/* NUMA: free the list3 structures */
+	for_each_online_node(i) {
+		l3 = cachep->nodelists[i];
+		if (l3) {
+			kfree(l3->shared);
+			free_alien_cache(l3->alien);
+			kfree(l3);
+		}
+	}
+	return 0;
 }
 
 /*
diff --git a/mm/slab.h b/mm/slab.h
index 6724aa6..c4f9a36 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -37,6 +37,5 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-void __kmem_cache_destroy(struct kmem_cache *);
 
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3e3c403..777cae0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -153,7 +153,6 @@ void kmem_cache_destroy(struct kmem_cache *s)
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
-			__kmem_cache_destroy(s);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
diff --git a/mm/slob.c b/mm/slob.c
index cb4ab96..50f6053 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -538,10 +538,6 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	return c;
 }
 
-void __kmem_cache_destroy(struct kmem_cache *c)
-{
-}
-
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
diff --git a/mm/slub.c b/mm/slub.c
index 8da785a..bb02589 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3205,12 +3205,12 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 
 int __kmem_cache_shutdown(struct kmem_cache *s)
 {
-	return kmem_cache_close(s);
-}
+	int rc = kmem_cache_close(s);
 
-void __kmem_cache_destroy(struct kmem_cache *s)
-{
-	sysfs_slab_remove(s);
+	if (!rc)
+		sysfs_slab_remove(s);
+
+	return rc;
 }
 
 /********************************************************************
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
