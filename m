Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBF486B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 15:07:29 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 14so590418itm.6
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 12:07:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n26sor9177283ioc.339.2018.01.10.12.07.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 12:07:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180109224700.GA175231@google.com>
References: <20180108225101.15790-1-yuzhao@google.com> <CALZtONCsC79jyCsFQcJOALhw=QrTeFMiYTpE+HRrVjMh-QeT-g@mail.gmail.com>
 <20180109224700.GA175231@google.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 10 Jan 2018 15:06:47 -0500
Message-ID: <CALZtONDc3VkWg83y1Nv_q+yUmwuFWmPUrFQOTJQv6b_ZbOh49g@mail.gmail.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 9, 2018 at 5:47 PM, Yu Zhao <yuzhao@google.com> wrote:
> On Tue, Jan 09, 2018 at 01:25:18PM -0500, Dan Streetman wrote:
>> On Mon, Jan 8, 2018 at 5:51 PM, Yu Zhao <yuzhao@google.com> wrote:
>> > We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
>> > as zpool driver because zsmalloc doesn't support eviction.
>> >
>> > Add zpool_shrinkable() to detect if zpool is shrinkable, and use
>> > it in zswap to avoid waste memory for zswap header.
>> >
>> > Signed-off-by: Yu Zhao <yuzhao@google.com>
>> > ---
>> >  include/linux/zpool.h |  2 ++
>> >  mm/zpool.c            | 17 ++++++++++++++++-
>> >  mm/zsmalloc.c         |  7 -------
>> >  mm/zswap.c            | 20 ++++++++++----------
>> >  4 files changed, 28 insertions(+), 18 deletions(-)
>> >
>> > diff --git a/include/linux/zpool.h b/include/linux/zpool.h
>> > index 004ba807df96..3f0ac2ab74aa 100644
>> > --- a/include/linux/zpool.h
>> > +++ b/include/linux/zpool.h
>> > @@ -108,4 +108,6 @@ void zpool_register_driver(struct zpool_driver *driver);
>> >
>> >  int zpool_unregister_driver(struct zpool_driver *driver);
>> >
>> > +bool zpool_shrinkable(struct zpool *pool);
>> > +
>> >  #endif
>> > diff --git a/mm/zpool.c b/mm/zpool.c
>> > index fd3ff719c32c..839d4234c540 100644
>> > --- a/mm/zpool.c
>> > +++ b/mm/zpool.c
>> > @@ -296,7 +296,8 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
>> >  int zpool_shrink(struct zpool *zpool, unsigned int pages,
>> >                         unsigned int *reclaimed)
>> >  {
>> > -       return zpool->driver->shrink(zpool->pool, pages, reclaimed);
>> > +       return zpool_shrinkable(zpool) ?
>> > +              zpool->driver->shrink(zpool->pool, pages, reclaimed) : -EINVAL;
>> >  }
>> >
>> >  /**
>> > @@ -355,6 +356,20 @@ u64 zpool_get_total_size(struct zpool *zpool)
>> >         return zpool->driver->total_size(zpool->pool);
>> >  }
>> >
>> > +/**
>> > + * zpool_shrinkable() - Test if zpool is shrinkable
>> > + * @pool       The zpool to test
>> > + *
>> > + * Zpool is only shrinkable when it's created with struct
>> > + * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
>> > + *
>> > + * Returns: true if shrinkable; false otherwise.
>> > + */
>> > +bool zpool_shrinkable(struct zpool *zpool)
>> > +{
>> > +       return zpool->ops && zpool->ops->evict && zpool->driver->shrink;
>>
>> as these things won't ever change for the life of the zpool, it would
>> probably be better to just check them at zpool creation time and set a
>> single new zpool param, like 'zpool->shrinkable'. since this function
>> will be called for every page that's swapped in or out, that may save
>> a bit of time.
>
> Ack.
>
>> also re: calling it 'shrinkable' or 'evictable', the real thing zswap
>> is interested in is if it needs to include the header info that
>> zswap_writeback_entry (i.e. ops->evict) later needs, so yeah it does
>> make more sense to call it zpool_evictable() and zpool->evictable.
>> However, I think the function should still be zpool_shrink() and
>> zpool->driver->shrink(), because it should be possible for
>> zs_pool_shrink() to call the normal zsmalloc shrinker, instead of
>> doing the zswap-style eviction, even if it doesn't do that currently.
>
> I agree we keep zpool_shrink(). It could either shrink pool if driver
> supports slab shrinker by providing zpool->driver->shrink or evict
> pages from pool if driver supports zpool->driver->evict (which in turn
> calls ops->evict provided by zswap) or both.
>
> We can't use a single zpool->driver->callback to achieve both because
> there will be no way for zswap to know if driver uses ops->evict thus
> no way to determine if zswap_header is needed.
>
> So for now, I think it'd be better if we deleted zpool->driver->shrink
> from zsmalloc and renamed it to zpool->driver->evict in zbud. Later
> if we decide zpool_shrink should also call zsmalloc slab shrinker, we
> add a new callback.

Well, I think shrink vs evict an implementation detail, isn't it?
That is, from zswap's perspective, there should be:

zpool_evictable()
if true, zswap needs to include the header on each compressed page,
because the zpool may callback zpool->ops->evict() which calls
zswap_writeback_entry() which expects the entry to start with a zswap
header.
if false, zswap doesn't need to include the header, because the zpool
will never, ever call zpool->ops->evict

zpool_shrink()
this will try to shrink the zpool, using whatever
zpool-implementation-specific shrinking method.  If zpool_evictable()
is true for this zpool, then zpool_shrink() *might* callback to
zpool->ops->evict(), although it doesn't have to if it can shrink
without evictions.  If zpool_evictable() is false, then zpool_shrink()
will never callback to zpool->ops->evict().

There is really no need for zswap to call different functions based on
whether the pool is evictable or not...is there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
