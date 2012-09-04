Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id AA2EE6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:18:34 -0400 (EDT)
Message-Id: <000001399393fdb9-1bf6cd5b-c1dc-4133-873e-de8623b04a0e-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:18:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [05/14] Extract a common function for kmem_cache_destroy
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

kmem_cache_destroy does basically the same in all allocators.

Extract common code which is easy since we already have common mutex handling.

V1-V2:
	- Move percpu freeing to later so that we fail cleaner if
		objects are left in the cache [JoonSoo Kim]

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   55 +++---------------------------------------------------
 mm/slab.h        |    3 +++
 mm/slab_common.c |   25 +++++++++++++++++++++++++
 mm/slob.c        |   15 +++++++--------
 mm/slub.c        |   36 +++++++++++------------------------
 5 files changed, 49 insertions(+), 85 deletions(-)

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-04 18:00:16.746080846 -0500
+++ linux/mm/slab.c	2012-09-04 18:01:58.303665841 -0500
@@ -2206,7 +2206,7 @@ static void slab_destroy(struct kmem_cac
 	}
 }
 
-static void __kmem_cache_destroy(struct kmem_cache *cachep)
+void __kmem_cache_destroy(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2763,49 +2763,10 @@ int kmem_cache_shrink(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
-/**
- * kmem_cache_destroy - delete a cache
- * @cachep: the cache to destroy
- *
- * Remove a &struct kmem_cache object from the slab cache.
- *
- * It is expected this function will be called by a module when it is
- * unloaded.  This will remove the cache completely, and avoid a duplicate
- * cache being allocated each time a module is loaded and unloaded, if the
- * module doesn't have persistent in-kernel storage across loads and unloads.
- *
- * The cache must be empty before calling this function.
- *
- * The caller must guarantee that no one will allocate memory from the cache
- * during the kmem_cache_destroy().
- */
-void kmem_cache_destroy(struct kmem_cache *cachep)
+int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
-	BUG_ON(!cachep || in_interrupt());
-
-	/* Find the cache in the chain of caches. */
-	get_online_cpus();
-	mutex_lock(&slab_mutex);
-	/*
-	 * the chain is never empty, cache_cache is never destroyed
-	 */
-	list_del(&cachep->list);
-	if (__cache_shrink(cachep)) {
-		slab_error(cachep, "Can't free all objects");
-		list_add(&cachep->list, &slab_caches);
-		mutex_unlock(&slab_mutex);
-		put_online_cpus();
-		return;
-	}
-
-	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
-		rcu_barrier();
-
-	__kmem_cache_destroy(cachep);
-	mutex_unlock(&slab_mutex);
-	put_online_cpus();
+	return __cache_shrink(cachep);
 }
-EXPORT_SYMBOL(kmem_cache_destroy);
 
 /*
  * Get the memory for a slab management obj.
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-04 17:57:07.447126505 -0500
+++ linux/mm/slab.h	2012-09-04 18:01:58.295665715 -0500
@@ -30,4 +30,7 @@ extern struct list_head slab_caches;
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
+int __kmem_cache_shutdown(struct kmem_cache *);
+void __kmem_cache_destroy(struct kmem_cache *);
+
 #endif
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.746080846 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:58.323666153 -0500
@@ -140,6 +140,31 @@ out_locked:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	get_online_cpus();
+	mutex_lock(&slab_mutex);
+	s->refcount--;
+	if (!s->refcount) {
+		list_del(&s->list);
+
+		if (!__kmem_cache_shutdown(s)) {
+			if (s->flags & SLAB_DESTROY_BY_RCU)
+				rcu_barrier();
+
+			__kmem_cache_destroy(s);
+		} else {
+			list_add(&s->list, &slab_caches);
+			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
+				s->name);
+			dump_stack();
+		}
+	}
+	mutex_unlock(&slab_mutex);
+	put_online_cpus();
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
 int slab_is_available(void)
 {
 	return slab_state >= UP;
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-09-04 18:00:16.746080846 -0500
+++ linux/mm/slob.c	2012-09-04 18:01:58.315666027 -0500
@@ -538,18 +538,11 @@ struct kmem_cache *__kmem_cache_create(c
 	return c;
 }
 
-void kmem_cache_destroy(struct kmem_cache *c)
+void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	mutex_lock(&slab_mutex);
-	list_del(&c->list);
-	mutex_unlock(&slab_mutex);
-
 	kmemleak_free(c);
-	if (c->flags & SLAB_DESTROY_BY_RCU)
-		rcu_barrier();
 	slob_free(c, sizeof(struct kmem_cache));
 }
-EXPORT_SYMBOL(kmem_cache_destroy);
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
@@ -617,6 +610,12 @@ unsigned int kmem_cache_size(struct kmem
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+int __kmem_cache_shutdown(struct kmem_cache *c)
+{
+	/* No way to check for remaining objects */
+	return 0;
+}
+
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.750080900 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:58.335666339 -0500
@@ -624,7 +624,7 @@ static void object_err(struct kmem_cache
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page, char *fmt, ...)
+static void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...)
 {
 	va_list args;
 	char buf[100];
@@ -3146,7 +3146,7 @@ static void list_slab_objects(struct kme
 				     sizeof(long), GFP_ATOMIC);
 	if (!map)
 		return;
-	slab_err(s, page, "%s", text);
+	slab_err(s, page, text, s->name);
 	slab_lock(page);
 
 	get_map(s, page, map);
@@ -3178,7 +3178,7 @@ static void free_partial(struct kmem_cac
 			discard_slab(s, page);
 		} else {
 			list_slab_objects(s, page,
-				"Objects remaining on kmem_cache_close()");
+			"Objects remaining in %s on kmem_cache_close()");
 		}
 	}
 }
@@ -3191,7 +3191,6 @@ static inline int kmem_cache_close(struc
 	int node;
 
 	flush_all(s);
-	free_percpu(s->cpu_slab);
 	/* Attempt to free all objects */
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
@@ -3200,33 +3199,20 @@ static inline int kmem_cache_close(struc
 		if (n->nr_partial || slabs_node(s, node))
 			return 1;
 	}
+	free_percpu(s->cpu_slab);
 	free_kmem_cache_nodes(s);
 	return 0;
 }
 
-/*
- * Close a cache and release the kmem_cache structure
- * (must be used for caches created using kmem_cache_create)
- */
-void kmem_cache_destroy(struct kmem_cache *s)
+int __kmem_cache_shutdown(struct kmem_cache *s)
 {
-	mutex_lock(&slab_mutex);
-	s->refcount--;
-	if (!s->refcount) {
-		list_del(&s->list);
-		mutex_unlock(&slab_mutex);
-		if (kmem_cache_close(s)) {
-			printk(KERN_ERR "SLUB %s: %s called for cache that "
-				"still has objects.\n", s->name, __func__);
-			dump_stack();
-		}
-		if (s->flags & SLAB_DESTROY_BY_RCU)
-			rcu_barrier();
-		sysfs_slab_remove(s);
-	} else
-		mutex_unlock(&slab_mutex);
+	return kmem_cache_close(s);
+}
+
+void __kmem_cache_destroy(struct kmem_cache *s)
+{
+	sysfs_slab_remove(s);
 }
-EXPORT_SYMBOL(kmem_cache_destroy);
 
 /********************************************************************
  *		Kmalloc subsystem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
