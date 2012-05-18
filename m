Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 215F18D0001
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:19:35 -0400 (EDT)
Message-Id: <20120518161933.271404153@linux.com>
Date: Fri, 18 May 2012 11:19:17 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] Common code 11/12] Move freeing of kmem_cache structure to common code
References: <20120518161906.207356777@linux.com>
Content-Disposition: inline; filename=common_kmem_cache_destroy
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

The freeing action is basically the same in all slab allocators.
Move to the common kmem_cache_destroy() function.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        |    1 -
 mm/slab_common.c |    1 +
 mm/slob.c        |    2 --
 mm/slub.c        |    1 -
 4 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-18 03:37:23.772360311 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-18 03:38:54.592358430 -0500
@@ -129,6 +129,7 @@ void kmem_cache_destroy(struct kmem_cach
 			rcu_barrier();
 
 		__kmem_cache_destroy(s);
+		kmem_cache_free(kmem_cache, s);
 	} else {
 		list_add(&s->list, &slab_caches);
 		printk(KERN_ERR "kmem_cache_destroy %s: Slab cache still has objects\n",
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-05-18 03:37:23.740360312 -0500
+++ linux-2.6/mm/slob.c	2012-05-18 03:37:48.184359806 -0500
@@ -572,8 +572,6 @@ struct kmem_cache *__kmem_cache_create(c
 
 void __kmem_cache_destroy(struct kmem_cache *c)
 {
-	kmemleak_free(c);
-	slob_free(c, sizeof(struct kmem_cache));
 }
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-18 03:37:23.760360314 -0500
+++ linux-2.6/mm/slub.c	2012-05-18 03:37:48.184359806 -0500
@@ -3175,7 +3175,6 @@ int __kmem_cache_shutdown(struct kmem_ca
 
 void __kmem_cache_destroy(struct kmem_cache *s)
 {
-	kfree(s);
 	sysfs_slab_remove(s);
 }
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-18 03:37:23.752360313 -0500
+++ linux-2.6/mm/slab.c	2012-05-18 03:37:48.188359801 -0500
@@ -2088,7 +2088,6 @@ void __kmem_cache_destroy(struct kmem_ca
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(kmem_cache, cachep);
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
