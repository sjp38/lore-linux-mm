Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E6DDD6B006E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:38:34 -0400 (EDT)
Message-Id: <0000013993a64e65-040bae0f-e472-4ec5-b49e-ecc834fb8ef3-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:38:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [08/14] Get rid of __kmem_cache_destroy
References: <20120904230609.691088980@linux.com>
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

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-04 18:00:16.790081538 -0500
+++ linux/mm/slab.c	2012-09-04 18:01:54.239602415 -0500
@@ -2208,26 +2208,6 @@ static void slab_destroy(struct kmem_cac
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
@@ -2364,9 +2344,6 @@ static int __init_refok setup_cpu_cache(
  * Cannot be called within a int, but can be interrupted.
  * The @ctor is run when new pages are allocated by the cache.
  *
- * @name must be valid until the cache is destroyed. This implies that
- * the module calling this has to destroy the cache before getting unloaded.
- *
  * The flags are
  *
  * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
@@ -2591,7 +2568,7 @@ __kmem_cache_create (const char *name, s
 	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
-		__kmem_cache_destroy(cachep);
+		__kmem_cache_shutdown(cachep);
 		return NULL;
 	}
 
@@ -2766,7 +2743,26 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 
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
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-04 18:00:16.774081296 -0500
+++ linux/mm/slab.h	2012-09-04 18:01:55.523622455 -0500
@@ -37,6 +37,5 @@ struct kmem_cache *__kmem_cache_create(c
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-void __kmem_cache_destroy(struct kmem_cache *);
 
 #endif
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.790081538 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:56.147632189 -0500
@@ -153,7 +153,6 @@ void kmem_cache_destroy(struct kmem_cach
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
-			__kmem_cache_destroy(s);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-09-04 18:00:16.790081538 -0500
+++ linux/mm/slob.c	2012-09-04 18:01:54.247602537 -0500
@@ -538,10 +538,6 @@ struct kmem_cache *__kmem_cache_create(c
 	return c;
 }
 
-void __kmem_cache_destroy(struct kmem_cache *c)
-{
-}
-
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.790081538 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:56.159632381 -0500
@@ -3205,12 +3205,12 @@ static inline int kmem_cache_close(struc
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
