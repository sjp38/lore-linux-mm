Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 786EF6B009E
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 19:35:52 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so6098463pac.28
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 16:35:52 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qb9si160311pdb.194.2014.10.06.16.35.49
        for <linux-mm@kvack.org>;
        Mon, 06 Oct 2014 16:35:51 -0700 (PDT)
Date: Tue, 7 Oct 2014 08:36:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-ID: <20141006233608.GA19445@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-5-git-send-email-minchan@kernel.org>
 <CALZtONB+NBMa8xf8xuAoeYHDoMtS56VLGP-a46LZgpppFyz7ag@mail.gmail.com>
 <20140925010229.GA17364@bbox>
 <CALZtONDnrqPZEBgJb5t8v_pmgh5YMSCA649sCPObb+U=5hAX_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONDnrqPZEBgJb5t8v_pmgh5YMSCA649sCPObb+U=5hAX_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

Hello Dan,

Sorry for the delay. I had internal works which should be handled
urgent. I hope you don't lose your interest due to my bad response
latency.

On Thu, Sep 25, 2014 at 11:52:22AM -0400, Dan Streetman wrote:
> On Wed, Sep 24, 2014 at 9:02 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Wed, Sep 24, 2014 at 10:01:03AM -0400, Dan Streetman wrote:
> >> On Sun, Sep 21, 2014 at 8:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > This patch implement SWAP_FULL handler in zram so that VM can
> >> > know whether zram is full or not and use it to stop anonymous
> >> > page reclaim.
> >> >
> >> > How to judge fullness is below,
> >> >
> >> > fullness = (100 * used space / total space)
> >> >
> >> > It means the higher fullness is, the slower we reach zram full.
> >> > Now, default of fullness is 80 so that it biased more momory
> >> > consumption rather than early OOM kill.
> >> >
> >> > Above logic works only when used space of zram hit over the limit
> >> > but zram also pretend to be full once 32 consecutive allocation
> >> > fail happens. It's safe guard to prevent system hang caused by
> >> > fragment uncertainty.
> >> >
> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> > ---
> >> >  drivers/block/zram/zram_drv.c | 60 ++++++++++++++++++++++++++++++++++++++++---
> >> >  drivers/block/zram/zram_drv.h |  1 +
> >> >  2 files changed, 57 insertions(+), 4 deletions(-)
> >> >
> >> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> >> > index 22a37764c409..649cad9d0b1c 100644
> >> > --- a/drivers/block/zram/zram_drv.c
> >> > +++ b/drivers/block/zram/zram_drv.c
> >> > @@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
> >> >  /* Module params (documentation at end) */
> >> >  static unsigned int num_devices = 1;
> >> >
> >> > +/*
> >> > + * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
> >> > + * we regards it as zram-full. It means that the higher
> >> > + * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
> >> > + */
> >> > +#define ZRAM_FULLNESS_PERCENT 80
> >>
> >> As Andrew said, this (or the user-configurable fullness param from the
> >> next patch) should have more detail about exactly why it's needed and
> >> what it does.  The details of how zram considers itself "full" should
> >> be clear, which probably includes explaining zsmalloc fragmentation.
> >> It should be also clear this param only matters when limit_pages is
> >> set, and this param is only checked when zsmalloc's total size has
> >> reached that limit.
> >
> > Sure, How about this?
> >
> >                 The fullness file is read/write and specifies how easily
> >                 zram become full state. Normally, we can think "full"
> >                 once all of memory is consumed but it's not simple with
> >                 zram because zsmalloc has some issue by internal design
> >                 so that write could fail once consumed *page* by zram
> >                 reaches the mem_limit and zsmalloc cannot have a empty
> >                 slot for the compressed object's size on fragmenet space
> >                 although it has more empty slots for other sizes.
> 
> I understand that, but it might be confusing or unclear to anyone
> who's not familiar with how zsmalloc works.
> 
> Maybe it could be explained by referencing the existing
> compr_data_size and mem_used_total?  In addition to some or all of the
> above, you could add something like:
> 
> This controls when zram decides that it is "full".  It is a percent
> value, checked against compr_data_size / mem_used_total.  When
> mem_used_total is equal to mem_limit, the fullness is checked and if
> the compr_data_size / mem_used_total percentage is higher than this
> specified fullness value, zram is considered "full".

Better than my verbose version.

