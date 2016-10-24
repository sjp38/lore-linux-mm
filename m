Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7AF280254
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:07:28 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 206so29261398ybp.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:07:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f8si13894574pav.216.2016.10.24.11.07.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 11:07:20 -0700 (PDT)
Subject: [net-next PATCH RFC 26/26] igb: Revert "igb: Revert support for
 build_skb in igb"
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:06:44 -0400
Message-ID: <20161024120643.16276.3846.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: davem@davemloft.net, brouer@redhat.com

This reverts commit f9d40f6a9921 ("igb: Revert support for build_skb in
igb") and adds a few changes to update it to work with the latest version
of igb. We are now able to revert the removal of this due to the fact
that with the recent changes to the page count and the use of
DMA_ATTR_SKIP_CPU_SYNC we can make the pages writable so we should not be
invalidating the additional data added when we call build_skb.

The biggest risk with this change is that we are now not able to support
full jumbo frames when using build_skb.  Instead we can only support up to
2K minus the skb overhead and padding offset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |   29 ++++++
 drivers/net/ethernet/intel/igb/igb_main.c |  130 ++++++++++++++++++++++++++---
 2 files changed, 142 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index acbc3ab..c3420f3 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -145,6 +145,10 @@ struct vf_data_storage {
 #define IGB_RX_HDR_LEN		IGB_RXBUFFER_256
 #define IGB_RX_BUFSZ		IGB_RXBUFFER_2048
 
+#define IGB_SKB_PAD		(NET_SKB_PAD + NET_IP_ALIGN)
+#define IGB_MAX_BUILD_SKB_SIZE \
+	(SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) - (IGB_SKB_PAD + IGB_TS_HDR_LEN))
+
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IGB_RX_BUFFER_WRITE	16 /* Must be power of 2 */
 
@@ -301,12 +305,29 @@ struct igb_q_vector {
 };
 
 enum e1000_ring_flags_t {
-	IGB_RING_FLAG_RX_SCTP_CSUM,
-	IGB_RING_FLAG_RX_LB_VLAN_BSWAP,
-	IGB_RING_FLAG_TX_CTX_IDX,
-	IGB_RING_FLAG_TX_DETECT_HANG
+	IGB_RING_FLAG_RX_SCTP_CSUM = 0,
+#if (NET_IP_ALIGN != 0)
+	IGB_RING_FLAG_RX_BUILD_SKB_ENABLED = 1,
+#endif
+	IGB_RING_FLAG_RX_LB_VLAN_BSWAP = 2,
+	IGB_RING_FLAG_TX_CTX_IDX = 3,
+	IGB_RING_FLAG_TX_DETECT_HANG = 4,
+#if (NET_IP_ALIGN == 0)
+#if (L1_CACHE_SHIFT < 5)
+	IGB_RING_FLAG_RX_BUILD_SKB_ENABLED = 5,
+#else
+	IGB_RING_FLAG_RX_BUILD_SKB_ENABLED = L1_CACHE_SHIFT,
+#endif
+#endif
 };
 
+#define ring_uses_build_skb(ring) \
+	test_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+#define set_ring_build_skb_enabled(ring) \
+	set_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+#define clear_ring_build_skb_enabled(ring) \
+	clear_bit(IGB_RING_FLAG_RX_BUILD_SKB_ENABLED, &(ring)->flags)
+
 #define IGB_TXD_DCMD (E1000_ADVTXD_DCMD_EOP | E1000_ADVTXD_DCMD_RS)
 
 #define IGB_RX_DESC(R, i)	\
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 83fdef6..7674a50 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3761,6 +3761,16 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	wr32(E1000_RXDCTL(reg_idx), rxdctl);
 }
 
+static void igb_set_rx_buffer_len(struct igb_adapter *adapter,
+				  struct igb_ring *rx_ring)
+{
+	/* set build_skb flag */
+	if (adapter->max_frame_size <= IGB_MAX_BUILD_SKB_SIZE)
+		set_ring_build_skb_enabled(rx_ring);
+	else
+		clear_ring_build_skb_enabled(rx_ring);
+}
+
 /**
  *  igb_configure_rx - Configure receive Unit after Reset
  *  @adapter: board private structure
@@ -3778,8 +3788,12 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_configure_rx_ring(adapter, adapter->rx_ring[i]);
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct igb_ring *rx_ring = adapter->rx_ring[i];
+
+		igb_set_rx_buffer_len(adapter, rx_ring);
+		igb_configure_rx_ring(adapter, rx_ring);
+	}
 }
 
 /**
@@ -4238,7 +4252,7 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned int vfn = adapter->vfs_allocated_count;
-	u32 rctl = 0, vmolr = 0;
+	u32 rctl = 0, vmolr = 0, rlpml = MAX_JUMBO_FRAME_SIZE;
 	int count;
 
 	/* Check for Promiscuous and All Multicast modes */
@@ -4310,12 +4324,18 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	vmolr |= rd32(E1000_VMOLR(vfn)) &
 		 ~(E1000_VMOLR_ROPE | E1000_VMOLR_MPME | E1000_VMOLR_ROMPE);
 
-	/* enable Rx jumbo frames, no need for restriction */
+	/* enable Rx jumbo frames, restrict as needed to support build_skb */
 	vmolr &= ~E1000_VMOLR_RLPML_MASK;
