Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8A8CB6B0044
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 17:03:23 -0400 (EDT)
Message-Id: <20120808210210.424031267@linux.com>
Date: Wed, 08 Aug 2012 16:01:37 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11 [08/20] Move freeing of kmem_cache structure to common code
References: <20120808210129.987345284@linux.com>
Content-Disposition: inline; filename=common_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The freeing action is basically the same in all slab allocators.
Move to the common kmem_cache_destroy() function.

Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |    1 -
 mm/slab_common.c |    1 +
 mm/slob.c        |    2 --
 mm/slub.c        |    1 -
 4 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-03 09:02:43.432389623 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-03 09:02:44.064400579 -0500
@@ -144,6 +144,7 @@ void kmem_cache_destroy(struct kmem_cach
 				rcu_barrier();
 
 			__kmem_cache_destroy(s);
+			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
 			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-03 09:02:43.436389695 -0500
+++ linux-2.6/mm/slob.c	2012-08-03 09:02:44.064400579 -0500
@@ -540,8 +540,6 @@ struct kmem_cache *__kmem_cache_create(c
 
 void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	kmemleak_free(c);
-	slob_free(c, sizeof(struct kmem_cache));
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-03 09:02:43.432389623 -0500
+++ linux-2.6/mm/slab.c	2012-08-03 09:02:44.064400579 -0500
@@ -2222,7 +2222,6 @@ void __kmem_cache_destroy(struct kmem_ca
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(kmem_cache, cachep);
 }
 
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-03 09:02:43.436389695 -0500
+++ linux-2.6/mm/slub.c	2012-08-03 09:02:44.064400579 -0500
@@ -213,7 +213,6 @@ static inline int sysfs_slab_alias(struc
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -5199,7 +5198,6 @@ static void kmem_cache_release(struct ko
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
