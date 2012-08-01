Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id F3BE56B005D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:11:58 -0400 (EDT)
Message-Id: <20120801211157.216088451@linux.com>
Date: Wed, 01 Aug 2012 16:11:33 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [03/16] Move list_add() to slab_common.c
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=move_list_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

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
--- linux-2.6.orig/mm/slab_common.c	2012-08-01 10:43:02.230775963 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-01 13:12:22.436286724 -0500
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
--- linux-2.6.orig/mm/slab.c	2012-08-01 10:43:09.362901221 -0500
+++ linux-2.6/mm/slab.c	2012-08-01 13:12:22.440286794 -0500
@@ -1687,6 +1687,7 @@
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1694,6 +1695,7 @@
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
 	slab_early_init = 0;
@@ -1712,6 +1714,7 @@
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1721,6 +1724,7 @@
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2590,6 +2594,7 @@
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2606,8 +2611,6 @@
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 13:06:02.673597753 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 13:12:22.440286794 -0500
@@ -3968,7 +3968,6 @@
 				size, align, flags, ctor)) {
 			int r;
 
-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3976,7 +3975,6 @@
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
