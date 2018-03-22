Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D20F86B0024
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:14 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so4336060pgt.6
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c11si4554184pga.382.2018.03.22.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 3/8] page_frag_cache: Rename 'nc' to 'pfc'
Date: Thu, 22 Mar 2018 08:31:52 -0700
Message-Id: <20180322153157.10447-4-willy@infradead.org>
In-Reply-To: <20180322153157.10447-1-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This name was a legacy from the 'netdev_alloc_cache' days.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/page_alloc.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d2c106f4e5d..c9fc76135dd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4336,21 +4336,21 @@ EXPORT_SYMBOL(free_pages);
  * drivers to provide a backing region of memory for use as either an
  * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
  */
-static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
+static struct page *__page_frag_cache_refill(struct page_frag_cache *pfc,
 					     gfp_t gfp_mask)
 {
 	unsigned int size = PAGE_SIZE;
 	struct page *page = NULL;
-	struct page *old = nc->va ? virt_to_page(nc->va) : NULL;
+	struct page *old = pfc->va ? virt_to_page(pfc->va) : NULL;
 	gfp_t gfp = gfp_mask;
-	unsigned int pagecnt_bias = nc->pagecnt_bias & ~PFC_MEMALLOC;
+	unsigned int pagecnt_bias = pfc->pagecnt_bias & ~PFC_MEMALLOC;
 
 	/* If all allocations have been freed, we can reuse this page */
 	if (old && page_ref_sub_and_test(old, pagecnt_bias)) {
 		page = old;
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
 		/* if size can vary use size else just use PAGE_SIZE */
-		size = nc->size;
+		size = pfc->size;
 #endif
 		/* Page count is 0, we can safely set it */
 		set_page_count(page, size);
@@ -4364,25 +4364,25 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
 				PAGE_FRAG_CACHE_MAX_ORDER);
 	if (page)
 		size = PAGE_FRAG_CACHE_MAX_SIZE;
-	nc->size = size;
+	pfc->size = size;
 #endif
 	if (unlikely(!page))
 		page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
 	if (!page) {
-		nc->va = NULL;
+		pfc->va = NULL;
 		return NULL;
 	}
 
-	nc->va = page_address(page);
+	pfc->va = page_address(page);
 
 	/* Using atomic_set() would break get_page_unless_zero() users. */
 	page_ref_add(page, size - 1);
 reset:
 	/* reset page count bias and offset to start of new frag */
-	nc->pagecnt_bias = size;
+	pfc->pagecnt_bias = size;
 	if (page_is_pfmemalloc(page))
-		nc->pagecnt_bias |= PFC_MEMALLOC;
-	nc->offset = size;
+		pfc->pagecnt_bias |= PFC_MEMALLOC;
+	pfc->offset = size;
 
 	return page;
 }
@@ -4402,27 +4402,27 @@ void __page_frag_cache_drain(struct page *page, unsigned int count)
 }
 EXPORT_SYMBOL(__page_frag_cache_drain);
 
-void *page_frag_alloc(struct page_frag_cache *nc,
+void *page_frag_alloc(struct page_frag_cache *pfc,
 		      unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct page *page;
 	int offset;
 
-	if (unlikely(!nc->va)) {
+	if (unlikely(!pfc->va)) {
 refill:
-		page = __page_frag_cache_refill(nc, gfp_mask);
+		page = __page_frag_cache_refill(pfc, gfp_mask);
 		if (!page)
 			return NULL;
 	}
 
-	offset = nc->offset - fragsz;
+	offset = pfc->offset - fragsz;
 	if (unlikely(offset < 0))
 		goto refill;
 
-	nc->pagecnt_bias--;
-	nc->offset = offset;
+	pfc->pagecnt_bias--;
+	pfc->offset = offset;
 
-	return nc->va + offset;
+	return pfc->va + offset;
 }
 EXPORT_SYMBOL(page_frag_alloc);
 
-- 
2.16.2
