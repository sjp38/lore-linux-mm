Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 66CF76B0072
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:40 -0400 (EDT)
Message-Id: <0000013945cd2c3e-98e825e1-bade-43c6-b657-a54cec84d4dd-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [11/19] Move sysfs_slab_add to common
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Simplify locking by moving the slab_add_sysfs after all locks
have been dropped. Eases the upcoming move to provide sysfs
support for all allocators.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.h        |    3 +++
 mm/slab_common.c |    8 ++++++++
 mm/slub.c        |   15 ++-------------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 84c28f4..ec7b944 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -39,10 +39,13 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
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
 
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e5cd47f..ec93056 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
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
diff --git a/mm/slub.c b/mm/slub.c
index 5751f30..5e37c89 100644
--- a/mm/slub.c
+++ b/mm/slub.c
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
@@ -3955,16 +3953,7 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
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
@@ -5258,7 +5247,7 @@ static char *create_unique_id(struct kmem_cache *s)
 	return name;
 }
 
-static int sysfs_slab_add(struct kmem_cache *s)
+int sysfs_slab_add(struct kmem_cache *s)
 {
 	int err;
 	const char *name;
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
