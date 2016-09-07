Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAEE26B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:33:52 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 10so58674535ual.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:33:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p4si7541853ywp.299.2016.09.07.12.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 12:18:48 -0700 (PDT)
Date: Wed, 7 Sep 2016 21:18:40 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 01/11] net/mlx5e: Single flow order-0 pages for
 Striding RQ
Message-ID: <20160907211840.36c37ea0@redhat.com>
In-Reply-To: <1473252152-11379-2-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-2-git-send-email-saeedm@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Cc: iovisor-dev <iovisor-dev@lists.iovisor.org>, netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tom Herbert <tom@herbertland.com>, Martin KaFai Lau <kafai@fb.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <edumazet@google.com>, Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com, linux-mm <linux-mm@kvack.org>


On Wed,  7 Sep 2016 15:42:22 +0300 Saeed Mahameed <saeedm@mellanox.com> wrote:

> From: Tariq Toukan <tariqt@mellanox.com>
> 
> To improve the memory consumption scheme, we omit the flow that
> demands and splits high-order pages in Striding RQ, and stay
> with a single Striding RQ flow that uses order-0 pages.

Thanks you for doing this! MM-list people thanks you!

For others to understand what this means:  This driver was doing
split_page() on high-order pages (for Striding RQ).  This was really bad
because it will cause fragmenting the page-allocator, and depleting the
high-order pages available quickly.

(I've left rest of patch intact below, if some MM people should be
interested in looking at the changes).

There is even a funny comment in split_page() relevant to this:

/* [...]
 * Note: this is probably too low level an operation for use in drivers.
 * Please consult with lkml before using this in your driver.
 */


> Moving to fragmented memory allows the use of larger MPWQEs,
> which reduces the number of UMR posts and filler CQEs.
> 
> Moving to a single flow allows several optimizations that improve
> performance, especially in production servers where we would
> anyway fallback to order-0 allocations:
> - inline functions that were called via function pointers.
> - improve the UMR post process.
> 
> This patch alone is expected to give a slight performance reduction.
> However, the new memory scheme gives the possibility to use a page-cache
> of a fair size, that doesn't inflate the memory footprint, which will
> dramatically fix the reduction and even give a huge gain.
> 
> We ran pktgen single-stream benchmarks, with iptables-raw-drop:
> 
> Single stride, 64 bytes:
> * 4,739,057 - baseline
> * 4,749,550 - this patch
> no reduction
> 
> Larger packets, no page cross, 1024 bytes:
> * 3,982,361 - baseline
> * 3,845,682 - this patch
> 3.5% reduction
> 
> Larger packets, every 3rd packet crosses a page, 1500 bytes:
> * 3,731,189 - baseline
> * 3,579,414 - this patch
> 4% reduction
> 

Well, the reduction does not really matter than much, because your
baseline benchmarks are from a freshly booted system, where you have
not fragmented and depleted the high-order pages yet... ;-)


