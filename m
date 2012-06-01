Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6052E6B0070
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:53:12 -0400 (EDT)
Message-Id: <20120601195310.415271849@linux.com>
Date: Fri, 01 Jun 2012 14:53:04 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [19/20] Allocate kmem_cache structure in slab_common.c
References: <20120601195245.084749371@linux.com>
Content-Disposition: inline; filename=move_kmem_alloc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Move kmem_cache memory allocation and the checks for success out of the
slab allocators into the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |  122 ++++++++++++++++++++-----------------------------------
 mm/slab.h        |    3 -
 mm/slab_common.c |   25 +++++++++--
 mm/slob.c        |   39 ++++++-----------
 mm/slub.c        |  107 ++++++++++++++++++++++--------------------------
 5 files changed, 134 insertions(+), 162 deletions(-)

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-06-01 08:26:42.794610001 -0500
+++ linux-2.6/mm/slab.h	2012-06-01 08:27:19.462609243 -0500
@@ -33,8 +33,7 @@ extern struct list_head slab_caches;
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *));
+int __kmem_cache_create(struct kmem_cache *s);
 
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-06-01 08:26:42.818610002 -0500
+++ linux-2.6/mm/slab_common.c	2012-06-01 08:27:19.490609240 -0500
@@ -54,6 +54,7 @@ struct kmem_cache *kmem_cache_create(con
 {
 	struct kmem_cache *s = NULL;
 	char *n;
+	int r;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -106,12 +107,30 @@ struct kmem_cache *kmem_cache_create(con
 	if (!n)
 		goto oops;
 
-	s = __kmem_cache_create(n, size, align, flags, ctor);
+	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 
-	if (s)
+	if (!s) {
+		kfree(n);
+		goto oops;
+	}
+
+	s->name = n;
+	s->size = s->object_size = size;
+	s->ctor = ctor;
+	s->flags = flags;
+	s->align = align;
+
+	r = __kmem_cache_create(s);
+
+	if (!r) {
+		s->refcount = 1;
 		list_add(&s->list, &slab_caches);
-	else
+	}
+	else {
+		kmem_cache_free(kmem_cache, s);
 		kfree(n);
+		s = NULL;
+	}
 
 oops:
 	mutex_unlock(&slab_mutex);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-06-01 08:26:42.766610003 -0500
+++ linux-2.6/mm/slub.c	2012-06-01 08:27:19.438609242 -0500
@@ -2999,24 +2999,17 @@ static int calculate_sizes(struct kmem_c
 
 }
 
-static int kmem_cache_open(struct kmem_cache *s,
-		const char *name, size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(void *))
+static int kmem_cache_open(struct kmem_cache *s)
 {
-	memset(s, 0, kmem_size);
-	s->name = name;
-	s->ctor = ctor;
-	s->object_size = size;
-	s->align = align;
-	s->flags = kmem_cache_flags(size, flags, name, ctor);
+	s->flags = kmem_cache_flags(s->size, s->flags, s->name, s->ctor);
 	s->reserved = 0;
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
 		s->reserved = sizeof(struct rcu_head);
 
 	if (!calculate_sizes(s, -1))
-		goto error;
+		return -EINVAL;
+
 	if (disable_higher_order_debug) {
 		/*
 		 * Disable debugging flags that store metadata if the min slab
@@ -3026,7 +3019,7 @@ static int kmem_cache_open(struct kmem_c
 			s->flags &= ~DEBUG_METADATA_FLAGS;
 			s->offset = 0;
 			if (!calculate_sizes(s, -1))
-				goto error;
+				return -EINVAL;
 		}
 	}
 
@@ -3071,23 +3064,16 @@ static int kmem_cache_open(struct kmem_c
 	else
 		s->cpu_partial = 30;
 
-	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
 	if (!init_kmem_cache_nodes(s))
-		goto error;
-
-	if (alloc_kmem_cache_cpus(s))
-		return 1;
+		return -ENOMEM;
 
-	free_kmem_cache_nodes(s);
-error:
-	if (flags & SLAB_PANIC)
-		panic("Cannot create slab %s size=%lu realsize=%u "
-			"order=%u offset=%u flags=%lx\n",
-			s->name, (unsigned long)size, s->size, oo_order(s->oo),
-			s->offset, flags);
+	if (!alloc_kmem_cache_cpus(s)) {
+		free_kmem_cache_nodes(s);
+		return -ENOMEM;
+	}
 	return 0;
 }
 
@@ -3229,23 +3215,25 @@ static struct kmem_cache *__init create_
 						int size, unsigned int flags)
 {
 	struct kmem_cache *s;
+	int r;
 
-	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
+	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+	s->name = name;
+	s->size = s->object_size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	s->flags = flags;
 
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slab_mutex here.
 	 */
-	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
-								flags, NULL))
-		goto panic;
+	r = kmem_cache_open(s);
+	if (r)
+		panic("Creation of kmalloc slab %s size=%d failed. Code %d\n",
+				name, size, r);
 
 	list_add(&s->list, &slab_caches);
 	return s;
-
-panic:
-	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
-	return NULL;
 }
 
 /*
@@ -3666,6 +3654,7 @@ static void __init kmem_cache_bootstrap_
 void __init kmem_cache_init(void)
 {
 	int i;
+	int r;
 	int caches = 0;
 	struct kmem_cache *temp_kmem_cache;
 	int order;
@@ -3689,10 +3678,13 @@ void __init kmem_cache_init(void)
 	 * kmem_cache_open for slab_state == DOWN.
 	 */
 	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
+	kmem_cache_node->name = "kmem_cache_node";
+	kmem_cache_node->size = kmem_cache_node->object_size = sizeof(struct kmem_cache_node);
+	kmem_cache_node->flags = SLAB_HWCACHE_ALIGN;
 
-	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	r = kmem_cache_open(kmem_cache_node);
+	if (r)
+		goto panic;
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
@@ -3700,8 +3692,14 @@ void __init kmem_cache_init(void)
 	slab_state = PARTIAL;
 
 	temp_kmem_cache = kmem_cache;
-	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache->name = "kmem_cache";
+	kmem_cache->size = kmem_cache->object_size = kmem_size;
+	kmem_cache->flags = SLAB_HWCACHE_ALIGN;
+
+	r = kmem_cache_open(kmem_cache);
+	if (r)
+		goto panic;
+
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
 
@@ -3823,6 +3821,10 @@ void __init kmem_cache_init(void)
 		caches, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
+	return;
+
+panic:
+	panic("SLUB bootstrap failed. Code %d\n", r);
 }
 
 void __init kmem_cache_init_late(void)
@@ -3914,29 +3916,22 @@ struct kmem_cache *__kmem_cache_alias(co
 	return s;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
-		size_t align, unsigned long flags, void (*ctor)(void *))
+int __kmem_cache_create(struct kmem_cache *s)
 {
-	struct kmem_cache *s;
+	int r = kmem_cache_open(s);
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
-	if (s) {
-		if (kmem_cache_open(s, name,
-				size, align, flags, ctor)) {
-			int r;
-
-			mutex_unlock(&slab_mutex);
-			r = sysfs_slab_add(s);
-			mutex_lock(&slab_mutex);
+	if (r)
+		return r;
 
-			if (!r)
-				return s;
+	mutex_unlock(&slab_mutex);
+	r = sysfs_slab_add(s);
+	mutex_lock(&slab_mutex);
 
-			kmem_cache_close(s);
-		}
-		kfree(s);
-	}
-	return NULL;
+	if (!r)
+		return 0;
+
+	kmem_cache_close(s);
+	return r;
 }
 
 #ifdef CONFIG_SMP
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-06-01 08:26:42.746610004 -0500
+++ linux-2.6/mm/slab.c	2012-06-01 08:27:19.418609242 -0500
@@ -1429,6 +1429,30 @@ static void __init set_up_list3s(struct
 	}
 }
 
