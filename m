Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 800656B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:09:40 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z190so179872192qkc.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:09:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i126si11033458ioe.6.2016.10.24.11.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:09:39 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:09:34 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next PATCH RFC 02/26] swiotlb: Add support for
 DMA_ATTR_SKIP_CPU_SYNC
Message-ID: <20161024180934.GA24840@char.us.oracle.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120437.16276.68349.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024120437.16276.68349.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, davem@davemloft.net

On Mon, Oct 24, 2016 at 08:04:37AM -0400, Alexander Duyck wrote:
> As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
> beyond just ARM I need to make it so that the swiotlb will respect the
> flag.  In order to do that I also need to update the swiotlb-xen since it
> heavily makes use of the functionality.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  drivers/xen/swiotlb-xen.c |   40 ++++++++++++++++++++++----------------
>  include/linux/swiotlb.h   |    6 ++++--
>  lib/swiotlb.c             |   48 +++++++++++++++++++++++++++------------------
>  3 files changed, 56 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
> index 87e6035..cf047d8 100644
> --- a/drivers/xen/swiotlb-xen.c
> +++ b/drivers/xen/swiotlb-xen.c
> @@ -405,7 +405,8 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>  	 */
>  	trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
>  
> -	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir);
> +	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir,
> +				     attrs);
>  	if (map == SWIOTLB_MAP_ERROR)
>  		return DMA_ERROR_CODE;
>  
> @@ -416,11 +417,13 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
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
> +	swiotlb_tbl_unmap_single(dev, map, size, dir,
> +				 attrs | DMA_ATTR_SKIP_CPU_SYNC);
> +
> +	return DMA_ERROR_CODE;

Why? This change (re-ordering the code - and returning DMA_ERROR_CODE instead
of 0) does not have anything to do with the title.

If you really feel strongly about it - then please send it as a seperate patch.
>  }
>  EXPORT_SYMBOL_GPL(xen_swiotlb_map_page);
>  
> @@ -444,7 +447,7 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
>  
>  	/* NOTE: We use dev_addr here, not paddr! */
>  	if (is_xen_swiotlb_buffer(dev_addr)) {
> -		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir);
> +		swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
>  		return;
>  	}
>  
> @@ -557,16 +560,9 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  								 start_dma_addr,
>  								 sg_phys(sg),
>  								 sg->length,
> -								 dir);
> -			if (map == SWIOTLB_MAP_ERROR) {
> -				dev_warn(hwdev, "swiotlb buffer is full\n");
> -				/* Don't panic here, we expect map_sg users
> -				   to do proper error handling. */
> -				xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
> -							   attrs);
> -				sg_dma_len(sgl) = 0;
> -				return 0;
> -			}
> +								 dir, attrs);
> +			if (map == SWIOTLB_MAP_ERROR)
> +				goto map_error;
>  			xen_dma_map_page(hwdev, pfn_to_page(map >> PAGE_SHIFT),
>  						dev_addr,
>  						map & ~PAGE_MASK,
> @@ -589,6 +585,16 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  		sg_dma_len(sg) = sg->length;
>  	}
>  	return nelems;
> +map_error:
> +	dev_warn(hwdev, "swiotlb buffer is full\n");
> +	/*
> +	 * Don't panic here, we expect map_sg users
> +	 * to do proper error handling.
> +	 */
> +	xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
> +				   attrs | DMA_ATTR_SKIP_CPU_SYNC);
> +	sg_dma_len(sgl) = 0;
> +	return 0;
>  }

This too. Why can't that be part of the existing code that was there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
