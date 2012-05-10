Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 2DF1B6B00F8
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:45:30 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/17] netvm: Propagate page->pfmemalloc from netdev_alloc_page to skb
Date: Thu, 10 May 2012 14:45:05 +0100
Message-Id: <1336657510-24378-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

The skb->pfmemalloc flag gets set to true iff during the slab
allocation of data in __alloc_skb that the the PFMEMALLOC reserves
were used. If page splitting is used, it is possible that pages will
be allocated from the PFMEMALLOC reserve without propagating this
information to the skb. This patch propagates page->pfmemalloc from
pages allocated for fragments to the skb.

It works by reintroducing and expanding the netdev_alloc_page() API
to take an skb. If the page was allocated from pfmemalloc reserves,
it is automatically copied. If the driver allocates the page before
the skb, it should call propagate_pfmemalloc_skb() after the skb is
allocated to ensure the flag is copied properly.

Failure to do so is not critical. The resulting driver may perform
slower if it is used for swap-over-NBD or swap-over-NFS but it should
not result in failure.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 +-
 drivers/net/usb/cdc-phonet.c                      |    2 +-
 drivers/usb/gadget/f_phonet.c                     |    2 +-
 include/linux/skbuff.h                            |   55 +++++++++++++++++++++
 8 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 2dae795..05f02b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -528,7 +528,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 #endif
 
 	while (n--) {
-		pg = alloc_page(gfp);
+		pg = __netdev_alloc_page(gfp, NULL);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 0bd585b..e8a372e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -653,7 +653,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 
 alloc_small_pages:
 	while (n--) {
-		page = alloc_page(gfp | __GFP_NOWARN | __GFP_COLD);
+		page = __netdev_alloc_page(gfp | __GFP_NOWARN, NULL);
 		if (unlikely(!page)) {
 			fl->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 5ec3159..9c2d7f6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6229,7 +6229,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	if (!page) {
-		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		page = __netdev_alloc_page(GFP_ATOMIC, bi->skb);
 		bi->page = page;
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_failed++;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7f3cd8..a092486 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1126,7 +1126,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	/* alloc new page for storage */
 	if (likely(!page)) {
-		page = alloc_pages(GFP_ATOMIC | __GFP_COLD,
+		page = __netdev_alloc_pages(GFP_ATOMIC, bi->skb,
 				   ixgbe_rx_pg_order(rx_ring));
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_rx_page_failed++;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 307611a..4f1c14f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -369,7 +369,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 		if (!bi->page_dma &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+				bi->page = __netdev_alloc_page(GFP_ATOMIC, NULL);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -403,6 +403,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 			 */
 			skb_reserve(skb, NET_IP_ALIGN);
 
+			propagate_pfmemalloc_skb(bi->page_dma, skb);
 			bi->skb = skb;
 		}
 		if (!bi->dma) {
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 3e41b00..5d46473 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -130,7 +130,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = alloc_page(gfp_flags);
+	page = __netdev_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
 	if (!page)
 		return -ENOMEM;
 
diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phonet.c
index 965a629..19adb15 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -301,7 +301,7 @@ pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = alloc_page(gfp_flags);
+	page = __netdev_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
 	if (!page)
 		return -ENOMEM;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ed7cc48..28c3de7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1747,6 +1747,61 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
 }
 
+/*
+ *	__netdev_alloc_page - allocate a page for ps-rx on a specific device
+ *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
+ *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
+ *	@order: size of the allocation
+ *
+ * 	Allocate a new page. dev currently unused.
+ *
+ * 	%NULL is returned if there is no free memory.
+*/
+static inline struct page *__netdev_alloc_pages(gfp_t gfp_mask,
+						struct sk_buff *skb,
+						unsigned int order)
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
+ *	__netdev_alloc_page - allocate a page for ps-rx on a specific device
+ *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
+ *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
+ *
+ * 	Allocate a new page. dev currently unused.
+ *
+ * 	%NULL is returned if there is no free memory.
+ */
+static inline struct page *__netdev_alloc_page(gfp_t gfp_mask,
+						struct sk_buff *skb)
+{
+	return __netdev_alloc_pages(gfp_mask, skb, 0);
+}
+
+/**
+ *	propagate_pfmemalloc_skb - Propagate pfmemalloc if skb is allocated after RX page
+ *	@page: The page that was allocated from netdev_alloc_page
+ *	@skb: The skb that may need pfmemalloc set
+ */
+static inline void propagate_pfmemalloc_skb(struct page *page,
+						struct sk_buff *skb)
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
