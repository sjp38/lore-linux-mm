Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECB988308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:09 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so96350426pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:09 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id kr7si6871315pab.120.2016.01.13.21.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:09 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id n128so6915594pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:09 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 13/16] mm/slab: make criteria for off slab determination robust and simple
Date: Thu, 14 Jan 2016 14:24:26 +0900
Message-Id: <1452749069-15334-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To become a off slab, there are some constraints to avoid
bootstrapping problem and recursive call. This can be avoided differently
by simply checking that corresponding kmalloc cache is ready and it's not
a off slab. It would be more robust because static size checking can be
affected by cache size change or architecture type but dynamic checking
isn't.

One check 'freelist_cache->size > cachep->size / 2' is added to check
benefit of choosing off slab, because, now, there is no size constraint
which ensures enough advantage when selecting off slab.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 45 +++++++++++++++++----------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b0f6eda..e86977e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -272,7 +272,6 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 
 #define CFLGS_OFF_SLAB		(0x80000000UL)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
-#define OFF_SLAB_MIN_SIZE (max_t(size_t, PAGE_SIZE >> 5, KMALLOC_MIN_SIZE + 1))
 
 #define BATCHREFILL_LIMIT	16
 /*
@@ -1880,7 +1879,6 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
 static size_t calculate_slab_order(struct kmem_cache *cachep,
 				size_t size, unsigned long flags)
 {
-	unsigned long offslab_limit;
 	size_t left_over = 0;
 	int gfporder;
 
@@ -1897,16 +1895,24 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
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
@@ -2032,17 +2038,9 @@ static bool set_off_slab_cache(struct kmem_cache *cachep,
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
 
@@ -2206,7 +2204,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * sized slab is initialized in current slab initialization sequence.
 	 */
 	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
-		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
 		size >= 256 && cachep->object_size > cache_line_size()) {
 		if (size < PAGE_SIZE || size % PAGE_SIZE == 0) {
 			size_t tmp_size = ALIGN(size, PAGE_SIZE);
@@ -2255,14 +2252,6 @@ done:
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
