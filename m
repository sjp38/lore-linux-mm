Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F182F280254
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:07:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x70so83333279pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:07:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l78si16583888pfi.288.2016.10.24.11.07.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:07:10 -0700 (PDT)
Subject: [net-next PATCH RFC 24/26] igb: Update driver to make use of
 DMA_ATTR_SKIP_CPU_SYNC
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:33 -0400
Message-ID: <20161024120633.16276.54873.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

The ARM architecture provides a mechanism for deferring cache line
invalidation in the case of map/unmap.  This patch makes use of this
mechanism to avoid unnecessary synchronization.

A secondary effect of this change is that the portion of the page that has
been synchronized for use by the CPU should be writable and could be passed
up the stack (at least on ARM).

The last bit that occurred to me is that on architectures where the
sync_for_cpu call invalidates cache lines we were prefetching and then
invalidating the first 128 bytes of the packet.  To avoid that I have moved
the sync up to before we perform the prefetch and allocate the skbuff so
that we can actually make use of it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   53 ++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 4feca69..c8c458c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3947,10 +3947,21 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 		if (!buffer_info->page)
 			continue;
 
-		dma_unmap_page(rx_ring->dev,
-			       buffer_info->dma,
-			       PAGE_SIZE,
-			       DMA_FROM_DEVICE);
+		/* Invalidate cache lines that may have been written to by
+		 * device so that we avoid corrupting memory.
+		 */
+		dma_sync_single_range_for_cpu(rx_ring->dev,
+					      buffer_info->dma,
+					      buffer_info->page_offset,
+					      IGB_RX_BUFSZ,
+					      DMA_FROM_DEVICE);
+
+		/* free resources associated with mapping */
+		dma_unmap_page_attrs(rx_ring->dev,
+				     buffer_info->dma,
+				     PAGE_SIZE,
+				     DMA_FROM_DEVICE,
+				     DMA_ATTR_SKIP_CPU_SYNC);
 		__free_page(buffer_info->page);
 
 		buffer_info->page = NULL;
@@ -6808,12 +6819,6 @@ static void igb_reuse_rx_page(struct igb_ring *rx_ring,
 
 	/* transfer page from old buffer to new buffer */
 	*new_buff = *old_buff;
-
-	/* sync the buffer for use by the device */
-	dma_sync_single_range_for_device(rx_ring->dev, old_buff->dma,
-					 old_buff->page_offset,
-					 IGB_RX_BUFSZ,
-					 DMA_FROM_DEVICE);
 }
 
 static inline bool igb_page_is_reserved(struct page *page)
@@ -6934,6 +6939,13 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 	page = rx_buffer->page;
 	prefetchw(page);
 
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      size,
+				      DMA_FROM_DEVICE);
+
 	if (likely(!skb)) {
 		void *page_addr = page_address(page) +
 				  rx_buffer->page_offset;
@@ -6958,21 +6970,15 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		prefetchw(skb->data);
 	}
 
-	/* we are reusing so sync this buffer for CPU use */
-	dma_sync_single_range_for_cpu(rx_ring->dev,
-				      rx_buffer->dma,
-				      rx_buffer->page_offset,
-				      size,
-				      DMA_FROM_DEVICE);
-
 	/* pull page into skb */
 	if (igb_add_rx_frag(rx_ring, rx_buffer, size, rx_desc, skb)) {
 		/* hand second half of page back to the ring */
 		igb_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
 		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
-			       PAGE_SIZE, DMA_FROM_DEVICE);
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
+				     PAGE_SIZE, DMA_FROM_DEVICE,
+				     DMA_ATTR_SKIP_CPU_SYNC);
 	}
 
 	/* clear contents of rx_buffer */
@@ -7230,7 +7236,8 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 	}
 
 	/* map page for use */
-	dma = dma_map_page(rx_ring->dev, page, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+	dma = dma_map_page_attrs(rx_ring->dev, page, 0, PAGE_SIZE,
+				 DMA_FROM_DEVICE, DMA_ATTR_SKIP_CPU_SYNC);
 
 	/* if mapping failed free memory back to system since
 	 * there isn't much point in holding memory we can't use
@@ -7271,6 +7278,12 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 		if (!igb_alloc_mapped_page(rx_ring, bi))
 			break;
 
+		/* sync the buffer for use by the device */
+		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
+						 bi->page_offset,
+						 IGB_RX_BUFSZ,
+						 DMA_FROM_DEVICE);
+
 		/* Refresh the desc even if buffer_addrs didn't change
 		 * because each write-back erases this info.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
