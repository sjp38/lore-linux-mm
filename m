Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17D506B7A69
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:13:10 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so336746plb.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:13:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r18si360491pls.115.2018.12.06.06.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 06:13:08 -0800 (PST)
Date: Thu, 6 Dec 2018 06:10:30 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/34] powerpc/dma: untangle vio_dma_mapping_ops from
 dma_iommu_ops
Message-ID: <20181206141030.GH29741@infradead.org>
References: <20181114082314.8965-1-hch@lst.de>
 <20181114082314.8965-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-9-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

ping?

On Wed, Nov 14, 2018 at 09:22:48AM +0100, Christoph Hellwig wrote:
> vio_dma_mapping_ops currently does a lot of indirect calls through
> dma_iommu_ops, which not only make the code harder to follow but are
> also expensive in the post-spectre world.  Unwind the indirect calls
> by calling the ppc_iommu_* or iommu_* APIs directly applicable, or
> just use the dma_iommu_* methods directly where we can.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/powerpc/include/asm/iommu.h     |  1 +
>  arch/powerpc/kernel/dma-iommu.c      |  2 +-
>  arch/powerpc/platforms/pseries/vio.c | 87 ++++++++++++----------------
>  3 files changed, 38 insertions(+), 52 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
> index 35db0cbc9222..75daa10f31a4 100644
> --- a/arch/powerpc/include/asm/iommu.h
> +++ b/arch/powerpc/include/asm/iommu.h
> @@ -242,6 +242,7 @@ static inline int __init tce_iommu_bus_notifier_init(void)
>  }
>  #endif /* !CONFIG_IOMMU_API */
>  
> +u64 dma_iommu_get_required_mask(struct device *dev);
>  int dma_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr);
>  
>  #else
> diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
> index 2ca6cfaebf65..0613278abf9f 100644
> --- a/arch/powerpc/kernel/dma-iommu.c
> +++ b/arch/powerpc/kernel/dma-iommu.c
> @@ -92,7 +92,7 @@ int dma_iommu_dma_supported(struct device *dev, u64 mask)
>  		return 1;
>  }
>  
> -static u64 dma_iommu_get_required_mask(struct device *dev)
> +u64 dma_iommu_get_required_mask(struct device *dev)
>  {
>  	struct iommu_table *tbl = get_iommu_table_base(dev);
>  	u64 mask;
> diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
> index 88f1ad1d6309..ea3a9745c812 100644
> --- a/arch/powerpc/platforms/pseries/vio.c
> +++ b/arch/powerpc/platforms/pseries/vio.c
> @@ -492,7 +492,9 @@ static void *vio_dma_iommu_alloc_coherent(struct device *dev, size_t size,
>  		return NULL;
>  	}
>  
> -	ret = dma_iommu_ops.alloc(dev, size, dma_handle, flag, attrs);
> +	ret = iommu_alloc_coherent(dev, get_iommu_table_base(dev), size,
> +				    dma_handle, dev->coherent_dma_mask, flag,
> +				    dev_to_node(dev));
>  	if (unlikely(ret == NULL)) {
>  		vio_cmo_dealloc(viodev, roundup(size, PAGE_SIZE));
>  		atomic_inc(&viodev->cmo.allocs_failed);
> @@ -507,8 +509,7 @@ static void vio_dma_iommu_free_coherent(struct device *dev, size_t size,
>  {
>  	struct vio_dev *viodev = to_vio_dev(dev);
>  
> -	dma_iommu_ops.free(dev, size, vaddr, dma_handle, attrs);
> -
> +	iommu_free_coherent(get_iommu_table_base(dev), size, vaddr, dma_handle);
>  	vio_cmo_dealloc(viodev, roundup(size, PAGE_SIZE));
>  }
>  
> @@ -518,22 +519,22 @@ static dma_addr_t vio_dma_iommu_map_page(struct device *dev, struct page *page,
>                                           unsigned long attrs)
>  {
>  	struct vio_dev *viodev = to_vio_dev(dev);
> -	struct iommu_table *tbl;
> +	struct iommu_table *tbl = get_iommu_table_base(dev);
>  	dma_addr_t ret = IOMMU_MAPPING_ERROR;
>  
> -	tbl = get_iommu_table_base(dev);
> -	if (vio_cmo_alloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)))) {
> -		atomic_inc(&viodev->cmo.allocs_failed);
> -		return ret;
> -	}
> -
> -	ret = dma_iommu_ops.map_page(dev, page, offset, size, direction, attrs);
> -	if (unlikely(dma_mapping_error(dev, ret))) {
> -		vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
> -		atomic_inc(&viodev->cmo.allocs_failed);
> -	}
> -
> +	if (vio_cmo_alloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl))))
> +		goto out_fail;
> +	ret = iommu_map_page(dev, tbl, page, offset, size, device_to_mask(dev),
> +			direction, attrs);
> +	if (unlikely(ret == IOMMU_MAPPING_ERROR))
> +		goto out_deallocate;
>  	return ret;
> +
> +out_deallocate:
> +	vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
> +out_fail:
> +	atomic_inc(&viodev->cmo.allocs_failed);
> +	return IOMMU_MAPPING_ERROR;
>  }
>  
>  static void vio_dma_iommu_unmap_page(struct device *dev, dma_addr_t dma_handle,
> @@ -542,11 +543,9 @@ static void vio_dma_iommu_unmap_page(struct device *dev, dma_addr_t dma_handle,
>  				     unsigned long attrs)
>  {
>  	struct vio_dev *viodev = to_vio_dev(dev);
> -	struct iommu_table *tbl;
> -
> -	tbl = get_iommu_table_base(dev);
> -	dma_iommu_ops.unmap_page(dev, dma_handle, size, direction, attrs);
> +	struct iommu_table *tbl = get_iommu_table_base(dev);
>  
> +	iommu_unmap_page(tbl, dma_handle, size, direction, attrs);
>  	vio_cmo_dealloc(viodev, roundup(size, IOMMU_PAGE_SIZE(tbl)));
>  }
>  
> @@ -555,34 +554,32 @@ static int vio_dma_iommu_map_sg(struct device *dev, struct scatterlist *sglist,
>                                  unsigned long attrs)
>  {
>  	struct vio_dev *viodev = to_vio_dev(dev);
> -	struct iommu_table *tbl;
> +	struct iommu_table *tbl = get_iommu_table_base(dev);
>  	struct scatterlist *sgl;
>  	int ret, count;
>  	size_t alloc_size = 0;
>  
> -	tbl = get_iommu_table_base(dev);
>  	for_each_sg(sglist, sgl, nelems, count)
>  		alloc_size += roundup(sgl->length, IOMMU_PAGE_SIZE(tbl));
>  
> -	if (vio_cmo_alloc(viodev, alloc_size)) {
> -		atomic_inc(&viodev->cmo.allocs_failed);
> -		return 0;
> -	}
> -
> -	ret = dma_iommu_ops.map_sg(dev, sglist, nelems, direction, attrs);
> -
> -	if (unlikely(!ret)) {
> -		vio_cmo_dealloc(viodev, alloc_size);
> -		atomic_inc(&viodev->cmo.allocs_failed);
> -		return ret;
> -	}
> +	if (vio_cmo_alloc(viodev, alloc_size))
> +		goto out_fail;
> +	ret = ppc_iommu_map_sg(dev, tbl, sglist, nelems, device_to_mask(dev),
> +			direction, attrs);
> +	if (unlikely(!ret))
> +		goto out_deallocate;
>  
>  	for_each_sg(sglist, sgl, ret, count)
>  		alloc_size -= roundup(sgl->dma_length, IOMMU_PAGE_SIZE(tbl));
>  	if (alloc_size)
>  		vio_cmo_dealloc(viodev, alloc_size);
> -
>  	return ret;
> +
> +out_deallocate:
> +	vio_cmo_dealloc(viodev, alloc_size);
> +out_fail:
> +	atomic_inc(&viodev->cmo.allocs_failed);
> +	return 0;
>  }
>  
>  static void vio_dma_iommu_unmap_sg(struct device *dev,
> @@ -591,30 +588,18 @@ static void vio_dma_iommu_unmap_sg(struct device *dev,
>  		unsigned long attrs)
>  {
>  	struct vio_dev *viodev = to_vio_dev(dev);
> -	struct iommu_table *tbl;
> +	struct iommu_table *tbl = get_iommu_table_base(dev);
>  	struct scatterlist *sgl;
>  	size_t alloc_size = 0;
>  	int count;
>  
> -	tbl = get_iommu_table_base(dev);
>  	for_each_sg(sglist, sgl, nelems, count)
>  		alloc_size += roundup(sgl->dma_length, IOMMU_PAGE_SIZE(tbl));
>  
> -	dma_iommu_ops.unmap_sg(dev, sglist, nelems, direction, attrs);
> -
> +	ppc_iommu_unmap_sg(tbl, sglist, nelems, direction, attrs);
>  	vio_cmo_dealloc(viodev, alloc_size);
>  }
>  
> -static int vio_dma_iommu_dma_supported(struct device *dev, u64 mask)
> -{
> -        return dma_iommu_ops.dma_supported(dev, mask);
> -}
> -
> -static u64 vio_dma_get_required_mask(struct device *dev)
> -{
> -        return dma_iommu_ops.get_required_mask(dev);
> -}
> -
>  static const struct dma_map_ops vio_dma_mapping_ops = {
>  	.alloc             = vio_dma_iommu_alloc_coherent,
>  	.free              = vio_dma_iommu_free_coherent,
> @@ -623,8 +608,8 @@ static const struct dma_map_ops vio_dma_mapping_ops = {
>  	.unmap_sg          = vio_dma_iommu_unmap_sg,
>  	.map_page          = vio_dma_iommu_map_page,
>  	.unmap_page        = vio_dma_iommu_unmap_page,
> -	.dma_supported     = vio_dma_iommu_dma_supported,
> -	.get_required_mask = vio_dma_get_required_mask,
> +	.dma_supported     = dma_iommu_mapping_error,
> +	.get_required_mask = dma_iommu_get_required_mask,
>  	.mapping_error	   = dma_iommu_mapping_error,
>  };
>  
> -- 
> 2.19.1
> 
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
