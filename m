Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 5F4056B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 10:06:07 -0500 (EST)
Date: Tue, 14 Feb 2012 10:02:55 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv6 3/7] ARM: dma-mapping: implement dma sg methods on top
 of any generic dma ops
Message-ID: <20120214150255.GC18359@phenom.dumpdata.com>
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
 <1328900324-20946-4-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1328900324-20946-4-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Shariq Hasnain <shariq.hasnain@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Krishna Reddy <vdumpa@nvidia.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, KyongHo Cho <pullip.cho@samsung.com>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Fri, Feb 10, 2012 at 07:58:40PM +0100, Marek Szyprowski wrote:
> This patch converts all dma_sg methods to be generic (independent of the
> current DMA mapping implementation for ARM architecture). All dma sg
> operations are now implemented on top of respective
> dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.

Looks good, except the worry I've that the DMA debug API calls are now
lost.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  arch/arm/mm/dma-mapping.c |   35 +++++++++++++++--------------------
>  1 files changed, 15 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 91fe436..31ff699 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -635,12 +635,13 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
>  int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>  		enum dma_data_direction dir, struct dma_attrs *attrs)
>  {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>  	struct scatterlist *s;
>  	int i, j;
>  
>  	for_each_sg(sg, s, nents, i) {
> -		s->dma_address = __dma_map_page(dev, sg_page(s), s->offset,
> -						s->length, dir);
> +		s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
> +						s->length, dir, attrs);
>  		if (dma_mapping_error(dev, s->dma_address))
>  			goto bad_mapping;
>  	}
> @@ -648,7 +649,7 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>  
>   bad_mapping:
>  	for_each_sg(sg, s, i, j)
> -		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
> +		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
>  	return 0;
>  }
>  
> @@ -665,11 +666,13 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>  void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
>  		enum dma_data_direction dir, struct dma_attrs *attrs)
>  {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>  	struct scatterlist *s;
> +
>  	int i;
>  
>  	for_each_sg(sg, s, nents, i)
> -		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
> +		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
>  }
>  
>  /**
> @@ -682,17 +685,13 @@ void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
>  void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>  			int nents, enum dma_data_direction dir)
>  {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>  	struct scatterlist *s;
>  	int i;
>  
> -	for_each_sg(sg, s, nents, i) {
> -		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s),
> -					    sg_dma_len(s), dir))
> -			continue;
> -
> -		__dma_page_dev_to_cpu(sg_page(s), s->offset,
> -				      s->length, dir);
> -	}
> +	for_each_sg(sg, s, nents, i)
> +		ops->sync_single_for_cpu(dev, sg_dma_address(s), s->length,
> +					 dir);
>  }
>  
>  /**
> @@ -705,17 +704,13 @@ void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>  void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
>  			int nents, enum dma_data_direction dir)
>  {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>  	struct scatterlist *s;
>  	int i;
>  
> -	for_each_sg(sg, s, nents, i) {
> -		if (!dmabounce_sync_for_device(dev, sg_dma_address(s),
> -					sg_dma_len(s), dir))
> -			continue;
> -
> -		__dma_page_cpu_to_dev(sg_page(s), s->offset,
> -				      s->length, dir);
> -	}
> +	for_each_sg(sg, s, nents, i)
> +		ops->sync_single_for_device(dev, sg_dma_address(s), s->length,
> +					    dir);
>  }
>  
>  /*
> -- 
> 1.7.1.569.g6f426
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
