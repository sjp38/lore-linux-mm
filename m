Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F1CB36B0078
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 17:12:04 -0400 (EDT)
Message-Id: <20120801211202.982983350@linux.com>
Date: Wed, 01 Aug 2012 16:11:43 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [13/16] slub: Introduce function for opening boot caches
References: <20120801211130.025389154@linux.com>
Content-Disposition: inline; filename=slub_create_open_boot
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

Basically the same thing happens for various boot caches.
Provide a function.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 15:04:36.833556978 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 15:10:39.852081546 -0500
@@ -3248,6 +3248,12 @@
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
+static int kmem_cache_open_boot(struct kmem_cache *s, const char *name, int size)
+{
+	return kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
+		SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+}
+
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
@@ -3681,17 +3687,15 @@
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
 	kmem_cache_node = &boot_kmem_cache_node;
 
-	kmem_cache_open(&boot_kmem_cache_node, "kmem_cache_node",
-		sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache_open_boot(kmem_cache_node, "kmem_cache_node",
+		sizeof(struct kmem_cache_node));
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
 
-	kmem_cache_open(&boot_kmem_cache, "kmem_cache", kmem_size,
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache_open_boot(&boot_kmem_cache, "kmem_cache", kmem_size);
 	kmem_cache = kmem_cache_alloc(&boot_kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, &boot_kmem_cache, kmem_size);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
