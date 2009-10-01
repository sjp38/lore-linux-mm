Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C169C600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:27:05 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 13/31] net: packet split receive api
Date: Thu,  1 Oct 2009 19:37:10 +0530
Message-Id: <1254406030-16120-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Jiri Bohac <jbohac@suse.cz>, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Add some packet-split receive hooks.

For one this allows to do NUMA node affine page allocs. Later on these hooks
will be extended to do emergency reserve allocations for fragments.

Thanks to Jiri Bohac for fixing a bug in bnx2.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 drivers/net/bnx2.c             |    9 +++------
 drivers/net/e1000e/netdev.c    |    7 ++-----
 drivers/net/igb/igb_main.c     |    9 ++-------
 drivers/net/ixgbe/ixgbe_main.c |   14 ++++++--------
 drivers/net/sky2.c             |   16 ++++++----------
 include/linux/skbuff.h         |    3 +++
 6 files changed, 22 insertions(+), 36 deletions(-)

Index: mmotm/drivers/net/bnx2.c
===================================================================
--- mmotm.orig/drivers/net/bnx2.c
+++ mmotm/drivers/net/bnx2.c
@@ -2648,7 +2648,7 @@ bnx2_alloc_rx_page(struct bnx2 *bp, stru
 	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct rx_bd *rxbd =
 		&rxr->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
-	struct page *page = alloc_page(GFP_ATOMIC);
+	struct page *page = netdev_alloc_page(bp->dev);
 
 	if (!page)
 		return -ENOMEM;
@@ -2678,7 +2678,7 @@ bnx2_free_rx_page(struct bnx2 *bp, struc
 	pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping), PAGE_SIZE,
 		       PCI_DMA_FROMDEVICE);
 
-	__free_page(page);
+	netdev_free_page(bp->dev, page);
 	rx_pg->page = NULL;
 }
 
@@ -3003,7 +3003,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2
 			if (i == pages - 1)
 				frag_len -= 4;
 
