Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id BFB146B0069
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:36:37 -0400 (EDT)
Message-Id: <20120731173635.856498317@linux.com>
Date: Tue, 31 Jul 2012 12:36:24 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [4/9] Extract a common function for kmem_cache_destroy
References: <20120731173620.432853182@linux.com>
Content-Disposition: inline; filename=kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

kmem_cache_destroy does basically the same in all allocators.

Extract common code which is easy since we already have common mutex handling.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.c        |   55 +++----------------------------------------------------
 mm/slab.h        |    3 +++
 mm/slab_common.c |   25 +++++++++++++++++++++++++
 mm/slob.c        |   11 +++++++----
 mm/slub.c        |   35 +++++++++++------------------------
 5 files changed, 49 insertions(+), 80 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-07-31 12:15:59.691331459 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-31 12:16:00.531346043 -0500
@@ -121,6 +121,31 @@
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
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-31 12:15:59.691331459 -0500
+++ linux-2.6/mm/slab.c	2012-07-31 12:16:00.531346043 -0500
@@ -779,16 +779,6 @@
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
@@ -2055,7 +2045,7 @@
 	}
 }
 
-static void __kmem_cache_destroy(struct kmem_cache *cachep)
+void __kmem_cache_destroy(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2612,49 +2602,10 @@
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
--- linux-2.6.orig/mm/slab.h	2012-07-31 12:15:50.027163690 -0500
+++ linux-2.6/mm/slab.h	2012-07-31 12:16:00.531346043 -0500
@@ -30,4 +30,7 @@
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
+int __kmem_cache_shutdown(struct kmem_cache *);
+void __kmem_cache_destroy(struct kmem_cache *);
+
 #endif
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-07-31 12:15:50.047164037 -0500
+++ linux-2.6/mm/slob.c	2012-07-31 12:16:00.531346043 -0500
@@ -538,14 +538,11 @@
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
@@ -613,6 +610,12 @@
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
--- linux-2.6.orig/mm/slub.c	2012-07-31 12:15:59.691331459 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 12:16:18.271653725 -0500
@@ -622,7 +622,7 @@
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page, char *fmt, ...)
+static void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...)
 {
 	va_list args;
 	char buf[100];
@@ -3115,7 +3115,7 @@
 				     sizeof(long), GFP_ATOMIC);
 	if (!map)
 		return;
-	slab_err(s, page, "%s", text);
+	slab_err(s, page, text, s->name);
 	slab_lock(page);
 
 	get_map(s, page, map);
@@ -3147,7 +3147,7 @@
 			discard_slab(s, page);
 		} else {
 			list_slab_objects(s, page,
-				"Objects remaining on kmem_cache_close()");
+			"Objects remaining in %s on kmem_cache_close()");
 		}
 	}
 }
@@ -3173,29 +3173,15 @@
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
