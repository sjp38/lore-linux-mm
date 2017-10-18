Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6403C6B026B
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:00:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y10so1797108wmd.4
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:00:18 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id m34si1066956ede.357.2017.10.18.01.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 01:00:16 -0700 (PDT)
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com [46.22.139.231])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id E43271C2F85
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:00:15 +0100 (IST)
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id D06771C2F79
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:00:15 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 8/8] mm: Remove __GFP_COLD
Date: Wed, 18 Oct 2017 08:59:52 +0100
Message-Id: <20171018075952.10627-9-mgorman@techsingularity.net>
In-Reply-To: <20171018075952.10627-1-mgorman@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

As the page free path makes no distinction between cache hot and cold
pages, there is no real useful ordering of pages in the free list that
allocation requests can take advantage of. Juding from the users of
__GFP_COLD, it is likely that a number of them are the result of copying
other sites instead of actually measuring the impact. Remove the
__GFP_COLD parameter which simplifies a number of paths in the page
allocator.

This is potentially controversial but bear in mind that the size of the
per-cpu pagelists versus modern cache sizes means that the whole per-cpu
list can often fit in the L3 cache. Hence, there is only a potential benefit
for microbenchmarks that alloc/free pages in a tight loop. It's even worse
when THP is taken into account which has little or no chance of getting a
cache-hot page as the per-cpu list is bypassed and the zeroing of multiple
pages will thrash the cache anyway.

