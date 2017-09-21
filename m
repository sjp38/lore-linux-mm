Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0506B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:11:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 93so9831949iol.2
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:11:29 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l191si909434oig.433.2017.09.21.04.11.28
        for <linux-mm@kvack.org>;
        Thu, 21 Sep 2017 04:11:28 -0700 (PDT)
Subject: Re: [PATCH 2/4] numa, iommu/io-pgtable-arm: Use NUMA aware memory
 allocation for smmu translation tables
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <20170921085922.11659-3-ganapatrao.kulkarni@cavium.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <37e3ce0e-717d-156d-fef3-27559aff980e@arm.com>
Date: Thu, 21 Sep 2017 12:11:23 +0100
MIME-Version: 1.0
In-Reply-To: <20170921085922.11659-3-ganapatrao.kulkarni@cavium.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Will.Deacon@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

On 21/09/17 09:59, Ganapatrao Kulkarni wrote:
> function __arm_lpae_alloc_pages is used to allcoated memory for smmu
> translation tables. updating function to allocate memory/pages
> from the proximity domain of SMMU device.

AFAICS, data->pgd_size always works out to a power-of-two number of
pages, so I'm not sure why we've ever needed alloc_pages_exact() here. I
think we could simply use alloc_pages_node() and drop patch #1.

Robin.

> Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
> ---
>  drivers/iommu/io-pgtable-arm.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/iommu/io-pgtable-arm.c b/drivers/iommu/io-pgtable-arm.c
> index e8018a3..f6d01f6 100644
> --- a/drivers/iommu/io-pgtable-arm.c
> +++ b/drivers/iommu/io-pgtable-arm.c
> @@ -215,8 +215,10 @@ static void *__arm_lpae_alloc_pages(size_t size, gfp_t gfp,
>  {
>  	struct device *dev = cfg->iommu_dev;
>  	dma_addr_t dma;
> -	void *pages = alloc_pages_exact(size, gfp | __GFP_ZERO);
> +	void *pages;
>  
> +	pages = alloc_pages_exact_nid(dev_to_node(dev), size,
> +			gfp | __GFP_ZERO);
>  	if (!pages)
>  		return NULL;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
