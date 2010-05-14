Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C55AF6B01F0
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:07 -0400 (EDT)
Message-Id: <20100514183944.948330467@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:13 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 05/10] SLUB: is_kmalloc_cache
Content-Disposition: inline; filename=slub_is_kmalloc_cache
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The determination if a slab is occurring multiple times.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>


---
 mm/slub.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-12 14:46:58.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-12 14:49:37.000000000 -0500
@@ -312,6 +312,11 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+static int is_kmalloc_cache(struct kmem_cache *s)
+{
+	return (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches);
+}
+
 #ifdef CONFIG_SLUB_DEBUG
 /*
  * Debug settings:
@@ -2076,7 +2081,7 @@ static DEFINE_PER_CPU(struct kmem_cache_
 
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
-	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
+	if (is_kmalloc_cache(s))
 		/*
 		 * Boot time creation of the kmalloc array. Use static per cpu data
 		 * since the per cpu allocator is not available yet.
@@ -2158,8 +2163,7 @@ static int init_kmem_cache_nodes(struct 
 	int node;
 	int local_node;
 
-	if (slab_state >= UP && (s < kmalloc_caches ||
-			s >= kmalloc_caches + KMALLOC_CACHES))
+	if (slab_state >= UP && !is_kmalloc_cache(s))
 		local_node = page_to_nid(virt_to_page(s));
 	else
 		local_node = 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
