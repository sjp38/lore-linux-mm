Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE1666B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:47:49 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id f76so55327011vke.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:47:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u63si14009910ybf.321.2016.09.07.12.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 12:32:50 -0700 (PDT)
Date: Wed, 7 Sep 2016 21:32:43 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 04/11] net/mlx5e: Build RX SKB on demand
Message-ID: <20160907213243.773e5cde@redhat.com>
In-Reply-To: <1473252152-11379-5-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-5-git-send-email-saeedm@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Cc: iovisor-dev <iovisor-dev@lists.iovisor.org>, netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tom Herbert <tom@herbertland.com>, Martin KaFai Lau <kafai@fb.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <edumazet@google.com>, Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com, linux-mm <linux-mm@kvack.org>


On Wed,  7 Sep 2016 15:42:25 +0300 Saeed Mahameed <saeedm@mellanox.com> wrote:

> For non-striding RQ configuration before this patch we had a ring
> with pre-allocated SKBs and mapped the SKB->data buffers for
> device.
> 
> For robustness and better RX data buffers management, we allocate a
> page per packet and build_skb around it.
> 
> This patch (which is a prerequisite for XDP) will actually reduce
> performance for normal stack usage, because we are now hitting a bottleneck
> in the page allocator. A later patch of page reuse mechanism will be
> needed to restore or even improve performance in comparison to the old
> RX scheme.

Yes, it is true that there is a performance reduction (for normal
stack, not XDP) caused by hitting a bottleneck in the page allocator.

I actually have a PoC implementation of my page_pool, that show we
regain the performance and then some.  Based on an earlier version of
this patch, where I hook it into the mlx5 driver (50Gbit/s version).


You desc might be a bit outdated, as this patch and the patch before
does contain you own driver local page-cache recycle facility.  And you
also show that you regain quite a lot of the lost performance.

You driver local page_cache does have its limitations (see comments on
other patch), as it depend on timely refcnt decrease, by the users of
the page.  If they hold onto pages (like TCP) then your page-cache will
not be efficient.

 
> Packet rate performance testing was done with pktgen 64B packets on
> xmit side and TC drop action on RX side.

I assume this is TC _ingress_ dropping, like [1]

[1] https://github.com/netoptimizer/network-testing/blob/master/bin/tc_ingress_drop.sh

> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
> 
> Comparison is done between:
>  1.Baseline, before 'net/mlx5e: Build RX SKB on demand'
>  2.Build SKB with RX page cache (This patch)
> 
> Streams    Baseline    Build SKB+page-cache    Improvement
> -----------------------------------------------------------
> 1          4.33Mpps      5.51Mpps                27%
> 2          7.35Mpps      11.5Mpps                52%
> 4          14.0Mpps      16.3Mpps                16%
> 8          22.2Mpps      29.6Mpps                20%
> 16         24.8Mpps      34.0Mpps                17%

The improvements gained from using your page-cache is impressively high.