The truncate microbenchmarks are not shown as this patch affects the
allocation path and not the free path. A page fault microbenchmark was
tested but it showed no sigificant difference which is not surprising given
that the __GFP_COLD branches are a miniscule percentage of the fault path.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c         |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c            |  2 +-
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c     |  3 +--
 .../net/ethernet/cavium/liquidio/octeon_network.h    |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c           |  5 ++---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  |  4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |  3 +--
 drivers/net/ethernet/sfc/falcon/rx.c                 |  2 +-
 drivers/net/ethernet/sfc/rx.c                        |  2 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c      |  2 +-
 drivers/net/ethernet/ti/netcp_core.c                 |  2 +-
 drivers/net/virtio_net.c                             |  1 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c      |  2 +-
 fs/cachefiles/rdwr.c                                 |  6 ++----
 include/linux/gfp.h                                  |  5 -----
 include/linux/pagemap.h                              |  8 +-------
 include/linux/skbuff.h                               |  2 +-
 include/linux/slab.h                                 |  3 ---
 include/trace/events/mmflags.h                       |  1 -
 kernel/power/snapshot.c                              |  4 ++--
 mm/filemap.c                                         |  6 +++---
 mm/page_alloc.c                                      | 20 ++++++--------------
 mm/percpu-vm.c                                       |  2 +-
 net/core/skbuff.c                                    |  4 ++--
 tools/perf/builtin-kmem.c                            |  1 -
 25 files changed, 32 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index f7dc22f65d9f..51f2800ac053 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -517,7 +517,7 @@ static int ena_refill_rx_bufs(struct ena_ring *rx_ring, u32 num)
 
 
 		rc = ena_alloc_rx_page(rx_ring, rx_info,
-				       __GFP_COLD | GFP_ATOMIC | __GFP_COMP);
+				       GFP_ATOMIC | __GFP_COMP);
 		if (unlikely(rc < 0)) {
 			netif_warn(rx_ring->adapter, rx_err, rx_ring->netdev,
 				   "failed to alloc buffer for rx queue %d\n",
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 45d92304068e..cc1e4f820e64 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -295,7 +295,7 @@ static int xgbe_alloc_pages(struct xgbe_prv_data *pdata,
 	order = alloc_order;
 
 	/* Try to obtain pages, decreasing order if necessary */
-	gfp = GFP_ATOMIC | __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
+	gfp = GFP_ATOMIC | __GFP_COMP | __GFP_NOWARN;
 	while (order >= 0) {
 		pages = alloc_pages_node(node, gfp, order);
 		if (pages)
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 0654e0c76bc2..519ca6534b85 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -304,8 +304,7 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 		buff->flags = 0U;
 		buff->len = AQ_CFG_RX_FRAME_MAX;
 
-		buff->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
-					 __GFP_COMP, pages_order);
+		buff->page = alloc_pages(GFP_ATOMIC | __GFP_COMP, pages_order);
 		if (!buff->page) {
 			err = -ENOMEM;
 			goto err_exit;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 9e36319cead6..57853eead4b5 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -195,7 +195,7 @@ static inline void
 	struct sk_buff *skb;
 	struct octeon_skb_page_info *skb_pg_info;
 
-	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	page = alloc_page(GFP_ATOMIC);
 	if (unlikely(!page))
 		return NULL;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b97a55c827eb..ffead38cf5da 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -193,7 +193,7 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 
 			if (mlx4_en_prepare_rx_desc(priv, ring,
 						    ring->actual_size,
-						    GFP_KERNEL | __GFP_COLD)) {
+						    GFP_KERNEL)) {
 				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
 					en_err(priv, "Failed to allocate enough rx buffers\n");
 					return -ENOMEM;
@@ -552,8 +552,7 @@ static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 	do {
 		if (mlx4_en_prepare_rx_desc(priv, ring,
 					    ring->prod & ring->size_mask,
-					    GFP_ATOMIC | __GFP_COLD |
-					    __GFP_MEMALLOC))
+					    GFP_ATOMIC | __GFP_MEMALLOC))
 			break;
 		ring->prod++;
 	} while (likely(--missing));
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1c0187f0af51..6364c9a7a372 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1183,7 +1183,7 @@ static void *nfp_net_rx_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 	if (!dp->xdp_prog)
 		frag = netdev_alloc_frag(dp->fl_bufsz);
 	else
-		frag = page_address(alloc_page(GFP_KERNEL | __GFP_COLD));
+		frag = page_address(alloc_page(GFP_KERNEL));
 	if (!frag) {
 		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
@@ -1206,7 +1206,7 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 	if (!dp->xdp_prog)
 		frag = napi_alloc_frag(dp->fl_bufsz);
 	else
-		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
+		frag = page_address(alloc_page(GFP_ATOMIC));
 	if (!frag) {
 		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
 		return NULL;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 9feec7009443..abfe2a5b28d5 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1092,8 +1092,7 @@ static int ql_get_next_chunk(struct ql_adapter *qdev, struct rx_ring *rx_ring,
 {
 	if (!rx_ring->pg_chunk.page) {
 		u64 map;
-		rx_ring->pg_chunk.page = alloc_pages(__GFP_COLD | __GFP_COMP |
-						GFP_ATOMIC,
+		rx_ring->pg_chunk.page = alloc_pages(__GFP_COMP | GFP_ATOMIC,
 						qdev->lbq_buf_order);
 		if (unlikely(!rx_ring->pg_chunk.page)) {
 			netif_err(qdev, drv, qdev->ndev,
diff --git a/drivers/net/ethernet/sfc/falcon/rx.c b/drivers/net/ethernet/sfc/falcon/rx.c
index 6a8406dc0c2b..91097aea6c41 100644
--- a/drivers/net/ethernet/sfc/falcon/rx.c
+++ b/drivers/net/ethernet/sfc/falcon/rx.c
@@ -163,7 +163,7 @@ static int ef4_init_rx_buffers(struct ef4_rx_queue *rx_queue, bool atomic)
 	do {
 		page = ef4_reuse_page(rx_queue);
 		if (page == NULL) {
-			page = alloc_pages(__GFP_COLD | __GFP_COMP |
+			page = alloc_pages(__GFP_COMP |
 					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
 					   efx->rx_buffer_order);
 			if (unlikely(page == NULL))
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 42443f434569..0004c50d3c83 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -163,7 +163,7 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
 	do {
 		page = efx_reuse_page(rx_queue);
 		if (page == NULL) {
-			page = alloc_pages(__GFP_COLD | __GFP_COMP |
+			page = alloc_pages(__GFP_COMP |
 					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
 					   efx->rx_buffer_order);
 			if (unlikely(page == NULL))
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
index e9672b1f9968..031cf9c3435a 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
@@ -335,7 +335,7 @@ static int xlgmac_alloc_pages(struct xlgmac_pdata *pdata,
 	dma_addr_t pages_dma;
 
 	/* Try to obtain pages, decreasing order if necessary */
-	gfp |= __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
+	gfp |= __GFP_COMP | __GFP_NOWARN;
 	while (order >= 0) {
 		pages = alloc_pages(gfp, order);
 		if (pages)
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 437d36289786..50d2b76771b5 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -906,7 +906,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
 		sw_data[0] = (u32)bufptr;
 	} else {
 		/* Allocate a secondary receive queue entry */
-		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
+		page = alloc_page(GFP_ATOMIC | GFP_DMA);
 		if (unlikely(!page)) {
 			dev_warn_ratelimited(netcp->ndev_dev, "Secondary page alloc failed\n");
 			goto fail;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 511f8339fa96..5eec09d63fc0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -988,7 +988,6 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
 	int err;
 	bool oom;
 
-	gfp |= __GFP_COLD;
 	do {
 		if (vi->mergeable_rx_bufs)
 			err = add_recvbuf_mergeable(vi, rq, gfp);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 6ef8ddec4ab6..32716bc75d3b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1151,7 +1151,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 	}
 
 	for (npages = 1; npages < max_pages; npages++) {
-		page = page_cache_alloc_cold(inode->i_mapping);
+		page = page_cache_alloc(inode->i_mapping);
 		if (!page)
 			break;
 		page_pool[npages] = page;
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 23097cca2674..883bc7bb12c5 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -256,8 +256,7 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 			goto backing_page_already_present;
 
 		if (!newpage) {
-			newpage = __page_cache_alloc(cachefiles_gfp |
-						     __GFP_COLD);
+			newpage = __page_cache_alloc(cachefiles_gfp);
 			if (!newpage)
 				goto nomem_monitor;
 		}
@@ -493,8 +492,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 				goto backing_page_already_present;
 
 			if (!newpage) {
-				newpage = __page_cache_alloc(cachefiles_gfp |
-							     __GFP_COLD);
+				newpage = __page_cache_alloc(cachefiles_gfp);
 				if (!newpage)
 					goto nomem;
 			}
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index cc0cdbaa1b24..3047cdc796b2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -23,7 +23,6 @@ struct vm_area_struct;
 #define ___GFP_HIGH		0x20u
 #define ___GFP_IO		0x40u
 #define ___GFP_FS		0x80u
-#define ___GFP_COLD		0x100u
 #define ___GFP_NOWARN		0x200u
 #define ___GFP_RETRY_MAYFAIL	0x400u
 #define ___GFP_NOFAIL		0x800u
@@ -192,9 +191,6 @@ struct vm_area_struct;
 /*
  * Action modifiers
  *
- * __GFP_COLD indicates that the caller does not expect to be used in the near
- *   future. Where possible, a cache-cold page will be returned.
- *
  * __GFP_NOWARN suppresses allocation failure reports.
  *
  * __GFP_COMP address compound page metadata.
@@ -207,7 +203,6 @@ struct vm_area_struct;
  *   distinguishing in the source between false positives and allocations that
  *   cannot be supported (e.g. page tables).
  */
-#define __GFP_COLD	((__force gfp_t)___GFP_COLD)
 #define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 514f6d9d8083..0d78856d3135 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -231,15 +231,9 @@ static inline struct page *page_cache_alloc(struct address_space *x)
 	return __page_cache_alloc(mapping_gfp_mask(x));
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
-{
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
-}
-
 static inline gfp_t readahead_gfp_mask(struct address_space *x)
 {
-	return mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN;
+	return mapping_gfp_mask(x) | __GFP_NORETRY | __GFP_NOWARN;
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061..5fedbb398b10 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2675,7 +2675,7 @@ static inline struct page *__dev_alloc_pages(gfp_t gfp_mask,
 	 * 4.  __GFP_MEMALLOC is ignored if __GFP_NOMEMALLOC is set due to
 	 *     code in gfp_to_alloc_flags that should be enforcing this.
 	 */
-	gfp_mask |= __GFP_COLD | __GFP_COMP | __GFP_MEMALLOC;
+	gfp_mask |= __GFP_COMP | __GFP_MEMALLOC;
 
 	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
 }
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 41473df6dfb0..d2529c6b37a9 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -458,9 +458,6 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  * Also it is possible to set different flags by OR'ing
  * in one or more of the following additional @flags:
  *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
  * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
  *
  * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index fec6291a6703..ab24013b0e33 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -31,7 +31,6 @@
 	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
 	{(unsigned long)__GFP_IO,		"__GFP_IO"},		\
 	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
-	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
 	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
 	{(unsigned long)__GFP_RETRY_MAYFAIL,	"__GFP_RETRY_MAYFAIL"},	\
 	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 0972a8e09d08..8a77a49f8f43 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1882,7 +1882,7 @@ static int enough_free_mem(unsigned int nr_pages, unsigned int nr_highmem)
  */
 static inline int get_highmem_buffer(int safe_needed)
 {
-	buffer = get_image_page(GFP_ATOMIC | __GFP_COLD, safe_needed);
+	buffer = get_image_page(GFP_ATOMIC, safe_needed);
 	return buffer ? 0 : -ENOMEM;
 }
 
@@ -1943,7 +1943,7 @@ static int swsusp_alloc(struct memory_bitmap *copy_bm,
 		while (nr_pages-- > 0) {
 			struct page *page;
 
-			page = alloc_image_page(GFP_ATOMIC | __GFP_COLD);
+			page = alloc_image_page(GFP_ATOMIC);
 			if (!page)
 				goto err_out;
 			memory_bm_set_bit(copy_bm, page_to_pfn(page));
diff --git a/mm/filemap.c b/mm/filemap.c
index aaaa324a283b..61175ac0b396 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2260,7 +2260,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page) {
 			error = -ENOMEM;
 			goto out;
@@ -2372,7 +2372,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 	int ret;
 
 	do {
-		page = __page_cache_alloc(gfp_mask|__GFP_COLD);
+		page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			return -ENOMEM;
 
@@ -2776,7 +2776,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp | __GFP_COLD);
+		page = __page_cache_alloc(gfp);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 13582efc57a0..ab68af66096f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2315,7 +2315,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
  */
 static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
-			int migratetype, bool cold)
+			int migratetype)
 {
 	int i, alloced = 0;
 
@@ -2337,10 +2337,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		 * merge IO requests if the physical pages are ordered
 		 * properly.
 		 */
-		if (likely(!cold))
-			list_add(&page->lru, list);
-		else
-			list_add_tail(&page->lru, list);
+		list_add(&page->lru, list);
 		list = &page->lru;
 		alloced++;
 		if (is_migrate_cma(get_pcppage_migratetype(page)))
@@ -2783,7 +2780,7 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 
 /* Remove page from the per-cpu list, caller must protect the list */
 static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
-			bool cold, struct per_cpu_pages *pcp,
+			struct per_cpu_pages *pcp,
 			struct list_head *list)
 {
 	struct page *page;
@@ -2792,16 +2789,12 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, list,
-					migratetype, cold);
+					migratetype);
 			if (unlikely(list_empty(list)))
 				return NULL;
 		}
 
-		if (cold)
-			page = list_last_entry(list, struct page, lru);
-		else
-			page = list_first_entry(list, struct page, lru);
-
+		page = list_first_entry(list, struct page, lru);
 		list_del(&page->lru);
 		pcp->count--;
 	} while (check_new_pcp(page));
@@ -2816,14 +2809,13 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
-	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 	struct page *page;
 	unsigned long flags;
 
 	local_irq_save(flags);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
-	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
+	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 15dab691ea70..9158e5a81391 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -81,7 +81,7 @@ static void pcpu_free_pages(struct pcpu_chunk *chunk,
 static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 			    struct page **pages, int page_start, int page_end)
 {
-	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM | __GFP_COLD;
+	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM;
 	unsigned int cpu, tcpu;
 	int i;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 16982de649b9..8951d90818d5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -357,7 +357,7 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
  */
 void *netdev_alloc_frag(unsigned int fragsz)
 {
-	return __netdev_alloc_frag(fragsz, GFP_ATOMIC | __GFP_COLD);
+	return __netdev_alloc_frag(fragsz, GFP_ATOMIC);
 }
 EXPORT_SYMBOL(netdev_alloc_frag);
 
@@ -370,7 +370,7 @@ static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 
 void *napi_alloc_frag(unsigned int fragsz)
 {
-	return __napi_alloc_frag(fragsz, GFP_ATOMIC | __GFP_COLD);
+	return __napi_alloc_frag(fragsz, GFP_ATOMIC);
 }
 EXPORT_SYMBOL(napi_alloc_frag);
 
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 24ee68ecdd42..34c7dc86c62b 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -640,7 +640,6 @@ static const struct {
 	{ "__GFP_ATOMIC",		"_A" },
 	{ "__GFP_IO",			"I" },
 	{ "__GFP_FS",			"F" },
-	{ "__GFP_COLD",			"CO" },
 	{ "__GFP_NOWARN",		"NWR" },
 	{ "__GFP_RETRY_MAYFAIL",	"R" },
 	{ "__GFP_NOFAIL",		"NF" },
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
