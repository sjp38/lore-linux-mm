Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A563D6B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:39 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so688450pab.11
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:39 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id of4si1280275pbb.406.2014.05.06.23.04.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 02/10] slab: makes clear_obj_pfmemalloc() just return masked value
Date: Wed,  7 May 2014 15:06:12 +0900
Message-Id: <1399442780-28748-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

clear_obj_pfmemalloc() takes the pointer to pointer to store masked value
back into this address. But this is useless, since we don't use this stored
value anymore. All we need is just masked value so makes clear_obj_pfmemalloc()
just return masked value.

v2: simplify commit description.
    directly return return value of clear_obj_pfmemalloc().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 1fede40..e2c80df 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -215,9 +215,9 @@ static inline void set_obj_pfmemalloc(void **objp)
 	return;
 }
 
-static inline void clear_obj_pfmemalloc(void **objp)
+static inline void *clear_obj_pfmemalloc(void *objp)
 {
-	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
+	return (void *)((unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC);
 }
 
 /*
@@ -809,10 +809,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	if (unlikely(is_obj_pfmemalloc(objp))) {
 		struct kmem_cache_node *n;
 
-		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
-			return objp;
-		}
+		if (gfp_pfmemalloc_allowed(flags))
+			return clear_obj_pfmemalloc(objp);
 
 		/* The caller cannot use PFMEMALLOC objects, find another one */
 		for (i = 0; i < ac->avail; i++) {
@@ -833,9 +831,8 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
 			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
 			recheck_pfmemalloc_active(cachep, ac);
-			return objp;
+			return clear_obj_pfmemalloc(objp);
 		}
 
 		/* No !PFMEMALLOC objects available */
@@ -3349,8 +3346,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		void *objp;
 		struct page *page;
 
-		clear_obj_pfmemalloc(&objpp[i]);
-		objp = objpp[i];
+		objp = clear_obj_pfmemalloc(objpp[i]);
 
 		page = virt_to_head_page(objp);
 		n = cachep->node[node];
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
