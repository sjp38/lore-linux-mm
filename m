Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93C438E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 09:29:58 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so3944327wrd.23
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 06:29:58 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t18si12920042wrx.287.2018.12.24.06.29.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 06:29:56 -0800 (PST)
Date: Mon, 24 Dec 2018 14:29:27 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v5 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20181224142927.GZ26090@n2100.armlinux.org.uk>
References: <20181224132531.GA22150@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181224132531.GA22150@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, joro@8bytes.org, robin.murphy@arm.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 24, 2018 at 06:55:31PM +0530, Souptick Joarder wrote:
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> ---
>  drivers/iommu/dma-iommu.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d1b0475..de7ffd8 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -622,17 +622,10 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>  
>  int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
>  {
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -	int ret = -ENXIO;
> +	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
>  
> -	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> -		ret = vm_insert_page(vma, uaddr, pages[i]);
> -		if (ret)
> -			break;
> -		uaddr += PAGE_SIZE;
> -	}
> -	return ret;
> +	return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff,
> +				count - vma->vm_pgoff);

This introduces a new bug.

I'm not going to continue to point out in minute detail the mistakes
you are introducing, as I don't think that is helping you to learn.

Look at this closely, and see whether you can spot the mistake.
Specifically, compare the boundary conditions for the final page
that is to be inserted and the value returned by the original version
and by your version for different scenarios.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
