Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 47DB16B0074
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:53 -0400 (EDT)
Message-Id: <20120809135635.632045122@linux.com>
Date: Thu, 09 Aug 2012 08:56:36 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [13/20] Move kmem_cache allocations into common code.
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=kmem_alloc_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Shift the allocations to common code. That way the allocation
and freeing of the kmem_cache structures is handled by common code.

V2->V3: Use GFP_KERNEL instead of GFP_NOWAIT (JoonSoo Kim).
V1->V2: Use the return code from setup_cpucache() in slab instead of returning -ENOSPC


Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-08 12:56:08.517806807 -0500
+++ linux-2.6/mm/slab.c	2012-08-08 12:56:19.405836235 -0500
@@ -1673,7 +1673,8 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = __kmem_cache_create(names[INDEX_AC].name,
+	sizes[INDEX_AC].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+	__kmem_cache_create(sizes[INDEX_AC].cs_cachep, names[INDEX_AC].name,
 					sizes[INDEX_AC].cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
@@ -1681,8 +1682,8 @@ void __init kmem_cache_init(void)
 
 	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
-		sizes[INDEX_L3].cs_cachep =
-			__kmem_cache_create(names[INDEX_L3].name,
+		sizes[INDEX_L3].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+		__kmem_cache_create(sizes[INDEX_L3].cs_cachep, names[INDEX_L3].name,
 				sizes[INDEX_L3].cs_size,
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
@@ -1701,7 +1702,8 @@ void __init kmem_cache_init(void)
 		 * allow tighter packing of the smaller caches.
 		 */
 		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = __kmem_cache_create(names->name,
+			sizes->cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+			__kmem_cache_create(sizes->cs_cachep, names->name,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
@@ -1709,7 +1711,8 @@ void __init kmem_cache_init(void)
 			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = __kmem_cache_create(
+		sizes->cs_dmacachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+		__kmem_cache_create(sizes->cs_dmacachep,
 					names->name_dma,
 					sizes->cs_size,
 					ARCH_KMALLOC_MINALIGN,
@@ -2353,13 +2356,13 @@ static int __init_refok setup_cpu_cache(
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-struct kmem_cache *
-__kmem_cache_create (const char *name, size_t size, size_t align,
+int
+__kmem_cache_create (struct kmem_cache *cachep, const char *name, size_t size, size_t align,
 	unsigned long flags, void (*ctor)(void *))
 {
 	size_t left_over, slab_size, ralign;
-	struct kmem_cache *cachep = NULL;
 	gfp_t gfp;
+	int err;
 
 #if DEBUG
 #if FORCED_DEBUG
@@ -2447,11 +2450,6 @@ __kmem_cache_create (const char *name, s
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
@@ -2506,8 +2504,7 @@ __kmem_cache_create (const char *name, s
 	if (!cachep->num) {
 		printk(KERN_ERR
 		       "kmem_cache_create: couldn't create cache %s.\n", name);
-		kmem_cache_free(kmem_cache, cachep);
-		return NULL;
+		return -E2BIG;
 	}
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
 			  + sizeof(struct slab), align);
@@ -2564,9 +2561,10 @@ __kmem_cache_create (const char *name, s
 	cachep->name = name;
 	cachep->refcount = 1;
 
-	if (setup_cpu_cache(cachep, gfp)) {
+	err = setup_cpu_cache(cachep, gfp);
+	if (err) {
 		__kmem_cache_shutdown(cachep);
-		return NULL;
+		return err;
 	}
 
 	if (flags & SLAB_DEBUG_OBJECTS) {
@@ -2579,7 +2577,7 @@ __kmem_cache_create (const char *name, s
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	return cachep;
+	return 0;
 }
 
 #if DEBUG
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-08 12:56:08.505806774 -0500
+++ linux-2.6/mm/slab.h	2012-08-08 12:56:19.405836235 -0500
@@ -33,8 +33,8 @@ extern struct list_head slab_caches;
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
-	size_t align, unsigned long flags, void (*ctor)(void *));
+extern int __kmem_cache_create(struct kmem_cache *, const char *name,
+	size_t size, size_t align, unsigned long flags, void (*ctor)(void *));
 
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 12:56:08.533806800 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 12:56:19.405836235 -0500
@@ -104,19 +104,21 @@ struct kmem_cache *kmem_cache_create(con
 	if (s)
 		goto out_locked;
 
-	s = __kmem_cache_create(n, size, align, flags, ctor);
-
+	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
 	if (s) {
-		/*
-		 * Check if the slab has actually been created and if it was a
-		 * real instatiation. Aliases do not belong on the list
-		 */
-		if (s->refcount == 1)
+		err = __kmem_cache_create(s, n, size, align, flags, ctor);
+		if (!err)
+
 			list_add(&s->list, &slab_caches);
 
+		else {
+			kfree(n);
+			kmem_cache_free(kmem_cache, s);
+		}
+
 	} else {
 		kfree(n);
-		err = -ENOSYS; /* Until __kmem_cache_create returns code */
+		err = -ENOMEM;
 	}
 
 out_locked:
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-08 12:56:08.525806780 -0500
+++ linux-2.6/mm/slob.c	2012-08-08 12:56:19.405836235 -0500
@@ -508,34 +508,27 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+int __kmem_cache_create(struct kmem_cache *c, const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *c;
-
-	c = slob_alloc(sizeof(struct kmem_cache),
-		GFP_KERNEL, ARCH_KMALLOC_MINALIGN, -1);
-
-	if (c) {
-		c->name = name;
-		c->size = size;
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
+	c->name = name;
+	c->size = size;
+	if (flags & SLAB_DESTROY_BY_RCU) {
+		/* leave room for rcu footer at the end of object */
+		c->size += sizeof(struct slob_rcu);
 	}
-	return c;
+	c->flags = flags;
+	c->ctor = ctor;
+	/* ignore alignment unless it's forced */
+	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
+	if (c->align < ARCH_SLAB_MINALIGN)
+		c->align = ARCH_SLAB_MINALIGN;
+	if (c->align < align)
+		c->align = align;
+
+	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
+	c->refcount = 1;
+	return 0;
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 12:56:08.545806872 -0500
+++ linux-2.6/mm/slub.c	2012-08-08 12:56:38.981888970 -0500
@@ -3027,7 +3027,6 @@ static int kmem_cache_open(struct kmem_c
 		size_t align, unsigned long flags,
 		void (*ctor)(void *))
 {
-	memset(s, 0, kmem_size);
 	s->name = name;
 	s->ctor = ctor;
 	s->object_size = size;
@@ -3102,7 +3101,7 @@ static int kmem_cache_open(struct kmem_c
 		goto error;
 
 	if (alloc_kmem_cache_cpus(s))
-		return 1;
+		return 0;
 
 	free_kmem_cache_nodes(s);
 error:
@@ -3111,7 +3110,7 @@ error:
 			"order=%u offset=%u flags=%lx\n",
 			s->name, (unsigned long)size, s->size, oo_order(s->oo),
 			s->offset, flags);
-	return 0;
+	return -EINVAL;
 }
 
 /*
@@ -3259,7 +3258,7 @@ static struct kmem_cache *__init create_
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slab_mutex here.
 	 */
-	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
+	if (kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
 								flags, NULL))
 		goto panic;
 
@@ -3937,20 +3936,11 @@ struct kmem_cache *__kmem_cache_alias(co
 	return s;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+int __kmem_cache_create(struct kmem_cache *s,
+		const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
-	struct kmem_cache *s;
-
-	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
-	if (s) {
-		if (kmem_cache_open(s, name,
-				size, align, flags, ctor)) {
-			return s;
-		}
-		kmem_cache_free(kmem_cache, s);
-	}
-	return NULL;
+	return kmem_cache_open(s, name, size, align, flags, ctor);
 }
 
 #ifdef CONFIG_SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
