Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 763A9828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:21 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id c10so47852795pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:21 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id fg8si684009pad.227.2016.02.25.22.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:20 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id q63so46300733pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:20 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 14/17] mm/slab: factor out slab list fixup code
Date: Fri, 26 Feb 2016 15:01:21 +0900
Message-Id: <1456466484-3442-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Slab list should be fixed up after object is detached from the slab and
this happens at two places.  They do exactly same thing.  They will be
changed in the following patch, so, to reduce code duplication, this patch
factor out them and make it common function.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index ab43d9f..95e5d63 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2723,6 +2723,17 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
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
@@ -2796,12 +2807,7 @@ retry:
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
@@ -3067,13 +3073,8 @@ retry:
 
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
