Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEFAE6B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:49:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q8so46734672lfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:49:41 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id y185si34974182wmg.9.2016.04.14.06.49.40
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 06:49:40 -0700 (PDT)
Date: Thu, 14 Apr 2016 14:49:26 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
Message-ID: <20160414134926.GD19990@nuc-i3427.alporthouse.com>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
 <CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Peniaev <r.peniaev@gmail.com>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 14, 2016 at 03:13:26PM +0200, Roman Peniaev wrote:
> Hi, Chris.
> 
> Is it made on purpose not to drop VM_LAZY_FREE flag in
> __purge_vmap_area_lazy()?  With your patch va->flags
> will have two bits set: VM_LAZY_FREE | VM_LAZY_FREEING.
> Seems it is not that bad, because all other code paths
> do not care, but still the change is not clear.

Oh, that was just a bad deletion.
 
> Also, did you consider to avoid taking static purge_lock
> in __purge_vmap_area_lazy() ? Because, with your change
> it seems that you can avoid taking this lock at all.
> Just be careful when you observe llist as empty, i.e.
> nr == 0.

I admit I only briefly looked at the lock. I will be honest and say I
do not fully understand the requirements of the sync/force_flush
parameters.

purge_fragmented_blocks() manages per-cpu lists, so that looks safe
under its own rcu_read_lock.

Yes, it looks feasible to remove the purge_lock if we can relax sync.

> > @@ -706,6 +703,8 @@ static void purge_vmap_area_lazy(void)
> >  static void free_vmap_area_noflush(struct vmap_area *va)
> >  {
> >         va->flags |= VM_LAZY_FREE;
> > +       llist_add(&va->purge_list, &vmap_purge_list);
> > +
> >         atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> 
> it seems to me that this a very long-standing problem: when you mark
> va->flags as VM_LAZY_FREE, va can be immediately freed from another CPU.
> If so, the line:
> 
>     atomic_add((va->va_end - va->va_start)....
> 
>  does use-after-free access.
> 
> So I would also fix it with careful line reordering with barrier:
> (probably barrier is excess here, because llist_add implies cmpxchg,
>  but I simply want to be explicit here, showing that marking va as
>  VM_LAZY_FREE and adding it to the list should be at the end)
> 
> -       va->flags |= VM_LAZY_FREE;
>         atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> +       smp_mb__after_atomic();
> +       va->flags |= VM_LAZY_FREE;
> +       llist_add(&va->purge_list, &vmap_purge_list);
> 
> What do you think?

Yup, it is racy. We can drop the modification of LAZY_FREE/LAZY_FREEING
to ease one headache, since those bits are not inspected anywhere afaict.
Would not using atomic_add_return() be even clearer with respect to
ordering:

        nr_lazy = atomic_add_return((va->va_end - va->va_start) >> PAGE_SHIFT,
                                    &vmap_lazy_nr);
        llist_add(&va->purge_list, &vmap_purge_list);

        if (unlikely(nr_lazy > lazy_max_pages()))
                try_purge_vmap_area_lazy();

Since it doesn't matter that much if we make an extra call to
try_purge_vmap_area_lazy() when we are on the boundary.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
