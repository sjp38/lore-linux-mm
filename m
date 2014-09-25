Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id ED09F6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 21:01:59 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so9592366pdj.4
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 18:01:59 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id nx16si953150pdb.101.2014.09.24.18.01.56
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 18:01:57 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:02:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-ID: <20140925010229.GA17364@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-5-git-send-email-minchan@kernel.org>
 <CALZtONB+NBMa8xf8xuAoeYHDoMtS56VLGP-a46LZgpppFyz7ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONB+NBMa8xf8xuAoeYHDoMtS56VLGP-a46LZgpppFyz7ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Wed, Sep 24, 2014 at 10:01:03AM -0400, Dan Streetman wrote:
> On Sun, Sep 21, 2014 at 8:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> > This patch implement SWAP_FULL handler in zram so that VM can
> > know whether zram is full or not and use it to stop anonymous
> > page reclaim.
> >
> > How to judge fullness is below,
> >
> > fullness = (100 * used space / total space)
> >
> > It means the higher fullness is, the slower we reach zram full.
> > Now, default of fullness is 80 so that it biased more momory
> > consumption rather than early OOM kill.
> >
> > Above logic works only when used space of zram hit over the limit
> > but zram also pretend to be full once 32 consecutive allocation
> > fail happens. It's safe guard to prevent system hang caused by
> > fragment uncertainty.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/zram_drv.c | 60 ++++++++++++++++++++++++++++++++++++++++---
> >  drivers/block/zram/zram_drv.h |  1 +
> >  2 files changed, 57 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 22a37764c409..649cad9d0b1c 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
> >  /* Module params (documentation at end) */
> >  static unsigned int num_devices = 1;
> >
> > +/*
> > + * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
> > + * we regards it as zram-full. It means that the higher
> > + * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
> > + */
> > +#define ZRAM_FULLNESS_PERCENT 80
> 
> As Andrew said, this (or the user-configurable fullness param from the
> next patch) should have more detail about exactly why it's needed and
> what it does.  The details of how zram considers itself "full" should
> be clear, which probably includes explaining zsmalloc fragmentation.
> It should be also clear this param only matters when limit_pages is
> set, and this param is only checked when zsmalloc's total size has
> reached that limit.

Sure, How about this?

		The fullness file is read/write and specifies how easily
		zram become full state. Normally, we can think "full"
		once all of memory is consumed but it's not simple with
		zram because zsmalloc has some issue by internal design
		so that write could fail once consumed *page* by zram
		reaches the mem_limit and zsmalloc cannot have a empty
		slot for the compressed object's size on fragmenet space
		although it has more empty slots for other sizes.

		We regard zram as full once consumed *page* reaches the
		mem_limit and consumed memory until now is higher the value
		resulted from the knob. So, if you set the value high,
		you can squeeze more pages into fragment space so you could
		avoid early OOM while you could see more write-fail warning,
		overhead to fail-write recovering by VM and reclaim latency.
		If you set the value low, you can see OOM kill easily
		even though there are memory space in zram but you could
		avoid shortcomings mentioned above.

		This knobs is valid ony if you set mem_limit.
		Currently, initial value is 80% but it could be changed.

I didn't decide how to change it from percent.
Decimal fraction Jerome mentioned does make sense to me so please ignore
percent part in above.

> 
> Also, since the next patch changes it to be used only as a default,
> shouldn't it be DEFAULT_ZRAM_FULLNESS_PERCENT or similar?

Okay, I will do it in 5/5.

