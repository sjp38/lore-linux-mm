Message-Id: <20081002131608.749239880@chello.nl>
References: <20081002130504.927878499@chello.nl>
Date: Thu, 02 Oct 2008 15:05:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 17/32] net: packet split receive api
Content-Disposition: inline; filename=net-ps_rx.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Add some packet-split receive hooks.

For one this allows to do NUMA node affine page allocs. Later on these hooks
will be extended to do emergency reserve allocations for fragments.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/net/bnx2.c             |    8 +++-----
 drivers/net/e1000/e1000_main.c |    8 ++------
 drivers/net/e1000e/netdev.c    |    7 ++-----
 drivers/net/igb/igb_main.c     |    9 ++-------
 drivers/net/ixgbe/ixgbe_main.c |   10 +++-------
 drivers/net/sky2.c             |   16 ++++++----------
 include/linux/skbuff.h         |   23 +++++++++++++++++++++++
 net/core/skbuff.c              |   20 ++++++++++++++++++++
 8 files changed, 61 insertions(+), 40 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -4347,12 +4347,8 @@ static bool e1000_clean_rx_irq_ps(struct
 			pci_unmap_page(pdev, ps_page_dma->ps_page_dma[j],
 					PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			ps_page_dma->ps_page_dma[j] = 0;
-			skb_fill_page_desc(skb, j, ps_page->ps_page[j], 0,
-			                   length);
+			skb_add_rx_frag(skb, j, ps_page->ps_page[j], 0, length);
 			ps_page->ps_page[j] = NULL;
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
 		}
 
 		/* strip the ethernet crc, problem is we're using pages now so
@@ -4551,7 +4547,7 @@ static void e1000_alloc_rx_buffers_ps(st
 			if (j < adapter->rx_ps_pages) {
 				if (likely(!ps_page->ps_page[j])) {
 					ps_page->ps_page[j] =
-						alloc_page(GFP_ATOMIC);
+						netdev_alloc_page(netdev);
 					if (unlikely(!ps_page->ps_page[j])) {
 						adapter->alloc_rx_buff_failed++;
 						goto no_buffers;
Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h
+++ linux-2.6/include/linux/skbuff.h
@@ -829,6 +829,9 @@ static inline void skb_fill_page_desc(st
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
+extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
+			    int off, int size);
+
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
@@ -1243,6 +1246,26 @@ static inline struct sk_buff *netdev_all
 	return __netdev_alloc_skb(dev, length, GFP_ATOMIC);
 }
 
+extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+
+/**
+ *	netdev_alloc_page - allocate a page for ps-rx on a specific device
+ *	@dev: network device to receive on
+ *
+ * 	Allocate a new page node local to the specified device.
+ *
+ * 	%NULL is returned if there is no free memory.
+ */
+static inline struct page *netdev_alloc_page(struct net_device *dev)
+{
+	return __netdev_alloc_page(dev, GFP_ATOMIC);
+}
+
+static inline void netdev_free_page(struct net_device *dev, struct page *page)
+{
+	__free_page(page);
+}
+
 /**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c
+++ linux-2.6/net/core/skbuff.c
@@ -263,6 +263,26 @@ struct sk_buff *__netdev_alloc_skb(struc
 	return skb;
 }
 
+struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
+{
+	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
+	struct page *page;
+
+	page = alloc_pages_node(node, gfp_mask, 0);
+	return page;
+}
+EXPORT_SYMBOL(__netdev_alloc_page);
+
+void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
+		int size)
+{
+	skb_fill_page_desc(skb, i, page, off, size);
+	skb->len += size;
+	skb->data_len += size;
+	skb->truesize += size;
+}
+EXPORT_SYMBOL(skb_add_rx_frag);
+
 /**
  *	dev_alloc_skb - allocate an skbuff for receiving
  *	@length: length to allocate
Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -1272,7 +1272,7 @@ static struct sk_buff *sky2_rx_alloc(str
 	}
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = netdev_alloc_page(sky2->netdev);
 
 		if (!page)
 			goto free_partial;
@@ -2141,8 +2141,8 @@ static struct sk_buff *receive_copy(stru
 }
 
 /* Adjust length of skb with fragments to match received data */
-static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
-			  unsigned int length)
+static void skb_put_frags(struct sky2_port *sky2, struct sk_buff *skb,
+			  unsigned int hdr_space, unsigned int length)
 {
 	int i, num_frags;
 	unsigned int size;
@@ -2159,15 +2159,11 @@ static void skb_put_frags(struct sk_buff
 
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
@@ -2194,7 +2190,7 @@ static struct sk_buff *receive_new(struc
 	sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space);
 
 	if (skb_shinfo(skb)->nr_frags)
-		skb_put_frags(skb, hdr_space, length);
+		skb_put_frags(sky2, skb, hdr_space, length);
 	else
 		skb_put(skb, length);
 	return skb;
Index: linux-2.6/drivers/net/bnx2.c
===================================================================
--- linux-2.6.orig/drivers/net/bnx2.c
+++ linux-2.6/drivers/net/bnx2.c
@@ -2472,7 +2472,7 @@ bnx2_alloc_rx_page(struct bnx2 *bp, stru
 	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct rx_bd *rxbd =
 		&rxr->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
-	struct page *page = alloc_page(GFP_ATOMIC);
+	struct page *page = netdev_alloc_page(bp->dev);
 
 	if (!page)
 		return -ENOMEM;
@@ -2497,7 +2497,7 @@ bnx2_free_rx_page(struct bnx2 *bp, struc
 	pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping), PAGE_SIZE,
 		       PCI_DMA_FROMDEVICE);
 
-	__free_page(page);
+	netdev_free_page(bp->dev, page);
 	rx_pg->page = NULL;
 }
 
@@ -2828,9 +2828,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2
 			}
 
 			frag_size -= frag_len;
