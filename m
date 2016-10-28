Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id C53DD6B027B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 13:35:38 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id p22so118457498ywe.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 10:35:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u72si6886621itb.22.2016.10.28.10.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 10:35:38 -0700 (PDT)
Date: Fri, 28 Oct 2016 13:35:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next PATCH 02/27] swiotlb-xen: Enforce return of
 DMA_ERROR_CODE in mapping function
Message-ID: <20161028173511.GF5112@char.us.oracle.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
 <20161025153658.4815.84254.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025153658.4815.84254.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, davem@davemloft.net

On Tue, Oct 25, 2016 at 11:36:58AM -0400, Alexander Duyck wrote:
> The mapping function should always return DMA_ERROR_CODE when a mapping has
> failed as this is what the DMA API expects when a DMA error has occurred.
> The current function for mapping a page in Xen was returning either
> DMA_ERROR_CODE or 0 depending on where it failed.
> 
> On x86 DMA_ERROR_CODE is 0, but on other architectures such as ARM it is
> ~0. We need to make sure we return the same error value if either the
> mapping failed or the device is not capable of accessing the mapping.
> 
> If we are returning DMA_ERROR_CODE as our error value we can drop the
> function for checking the error code as the default is to compare the
> return value against DMA_ERROR_CODE if no function is defined.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

I am pretty sure I gave an Ack. Any particular reason from dropping it
(if so, please add a comment under the --- of the reason).

Thanks.
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/arm/xen/mm.c              |    1 -
>  arch/x86/xen/pci-swiotlb-xen.c |    1 -
>  drivers/xen/swiotlb-xen.c      |   18 ++++++------------
>  include/xen/swiotlb-xen.h      |    3 ---
>  4 files changed, 6 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
> index d062f08..bd62d94 100644
> --- a/arch/arm/xen/mm.c
> +++ b/arch/arm/xen/mm.c
> @@ -186,7 +186,6 @@ void xen_destroy_contiguous_region(phys_addr_t pstart, unsigned int order)
>  EXPORT_SYMBOL(xen_dma_ops);
>  
>  static struct dma_map_ops xen_swiotlb_dma_ops = {
> -	.mapping_error = xen_swiotlb_dma_mapping_error,
>  	.alloc = xen_swiotlb_alloc_coherent,
>  	.free = xen_swiotlb_free_coherent,
>  	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
> diff --git a/arch/x86/xen/pci-swiotlb-xen.c b/arch/x86/xen/pci-swiotlb-xen.c
> index 0e98e5d..a9fafb5 100644
> --- a/arch/x86/xen/pci-swiotlb-xen.c
> +++ b/arch/x86/xen/pci-swiotlb-xen.c
> @@ -19,7 +19,6 @@
>  int xen_swiotlb __read_mostly;
>  
>  static struct dma_map_ops xen_swiotlb_dma_ops = {
> -	.mapping_error = xen_swiotlb_dma_mapping_error,
>  	.alloc = xen_swiotlb_alloc_coherent,
>  	.free = xen_swiotlb_free_coherent,
>  	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
> diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
> index 87e6035..b8014bf 100644
> --- a/drivers/xen/swiotlb-xen.c
> +++ b/drivers/xen/swiotlb-xen.c
> @@ -416,11 +416,12 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>  	/*
>  	 * Ensure that the address returned is DMA'ble
>  	 */
> -	if (!dma_capable(dev, dev_addr, size)) {
> -		swiotlb_tbl_unmap_single(dev, map, size, dir);
> -		dev_addr = 0;
> -	}
> -	return dev_addr;
> +	if (dma_capable(dev, dev_addr, size))
> +		return dev_addr;
> +
> +	swiotlb_tbl_unmap_single(dev, map, size, dir);
> +
> +	return DMA_ERROR_CODE;
>  }
>  EXPORT_SYMBOL_GPL(xen_swiotlb_map_page);
>  
> @@ -648,13 +649,6 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  }
>  EXPORT_SYMBOL_GPL(xen_swiotlb_sync_sg_for_device);
>  
> -int
> -xen_swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
> -{
> -	return !dma_addr;
> -}
> -EXPORT_SYMBOL_GPL(xen_swiotlb_dma_mapping_error);
> -
>  /*
>   * Return whether the given device DMA address mask can be supported
>   * properly.  For example, if your device can only drive the low 24-bits
> diff --git a/include/xen/swiotlb-xen.h b/include/xen/swiotlb-xen.h
> index 7c35e27..a0083be 100644
> --- a/include/xen/swiotlb-xen.h
> +++ b/include/xen/swiotlb-xen.h
> @@ -51,9 +51,6 @@ extern void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  			       int nelems, enum dma_data_direction dir);
>  
>  extern int
> -xen_swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr);
> -
> -extern int
>  xen_swiotlb_dma_supported(struct device *hwdev, u64 mask);
>  
>  extern int
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