> 
> > +
> > +/*
> > + * If zram fails to allocate memory consecutively up to this,
> > + * we regard it as zram-full. It's safe guard to prevent too
> > + * many swap write fail due to lack of fragmentation uncertainty.
> > + */
> > +#define ALLOC_FAIL_MAX 32
> > +
> >  #define ZRAM_ATTR_RO(name)                                             \
> >  static ssize_t zram_attr_##name##_show(struct device *d,               \
> >                                 struct device_attribute *attr, char *b) \
> > @@ -148,6 +162,7 @@ static ssize_t mem_limit_store(struct device *dev,
> >
> >         down_write(&zram->init_lock);
> >         zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
> > +       atomic_set(&zram->alloc_fail, 0);
> >         up_write(&zram->init_lock);
> >
> >         return len;
> > @@ -410,6 +425,7 @@ static void zram_free_page(struct zram *zram, size_t index)
> >         atomic64_sub(zram_get_obj_size(meta, index),
> >                         &zram->stats.compr_data_size);
> >         atomic64_dec(&zram->stats.pages_stored);
> > +       atomic_set(&zram->alloc_fail, 0);
> >
> >         meta->table[index].handle = 0;
> >         zram_set_obj_size(meta, index, 0);
> > @@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >         }
> >
> >         alloced_pages = zs_get_total_pages(meta->mem_pool);
> > -       if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> > -               zs_free(meta->mem_pool, handle);
> > -               ret = -ENOMEM;
> > -               goto out;
> > +       if (zram->limit_pages) {
> > +               if (alloced_pages > zram->limit_pages) {
> > +                       zs_free(meta->mem_pool, handle);
> > +                       atomic_inc(&zram->alloc_fail);
> > +                       ret = -ENOMEM;
> > +                       goto out;
> > +               } else {
> > +                       atomic_set(&zram->alloc_fail, 0);
> > +               }
> 
> So, with zram_full() checking for alloced_pages >= limit_pages, this
> will need to be changed; the way it is now it prevents that from ever
> being true.
> 
> Instead I believe this check has to be moved to before zs_malloc(), so
> that alloced_pages > limit_pages is true.

I don't get it why you said "it prevents that from ever being true".
Now, zram can use up until limit_pages (ie, used memory == zram->limit_pages)
and trying to get more is failed. so zram_full checks it as
toal_pages >= zram->limit_pages so what is problem?
If I miss your point, could you explain more?

> 
> 
> >         }
> >
> >         update_used_max(zram, alloced_pages);
> > @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >         down_write(&zram->init_lock);
> >
> >         zram->limit_pages = 0;
> > +       atomic_set(&zram->alloc_fail, 0);
> >
> >         if (!init_done(zram)) {
> >                 up_write(&zram->init_lock);
> > @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >         return 0;
> >  }
> >
> > +static int zram_full(struct block_device *bdev, void *arg)
> > +{
> > +       struct zram *zram;
> > +       struct zram_meta *meta;
> > +       unsigned long total_pages, compr_pages;
> > +
> > +       zram = bdev->bd_disk->private_data;
> > +       if (!zram->limit_pages)
> > +               return 0;
> > +
> > +       meta = zram->meta;
> > +       total_pages = zs_get_total_pages(meta->mem_pool);
> > +
> > +       if (total_pages >= zram->limit_pages) {
> > +
> > +               compr_pages = atomic64_read(&zram->stats.compr_data_size)
> > +                                       >> PAGE_SHIFT;
> > +               if ((100 * compr_pages / total_pages)
> > +                       >= ZRAM_FULLNESS_PERCENT)
> > +                       return 1;
> > +       }
> > +
> > +       if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
> > +               return 1;
> > +
> > +       return 0;
> > +}
> > +
> >  static int zram_swap_hint(struct block_device *bdev,
> >                                 unsigned int hint, void *arg)
> >  {
> > @@ -951,6 +1001,8 @@ static int zram_swap_hint(struct block_device *bdev,
> >
> >         if (hint == SWAP_FREE)
> >                 ret = zram_slot_free_notify(bdev, (unsigned long)arg);
> > +       else if (hint == SWAP_FULL)
> > +               ret = zram_full(bdev, arg);
> >
> >         return ret;
> >  }
> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > index c6ee271317f5..fcf3176a9f15 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -113,6 +113,7 @@ struct zram {
> >         u64 disksize;   /* bytes */
> >         int max_comp_streams;
> >         struct zram_stats stats;
> > +       atomic_t alloc_fail;
> >         /*
> >          * the number of pages zram can consume for storing compressed data
> >          */
> > --
> > 2.0.0
> >
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