> 
> 
> >
> >                 We regard zram as full once consumed *page* reaches the
> >                 mem_limit and consumed memory until now is higher the value
> >                 resulted from the knob. So, if you set the value high,
> >                 you can squeeze more pages into fragment space so you could
> >                 avoid early OOM while you could see more write-fail warning,
> >                 overhead to fail-write recovering by VM and reclaim latency.
> >                 If you set the value low, you can see OOM kill easily
> >                 even though there are memory space in zram but you could
> >                 avoid shortcomings mentioned above.
> 
> You should clarify also that this is currently only used by
> swap-on-zram, and this value prevents swap from writing to zram once
> it is "full".  This setting has no effect when using zram for a
> mounted filesystem.

Sure.

> 
> >
> >                 This knobs is valid ony if you set mem_limit.
> >                 Currently, initial value is 80% but it could be changed.
> >
> > I didn't decide how to change it from percent.
> > Decimal fraction Jerome mentioned does make sense to me so please ignore
> > percent part in above.
> >
> >>
> >> Also, since the next patch changes it to be used only as a default,
> >> shouldn't it be DEFAULT_ZRAM_FULLNESS_PERCENT or similar?
> >
> > Okay, I will do it in 5/5.
> >
> >>
> >> > +
> >> > +/*
> >> > + * If zram fails to allocate memory consecutively up to this,
> >> > + * we regard it as zram-full. It's safe guard to prevent too
> >> > + * many swap write fail due to lack of fragmentation uncertainty.
> >> > + */
> >> > +#define ALLOC_FAIL_MAX 32
> >> > +
> >> >  #define ZRAM_ATTR_RO(name)                                             \
> >> >  static ssize_t zram_attr_##name##_show(struct device *d,               \
> >> >                                 struct device_attribute *attr, char *b) \
> >> > @@ -148,6 +162,7 @@ static ssize_t mem_limit_store(struct device *dev,
> >> >
> >> >         down_write(&zram->init_lock);
> >> >         zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
> >> > +       atomic_set(&zram->alloc_fail, 0);
> >> >         up_write(&zram->init_lock);
> >> >
> >> >         return len;
> >> > @@ -410,6 +425,7 @@ static void zram_free_page(struct zram *zram, size_t index)
> >> >         atomic64_sub(zram_get_obj_size(meta, index),
> >> >                         &zram->stats.compr_data_size);
> >> >         atomic64_dec(&zram->stats.pages_stored);
> >> > +       atomic_set(&zram->alloc_fail, 0);
> >> >
> >> >         meta->table[index].handle = 0;
> >> >         zram_set_obj_size(meta, index, 0);
> >> > @@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >> >         }
> >> >
> >> >         alloced_pages = zs_get_total_pages(meta->mem_pool);
> >> > -       if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> >> > -               zs_free(meta->mem_pool, handle);
> >> > -               ret = -ENOMEM;
> >> > -               goto out;
> >> > +       if (zram->limit_pages) {
> >> > +               if (alloced_pages > zram->limit_pages) {
> >> > +                       zs_free(meta->mem_pool, handle);
> >> > +                       atomic_inc(&zram->alloc_fail);
> >> > +                       ret = -ENOMEM;
> >> > +                       goto out;
> >> > +               } else {
> >> > +                       atomic_set(&zram->alloc_fail, 0);
> >> > +               }
> >>
> >> So, with zram_full() checking for alloced_pages >= limit_pages, this
> >> will need to be changed; the way it is now it prevents that from ever
> >> being true.
> >>
> >> Instead I believe this check has to be moved to before zs_malloc(), so
> >> that alloced_pages > limit_pages is true.
> >
> > I don't get it why you said "it prevents that from ever being true".
> > Now, zram can use up until limit_pages (ie, used memory == zram->limit_pages)
> > and trying to get more is failed. so zram_full checks it as
> > toal_pages >= zram->limit_pages so what is problem?
> > If I miss your point, could you explain more?
> 
> ok, that's true, it's possible for alloc_pages == limit_pages, but
> since zsmalloc will increase its size by a full zspage, and those can
> be anywhere between 1 and 4 pages in size, it's only a (very roughly)
> 25% chance that an alloc will cause alloc_pages == limit_pages, it's
> more likely that an alloc will cause alloc_pages > limit_pages.  Now,
> after some number of write failures, that 25% (-ish) probability will
> be met, and alloc_pages == limit_pages will happen, but there's a
> rather high chance that there will be some number of write failures
> first.
> 
> To summarize or restate that, I guess what I'm saying is that for
> users who don't care about some write failures and/or users with no
> other swap devices except zram, it probably does not matter.  However
> for them, they probably will rely on the 32 write failure limit, and
> not the fullness limit.  For users where zram is only the primary swap
> device, and there is a backup swap device, they probably will want
> zram to fail over to the backup fairly quickly, with as few write
> failures as possible (preferably, none, I would think).  And this
> situation makes that highly unlikely - since there's only about a 25%
> chance of alloc_pages == limit_pages with no previous write failures,
> it's almost a certainty that there will be write failures before zram
> is decided to be "full", even if "fullness" is set to 0.
> 
> With that said, you're right that it will eventually work, and those
> few write failures while trying to get to alloc_pages == limit_pages
> would probably not be noticable.  However, do remember that zram won't
> stay full forever, so if it is only the primary swap device, it's
> likely it will move between "full" and "not full" quite a lot, and
> those few write failures may start adding up.

Fair enough.

But it is possible to see write-failure even though we correct
it because there is potential chance for zram to fail to allocate
order-0 page by a few reason which one of them is CMA I got several
reports because zRAM cannot allocate a movable page due to lack of
migration while usersapce goes with it well. I have a plan to fix it
with zsmalloc migration work but there are another chances to make
fail order-0 page by serval ways so I don't think we cannot prevent
write-failure completely unless we have reserved memory for zram.

Having said that, I agree it would be better to reduce such fails
with small code piece so I will check zram_full as follows,

/*
 * XXX: zsmalloc_maxpages check should be removed when zsmalloc
 * implement using of fragmented spaces in last page of zspage.
 */
if (total_pages >= zram->limit_pages - zsmalloc_maxpages()) {
        ...
}

It will reduce 3 pages at maximum but shouldn't a big deal.

> 
> I suppose testing would show if those few write failures are
> significant.  Also, if nobody ever uses zram with a backup (real disk)
> secondary swap device, then it likely doesn't matter.

I think it's really reasonable scenario.

> 
> >
> >>
> >>
> >> >         }
> >> >
> >> >         update_used_max(zram, alloced_pages);
> >> > @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >> >         down_write(&zram->init_lock);
> >> >
> >> >         zram->limit_pages = 0;
> >> > +       atomic_set(&zram->alloc_fail, 0);
> >> >
> >> >         if (!init_done(zram)) {
> >> >                 up_write(&zram->init_lock);
> >> > @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >> >         return 0;
> >> >  }
> >> >
> >> > +static int zram_full(struct block_device *bdev, void *arg)
> >> > +{
> >> > +       struct zram *zram;
> >> > +       struct zram_meta *meta;
> >> > +       unsigned long total_pages, compr_pages;
> >> > +
> >> > +       zram = bdev->bd_disk->private_data;
> >> > +       if (!zram->limit_pages)
> >> > +               return 0;
> >> > +
> >> > +       meta = zram->meta;
> >> > +       total_pages = zs_get_total_pages(meta->mem_pool);
> >> > +
> >> > +       if (total_pages >= zram->limit_pages) {
> >> > +
> >> > +               compr_pages = atomic64_read(&zram->stats.compr_data_size)
> >> > +                                       >> PAGE_SHIFT;
> >> > +               if ((100 * compr_pages / total_pages)
> >> > +                       >= ZRAM_FULLNESS_PERCENT)
> >> > +                       return 1;
> >> > +       }
> >> > +
> >> > +       if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
> >> > +               return 1;
> >> > +
> >> > +       return 0;
> >> > +}
> >> > +
> >> >  static int zram_swap_hint(struct block_device *bdev,
> >> >                                 unsigned int hint, void *arg)
> >> >  {
> >> > @@ -951,6 +1001,8 @@ static int zram_swap_hint(struct block_device *bdev,
> >> >
> >> >         if (hint == SWAP_FREE)
> >> >                 ret = zram_slot_free_notify(bdev, (unsigned long)arg);
> >> > +       else if (hint == SWAP_FULL)
> >> > +               ret = zram_full(bdev, arg);
> >> >
> >> >         return ret;
> >> >  }
> >> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> >> > index c6ee271317f5..fcf3176a9f15 100644
> >> > --- a/drivers/block/zram/zram_drv.h
> >> > +++ b/drivers/block/zram/zram_drv.h
> >> > @@ -113,6 +113,7 @@ struct zram {
> >> >         u64 disksize;   /* bytes */
> >> >         int max_comp_streams;
> >> >         struct zram_stats stats;
> >> > +       atomic_t alloc_fail;
> >> >         /*
> >> >          * the number of pages zram can consume for storing compressed data
> >> >          */
> >> > --
> >> > 2.0.0
> >> >
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
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
