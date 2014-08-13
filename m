Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3E89A6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 12:11:27 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so11427945wgh.15
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 09:11:26 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id hl8si3038279wib.60.2014.08.13.09.11.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 09:11:25 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so11551991wgh.30
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 09:11:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140813152504.GE1091@swordfish>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-2-git-send-email-minchan@kernel.org> <CALZtONDmvLDtceVW9AyiDwdSHQzPbay36JEts8iuZ4nvykWfeA@mail.gmail.com>
 <20140813141413.GA1091@swordfish> <CALZtONDgYRUwrsN_G7pds2QY6QTOr8G8jAHa6Zta2XDhDHV8_A@mail.gmail.com>
 <20140813151354.GD1091@swordfish> <20140813152504.GE1091@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 13 Aug 2014 12:11:04 -0400
Message-ID: <CALZtONA9sJ3L8MxJ+gy_x5iktCxabStQK9BexF06XyOjRjoPNQ@mail.gmail.com>
Subject: Re: [RFC 1/3] zsmalloc: move pages_allocated to zs_pool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Aug 13, 2014 at 11:25 AM, Sergey Senozhatsky
<sergey.senozhatsky@gmail.com> wrote:
> On (08/14/14 00:13), Sergey Senozhatsky wrote:
>> > On Wed, Aug 13, 2014 at 10:14 AM, Sergey Senozhatsky
>> > <sergey.senozhatsky@gmail.com> wrote:
>> > > On (08/13/14 09:59), Dan Streetman wrote:
>> > >> On Tue, Aug 5, 2014 at 4:02 AM, Minchan Kim <minchan@kernel.org> wrote:
>> > >> > Pages_allocated has counted in size_class structure and when user
>> > >> > want to see total_size_bytes, it gathers all of value from each
>> > >> > size_class to report the sum.
>> > >> >
>> > >> > It's not bad if user don't see the value often but if user start
>> > >> > to see the value frequently, it would be not a good deal for
>> > >> > performance POV.
>> > >> >
>> > >> > This patch moves the variable from size_class to zs_pool so it would
>> > >> > reduce memory footprint (from [255 * 8byte] to [sizeof(atomic_t)])
>> > >> > but it adds new locking overhead but it wouldn't be severe because
>> > >> > it's not a hot path in zs_malloc(ie, it is called only when new
>> > >> > zspage is created, not a object).
>> > >>
>> > >> Would using an atomic64_t without locking be simpler?
>> > >
>> > > it would be racy.
>> >
>> > oh.  atomic operations aren't smp safe?  is that because other
>> > processors might use a stale value, and barriers must be added?  I
>> > guess I don't quite understand the value of atomic then. :-/
>>
>> pool not only set the value, it also read it and make some decisions
>> based on that value:
>>
>>       pages_allocated += X
>>       if (pages_allocated >= max_pages_allocated)
>>               return 0;
>

I'm missing where that is?  I don't see that in this patch?

>
> I mean, suppose this happens on two CPUs
>
> max_pages_allocated is 10; current pages_allocated is 8. now you have 2 zs_malloc()
> happenning on two CPUs. each of them will do `pages_allocated += 1'. the problem is
> that both will see 10 at `if (pages_allocated >= max_pages_allocated)', so we will
> fail 2 operations, while we only were supposed to fail one.

Do you mean this from the 2/3 patch:
@@ -946,6 +947,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
                set_zspage_mapping(first_page, class->index, ZS_EMPTY);
                spin_lock(&pool->stat_lock);
                pool->pages_allocated += class->pages_per_zspage;
+               if (pool->max_pages_allocated < pool->pages_allocated)
+                       pool->max_pages_allocated = pool->pages_allocated;
                spin_unlock(&pool->stat_lock);
                spin_lock(&class->lock);
        }

I see, yeah the max > allocated check before setting is easiest done
with a spinlock.  I think pages_allocated could still be done as
atomic, just using atomic_add_return() to grab the current value to
check against, but keeping them the same type and both protected by
the same spinlock I guess simplifies things.  Although, if they were
both atomic, then the *only* place that would need a spinlock would be
this check - reading the (atomic) max_pages_allocated wouldn't need a
spinlock, nor would clearing it to 0.