+struct kmem_cache *create_kmalloc_cache(char *name, int size, int flags)
+{
+	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
+	int r = -ENOMEM;
+
+	if (!s)
+		goto panic;
+
+	s->name = name;
+	s->size = s->object_size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	s->flags = flags | ARCH_KMALLOC_FLAGS;
+
+	r = __kmem_cache_create(s);
+
+	if (r)
+		goto panic;
+
+	list_add(&s->list, &slab_caches);
+	return s;
+panic:
+	panic("Failed to create kmalloc cache %s. Size=%d Code=%d\n", name, size, r);
+}
+
 /*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
@@ -1524,22 +1548,13 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
-					sizes[INDEX_AC].cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
+	sizes[INDEX_AC].cs_cachep = create_kmalloc_cache(names[INDEX_AC].name,
+					sizes[INDEX_AC].cs_size, 0);
 
-	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
-	if (INDEX_AC != INDEX_L3) {
+	if (INDEX_AC != INDEX_L3)
 		sizes[INDEX_L3].cs_cachep =
-			__kmem_cache_create(names[INDEX_L3].name,
-				sizes[INDEX_L3].cs_size,
-				ARCH_KMALLOC_MINALIGN,
-				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-				NULL);
-		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
-	}
+			create_kmalloc_cache(names[INDEX_L3].name,
+				sizes[INDEX_L3].cs_size, 0);
 
 	slab_early_init = 0;
 
@@ -1551,23 +1566,13 @@ void __init kmem_cache_init(void)
 		 * Note for systems short on memory removing the alignment will
 		 * allow tighter packing of the smaller caches.
 		 */
-		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = __kmem_cache_create(names->name,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
-					NULL);
-			list_add(&sizes->cs_cachep->list, &slab_caches);
-		}
+		if (!sizes->cs_cachep)
+			sizes->cs_cachep = create_kmalloc_cache(names->name,
+					sizes->cs_size, 0);
+
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = __kmem_cache_create(
-					names->name_dma,
-					sizes->cs_size,
-					ARCH_KMALLOC_MINALIGN,
-					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
-						SLAB_PANIC,
-					NULL);
-		list_add(&sizes->cs_dmacachep->list, &slab_caches);
+		sizes->cs_dmacachep = create_kmalloc_cache(
+			names->name_dma, sizes->cs_size, SLAB_CACHE_DMA);
 #endif
 		sizes++;
 		names++;
