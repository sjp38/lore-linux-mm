Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0B3F66B0074
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:06:16 -0400 (EDT)
Message-Id: <000001399388ba04-37cd3b88-ef26-40da-9fc7-0460d0a0cb5f-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:06:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [02/14] slub: Use kmem_cache for the kmem_cache structure
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org

Do not use kmalloc() but kmem_cache_alloc() for the allocation
of the kmem_cache structures in slub.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.710080309 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:59.767688688 -0500
@@ -213,7 +213,7 @@ static inline int sysfs_slab_alias(struc
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -3969,7 +3969,7 @@ struct kmem_cache *__kmem_cache_create(c
 	if (!n)
 		return NULL;
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
@@ -3986,7 +3986,7 @@ struct kmem_cache *__kmem_cache_create(c
 			list_del(&s->list);
 			kmem_cache_close(s);
 		}
-		kfree(s);
+		kmem_cache_free(kmem_cache, s);
 	}
 	kfree(n);
 	return NULL;
@@ -5224,7 +5224,7 @@ static void kmem_cache_release(struct ko
 	struct kmem_cache *s = to_slab(kobj);
 
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 static const struct sysfs_ops slab_sysfs_ops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
