Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 1AE1E6B007D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:57:54 -0400 (EDT)
Message-Id: <20120809135634.298829888@linux.com>
Date: Thu, 09 Aug 2012 08:56:28 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [05/20] Move list_add() to slab_common.c
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=move_list_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Move the code to append the new kmem_cache to the list of slab caches to
the kmem_cache_create code in the shared code.

This is possible now since the acquisition of the mutex was moved into
kmem_cache_create().

V1->V2:
	- SLOB: Add code to remove the slab from list
	 (will be removed a couple of patches down when we also move the
	 list_del to common code).

Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.c        |    7 +++++--
 mm/slab_common.c |    7 +++++++
 mm/slub.c        |    2 --
 3 files changed, 12 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 09:45:01.039150037 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 09:45:02.847153178 -0500
@@ -96,6 +96,13 @@ struct kmem_cache *kmem_cache_create(con
 	if (!s)
 		err = -ENOSYS; /* Until __kmem_cache_create returns code */
 
+	/*
+	 * Check if the slab has actually been created and if it was a
+	 * real instatiation. Aliases do not belong on the list
+	 */
+	if (s && s->refcount == 1)
+		list_add(&s->list, &slab_caches);
+
 #ifdef CONFIG_DEBUG_VM
 out_locked:
 #endif
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-08 09:44:18.567076524 -0500
+++ linux-2.6/mm/slab.c	2012-08-08 09:45:02.847153178 -0500
@@ -1687,6 +1687,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1694,6 +1695,7 @@ void __init kmem_cache_init(void)
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
 	slab_early_init = 0;
@@ -1712,6 +1714,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1721,6 +1724,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2590,6 +2594,7 @@ __kmem_cache_create (const char *name, s
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2606,8 +2611,6 @@ __kmem_cache_create (const char *name, s
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 09:44:54.943139511 -0500
+++ linux-2.6/mm/slub.c	2012-08-08 09:45:02.847153178 -0500
@@ -3968,7 +3968,6 @@ struct kmem_cache *__kmem_cache_create(c
 				size, align, flags, ctor)) {
 			int r;
 
-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3976,7 +3975,6 @@ struct kmem_cache *__kmem_cache_create(c
 			if (!r)
 				return s;
 
-			list_del(&s->list);
 			kmem_cache_close(s);
 		}
 		kmem_cache_free(kmem_cache, s);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
