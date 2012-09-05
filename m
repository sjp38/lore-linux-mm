Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 274A86B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:18:34 -0400 (EDT)
Message-Id: <0000013993cae9e7-393d762d-b710-4556-8c17-c5ac25b6bc15-000000@email.amazonses.com>
Date: Wed, 5 Sep 2012 00:18:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [10/14] Do slab aliasing call from common code
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

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
 mm/slab_common.c |    4 ++++
 mm/slub.c        |   15 +++++++++++----
 3 files changed, 25 insertions(+), 4 deletions(-)

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-04 18:00:16.802081734 -0500
+++ linux/mm/slab.h	2012-09-04 18:01:54.947613462 -0500
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
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.814081912 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:54.959613652 -0500
@@ -115,6 +115,10 @@ struct kmem_cache *kmem_cache_create(con
 		goto out_locked;
 	}
 
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
+		goto out_locked;
+
 	s = __kmem_cache_create(n, size, align, flags, ctor);
 
 	if (s) {
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.818081972 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:54.971613835 -0500
@@ -3708,7 +3708,7 @@ void __init kmem_cache_init(void)
 		slub_max_order = 0;
 
 	kmem_size = offsetof(struct kmem_cache, node) +
-				nr_node_ids * sizeof(struct kmem_cache_node *);
+			nr_node_ids * sizeof(struct kmem_cache_node *);
 
 	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
@@ -3922,7 +3922,7 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
@@ -3939,11 +3939,18 @@ struct kmem_cache *__kmem_cache_create(c
 
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
