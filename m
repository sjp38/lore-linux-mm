Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 24341828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:25 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id x65so46381900pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:25 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 134si552063pfa.156.2016.02.25.22.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:24 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id yy13so45402362pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:24 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 15/17] mm/slab: factor out debugging initialization in cache_init_objs()
Date: Fri, 26 Feb 2016 15:01:22 +0900
Message-Id: <1456466484-3442-16-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

cache_init_objs() will be changed in following patch and current form
doesn't fit well for that change.  So, before doing it, this patch
separates debugging initialization.  This would cause two loop iteration
when debugging is enabled, but, this overhead seems too light than debug
feature itself so effect may not be visible.  This patch will greatly
simplify changes in cache_init_objs() in following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 95e5d63..d3608d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2460,14 +2460,14 @@ static inline void set_free_obj(struct page *page,
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
 
@@ -2496,10 +2496,22 @@ static void cache_init_objs(struct kmem_cache *cachep,
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
