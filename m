Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7585F940001
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:35:18 -0400 (EDT)
Message-Id: <20120523203516.454190216@linux.com>
Date: Wed, 23 May 2012 15:34:53 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common 20/22] Set parameters on kmem_cache instead of passing them to functions
References: <20120523203433.340661918@linux.com>
Content-Disposition: inline; filename=parameters_in_kmem_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

There are numerous parameters repeatedly passed to kmemcache create functions.
Simplify things by having the common code set these variables in the
kmem_cache structure. That way parameter lists get much simpler and
the code follows that as well. It is then also possible to put more handling
into the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.c        |   16 ++++++++++------
 mm/slab.h        |    3 +--
 mm/slab_common.c |    5 ++++-
 mm/slob.c        |    8 ++++----
 mm/slub.c        |   28 +++++++++++++++-------------
 5 files changed, 34 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-23 08:54:35.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-05-23 08:55:22.514686758 -0500
@@ -2999,12 +2999,10 @@ static int calculate_sizes(struct kmem_c
 
 }
 
-static int kmem_cache_open(struct kmem_cache *s, size_t size,
-		size_t align, unsigned long flags)
+static int kmem_cache_open(struct kmem_cache *s)
 {
-	s->objsize = size;
-	s->align = align;
-	s->flags = kmem_cache_flags(size, flags, s->name, s->ctor);
+	s->objsize = s->size;
+	s->flags = kmem_cache_flags(s->size, s->flags, s->name, s->ctor);
 	s->reserved = 0;
 
 	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
@@ -3222,12 +3220,15 @@ static struct kmem_cache *__init create_
 
 	s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 	s->name = name;
+	s->size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	s->flags = flags;
 
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slab_mutex here.
 	 */
-	r = kmem_cache_open(s, size, ARCH_KMALLOC_MINALIGN, flags);
+	r = kmem_cache_open(s);
 	if (r)
 		panic("Creation of kmalloc slab %s size=%d failed. Code %d\n",
 				name, size, r);
@@ -3679,9 +3680,10 @@ void __init kmem_cache_init(void)
 	 */
 	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
 	kmem_cache_node->name = "kmem_cache_node";
+	kmem_cache_node->size = sizeof(struct kmem_cache_node);
+	kmem_cache_node->flags = SLAB_HWCACHE_ALIGN;
 
-	r = kmem_cache_open(kmem_cache_node, sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN);
+	r = kmem_cache_open(kmem_cache_node);
 	if (r)
 		goto panic;
 
@@ -3692,9 +3694,10 @@ void __init kmem_cache_init(void)
 
 	temp_kmem_cache = kmem_cache;
 	kmem_cache->name = "kmem_cache";
+	kmem_cache->size = kmem_size;
+	kmem_cache->flags = SLAB_HWCACHE_ALIGN;
 
-	r = kmem_cache_open(kmem_cache, kmem_size, 0,
-			SLAB_HWCACHE_ALIGN);
+	r = kmem_cache_open(kmem_cache);
 	if (r)
 		goto panic;
 
@@ -3914,10 +3917,9 @@ struct kmem_cache *__kmem_cache_alias(co
 	return s;
 }
 
-int __kmem_cache_create(struct kmem_cache *s, size_t size,
-		size_t align, unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *s)
 {
-	int r = kmem_cache_open(s, size, align, flags);
+	int r = kmem_cache_open(s);
 
 	if (r)
 		return r;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-05-23 08:54:35.000000000 -0500
+++ linux-2.6/mm/slab.h	2012-05-23 08:55:22.514686758 -0500
@@ -33,8 +33,7 @@ extern struct list_head slab_caches;
 extern struct kmem_cache *kmem_cache;
 
 /* Functions provided by the slab allocators */
-int __kmem_cache_create(struct kmem_cache *s, size_t size,
-	size_t align, unsigned long flags);
+int __kmem_cache_create(struct kmem_cache *s);
 
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-23 08:54:35.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-23 08:55:22.518686752 -0500
@@ -116,7 +116,10 @@ struct kmem_cache *kmem_cache_create(con
 
 	s->name = n;
 	s->ctor = ctor;
-	r = __kmem_cache_create(s, size, align, flags);
+	s->size = size;
+	s->align = align;
+	s->flags = flags;
+	r = __kmem_cache_create(s);
 
 	if (!r) {
 		s->refcount = 1;
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-23 08:54:34.000000000 -0500
+++ linux-2.6/mm/slab.c	2012-05-23 08:55:22.518686752 -0500
@@ -1444,9 +1444,11 @@ struct kmem_cache *create_kmalloc_cache(
 		goto panic;
 
 	s->name = name;
+	s->size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	s->flags = flags | ARCH_KMALLOC_FLAGS;
 
-	r = __kmem_cache_create(s, size, ARCH_KMALLOC_MINALIGN,
-				flags | ARCH_KMALLOC_FLAGS);
+	r = __kmem_cache_create(s);
 
 	if (r)
 		goto panic;
@@ -2206,11 +2208,13 @@ static int __init_refok setup_cpu_cache(
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-int __kmem_cache_create(struct kmem_cache *cachep, size_t size, size_t align,
-	unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *cachep)
 {
 	size_t left_over, slab_size, ralign;
 	gfp_t gfp;
+	int flags = cachep->flags;
+	int size = cachep->size;
+	int align = cachep->align;
 
 #if DEBUG
 #if FORCED_DEBUG
@@ -2282,8 +2286,8 @@ int __kmem_cache_create(struct kmem_cach
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
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-23 08:55:12.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-05-23 08:55:53.834686358 -0500
@@ -508,15 +508,15 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-int __kmem_cache_create(struct kmem_cache *c, size_t size,
-	size_t align, unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *c)
 {
-	c->size = size;
+	int flags = c->flags;
+	int align = c->align;
+
 	if (flags & SLAB_DESTROY_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
 		c->size += sizeof(struct slob_rcu);
 	}
-	c->flags = flags;
 	/* ignore alignment unless it's forced */
 	c->align = (flags & SLAB_HWCACHE_ALIGN) ? SLOB_ALIGN : 0;
 	if (c->align < ARCH_SLAB_MINALIGN)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
