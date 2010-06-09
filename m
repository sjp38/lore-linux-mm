Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BC5C26B01DE
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:49:20 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o596nI8f011497
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:18 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz1.hot.corp.google.com with ESMTP id o596mbgx030284
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:17 -0700
Received: by pvg7 with SMTP id 7so3783310pvg.25
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:49:17 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:49:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/4] slub: remove gfp_flags argument from
 create_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082348450.30606@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

create_kmalloc_cache() is always passed a gfp_t of GFP_NOWAIT, so it may
be hardwired into the function itself instead of passed.

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2572,7 +2572,7 @@ static int __init setup_slub_nomerge(char *str)
 __setup("slub_nomerge", setup_slub_nomerge);
 
 static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
-		const char *name, int size, gfp_t gfp_flags)
+				const char *name, int size)
 {
 	unsigned int flags = 0;
 
@@ -2582,14 +2582,11 @@ static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
 		return s;
 	}
 
-	if (gfp_flags & SLUB_DMA)
-		flags = SLAB_CACHE_DMA;
-
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slub_lock here.
 	 */
-	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
+	if (!kmem_cache_open(s, GFP_NOWAIT, name, size, ARCH_KMALLOC_MINALIGN,
 								flags, NULL))
 		goto panic;
 
@@ -3077,7 +3074,7 @@ void __init kmem_cache_init(void)
 	 */
 	i = kmalloc_index(sizeof(struct kmem_cache_node));
 	create_kmalloc_cache(&kmalloc_caches[i], "bootstrap",
-		sizeof(struct kmem_cache_node), GFP_NOWAIT);
+		sizeof(struct kmem_cache_node));
 	kmalloc_caches[i].refcount = -1;
 	caches++;
 
@@ -3089,19 +3086,16 @@ void __init kmem_cache_init(void)
 
 	/* Caches that are not of the two-to-the-power-of size */
 	if (KMALLOC_MIN_SIZE <= 32) {
-		create_kmalloc_cache(&kmalloc_caches[1],
-				"kmalloc-96", 96, GFP_NOWAIT);
+		create_kmalloc_cache(&kmalloc_caches[1], "kmalloc-96", 96);
 		caches++;
 	}
 	if (KMALLOC_MIN_SIZE <= 64) {
-		create_kmalloc_cache(&kmalloc_caches[2],
-				"kmalloc-192", 192, GFP_NOWAIT);
+		create_kmalloc_cache(&kmalloc_caches[2], "kmalloc-192", 192);
 		caches++;
 	}
 
 	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
-		create_kmalloc_cache(&kmalloc_caches[i],
-			"kmalloc", 1 << i, GFP_NOWAIT);
+		create_kmalloc_cache(&kmalloc_caches[i], "kmalloc", 1 << i);
 		caches++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