>
>         -ss
>
>>
>> > >>
>> > >> >
>> > >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>> > >> > ---
>> > >> >  mm/zsmalloc.c | 30 ++++++++++++++++--------------
>> > >> >  1 file changed, 16 insertions(+), 14 deletions(-)
>> > >> >
>> > >> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> > >> > index fe78189624cf..a6089bd26621 100644
>> > >> > --- a/mm/zsmalloc.c
>> > >> > +++ b/mm/zsmalloc.c
>> > >> > @@ -198,9 +198,6 @@ struct size_class {
>> > >> >
>> > >> >         spinlock_t lock;
>> > >> >
>> > >> > -       /* stats */
>> > >> > -       u64 pages_allocated;
>> > >> > -
>> > >> >         struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
>> > >> >  };
>> > >> >
>> > >> > @@ -216,9 +213,12 @@ struct link_free {
>> > >> >  };
>> > >> >
>> > >> >  struct zs_pool {
>> > >> > +       spinlock_t stat_lock;
>> > >> > +
>> > >> >         struct size_class size_class[ZS_SIZE_CLASSES];
>> > >> >
>> > >> >         gfp_t flags;    /* allocation flags used when growing pool */
>> > >> > +       unsigned long pages_allocated;
>> > >> >  };
>> > >> >
>> > >> >  /*
>> > >> > @@ -882,6 +882,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>> > >> >
>> > >> >         }
>> > >> >
>> > >> > +       spin_lock_init(&pool->stat_lock);
>> > >> >         pool->flags = flags;
>> > >> >
>> > >> >         return pool;
>> > >> > @@ -943,8 +944,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>> > >> >                         return 0;
>> > >> >
>> > >> >                 set_zspage_mapping(first_page, class->index, ZS_EMPTY);
>> > >> > +               spin_lock(&pool->stat_lock);
>> > >> > +               pool->pages_allocated += class->pages_per_zspage;
>> > >> > +               spin_unlock(&pool->stat_lock);
>> > >> >                 spin_lock(&class->lock);
>> > >> > -               class->pages_allocated += class->pages_per_zspage;
>> > >> >         }
>> > >> >
>> > >> >         obj = (unsigned long)first_page->freelist;
>> > >> > @@ -997,14 +1000,14 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>> > >> >
>> > >> >         first_page->inuse--;
>> > >> >         fullness = fix_fullness_group(pool, first_page);
>> > >> > -
>> > >> > -       if (fullness == ZS_EMPTY)
>> > >> > -               class->pages_allocated -= class->pages_per_zspage;
>> > >> > -
>> > >> >         spin_unlock(&class->lock);
>> > >> >
>> > >> > -       if (fullness == ZS_EMPTY)
>> > >> > +       if (fullness == ZS_EMPTY) {
>> > >> > +               spin_lock(&pool->stat_lock);
>> > >> > +               pool->pages_allocated -= class->pages_per_zspage;
>> > >> > +               spin_unlock(&pool->stat_lock);
>> > >> >                 free_zspage(first_page);
>> > >> > +       }
>> > >> >  }
>> > >> >  EXPORT_SYMBOL_GPL(zs_free);
>> > >> >
>> > >> > @@ -1100,12 +1103,11 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
>> > >> >
>> > >> >  u64 zs_get_total_size_bytes(struct zs_pool *pool)
>> > >> >  {
>> > >> > -       int i;
>> > >> > -       u64 npages = 0;
>> > >> > -
>> > >> > -       for (i = 0; i < ZS_SIZE_CLASSES; i++)
>> > >> > -               npages += pool->size_class[i].pages_allocated;
>> > >> > +       u64 npages;
>> > >> >
>> > >> > +       spin_lock(&pool->stat_lock);
>> > >> > +       npages = pool->pages_allocated;
>> > >> > +       spin_unlock(&pool->stat_lock);
>> > >> >         return npages << PAGE_SHIFT;
>> > >> >  }
>> > >> >  EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
>> > >> > --
>> > >> > 2.0.0
>> > >> >
>> > >> > --
>> > >> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > >> > the body to majordomo@kvack.org.  For more info on Linux MM,
>> > >> > see: http://www.linux-mm.org/ .
>> > >> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> > >>
>> >
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
