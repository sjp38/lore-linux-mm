Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C0B236B00EF
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:16:15 -0400 (EDT)
Message-Id: <20120514201614.038013917@linux.com>
Date: Mon, 14 May 2012 15:15:53 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] SL[AUO]B common code 9/9] slabs: Extract a common function for kmem_cache_destroy
References: <20120514201544.334122849@linux.com>
Content-Disposition: inline; filename=kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

kmem_cache_destroy does basically the same in all allocators.

Extract common code which is easy since we already have common mutex handling.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.c        |   55 +++----------------------------------------------------
 mm/slab.h        |    4 +++-
 mm/slab_common.c |   22 ++++++++++++++++++++++
 mm/slob.c        |   11 +++++++----
 mm/slub.c        |   29 ++++++++---------------------
 5 files changed, 43 insertions(+), 78 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-14 08:39:29.827145790 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-14 08:39:42.867145519 -0500
@@ -113,6 +113,28 @@ out:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	get_online_cpus();
+	mutex_lock(&slab_mutex);
+	list_del(&s->list);
+
+	if (!__kmem_cache_shutdown(s)) {
+		if (s->flags & SLAB_DESTROY_BY_RCU)
+			rcu_barrier();
+
+		__kmem_cache_destroy(s);
+	} else {
+		list_add(&s->list, &slab_caches);
+		printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
+			s->name);
+		dump_stack();
+	}
+	mutex_unlock(&slab_mutex);
+	put_online_cpus();
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
 int slab_is_available(void)
 {
 	return slab_state >= UP;
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-14 08:39:29.831145790 -0500
+++ linux-2.6/mm/slab.c	2012-05-14 08:39:42.871145519 -0500
@@ -804,16 +804,6 @@ static void cache_estimate(unsigned long
 	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
 }
 
-#define slab_error(cachep, msg) __slab_error(__func__, cachep, msg)
-
-static void __slab_error(const char *function, struct kmem_cache *cachep,
-			char *msg)
-{
-	printk(KERN_ERR "slab error in %s(): cache `%s': %s\n",
-	       function, cachep->name, msg);
-	dump_stack();
-}
-
 /*
  * By default on NUMA we use alien caches to stage the freeing of
  * objects allocated from other nodes. This causes massive memory
@@ -2079,7 +2069,7 @@ static void slab_destroy(struct kmem_cac
 	}
 }
 
-static void __kmem_cache_destroy(struct kmem_cache *cachep)
+void __kmem_cache_destroy(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2635,49 +2625,10 @@ int kmem_cache_shrink(struct kmem_cache
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
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-05-14 08:39:27.195145844 -0500
+++ linux-2.6/mm/slab.h	2012-05-14 08:39:42.871145519 -0500
@@ -30,5 +30,7 @@ extern struct list_head slab_caches;
 struct kmem_cache *__kmem_cache_create (const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
-#endif
+int __kmem_cache_shutdown(struct kmem_cache *);
+void __kmem_cache_destroy(struct kmem_cache *);
 
+#endif
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-14 08:39:26.455145860 -0500
+++ linux-2.6/mm/slob.c	2012-05-14 08:39:42.871145519 -0500
@@ -570,14 +570,11 @@ struct kmem_cache *__kmem_cache_create(c
 	return c;
 }
 
-void kmem_cache_destroy(struct kmem_cache *c)
+void __kmem_cache_destroy(struct kmem_cache *c)
 {
 	kmemleak_free(c);
-	if (c->flags & SLAB_DESTROY_BY_RCU)
-		rcu_barrier();
 	slob_free(c, sizeof(struct kmem_cache));
 }
-EXPORT_SYMBOL(kmem_cache_destroy);
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
@@ -645,6 +642,12 @@ unsigned int kmem_cache_size(struct kmem
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
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-14 08:39:29.831145790 -0500
+++ linux-2.6/mm/slub.c	2012-05-14 08:39:42.871145519 -0500
@@ -3168,29 +3168,16 @@ static inline int kmem_cache_close(struc
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
+	kfree(s);
+	sysfs_slab_remove(s);
 }
-EXPORT_SYMBOL(kmem_cache_destroy);
 
 /********************************************************************
  *		Kmalloc subsystem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
