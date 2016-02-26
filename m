Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E51916B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:42 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id c10so47842298pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:42 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id e69si17590634pfd.66.2016.02.25.22.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:42 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id q63so46290558pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:42 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 03/17] mm/slab: remove the checks for slab implementation bug
Date: Fri, 26 Feb 2016 15:01:10 +0900
Message-Id: <1456466484-3442-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Some of "#if DEBUG" are for reporting slab implementation bug rather than
user usecase bug.  It's not really needed because slab is stable for a
quite long time and it makes code too dirty.  This patch remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3634dc1..14c3f9c 100644
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
@@ -3101,7 +3088,7 @@ retry:
 
 	BUG_ON(page->active == cachep->num);
 
-	obj = slab_get_obj(cachep, page, nodeid);
+	obj = slab_get_obj(cachep, page);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
 	list_del(&page->lru);
@@ -3252,7 +3239,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		page = virt_to_head_page(objp);
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
-		slab_put_obj(cachep, page, objp, node);
+		slab_put_obj(cachep, page, objp);
 		STATS_DEC_ACTIVE(cachep);
 		n->free_objects++;
 
@@ -3282,9 +3269,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
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
