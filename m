Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC904280281
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 12:17:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u5so114552155pgi.7
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:17:37 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id l7si34723519pfc.49.2016.12.23.09.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 09:17:36 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so1079449pgc.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:17:36 -0800 (PST)
Subject: [net/mm PATCH v2 2/3] mm: Rename __page_frag functions to
 __page_frag_cache, drop order from drain
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 23 Dec 2016 09:17:35 -0800
Message-ID: <20161223171718.14573.63466.stgit@localhost.localdomain>
In-Reply-To: <20161223170756.14573.74139.stgit@localhost.localdomain>
References: <20161223170756.14573.74139.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch does two things.

First it goes through and renames the __page_frag prefixed functions to
__page_frag_cache so that we can be clear that we are draining or refilling
the cache, not the frags themselves.

Second we drop the order parameter from __page_frag_cache_drain since we
don't actually need to pass it since all fragments are either order 0 or
must be a compound page.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: No change

 drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
 include/linux/gfp.h                       |    3 +--
 mm/page_alloc.c                           |   13 +++++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a761001308dc..1515abaa5ac9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3962,8 +3962,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__page_frag_drain(buffer_info->page, 0,
-				  buffer_info->pagecnt_bias);
+		__page_frag_cache_drain(buffer_info->page,
+					buffer_info->pagecnt_bias);
 
 		buffer_info->page = NULL;
 	}
@@ -6991,7 +6991,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     PAGE_SIZE, DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__page_frag_drain(page, 0, rx_buffer->pagecnt_bias);
+		__page_frag_cache_drain(page, rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of rx_buffer */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6238c74e0a01..884080404e24 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -506,8 +506,7 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
-extern void __page_frag_drain(struct page *page, unsigned int order,
-			      unsigned int count);
+extern void __page_frag_cache_drain(struct page *page, unsigned int count);
 extern void *page_frag_alloc(struct page_frag_cache *nc,
 			     unsigned int fragsz, gfp_t gfp_mask);
 extern void page_frag_free(void *addr);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 842df9d60ebc..c11c359c46b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3904,8 +3904,8 @@ void free_pages(unsigned long addr, unsigned int order)
  * drivers to provide a backing region of memory for use as either an
  * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
  */
-static struct page *__page_frag_refill(struct page_frag_cache *nc,
-				       gfp_t gfp_mask)
+static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
+					     gfp_t gfp_mask)
 {
 	struct page *page = NULL;
 	gfp_t gfp = gfp_mask;
@@ -3925,19 +3925,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
 	return page;
 }
 
-void __page_frag_drain(struct page *page, unsigned int order,
-		       unsigned int count)
+void __page_frag_cache_drain(struct page *page, unsigned int count)
 {
 	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
 
 	if (page_ref_sub_and_test(page, count)) {
+		unsigned int order = compound_order(page);
+
 		if (order == 0)
 			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
 	}
 }
-EXPORT_SYMBOL(__page_frag_drain);
+EXPORT_SYMBOL(__page_frag_cache_drain);
 
 void *page_frag_alloc(struct page_frag_cache *nc,
 		      unsigned int fragsz, gfp_t gfp_mask)
@@ -3948,7 +3949,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 
 	if (unlikely(!nc->va)) {
 refill:
-		page = __page_frag_refill(nc, gfp_mask);
+		page = __page_frag_cache_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