-	vmolr |= MAX_JUMBO_FRAME_SIZE | E1000_VMOLR_LPE;
+	vmolr |= E1000_VMOLR_LPE;
+	vmolr |= (adapter->max_frame_size <= IGB_MAX_BUILD_SKB_SIZE) ?
+		 IGB_MAX_BUILD_SKB_SIZE : MAX_JUMBO_FRAME_SIZE;
+
+	if (!adapter->vfs_allocated_count &&
+	    (adapter->max_frame_size <= IGB_MAX_BUILD_SKB_SIZE))
+		rlpml = IGB_MAX_BUILD_SKB_SIZE;
 
 	wr32(E1000_VMOLR(vfn), vmolr);
-	wr32(E1000_RLPML, MAX_JUMBO_FRAME_SIZE);
+	wr32(E1000_RLPML, rlpml);
 
 	igb_restore_vf_multicasts(adapter);
 }
@@ -5046,9 +5066,9 @@ static void igb_tx_csum(struct igb_ring *tx_ring, struct igb_tx_buffer *first)
 }
 
 #define IGB_SET_FLAG(_input, _flag, _result) \
-	((_flag <= _result) ? \
-	 ((u32)(_input & _flag) * (_result / _flag)) : \
-	 ((u32)(_input & _flag) / (_flag / _result)))
+	(((_flag) <= (_result)) ? \
+	 ((u32)(_input & (_flag)) * ((_result) / (_flag))) : \
+	 ((u32)(_input & (_flag)) / ((_flag) / (_result))))
 
 static u32 igb_tx_cmd_type(struct sk_buff *skb, u32 tx_flags)
 {
@@ -6829,7 +6849,7 @@ static inline bool igb_page_is_reserved(struct page *page)
 
 static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 				  struct page *page,
-				  unsigned int truesize)
+				  const unsigned int truesize)
 {
 	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
 
@@ -6888,7 +6908,7 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = IGB_RX_BUFSZ;
+	const unsigned int truesize = IGB_RX_BUFSZ;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
@@ -6933,6 +6953,78 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 	return igb_can_reuse_rx_page(rx_buffer, page, truesize);
 }
 
+static struct sk_buff *igb_build_rx_buffer(struct igb_ring *rx_ring,
+					   union e1000_adv_rx_desc *rx_desc)
+{
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
+	struct igb_rx_buffer *rx_buffer;
+	struct sk_buff *skb;
+	struct page *page;
+	void *va;
+#if (PAGE_SIZE < 8192)
+	const unsigned int truesize = IGB_RX_BUFSZ;
+#else
+	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
+				SKB_DATA_ALIGN(NET_SKB_PAD +
+					       NET_IP_ALIGN +
+					       size);
+#endif
+
+	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
+	page = rx_buffer->page;
+	prefetchw(page);
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset + IGB_SKB_PAD,
+				      size,
+				      DMA_FROM_DEVICE);
+
+	va = page_address(page) + rx_buffer->page_offset;
+
+	/* prefetch first cache line of first page */
+	prefetch(va + IGB_SKB_PAD);
+#if L1_CACHE_BYTES < 128
+	prefetch(va + L1_CACHE_BYTES + IGB_SKB_PAD);
+#endif
+
+	/* build an skb to around the page buffer */
+	skb = build_skb(va, truesize);
+	if (unlikely(!skb)) {
+		rx_ring->rx_stats.alloc_failed++;
+		return NULL;
+	}
+
+	/* update pointers within the skb to store the data */
+	skb_reserve(skb, IGB_SKB_PAD);
+	__skb_put(skb, size);
+
+	/* pull timestamp out of packet data */
+	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
+		igb_ptp_rx_pktstamp(rx_ring->q_vector, skb->data, skb);
+		__skb_pull(skb, IGB_TS_HDR_LEN);
+	}
+
+	if (igb_can_reuse_rx_page(rx_buffer, page, truesize)) {
+		/* hand second half of page back to the ring */
+		igb_reuse_rx_page(rx_ring, rx_buffer);
+	} else {
+		/* We are not reusing the buffer so unmap it and free
+		 * any references we are holding to it
+		 */
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
+				     PAGE_SIZE, DMA_FROM_DEVICE,
+				     DMA_ATTR_SKIP_CPU_SYNC);
+		__page_frag_drain(page, 0, rx_buffer->pagecnt_bias);
+	}
+
+	/* clear contents of rx_buffer */
+	rx_buffer->page = NULL;
+
+	return skb;
+}
+
 static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 					   union e1000_adv_rx_desc *rx_desc,
 					   struct sk_buff *skb)
@@ -7178,7 +7270,10 @@ static int igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 		dma_rmb();
 
 		/* retrieve a buffer from the ring */
-		skb = igb_fetch_rx_buffer(rx_ring, rx_desc, skb);
+		if (ring_uses_build_skb(rx_ring))
+			skb = igb_build_rx_buffer(rx_ring, rx_desc);
+		else
+			skb = igb_fetch_rx_buffer(rx_ring, rx_desc, skb);
 
 		/* exit if we failed to retrieve a buffer */
 		if (!skb)
@@ -7266,6 +7361,13 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 	return true;
 }
 
+static inline unsigned int igb_rx_offset(struct igb_ring *rx_ring)
+{
+	return IGB_SET_FLAG(rx_ring->flags,
+			    1 << IGB_RING_FLAG_RX_BUILD_SKB_ENABLED,
+			    IGB_SKB_PAD);
+}
+
 /**
  *  igb_alloc_rx_buffers - Replace used receive buffers; packet split
  *  @adapter: address of board private structure
@@ -7297,7 +7399,9 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 		/* Refresh the desc even if buffer_addrs didn't change
 		 * because each write-back erases this info.
 		 */
-		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma +
+						     bi->page_offset +
+						     igb_rx_offset(rx_ring));
 
 		rx_desc++;
 		bi++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
