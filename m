Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6B0E6B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 09:56:30 -0400 (EDT)
Date: Tue, 17 Aug 2010 08:56:28 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <4C6A408C.6040203@kernel.org>
Message-ID: <alpine.DEB.2.00.1008170854060.7853@router.home>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com> <alpine.DEB.2.00.1008051231400.6787@router.home>
 <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com> <4C6A408C.6040203@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Tejun Heo wrote:

> Hello,
>
> On 08/17/2010 06:56 AM, David Rientjes wrote:
> > I'm adding Tejun Heo to the cc because of another thing that may be
> > problematic: alloc_percpu() allocates GFP_KERNEL memory, so when we try to
> > allocate kmem_cache_cpu for a DMA cache we may be returning memory from a
> > node that doesn't include lowmem so there will be no affinity between the
> > struct and the slab.  I'm wondering if it would be better for the percpu
> > allocator to be extended for kzalloc_node(), or vmalloc_node(), when
> > allocating memory after the slab layer is up.
>
> Hmmm... do you mean adding @gfp_mask to percpu allocation function?

DMA caches may only exist on certain nodes because others do not have a
DMA zone. Their role is quite limited these days. DMA caches allocated on
nodes without DMA zones would have their percpu area allocated on the node
but the DMA allocations would be redirected to the closest node with DMA
memory.

> I've been thinking about adding it for atomic allocations (Christoph,
> do you still want it?).  I've been sort of against it because I
> primarily don't really like atomic allocations (it often just pushes
> error handling complexities elsewhere where it becomes more complex)
> and it would also require making vmalloc code do atomic allocations.

At this point I would think that we do not need that support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
