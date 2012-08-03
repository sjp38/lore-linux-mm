Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D58B46B0068
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 15:21:54 -0400 (EDT)
Message-Id: <20120803192152.983896137@linux.com>
Date: Fri, 03 Aug 2012 14:21:01 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common10 [09/20] Get rid of __kmem_cache_destroy
References: <20120803192052.448575403@linux.com>
Content-Disposition: inline; filename=no_slab_specific_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slob.c	2012-08-02 14:20:06.968599959 -0500
+++ linux-2.6/mm/slob.c	2012-08-02 14:20:14.452734107 -0500
@@ -538,10 +538,6 @@
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
--- linux-2.6.orig/mm/slub.c	2012-08-02 14:20:06.968599959 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 14:20:14.456734180 -0500
@@ -3198,12 +3198,12 @@
 
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
--- linux-2.6.orig/mm/slab.c	2012-08-02 14:20:06.968599959 -0500
+++ linux-2.6/mm/slab.c	2012-08-02 14:20:14.456734180 -0500
@@ -2205,26 +2205,6 @@
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
@@ -2588,7 +2568,7 @@
 	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
-		__kmem_cache_destroy(cachep);
+		__kmem_cache_shutdown(cachep);
 		return NULL;
 	}
 
@@ -2763,7 +2743,26 @@
 
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
--- linux-2.6.orig/mm/slab.h	2012-08-02 14:20:05.688577022 -0500
+++ linux-2.6/mm/slab.h	2012-08-02 14:20:14.456734180 -0500
@@ -37,6 +37,5 @@
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
 int __kmem_cache_shutdown(struct kmem_cache *);
-void __kmem_cache_destroy(struct kmem_cache *);
 
 #endif
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 14:20:06.964599888 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 14:20:14.456734180 -0500
@@ -143,7 +143,6 @@
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
