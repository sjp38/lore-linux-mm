Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53A3C6B0071
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:38:41 -0400 (EDT)
Date: Wed, 16 Jun 2010 12:35:14 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] slub: Simplify boot kmem_cache_cpu allocations
In-Reply-To: <4C190748.7030400@kernel.org>
Message-ID: <alpine.DEB.2.00.1006161231420.6361@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010, Tejun Heo wrote:

> Hello,
>
> On 06/16/2010 06:33 PM, Christoph Lameter wrote:
> > On Wed, 16 Jun 2010, Tejun Heo wrote:
> >>> Tejun: Is it somehow possible to reliably use the alloc_percpu() on all
> >>> platforms during early boot before the slab allocator is up?
> >>
> >> Hmmm... first chunk allocation is done using bootmem, so if we give it
> >> enough to room (for both chunk itself and alloc map) so that it can
> >> serve till slab comes up, it should work fine.  I think what's
> >> important here is making up our minds and decide on how to order them.
> >> If the order is well defined, things can be made to work one way or
> >> the other.  What happened to the get-rid-of-bootmem effort?  Wouldn't
> >> that also interact with this?
> >
> > Ok how do we make sure that the first chunk has enough room?
>
> It's primarily controlled by PERCPU_DYNAMIC_RESERVE.  I don't think
> there will be any systematic way to do it other than sizing it
> sufficiently.  Can you calculate the upper bound?  The constant has
> been used primarily for optimization so how it's used needs to be
> audited if we wanna guarantee free space in the first chunk but I
> don't think it would be too difficult.

The upper bound is SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu).

Thats usually 14 * 104 bytes = 1456 bytes. This may increase to more
than 8k given the future plans to add queues into kmem_cache_cpu.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
