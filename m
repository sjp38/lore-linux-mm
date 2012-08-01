Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A87636B0062
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:00 -0400 (EDT)
Message-Id: <20120801211158.941450406@linux.com>
Date: Wed, 01 Aug 2012 16:11:36 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [06/16] Move freeing of kmem_cache structure to common code
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=common_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 13:12:30.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 13:12:36.836540373 -0500
@@ -135,6 +135,7 @@
 				rcu_barrier();
 
 			__kmem_cache_destroy(s);
+			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
 			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-01 13:12:30.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-08-01 13:12:36.836540373 -0500
@@ -540,8 +540,6 @@
 
 void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	kmemleak_free(c);
-	slob_free(c, sizeof(struct kmem_cache));
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-01 13:12:30.480428413 -0500
+++ linux-2.6/mm/slab.c	2012-08-01 13:12:36.836540373 -0500
@@ -2222,7 +2222,6 @@
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(kmem_cache, cachep);
 }
 
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 13:12:30.000000000 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 13:13:03.605011880 -0500
@@ -213,7 +213,6 @@
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
 }
 
 #endif
@@ -5325,7 +5324,6 @@
 	kobject_del(&s->kobj);
 	kobject_put(&s->kobj);
 	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
