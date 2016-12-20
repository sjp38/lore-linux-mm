Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3147F6B030F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:28:26 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id k201so22792801qke.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:28:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si12268974qtb.147.2016.12.20.05.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:28:25 -0800 (PST)
Subject: [RFC PATCH 3/4] mlx5: use page_pool
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 20 Dec 2016 14:28:22 +0100
Message-ID: <20161220132822.18788.19768.stgit@firesoul>
In-Reply-To: <20161220132444.18788.50875.stgit@firesoul>
References: <20161220132444.18788.50875.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>

The mlx5 driver already have a driver local page recycle cache.  This
page cache is only efficient when the number of outstanding pages is
small, the queue based cache array size is 128.  Further more a single
page with elevated refcnt can block the queue.

Benchmarking on next-next at commit f5f99309fa74 ("sock: do not set
sk_err in sock_dequeue_err_skb"), which include Paolo's UDP
performance optimizations (commit fc13fd398625 ("Merge branch
'udp-fwd-mem-sched-on-dequeue'").  Showed a speedup of 29% for UDP
packets. Detailed ethtool stats showed mlx5 page recycler didn't
"work" in that benchmark.  The XDP_DROP use-case, showed a small perf
regression +2.7ns using page_pool.  This correspons well to the 28%
gain reported in commit 1bfecfca565c ("net/mlx5e: Build RX SKB on
demand").

UPDATE: On newer kernels, net-next at commit 52f40e9d65. The mlx5 page
recycle cache works again, and performance gain is gone.  Detailed
benchmarking show, RX-ksoftirq side is approx 10% faster, while UDP
socket delivery is same performance.

For TC early ingress drop there is a small performance regression of
approx +4 ns. There are pending page_pool optimization that will
close that gap.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   28 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   47 ++++++++++++++-------
 3 files changed, 60 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 951dbd58594d..b30d5b08d6a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -361,6 +361,7 @@ struct mlx5e_rq {
 	struct mlx5e_tstamp   *tstamp;
 	struct mlx5e_rq_stats  stats;
 	struct mlx5e_cq        cq;
+	struct page_pool      *page_pool;
 	struct mlx5e_page_cache page_cache;
 
 	mlx5e_fp_handle_rx_cqe handle_rx_cqe;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cbfa38fc72c0..cd71e5764ec1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -34,6 +34,7 @@
 #include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
+#include <linux/page_pool.h>
 #include <linux/bpf.h>
 #include "en.h"
 #include "en_tc.h"
@@ -521,6 +522,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
 {
+	struct page_pool_params pp_params = { 0 };
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqc = param->rqc;
@@ -591,6 +593,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
 		rq->dma_info = kzalloc_node(wq_sz * sizeof(*rq->dma_info),
 					    GFP_KERNEL, cpu_to_node(c->cpu));
+//		rq->dma_info = NULL; //HACK ALWAYS FAIL TEST
 		if (!rq->dma_info) {
 			err = -ENOMEM;
 			goto err_rq_wq_destroy;
@@ -618,6 +621,24 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		npages = DIV_ROUND_UP(frag_sz, PAGE_SIZE);
 		rq->buff.page_order = order_base_2(npages);
 
+		pp_params.size		= PAGE_POOL_PARAMS_SIZE;
+		pp_params.order		= rq->buff.page_order;
+		pp_params.dev		= c->pdev;
+		pp_params.nid		= cpu_to_node(c->cpu);
+		pp_params.dma_dir	= DMA_BIDIRECTIONAL;
+		pp_params.pool_size	= 2000;
+		pr_info("XXX: %s() pp_params.size=%d end=%lu\n",
+			__func__, pp_params.size,
+			offsetof(struct page_pool_params, end_marker));
+
+		rq->page_pool = page_pool_create(&pp_params);
+		if (IS_ERR_OR_NULL(rq->page_pool)) {
+			rq->page_pool = NULL;
+			kfree(rq->dma_info);
+			err = -ENOMEM;
+			goto err_rq_wq_destroy;
+		}
+
 		byte_count |= MLX5_HW_START_PADDING;
 		rq->mkey_be = c->mkey_be;
 	}
@@ -662,6 +683,13 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
 		kfree(rq->dma_info);
+		if (rq->page_pool)
+			page_pool_destroy(rq->page_pool);
+		else
+			// Can happen because mlx5 have some extra
+			// rq's for some other purposes... (explain?)
+			pr_err("XXX: %s() NULL pointer at rq->page_pool\n",
+			       __func__);
 	}
 
 	for (i = rq->page_cache.head; i != rq->page_cache.tail;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0e2fb3ed1790..0512632b30fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -182,6 +182,7 @@ void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
 
 #define RQ_PAGE_SIZE(rq) ((1 << rq->buff.page_order) << PAGE_SHIFT)
 
+// TODO: Remove mlx5-page-cache
 static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
 				      struct mlx5e_dma_info *dma_info)
 {
@@ -198,6 +199,7 @@ static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
 	return true;
 }
 
+// TODO: Remove mlx5-page-cache
 static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
 				      struct mlx5e_dma_info *dma_info)
 {
@@ -228,20 +230,27 @@ static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 {
 	struct page *page;
 
-	if (mlx5e_rx_cache_get(rq, dma_info))
-		return 0;
+//	if (mlx5e_rx_cache_get(rq, dma_info))
+//		return 0;
 
-	page = dev_alloc_pages(rq->buff.page_order);
+	//page = dev_alloc_pages(rq->buff.page_order);
+	page = page_pool_dev_alloc_pages(rq->page_pool);
 	if (unlikely(!page))
 		return -ENOMEM;
 
 	dma_info->page = page;
-	dma_info->addr = dma_map_page(rq->pdev, page, 0,
-				      RQ_PAGE_SIZE(rq), rq->buff.map_dir);
-	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
-		put_page(page);
-		return -ENOMEM;
-	}
+	dma_info->addr = page->dma_addr;
+//	dma_info->addr = dma_map_page(rq->pdev, page, 0,
+//				      RQ_PAGE_SIZE(rq), rq->buff.map_dir);
+
+	/* DISCUSS: should this be moved into page_pool API?  Here we
+	 * sync entire page, but some drivers might want have more
+	 * control?  Like using the dma_sync_single_range_for_device()
+	 * like Alex is doing in the Intel drivers...
+	 */
+	dma_sync_single_for_device(rq->pdev, dma_info->addr,
+				   RQ_PAGE_SIZE(rq),
+				   DMA_FROM_DEVICE);
 
 	return 0;
 }
@@ -249,11 +258,21 @@ static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 			bool recycle)
 {
-	if (likely(recycle) && mlx5e_rx_cache_put(rq, dma_info))
+//	if (likely(recycle) && mlx5e_rx_cache_put(rq, dma_info))
+//		return;
+	// TODO: use page_pool_recycle_direct(dma_info->page);
+	if (recycle) {
+		page_pool_recycle_direct(dma_info->page);
 		return;
+	}
+
+// page_pool take over dma_unmap
+//	dma_unmap_page(rq->pdev, dma_info->addr, RQ_PAGE_SIZE(rq),
+//		       rq->buff.map_dir);
+	// XXX: do we need to call dma_sync_single_range_for_cpu here???
+	// dma_sync_single_range_for_cpu(rq->pdev, dma_info->addr,
+	//			      RQ_PAGE_SIZE(rq), rq->buff.map_dir);
 
-	dma_unmap_page(rq->pdev, dma_info->addr, RQ_PAGE_SIZE(rq),
-		       rq->buff.map_dir);
 	put_page(dma_info->page);
 }
 
@@ -773,10 +792,6 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 		return NULL;
 	}
 
-	/* queue up for recycling ..*/
-	page_ref_inc(di->page);
-	mlx5e_page_release(rq, di, true);
-
 	skb_reserve(skb, MLX5_RX_HEADROOM);
 	skb_put(skb, cqe_bcnt);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
