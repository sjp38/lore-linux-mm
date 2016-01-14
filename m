Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 81500828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:37 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so109900654pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:37 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id k11si3218420pfb.72.2016.01.13.21.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:36 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id e65so6950168pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:36 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 03/16] mm/slab: remove the checks for slab implementation bug
Date: Thu, 14 Jan 2016 14:24:16 +0900
Message-Id: <1452749069-15334-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Some of "#if DEBUG" are for reporting slab implementation bug
rather than user usecase bug. It's not really needed because slab
is stable for a quite long time and it makes code too dirty. This
patch remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1bc6294..bbe4df2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2110,8 +2110,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (!(flags & SLAB_DESTROY_BY_RCU))
 		flags |= SLAB_POISON;
 #endif
-	if (flags & SLAB_DESTROY_BY_RCU)
-		BUG_ON(flags & SLAB_POISON);
 #endif
 
 	/*
@@ -2368,9 +2366,6 @@ static int drain_freelist(struct kmem_cache *cache,
 		}
 
 		page = list_entry(p, struct page, lru);
-#if DEBUG
-		BUG_ON(page->active);
-#endif
 		list_del(&page->lru);
 		/*
 		 * Safe to drop the lock. The slab is no longer linked
@@ -2528,30 +2523,23 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 	}
 }
 
-static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
-				int nodeid)
+static void *slab_get_obj(struct kmem_cache *cachep, struct page *page)
 {
 	void *objp;
 
 	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
 	page->active++;
-#if DEBUG
-	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
-#endif
 
 	return objp;
 }
 
-static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
-				void *objp, int nodeid)
+static void slab_put_obj(struct kmem_cache *cachep,
+			struct page *page, void *objp)
 {
 	unsigned int objnr = obj_to_index(cachep, page, objp);
 #if DEBUG
 	unsigned int i;
 
-	/* Verify that the slab belongs to the intended node */
-	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
-
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
 		if (get_free_obj(page, i) == objnr) {
@@ -2817,8 +2805,7 @@ retry:
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac_put_obj(cachep, ac, slab_get_obj(cachep, page,
-									node));
+			ac_put_obj(cachep, ac, slab_get_obj(cachep, page));
 		}
 
 		/* move slabp to correct slabp list: */
@@ -3109,7 +3096,7 @@ retry:
 
 	BUG_ON(page->active == cachep->num);
 
-	obj = slab_get_obj(cachep, page, nodeid);
+	obj = slab_get_obj(cachep, page);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
 	list_del(&page->lru);
@@ -3278,7 +3265,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		page = virt_to_head_page(objp);
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
-		slab_put_obj(cachep, page, objp, node);
+		slab_put_obj(cachep, page, objp);
 		STATS_DEC_ACTIVE(cachep);
 		n->free_objects++;
 
@@ -3308,9 +3295,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 	LIST_HEAD(list);
 
 	batchcount = ac->batchcount;
-#if DEBUG
-	BUG_ON(!batchcount || batchcount > ac->avail);
-#endif
+
 	check_irq_off();
 	n = get_node(cachep, node);
 	spin_lock(&n->list_lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
