Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 30E7F6B0078
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:36:37 -0400 (EDT)
Message-Id: <20120731173635.305083019@linux.com>
Date: Tue, 31 Jul 2012 12:36:23 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [3/9] Move list_add() to slab_common.c
References: <20120731173620.432853182@linux.com>
Content-Disposition: inline; filename=move_list_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Move the code to append the new kmem_cache to the list of slab caches to
the kmem_cache_create code in the shared code.

This is possible now since the acquisition of the mutex was moved into
kmem_cache_create().

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
--- linux-2.6.orig/mm/slab_common.c	2012-07-31 11:57:06.959870010 -0500
+++ linux-2.6/mm/slab_common.c	2012-07-31 11:59:47.226589653 -0500
@@ -98,6 +98,13 @@
 
 	s = __kmem_cache_create(name, size, align, flags, ctor);
 
+	/*
+	 * Check if the slab has actually been created and if it was a
+	 * real instatiation. Aliases do not belong on the list
+	 */
+	if (s && s->refcount == 1)
+		list_add(&s->list, &slab_caches);
+
 #ifdef CONFIG_DEBUG_VM
 oops:
 #endif
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-07-31 11:46:01.524493044 -0500
+++ linux-2.6/mm/slab.c	2012-07-31 11:59:47.226589653 -0500
@@ -1538,6 +1538,7 @@
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1545,6 +1546,7 @@
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
 	slab_early_init = 0;
@@ -1563,6 +1565,7 @@
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1572,6 +1575,7 @@
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2432,6 +2436,7 @@
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2448,8 +2453,6 @@
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-07-31 11:58:47.529574942 -0500
+++ linux-2.6/mm/slub.c	2012-07-31 11:59:47.226589653 -0500
@@ -3944,7 +3944,6 @@
 				size, align, flags, ctor)) {
 			int r;
 
-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3952,7 +3951,6 @@
 			if (!r)
 				return s;
 
-			list_del(&s->list);
 			kmem_cache_close(s);
 		}
 		kfree(s);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
