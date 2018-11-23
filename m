Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD246B31F7
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:23:11 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a19so2378564otq.1
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:23:11 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w202si14016440oif.241.2018.11.23.09.23.09
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 09:23:09 -0800 (PST)
Subject: Re: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
References: <20181115154950.GA27985@jordon-HP-15-Notebook-PC>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <bbad42cb-4a76-a7e7-c385-db77f1cc588b@arm.com>
Date: Fri, 23 Nov 2018 17:23:06 +0000
MIME-Version: 1.0
In-Reply-To: <20181115154950.GA27985@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, joro@8bytes.org
Cc: linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On 15/11/2018 15:49, Souptick Joarder wrote:
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> ---
>   drivers/iommu/dma-iommu.c | 12 ++----------
>   1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d1b0475..69c66b1 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -622,17 +622,9 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>   
>   int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
>   {
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
> +	return vm_insert_range(vma, vma->vm_start, pages, count);

AFIACS, vm_insert_range() doesn't respect vma->vm_pgoff, so doesn't this 
break partial mmap()s of a large buffer? (which I believe can be a thing)

Robin.

>   }
>   
>   static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
> 
