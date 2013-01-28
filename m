Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 4D2AD6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:39:45 -0500 (EST)
Date: Mon, 28 Jan 2013 12:39:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] staging: zsmalloc: add gfp flags to zs_create_pool
Message-ID: <20130128033944.GB3321@blaptop>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Seth,

On Fri, Jan 25, 2013 at 11:46:15AM -0600, Seth Jennings wrote:
> zs_create_pool() currently takes a gfp flags argument
> that is used when growing the memory pool.  However
> it is not used in allocating the metadata for the pool
> itself.  That is currently hardcoded to GFP_KERNEL.
> 
> zswap calls zs_create_pool() at swapon time which is done
> in atomic context, resulting in a "might sleep" warning.
> 
> This patch changes the meaning of the flags argument in
> zs_create_pool() to mean the flags for the metadata allocation,
> and adds a flags argument to zs_malloc that will be used for
> memory pool growth if required.

As I mentioned, I'm not strongly against with this patch but it
should be last resort in case of not being able to address
frontswap's init routine's dependency with swap_lock.

I sent a patch and am waiting reply of Konrand or Dan.
If we can fix frontswap, it would be better rather than
changing zsmalloc.

> 
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zram/zram_drv.c          |    4 ++--
>  drivers/staging/zsmalloc/zsmalloc-main.c |    9 +++------
>  drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
>  3 files changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index 6762b99..836dccf 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -325,7 +325,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		clen = PAGE_SIZE;
>  	}
>  
> -	handle = zs_malloc(zram->mem_pool, clen);
> +	handle = zs_malloc(zram->mem_pool, clen, GFP_NOIO | __GFP_HIGHMEM);
>  	if (!handle) {
>  		pr_info("Error allocating memory for compressed "
>  			"page: %u, size=%zu\n", index, clen);
> @@ -565,7 +565,7 @@ int zram_init_device(struct zram *zram)
>  	/* zram devices sort of resembles non-rotational disks */
>  	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
>  
> -	zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
> +	zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
>  	if (!zram->mem_pool) {
>  		pr_err("Error creating memory pool\n");
>  		ret = -ENOMEM;
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index eb00772..f29f170 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -205,8 +205,6 @@ struct link_free {
>  
>  struct zs_pool {
>  	struct size_class size_class[ZS_SIZE_CLASSES];
> -
> -	gfp_t flags;	/* allocation flags used when growing pool */
>  	const char *name;
>  };
>  
> @@ -818,7 +816,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>  		return NULL;
>  
>  	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> -	pool = kzalloc(ovhd_size, GFP_KERNEL);
> +	pool = kzalloc(ovhd_size, flags);
>  	if (!pool)
>  		return NULL;
>  
> @@ -838,7 +836,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>  
>  	}
>  
> -	pool->flags = flags;
>  	pool->name = name;
>  
>  	return pool;
> @@ -874,7 +871,7 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
>   * otherwise 0.
>   * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
>   */
> -unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags)
>  {
>  	unsigned long obj;
>  	struct link_free *link;
> @@ -896,7 +893,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>  
>  	if (!first_page) {
>  		spin_unlock(&class->lock);
> -		first_page = alloc_zspage(class, pool->flags);
> +		first_page = alloc_zspage(class, flags);
>  		if (unlikely(!first_page))
>  			return 0;
>  
> diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
> index de2e8bf..907ff03 100644
> --- a/drivers/staging/zsmalloc/zsmalloc.h
> +++ b/drivers/staging/zsmalloc/zsmalloc.h
> @@ -31,7 +31,7 @@ struct zs_pool;
>  struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
>  void zs_destroy_pool(struct zs_pool *pool);
>  
> -unsigned long zs_malloc(struct zs_pool *pool, size_t size);
> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
>  void zs_free(struct zs_pool *pool, unsigned long obj);
>  
>  void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
