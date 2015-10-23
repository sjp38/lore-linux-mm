Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id A8DCB6B0253
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:46:19 -0400 (EDT)
Received: by iow1 with SMTP id 1so122637613iow.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:46:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g7si3114814igq.93.2015.10.23.05.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:46:19 -0700 (PDT)
Subject: [PATCH 3/4] ixgbe: bulk free SKBs during TX completion cleanup cycle
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 23 Oct 2015 14:46:16 +0200
Message-ID: <20151023124616.17364.61007.stgit@firesoul>
In-Reply-To: <20151023124451.17364.14594.stgit@firesoul>
References: <20151023124451.17364.14594.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

There is an opportunity to bulk free SKBs during reclaiming of
resources after DMA transmit completes in ixgbe_clean_tx_irq.  Thus,
bulk freeing at this point does not introduce any added latency.

Simply use napi_consume_skb() which were recently introduced.  The
napi_budget parameter is needed by napi_consume_skb() to detect if it
is called from netpoll.

Benchmarking IPv4-forwarding, on CPU i7-4790K @4.2GHz (no turbo boost)
 Single CPU/flow numbers: before: 1982144 pps ->  after : 2064446 pps
 Improvement: +82302 pps, -20 nanosec, +4.1%
 (SLUB and GCC version 5.1.1 20150618 (Red Hat 5.1.1-4))

Joint work with Alexander Duyck.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9f8a7fd7a195..4614dfb3febd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1090,7 +1090,7 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
  * @tx_ring: tx ring to clean
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
-			       struct ixgbe_ring *tx_ring)
+			       struct ixgbe_ring *tx_ring, int napi_budget)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_tx_buffer *tx_buffer;
@@ -1128,7 +1128,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -2784,7 +2784,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 #endif
 
 	ixgbe_for_each_ring(ring, q_vector->tx)
-		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
+		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring, budget);
 
 	if (!ixgbe_qv_lock_napi(q_vector))
 		return budget;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
