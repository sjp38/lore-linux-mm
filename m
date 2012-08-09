Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 83B936B006E
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:51 -0400 (EDT)
Message-Id: <20120809135634.966198614@linux.com>
Date: Thu, 09 Aug 2012 08:56:32 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [09/20] Get rid of __kmem_cache_destroy
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=no_slab_specific_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

What is done there can be done in __kmem_cache_shutdown.

This affects RCU handling somewhat. On rcu free all slab allocators
do not refer to other management structures than the kmem_cache structure.
Therefore these other structures can be freed before the rcu deferred
free to the page allocator occurs.

Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |   43 +++++++++++++++++++++----------------------
 mm/slab.h        |    1 -
 mm/slab_common.c |    1 -
 mm/slob.c        |    4 ----
 mm/slub.c        |   10 +++++-----
 5 files changed, 26 insertions(+), 33 deletions(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-08 09:54:14.412139056 -0500
+++ linux-2.6/mm/slob.c	2012-08-09 08:52:56.767926051 -0500
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
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 09:54:14.412139056 -0500
+++ linux-2.6/mm/slub.c	2012-08-09 08:53:26.464693215 -0500
@@ -3198,12 +3198,12 @@ static inline int kmem_cache_close(struc
 
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
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-08 09:54:14.412139056 -0500
+++ linux-2.6/mm/slab.c	2012-08-09 08:52:56.759925844 -0500
@@ -2205,26 +2205,6 @@ static void slab_destroy(struct kmem_cac
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
@@ -2361,9 +2341,6 @@ static int __init_refok setup_cpu_cache(
  * Cannot be called within a int, but can be interrupted.
  * The @ctor is run when new pages are allocated by the cache.
  *
- * @name must be valid until the cache is destroyed. This implies that
- * the module calling this has to destroy the cache before getting unloaded.
- *
  * The flags are
  *
  * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
@@ -2588,7 +2565,7 @@ __kmem_cache_create (const char *name, s
 	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
-		__kmem_cache_destroy(cachep);
+		__kmem_cache_shutdown(cachep);
 		return NULL;
 	}
 
@@ -2763,7 +2740,26 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 
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
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-08 09:54:08.412128035 -0500
+++ linux-2.6/mm/slab.h	2012-08-09 08:53:26.372690845 -0500
@@ -37,6 +37,5 @@ struct kmem_cache *__kmem_cache_create(c
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-void __kmem_cache_destroy(struct kmem_cache *);
 
 #endif
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 09:54:14.412139056 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-09 08:53:26.452692905 -0500
@@ -143,7 +143,6 @@ void kmem_cache_destroy(struct kmem_cach
 			if (s->flags & SLAB_DESTROY_BY_RCU)
 				rcu_barrier();
 
-			__kmem_cache_destroy(s);
 			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
