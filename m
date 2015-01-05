Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8652D6B0071
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:45 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so27111273pdj.34
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:45 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vv3si8807352pab.173.2015.01.04.17.37.40
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:42 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/6] mm/slab: clean-up __ac_get_obj() to prepare future changes
Date: Mon,  5 Jan 2015 10:37:28 +0900
Message-Id: <1420421851-3281-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

This is the patch for clean-up and preparation to optimize
allocation fastpath. Until now, SLAB handles allocation request with
disabling irq. But, to improve performance, irq will not be disabled
at first in allocation fastpath. This requires changes of interface
and assumption of __ac_get_obj(). Object will be passed to
__ac_get_obj() rather than direct accessing object in array cache
in __ac_get_obj(). irq will not be disabled when entering.

To handle this future situation, this patch changes interface and name of
function to make suitable for future use. Main purpose of this
function, that is, if we have pfmemalloc object and we are not legimate
user for this memory, exchanging it to non-pfmemalloc object, is
unchanged.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   91 +++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 52 insertions(+), 39 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9aa58fc..62cd5c6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -720,50 +720,62 @@ out:
 	spin_unlock_irqrestore(&n->list_lock, flags);
 }
 
-static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
-						gfp_t flags, bool force_refill)
+static void *get_obj_from_pfmemalloc_obj(struct kmem_cache *cachep,
+				struct array_cache *ac, void *objp,
+				gfp_t flags, bool force_refill)
 {
 	int i;
-	void *objp = ac->entry[--ac->avail];
+	struct kmem_cache_node *n;
+	LIST_HEAD(list);
+	int node;
 
-	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
-	if (unlikely(is_obj_pfmemalloc(objp))) {
-		struct kmem_cache_node *n;
+	BUG_ON(ac->avail >= ac->limit);
+	BUG_ON(objp != ac->entry[ac->avail]);
 
-		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
-			return objp;
-		}
+	if (gfp_pfmemalloc_allowed(flags)) {
+		clear_obj_pfmemalloc(&objp);
+		return objp;
+	}
 
-		/* The caller cannot use PFMEMALLOC objects, find another one */
-		for (i = 0; i < ac->avail; i++) {
-			/* If a !PFMEMALLOC object is found, swap them */
-			if (!is_obj_pfmemalloc(ac->entry[i])) {
-				objp = ac->entry[i];
-				ac->entry[i] = ac->entry[ac->avail];
-				ac->entry[ac->avail] = objp;
-				return objp;
-			}
-		}
+	/* The caller cannot use PFMEMALLOC objects, find another one */
+	for (i = 0; i < ac->avail; i++) {
+		if (is_obj_pfmemalloc(ac->entry[i]))
+			continue;
 
-		/*
-		 * If there are empty slabs on the slabs_free list and we are
-		 * being forced to refill the cache, mark this one !pfmemalloc.
-		 */
-		n = get_node(cachep, numa_mem_id());
-		if (!list_empty(&n->slabs_free) && force_refill) {
-			struct page *page = virt_to_head_page(objp);
-			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
-			recheck_pfmemalloc_active(cachep, ac);
-			return objp;
-		}
+		/* !PFMEMALLOC object is found, swap them */
+		objp = ac->entry[i];
+		ac->entry[i] = ac->entry[ac->avail];
+		ac->entry[ac->avail] = objp;
 
-		/* No !PFMEMALLOC objects available */
-		ac->avail++;
-		objp = NULL;
+		return objp;
 	}
 
+	/*
+	 * If there are empty slabs on the slabs_free list and we are
+	 * being forced to refill the cache, mark this one !pfmemalloc.
+	 */
+	node = numa_mem_id();
+	n = get_node(cachep, node);
+	if (!list_empty(&n->slabs_free) && force_refill) {
+		struct page *page = virt_to_head_page(objp);
+
+		ClearPageSlabPfmemalloc(page);
+		clear_obj_pfmemalloc(&objp);
+		recheck_pfmemalloc_active(cachep, ac);
+
+		return objp;
+	}
+
+	/* No !PFMEMALLOC objects available */
+	if (ac->avail < ac->limit)
+		ac->entry[ac->avail++] = objp;
+	else {
+		spin_lock(&n->list_lock);
+		free_block(cachep, &objp, 1, node, &list);
+		spin_unlock(&n->list_lock);
+	}
+	objp = NULL;
+
 	return objp;
 }
 
@@ -772,10 +784,11 @@ static inline void *ac_get_obj(struct kmem_cache *cachep,
 {
 	void *objp;
 
-	if (unlikely(sk_memalloc_socks()))
-		objp = __ac_get_obj(cachep, ac, flags, force_refill);
-	else
-		objp = ac->entry[--ac->avail];
+	objp = ac->entry[--ac->avail];
+	if (unlikely(sk_memalloc_socks()) && is_obj_pfmemalloc(objp)) {
+		objp = get_obj_from_pfmemalloc_obj(cachep, ac, objp,
+						flags, force_refill);
+	}
 
 	return objp;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
