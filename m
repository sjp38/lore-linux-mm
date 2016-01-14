Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3688308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:13 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so93573193pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:13 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id c76si6891684pfj.134.2016.01.13.21.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:12 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id e65so6950715pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:12 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 14/16] mm/slab: factor out slab list fixup code
Date: Thu, 14 Jan 2016 14:24:27 +0900
Message-Id: <1452749069-15334-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Slab list should be fixed up after object is detached from the slab
and this happens at two places. They do exactly same thing. They will
be changed in the following patch, so, to reduce code duplication,
this patch factor out them and make it common function.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e86977e..dbf18ed 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2724,6 +2724,17 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 #define cache_free_debugcheck(x,objp,z) (objp)
 #endif
 
+static inline void fixup_slab_list(struct kmem_cache *cachep,
+				struct kmem_cache_node *n, struct page *page)
+{
+	/* move slabp to correct slabp list: */
+	list_del(&page->lru);
+	if (page->active == cachep->num)
+		list_add(&page->lru, &n->slabs_full);
+	else
+		list_add(&page->lru, &n->slabs_partial);
+}
+
 static struct page *get_first_slab(struct kmem_cache_node *n)
 {
 	struct page *page;
@@ -2797,12 +2808,7 @@ retry:
 			ac_put_obj(cachep, ac, slab_get_obj(cachep, page));
 		}
 
-		/* move slabp to correct slabp list: */
-		list_del(&page->lru);
-		if (page->active == cachep->num)
-			list_add(&page->lru, &n->slabs_full);
-		else
-			list_add(&page->lru, &n->slabs_partial);
+		fixup_slab_list(cachep, n, page);
 	}
 
 must_grow:
@@ -3076,13 +3082,8 @@ retry:
 
 	obj = slab_get_obj(cachep, page);
 	n->free_objects--;
-	/* move slabp to correct slabp list: */
-	list_del(&page->lru);
 
-	if (page->active == cachep->num)
-		list_add(&page->lru, &n->slabs_full);
-	else
-		list_add(&page->lru, &n->slabs_partial);
+	fixup_slab_list(cachep, n, page);
 
 	spin_unlock(&n->list_lock);
 	goto done;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
