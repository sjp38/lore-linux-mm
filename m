Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id DFCB66B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 17:03:24 -0400 (EDT)
Message-Id: <20120808210211.926059588@linux.com>
Date: Wed, 08 Aug 2012 16:01:46 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11 [17/20] create common functions for boot slab creation
References: <20120808210129.987345284@linux.com>
Content-Disposition: inline; filename=extract_create_kmalloc_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Use a special function to create kmalloc caches and use that function in
SLAB and SLUB.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c |   53 +++++++++++++++++++++++------------------------------
 1 file changed, 23 insertions(+), 30 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-08 14:33:32.438009523 -0500
+++ linux-2.6/mm/slab.c	2012-08-08 14:33:32.846012306 -0500
@@ -1681,23 +1681,13 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	sizes[INDEX_AC].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-	sizes[INDEX_AC].cs_cachep->name = names[INDEX_AC].name;
-	sizes[INDEX_AC].cs_cachep->size = sizes[INDEX_AC].cs_size;
-	sizes[INDEX_AC].cs_cachep->object_size = sizes[INDEX_AC].cs_size;
-	sizes[INDEX_AC].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-	__kmem_cache_create(sizes[INDEX_AC].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
+	sizes[INDEX_AC].cs_cachep = create_kmalloc_cache(names[INDEX_AC].name,
+					sizes[INDEX_AC].cs_size, ARCH_KMALLOC_FLAGS);
 
-	if (INDEX_AC != INDEX_L3) {
-		sizes[INDEX_L3].cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-		sizes[INDEX_L3].cs_cachep->name = names[INDEX_L3].name;
-		sizes[INDEX_L3].cs_cachep->size = sizes[INDEX_L3].cs_size;
-		sizes[INDEX_L3].cs_cachep->object_size = sizes[INDEX_L3].cs_size;
-		sizes[INDEX_L3].cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-		__kmem_cache_create(sizes[INDEX_L3].cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
-	}
+	if (INDEX_AC != INDEX_L3)
+		sizes[INDEX_L3].cs_cachep =
+			create_kmalloc_cache(names[INDEX_L3].name,
+				sizes[INDEX_L3].cs_size, ARCH_KMALLOC_FLAGS);
 
 	slab_early_init = 0;
 
@@ -1709,24 +1699,14 @@ void __init kmem_cache_init(void)
 		 * Note for systems short on memory removing the alignment will
 		 * allow tighter packing of the smaller caches.
 		 */
-		if (!sizes->cs_cachep) {
-			sizes->cs_cachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-			sizes->cs_cachep->name = names->name;
-			sizes->cs_cachep->size = sizes->cs_size;
-			sizes->cs_cachep->object_size = sizes->cs_size;
-			sizes->cs_cachep->align = ARCH_KMALLOC_MINALIGN;
-			__kmem_cache_create(sizes->cs_cachep, ARCH_KMALLOC_FLAGS|SLAB_PANIC);
-			list_add(&sizes->cs_cachep->list, &slab_caches);
-		}
+		if (!sizes->cs_cachep)
+			sizes->cs_cachep = create_kmalloc_cache(names->name,
+					sizes->cs_size, ARCH_KMALLOC_FLAGS);
+
 #ifdef CONFIG_ZONE_DMA
-		sizes->cs_dmacachep = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
-		sizes->cs_dmacachep->name = names->name_dma;
-		sizes->cs_dmacachep->size = sizes->cs_size;
-		sizes->cs_dmacachep->object_size = sizes->cs_size;
-		sizes->cs_dmacachep->align = ARCH_KMALLOC_MINALIGN;
-		__kmem_cache_create(sizes->cs_dmacachep,
-			       ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA| SLAB_PANIC);
-		list_add(&sizes->cs_dmacachep->list, &slab_caches);
+		sizes->cs_dmacachep = create_kmalloc_cache(
+			names->name_dma, sizes->cs_size,
+			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
 #endif
 		sizes++;
 		names++;
Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-08 14:33:18.357913392 -0500
+++ linux-2.6/mm/slab.h	2012-08-08 14:33:32.846012306 -0500
@@ -35,6 +35,11 @@ extern struct kmem_cache *kmem_cache;
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
+extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
+			unsigned long flags);
+extern void create_boot_cache(struct kmem_cache *, const char *name,
+	       size_t size, unsigned long flags);
+
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 14:33:31.934006086 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 14:33:32.846012306 -0500
@@ -185,3 +185,35 @@ int slab_is_available(void)
 {
 	return slab_state >= UP;
 }
+
+/* Create a cache during boot when no slab services are available yet */
+void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
+	       	unsigned long flags)
+{
+	int err;
+
+	s->name = name;
+	s->size = s->object_size = size;
+	s->align = ARCH_KMALLOC_MINALIGN;
+	err = __kmem_cache_create(s, flags);
+
+	if (err)
+		panic("Creation of kmalloc slab %s size=%ld failed. Reason %d\n",
+		       			name, size, err);
+
+	list_add(&s->list, &slab_caches);
+	s->refcount = -1;	/* Exempt from merging for now */
+}
+
+struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
+				unsigned long flags)
+{
+	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
+
+	if (!s)
+		panic("Out of memory when creating slab %s\n", name);
+
+	create_boot_cache(s, name, size, flags);
+	s->refcount = 1;
+	return s;
+}
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 14:33:31.938006113 -0500
+++ linux-2.6/mm/slub.c	2012-08-08 14:33:38.738052474 -0500
@@ -3239,32 +3239,6 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static struct kmem_cache *__init create_kmalloc_cache(const char *name,
-						int size, unsigned int flags)
-{
-	struct kmem_cache *s;
-
-	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-
-	s->name = name;
-	s->size = s->object_size = size;
-	s->align = ARCH_KMALLOC_MINALIGN;
-
-	/*
-	 * This function is called with IRQs disabled during early-boot on
-	 * single CPU so there's no need to take slab_mutex here.
-	 */
-	if (kmem_cache_open(s, flags))
-		goto panic;
-
-	list_add(&s->list, &slab_caches);
-	return s;
-
-panic:
-	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
-	return NULL;
-}
-
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
@@ -3707,10 +3681,8 @@ void __init kmem_cache_init(void)
 	 */
 	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
 
-	kmem_cache_node->name = "kmem_cache_node";
-	kmem_cache_node->size = kmem_cache_node->object_size =
-		sizeof(struct kmem_cache_node);
-	kmem_cache_open(kmem_cache_node, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+	create_boot_cache(kmem_cache_node, "kmem_cache_node",
+		       sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
@@ -3718,9 +3690,7 @@ void __init kmem_cache_init(void)
 	slab_state = PARTIAL;
 
 	temp_kmem_cache = kmem_cache;
-	kmem_cache->name = "kmem_cache";
-	kmem_cache->size = kmem_cache->object_size = kmem_size;
-	kmem_cache_open(kmem_cache, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+	create_boot_cache(kmem_cache, "kmem_cache", kmem_size, SLAB_HWCACHE_ALIGN);
 
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
