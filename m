Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0F76B0261
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 21:41:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so745049811pfk.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 18:41:53 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 33si70930902pli.217.2017.01.03.18.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 18:41:52 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id i88so26277914pfk.2
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 18:41:52 -0800 (PST)
Subject: [next PATCH v4 2/3] mm: Rename __page_frag functions to
 __page_frag_cache, drop order from drain
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 03 Jan 2017 18:41:51 -0800
Message-ID: <20170104023954.13451.5678.stgit@localhost.localdomain>
In-Reply-To: <20170104023620.13451.80691.stgit@localhost.localdomain>
References: <20170104023620.13451.80691.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

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
v3: No change (in theory)
v4: Pulled out page_frag_alloc rename bits which had leaked through due to me
    trying out reordering some patches in my own queue.

 drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
 include/linux/gfp.h                       |    3 +--
 mm/page_alloc.c                           |   13 +++++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 594604e09f8d..cb08900c9cf2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3964,8 +3964,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__page_frag_drain(buffer_info->page, 0,
-				  buffer_info->pagecnt_bias);
+		__page_frag_cache_drain(buffer_info->page,
+					buffer_info->pagecnt_bias);
 
 		buffer_info->page = NULL;
 	}
@@ -6993,7 +6993,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
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
index 9534e44308b2..4b0541cd3699 100644
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
