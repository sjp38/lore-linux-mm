Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 405AB6B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 20:18:35 -0400 (EDT)
Message-Id: <0000013993cae9f6-83e048c2-669a-46f2-9590-ed0afb78ff4a-000000@email.amazonses.com>
Date: Wed, 5 Sep 2012 00:18:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [07/14] Move freeing of kmem_cache structure to common code
References: <20120904230609.691088980@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The freeing action is basically the same in all slab allocators.
Move to the common kmem_cache_destroy() function.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |    1 -
 mm/slab_common.c |    1 +
 mm/slob.c        |    2 --
 mm/slub.c        |    2 --
 4 files changed, 1 insertion(+), 5 deletions(-)

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-04 18:00:16.774081296 -0500
+++ linux/mm/slab.c	2012-09-04 18:01:56.855643242 -0500
@@ -2225,7 +2225,6 @@ void __kmem_cache_destroy(struct kmem_ca
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(kmem_cache, cachep);
 }
 
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.774081296 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:01:56.871643489 -0500
@@ -154,6 +154,7 @@ void kmem_cache_destroy(struct kmem_cach
 				rcu_barrier();
 
 			__kmem_cache_destroy(s);
+			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
 			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-09-04 18:00:16.774081296 -0500
+++ linux/mm/slob.c	2012-09-04 18:01:56.863643366 -0500
@@ -540,8 +540,6 @@ struct kmem_cache *__kmem_cache_create(c
 
 void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	kmemleak_free(c);
-	slob_free(c, sizeof(struct kmem_cache));
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.778081353 -0500
+++ linux/mm/slub.c	2012-09-04 18:01:56.883643678 -0500
@@ -213,7 +213,6 @@ static inline int sysfs_slab_alias(struc
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -5206,7 +5205,6 @@ static void kmem_cache_release(struct ko
 	struct kmem_cache *s = to_slab(kobj);
 
 	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
 }
 
 static const struct sysfs_ops slab_sysfs_ops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