@@ -2170,38 +2175,14 @@ static int __init_refok setup_cpu_cache(
 
 /**
  * __kmem_cache_create - Create a cache.
- * @name: A string which is used in /proc/slabinfo to identify this cache.
- * @size: The size of objects to be created in this cache.
- * @align: The required alignment for the objects.
- * @flags: SLAB flags
- * @ctor: A constructor for the objects.
- *
- * Returns a ptr to the cache on success, NULL on failure.
- * Cannot be called within a int, but can be interrupted.
- * The @ctor is run when new pages are allocated by the cache.
- *
- * @name must be valid until the cache is destroyed. This implies that
- * the module calling this has to destroy the cache before getting unloaded.
- *
- * The flags are
- *
- * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
- * to catch references to uninitialised memory.
- *
- * %SLAB_RED_ZONE - Insert `Red' zones around the allocated memory to check
- * for buffer overruns.
- *
- * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
- * cacheline.  This can be beneficial if you're counting cycles as closely
- * as davem.
  */
-struct kmem_cache *
-__kmem_cache_create (const char *name, size_t size, size_t align,
-	unsigned long flags, void (*ctor)(void *))
+int __kmem_cache_create(struct kmem_cache *cachep)
 {
 	size_t left_over, slab_size, ralign;
-	struct kmem_cache *cachep = NULL;
 	gfp_t gfp;
+	int flags = cachep->flags;
+	int size = cachep->object_size;
+	int align;
 
 #if DEBUG
 #if FORCED_DEBUG
@@ -2273,8 +2254,8 @@ __kmem_cache_create (const char *name, s
 		ralign = ARCH_SLAB_MINALIGN;
 	}
 	/* 3) caller mandated alignment */
-	if (ralign < align) {
-		ralign = align;
+	if (ralign < cachep->align) {
+		ralign = cachep->align;
 	}
 	/* disable debug if necessary */
 	if (ralign > __alignof__(unsigned long long))
@@ -2289,11 +2270,6 @@ __kmem_cache_create (const char *name, s
 	else
 		gfp = GFP_NOWAIT;
 
-	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(kmem_cache, gfp);
-	if (!cachep)
-		return NULL;
-
 	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
 	cachep->object_size = size;
 	cachep->align = align;
@@ -2345,12 +2321,9 @@ __kmem_cache_create (const char *name, s
 
 	left_over = calculate_slab_order(cachep, size, align, flags);
 
-	if (!cachep->num) {
-		printk(KERN_ERR
-		       "kmem_cache_create: couldn't create cache %s.\n", name);
-		kmem_cache_free(kmem_cache, cachep);
-		return NULL;
-	}
+	if (!cachep->num)
+		return -EINVAL;
+
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
 			  + sizeof(struct slab), align);
 
@@ -2402,13 +2375,10 @@ __kmem_cache_create (const char *name, s
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->ctor = ctor;
-	cachep->name = name;
-	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_shutdown(cachep);
-		return NULL;
+		return -ENOMEM;
 	}
 
 	if (flags & SLAB_DEBUG_OBJECTS) {
@@ -2421,7 +2391,7 @@ __kmem_cache_create (const char *name, s
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	return cachep;
+	return 0;
 }
 
 #if DEBUG
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-06-01 08:26:42.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-06-01 08:27:33.298609009 -0500
@@ -508,34 +508,23 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *))
+int __kmem_cache_create(struct kmem_cache *c)
 {
-	struct kmem_cache *c;
+	int align = c->align;
 
-	c = slob_alloc(sizeof(struct kmem_cache),
-		GFP_KERNEL, ARCH_KMALLOC_MINALIGN, -1);
-
-	if (c) {
-		c->name = name;
-		c->size = c->object_size;
-		if (flags & SLAB_DESTROY_BY_RCU) {
-			/* leave room for rcu footer at the end of object */
-			c->size += sizeof(struct slob_rcu);
-		}
-		c->flags = flags;
-		c->ctor = ctor;
-		/* ignore alignment unless it's forced */
-		c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
-		if (c->align < ARCH_SLAB_MINALIGN)
-			c->align = ARCH_SLAB_MINALIGN;
-		if (c->align < align)
-			c->align = align;
-
-		kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-		c->refcount = 1;
+	if (c->flags & SLAB_DESTROY_BY_RCU) {
+		/* leave room for rcu footer at the end of object */
+		c->size += sizeof(struct slob_rcu);
 	}
-	return c;
+	/* ignore alignment unless it's forced */
+	c->align = (c->flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
+	if (c->align < ARCH_SLAB_MINALIGN)
+		c->align = ARCH_SLAB_MINALIGN;
+	if (c->align < align)
+		c->align = align;
+
+	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+	return 0;
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
