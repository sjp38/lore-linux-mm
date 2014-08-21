Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EA0666B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 14:54:19 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so9725736wgg.24
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 11:54:19 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id e13si10451609wik.12.2014.08.21.11.54.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 11:54:18 -0700 (PDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so8905918wiv.13
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 11:54:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408580838-29236-3-git-send-email-minchan@kernel.org>
References: <1408580838-29236-1-git-send-email-minchan@kernel.org> <1408580838-29236-3-git-send-email-minchan@kernel.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Aug 2014 14:53:57 -0400
Message-ID: <CALZtONBuZOORHAF0UHEZM7Aybuoesg3fyjnu9ACj_F7O5G35Og@mail.gmail.com>
Subject: Re: [PATCH v3 2/4] zsmalloc: change return value unit of zs_get_total_size_bytes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, David Horner <ds2horner@gmail.com>

On Wed, Aug 20, 2014 at 8:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> zs_get_total_size_bytes returns a amount of memory zsmalloc
> consumed with *byte unit* but zsmalloc operates *page unit*
> rather than byte unit so let's change the API so benefit
> we could get is that reduce unnecessary overhead
> (ie, change page unit with byte unit) in zsmalloc.
>
> Now, zswap can rollback to zswap_pool_pages.
> Over to zswap guys ;-)

We could change zpool/zswap over to total pages instead of total
bytes, since both zbud and zsmalloc now report size in pages.  The
only downside would be if either changed later to not use only whole
pages (or if they start using huge pages for storage...), but for what
they do that seems unlikely.  After this patch is finalized I can
write up a quick patch unless Seth disagrees (or already has a patch
:)

>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c |  4 ++--
>  include/linux/zsmalloc.h      |  2 +-
>  mm/zsmalloc.c                 | 10 +++++-----
>  3 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index d00831c3d731..302dd37bcea3 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -103,10 +103,10 @@ static ssize_t mem_used_total_show(struct device *dev,
>
>         down_read(&zram->init_lock);
>         if (init_done(zram))
> -               val = zs_get_total_size_bytes(meta->mem_pool);
> +               val = zs_get_total_size(meta->mem_pool);
>         up_read(&zram->init_lock);
>
> -       return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
>  }
>
>  static ssize_t max_comp_streams_show(struct device *dev,
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index e44d634e7fb7..105b56e45d23 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -46,6 +46,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>                         enum zs_mapmode mm);
>  void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
>
> -u64 zs_get_total_size_bytes(struct zs_pool *pool);
> +unsigned long zs_get_total_size(struct zs_pool *pool);

minor naming suggestion, but since the name is changing anyway,
"zs_get_total_size" implies to me the units are bytes, would
"zs_get_total_pages" be clearer that it's returning size in # of
pages, not bytes?

>
>  #endif
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index a65924255763..80408a1da03a 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -299,7 +299,7 @@ static void zs_zpool_unmap(void *pool, unsigned long handle)
>
>  static u64 zs_zpool_total_size(void *pool)
>  {
> -       return zs_get_total_size_bytes(pool);
> +       return zs_get_total_size(pool) << PAGE_SHIFT;
>  }
>
>  static struct zpool_driver zs_zpool_driver = {
> @@ -1186,16 +1186,16 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  }
>  EXPORT_SYMBOL_GPL(zs_unmap_object);
>
> -u64 zs_get_total_size_bytes(struct zs_pool *pool)
> +unsigned long zs_get_total_size(struct zs_pool *pool)
>  {
> -       u64 npages;
> +       unsigned long npages;
>
>         spin_lock(&pool->stat_lock);
>         npages = pool->pages_allocated;
>         spin_unlock(&pool->stat_lock);
> -       return npages << PAGE_SHIFT;
> +       return npages;
>  }
> -EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
> +EXPORT_SYMBOL_GPL(zs_get_total_size);
>
>  module_init(zs_init);
>  module_exit(zs_exit);
> --
> 2.0.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
