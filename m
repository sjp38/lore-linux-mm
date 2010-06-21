Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CF9C66B01AD
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:36:17 -0400 (EDT)
Date: Mon, 21 Jun 2010 15:32:40 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: slub: remove dynamic dma slab allocation
In-Reply-To: <alpine.DEB.2.00.1006211234230.8367@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006211521470.9272@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006181513060.20110@chino.kir.corp.google.com> <alpine.DEB.2.00.1006210919400.4513@router.home> <alpine.DEB.2.00.1006211234230.8367@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, David Rientjes wrote:

> > You cannot do that here because this function is also used later when the
> > slab is up. There is more in the percpu allocator which we are also trying
> > to use to avoid having static kmem_cache_cpu declarations. GFP_KERNEL
> > needs to be usable during early boot otherwise functions will have to add
> > special casing for boot situations.
> >
>
> The gfp_allowed_mask only changes once irqs are enabled, so either the
> gfpflags need to be passed into init_kmem_cache_nodes again or we need to
> do something like
>
> 	gfp_t gfpflags = irqs_disabled() ? GFP_NOWAIT : GFP_KERNEL;
>
> locally.

What a mess....

> The cleanest solution would probably be to extend slab_state to be set in
> kmem_cache_init_late() to determine when we're fully initialized, though.

Not sure what the point would be. Changing slab_state does not change the
interrupt enabled/disabled state of the processor.

Is gfp_allowed_mask properly updated during boot? Then we could just use

	GFP_KERNEL & gfp_allowed_mask

in these locations? Still bad since we are wasting code on correctness
checks.

Noone thought about this when designing these checks? The checks cannot be
fixed up to consider boot time so that we do not have to do artistics in
the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
