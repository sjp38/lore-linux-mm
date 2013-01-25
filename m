Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 3356F6B0008
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 19:09:32 -0500 (EST)
Received: by mail-ia0-f175.google.com with SMTP id r4so5605296iaj.6
        for <linux-mm@kvack.org>; Thu, 24 Jan 2013 16:09:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357590280-31535-3-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1357590280-31535-3-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Thu, 24 Jan 2013 16:09:31 -0800
Message-ID: <CAPkvG_eVwn4uOxrT8YUV31Ggcyx-A=z1L6RY2mH0W3MWU_ABxA@mail.gmail.com>
Subject: Re: [PATCHv2 2/9] staging: zsmalloc: remove unsed pool name
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jan 7, 2013 at 12:24 PM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> zs_create_pool() currently takes a name argument which is
> never used in any useful way.
>
> This patch removes it.
>
> Signed-off-by: Seth Jennnings <sjenning@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c     |    2 +-
>  drivers/staging/zram/zram_drv.c          |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |    7 +------
>  drivers/staging/zsmalloc/zsmalloc.h      |    2 +-
>  4 files changed, 4 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 674c754..6fa9f9a 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -982,7 +982,7 @@ int zcache_new_client(uint16_t cli_id)
>                 goto out;
>         cli->allocated = 1;
>  #ifdef CONFIG_FRONTSWAP
> -       cli->zspool = zs_create_pool("zcache", GFP_KERNEL);
> +       cli->zspool = zs_create_pool(GFP_KERNEL);
>         if (cli->zspool == NULL)
>                 goto out;
>         idr_init(&cli->tmem_pools);
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index 13e9b4b..13d9f6d 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -576,7 +576,7 @@ int zram_init_device(struct zram *zram)
>         /* zram devices sort of resembles non-rotational disks */
>         queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
>
> -       zram->mem_pool = zs_create_pool("zram", GFP_KERNEL);
> +       zram->mem_pool = zs_create_pool(GFP_KERNEL);
>         if (!zram->mem_pool) {
>                 pr_err("Error creating memory pool\n");
>                 ret = -ENOMEM;
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 6ff380e..5e212c0 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -796,14 +796,11 @@ fail:
>         return notifier_to_errno(ret);
>  }
>
> -struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
> +struct zs_pool *zs_create_pool(gfp_t flags)
>  {
>         int i, ovhd_size;
>         struct zs_pool *pool;
>
> -       if (!name)
> -               return NULL;
> -
>         ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
>         pool = kzalloc(ovhd_size, flags);
>         if (!pool)
> @@ -825,8 +822,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>
>         }
>
> -       pool->name = name;
> -
>         return pool;
>  }
>  EXPORT_SYMBOL_GPL(zs_create_pool);
> diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
> index 907ff03..25a4b4d 100644
> --- a/drivers/staging/zsmalloc/zsmalloc.h
> +++ b/drivers/staging/zsmalloc/zsmalloc.h
> @@ -28,7 +28,7 @@ enum zs_mapmode {
>
>  struct zs_pool;
>
> -struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
> +struct zs_pool *zs_create_pool(gfp_t flags);
>  void zs_destroy_pool(struct zs_pool *pool);
>
>  unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
> --
> 1.7.9.5
>

Acked-by: Nitin Gupta <ngupta@vflare.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
