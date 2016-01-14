Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 59A2D8308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:16 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so93573907pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:16 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id f83si6868601pfd.208.2016.01.13.21.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:15 -0800 (PST)
Received: by mail-pa0-x244.google.com with SMTP id a20so22798697pag.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:15 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 15/16] mm/slab: factor out debugging initialization in cache_init_objs()
Date: Thu, 14 Jan 2016 14:24:28 +0900
Message-Id: <1452749069-15334-16-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

cache_init_objs() will be changed in following patch and current form
doesn't fit well for that change. So, before doing it, this patch
separates debugging initialization. This would cause two loop iteration
when debugging is enabled, but, this overhead seems too light than
debug feature itself so effect may not be visible. This patch will
greatly simplify changes in cache_init_objs() in following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index dbf18ed..a9807c3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2461,14 +2461,14 @@ static inline void set_free_obj(struct page *page,
 	((freelist_idx_t *)(page->freelist))[idx] = val;
 }
 
-static void cache_init_objs(struct kmem_cache *cachep,
-			    struct page *page)
+static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 {
+#if DEBUG
 	int i;
 
 	for (i = 0; i < cachep->num; i++) {
 		void *objp = index_to_obj(cachep, page, i);
-#if DEBUG
+
 		if (cachep->flags & SLAB_STORE_USER)
 			*dbg_userword(cachep, objp) = NULL;
 
@@ -2497,10 +2497,22 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			poison_obj(cachep, objp, POISON_FREE);
 			slab_kernel_map(cachep, objp, 0, 0);
 		}
-#else
-		if (cachep->ctor)
-			cachep->ctor(objp);
+	}
 #endif
+}
+
+static void cache_init_objs(struct kmem_cache *cachep,
+			    struct page *page)
+{
+	int i;
+
+	cache_init_objs_debug(cachep, page);
+
+	for (i = 0; i < cachep->num; i++) {
+		/* constructor could break poison info */
+		if (DEBUG == 0 && cachep->ctor)
+			cachep->ctor(index_to_obj(cachep, page, i));
+
 		set_free_obj(page, i, i);
 	}
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