Thanks for working on this,
 --Jesper
 
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en.h      |  10 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  31 +++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 215 +++++++++++-----------
>  3 files changed, 133 insertions(+), 123 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index afbdf70..a346112 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -65,6 +65,8 @@
>  #define MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW            0x3
>  #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW            0x6
>  
> +#define MLX5_RX_HEADROOM NET_SKB_PAD
> +
>  #define MLX5_MPWRQ_LOG_STRIDE_SIZE		6  /* >= 6, HW restriction */
>  #define MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS	8  /* >= 6, HW restriction */
>  #define MLX5_MPWRQ_LOG_WQE_SZ			18
> @@ -302,10 +304,14 @@ struct mlx5e_page_cache {
>  struct mlx5e_rq {
>  	/* data path */
>  	struct mlx5_wq_ll      wq;
> -	u32                    wqe_sz;
> -	struct sk_buff       **skb;
> +
> +	struct mlx5e_dma_info *dma_info;
>  	struct mlx5e_mpw_info *wqe_info;
>  	void                  *mtt_no_align;
> +	struct {
> +		u8             page_order;
> +		u32            wqe_sz;    /* wqe data buffer size */
> +	} buff;
>  	__be32                 mkey_be;
>  
>  	struct device         *pdev;
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index c84702c..c9f1dea 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -411,6 +411,8 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>  	void *rqc = param->rqc;
>  	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
>  	u32 byte_count;
> +	u32 frag_sz;
> +	int npages;
>  	int wq_sz;
>  	int err;
>  	int i;
> @@ -445,29 +447,40 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>  
>  		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
>  		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
> -		rq->wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
> -		byte_count = rq->wqe_sz;
> +
> +		rq->buff.wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
> +		byte_count = rq->buff.wqe_sz;
>  		rq->mkey_be = cpu_to_be32(c->priv->umr_mkey.key);
>  		err = mlx5e_rq_alloc_mpwqe_info(rq, c);
>  		if (err)
>  			goto err_rq_wq_destroy;
>  		break;
>  	default: /* MLX5_WQ_TYPE_LINKED_LIST */
> -		rq->skb = kzalloc_node(wq_sz * sizeof(*rq->skb), GFP_KERNEL,
> -				       cpu_to_node(c->cpu));
> -		if (!rq->skb) {
> +		rq->dma_info = kzalloc_node(wq_sz * sizeof(*rq->dma_info), GFP_KERNEL,
> +					    cpu_to_node(c->cpu));
> +		if (!rq->dma_info) {
>  			err = -ENOMEM;
>  			goto err_rq_wq_destroy;
>  		}
> +
>  		rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
>  		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
>  		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
>  
> -		rq->wqe_sz = (priv->params.lro_en) ?
> +		rq->buff.wqe_sz = (priv->params.lro_en) ?
>  				priv->params.lro_wqe_sz :
>  				MLX5E_SW2HW_MTU(priv->netdev->mtu);
> -		rq->wqe_sz = SKB_DATA_ALIGN(rq->wqe_sz);
> -		byte_count = rq->wqe_sz;
> +		byte_count = rq->buff.wqe_sz;
> +
> +		/* calc the required page order */
> +		frag_sz = MLX5_RX_HEADROOM +
> +			  byte_count /* packet data */ +
> +			  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +		frag_sz = SKB_DATA_ALIGN(frag_sz);
> +
> +		npages = DIV_ROUND_UP(frag_sz, PAGE_SIZE);
> +		rq->buff.page_order = order_base_2(npages);
> +
>  		byte_count |= MLX5_HW_START_PADDING;
>  		rq->mkey_be = c->mkey_be;
>  	}
> @@ -502,7 +515,7 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
>  		mlx5e_rq_free_mpwqe_info(rq);
>  		break;
>  	default: /* MLX5_WQ_TYPE_LINKED_LIST */
> -		kfree(rq->skb);
> +		kfree(rq->dma_info);
>  	}
>  
>  	for (i = rq->page_cache.head; i != rq->page_cache.tail;
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index 8e02af3..2f5bc6f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -179,50 +179,99 @@ unlock:
>  	mutex_unlock(&priv->state_lock);
>  }
>  
> -int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
> +#define RQ_PAGE_SIZE(rq) ((1 << rq->buff.page_order) << PAGE_SHIFT)
> +
> +static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
> +				      struct mlx5e_dma_info *dma_info)
>  {
> -	struct sk_buff *skb;
> -	dma_addr_t dma_addr;
> +	struct mlx5e_page_cache *cache = &rq->page_cache;
> +	u32 tail_next = (cache->tail + 1) & (MLX5E_CACHE_SIZE - 1);
>  
> -	skb = napi_alloc_skb(rq->cq.napi, rq->wqe_sz);
> -	if (unlikely(!skb))
> -		return -ENOMEM;
> +	if (tail_next == cache->head) {
> +		rq->stats.cache_full++;
> +		return false;
> +	}
> +
> +	cache->page_cache[cache->tail] = *dma_info;
> +	cache->tail = tail_next;
> +	return true;
> +}
> +
> +static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
> +				      struct mlx5e_dma_info *dma_info)
> +{
> +	struct mlx5e_page_cache *cache = &rq->page_cache;
> +
> +	if (unlikely(cache->head == cache->tail)) {
> +		rq->stats.cache_empty++;
> +		return false;
> +	}
> +
> +	if (page_ref_count(cache->page_cache[cache->head].page) != 1) {
> +		rq->stats.cache_busy++;
> +		return false;
> +	}
> +
> +	*dma_info = cache->page_cache[cache->head];
> +	cache->head = (cache->head + 1) & (MLX5E_CACHE_SIZE - 1);
> +	rq->stats.cache_reuse++;
> +
> +	dma_sync_single_for_device(rq->pdev, dma_info->addr,
> +				   RQ_PAGE_SIZE(rq),
> +				   DMA_FROM_DEVICE);
> +	return true;
> +}
>  
> -	dma_addr = dma_map_single(rq->pdev,
> -				  /* hw start padding */
> -				  skb->data,
> -				  /* hw end padding */
> -				  rq->wqe_sz,
> -				  DMA_FROM_DEVICE);
> +static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
> +					  struct mlx5e_dma_info *dma_info)
> +{
> +	struct page *page;
>  
> -	if (unlikely(dma_mapping_error(rq->pdev, dma_addr)))
> -		goto err_free_skb;
> +	if (mlx5e_rx_cache_get(rq, dma_info))
> +		return 0;
>  
> -	*((dma_addr_t *)skb->cb) = dma_addr;
> -	wqe->data.addr = cpu_to_be64(dma_addr);
> +	page = dev_alloc_pages(rq->buff.page_order);
> +	if (unlikely(!page))
> +		return -ENOMEM;
>  
> -	rq->skb[ix] = skb;
> +	dma_info->page = page;
> +	dma_info->addr = dma_map_page(rq->pdev, page, 0,
> +				      RQ_PAGE_SIZE(rq), DMA_FROM_DEVICE);
> +	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
> +		put_page(page);
> +		return -ENOMEM;
> +	}
>  
>  	return 0;
> +}
>  
> -err_free_skb:
> -	dev_kfree_skb(skb);
> +void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
> +			bool recycle)
> +{
> +	if (likely(recycle) && mlx5e_rx_cache_put(rq, dma_info))
> +		return;
> +
> +	dma_unmap_page(rq->pdev, dma_info->addr, RQ_PAGE_SIZE(rq),
> +		       DMA_FROM_DEVICE);
> +	put_page(dma_info->page);
> +}
> +
> +int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
> +{
> +	struct mlx5e_dma_info *di = &rq->dma_info[ix];
>  
> -	return -ENOMEM;
> +	if (unlikely(mlx5e_page_alloc_mapped(rq, di)))
> +		return -ENOMEM;
> +
> +	wqe->data.addr = cpu_to_be64(di->addr + MLX5_RX_HEADROOM);
> +	return 0;
>  }
>  
>  void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix)
>  {
> -	struct sk_buff *skb = rq->skb[ix];
> +	struct mlx5e_dma_info *di = &rq->dma_info[ix];
>  
> -	if (skb) {
> -		rq->skb[ix] = NULL;
> -		dma_unmap_single(rq->pdev,
> -				 *((dma_addr_t *)skb->cb),
> -				 rq->wqe_sz,
> -				 DMA_FROM_DEVICE);
> -		dev_kfree_skb(skb);
> -	}
> +	mlx5e_page_release(rq, di, true);
>  }
>  
>  static inline int mlx5e_mpwqe_strides_per_page(struct mlx5e_rq *rq)
> @@ -305,79 +354,6 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
>  	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
>  }
>  
> -static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
> -				      struct mlx5e_dma_info *dma_info)
> -{
> -	struct mlx5e_page_cache *cache = &rq->page_cache;
> -	u32 tail_next = (cache->tail + 1) & (MLX5E_CACHE_SIZE - 1);
> -
> -	if (tail_next == cache->head) {
> -		rq->stats.cache_full++;
> -		return false;
> -	}
> -
> -	cache->page_cache[cache->tail] = *dma_info;
> -	cache->tail = tail_next;
> -	return true;
> -}
> -
> -static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
> -				      struct mlx5e_dma_info *dma_info)
> -{
> -	struct mlx5e_page_cache *cache = &rq->page_cache;
> -
> -	if (unlikely(cache->head == cache->tail)) {
> -		rq->stats.cache_empty++;
> -		return false;
> -	}
> -
> -	if (page_ref_count(cache->page_cache[cache->head].page) != 1) {
> -		rq->stats.cache_busy++;
> -		return false;
> -	}
> -
> -	*dma_info = cache->page_cache[cache->head];
> -	cache->head = (cache->head + 1) & (MLX5E_CACHE_SIZE - 1);
> -	rq->stats.cache_reuse++;
> -
> -	dma_sync_single_for_device(rq->pdev, dma_info->addr, PAGE_SIZE,
> -				   DMA_FROM_DEVICE);
> -	return true;
> -}
> -
> -static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
> -					  struct mlx5e_dma_info *dma_info)
> -{
> -	struct page *page;
> -
> -	if (mlx5e_rx_cache_get(rq, dma_info))
> -		return 0;
> -
> -	page = dev_alloc_page();
> -	if (unlikely(!page))
> -		return -ENOMEM;
> -
> -	dma_info->page = page;
> -	dma_info->addr = dma_map_page(rq->pdev, page, 0, PAGE_SIZE,
> -				      DMA_FROM_DEVICE);
> -	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
> -		put_page(page);
> -		return -ENOMEM;
> -	}
> -
> -	return 0;
> -}
> -
> -void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
> -			bool recycle)
> -{
> -	if (likely(recycle) && mlx5e_rx_cache_put(rq, dma_info))
> -		return;
> -
> -	dma_unmap_page(rq->pdev, dma_info->addr, PAGE_SIZE, DMA_FROM_DEVICE);
> -	put_page(dma_info->page);
> -}
> -
>  static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
>  				    struct mlx5e_rx_wqe *wqe,
>  				    u16 ix)
> @@ -448,7 +424,7 @@ void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
>  	mlx5_wq_ll_update_db_record(wq);
>  }
>  
> -int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,	u16 ix)
> +int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
>  {
>  	int err;
>  
> @@ -650,31 +626,46 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
>  
>  void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>  {
> +	struct mlx5e_dma_info *di;
>  	struct mlx5e_rx_wqe *wqe;
> -	struct sk_buff *skb;
>  	__be16 wqe_counter_be;
> +	struct sk_buff *skb;
>  	u16 wqe_counter;
>  	u32 cqe_bcnt;
> +	void *va;
>  
>  	wqe_counter_be = cqe->wqe_counter;
>  	wqe_counter    = be16_to_cpu(wqe_counter_be);
>  	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
> -	skb            = rq->skb[wqe_counter];
> -	prefetch(skb->data);
> -	rq->skb[wqe_counter] = NULL;
> +	di             = &rq->dma_info[wqe_counter];
> +	va             = page_address(di->page);
>  
> -	dma_unmap_single(rq->pdev,
> -			 *((dma_addr_t *)skb->cb),
> -			 rq->wqe_sz,
> -			 DMA_FROM_DEVICE);
> +	dma_sync_single_range_for_cpu(rq->pdev,
> +				      di->addr,
> +				      MLX5_RX_HEADROOM,
> +				      rq->buff.wqe_sz,
> +				      DMA_FROM_DEVICE);
> +	prefetch(va + MLX5_RX_HEADROOM);
>  
>  	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
>  		rq->stats.wqe_err++;
> -		dev_kfree_skb(skb);
> +		mlx5e_page_release(rq, di, true);
>  		goto wq_ll_pop;
>  	}
>  
> +	skb = build_skb(va, RQ_PAGE_SIZE(rq));
> +	if (unlikely(!skb)) {
> +		rq->stats.buff_alloc_err++;
> +		mlx5e_page_release(rq, di, true);
> +		goto wq_ll_pop;
> +	}
> +
> +	/* queue up for recycling ..*/
> +	page_ref_inc(di->page);
> +	mlx5e_page_release(rq, di, true);
> +
>  	cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
> +	skb_reserve(skb, MLX5_RX_HEADROOM);
>  	skb_put(skb, cqe_bcnt);
>  
>  	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
