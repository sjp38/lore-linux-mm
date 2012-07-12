Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4A6766B0078
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:51 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/16] netvm: Propagate page->pfmemalloc from skb_alloc_page to skb
Date: Thu, 12 Jul 2012 07:40:27 +0100
Message-Id: <1342075232-29267-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

The skb->pfmemalloc flag gets set to true iff during the slab
allocation of data in __alloc_skb that the the PFMEMALLOC reserves
were used. If page splitting is used, it is possible that pages will
be allocated from the PFMEMALLOC reserve without propagating this
information to the skb. This patch propagates page->pfmemalloc from
pages allocated for fragments to the skb.

It works by reintroducing and expanding the skb_alloc_page() API
to take an skb. If the page was allocated from pfmemalloc reserves,
it is automatically copied. If the driver allocates the page before
the skb, it should call skb_propagate_pfmemalloc() after the skb is
allocated to ensure the flag is copied properly.

Failure to do so is not critical. The resulting driver may perform
slower if it is used for swap-over-NBD or swap-over-NFS but it should
not result in failure.

[davem@davemloft.net: API rename and consistency]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 +-
 drivers/net/usb/cdc-phonet.c                      |    2 +-
 drivers/usb/gadget/f_phonet.c                     |    2 +-
 include/linux/skbuff.h                            |   55 +++++++++++++++++++++
 8 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 8596aca..d49933e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -528,7 +528,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 #endif
 
 	while (n--) {
-		pg = alloc_page(gfp);
+		pg = __skb_alloc_page(gfp, NULL);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index f2d1ecd..8877fbf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -653,7 +653,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 
 alloc_small_pages:
 	while (n--) {
-		page = alloc_page(gfp | __GFP_NOWARN | __GFP_COLD);
+		page = __skb_alloc_page(gfp | __GFP_NOWARN, NULL);
 		if (unlikely(!page)) {
 			fl->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 01ced68..16e0892 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6233,7 +6233,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	if (!page) {
-		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		page = __skb_alloc_page(GFP_ATOMIC, bi->skb);
 		bi->page = page;
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_failed++;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 694508b..6f0e7cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1146,8 +1146,8 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	/* alloc new page for storage */
 	if (likely(!page)) {
-		page = alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
-				   ixgbe_rx_pg_order(rx_ring));
+		page = __skb_alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
+				 	 bi->skb, ixgbe_rx_pg_order(rx_ring));
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_rx_page_failed++;
 			return false;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f69ec42..0e2d91d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -369,7 +369,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 		if (!bi->page_dma &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+				bi->page = __skb_alloc_page(GFP_ATOMIC, NULL);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -403,6 +403,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 			 */
 			skb_reserve(skb, NET_IP_ALIGN);
 
+			skb_propagate_pfmemalloc(bi->page, skb);
 			bi->skb = skb;
 		}
 		if (!bi->dma) {
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 187c144..6461004 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -130,7 +130,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = alloc_page(gfp_flags);
+	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
 	if (!page)
 		return -ENOMEM;
 
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index 965a629..8ee9268 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -301,7 +301,7 @@ pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = alloc_page(gfp_flags);
+	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
 	if (!page)
 		return -ENOMEM;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b814bb8..7632c87 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1774,6 +1774,61 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
 }
 
+/*
+ *	__skb_alloc_page - allocate pages for ps-rx on a skb and preserve pfmemalloc data
+ *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
+ *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
+ *	@order: size of the allocation
+ *
+ * 	Allocate a new page.
+ *
+ * 	%NULL is returned if there is no free memory.
+*/
+static inline struct page *__skb_alloc_pages(gfp_t gfp_mask,
+					      struct sk_buff *skb,
+					      unsigned int order)
+{
+	struct page *page;
+
+	gfp_mask |= __GFP_COLD;
+
+	if (!(gfp_mask & __GFP_NOMEMALLOC))
+		gfp_mask |= __GFP_MEMALLOC;
+
+	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
+	if (skb && page && page->pfmemalloc)
+		skb->pfmemalloc = true;
+
+	return page;
+}
+
+/**
+ *	__skb_alloc_page - allocate a page for ps-rx for a given skb and preserve pfmemalloc data
+ *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
+ *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
+ *
+ * 	Allocate a new page.
+ *
+ * 	%NULL is returned if there is no free memory.
+ */
+static inline struct page *__skb_alloc_page(gfp_t gfp_mask,
+					     struct sk_buff *skb)
+{
+	return __skb_alloc_pages(gfp_mask, skb, 0);
+}
+
+/**
+ *	skb_propagate_pfmemalloc - Propagate pfmemalloc if skb is allocated after RX page
+ *	@page: The page that was allocated from skb_alloc_page
+ *	@skb: The skb that may need pfmemalloc set
+ */
+static inline void skb_propagate_pfmemalloc(struct page *page,
+					     struct sk_buff *skb)
+{
+	if (page && page->pfmemalloc)
+		skb->pfmemalloc = true;
+}
+
 /**
  * skb_frag_page - retrieve the page refered to by a paged fragment
  * @frag: the paged fragment
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