> Fixes: 461017cb006a ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
> Fixes: bc77b240b3c5 ("net/mlx5e: Add fragmented memory support for RX multi packet WQE")
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |  54 ++--
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 136 ++++++++--
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 292 ++++-----------------
>  drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   4 -
>  drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   2 +-
>  5 files changed, 184 insertions(+), 304 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index bf722aa..075cdfc 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -62,12 +62,12 @@
>  #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE                0xd
>  
>  #define MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE_MPW            0x1
> -#define MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW            0x4
> +#define MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE_MPW            0x3
>  #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW            0x6
>  
>  #define MLX5_MPWRQ_LOG_STRIDE_SIZE		6  /* >= 6, HW restriction */
>  #define MLX5_MPWRQ_LOG_STRIDE_SIZE_CQE_COMPRESS	8  /* >= 6, HW restriction */
> -#define MLX5_MPWRQ_LOG_WQE_SZ			17
> +#define MLX5_MPWRQ_LOG_WQE_SZ			18
>  #define MLX5_MPWRQ_WQE_PAGE_ORDER  (MLX5_MPWRQ_LOG_WQE_SZ - PAGE_SHIFT > 0 ? \
>  				    MLX5_MPWRQ_LOG_WQE_SZ - PAGE_SHIFT : 0)
>  #define MLX5_MPWRQ_PAGES_PER_WQE		BIT(MLX5_MPWRQ_WQE_PAGE_ORDER)
> @@ -293,8 +293,8 @@ struct mlx5e_rq {
>  	u32                    wqe_sz;
>  	struct sk_buff       **skb;
>  	struct mlx5e_mpw_info *wqe_info;
> +	void                  *mtt_no_align;
>  	__be32                 mkey_be;
> -	__be32                 umr_mkey_be;
>  
>  	struct device         *pdev;
>  	struct net_device     *netdev;
> @@ -323,32 +323,15 @@ struct mlx5e_rq {
>  
>  struct mlx5e_umr_dma_info {
>  	__be64                *mtt;
> -	__be64                *mtt_no_align;
>  	dma_addr_t             mtt_addr;
> -	struct mlx5e_dma_info *dma_info;
> +	struct mlx5e_dma_info  dma_info[MLX5_MPWRQ_PAGES_PER_WQE];
> +	struct mlx5e_umr_wqe   wqe;
>  };
>  
>  struct mlx5e_mpw_info {
> -	union {
> -		struct mlx5e_dma_info     dma_info;
> -		struct mlx5e_umr_dma_info umr;
> -	};
> +	struct mlx5e_umr_dma_info umr;
>  	u16 consumed_strides;
>  	u16 skbs_frags[MLX5_MPWRQ_PAGES_PER_WQE];
> -
> -	void (*dma_pre_sync)(struct device *pdev,
> -			     struct mlx5e_mpw_info *wi,
> -			     u32 wqe_offset, u32 len);
> -	void (*add_skb_frag)(struct mlx5e_rq *rq,
> -			     struct sk_buff *skb,
> -			     struct mlx5e_mpw_info *wi,
> -			     u32 page_idx, u32 frag_offset, u32 len);
> -	void (*copy_skb_header)(struct device *pdev,
> -				struct sk_buff *skb,
> -				struct mlx5e_mpw_info *wi,
> -				u32 page_idx, u32 offset,
> -				u32 headlen);
> -	void (*free_wqe)(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi);
>  };
>  
>  struct mlx5e_tx_wqe_info {
> @@ -706,24 +689,11 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
>  void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
>  bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
>  int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
> -int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
> +int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,	u16 ix);
>  void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix);
>  void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix);
> -void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq);
> -void mlx5e_complete_rx_linear_mpwqe(struct mlx5e_rq *rq,
> -				    struct mlx5_cqe64 *cqe,
> -				    u16 byte_cnt,
> -				    struct mlx5e_mpw_info *wi,
> -				    struct sk_buff *skb);
> -void mlx5e_complete_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
> -					struct mlx5_cqe64 *cqe,
> -					u16 byte_cnt,
> -					struct mlx5e_mpw_info *wi,
> -					struct sk_buff *skb);
> -void mlx5e_free_rx_linear_mpwqe(struct mlx5e_rq *rq,
> -				struct mlx5e_mpw_info *wi);
> -void mlx5e_free_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
> -				    struct mlx5e_mpw_info *wi);
> +void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq);
> +void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi);
>  struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
>  
>  void mlx5e_rx_am(struct mlx5e_rq *rq);
> @@ -810,6 +780,12 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
>  	mlx5_cq_arm(mcq, MLX5_CQ_DB_REQ_NOT, mcq->uar->map, NULL, cq->wq.cc);
>  }
>  
> +static inline u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
> +{
> +	return rq->mpwqe_mtt_offset +
> +		wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
> +}
> +
>  static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
>  {
>  	return min_t(int, mdev->priv.eq_table.num_comp_vectors,
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 2459c7f..0db4d3b 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -138,7 +138,6 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
>  		s->rx_csum_unnecessary_inner += rq_stats->csum_unnecessary_inner;
>  		s->rx_wqe_err   += rq_stats->wqe_err;
>  		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
> -		s->rx_mpwqe_frag   += rq_stats->mpwqe_frag;
>  		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
>  		s->rx_cqe_compress_blks += rq_stats->cqe_compress_blks;
>  		s->rx_cqe_compress_pkts += rq_stats->cqe_compress_pkts;
> @@ -298,6 +297,107 @@ static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
>  #define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
>  #define MLX5E_SW2HW_MTU(swmtu) (swmtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
>  
> +static inline int mlx5e_get_wqe_mtt_sz(void)
> +{
> +	/* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
> +	 * To avoid copying garbage after the mtt array, we allocate
> +	 * a little more.
> +	 */
> +	return ALIGN(MLX5_MPWRQ_PAGES_PER_WQE * sizeof(__be64),
> +		     MLX5_UMR_MTT_ALIGNMENT);
> +}
> +
> +static inline void mlx5e_build_umr_wqe(struct mlx5e_rq *rq, struct mlx5e_sq *sq,
> +				       struct mlx5e_umr_wqe *wqe, u16 ix)
> +{
> +	struct mlx5_wqe_ctrl_seg      *cseg = &wqe->ctrl;
> +	struct mlx5_wqe_umr_ctrl_seg *ucseg = &wqe->uctrl;
> +	struct mlx5_wqe_data_seg      *dseg = &wqe->data;
> +	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> +	u8 ds_cnt = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_DS);
> +	u32 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq, ix);
> +
> +	cseg->qpn_ds    = cpu_to_be32((sq->sqn << MLX5_WQE_CTRL_QPN_SHIFT) |
> +				      ds_cnt);
> +	cseg->fm_ce_se  = MLX5_WQE_CTRL_CQ_UPDATE;
> +	cseg->imm       = rq->mkey_be;
> +
> +	ucseg->flags = MLX5_UMR_TRANSLATION_OFFSET_EN;
> +	ucseg->klm_octowords =
> +		cpu_to_be16(MLX5_MTT_OCTW(MLX5_MPWRQ_PAGES_PER_WQE));
> +	ucseg->bsf_octowords =
> +		cpu_to_be16(MLX5_MTT_OCTW(umr_wqe_mtt_offset));
> +	ucseg->mkey_mask     = cpu_to_be64(MLX5_MKEY_MASK_FREE);
> +
> +	dseg->lkey = sq->mkey_be;
> +	dseg->addr = cpu_to_be64(wi->umr.mtt_addr);
> +}
> +
> +static int mlx5e_rq_alloc_mpwqe_info(struct mlx5e_rq *rq,
> +				     struct mlx5e_channel *c)
> +{
> +	int wq_sz = mlx5_wq_ll_get_size(&rq->wq);
> +	int mtt_sz = mlx5e_get_wqe_mtt_sz();
> +	int mtt_alloc = mtt_sz + MLX5_UMR_ALIGN - 1;
> +	int i;
> +
> +	rq->wqe_info = kzalloc_node(wq_sz * sizeof(*rq->wqe_info),
> +				    GFP_KERNEL, cpu_to_node(c->cpu));
> +	if (!rq->wqe_info)
> +		goto err_out;
> +
> +	/* We allocate more than mtt_sz as we will align the pointer */
> +	rq->mtt_no_align = kzalloc_node(mtt_alloc * wq_sz, GFP_KERNEL,
> +					cpu_to_node(c->cpu));
> +	if (unlikely(!rq->mtt_no_align))
> +		goto err_free_wqe_info;
> +
> +	for (i = 0; i < wq_sz; i++) {
> +		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
> +
> +		wi->umr.mtt = PTR_ALIGN(rq->mtt_no_align + i * mtt_alloc,
> +					MLX5_UMR_ALIGN);
> +		wi->umr.mtt_addr = dma_map_single(c->pdev, wi->umr.mtt, mtt_sz,
> +						  PCI_DMA_TODEVICE);
> +		if (unlikely(dma_mapping_error(c->pdev, wi->umr.mtt_addr)))
> +			goto err_unmap_mtts;
> +
> +		mlx5e_build_umr_wqe(rq, &c->icosq, &wi->umr.wqe, i);
> +	}
> +
> +	return 0;
> +
> +err_unmap_mtts:
> +	while (--i >= 0) {
> +		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
> +
> +		dma_unmap_single(c->pdev, wi->umr.mtt_addr, mtt_sz,
> +				 PCI_DMA_TODEVICE);
> +	}
> +	kfree(rq->mtt_no_align);
> +err_free_wqe_info:
> +	kfree(rq->wqe_info);
> +
> +err_out:
> +	return -ENOMEM;
> +}
> +
> +static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
> +{
> +	int wq_sz = mlx5_wq_ll_get_size(&rq->wq);
> +	int mtt_sz = mlx5e_get_wqe_mtt_sz();
> +	int i;
> +
> +	for (i = 0; i < wq_sz; i++) {
> +		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
> +
> +		dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz,
> +				 PCI_DMA_TODEVICE);
> +	}
> +	kfree(rq->mtt_no_align);
> +	kfree(rq->wqe_info);
> +}
> +
>  static int mlx5e_create_rq(struct mlx5e_channel *c,
>  			   struct mlx5e_rq_param *param,
>  			   struct mlx5e_rq *rq)
> @@ -322,14 +422,16 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>  
>  	wq_sz = mlx5_wq_ll_get_size(&rq->wq);
>  
> +	rq->wq_type = priv->params.rq_wq_type;
> +	rq->pdev    = c->pdev;
> +	rq->netdev  = c->netdev;
> +	rq->tstamp  = &priv->tstamp;
> +	rq->channel = c;
> +	rq->ix      = c->ix;
> +	rq->priv    = c->priv;
> +
>  	switch (priv->params.rq_wq_type) {
>  	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
> -		rq->wqe_info = kzalloc_node(wq_sz * sizeof(*rq->wqe_info),
> -					    GFP_KERNEL, cpu_to_node(c->cpu));
> -		if (!rq->wqe_info) {
> -			err = -ENOMEM;
> -			goto err_rq_wq_destroy;
> -		}
>  		rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
>  		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
>  		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
> @@ -341,6 +443,10 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>  		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
>  		rq->wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
>  		byte_count = rq->wqe_sz;
> +		rq->mkey_be = cpu_to_be32(c->priv->umr_mkey.key);
> +		err = mlx5e_rq_alloc_mpwqe_info(rq, c);
> +		if (err)
> +			goto err_rq_wq_destroy;
>  		break;
>  	default: /* MLX5_WQ_TYPE_LINKED_LIST */
>  		rq->skb = kzalloc_node(wq_sz * sizeof(*rq->skb), GFP_KERNEL,
> @@ -359,27 +465,19 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>  		rq->wqe_sz = SKB_DATA_ALIGN(rq->wqe_sz);
>  		byte_count = rq->wqe_sz;
>  		byte_count |= MLX5_HW_START_PADDING;
> +		rq->mkey_be = c->mkey_be;
>  	}
>  
>  	for (i = 0; i < wq_sz; i++) {
>  		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(&rq->wq, i);
>  
>  		wqe->data.byte_count = cpu_to_be32(byte_count);
> +		wqe->data.lkey = rq->mkey_be;
>  	}
>  
>  	INIT_WORK(&rq->am.work, mlx5e_rx_am_work);
>  	rq->am.mode = priv->params.rx_cq_period_mode;
>  
> -	rq->wq_type = priv->params.rq_wq_type;
> -	rq->pdev    = c->pdev;
> -	rq->netdev  = c->netdev;
> -	rq->tstamp  = &priv->tstamp;
> -	rq->channel = c;
> -	rq->ix      = c->ix;
> -	rq->priv    = c->priv;
> -	rq->mkey_be = c->mkey_be;
> -	rq->umr_mkey_be = cpu_to_be32(c->priv->umr_mkey.key);
> -
>  	return 0;
>  
>  err_rq_wq_destroy:
> @@ -392,7 +490,7 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
>  {
>  	switch (rq->wq_type) {
>  	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
> -		kfree(rq->wqe_info);
> +		mlx5e_rq_free_mpwqe_info(rq);
>  		break;
>  	default: /* MLX5_WQ_TYPE_LINKED_LIST */
>  		kfree(rq->skb);
> @@ -530,7 +628,7 @@ static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
>  
>  	/* UMR WQE (if in progress) is always at wq->head */
>  	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
> -		mlx5e_free_rx_fragmented_mpwqe(rq, &rq->wqe_info[wq->head]);
> +		mlx5e_free_rx_mpwqe(rq, &rq->wqe_info[wq->head]);
>  
>  	while (!mlx5_wq_ll_is_empty(wq)) {
>  		wqe_ix_be = *wq->tail_next;
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index b6f8ebb..8ad4d32 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -200,7 +200,6 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
>  
>  	*((dma_addr_t *)skb->cb) = dma_addr;
>  	wqe->data.addr = cpu_to_be64(dma_addr);
> -	wqe->data.lkey = rq->mkey_be;
>  
>  	rq->skb[ix] = skb;
>  
> @@ -231,44 +230,11 @@ static inline int mlx5e_mpwqe_strides_per_page(struct mlx5e_rq *rq)
>  	return rq->mpwqe_num_strides >> MLX5_MPWRQ_WQE_PAGE_ORDER;
>  }
>  
> -static inline void
> -mlx5e_dma_pre_sync_linear_mpwqe(struct device *pdev,
> -				struct mlx5e_mpw_info *wi,
> -				u32 wqe_offset, u32 len)
> -{
> -	dma_sync_single_for_cpu(pdev, wi->dma_info.addr + wqe_offset,
> -				len, DMA_FROM_DEVICE);
> -}
> -
> -static inline void
> -mlx5e_dma_pre_sync_fragmented_mpwqe(struct device *pdev,
> -				    struct mlx5e_mpw_info *wi,
> -				    u32 wqe_offset, u32 len)
> -{
> -	/* No dma pre sync for fragmented MPWQE */
> -}
> -
> -static inline void
> -mlx5e_add_skb_frag_linear_mpwqe(struct mlx5e_rq *rq,
> -				struct sk_buff *skb,
> -				struct mlx5e_mpw_info *wi,
> -				u32 page_idx, u32 frag_offset,
> -				u32 len)
> -{
> -	unsigned int truesize =	ALIGN(len, rq->mpwqe_stride_sz);
> -
> -	wi->skbs_frags[page_idx]++;
> -	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
> -			&wi->dma_info.page[page_idx], frag_offset,
> -			len, truesize);
> -}
> -
> -static inline void
> -mlx5e_add_skb_frag_fragmented_mpwqe(struct mlx5e_rq *rq,
> -				    struct sk_buff *skb,
> -				    struct mlx5e_mpw_info *wi,
> -				    u32 page_idx, u32 frag_offset,
> -				    u32 len)
> +static inline void mlx5e_add_skb_frag_mpwqe(struct mlx5e_rq *rq,
> +					    struct sk_buff *skb,
> +					    struct mlx5e_mpw_info *wi,
> +					    u32 page_idx, u32 frag_offset,
> +					    u32 len)
>  {
>  	unsigned int truesize =	ALIGN(len, rq->mpwqe_stride_sz);
>  
> @@ -282,24 +248,11 @@ mlx5e_add_skb_frag_fragmented_mpwqe(struct mlx5e_rq *rq,
>  }
>  
>  static inline void
> -mlx5e_copy_skb_header_linear_mpwqe(struct device *pdev,
> -				   struct sk_buff *skb,
> -				   struct mlx5e_mpw_info *wi,
> -				   u32 page_idx, u32 offset,
> -				   u32 headlen)
> -{
> -	struct page *page = &wi->dma_info.page[page_idx];
> -
> -	skb_copy_to_linear_data(skb, page_address(page) + offset,
> -				ALIGN(headlen, sizeof(long)));
> -}
> -
> -static inline void
> -mlx5e_copy_skb_header_fragmented_mpwqe(struct device *pdev,
> -				       struct sk_buff *skb,
> -				       struct mlx5e_mpw_info *wi,
> -				       u32 page_idx, u32 offset,
> -				       u32 headlen)
> +mlx5e_copy_skb_header_mpwqe(struct device *pdev,
> +			    struct sk_buff *skb,
> +			    struct mlx5e_mpw_info *wi,
> +			    u32 page_idx, u32 offset,
> +			    u32 headlen)
>  {
>  	u16 headlen_pg = min_t(u32, headlen, PAGE_SIZE - offset);
>  	struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[page_idx];
> @@ -324,46 +277,9 @@ mlx5e_copy_skb_header_fragmented_mpwqe(struct device *pdev,
>  	}
>  }
>  
> -static u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
> -{
> -	return rq->mpwqe_mtt_offset +
> -		wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
> -}
> -
> -static void mlx5e_build_umr_wqe(struct mlx5e_rq *rq,
> -				struct mlx5e_sq *sq,
> -				struct mlx5e_umr_wqe *wqe,
> -				u16 ix)
> +static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
>  {
> -	struct mlx5_wqe_ctrl_seg      *cseg = &wqe->ctrl;
> -	struct mlx5_wqe_umr_ctrl_seg *ucseg = &wqe->uctrl;
> -	struct mlx5_wqe_data_seg      *dseg = &wqe->data;
>  	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> -	u8 ds_cnt = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_DS);
> -	u32 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq, ix);
> -
> -	memset(wqe, 0, sizeof(*wqe));
> -	cseg->opmod_idx_opcode =
> -		cpu_to_be32((sq->pc << MLX5_WQE_CTRL_WQE_INDEX_SHIFT) |
> -			    MLX5_OPCODE_UMR);
> -	cseg->qpn_ds    = cpu_to_be32((sq->sqn << MLX5_WQE_CTRL_QPN_SHIFT) |
> -				      ds_cnt);
> -	cseg->fm_ce_se  = MLX5_WQE_CTRL_CQ_UPDATE;
> -	cseg->imm       = rq->umr_mkey_be;
> -
> -	ucseg->flags = MLX5_UMR_TRANSLATION_OFFSET_EN;
> -	ucseg->klm_octowords =
> -		cpu_to_be16(MLX5_MTT_OCTW(MLX5_MPWRQ_PAGES_PER_WQE));
> -	ucseg->bsf_octowords =
> -		cpu_to_be16(MLX5_MTT_OCTW(umr_wqe_mtt_offset));
> -	ucseg->mkey_mask     = cpu_to_be64(MLX5_MKEY_MASK_FREE);
> -
> -	dseg->lkey = sq->mkey_be;
> -	dseg->addr = cpu_to_be64(wi->umr.mtt_addr);
> -}
> -
> -static void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
> -{
>  	struct mlx5e_sq *sq = &rq->channel->icosq;
>  	struct mlx5_wq_cyc *wq = &sq->wq;
>  	struct mlx5e_umr_wqe *wqe;
> @@ -378,30 +294,22 @@ static void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
>  	}
>  
>  	wqe = mlx5_wq_cyc_get_wqe(wq, pi);
> -	mlx5e_build_umr_wqe(rq, sq, wqe, ix);
> +	memcpy(wqe, &wi->umr.wqe, sizeof(*wqe));
> +	wqe->ctrl.opmod_idx_opcode =
> +		cpu_to_be32((sq->pc << MLX5_WQE_CTRL_WQE_INDEX_SHIFT) |
> +			    MLX5_OPCODE_UMR);
> +
>  	sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_UMR;
>  	sq->ico_wqe_info[pi].num_wqebbs = num_wqebbs;
>  	sq->pc += num_wqebbs;
>  	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
>  }
>  
> -static inline int mlx5e_get_wqe_mtt_sz(void)
> -{
> -	/* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
> -	 * To avoid copying garbage after the mtt array, we allocate
> -	 * a little more.
> -	 */
> -	return ALIGN(MLX5_MPWRQ_PAGES_PER_WQE * sizeof(__be64),
> -		     MLX5_UMR_MTT_ALIGNMENT);
> -}
> -
> -static int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
> -				    struct mlx5e_mpw_info *wi,
> -				    int i)
> +static inline int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
> +					   struct mlx5e_mpw_info *wi,
> +					   int i)
>  {
> -	struct page *page;
> -
> -	page = dev_alloc_page();
> +	struct page *page = dev_alloc_page();
>  	if (unlikely(!page))
>  		return -ENOMEM;
>  
> @@ -417,47 +325,25 @@ static int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
>  	return 0;
>  }
>  
> -static int mlx5e_alloc_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
> -					   struct mlx5e_rx_wqe *wqe,
> -					   u16 ix)
> +static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
> +				    struct mlx5e_rx_wqe *wqe,
> +				    u16 ix)
>  {
>  	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> -	int mtt_sz = mlx5e_get_wqe_mtt_sz();
>  	u64 dma_offset = (u64)mlx5e_get_wqe_mtt_offset(rq, ix) << PAGE_SHIFT;
> +	int pg_strides = mlx5e_mpwqe_strides_per_page(rq);
> +	int err;
>  	int i;
>  
> -	wi->umr.dma_info = kmalloc(sizeof(*wi->umr.dma_info) *
> -				   MLX5_MPWRQ_PAGES_PER_WQE,
> -				   GFP_ATOMIC);
> -	if (unlikely(!wi->umr.dma_info))
> -		goto err_out;
> -
> -	/* We allocate more than mtt_sz as we will align the pointer */
> -	wi->umr.mtt_no_align = kzalloc(mtt_sz + MLX5_UMR_ALIGN - 1,
> -				       GFP_ATOMIC);
> -	if (unlikely(!wi->umr.mtt_no_align))
> -		goto err_free_umr;
> -
> -	wi->umr.mtt = PTR_ALIGN(wi->umr.mtt_no_align, MLX5_UMR_ALIGN);
> -	wi->umr.mtt_addr = dma_map_single(rq->pdev, wi->umr.mtt, mtt_sz,
> -					  PCI_DMA_TODEVICE);
> -	if (unlikely(dma_mapping_error(rq->pdev, wi->umr.mtt_addr)))
> -		goto err_free_mtt;
> -
>  	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
> -		if (unlikely(mlx5e_alloc_and_map_page(rq, wi, i)))
> +		err = mlx5e_alloc_and_map_page(rq, wi, i);
> +		if (unlikely(err))
>  			goto err_unmap;
> -		page_ref_add(wi->umr.dma_info[i].page,
> -			     mlx5e_mpwqe_strides_per_page(rq));
> +		page_ref_add(wi->umr.dma_info[i].page, pg_strides);
>  		wi->skbs_frags[i] = 0;
>  	}
>  
>  	wi->consumed_strides = 0;
> -	wi->dma_pre_sync = mlx5e_dma_pre_sync_fragmented_mpwqe;
> -	wi->add_skb_frag = mlx5e_add_skb_frag_fragmented_mpwqe;
> -	wi->copy_skb_header = mlx5e_copy_skb_header_fragmented_mpwqe;
> -	wi->free_wqe     = mlx5e_free_rx_fragmented_mpwqe;
> -	wqe->data.lkey = rq->umr_mkey_be;
>  	wqe->data.addr = cpu_to_be64(dma_offset);
>  
>  	return 0;
> @@ -466,41 +352,28 @@ err_unmap:
>  	while (--i >= 0) {
>  		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
>  			       PCI_DMA_FROMDEVICE);
> -		page_ref_sub(wi->umr.dma_info[i].page,
> -			     mlx5e_mpwqe_strides_per_page(rq));
> +		page_ref_sub(wi->umr.dma_info[i].page, pg_strides);
>  		put_page(wi->umr.dma_info[i].page);
>  	}
> -	dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz, PCI_DMA_TODEVICE);
> -
> -err_free_mtt:
> -	kfree(wi->umr.mtt_no_align);
> -
> -err_free_umr:
> -	kfree(wi->umr.dma_info);
>  
> -err_out:
> -	return -ENOMEM;
> +	return err;
>  }
>  
> -void mlx5e_free_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
> -				    struct mlx5e_mpw_info *wi)
> +void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi)
>  {
> -	int mtt_sz = mlx5e_get_wqe_mtt_sz();
> +	int pg_strides = mlx5e_mpwqe_strides_per_page(rq);
>  	int i;
>  
>  	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
>  		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
>  			       PCI_DMA_FROMDEVICE);
>  		page_ref_sub(wi->umr.dma_info[i].page,
> -			mlx5e_mpwqe_strides_per_page(rq) - wi->skbs_frags[i]);
> +			     pg_strides - wi->skbs_frags[i]);
>  		put_page(wi->umr.dma_info[i].page);
>  	}
> -	dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz, PCI_DMA_TODEVICE);
> -	kfree(wi->umr.mtt_no_align);
> -	kfree(wi->umr.dma_info);
>  }
>  
> -void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq)
> +void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
>  {
>  	struct mlx5_wq_ll *wq = &rq->wq;
>  	struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
> @@ -508,12 +381,11 @@ void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq)
>  	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
>  
>  	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state))) {
> -		mlx5e_free_rx_fragmented_mpwqe(rq, &rq->wqe_info[wq->head]);
> +		mlx5e_free_rx_mpwqe(rq, &rq->wqe_info[wq->head]);
>  		return;
>  	}
>  
>  	mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
> -	rq->stats.mpwqe_frag++;
>  
>  	/* ensure wqes are visible to device before updating doorbell record */
>  	dma_wmb();
> @@ -521,84 +393,23 @@ void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq)
>  	mlx5_wq_ll_update_db_record(wq);
>  }
>  
> -static int mlx5e_alloc_rx_linear_mpwqe(struct mlx5e_rq *rq,
> -				       struct mlx5e_rx_wqe *wqe,
> -				       u16 ix)
> -{
> -	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
> -	gfp_t gfp_mask;
> -	int i;
> -
> -	gfp_mask = GFP_ATOMIC | __GFP_COLD | __GFP_MEMALLOC;
> -	wi->dma_info.page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
> -					     MLX5_MPWRQ_WQE_PAGE_ORDER);
> -	if (unlikely(!wi->dma_info.page))
> -		return -ENOMEM;
> -
> -	wi->dma_info.addr = dma_map_page(rq->pdev, wi->dma_info.page, 0,
> -					 rq->wqe_sz, PCI_DMA_FROMDEVICE);
> -	if (unlikely(dma_mapping_error(rq->pdev, wi->dma_info.addr))) {
> -		put_page(wi->dma_info.page);
> -		return -ENOMEM;
> -	}
> -
> -	/* We split the high-order page into order-0 ones and manage their
> -	 * reference counter to minimize the memory held by small skb fragments
> -	 */
> -	split_page(wi->dma_info.page, MLX5_MPWRQ_WQE_PAGE_ORDER);
> -	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
> -		page_ref_add(&wi->dma_info.page[i],
> -			     mlx5e_mpwqe_strides_per_page(rq));
> -		wi->skbs_frags[i] = 0;
> -	}
> -
> -	wi->consumed_strides = 0;
> -	wi->dma_pre_sync = mlx5e_dma_pre_sync_linear_mpwqe;
> -	wi->add_skb_frag = mlx5e_add_skb_frag_linear_mpwqe;
> -	wi->copy_skb_header = mlx5e_copy_skb_header_linear_mpwqe;
> -	wi->free_wqe     = mlx5e_free_rx_linear_mpwqe;
> -	wqe->data.lkey = rq->mkey_be;
> -	wqe->data.addr = cpu_to_be64(wi->dma_info.addr);
> -
> -	return 0;
> -}
> -
> -void mlx5e_free_rx_linear_mpwqe(struct mlx5e_rq *rq,
> -				struct mlx5e_mpw_info *wi)
> -{
> -	int i;
> -
> -	dma_unmap_page(rq->pdev, wi->dma_info.addr, rq->wqe_sz,
> -		       PCI_DMA_FROMDEVICE);
> -	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
> -		page_ref_sub(&wi->dma_info.page[i],
> -			mlx5e_mpwqe_strides_per_page(rq) - wi->skbs_frags[i]);
> -		put_page(&wi->dma_info.page[i]);
> -	}
> -}
> -
> -int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
> +int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,	u16 ix)
>  {
>  	int err;
>  
> -	err = mlx5e_alloc_rx_linear_mpwqe(rq, wqe, ix);
> -	if (unlikely(err)) {
> -		err = mlx5e_alloc_rx_fragmented_mpwqe(rq, wqe, ix);
> -		if (unlikely(err))
> -			return err;
> -		set_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
> -		mlx5e_post_umr_wqe(rq, ix);
> -		return -EBUSY;
> -	}
> -
> -	return 0;
> +	err = mlx5e_alloc_rx_umr_mpwqe(rq, wqe, ix);
> +	if (unlikely(err))
> +		return err;
> +	set_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
> +	mlx5e_post_umr_wqe(rq, ix);
> +	return -EBUSY;
>  }
>  
>  void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
>  {
>  	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
>  
> -	wi->free_wqe(rq, wi);
> +	mlx5e_free_rx_mpwqe(rq, wi);
>  }
>  
>  #define RQ_CANNOT_POST(rq) \
> @@ -617,9 +428,10 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
>  		int err;
>  
>  		err = rq->alloc_wqe(rq, wqe, wq->head);
> +		if (err == -EBUSY)
> +			return true;
>  		if (unlikely(err)) {
> -			if (err != -EBUSY)
> -				rq->stats.buff_alloc_err++;
> +			rq->stats.buff_alloc_err++;
>  			break;
>  		}
>  
> @@ -823,7 +635,6 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
>  					   u32 cqe_bcnt,
>  					   struct sk_buff *skb)
>  {
> -	u32 consumed_bytes = ALIGN(cqe_bcnt, rq->mpwqe_stride_sz);
>  	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
>  	u32 wqe_offset     = stride_ix * rq->mpwqe_stride_sz;
>  	u32 head_offset    = wqe_offset & (PAGE_SIZE - 1);
> @@ -837,21 +648,20 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
>  		page_idx++;
>  		frag_offset -= PAGE_SIZE;
>  	}
> -	wi->dma_pre_sync(rq->pdev, wi, wqe_offset, consumed_bytes);
>  
>  	while (byte_cnt) {
>  		u32 pg_consumed_bytes =
>  			min_t(u32, PAGE_SIZE - frag_offset, byte_cnt);
>  
> -		wi->add_skb_frag(rq, skb, wi, page_idx, frag_offset,
> -				 pg_consumed_bytes);
> +		mlx5e_add_skb_frag_mpwqe(rq, skb, wi, page_idx, frag_offset,
> +					 pg_consumed_bytes);
>  		byte_cnt -= pg_consumed_bytes;
>  		frag_offset = 0;
>  		page_idx++;
>  	}
>  	/* copy header */
> -	wi->copy_skb_header(rq->pdev, skb, wi, head_page_idx, head_offset,
> -			    headlen);
> +	mlx5e_copy_skb_header_mpwqe(rq->pdev, skb, wi, head_page_idx,
> +				    head_offset, headlen);
>  	/* skb linear part was allocated with headlen and aligned to long */
>  	skb->tail += headlen;
>  	skb->len  += headlen;
> @@ -896,7 +706,7 @@ mpwrq_cqe_out:
>  	if (likely(wi->consumed_strides < rq->mpwqe_num_strides))
>  		return;
>  
> -	wi->free_wqe(rq, wi);
> +	mlx5e_free_rx_mpwqe(rq, wi);
>  	mlx5_wq_ll_pop(&rq->wq, cqe->wqe_id, &wqe->next.next_wqe_index);
>  }
>  
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> index 499487c..1f56543 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
> @@ -73,7 +73,6 @@ struct mlx5e_sw_stats {
>  	u64 tx_xmit_more;
>  	u64 rx_wqe_err;
>  	u64 rx_mpwqe_filler;
> -	u64 rx_mpwqe_frag;
>  	u64 rx_buff_alloc_err;
>  	u64 rx_cqe_compress_blks;
>  	u64 rx_cqe_compress_pkts;
> @@ -105,7 +104,6 @@ static const struct counter_desc sw_stats_desc[] = {
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_xmit_more) },
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_wqe_err) },
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
> -	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_frag) },
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_blks) },
>  	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_pkts) },
> @@ -274,7 +272,6 @@ struct mlx5e_rq_stats {
>  	u64 lro_bytes;
>  	u64 wqe_err;
>  	u64 mpwqe_filler;
> -	u64 mpwqe_frag;
>  	u64 buff_alloc_err;
>  	u64 cqe_compress_blks;
>  	u64 cqe_compress_pkts;
> @@ -290,7 +287,6 @@ static const struct counter_desc rq_stats_desc[] = {
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_bytes) },
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, wqe_err) },
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, mpwqe_filler) },
> -	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, mpwqe_frag) },
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, buff_alloc_err) },
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_blks) },
>  	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_pkts) },
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
> index 9bf33bb..08d8b0c 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
> @@ -87,7 +87,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
>  		case MLX5_OPCODE_NOP:
>  			break;
>  		case MLX5_OPCODE_UMR:
> -			mlx5e_post_rx_fragmented_mpwqe(&sq->channel->rq);
> +			mlx5e_post_rx_mpwqe(&sq->channel->rq);
>  			break;
>  		default:
>  			WARN_ONCE(true,



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