-			skb->data_len += frag_len;
-			skb->truesize += frag_len;
-			skb->len += frag_len;
+			skb_add_rx_frag(skb, i, rx_pg->page, 0, frag_len);
 
 			pg_prod = NEXT_RX_BD(pg_prod);
 			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -258,7 +258,7 @@ static void e1000_alloc_rx_buffers_ps(st
 				continue;
 			}
 			if (!ps_page->page) {
-				ps_page->page = alloc_page(GFP_ATOMIC);
+				ps_page->page = netdev_alloc_page(netdev);
 				if (!ps_page->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
@@ -818,11 +818,8 @@ static bool e1000_clean_rx_irq_ps(struct
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
 
 copydone:
Index: linux-2.6/drivers/net/igb/igb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/igb/igb_main.c
+++ linux-2.6/drivers/net/igb/igb_main.c
@@ -3874,7 +3874,7 @@ static bool igb_clean_rx_irq_adv(struct 
 				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags++,
 						buffer_info->page,
 						buffer_info->page_offset,
 						length);
@@ -3884,11 +3884,6 @@ static bool igb_clean_rx_irq_adv(struct 
 				buffer_info->page = NULL;
 			else
 				get_page(buffer_info->page);
-
-			skb->len += length;
-			skb->data_len += length;
-
-			skb->truesize += length;
 		}
 send_up:
 		i++;
@@ -3982,7 +3977,7 @@ static void igb_alloc_rx_buffers_adv(str
 
 		if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
-				buffer_info->page = alloc_page(GFP_ATOMIC);
+				buffer_info->page = netdev_alloc_page(netdev);
 				if (!buffer_info->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
Index: linux-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -495,7 +495,7 @@ static void ixgbe_alloc_rx_buffers(struc
 
 		if (!bi->page &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
-			bi->page = alloc_page(GFP_ATOMIC);
+			bi->page = netdev_alloc_page(netdev);
 			if (!bi->page) {
 				adapter->alloc_rx_page_failed++;
 				goto no_buffers;
@@ -622,13 +622,9 @@ static bool ixgbe_clean_rx_irq(struct ix
 			pci_unmap_page(pdev, rx_buffer_info->page_dma,
 				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			rx_buffer_info->page_dma = 0;
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-					   rx_buffer_info->page, 0, upper_len);
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+					rx_buffer_info->page, 0, upper_len);
 			rx_buffer_info->page = NULL;
-
-			skb->len += upper_len;
-			skb->data_len += upper_len;
-			skb->truesize += upper_len;
 		}
 
 		i++;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
