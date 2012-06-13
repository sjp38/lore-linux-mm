Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id D0BFE6B0092
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 11:25:26 -0400 (EDT)
Message-Id: <20120613152524.995425044@linux.com>
Date: Wed, 13 Jun 2012 10:25:09 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [18/20] Do slab aliasing call from common code
References: <20120613152451.465596612@linux.com>
Content-Disposition: inline; filename=slab_alias_common
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

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
 mm/slub.c        |   16 +++++++++++-----
 3 files changed, 28 insertions(+), 14 deletions(-)

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-06-13 03:44:40.949477453 -0500
+++ linux-2.6/mm/slab.h	2012-06-13 03:45:11.637476817 -0500
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
--- linux-2.6.orig/mm/slab_common.c	2012-06-13 03:44:40.977477452 -0500
+++ linux-2.6/mm/slab_common.c	2012-06-13 03:45:11.657476817 -0500
@@ -98,21 +98,19 @@ struct kmem_cache *kmem_cache_create(con
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
 
 oops:
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-06-13 03:44:40.977477452 -0500
+++ linux-2.6/mm/slub.c	2012-06-13 03:45:11.621476817 -0500
@@ -3903,11 +3903,10 @@ static struct kmem_cache *find_mergeable
 	return NULL;
 }
 
-struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
+struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
-	char *n;
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
@@ -3921,14 +3920,21 @@ struct kmem_cache *__kmem_cache_create(c
 
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
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
-		if (kmem_cache_open(s, n,
+		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
 			int r;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
