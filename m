Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1BD276B0072
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 15:21:57 -0400 (EDT)
Message-Id: <20120803192154.777250838@linux.com>
Date: Fri, 03 Aug 2012 14:21:04 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common10 [12/20] Move sysfs_slab_add to common
References: <20120803192052.448575403@linux.com>
Content-Disposition: inline; filename=move_sysfs_slab_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Simplify locking by moving the slab_add_sysfs after all locks
have been dropped. Eases the upcoming move to provide sysfs
support for all allocators.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-03 09:04:19.558047765 -0500
+++ linux-2.6/mm/slab.h	2012-08-03 09:04:21.258077096 -0500
@@ -39,10 +39,13 @@ struct kmem_cache *__kmem_cache_create(c
 #ifdef CONFIG_SLUB
 struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
+extern int sysfs_slab_add(struct kmem_cache *s);
 #else
 static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *))
 { return NULL; }
+static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
+
 #endif
 
 
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-03 09:04:19.558047765 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-03 09:04:21.258077096 -0500
@@ -140,6 +140,9 @@ out:
 		return NULL;
 	}
 
+	if (s->refcount == 1)
+		sysfs_slab_add(s);
+
 	return s;
 }
 EXPORT_SYMBOL(kmem_cache_create);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 09:04:19.562047834 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 09:04:21.258077096 -0500
@@ -202,12 +202,10 @@ struct track {
 enum track_item { TRACK_ALLOC, TRACK_FREE };
 
 #ifdef CONFIG_SYSFS
-static int sysfs_slab_add(struct kmem_cache *);
 static int sysfs_slab_alias(struct kmem_cache *, const char *);
 static void sysfs_slab_remove(struct kmem_cache *);
 
 #else
-static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
 static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 							{ return 0; }
 static inline void sysfs_slab_remove(struct kmem_cache *s) { }
@@ -3948,16 +3946,7 @@ struct kmem_cache *__kmem_cache_create(c
 	if (s) {
 		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
-			int r;
-
-			mutex_unlock(&slab_mutex);
-			r = sysfs_slab_add(s);
-			mutex_lock(&slab_mutex);
-
-			if (!r)
-				return s;
-
-			kmem_cache_close(s);
+			return s;
 		}
 		kmem_cache_free(kmem_cache, s);
 	}
@@ -5251,7 +5240,7 @@ static char *create_unique_id(struct kme
 	return name;
 }
 
-static int sysfs_slab_add(struct kmem_cache *s)
+int sysfs_slab_add(struct kmem_cache *s)
 {
 	int err;
 	const char *name;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
