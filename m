Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CEE6280254
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:07:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x70so83333970pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:07:16 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id pc4si13858183pac.262.2016.10.24.11.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:07:15 -0700 (PDT)
Subject: [net-next PATCH RFC 25/26] igb: Update code to better handle
 incrementing page count
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:38 -0400
Message-ID: <20161024120638.16276.40943.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

This patch updates the driver code so that we do bulk updates of the page
reference count instead of just incrementing it by one reference at a time.
The advantage to doing this is that we cut down on atomic operations and
this in turn should give us a slight improvement in cycles per packet.  In
addition if we eventually move this over to using build_skb the gains will
be more noticeable.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c |   24 +++++++++++++++++-------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index d11093d..acbc3ab 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -210,7 +210,12 @@ struct igb_tx_buffer {
 struct igb_rx_buffer {
 	dma_addr_t dma;
 	struct page *page;
-	unsigned int page_offset;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
+	__u32 page_offset;
+#else
+	__u16 page_offset;
+#endif
+	__u16 pagecnt_bias;
 };
 
 struct igb_tx_queue_stats {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c8c458c..83fdef6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3962,7 +3962,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__free_page(buffer_info->page);
+		__page_frag_drain(buffer_info->page, 0,
+				  buffer_info->pagecnt_bias);
 
 		buffer_info->page = NULL;
 	}
@@ -6830,13 +6831,15 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 				  struct page *page,
 				  unsigned int truesize)
 {
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+
 	/* avoid re-using remote pages */
 	if (unlikely(igb_page_is_reserved(page)))
 		return false;
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_ref_count(page) != pagecnt_bias))
 		return false;
 
 	/* flip page offset to other buffer */
@@ -6849,10 +6852,14 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 		return false;
 #endif
 
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
+	/* If we have drained the page fragment pool we need to update
+	 * the pagecnt_bias and page count so that we fully restock the
+	 * number of references the driver holds.
 	 */
-	page_ref_inc(page);
+	if (unlikely(!rx_buffer->pagecnt_bias)) {
+		page_ref_add(page, USHRT_MAX);
+		rx_buffer->pagecnt_bias = USHRT_MAX;
+	}
 
 	return true;
 }
@@ -6904,7 +6911,6 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 			return true;
 
 		/* this page cannot be reused so discard it */
-		__free_page(page);
 		return false;
 	}
 
@@ -6975,10 +6981,13 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		/* hand second half of page back to the ring */
 		igb_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
-		/* we are not reusing the buffer so unmap it */
+		/* We are not reusing the buffer so unmap it and free
+		 * any references we are holding to it
+		 */
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     PAGE_SIZE, DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
+		__page_frag_drain(page, 0, rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of rx_buffer */
@@ -7252,6 +7261,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+	bi->pagecnt_bias = 1;
 
 	return true;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
