Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CE5B16B0088
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:36:38 -0400 (EDT)
Message-Id: <20120731173636.957620874@linux.com>
Date: Tue, 31 Jul 2012 12:36:26 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [6/9] Move freeing of kmem_cache structure to common code
References: <20120731173620.432853182@linux.com>
Content-Disposition: inline; filename=common_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slab_common.c	2012-07-31 12:20:08.035649028 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-31 12:20:10.139685656 -0500
@@ -135,6 +135,7 @@
 				rcu_barrier();
 
 			__kmem_cache_destroy(s);
+			kmem_cache_free(kmem_cache, s);
 		} else {
 			list_add(&s->list, &slab_caches);
 			printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-07-31 12:20:08.027648887 -0500
+++ linux-2.6/mm/slob.c	2012-07-31 12:20:10.139685656 -0500
@@ -540,8 +540,6 @@
 
 void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	kmemleak_free(c);
-	slob_free(c, sizeof(struct kmem_cache));
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-31 12:20:08.019648748 -0500
+++ linux-2.6/mm/slab.c	2012-07-31 12:20:10.143685717 -0500
@@ -2064,7 +2064,6 @@
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(kmem_cache, cachep);
 }
 
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-31 12:20:08.047649236 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 12:20:37.228157295 -0500
@@ -211,7 +211,6 @@
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
 	kfree(s->name);
-	kfree(s);
 }
 
 #endif
@@ -5301,7 +5300,6 @@
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
