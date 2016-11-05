Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 718026B0266
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 15:39:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x190so33230755qkb.5
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 12:39:34 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id v54si11569856qtv.30.2016.11.05.12.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 12:39:33 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id x190so8405246qkb.0
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 12:39:33 -0700 (PDT)
Date: Sat, 5 Nov 2016 15:39:30 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [mm PATCH v2 03/26] swiotlb: Add support for
 DMA_ATTR_SKIP_CPU_SYNC
Message-ID: <20161105193929.GA26349@localhost.localdomain>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111252.79519.21950.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102111252.79519.21950.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

.. snip..
> @@ -561,6 +565,7 @@ void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
>  	 * First, sync the memory before unmapping the entry
>  	 */
>  	if (orig_addr != INVALID_PHYS_ADDR &&
> +	    !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
>  	    ((dir == DMA_FROM_DEVICE) || (dir == DMA_BIDIRECTIONAL)))
>  		swiotlb_bounce(orig_addr, tlb_addr, size, DMA_FROM_DEVICE);
>  
> @@ -654,7 +659,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>  		 * GFP_DMA memory; fall back on map_single(), which
>  		 * will grab memory from the lowest available address range.
>  		 */
> -		phys_addr_t paddr = map_single(hwdev, 0, size, DMA_FROM_DEVICE);
> +		phys_addr_t paddr = map_single(hwdev, 0, size,
> +					       DMA_FROM_DEVICE, 0);
>  		if (paddr == SWIOTLB_MAP_ERROR)
>  			goto err_warn;
>  
> @@ -669,7 +675,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>  
>  			/* DMA_TO_DEVICE to avoid memcpy in unmap_single */
>  			swiotlb_tbl_unmap_single(hwdev, paddr,
> -						 size, DMA_TO_DEVICE);
> +						 size, DMA_TO_DEVICE,
> +						 DMA_ATTR_SKIP_CPU_SYNC);

This I believe is redundant. That is swiotlb_tbl_unmap_single only
does an bounce if the dir is DMA_FROM_DEVICE or DMA_BIDIRECTIONAL.

I added /* optional. */
>  			goto err_warn;
>  		}
>  	}
> @@ -699,7 +706,7 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>  		free_pages((unsigned long)vaddr, get_order(size));
>  	else
>  		/* DMA_TO_DEVICE to avoid memcpy in swiotlb_tbl_unmap_single */
> -		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE);
> +		swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE, 0);

.. but here you choose to put 0? I changed that to
DMA_ATTR_SKIP_CPU_SYNC and expanded the comment above.

Time to test the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
