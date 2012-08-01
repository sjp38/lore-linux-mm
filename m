Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 37A556B0072
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:03 -0400 (EDT)
Message-Id: <20120801211201.299570354@linux.com>
Date: Wed, 01 Aug 2012 16:11:40 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [10/16] Move sysfs_slab_add to common
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=move_sysfs_slab_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Simplifies the locking by moveing the slab_add_sysfs after all locks
have been dropped and eases the upcoming move to provide sysfs
support for all allocators.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.h
===================================================================
--- linux-2.6.orig/mm/slab.h	2012-08-01 14:50:14.000000000 -0500
+++ linux-2.6/mm/slab.h	2012-08-01 14:50:27.310260888 -0500
@@ -39,10 +39,13 @@
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
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 14:50:14.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 14:53:49.693908703 -0500
@@ -54,6 +54,7 @@
 {
 	struct kmem_cache *s = NULL;
 	char *n;
+	int alias = 0;
 
 #ifdef CONFIG_DEBUG_VM
 	if (!name || in_interrupt() || size < sizeof(void *) ||
@@ -99,8 +100,10 @@
 #endif
 
 	s = __kmem_cache_alias(name, size, align, flags, ctor);
-	if (s)
+	if (s) {
+		alias = 1;
 		goto oops;
+	}
 
 	n = kstrdup(name, GFP_KERNEL);
 	if (!n)
@@ -125,6 +128,9 @@
 	if (!s && (flags & SLAB_PANIC))
 		panic("kmem_cache_create: Failed to create slab '%s'\n", name);
 
+	if (!alias)
+		sysfs_slab_add(s);
+
 	return s;
 }
 EXPORT_SYMBOL(kmem_cache_create);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 14:50:16.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 14:52:12.944165176 -0500
@@ -202,12 +202,10 @@
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
@@ -3948,16 +3946,7 @@
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
@@ -5260,7 +5249,7 @@
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
