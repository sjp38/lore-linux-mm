Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C39CC6B0266
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 17:47:05 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i2so9560484pgq.8
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 14:47:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor2171762pll.95.2018.01.09.14.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 14:47:04 -0800 (PST)
Date: Tue, 9 Jan 2018 14:47:00 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Message-ID: <20180109224700.GA175231@google.com>
References: <20180108225101.15790-1-yuzhao@google.com>
 <CALZtONCsC79jyCsFQcJOALhw=QrTeFMiYTpE+HRrVjMh-QeT-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCsC79jyCsFQcJOALhw=QrTeFMiYTpE+HRrVjMh-QeT-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 09, 2018 at 01:25:18PM -0500, Dan Streetman wrote:
> On Mon, Jan 8, 2018 at 5:51 PM, Yu Zhao <yuzhao@google.com> wrote:
> > We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
> > as zpool driver because zsmalloc doesn't support eviction.
> >
> > Add zpool_shrinkable() to detect if zpool is shrinkable, and use
> > it in zswap to avoid waste memory for zswap header.
> >
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  include/linux/zpool.h |  2 ++
> >  mm/zpool.c            | 17 ++++++++++++++++-
> >  mm/zsmalloc.c         |  7 -------
> >  mm/zswap.c            | 20 ++++++++++----------
> >  4 files changed, 28 insertions(+), 18 deletions(-)
> >
> > diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> > index 004ba807df96..3f0ac2ab74aa 100644
> > --- a/include/linux/zpool.h
> > +++ b/include/linux/zpool.h
> > @@ -108,4 +108,6 @@ void zpool_register_driver(struct zpool_driver *driver);
> >
> >  int zpool_unregister_driver(struct zpool_driver *driver);
> >
> > +bool zpool_shrinkable(struct zpool *pool);
> > +
> >  #endif
> > diff --git a/mm/zpool.c b/mm/zpool.c
> > index fd3ff719c32c..839d4234c540 100644
> > --- a/mm/zpool.c
> > +++ b/mm/zpool.c
> > @@ -296,7 +296,8 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
> >  int zpool_shrink(struct zpool *zpool, unsigned int pages,
> >                         unsigned int *reclaimed)
> >  {
> > -       return zpool->driver->shrink(zpool->pool, pages, reclaimed);
> > +       return zpool_shrinkable(zpool) ?
> > +              zpool->driver->shrink(zpool->pool, pages, reclaimed) : -EINVAL;
> >  }
> >
> >  /**
> > @@ -355,6 +356,20 @@ u64 zpool_get_total_size(struct zpool *zpool)
> >         return zpool->driver->total_size(zpool->pool);
> >  }
> >
> > +/**
> > + * zpool_shrinkable() - Test if zpool is shrinkable
> > + * @pool       The zpool to test
> > + *
> > + * Zpool is only shrinkable when it's created with struct
> > + * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
> > + *
> > + * Returns: true if shrinkable; false otherwise.
> > + */
> > +bool zpool_shrinkable(struct zpool *zpool)
> > +{
> > +       return zpool->ops && zpool->ops->evict && zpool->driver->shrink;
> 
> as these things won't ever change for the life of the zpool, it would
> probably be better to just check them at zpool creation time and set a
> single new zpool param, like 'zpool->shrinkable'. since this function
> will be called for every page that's swapped in or out, that may save
> a bit of time.

Ack.

> also re: calling it 'shrinkable' or 'evictable', the real thing zswap
> is interested in is if it needs to include the header info that
> zswap_writeback_entry (i.e. ops->evict) later needs, so yeah it does
> make more sense to call it zpool_evictable() and zpool->evictable.
> However, I think the function should still be zpool_shrink() and
> zpool->driver->shrink(), because it should be possible for
> zs_pool_shrink() to call the normal zsmalloc shrinker, instead of
> doing the zswap-style eviction, even if it doesn't do that currently.

I agree we keep zpool_shrink(). It could either shrink pool if driver
supports slab shrinker by providing zpool->driver->shrink or evict
pages from pool if driver supports zpool->driver->evict (which in turn
calls ops->evict provided by zswap) or both.

We can't use a single zpool->driver->callback to achieve both because
there will be no way for zswap to know if driver uses ops->evict thus
no way to determine if zswap_header is needed.

So for now, I think it'd be better if we deleted zpool->driver->shrink
from zsmalloc and renamed it to zpool->driver->evict in zbud. Later
if we decide zpool_shrink should also call zsmalloc slab shrinker, we
add a new callback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
