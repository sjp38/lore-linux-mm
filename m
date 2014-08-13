Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B0B9C6B003A
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 11:15:06 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so14840437pad.8
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:15:06 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id hr10si1746499pac.24.2014.08.13.08.15.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 08:15:05 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so14655932pdj.30
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:15:05 -0700 (PDT)
Date: Thu, 14 Aug 2014 00:13:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC 1/3] zsmalloc: move pages_allocated to zs_pool
Message-ID: <20140813151354.GD1091@swordfish>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-2-git-send-email-minchan@kernel.org>
 <CALZtONDmvLDtceVW9AyiDwdSHQzPbay36JEts8iuZ4nvykWfeA@mail.gmail.com>
 <20140813141413.GA1091@swordfish>
 <CALZtONDgYRUwrsN_G7pds2QY6QTOr8G8jAHa6Zta2XDhDHV8_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDgYRUwrsN_G7pds2QY6QTOr8G8jAHa6Zta2XDhDHV8_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

On (08/13/14 10:51), Dan Streetman wrote:
> Date: Wed, 13 Aug 2014 10:51:40 -0400
> From: Dan Streetman <ddstreet@ieee.org>
> To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>,
>  linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand
>  <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi
>  Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>
> Subject: Re: [RFC 1/3] zsmalloc: move pages_allocated to zs_pool
> 
> On Wed, Aug 13, 2014 at 10:14 AM, Sergey Senozhatsky
> <sergey.senozhatsky@gmail.com> wrote:
> > On (08/13/14 09:59), Dan Streetman wrote:
> >> On Tue, Aug 5, 2014 at 4:02 AM, Minchan Kim <minchan@kernel.org> wrote:
> >> > Pages_allocated has counted in size_class structure and when user
> >> > want to see total_size_bytes, it gathers all of value from each
> >> > size_class to report the sum.
> >> >
> >> > It's not bad if user don't see the value often but if user start
> >> > to see the value frequently, it would be not a good deal for
> >> > performance POV.
> >> >
> >> > This patch moves the variable from size_class to zs_pool so it would
> >> > reduce memory footprint (from [255 * 8byte] to [sizeof(atomic_t)])
> >> > but it adds new locking overhead but it wouldn't be severe because
> >> > it's not a hot path in zs_malloc(ie, it is called only when new
> >> > zspage is created, not a object).
> >>
> >> Would using an atomic64_t without locking be simpler?
> >
> > it would be racy.
> 
> oh.  atomic operations aren't smp safe?  is that because other
> processors might use a stale value, and barriers must be added?  I
> guess I don't quite understand the value of atomic then. :-/

pool not only set the value, it also read it and make some decisions
based on that value:

	pages_allocated += X
	if (pages_allocated >= max_pages_allocated)
		return 0;

	-ss

> >>
> >> >
> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> > ---
> >> >  mm/zsmalloc.c | 30 ++++++++++++++++--------------
> >> >  1 file changed, 16 insertions(+), 14 deletions(-)
> >> >
> >> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >> > index fe78189624cf..a6089bd26621 100644
> >> > --- a/mm/zsmalloc.c
> >> > +++ b/mm/zsmalloc.c
> >> > @@ -198,9 +198,6 @@ struct size_class {
> >> >
> >> >         spinlock_t lock;
> >> >
> >> > -       /* stats */
> >> > -       u64 pages_allocated;
> >> > -
> >> >         struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> >> >  };
> >> >
> >> > @@ -216,9 +213,12 @@ struct link_free {
> >> >  };
> >> >
> >> >  struct zs_pool {
> >> > +       spinlock_t stat_lock;
> >> > +
> >> >         struct size_class size_class[ZS_SIZE_CLASSES];
> >> >
> >> >         gfp_t flags;    /* allocation flags used when growing pool */
> >> > +       unsigned long pages_allocated;
> >> >  };
> >> >
> >> >  /*
> >> > @@ -882,6 +882,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
> >> >
> >> >         }
> >> >
> >> > +       spin_lock_init(&pool->stat_lock);
> >> >         pool->flags = flags;
> >> >
> >> >         return pool;
> >> > @@ -943,8 +944,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> >> >                         return 0;
> >> >
> >> >                 set_zspage_mapping(first_page, class->index, ZS_EMPTY);
> >> > +               spin_lock(&pool->stat_lock);
> >> > +               pool->pages_allocated += class->pages_per_zspage;
> >> > +               spin_unlock(&pool->stat_lock);
> >> >                 spin_lock(&class->lock);
> >> > -               class->pages_allocated += class->pages_per_zspage;
> >> >         }
> >> >
> >> >         obj = (unsigned long)first_page->freelist;
> >> > @@ -997,14 +1000,14 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
> >> >
> >> >         first_page->inuse--;
> >> >         fullness = fix_fullness_group(pool, first_page);
> >> > -
> >> > -       if (fullness == ZS_EMPTY)
> >> > -               class->pages_allocated -= class->pages_per_zspage;
> >> > -
> >> >         spin_unlock(&class->lock);
> >> >
> >> > -       if (fullness == ZS_EMPTY)
> >> > +       if (fullness == ZS_EMPTY) {
> >> > +               spin_lock(&pool->stat_lock);
> >> > +               pool->pages_allocated -= class->pages_per_zspage;
> >> > +               spin_unlock(&pool->stat_lock);
> >> >                 free_zspage(first_page);
> >> > +       }
> >> >  }
> >> >  EXPORT_SYMBOL_GPL(zs_free);
> >> >
> >> > @@ -1100,12 +1103,11 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
> >> >
> >> >  u64 zs_get_total_size_bytes(struct zs_pool *pool)
> >> >  {
> >> > -       int i;
> >> > -       u64 npages = 0;
> >> > -
> >> > -       for (i = 0; i < ZS_SIZE_CLASSES; i++)
> >> > -               npages += pool->size_class[i].pages_allocated;
> >> > +       u64 npages;
> >> >
> >> > +       spin_lock(&pool->stat_lock);
> >> > +       npages = pool->pages_allocated;
> >> > +       spin_unlock(&pool->stat_lock);
> >> >         return npages << PAGE_SHIFT;
> >> >  }
> >> >  EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
> >> > --
> >> > 2.0.0
> >> >
> >> > --
> >> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> > the body to majordomo@kvack.org.  For more info on Linux MM,
> >> > see: http://www.linux-mm.org/ .
> >> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
