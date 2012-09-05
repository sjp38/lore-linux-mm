Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1366C6B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:18:35 -0400 (EDT)
Message-Id: <0000013993cae9d0-0682a7ce-0ba1-4361-acab-e31af05c2ab8-000000@email.amazonses.com>
Date: Wed, 5 Sep 2012 00:18:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [11/14] Move sysfs_slab_add to common
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Simplify locking by moving the slab_add_sysfs after all locks
have been dropped. Eases the upcoming move to provide sysfs
support for all allocators.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.h        |    3 +++
 mm/slab_common.c |    8 ++++++++
 mm/slub.c        |   15 ++-------------
 3 files changed, 13 insertions(+), 13 deletions(-)

Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-04 18:00:16.830082166 -0500
+++ linux/mm/slab.h	2012-09-04 18:01:54.227602225 -0500
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
 
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.830082166 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:54.255602662 -0500
@@ -152,6 +152,14 @@ out_locked:
 		return NULL;
 	}
 
+	if (s->refcount == 1) {
+		err = sysfs_slab_add(s);
+		if (err)
+			printk(KERN_WARNING "kmem_cache_create(%s) failed to"
+				" create sysfs entry. Error %d\n",
+					name, err);
+	}
+
 	return s;
 }
 EXPORT_SYMBOL(kmem_cache_create);
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.830082166 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:54.267602849 -0500
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
@@ -3955,16 +3953,7 @@ struct kmem_cache *__kmem_cache_create(c
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
@@ -5258,7 +5247,7 @@ static char *create_unique_id(struct kme
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
