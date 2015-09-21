Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 82C436B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 13:15:51 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so83484794igc.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:15:51 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id h127si17880728ioh.207.2015.09.21.10.15.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 10:15:50 -0700 (PDT)
Received: by iofh134 with SMTP id h134so127106923iof.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:15:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150916135347.149f550d51751c58c8b7ca96@gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com> <20150916135347.149f550d51751c58c8b7ca96@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 21 Sep 2015 13:15:10 -0400
Message-ID: <CALZtONCdTrsYa5HC15RVQCTDb3kG+2_-ECx7RsBxf7prhbw2AA@mail.gmail.com>
Subject: Re: [PATCH 2/2] zpool/zsmalloc/zbud: align on interfaces
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjennings@variantweb.net>

On Wed, Sep 16, 2015 at 7:53 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> As a preparation step for zram to be able to use common zpool API,
> there has to be some alignment done on it. This patch adds
> functions that correspond to zsmalloc-specific API to the common
> zpool API and takes care of the callbacks that have to be
> introduced, too.
>
> This version of the patch uses simplified 'compact' API/callbacks.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  drivers/block/zram/zram_drv.c |  4 ++--
>  include/linux/zpool.h         | 14 ++++++++++++++
>  include/linux/zsmalloc.h      |  8 ++------
>  mm/zbud.c                     | 12 ++++++++++++
>  mm/zpool.c                    | 21 +++++++++++++++++++++
>  mm/zsmalloc.c                 | 19 ++++++++++++++++---
>  6 files changed, 67 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9fa15bb..a0a786e 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -426,12 +426,12 @@ static ssize_t mm_stat_show(struct device *dev,
>                 struct device_attribute *attr, char *buf)
>  {
>         struct zram *zram = dev_to_zram(dev);
> -       struct zs_pool_stats pool_stats;
> +       struct zpool_stats pool_stats;
>         u64 orig_size, mem_used = 0;
>         long max_used;
>         ssize_t ret;
>
> -       memset(&pool_stats, 0x00, sizeof(struct zs_pool_stats));
> +       memset(&pool_stats, 0x00, sizeof(struct zpool_stats));
>
>         down_read(&zram->init_lock);
>         if (init_done(zram)) {

you don't need to change zram in this patch.  save this part for the
patch to update zram to use zpool.


> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> index 42f8ec9..a2a5bc4 100644
> --- a/include/linux/zpool.h
> +++ b/include/linux/zpool.h
> @@ -17,6 +17,11 @@ struct zpool_ops {
>         int (*evict)(struct zpool *pool, unsigned long handle);
>  };
>
> +struct zpool_stats {
> +       /* How many pages were migrated (freed) */
> +       unsigned long pages_compacted;
> +};
> +
>  /*
>   * Control how a handle is mapped.  It will be ignored if the
>   * implementation does not support it.  Its use is optional.
> @@ -58,6 +63,10 @@ void *zpool_map_handle(struct zpool *pool, unsigned long handle,
>
>  void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
>
> +unsigned long zpool_compact(struct zpool *pool);
> +
> +void zpool_stats(struct zpool *pool, struct zpool_stats *zstats);
> +
>  u64 zpool_get_total_size(struct zpool *pool);
>
>
> @@ -72,6 +81,8 @@ u64 zpool_get_total_size(struct zpool *pool);
>   * @shrink:    shrink the pool.
>   * @map:       map a handle.
>   * @unmap:     unmap a handle.
> + * @compact:   try to run compaction for the pool
> + * @stats:     get statistics for the pool
>   * @total_size:        get total size of a pool.
>   *
>   * This is created by a zpool implementation and registered
> @@ -98,6 +109,9 @@ struct zpool_driver {
>                                 enum zpool_mapmode mm);
>         void (*unmap)(void *pool, unsigned long handle);
>
> +       unsigned long (*compact)(void *pool);
> +       void (*stats)(void *pool, struct zpool_stats *stats);
> +
>         u64 (*total_size)(void *pool);
>  };
>
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index 6398dfa..5aee1c7 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -15,6 +15,7 @@
>  #define _ZS_MALLOC_H_
>
>  #include <linux/types.h>
> +#include <linux/zpool.h>
>
>  /*
>   * zsmalloc mapping modes
> @@ -34,11 +35,6 @@ enum zs_mapmode {
>          */
>  };
>
> -struct zs_pool_stats {
> -       /* How many pages were migrated (freed) */
> -       unsigned long pages_compacted;
> -};
> -
>  struct zs_pool;
>
>  struct zs_pool *zs_create_pool(char *name, gfp_t flags);
> @@ -54,5 +50,5 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
>  unsigned long zs_get_total_pages(struct zs_pool *pool);
>  unsigned long zs_compact(struct zs_pool *pool);
>
> -void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
> +void zs_pool_stats(struct zs_pool *pool, struct zpool_stats *stats);
>  #endif
> diff --git a/mm/zbud.c b/mm/zbud.c
> index ee8b5d6..23cfc76 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -193,6 +193,16 @@ static void zbud_zpool_unmap(void *pool, unsigned long handle)
>         zbud_unmap(pool, handle);
>  }
>
> +static unsigned long zbud_zpool_compact(void *pool)
> +{
> +       return 0;
> +}
> +
> +static void zbud_zpool_stats(void *pool, struct zpool_stats *stats)
> +{
> +       /* no-op */
> +}
> +
>  static u64 zbud_zpool_total_size(void *pool)
>  {
>         return zbud_get_pool_size(pool) * PAGE_SIZE;
> @@ -208,6 +218,8 @@ static struct zpool_driver zbud_zpool_driver = {
>         .shrink =       zbud_zpool_shrink,
>         .map =          zbud_zpool_map,
>         .unmap =        zbud_zpool_unmap,
> +       .compact =      zbud_zpool_compact,
> +       .stats =        zbud_zpool_stats,
>         .total_size =   zbud_zpool_total_size,
>  };
>
> diff --git a/mm/zpool.c b/mm/zpool.c
> index 8f670d3..d454f37 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -341,6 +341,27 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
>  }
>
>  /**
> + * zpool_compact() - try to run compaction over zpool
> + * @pool       The zpool to compact
> + *
> + * Returns: the number of migrated pages (0 if nothing happened)

don't say "nothing happened", 0 doesn't necessarily mean that.  0
means no pages were compacted.

> + */
> +unsigned long zpool_compact(struct zpool *zpool)
> +{
> +       return zpool->driver->compact(zpool->pool);
> +}
> +
> +/**
> + * zpool_stats() - obtain zpool statistics
> + * @pool       The zpool to get statistics for
> + * @zstats     stats to fill in

this doc needs more.  how is this function used?  what should the
caller expect in the zstats fields before and after the call?

for the common zpool interface, it might make more sense to just
include a direct function to access the pages_compacted, instead of
the indirect stats call.  If more stats get added in the future, the
call can be changed into a zpool_stats function.

> + */
> +void zpool_stats(struct zpool *zpool, struct zpool_stats *zstats)
> +{
> +       zpool->driver->stats(zpool->pool, zstats);
> +}
> +
> +/**
>   * zpool_get_total_size() - The total size of the pool
>   * @pool       The zpool to check
>   *
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index f135b1b..3ab0515 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -245,7 +245,7 @@ struct zs_pool {
>         gfp_t flags;    /* allocation flags used when growing pool */
>         atomic_long_t pages_allocated;
>
> -       struct zs_pool_stats stats;
> +       struct zpool_stats stats;

