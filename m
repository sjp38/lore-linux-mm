Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id BEB416B007B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:53 -0400 (EDT)
Message-Id: <20120809135635.299325851@linux.com>
Date: Thu, 09 Aug 2012 08:56:34 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [11/20] Do slab aliasing call from common code
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=slab_alias_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The slab aliasing logic causes some strange contortions in
slub. So add a call to deal with aliases to slab_common.c
but disable it for other slab allocators by providng stubs
that fail to create aliases.

Full general support for aliases will require additional
cleanup passes and more standardization of fields in
kmem_cache.

V1->V2:
	- Move kstrdup before kmem_cache_alias invocation.
	(JoonSoo Kim)

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.h        |   10 ++++++++++
 mm/slab_common.c |   16 +++++++---------
 mm/slub.c        |   18 ++++++++++++------
 3 files changed, 29 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-08 09:54:18.000000000 -0500
+++ linux-2.6/mm/slab.h	2012-08-09 08:53:10.104271149 -0500
@@ -36,6 +36,16 @@ extern struct kmem_cache *kmem_cache;
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
+#ifdef CONFIG_SLUB
+struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
+	size_t align, unsigned long flags, void (*ctor)(void *));
+#else
+static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
+	size_t align, unsigned long flags, void (*ctor)(void *))
+{ return NULL; }
+#endif
+
+
 int __kmem_cache_shutdown(struct kmem_cache *);
 
 #endif
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 09:54:31.016169589 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-09 08:53:10.116271459 -0500
@@ -100,6 +100,10 @@ struct kmem_cache *kmem_cache_create(con
 		goto out_locked;
 	}
 
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
+		goto out_locked;
+
 	s = __kmem_cache_create(n, size, align, flags, ctor);
 
 	if (s) {
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 09:54:20.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-08-09 08:53:10.128271769 -0500
@@ -3701,7 +3701,7 @@ void __init kmem_cache_init(void)
 		slub_max_order = 0;
 
 	kmem_size = offsetof(struct kmem_cache, node) +
-				nr_node_ids * sizeof(struct kmem_cache_node *);
+			nr_node_ids * sizeof(struct kmem_cache_node *);
 
 	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
@@ -3915,7 +3915,7 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
@@ -3932,11 +3932,18 @@ struct kmem_cache *__kmem_cache_create(c
 
 		if (sysfs_slab_alias(s, name)) {
 			s->refcount--;
-			return NULL;
+			s = NULL;
 		}
-		return s;
 	}
 
+	return s;
+}
+
+struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+		size_t align, unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *s;
+
 	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, name,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
