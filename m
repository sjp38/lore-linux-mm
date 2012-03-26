Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B4C876B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 07:38:43 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so7288967pbc.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 04:38:43 -0700 (PDT)
Message-ID: <4F70553B.2000100@gmail.com>
Date: Mon, 26 Mar 2012 17:08:35 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv7 5/9] ARM: dma-mapping: implement dma sg methods on top
 of any generic dma ops
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com> <1330527862-16234-6-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1330527862-16234-6-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Hi Marek,

As per our discussion over IRC, I would like to check with you the 
feasibility to extend the dma operation calls for the coherent regions. 
You said that since struct page wont be available for the buffers in 
these regions, functions like arm_dma_map_sg() (below) will fail in the 
cache maintenance operations. Infact, I am facing this issue when I 
integrated dma-buf buffer sharing + v4l2/vb2 exporter patch series + 
dma_mapping (v7) and use coherent memory.

So I want to know opinion of you, others about extending the dma-mapping 
framework for scenarios which use device coherent memory.

Regards,
Subash

On 02/29/2012 08:34 PM, Marek Szyprowski wrote:
> This patch converts all dma_sg methods to be generic (independent of the
> current DMA mapping implementation for ARM architecture). All dma sg
> operations are now implemented on top of respective
> dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.
>
> Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
> ---
>   arch/arm/mm/dma-mapping.c |   43 +++++++++++++++++++------------------------
>   1 files changed, 19 insertions(+), 24 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index cd5ed8d..a5a0b5b 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -616,7 +616,7 @@ void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
>   EXPORT_SYMBOL(___dma_page_dev_to_cpu);
>
>   /**
> - * dma_map_sg - map a set of SG buffers for streaming mode DMA
> + * arm_dma_map_sg - map a set of SG buffers for streaming mode DMA
>    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
>    * @sg: list of buffers
>    * @nents: number of buffers to map
> @@ -634,12 +634,13 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
>   int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>   		enum dma_data_direction dir, struct dma_attrs *attrs)
>   {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>   	struct scatterlist *s;
>   	int i, j;
>
>   	for_each_sg(sg, s, nents, i) {
> -		s->dma_address = __dma_map_page(dev, sg_page(s), s->offset,
> -						s->length, dir);
> +		s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
> +						s->length, dir, attrs);
>   		if (dma_mapping_error(dev, s->dma_address))
>   			goto bad_mapping;
>   	}
> @@ -647,12 +648,12 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>
>    bad_mapping:
>   	for_each_sg(sg, s, i, j)
> -		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
> +		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
>   	return 0;
>   }
>
>   /**
> - * dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
> + * arm_dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
>    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
>    * @sg: list of buffers
>    * @nents: number of buffers to unmap (same as was passed to dma_map_sg)
> @@ -664,15 +665,17 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>   void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
>   		enum dma_data_direction dir, struct dma_attrs *attrs)
>   {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>   	struct scatterlist *s;
> +
>   	int i;
>
>   	for_each_sg(sg, s, nents, i)
> -		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
> +		ops->unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir, attrs);
>   }
>
>   /**
> - * dma_sync_sg_for_cpu
> + * arm_dma_sync_sg_for_cpu
>    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
>    * @sg: list of buffers
>    * @nents: number of buffers to map (returned from dma_map_sg)
> @@ -681,21 +684,17 @@ void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
>   void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>   			int nents, enum dma_data_direction dir)
>   {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>   	struct scatterlist *s;
>   	int i;
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
>   }
>
>   /**
> - * dma_sync_sg_for_device
> + * arm_dma_sync_sg_for_device
>    * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
>    * @sg: list of buffers
>    * @nents: number of buffers to map (returned from dma_map_sg)
> @@ -704,17 +703,13 @@ void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>   void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
>   			int nents, enum dma_data_direction dir)
>   {
> +	struct dma_map_ops *ops = get_dma_ops(dev);
>   	struct scatterlist *s;
>   	int i;
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
>   }
>
>   /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
