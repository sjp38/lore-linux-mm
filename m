Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 00A7C6B0081
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:39 -0400 (EDT)
Message-Id: <20120802201538.332758066@linux.com>
Date: Thu, 02 Aug 2012 15:15:20 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [14/19] slub: Introduce function for opening boot caches
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=slub_create_open_boot
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Basically the same thing happens for various boot caches.
Provide a function.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 14:56:03.915144783 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 14:56:28.451584021 -0500
@@ -3271,6 +3271,12 @@ panic:
 	return NULL;
 }
 
+static int kmem_cache_open_boot(struct kmem_cache *s, const char *name, int size)
+{
+	return kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
+		SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+}
+
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
@@ -3704,17 +3710,15 @@ void __init kmem_cache_init(void)
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