we haven't made zsmalloc completely dependent on zpool just yet :-)
this won't compile when CONFIG_ZPOOL isn't set.

leave this as a zs_pool_stats type and just handle the translation in
the zs_zpool_stats function call.

>
>         /* Compact classes */
>         struct shrinker shrinker;
> @@ -365,6 +365,17 @@ static void zs_zpool_unmap(void *pool, unsigned long handle)
>         zs_unmap_object(pool, handle);
>  }
>
> +static unsigned long zs_zpool_compact(void *pool)
> +{
> +       return zs_compact(pool);
> +}
> +
> +
> +static void zs_zpool_stats(void *pool, struct zpool_stats *stats)
> +{
> +       zs_pool_stats(pool, stats);
> +}
> +
>  static u64 zs_zpool_total_size(void *pool)
>  {
>         return zs_get_total_pages(pool) << PAGE_SHIFT;
> @@ -380,6 +391,8 @@ static struct zpool_driver zs_zpool_driver = {
>         .shrink =       zs_zpool_shrink,
>         .map =          zs_zpool_map,
>         .unmap =        zs_zpool_unmap,
> +       .compact =      zs_zpool_compact,
> +       .stats =        zs_zpool_stats,
>         .total_size =   zs_zpool_total_size,
>  };
>
> @@ -1789,9 +1802,9 @@ unsigned long zs_compact(struct zs_pool *pool)
>  }
>  EXPORT_SYMBOL_GPL(zs_compact);
>
> -void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
> +void zs_pool_stats(struct zs_pool *pool, struct zpool_stats *stats)
>  {
> -       memcpy(stats, &pool->stats, sizeof(struct zs_pool_stats));
> +       memcpy(stats, &pool->stats, sizeof(struct zpool_stats));
>  }
>  EXPORT_SYMBOL_GPL(zs_pool_stats);
>
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
