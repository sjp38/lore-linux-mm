Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC836B0038
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:01:25 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id fb4so6540114wid.5
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:01:24 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id bf5si11487296wjc.82.2014.09.24.07.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 07:01:23 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id t60so6284479wes.9
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:01:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411344191-2842-5-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org> <1411344191-2842-5-git-send-email-minchan@kernel.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 24 Sep 2014 10:01:03 -0400
Message-ID: <CALZtONB+NBMa8xf8xuAoeYHDoMtS56VLGP-a46LZgpppFyz7ag@mail.gmail.com>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Sun, Sep 21, 2014 at 8:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> This patch implement SWAP_FULL handler in zram so that VM can
> know whether zram is full or not and use it to stop anonymous
> page reclaim.
>
> How to judge fullness is below,
>
> fullness = (100 * used space / total space)
>
> It means the higher fullness is, the slower we reach zram full.
> Now, default of fullness is 80 so that it biased more momory
> consumption rather than early OOM kill.
>
> Above logic works only when used space of zram hit over the limit
> but zram also pretend to be full once 32 consecutive allocation
> fail happens. It's safe guard to prevent system hang caused by
> fragment uncertainty.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 60 ++++++++++++++++++++++++++++++++++++++++---
>  drivers/block/zram/zram_drv.h |  1 +
>  2 files changed, 57 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 22a37764c409..649cad9d0b1c 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
>  /* Module params (documentation at end) */
>  static unsigned int num_devices = 1;
>
> +/*
> + * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
> + * we regards it as zram-full. It means that the higher
> + * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
> + */
> +#define ZRAM_FULLNESS_PERCENT 80

As Andrew said, this (or the user-configurable fullness param from the
next patch) should have more detail about exactly why it's needed and
what it does.  The details of how zram considers itself "full" should
be clear, which probably includes explaining zsmalloc fragmentation.
It should be also clear this param only matters when limit_pages is
set, and this param is only checked when zsmalloc's total size has
reached that limit.

Also, since the next patch changes it to be used only as a default,
shouldn't it be DEFAULT_ZRAM_FULLNESS_PERCENT or similar?

> +
> +/*
> + * If zram fails to allocate memory consecutively up to this,
> + * we regard it as zram-full. It's safe guard to prevent too
> + * many swap write fail due to lack of fragmentation uncertainty.
> + */
> +#define ALLOC_FAIL_MAX 32
> +
>  #define ZRAM_ATTR_RO(name)                                             \
>  static ssize_t zram_attr_##name##_show(struct device *d,               \
>                                 struct device_attribute *attr, char *b) \
> @@ -148,6 +162,7 @@ static ssize_t mem_limit_store(struct device *dev,
>
>         down_write(&zram->init_lock);
>         zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
> +       atomic_set(&zram->alloc_fail, 0);
>         up_write(&zram->init_lock);
>
>         return len;
> @@ -410,6 +425,7 @@ static void zram_free_page(struct zram *zram, size_t index)
>         atomic64_sub(zram_get_obj_size(meta, index),
>                         &zram->stats.compr_data_size);
>         atomic64_dec(&zram->stats.pages_stored);
> +       atomic_set(&zram->alloc_fail, 0);
>
>         meta->table[index].handle = 0;
>         zram_set_obj_size(meta, index, 0);
> @@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>         }
>
>         alloced_pages = zs_get_total_pages(meta->mem_pool);
> -       if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> -               zs_free(meta->mem_pool, handle);
> -               ret = -ENOMEM;
> -               goto out;
> +       if (zram->limit_pages) {
> +               if (alloced_pages > zram->limit_pages) {
> +                       zs_free(meta->mem_pool, handle);
> +                       atomic_inc(&zram->alloc_fail);
> +                       ret = -ENOMEM;
> +                       goto out;
> +               } else {
> +                       atomic_set(&zram->alloc_fail, 0);
> +               }

So, with zram_full() checking for alloced_pages >= limit_pages, this
will need to be changed; the way it is now it prevents that from ever
being true.

Instead I believe this check has to be moved to before zs_malloc(), so
that alloced_pages > limit_pages is true.


>         }
>
>         update_used_max(zram, alloced_pages);
> @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>         down_write(&zram->init_lock);
>
>         zram->limit_pages = 0;
> +       atomic_set(&zram->alloc_fail, 0);
>
>         if (!init_done(zram)) {
>                 up_write(&zram->init_lock);
> @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
>         return 0;
>  }
>
> +static int zram_full(struct block_device *bdev, void *arg)
> +{
> +       struct zram *zram;
> +       struct zram_meta *meta;
> +       unsigned long total_pages, compr_pages;
> +
> +       zram = bdev->bd_disk->private_data;
> +       if (!zram->limit_pages)
> +               return 0;
> +
> +       meta = zram->meta;
> +       total_pages = zs_get_total_pages(meta->mem_pool);
> +
> +       if (total_pages >= zram->limit_pages) {
> +
> +               compr_pages = atomic64_read(&zram->stats.compr_data_size)
> +                                       >> PAGE_SHIFT;
> +               if ((100 * compr_pages / total_pages)
> +                       >= ZRAM_FULLNESS_PERCENT)
> +                       return 1;
> +       }
> +
> +       if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
> +               return 1;
> +
> +       return 0;
> +}
> +
>  static int zram_swap_hint(struct block_device *bdev,
>                                 unsigned int hint, void *arg)
>  {
> @@ -951,6 +1001,8 @@ static int zram_swap_hint(struct block_device *bdev,
>
>         if (hint == SWAP_FREE)
>                 ret = zram_slot_free_notify(bdev, (unsigned long)arg);
> +       else if (hint == SWAP_FULL)
> +               ret = zram_full(bdev, arg);
>
>         return ret;
>  }
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index c6ee271317f5..fcf3176a9f15 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -113,6 +113,7 @@ struct zram {
>         u64 disksize;   /* bytes */
>         int max_comp_streams;
>         struct zram_stats stats;
> +       atomic_t alloc_fail;
>         /*
>          * the number of pages zram can consume for storing compressed data
>          */
> --
> 2.0.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
