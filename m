Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 514436B0073
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:39 -0400 (EDT)
Message-Id: <0000013945cd24f3-3c3db163-3d7a-40fa-92bd-505449d78eaf-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [05/19] Extract a common function for kmem_cache_destroy
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

kmem_cache_destroy does basically the same in all allocators.

Extract common code which is easy since we already have common mutex handling.

V1-V2:
	- Move percpu freeing to later so that we fail cleaner if
		objects are left in the cache [JoonSoo Kim]

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   55 +++---------------------------------------------------
 mm/slab.h        |    3 +++
 mm/slab_common.c |   25 +++++++++++++++++++++++++
 mm/slob.c        |   15 +++++++--------
 mm/slub.c        |   36 +++++++++++------------------------
 5 files changed, 49 insertions(+), 85 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a699031..6826d93 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -803,16 +803,6 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
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
@@ -2206,7 +2196,7 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 	}
 }
 
-static void __kmem_cache_destroy(struct kmem_cache *cachep)
+void __kmem_cache_destroy(struct kmem_cache *cachep)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2763,49 +2753,10 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
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
diff --git a/mm/slab.h b/mm/slab.h
index db7848c..07a537e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -30,4 +30,7 @@ extern struct list_head slab_caches;
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
+int __kmem_cache_shutdown(struct kmem_cache *);
+void __kmem_cache_destroy(struct kmem_cache *);
+
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d419a3e..5cc1371 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
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
diff --git a/mm/slob.c b/mm/slob.c
index 5225d28..289be4f 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -538,18 +538,11 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
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
@@ -617,6 +610,12 @@ unsigned int kmem_cache_size(struct kmem_cache *c)
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
diff --git a/mm/slub.c b/mm/slub.c
index 37d5177..c99c0af 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -624,7 +624,7 @@ static void object_err(struct kmem_cache *s, struct page *page,
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct page *page, char *fmt, ...)
+static void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...)
 {
 	va_list args;
 	char buf[100];
@@ -3146,7 +3146,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 				     sizeof(long), GFP_ATOMIC);
 	if (!map)
 		return;
-	slab_err(s, page, "%s", text);
+	slab_err(s, page, text, s->name);
 	slab_lock(page);
 
 	get_map(s, page, map);
@@ -3178,7 +3178,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 			discard_slab(s, page);
 		} else {
 			list_slab_objects(s, page,
-				"Objects remaining on kmem_cache_close()");
+			"Objects remaining in %s on kmem_cache_close()");
 		}
 	}
 }
@@ -3191,7 +3191,6 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 	int node;
 
 	flush_all(s);
-	free_percpu(s->cpu_slab);
 	/* Attempt to free all objects */
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
@@ -3200,33 +3199,20 @@ static inline int kmem_cache_close(struct kmem_cache *s)
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
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
