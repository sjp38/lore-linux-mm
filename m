Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 628EC6B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 08:43:36 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x79so22671762lff.2
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 05:43:36 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id hm2si30914137wjb.83.2016.10.09.05.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Oct 2016 05:43:34 -0700 (PDT)
Date: Sun, 9 Oct 2016 13:42:42 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm/vmalloc: reduce the number of lazy_max_pages to
 reduce latency
Message-ID: <20161009124242.GA2718@nuc-i3427.alporthouse.com>
References: <20160929073411.3154-1-jszhang@marvell.com>
 <20160929081818.GE28107@nuc-i3427.alporthouse.com>
 <CAD=GYpYKL9=uY=Fks2xO6oK3bJ772yo4EiJ1tJkVU9PheSD+Cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD=GYpYKL9=uY=Fks2xO6oK3bJ772yo4EiJ1tJkVU9PheSD+Cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <agnel.joel@gmail.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, rientjes@google.com, iamjoonsoo.kim@lge.com, npiggin@kernel.dk, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM Kernel List <linux-arm-kernel@lists.infradead.org>

On Sat, Oct 08, 2016 at 08:43:51PM -0700, Joel Fernandes wrote:
> On Thu, Sep 29, 2016 at 1:18 AM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> > On Thu, Sep 29, 2016 at 03:34:11PM +0800, Jisheng Zhang wrote:
> >> On Marvell berlin arm64 platforms, I see the preemptoff tracer report
> >> a max 26543 us latency at __purge_vmap_area_lazy, this latency is an
> >> awfully bad for STB. And the ftrace log also shows __free_vmap_area
> >> contributes most latency now. I noticed that Joel mentioned the same
> >> issue[1] on x86 platform and gave two solutions, but it seems no patch
> >> is sent out for this purpose.
> >>
> >> This patch adopts Joel's first solution, but I use 16MB per core
> >> rather than 8MB per core for the number of lazy_max_pages. After this
> >> patch, the preemptoff tracer reports a max 6455us latency, reduced to
> >> 1/4 of original result.
> >
> > My understanding is that
> >
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 91f44e78c516..3f7c6d6969ac 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -626,7 +626,6 @@ void set_iounmap_nonlazy(void)
> >  static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >                                         int sync, int force_flush)
> >  {
> > -       static DEFINE_SPINLOCK(purge_lock);
> >         struct llist_node *valist;
> >         struct vmap_area *va;
> >         struct vmap_area *n_va;
> > @@ -637,12 +636,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >          * should not expect such behaviour. This just simplifies locking for
> >          * the case that isn't actually used at the moment anyway.
> >          */
> > -       if (!sync && !force_flush) {
> > -               if (!spin_trylock(&purge_lock))
> > -                       return;
> > -       } else
> > -               spin_lock(&purge_lock);
> > -
> >         if (sync)
> >                 purge_fragmented_blocks_allcpus();
> >
> > @@ -667,7 +660,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >                         __free_vmap_area(va);
> >                 spin_unlock(&vmap_area_lock);
> >         }
> > -       spin_unlock(&purge_lock);
> >  }
> >
> [..]
> > should now be safe. That should significantly reduce the preempt-disabled
> > section, I think.
> 
> I believe that the purge_lock is supposed to prevent concurrent purges
> from happening.
> 
> For the case where if you have another concurrent overflow happen in
> alloc_vmap_area() between the spin_unlock and purge :
> 
> spin_unlock(&vmap_area_lock);
> if (!purged)
>    purge_vmap_area_lazy();
> 
> Then the 2 purges would happen at the same time and could subtract
> vmap_lazy_nr twice.

That itself is not the problem, as each instance of
__purge_vmap_area_lazy() operates on its own freelist, and so there will
be no double accounting.

However, removing the lock removes the serialisation which does mean
that alloc_vmap_area() will not block on another thread conducting the
purge, and so it will try to reallocate before that is complete and the
free area made available. It also means that we are doing the
atomic_sub(vmap_lazy_nr) too early.

That supports making the outer lock a mutex as you suggested. But I think
cond_resched_lock() is better for the vmap_area_lock (just because it
turns out to be an expensive loop and we may want the reschedule).
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
