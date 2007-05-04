Message-Id: <20070504103158.188458962@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:03 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/40] net: packet split receive api
Content-Disposition: inline; filename=net-ps_rx.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Add some packet-split receive hooks.

For one this allows to do NUMA node affine page allocs.  Later on these hooks
will be extended to do emergency reserve allocations for fragments.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/net/e1000/e1000_main.c |    8 ++------
 drivers/net/sky2.c             |   16 ++++++----------
 include/linux/skbuff.h         |   23 +++++++++++++++++++++++
 net/core/skbuff.c              |   20 ++++++++++++++++++++
 4 files changed, 51 insertions(+), 16 deletions(-)

Index: linux-2.6-git/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6-git.orig/drivers/net/e1000/e1000_main.c	2007-02-14 08:31:12.000000000 +0100
+++ linux-2.6-git/drivers/net/e1000/e1000_main.c	2007-02-14 11:42:07.000000000 +0100
@@ -4412,12 +4412,8 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
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
@@ -4623,7 +4619,7 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
 			if (j < adapter->rx_ps_pages) {
 				if (likely(!ps_page->ps_page[j])) {
 					ps_page->ps_page[j] =
-						alloc_page(GFP_ATOMIC);
+						netdev_alloc_page(netdev);
 					if (unlikely(!ps_page->ps_page[j])) {
 						adapter->alloc_rx_buff_failed++;
 						goto no_buffers;
Index: linux-2.6-git/include/linux/skbuff.h
===================================================================
--- linux-2.6-git.orig/include/linux/skbuff.h	2007-02-14 11:29:54.000000000 +0100
+++ linux-2.6-git/include/linux/skbuff.h	2007-02-14 11:59:04.000000000 +0100
@@ -813,6 +813,9 @@ static inline void skb_fill_page_desc(st
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
+extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
+			    int off, int size);
+
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->frag_list)
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
@@ -1148,6 +1151,26 @@ static inline struct sk_buff *netdev_all
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
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
Index: linux-2.6-git/net/core/skbuff.c
===================================================================
--- linux-2.6-git.orig/net/core/skbuff.c	2007-02-14 11:29:54.000000000 +0100
+++ linux-2.6-git/net/core/skbuff.c	2007-02-14 12:01:40.000000000 +0100
@@ -279,6 +279,24 @@ struct sk_buff *__netdev_alloc_skb(struc
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
+
+void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
+		int size)
+{
+	skb_fill_page_desc(skb, i, page, off, size);
+	skb->len += size;
+	skb->data_len += size;
+	skb->truesize += size;
+}
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list = *listp;
@@ -2066,6 +2084,8 @@ EXPORT_SYMBOL(kfree_skb);
 EXPORT_SYMBOL(__pskb_pull_tail);
 EXPORT_SYMBOL(__alloc_skb);
 EXPORT_SYMBOL(__netdev_alloc_skb);
+EXPORT_SYMBOL(__netdev_alloc_page);
+EXPORT_SYMBOL(skb_add_rx_frag);
 EXPORT_SYMBOL(pskb_copy);
 EXPORT_SYMBOL(pskb_expand_head);
 EXPORT_SYMBOL(skb_checksum);
Index: linux-2.6-git/drivers/net/sky2.c
===================================================================
--- linux-2.6-git.orig/drivers/net/sky2.c	2007-02-14 08:31:12.000000000 +0100
+++ linux-2.6-git/drivers/net/sky2.c	2007-02-14 12:00:22.000000000 +0100
@@ -1083,7 +1083,7 @@ static struct sk_buff *sky2_rx_alloc(str
 	skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = netdev_alloc_page(sky2->netdev);
 
 		if (!page)
 			goto free_partial;
@@ -1972,8 +1972,8 @@ static struct sk_buff *receive_copy(stru
 }
 
 /* Adjust length of skb with fragments to match received data */
-static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
-			  unsigned int length)
+static void skb_put_frags(struct sky2_port *sky2, struct sk_buff *skb,
+			  unsigned int hdr_space, unsigned int length)
 {
 	int i, num_frags;
 	unsigned int size;
@@ -1990,15 +1990,11 @@ static void skb_put_frags(struct sk_buff
 
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
@@ -2027,7 +2023,7 @@ static struct sk_buff *receive_new(struc
 	sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space);
 
 	if (skb_shinfo(skb)->nr_frags)
-		skb_put_frags(skb, hdr_space, length);
+		skb_put_frags(sky2, skb, hdr_space, length);
 	else
 		skb_put(skb, length);
 	return skb;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
