Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 60F3A6B0075
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:22 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so15374310qge.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j93si893867qkh.41.2015.05.06.21.12.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:12:21 -0700 (PDT)
Subject: [PATCH 08/10] e1000: Replace e1000_free_frag with skb_free_frag
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:12:20 -0700
Message-ID: <20150507041220.1873.80925.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 983eb4e6f7aa..74dc15055971 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2079,11 +2079,6 @@ static void *e1000_alloc_frag(const struct e1000_adapter *a)
 	return data;
 }
 
-static void e1000_free_frag(const void *data)
-{
-	put_page(virt_to_head_page(data));
-}
-
 /**
  * e1000_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
@@ -2107,7 +2102,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 						 adapter->rx_buffer_len,
 						 DMA_FROM_DEVICE);
 			if (buffer_info->rxbuf.data) {
-				e1000_free_frag(buffer_info->rxbuf.data);
+				skb_free_frag(buffer_info->rxbuf.data);
 				buffer_info->rxbuf.data = NULL;
 			}
 		} else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
@@ -4594,28 +4589,28 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			data = e1000_alloc_frag(adapter);
 			/* Failed allocation, critical failure */
 			if (!data) {
-				e1000_free_frag(olddata);
+				skb_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
 			if (!e1000_check_64k_bound(adapter, data, bufsz)) {
 				/* give up */
-				e1000_free_frag(data);
-				e1000_free_frag(olddata);
+				skb_free_frag(data);
+				skb_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
 			/* Use new allocation */
-			e1000_free_frag(olddata);
+			skb_free_frag(olddata);
 		}
 		buffer_info->dma = dma_map_single(&pdev->dev,
 						  data,
 						  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-			e1000_free_frag(data);
+			skb_free_frag(data);
 			buffer_info->dma = 0;
 			adapter->alloc_rx_buff_failed++;
 			break;
@@ -4637,7 +4632,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 					 adapter->rx_buffer_len,
 					 DMA_FROM_DEVICE);
 
-			e1000_free_frag(data);
+			skb_free_frag(data);
 			buffer_info->rxbuf.data = NULL;
 			buffer_info->dma = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
