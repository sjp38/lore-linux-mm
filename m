Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 0B6576B0085
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 17:04:15 -0400 (EDT)
Message-Id: <20120808210209.416831074@linux.com>
Date: Wed, 08 Aug 2012 16:01:31 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11 [02/20] slub: Use kmem_cache for the kmem_cache structure
References: <20120808210129.987345284@linux.com>
Content-Disposition: inline; filename=slub_use_kmem_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Do not use kmalloc() but kmem_cache_alloc() for the allocation
of the kmem_cache structures in slub.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 09:01:06.650720492 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 09:01:23.583012476 -0500
@@ -213,7 +213,7 @@ static inline int sysfs_slab_alias(struc
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kfree(s);
+	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -3962,7 +3962,7 @@ struct kmem_cache *__kmem_cache_create(c
 	if (!n)
 		return NULL;
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmem_cache_alloc(kmem_cache, GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
@@ -3979,7 +3979,7 @@ struct kmem_cache *__kmem_cache_create(c
 			list_del(&s->list);
 			kmem_cache_close(s);
 		}
-		kfree(s);
+		kmem_cache_free(kmem_cache, s);
 	}
 	kfree(n);
 	return NULL;
@@ -5217,7 +5217,7 @@ static void kmem_cache_release(struct ko
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
