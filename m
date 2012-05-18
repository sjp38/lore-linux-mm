Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C22258D0004
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:19:35 -0400 (EDT)
Message-Id: <20120518161933.891500516@linux.com>
Date: Fri, 18 May 2012 11:19:18 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] Common code 12/12] [slauob]: Get rid of __kmem_cache_destroy
References: <20120518161906.207356777@linux.com>
Content-Disposition: inline; filename=no_slab_specific_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

Actions done there can be done in __kmem_cache_shutdown.

This affects RCU handling somewhat. On rcu free all slab allocators
do not refer to other management structures than the kmem_cache structure.
Therefore these other structures can be freed before the rcu deferred
free to the page allocator occurs.

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
--- linux-2.6.orig/mm/slob.c	2012-05-18 03:37:48.184359806 -0500
+++ linux-2.6/mm/slob.c	2012-05-18 03:39:12.100358071 -0500
@@ -570,10 +570,6 @@ struct kmem_cache *__kmem_cache_create(c
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
--- linux-2.6.orig/mm/slub.c	2012-05-18 03:37:48.184359806 -0500
+++ linux-2.6/mm/slub.c	2012-05-18 03:39:12.104358068 -0500
@@ -3170,12 +3170,12 @@ static inline int kmem_cache_close(struc
 
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
--- linux-2.6.orig/mm/slab.c	2012-05-18 03:37:48.188359801 -0500
+++ linux-2.6/mm/slab.c	2012-05-18 03:39:12.104358068 -0500
@@ -2071,26 +2071,6 @@ static void slab_destroy(struct kmem_cac
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
@@ -2453,7 +2433,7 @@ __kmem_cache_create (const char *name, s
 	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
-		__kmem_cache_destroy(cachep);
+		__kmem_cache_shutdown(cachep);
 		return NULL;
 	}
 
@@ -2628,7 +2608,26 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 
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
--- linux-2.6.orig/mm/slab.h	2012-05-18 03:36:21.724361601 -0500
+++ linux-2.6/mm/slab.h	2012-05-18 03:39:12.104358068 -0500
@@ -37,6 +37,5 @@ struct kmem_cache *__kmem_cache_create (
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-void __kmem_cache_destroy(struct kmem_cache *);
 
 #endif
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-18 04:08:38.324321471 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-18 04:16:04.928312217 -0500
@@ -128,7 +128,6 @@ void kmem_cache_destroy(struct kmem_cach
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 
-		__kmem_cache_destroy(s);
 		kmem_cache_free(kmem_cache, s);
 	} else {
 		list_add(&s->list, &slab_caches);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