-			skb_fill_page_desc(skb, i, rx_pg->page, 0, frag_len);
+			skb_add_rx_frag(skb, i, rx_pg->page, 0, frag_len);
 			rx_pg->page = NULL;
 
 			err = bnx2_alloc_rx_page(bp, rxr,
@@ -3020,9 +3020,6 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2
 				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
 
 			frag_size -= frag_len;
-			skb->data_len += frag_len;
-			skb->truesize += frag_len;
-			skb->len += frag_len;
 
 			pg_prod = NEXT_RX_BD(pg_prod);
 			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
Index: mmotm/drivers/net/e1000e/netdev.c
===================================================================
--- mmotm.orig/drivers/net/e1000e/netdev.c
+++ mmotm/drivers/net/e1000e/netdev.c
@@ -259,7 +259,7 @@ static void e1000_alloc_rx_buffers_ps(st
 				continue;
 			}
 			if (!ps_page->page) {
-				ps_page->page = alloc_page(GFP_ATOMIC);
+				ps_page->page = netdev_alloc_page(netdev);
 				if (!ps_page->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
@@ -820,11 +820,8 @@ static bool e1000_clean_rx_irq_ps(struct
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
 			ps_page->dma = 0;
-			skb_fill_page_desc(skb, j, ps_page->page, 0, length);
+			skb_add_rx_frag(skb, j, ps_page->page, 0, length);
 			ps_page->page = NULL;
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
 		}
 
 		/* strip the ethernet crc, problem is we're using pages now so
Index: mmotm/drivers/net/igb/igb_main.c
===================================================================
--- mmotm.orig/drivers/net/igb/igb_main.c
+++ mmotm/drivers/net/igb/igb_main.c
@@ -4616,7 +4616,7 @@ static bool igb_clean_rx_irq_adv(struct
 				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags++,
 						buffer_info->page,
 						buffer_info->page_offset,
 						length);
@@ -4626,11 +4626,6 @@ static bool igb_clean_rx_irq_adv(struct
 				buffer_info->page = NULL;
 			else
 				get_page(buffer_info->page);
-
-			skb->len += length;
-			skb->data_len += length;
-
-			skb->truesize += length;
 		}
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
@@ -4755,7 +4750,7 @@ static void igb_alloc_rx_buffers_adv(str
 
 		if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
-				buffer_info->page = alloc_page(GFP_ATOMIC);
+				buffer_info->page = netdev_alloc_page(netdev);
 				if (!buffer_info->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
Index: mmotm/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- mmotm.orig/drivers/net/ixgbe/ixgbe_main.c
+++ mmotm/drivers/net/ixgbe/ixgbe_main.c
@@ -574,6 +574,7 @@ static void ixgbe_alloc_rx_buffers(struc
                                    int cleaned_count)
 {
 	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
@@ -587,7 +588,7 @@ static void ixgbe_alloc_rx_buffers(struc
 		if (!bi->page_dma &&
 		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
+				bi->page = netdev_alloc_page(netdev);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -756,10 +757,10 @@ static bool ixgbe_clean_rx_irq(struct ix
 			pci_unmap_page(pdev, rx_buffer_info->page_dma,
 			               PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			rx_buffer_info->page_dma = 0;
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-			                   rx_buffer_info->page,
-			                   rx_buffer_info->page_offset,
-			                   upper_len);
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+					rx_buffer_info->page,
+					rx_buffer_info->page_offset,
+					upper_len);
 
 			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
 			    (page_count(rx_buffer_info->page) != 1))
@@ -767,9 +768,6 @@ static bool ixgbe_clean_rx_irq(struct ix
 			else
 				get_page(rx_buffer_info->page);
 
-			skb->len += upper_len;
-			skb->data_len += upper_len;
-			skb->truesize += upper_len;
 		}
 
 		i++;
Index: mmotm/drivers/net/sky2.c
===================================================================
--- mmotm.orig/drivers/net/sky2.c
+++ mmotm/drivers/net/sky2.c
@@ -1282,7 +1282,7 @@ static struct sk_buff *sky2_rx_alloc(str
 		skb_reserve(skb, NET_IP_ALIGN);
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = netdev_alloc_page(sky2->netdev);
 
 		if (!page)
 			goto free_partial;
@@ -2218,8 +2218,8 @@ static struct sk_buff *receive_copy(stru
 }
 
 /* Adjust length of skb with fragments to match received data */
-static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
-			  unsigned int length)
+static void skb_put_frags(struct sky2_port *sky2, struct sk_buff *skb,
+			  unsigned int hdr_space, unsigned int length)
 {
 	int i, num_frags;
 	unsigned int size;
@@ -2236,15 +2236,11 @@ static void skb_put_frags(struct sk_buff
 
 		if (length == 0) {
 			/* don't need this page */
-			__free_page(frag->page);
+			netdev_free_page(sky2->netdev, frag->page);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
-
-			frag->size = size;
-			skb->data_len += size;
-			skb->truesize += size;
-			skb->len += size;
+			skb_add_rx_frag(skb, i, frag->page, 0, size);
 			length -= size;
 		}
 	}
@@ -2275,7 +2271,7 @@ static struct sk_buff *receive_new(struc
 	}
 
 	if (skb_shinfo(skb)->nr_frags)
-		skb_put_frags(skb, hdr_space, length);
+		skb_put_frags(sky2, skb, hdr_space, length);
 	else
 		skb_put(skb, length);
 	return skb;
Index: mmotm/include/linux/skbuff.h
===================================================================
--- mmotm.orig/include/linux/skbuff.h
+++ mmotm/include/linux/skbuff.h
@@ -1079,6 +1079,9 @@ static inline void skb_fill_page_desc(st
 extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
 			    int off, int size);
 
+extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
+			    int off, int size);
+
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frags(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
