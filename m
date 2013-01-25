Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 6F3C96B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 19:08:06 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id n12so10767164oag.38
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 16:08:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Thu, 24 Jan 2013 16:08:05 -0800
Message-ID: <CAPkvG_c7z3Xj-Z-NkhRf5W1o=yNSNjpE5n3qio75YU5Jo3ie2A@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jan 7, 2013 at 12:24 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
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
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c     |    4 ++--
>  drivers/staging/zram/zram_drv.c          |    4 ++--
>  drivers/staging/zsmalloc/zsmalloc-main.c |    9 +++------
>  drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
>  4 files changed, 8 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 52b43b7..674c754 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -711,7 +711,7 @@ static unsigned long zv_create(struct zs_pool *pool, uint32_t pool_id,
>
>         BUG_ON(!irqs_disabled());
>         BUG_ON(chunks >= NCHUNKS);
> -       handle = zs_malloc(pool, size);
> +       handle = zs_malloc(pool, size, ZCACHE_GFP_MASK);
>         if (!handle)
>                 goto out;
>         atomic_inc(&zv_curr_dist_counts[chunks]);
> @@ -982,7 +982,7 @@ int zcache_new_client(uint16_t cli_id)
>                 goto out;
>         cli->allocated = 1;
>  #ifdef CONFIG_FRONTSWAP
> -       cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
> +       cli->zspool = zs_create_pool("zcache", GFP_KERNEL);
>         if (cli->zspool == NULL)
>                 goto out;
>         idr_init(&cli->tmem_pools);
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index fb4a7c9..13e9b4b 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -336,7 +336,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>                 clen = PAGE_SIZE;
>         }
>
> -       handle = zs_malloc(zram->mem_pool, clen);
> +       handle = zs_malloc(zram->mem_pool, clen, GFP_NOIO | __GFP_HIGHMEM);
>         if (!handle) {
>                 pr_info("Error allocating memory for compressed "
>                         "page: %u, size=%zu\n", index, clen);
> @@ -576,7 +576,7 @@ int zram_init_device(struct zram *zram)
>         /* zram devices sort of resembles non-rotational disks */
>         queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
>
> -       zram->mem_pool = zs_create_pool("zram", GFP_NOIO | __GFP_HIGHMEM);
> +       zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
>         if (!zram->mem_pool) {
>                 pr_err("Error creating memory pool\n");
>                 ret = -ENOMEM;
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 09a9d35..6ff380e 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -205,8 +205,6 @@ struct link_free {
>
>  struct zs_pool {
>         struct size_class size_class[ZS_SIZE_CLASSES];
> -
> -       gfp_t flags;    /* allocation flags used when growing pool */
>         const char *name;
>  };
>
> @@ -807,7 +805,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>                 return NULL;
>
>         ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
> -       pool = kzalloc(ovhd_size, GFP_KERNEL);
> +       pool = kzalloc(ovhd_size, flags);
>         if (!pool)
>                 return NULL;
>
> @@ -827,7 +825,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>
>         }
>
> -       pool->flags = flags;
>         pool->name = name;
>
>         return pool;
> @@ -863,7 +860,7 @@ EXPORT_SYMBOL_GPL(zs_destroy_pool);
>   * otherwise 0.
>   * Allocation requests with size > ZS_MAX_ALLOC_SIZE will fail.
>   */
> -unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> +unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags)
>  {
>         unsigned long obj;
>         struct link_free *link;
> @@ -885,7 +882,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>
>         if (!first_page) {
>                 spin_unlock(&class->lock);
> -               first_page = alloc_zspage(class, pool->flags);
> +               first_page = alloc_zspage(class, flags);
>                 if (unlikely(!first_page))
>                         return 0;
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


The additional of flags, especially for zs_create_pool seems not so
obvious so should be documented as function comment. Otherwise,
looks good to me.

Acked-by: Nitin Gupta <ngupta@vflare.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
