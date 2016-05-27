Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F89F6B0005
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:14:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so28330772lfz.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:14:06 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id v8si27346211wjf.38.2016.05.27.10.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:14:04 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id z87so793492wmh.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:14:04 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1] [mm] Set page->slab_cache for every page allocated for a kmem_cache.
Date: Fri, 27 May 2016 19:14:00 +0200
Message-Id: <1464369240-35844-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's reasonable to rely on the fact that for every page allocated for a
kmem_cache the |slab_cache| field points to that cache. Without that it's
hard to figure out which cache does an allocated object belong to.

Fixes: 55834c59098d0c5a97b0f324 ("mm: kasan: initial memory quarantine
implementation")
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 mm/slab.c | 7 ++++++-
 mm/slub.c | 8 +++++---
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1..ac6c251 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2703,8 +2703,13 @@ static void slab_put_obj(struct kmem_cache *cachep,
 static void slab_map_pages(struct kmem_cache *cache, struct page *page,
 			   void *freelist)
 {
-	page->slab_cache = cache;
+	int i, nr_pages;
+	char *start = page_address(page);
+
 	page->freelist = freelist;
+	nr_pages = (1 << cache->gfporder);
+	for (i = 0; i < nr_pages; i++)
+		virt_to_page(start + PAGE_SIZE * i)->slab_cache = cache;
 }
 
 /*
diff --git a/mm/slub.c b/mm/slub.c
index 825ff45..fc75ddb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1411,7 +1411,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
 	void *start, *p;
-	int idx, order;
+	int idx, order, i, pages;
 
 	flags &= gfp_allowed_mask;
 
@@ -1442,9 +1442,9 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 		stat(s, ORDER_FALLBACK);
 	}
 
+	pages = 1 << oo_order(oo);
 	if (kmemcheck_enabled &&
 	    !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
-		int pages = 1 << oo_order(oo);
 
 		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
 
@@ -1461,13 +1461,15 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	page->objects = oo_objects(oo);
 
 	order = compound_order(page);
-	page->slab_cache = s;
 	__SetPageSlab(page);
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
 	start = page_address(page);
 
+	for (i = 0; i < pages; i++)
+		virt_to_page(start + PAGE_SIZE * i)->slab_cache = s;
+
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
