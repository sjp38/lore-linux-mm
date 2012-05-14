Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2C3496B00F1
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:16:15 -0400 (EDT)
Message-Id: <20120514201613.467708800@linux.com>
Date: Mon, 14 May 2012 15:15:52 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] SL[AUO]B common code 8/9] slabs: list addition move to slab_common
References: <20120514201544.334122849@linux.com>
Content-Disposition: inline; filename=move_list_add
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

Move the code to append the new kmem_cache to the list of slab caches to
the kmem_cache_create code in the shared code.

This is possible now since the acquisition of the mutex was moved into
kmem_cache_create().

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slab.c        |    7 +++++--
 mm/slab_common.c |    3 +++
 mm/slub.c        |    2 --
 3 files changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-05-14 08:39:27.859145830 -0500
+++ linux-2.6/mm/slab_common.c	2012-05-14 08:39:29.827145790 -0500
@@ -98,6 +98,9 @@ struct kmem_cache *kmem_cache_create(con
 
 	s = __kmem_cache_create(name, size, align, flags, ctor);
 
+	if (s && s->refcount == 1)
+		list_add(&s->list, &slab_caches);
+
 oops:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-05-14 08:39:28.563145816 -0500
+++ linux-2.6/mm/slab.c	2012-05-14 08:39:29.831145790 -0500
@@ -1565,6 +1565,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1572,6 +1573,7 @@ void __init kmem_cache_init(void)
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
 	slab_early_init = 0;
@@ -1590,6 +1592,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1599,6 +1602,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2455,6 +2459,7 @@ __kmem_cache_create (const char *name, s
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2471,8 +2476,6 @@ __kmem_cache_create (const char *name, s
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-05-14 08:39:27.859145830 -0500
+++ linux-2.6/mm/slub.c	2012-05-14 08:39:29.831145790 -0500
@@ -3939,7 +3939,6 @@ struct kmem_cache *__kmem_cache_create(c
 				size, align, flags, ctor)) {
 			int r;
 
-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3947,7 +3946,6 @@ struct kmem_cache *__kmem_cache_create(c
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
