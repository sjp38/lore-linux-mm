Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77F526B000D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:14 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id k4-v6so5600464pls.15
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bf3-v6si4555837plb.734.2018.03.22.08.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 2/8] page_frag_cache: Move slowpath code from page_frag_alloc
Date: Thu, 22 Mar 2018 08:31:51 -0700
Message-Id: <20180322153157.10447-3-willy@infradead.org>
In-Reply-To: <20180322153157.10447-1-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Put all the unlikely code in __page_frag_cache_refill to make the
fastpath code more obvious.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/page_alloc.c | 70 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 34 insertions(+), 36 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61366f23e8c8..6d2c106f4e5d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4339,20 +4339,50 @@ EXPORT_SYMBOL(free_pages);
 static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
 					     gfp_t gfp_mask)
 {
+	unsigned int size = PAGE_SIZE;
 	struct page *page = NULL;
+	struct page *old = nc->va ? virt_to_page(nc->va) : NULL;
 	gfp_t gfp = gfp_mask;
+	unsigned int pagecnt_bias = nc->pagecnt_bias & ~PFC_MEMALLOC;
+
+	/* If all allocations have been freed, we can reuse this page */
+	if (old && page_ref_sub_and_test(old, pagecnt_bias)) {
+		page = old;
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+		/* if size can vary use size else just use PAGE_SIZE */
+		size = nc->size;
+#endif
+		/* Page count is 0, we can safely set it */
+		set_page_count(page, size);
+		goto reset;
+	}
 
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
 	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
 		    __GFP_NOMEMALLOC;
 	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
 				PAGE_FRAG_CACHE_MAX_ORDER);
-	nc->size = page ? PAGE_FRAG_CACHE_MAX_SIZE : PAGE_SIZE;
+	if (page)
+		size = PAGE_FRAG_CACHE_MAX_SIZE;
+	nc->size = size;
 #endif
 	if (unlikely(!page))
 		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
+	if (!page) {
+		nc->va = NULL;
+		return NULL;
+	}
+
+	nc->va = page_address(page);
 
-	nc->va = page ? page_address(page) : NULL;
+	/* Using atomic_set() would break get_page_unless_zero() users. */
+	page_ref_add(page, size - 1);
+reset:
+	/* reset page count bias and offset to start of new frag */
+	nc->pagecnt_bias = size;
+	if (page_is_pfmemalloc(page))
+		nc->pagecnt_bias |= PFC_MEMALLOC;
+	nc->offset = size;
 
 	return page;
 }
@@ -4375,7 +4405,6 @@ EXPORT_SYMBOL(__page_frag_cache_drain);
 void *page_frag_alloc(struct page_frag_cache *nc,
 		      unsigned int fragsz, gfp_t gfp_mask)
 {
-	unsigned int size = PAGE_SIZE;
 	struct page *page;
 	int offset;
 
@@ -4384,42 +4413,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		page = __page_frag_cache_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
-
-#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
-		/* if size can vary use size else just use PAGE_SIZE */
-		size = nc->size;
-#endif
-		/* Even if we own the page, we do not use atomic_set().
-		 * This would break get_page_unless_zero() users.
-		 */
-		page_ref_add(page, size - 1);
-
-		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
-		if (page_is_pfmemalloc(page))
-			nc->pagecnt_bias |= PFC_MEMALLOC;
-		nc->offset = size;
 	}
 
 	offset = nc->offset - fragsz;
-	if (unlikely(offset < 0)) {
-		unsigned int pagecnt_bias = nc->pagecnt_bias & ~PFC_MEMALLOC;
-		page = virt_to_page(nc->va);
-
-		if (!page_ref_sub_and_test(page, pagecnt_bias))
-			goto refill;
-
-#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
-		/* if size can vary use size else just use PAGE_SIZE */
-		size = nc->size;
-#endif
-		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
-
-		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size | (nc->pagecnt_bias - pagecnt_bias);
-		offset = size - fragsz;
-	}
+	if (unlikely(offset < 0))
+		goto refill;
 
 	nc->pagecnt_bias--;
 	nc->offset = offset;
-- 
2.16.2
