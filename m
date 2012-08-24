Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6043F6B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 07:13:44 -0400 (EDT)
Date: Fri, 24 Aug 2012 07:13:23 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [v3 1/4] ARM: dma-mapping: atomic_pool with struct page **pages
Message-ID: <20120824111323.GB11007@konrad-lan.dumpdata.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
 <1345796945-21115-2-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345796945-21115-2-git-send-email-hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

On Fri, Aug 24, 2012 at 11:29:02AM +0300, Hiroshi Doyu wrote:
> struct page **pages is necessary to align with non atomic path in
> __iommu_get_pages(). atomic_pool() has the intialized **pages instead
> of just *page.
> 
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |   17 +++++++++++++----
>  1 files changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 601da7a..b14ee64 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -296,7 +296,7 @@ struct dma_pool {
>  	unsigned long *bitmap;
>  	unsigned long nr_pages;
>  	void *vaddr;
> -	struct page *page;
> +	struct page **pages;
>  };
>  
>  static struct dma_pool atomic_pool = {
> @@ -335,12 +335,16 @@ static int __init atomic_pool_init(void)
>  	unsigned long nr_pages = pool->size >> PAGE_SHIFT;
>  	unsigned long *bitmap;
>  	struct page *page;
> +	struct page **pages;
>  	void *ptr;
>  	int bitmap_size = BITS_TO_LONGS(nr_pages) * sizeof(long);
> +	size_t size = nr_pages * sizeof(struct page *);
>  
> -	bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> +	size += bitmap_size;
> +	bitmap = kzalloc(size, GFP_KERNEL);
>  	if (!bitmap)
>  		goto no_bitmap;
> +	pages = (void *)bitmap + bitmap_size;

So you stuck a bitmap field in front of the array then?
Why not just define a structure where this is clearly defined
instead of doing the casting.

>  
>  	if (IS_ENABLED(CONFIG_CMA))
>  		ptr = __alloc_from_contiguous(NULL, pool->size, prot, &page);
> @@ -348,9 +352,14 @@ static int __init atomic_pool_init(void)
>  		ptr = __alloc_remap_buffer(NULL, pool->size, GFP_KERNEL, prot,
>  					   &page, NULL);
>  	if (ptr) {
> +		int i;
> +
> +		for (i = 0; i < nr_pages; i++)
> +			pages[i] = page + i;
> +
>  		spin_lock_init(&pool->lock);
>  		pool->vaddr = ptr;
> -		pool->page = page;
> +		pool->pages = pages;
>  		pool->bitmap = bitmap;
>  		pool->nr_pages = nr_pages;
>  		pr_info("DMA: preallocated %u KiB pool for atomic coherent allocations\n",
> @@ -481,7 +490,7 @@ static void *__alloc_from_pool(size_t size, struct page **ret_page)
>  	if (pageno < pool->nr_pages) {
>  		bitmap_set(pool->bitmap, pageno, count);
>  		ptr = pool->vaddr + PAGE_SIZE * pageno;
> -		*ret_page = pool->page + pageno;
> +		*ret_page = pool->pages[pageno];
>  	} else {
>  		pr_err_once("ERROR: %u KiB atomic DMA coherent pool is too small!\n"
>  			    "Please increase it with coherent_pool= kernel parameter!\n",
> -- 
> 1.7.5.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
