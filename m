Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4AEE6B0276
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:43 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id n9so8022956ybm.13
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h14si1410112ywa.484.2017.12.15.14.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 75/78] usb: Convert xhci-mem to XArray
Date: Fri, 15 Dec 2017 14:04:47 -0800
Message-Id: <20171215220450.7899-76-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The XArray API is a slightly better fit for xhci_insert_segment_mapping()
than the radix tree API was.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/usb/host/xhci-mem.c | 68 +++++++++++++++++++--------------------------
 drivers/usb/host/xhci.h     |  6 ++--
 2 files changed, 32 insertions(+), 42 deletions(-)

diff --git a/drivers/usb/host/xhci-mem.c b/drivers/usb/host/xhci-mem.c
index 15f7d422885f..9a2a02d244b0 100644
--- a/drivers/usb/host/xhci-mem.c
+++ b/drivers/usb/host/xhci-mem.c
@@ -149,70 +149,60 @@ static void xhci_link_rings(struct xhci_hcd *xhci, struct xhci_ring *ring,
 }
 
 /*
- * We need a radix tree for mapping physical addresses of TRBs to which stream
- * ID they belong to.  We need to do this because the host controller won't tell
+ * We need to map physical addresses of TRBs to the stream ID they belong to.
+ * We need to do this because the host controller won't tell
  * us which stream ring the TRB came from.  We could store the stream ID in an
  * event data TRB, but that doesn't help us for the cancellation case, since the
  * endpoint may stop before it reaches that event data TRB.
  *
- * The radix tree maps the upper portion of the TRB DMA address to a ring
+ * The xarray maps the upper portion of the TRB DMA address to a ring
  * segment that has the same upper portion of DMA addresses.  For example, say I
  * have segments of size 1KB, that are always 1KB aligned.  A segment may
  * start at 0x10c91000 and end at 0x10c913f0.  If I use the upper 10 bits, the
- * key to the stream ID is 0x43244.  I can use the DMA address of the TRB to
- * pass the radix tree a key to get the right stream ID:
+ * index of the stream ID is 0x43244.  I can use the DMA address of the TRB as
+ * the xarray index to get the right stream ID:
  *
  *	0x10c90fff >> 10 = 0x43243
  *	0x10c912c0 >> 10 = 0x43244
  *	0x10c91400 >> 10 = 0x43245
  *
  * Obviously, only those TRBs with DMA addresses that are within the segment
- * will make the radix tree return the stream ID for that ring.
+ * will make the xarray return the stream ID for that ring.
  *
- * Caveats for the radix tree:
+ * Caveats for the xarray:
  *
- * The radix tree uses an unsigned long as a key pair.  On 32-bit systems, an
+ * The xarray uses an unsigned long for the index.  On 32-bit systems, an
  * unsigned long will be 32-bits; on a 64-bit system an unsigned long will be
  * 64-bits.  Since we only request 32-bit DMA addresses, we can use that as the
- * key on 32-bit or 64-bit systems (it would also be fine if we asked for 64-bit
- * PCI DMA addresses on a 64-bit system).  There might be a problem on 32-bit
- * extended systems (where the DMA address can be bigger than 32-bits),
+ * index on 32-bit or 64-bit systems (it would also be fine if we asked for
+ * 64-bit PCI DMA addresses on a 64-bit system).  There might be a problem on
+ * 32-bit extended systems (where the DMA address can be bigger than 32-bits),
  * if we allow the PCI dma mask to be bigger than 32-bits.  So don't do that.
  */
-static int xhci_insert_segment_mapping(struct radix_tree_root *trb_address_map,
+
+static unsigned long trb_index(dma_addr_t dma)
+{
+	return (unsigned long)(dma >> TRB_SEGMENT_SHIFT);
+}
+
+static int xhci_insert_segment_mapping(struct xarray *trb_address_map,
 		struct xhci_ring *ring,
 		struct xhci_segment *seg,
-		gfp_t mem_flags)
+		gfp_t gfp)
 {
-	unsigned long key;
-	int ret;
-
-	key = (unsigned long)(seg->dma >> TRB_SEGMENT_SHIFT);
 	/* Skip any segments that were already added. */
-	if (radix_tree_lookup(trb_address_map, key))
-		return 0;
-
-	ret = radix_tree_maybe_preload(mem_flags);
-	if (ret)
-		return ret;
-	ret = radix_tree_insert(trb_address_map,
-			key, ring);
-	radix_tree_preload_end();
-	return ret;
+	return xa_err(xa_cmpxchg(trb_address_map, trb_index(seg->dma), NULL,
+								ring, gfp));
 }
 
