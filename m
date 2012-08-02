Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 736946B0075
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:38 -0400 (EDT)
Message-Id: <20120802201536.599847135@linux.com>
Date: Thu, 02 Aug 2012 15:15:17 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [11/19] Do slab aliasing call from common code
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=slab_alias_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slab.h	2012-08-02 14:21:24.841995858 -0500
+++ linux-2.6/mm/slab.h	2012-08-02 14:23:08.071846583 -0500
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
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 14:22:59.087685489 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 14:23:08.071846583 -0500
@@ -94,6 +94,10 @@
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
 #endif
 
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
+		goto out_locked;
+
 	n = kstrdup(name, GFP_KERNEL);
 	if (!n) {
 		err = -ENOMEM;
@@ -115,9 +119,7 @@
 		err = -ENOSYS; /* Until __kmem_cache_create returns code */
 	}
 
-#ifdef CONFIG_DEBUG_VM
 out_locked:
-#endif
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 14:21:30.678100549 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 14:23:08.075846653 -0500
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
