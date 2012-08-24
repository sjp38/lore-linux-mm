Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C39536B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 07:15:07 -0400 (EDT)
Date: Fri, 24 Aug 2012 07:14:55 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [v3 2/4] ARM: dma-mapping: Refactor out to introduce
 __in_atomic_pool
Message-ID: <20120824111455.GC11007@konrad-lan.dumpdata.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
 <1345796945-21115-3-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345796945-21115-3-git-send-email-hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

On Fri, Aug 24, 2012 at 11:29:03AM +0300, Hiroshi Doyu wrote:
> Check the given range("start", "size") is included in "atomic_pool" or not.
> 
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |   25 +++++++++++++++++++------
>  1 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index b14ee64..508fde1 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -501,19 +501,32 @@ static void *__alloc_from_pool(size_t size, struct page **ret_page)
>  	return ptr;
>  }
>  
> +static bool __in_atomic_pool(void *start, size_t size)
> +{
> +	struct dma_pool *pool = &atomic_pool;
> +	void *end = start + size;
> +	void *pool_start = pool->vaddr;
> +	void *pool_end = pool->vaddr + pool->size;
> +
> +	if (start < pool_start || start > pool_end)
> +		return false;
> +
> +	if (end > pool_end) {
> +		WARN(1, "freeing wrong coherent size from pool\n");

That does not tell what size or from what pool. Perhaps you should
include some details, such as the 'size' value, the pool used, the
range of the pool, etc. Something that will help _you_in the field
be able to narrow down what might be wrong.

> +		return false;
> +	}
> +
> +	return true;
> +}
> +
>  static int __free_from_pool(void *start, size_t size)
>  {
>  	struct dma_pool *pool = &atomic_pool;
>  	unsigned long pageno, count;
>  	unsigned long flags;
>  
> -	if (start < pool->vaddr || start > pool->vaddr + pool->size)
> -		return 0;
> -
> -	if (start + size > pool->vaddr + pool->size) {
> -		WARN(1, "freeing wrong coherent size from pool\n");
> +	if (!__in_atomic_pool(start, size))
>  		return 0;
> -	}
>  
>  	pageno = (start - pool->vaddr) >> PAGE_SHIFT;
>  	count = size >> PAGE_SHIFT;
> -- 
> 1.7.5.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
