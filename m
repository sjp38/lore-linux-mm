Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F90F6B01BA
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 17:09:02 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o5LL90cR009036
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 14:09:00 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz17.hot.corp.google.com with ESMTP id o5LL8wKd031862
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 14:08:59 -0700
Received: by pwj1 with SMTP id 1so643986pwj.13
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 14:08:58 -0700 (PDT)
Date: Mon, 21 Jun 2010 14:08:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1006211521470.9272@router.home>
Message-ID: <alpine.DEB.2.00.1006211354440.31743@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006181513060.20110@chino.kir.corp.google.com> <alpine.DEB.2.00.1006210919400.4513@router.home> <alpine.DEB.2.00.1006211234230.8367@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1006211521470.9272@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, Christoph Lameter wrote:

> > > You cannot do that here because this function is also used later when the
> > > slab is up. There is more in the percpu allocator which we are also trying
> > > to use to avoid having static kmem_cache_cpu declarations. GFP_KERNEL
> > > needs to be usable during early boot otherwise functions will have to add
> > > special casing for boot situations.
> > >
> >
> > The gfp_allowed_mask only changes once irqs are enabled, so either the
> > gfpflags need to be passed into init_kmem_cache_nodes again or we need to
> > do something like
> >
> > 	gfp_t gfpflags = irqs_disabled() ? GFP_NOWAIT : GFP_KERNEL;
> >
> > locally.
> 
> What a mess....
> 
> > The cleanest solution would probably be to extend slab_state to be set in
> > kmem_cache_init_late() to determine when we're fully initialized, though.
> 
> Not sure what the point would be. Changing slab_state does not change the
> interrupt enabled/disabled state of the processor.
> 

If you added an even higher slab_state level than UP and set it in 
kmem_cache_init_late(), then you could check for it to determine 
GFP_NOWAIT or GFP_KERNEL in init_kmem_cache_nodes() rather than 
irqs_disabled() because that's the only real event that requires 
kmem_cache_init_late() to need to exist in the first place.

I'm not sure if you'd ever use that state again, but it's robust if 
anything is ever added in the space between kmem_cache_init() and 
kmem_cache_init_late() for a reason.  slab_is_available() certainly 
doesn't need it because we don't kmem_cache_create() in between the two.

When you consider those solutions, it doesn't appear as though removing 
the gfp_t formal in init_kmem_cache_nodes() is really that much of a 
cleanup.

> Is gfp_allowed_mask properly updated during boot? Then we could just use
> 
> 	GFP_KERNEL & gfp_allowed_mask
> 
> in these locations? Still bad since we are wasting code on correctness
> checks.
> 

That certainly does get us GFP_NOWAIT (same as GFP_BOOT_MASK) before irqs 
are enabled and GFP_KERNEL afterwards since gfp_allowed_mask is updated at 
the same time.  If it's worth getting of the gfp_t formal in 
init_kmem_cache_nodes() so much, then that masking would deserve a big fat 
comment :)

> Noone thought about this when designing these checks? The checks cannot be
> fixed up to consider boot time so that we do not have to do artistics in
> the code?
> 

I think gfp_allowed_mask is the intended solution since it simply masks 
off GFP_KERNEL and turns those allocations into GFP_BOOT_MASK before it 
gets updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
