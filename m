Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id 354A66B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:03:52 -0400 (EDT)
Received: by mail-ve0-f172.google.com with SMTP id oz11so5219572veb.17
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:03:51 -0700 (PDT)
Received: from mail-ve0-x235.google.com (mail-ve0-x235.google.com [2607:f8b0:400c:c01::235])
        by mx.google.com with ESMTPS id yh7si7883758vdc.93.2014.06.02.07.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 07:03:51 -0700 (PDT)
Received: by mail-ve0-f181.google.com with SMTP id pa12so5231121veb.12
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:03:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140602114741.GA1039@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
	<5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
	<alpine.DEB.2.10.1405300955120.11943@gentwo.org>
	<20140531110456.GC25076@esperanza>
	<20140602042435.GA17964@js1304-P5Q-DELUXE>
	<20140602114741.GA1039@esperanza>
Date: Mon, 2 Jun 2014 23:03:51 +0900
Message-ID: <CAAmzW4P=kUAJwozBPPos+uUewzSDnE43P6NcGYKNpBjjfv1EWA@mail.gmail.com>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs immediately
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2014-06-02 20:47 GMT+09:00 Vladimir Davydov <vdavydov@parallels.com>:
> Hi Joonsoo,
>
> On Mon, Jun 02, 2014 at 01:24:36PM +0900, Joonsoo Kim wrote:
>> On Sat, May 31, 2014 at 03:04:58PM +0400, Vladimir Davydov wrote:
>> > On Fri, May 30, 2014 at 09:57:10AM -0500, Christoph Lameter wrote:
>> > > On Fri, 30 May 2014, Vladimir Davydov wrote:
>> > >
>> > > > (3) is a bit more difficult, because slabs are added to per-cpu partial
>> > > > lists lock-less. Fortunately, we only have to handle the __slab_free
>> > > > case, because, as there shouldn't be any allocation requests dispatched
>> > > > to a dead memcg cache, get_partial_node() should never be called. In
>> > > > __slab_free we use cmpxchg to modify kmem_cache_cpu->partial (see
>> > > > put_cpu_partial) so that setting ->partial to a special value, which
>> > > > will make put_cpu_partial bail out, will do the trick.
> [...]
>> I think that we can do (3) easily.
>> If we check memcg_cache_dead() in the end of put_cpu_partial() rather
>> than in the begin of put_cpu_partial(), we can avoid the race you
>> mentioned. If someone do put_cpu_partial() before dead flag is set,
>> it can be zapped by who set dead flag. And if someone do
>> put_cpu_partial() after dead flag is set, it can be zapped by who
>> do put_cpu_partial().
>
> After put_cpu_partial() adds a frozen slab to a per cpu partial list,
> the slab becomes visible to other threads, which means it can be
> unfrozen and freed. The latter can trigger cache destruction. Hence we
> shouldn't touch the cache, in particular call memcg_cache_dead() on it,
> after calling put_cpu_partial(), otherwise we can get use-after-free.
>
> However, what you propose makes sense if we disable irqs before adding a
> slab to a partial list and enable them only after checking if the cache
> is dead and unfreezing all partials if so, i.e.
>
> diff --git a/mm/slub.c b/mm/slub.c
> index d96faa2464c3..14b9e9a8677c 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2030,8 +2030,15 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>         struct page *oldpage;
>         int pages;
>         int pobjects;
> +       unsigned long flags;
> +       int irq_saved = 0;
>
>         do {
> +               if (irq_saved) {
> +                       local_irq_restore(flags);
> +                       irq_saved = 0;
> +               }
> +
>                 pages = 0;
>                 pobjects = 0;
>                 oldpage = this_cpu_read(s->cpu_slab->partial);
> @@ -2062,8 +2069,16 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>                 page->pobjects = pobjects;
>                 page->next = oldpage;
>
> +               local_irq_save(flags);
> +               irq_saved = 1;
> +
>         } while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>                                                                 != oldpage);
> +
> +       if (memcg_cache_dead(s))
> +               unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
> +
> +       local_irq_restore(flags);
>  #endif
>  }
>
>
> That would be safe against possible cache destruction, because to remove
> a slab from a per cpu partial list we have to run on the cpu it was
> frozen on. Disabling irqs makes it impossible.

Hmm... this is also a bit ugly.
How about following change?

Thanks.

diff --git a/mm/slub.c b/mm/slub.c
index 2b1ce69..6adab87 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2058,6 +2058,21 @@ static void put_cpu_partial(struct kmem_cache
*s, struct page *page, int drain)

        } while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
                                                                != oldpage);
+
+       if (memcg_cache_dead(s)) {
+               bool done = false;
+               unsigned long flags;
+
+               local_irq_save(flags);
+               if (this_cpu_read(s->cpu_slab->partial) == page) {
+                       done = true;
+                       unfreeze_partials(s, this_cpu_ptr);
+               }
+               local_irq_restore(flags);
+
+               if (!done)
+                       flush_all(s);
+       }
 #endif
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
