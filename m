Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B0EF26B0257
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 13:01:23 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so29528281pac.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 10:01:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ml3si5210970pab.134.2015.09.04.10.01.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 10:01:23 -0700 (PDT)
Subject: [RFC PATCH 3/3] ixgbe: bulk free SKBs during TX completion cleanup
 cycle
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Sep 2015 19:01:21 +0200
Message-ID: <20150904170117.4312.97676.stgit@devil>
In-Reply-To: <20150904165944.4312.32435.stgit@devil>
References: <20150904165944.4312.32435.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

First user of the SKB bulk free API (namely kfree_skb_bulk() via
waitlist helper add-and-flush API).

There is an opportunity to bulk free SKBs during reclaiming of
resources after DMA transmit completes in ixgbe_clean_tx_irq.  Thus,
bulk freeing at this point does not introduce any added latency.
Choosing bulk size 32 even-though budget usually is 64, due (1) to
limit the stack usage and (2) as SLAB behind SKBs have 32 objects per
slab.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 463ff47200f1..d35d6b47bae2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1075,6 +1075,7 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
  * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
  **/
+#define BULK_FREE_SIZE 32
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *tx_ring)
 {
@@ -1084,6 +1085,11 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int budget = q_vector->tx.work_limit;
 	unsigned int i = tx_ring->next_to_clean;
+	struct sk_buff *skbs[BULK_FREE_SIZE];
+	struct dev_free_waitlist wl;
+
+	wl.skb_cnt = 0;
+	wl.skbs = skbs;
 
 	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return true;
@@ -1113,8 +1119,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_bytes += tx_buffer->bytecount;
 		total_packets += tx_buffer->gso_segs;
 
-		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		/* delay skb free and bulk free later */
+		dev_free_waitlist_add(&wl, tx_buffer->skb, BULK_FREE_SIZE);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -1164,6 +1170,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		budget--;
 	} while (likely(budget));
 
+	dev_free_waitlist_flush(&wl); /* free remaining SKBs on waitlist */
+
 	i += tx_ring->count;
 	tx_ring->next_to_clean = i;
 	u64_stats_update_begin(&tx_ring->syncp);
@@ -1224,6 +1232,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 
 	return !!budget;
 }
+#undef BULK_FREE_SIZE
 
 #ifdef CONFIG_IXGBE_DCA
 static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
