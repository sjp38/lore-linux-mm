Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B7A056B0073
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:02 -0400 (EDT)
Message-Id: <20120801211200.655711830@linux.com>
Date: Wed, 01 Aug 2012 16:11:39 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [09/16] Do slab aliasing call from common code
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=slab_alias_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

The slab aliasing logic causes some strange contortions in
slub. So add a call to deal with aliases to slab_common.c
but disable it for other slab allocators by providng stubs
that fail to create aliases.

Full general support for aliases will require additional
cleanup passes and more standardization of fields in
kmem_cache.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.h        |   10 ++++++++++
 mm/slab_common.c |   16 +++++++---------
 mm/slub.c        |   18 ++++++++++++------
 3 files changed, 29 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-01 13:13:11.233146251 -0500
+++ linux-2.6/mm/slab.h	2012-08-01 13:13:19.173286112 -0500
@@ -36,6 +36,16 @@
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
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 13:13:15.597223121 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 13:13:19.177286183 -0500
@@ -98,21 +98,19 @@
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif
 
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
+		goto oops;
+
 	n = kstrdup(name, GFP_KERNEL);
 	if (!n)
 		goto oops;
 
 	s = __kmem_cache_create(n, size, align, flags, ctor);
 
-	if (s) {
-		/*
-		 * Check if the slab has actually been created and if it was a
-		 * real instatiation. Aliases do not belong on the list
-		 */
-		if (s->refcount == 1)
-			list_add(&s->list, &slab_caches);
-
-	} else
+	if (s)
+		list_add(&s->list, &slab_caches);
+	else
 		kfree(n);
 
 #ifdef CONFIG_DEBUG_VM
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 13:13:15.601223192 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 13:13:19.177286183 -0500
@@ -3701,7 +3701,7 @@
 		slub_max_order = 0;
 
 	kmem_size = offsetof(struct kmem_cache, node) +
-				nr_node_ids * sizeof(struct kmem_cache_node *);
+			nr_node_ids * sizeof(struct kmem_cache_node *);
 
 	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
@@ -3915,7 +3915,7 @@
 	return NULL;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
@@ -3932,11 +3932,18 @@
 
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
