Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC806B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:27 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so11837704pab.19
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:27 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id to9si4662117pbc.125.2014.02.13.22.57.25
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:26 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/9] slab: makes clear_obj_pfmemalloc() just return store masked value
Date: Fri, 14 Feb 2014 15:57:16 +0900
Message-Id: <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

clear_obj_pfmemalloc() takes the pointer to the object pointer as argument
to store masked value back into this address.
But this is useless, since we don't use this stored value anymore.
All we need is just masked value. So makes clear_obj_pfmemalloc()
just return masked value.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 5906f8f..6d17cad 100644
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
@@ -810,7 +810,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		struct kmem_cache_node *n;
 
 		if (gfp_pfmemalloc_allowed(flags)) {
-			clear_obj_pfmemalloc(&objp);
+			objp = clear_obj_pfmemalloc(objp);
 			return objp;
 		}
 
@@ -833,7 +833,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
 			ClearPageSlabPfmemalloc(page);
-			clear_obj_pfmemalloc(&objp);
+			objp = clear_obj_pfmemalloc(objp);
 			recheck_pfmemalloc_active(cachep, ac);
 			return objp;
 		}
@@ -3365,8 +3365,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
