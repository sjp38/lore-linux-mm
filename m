Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2B603828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:18 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e127so46391028pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:18 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id v68si17608091pfi.16.2016.02.25.22.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:17 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id fl4so45443350pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:17 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 13/17] mm/slab: make criteria for off slab determination robust and simple
Date: Fri, 26 Feb 2016 15:01:20 +0900
Message-Id: <1456466484-3442-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

To become an off slab, there are some constraints to avoid bootstrapping
problem and recursive call.  This can be avoided differently by simply
checking that corresponding kmalloc cache is ready and it's not a off
slab.  It would be more robust because static size checking can be
affected by cache size change or architecture type but dynamic checking
isn't.

One check 'freelist_cache->size > cachep->size / 2' is added to check
benefit of choosing off slab, because, now, there is no size constraint
which ensures enough advantage when selecting off slab.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 45 +++++++++++++++++----------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 21aad9d..ab43d9f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -272,7 +272,6 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 
 #define CFLGS_OFF_SLAB		(0x80000000UL)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
-#define OFF_SLAB_MIN_SIZE (max_t(size_t, PAGE_SIZE >> 5, KMALLOC_MIN_SIZE + 1))
 
 #define BATCHREFILL_LIMIT	16
 /*
@@ -1879,7 +1878,6 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
 static size_t calculate_slab_order(struct kmem_cache *cachep,
 				size_t size, unsigned long flags)
 {
-	unsigned long offslab_limit;
 	size_t left_over = 0;
 	int gfporder;
 
@@ -1896,16 +1894,24 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			break;
 
 		if (flags & CFLGS_OFF_SLAB) {
+			struct kmem_cache *freelist_cache;
+			size_t freelist_size;
+
+			freelist_size = num * sizeof(freelist_idx_t);
+			freelist_cache = kmalloc_slab(freelist_size, 0u);
+			if (!freelist_cache)
+				continue;
+
 			/*
-			 * Max number of objs-per-slab for caches which
-			 * use off-slab slabs. Needed to avoid a possible
-			 * looping condition in cache_grow().
+			 * Needed to avoid possible looping condition
+			 * in cache_grow()
 			 */
-			offslab_limit = size;
-			offslab_limit /= sizeof(freelist_idx_t);
+			if (OFF_SLAB(freelist_cache))
+				continue;
 
- 			if (num > offslab_limit)
-				break;
+			/* check if off slab has enough benefit */
+			if (freelist_cache->size > cachep->size / 2)
+				continue;
 		}
 
 		/* Found something acceptable - save it away */
@@ -2031,17 +2037,9 @@ static bool set_off_slab_cache(struct kmem_cache *cachep,
 	cachep->num = 0;
 
 	/*
-	 * Determine if the slab management is 'on' or 'off' slab.
-	 * (bootstrapping cannot cope with offslab caches so don't do
-	 * it too early on. Always use on-slab management when
-	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
+	 * Always use on-slab management when SLAB_NOLEAKTRACE
+	 * to avoid recursive calls into kmemleak.
 	 */
-	if (size < OFF_SLAB_MIN_SIZE)
-		return false;
-
-	if (slab_early_init)
-		return false;
-
 	if (flags & SLAB_NOLEAKTRACE)
 		return false;
 
@@ -2205,7 +2203,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * sized slab is initialized in current slab initialization sequence.
 	 */
 	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
-		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
 		size >= 256 && cachep->object_size > cache_line_size()) {
 		if (size < PAGE_SIZE || size % PAGE_SIZE == 0) {
 			size_t tmp_size = ALIGN(size, PAGE_SIZE);
@@ -2254,14 +2251,6 @@ done:
 	if (OFF_SLAB(cachep)) {
 		cachep->freelist_cache =
 			kmalloc_slab(cachep->freelist_size, 0u);
-		/*
-		 * This is a possibility for one of the kmalloc_{dma,}_caches.
-		 * But since we go off slab only for object size greater than
-		 * OFF_SLAB_MIN_SIZE, and kmalloc_{dma,}_caches get created
-		 * in ascending order,this should not happen at all.
-		 * But leave a BUG_ON for some lucky dude.
-		 */
-		BUG_ON(ZERO_OR_NULL_PTR(cachep->freelist_cache));
 	}
 
 	err = setup_cpu_cache(cachep, gfp);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