-static void xhci_remove_segment_mapping(struct radix_tree_root *trb_address_map,
+static void xhci_remove_segment_mapping(struct xarray *trb_address_map,
 		struct xhci_segment *seg)
 {
-	unsigned long key;
-
-	key = (unsigned long)(seg->dma >> TRB_SEGMENT_SHIFT);
-	if (radix_tree_lookup(trb_address_map, key))
-		radix_tree_delete(trb_address_map, key);
+	xa_erase(trb_address_map, trb_index(seg->dma));
 }
 
 static int xhci_update_stream_segment_mapping(
-		struct radix_tree_root *trb_address_map,
+		struct xarray *trb_address_map,
 		struct xhci_ring *ring,
 		struct xhci_segment *first_seg,
 		struct xhci_segment *last_seg,
@@ -574,8 +564,8 @@ struct xhci_ring *xhci_dma_to_transfer_ring(
 		u64 address)
 {
 	if (ep->ep_state & EP_HAS_STREAMS)
-		return radix_tree_lookup(&ep->stream_info->trb_address_map,
-				address >> TRB_SEGMENT_SHIFT);
+		return xa_load(&ep->stream_info->trb_address_map,
+				trb_index(address));
 	return ep->ring;
 }
 
@@ -654,10 +644,10 @@ struct xhci_stream_info *xhci_alloc_stream_info(struct xhci_hcd *xhci,
 	if (!stream_info->free_streams_command)
 		goto cleanup_ctx;
 
-	INIT_RADIX_TREE(&stream_info->trb_address_map, GFP_ATOMIC);
+	xa_init(&stream_info->trb_address_map);
 
 	/* Allocate rings for all the streams that the driver will use,
-	 * and add their segment DMA addresses to the radix tree.
+	 * and add their segment DMA addresses to the map.
 	 * Stream 0 is reserved.
 	 */
 
@@ -2369,7 +2359,7 @@ int xhci_mem_init(struct xhci_hcd *xhci, gfp_t flags)
 	 * Initialize the ring segment pool.  The ring must be a contiguous
 	 * structure comprised of TRBs.  The TRBs must be 16 byte aligned,
 	 * however, the command ring segment needs 64-byte aligned segments
-	 * and our use of dma addresses in the trb_address_map radix tree needs
+	 * and our use of dma addresses in the trb_address_map xarray needs
 	 * TRB_SEGMENT_SIZE alignment, so we pick the greater alignment need.
 	 */
 	xhci->segment_pool = dma_pool_create("xHCI ring segments", dev,
diff --git a/drivers/usb/host/xhci.h b/drivers/usb/host/xhci.h
index 054ce74524af..e8208a3eee3c 100644
--- a/drivers/usb/host/xhci.h
+++ b/drivers/usb/host/xhci.h
@@ -15,7 +15,7 @@
 #include <linux/usb.h>
 #include <linux/timer.h>
 #include <linux/kernel.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/usb/hcd.h>
 #include <linux/io-64-nonatomic-lo-hi.h>
 
@@ -837,7 +837,7 @@ struct xhci_stream_info {
 	unsigned int			num_stream_ctxs;
 	dma_addr_t			ctx_array_dma;
 	/* For mapping physical TRB addresses to segments in stream rings */
-	struct radix_tree_root		trb_address_map;
+	struct xarray			trb_address_map;
 	struct xhci_command		*free_streams_command;
 };
 
@@ -1584,7 +1584,7 @@ struct xhci_ring {
 	unsigned int		bounce_buf_len;
 	enum xhci_ring_type	type;
 	bool			last_td_was_short;
-	struct radix_tree_root	*trb_address_map;
+	struct xarray		*trb_address_map;
 };
 
 struct xhci_erst_entry {
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
