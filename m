Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705161320020.11018@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
	 <1179164453.2942.26.camel@lappy>
	 <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
	 <1179170912.2942.37.camel@lappy> <1179250036.7173.7.camel@twins>
	 <Pine.LNX.4.64.0705151457060.3155@schroedinger.engr.sgi.com>
	 <1179298771.7173.16.camel@twins>
	 <Pine.LNX.4.64.0705161139540.10265@schroedinger.engr.sgi.com>
	 <1179343521.2912.20.camel@lappy>
	 <Pine.LNX.4.64.0705161235490.10660@schroedinger.engr.sgi.com>
	 <1179346738.2912.39.camel@lappy>
	 <Pine.LNX.4.64.0705161320020.11018@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 22:40:39 +0200
Message-Id: <1179348039.2912.48.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 13:27 -0700, Christoph Lameter wrote:
> On Wed, 16 May 2007, Peter Zijlstra wrote:
> 
> > > So its no use on NUMA?
> > 
> > It is, its just that we're swapping very heavily at that point, a
> > bouncing cache-line will not significantly slow down the box compared to
> > waiting for block IO, will it?
> 
> How does all of this interact with
> 
> 1. cpusets
> 
> 2. dma allocations and highmem?
> 
> 3. Containers?

Much like the normal kmem_cache would do; I'm not changing any of the
page allocation semantics.

For containers it could be that the machine is not actually swapping but
the container will be in dire straights.

> > > The problem here is that you may spinlock and take out the slab for one 
> > > cpu but then (AFAICT) other cpus can still not get their high priority 
> > > allocs satisfied. Some comments follow.
> > 
> > All cpus are redirected to ->reserve_slab when the regular allocations
> > start to fail.
> 
> And the reserve slab is refilled from page allocator reserves if needed?

Yes, using new_slab(), exacly as it would normally be.

> > > But this is only working if we are using the slab after
> > > explicitly flushing the cpuslabs. Otherwise the slab may be full and we
> > > get to alloc_slab.
> > 
> > /me fails to parse.
> 
> s->cpu[cpu] is only NULL if the cpu slab was flushed. This is a pretty 
> rare case likely not worth checking.

Ah, right:
 - !page || !page->freelist
 - and no available partial slabs.

then we try the reserve (if we're entiteld).

> > > Remove the above two lines (they are wrong regardless) and simply make 
> > > this the cpu slab.
> > 
> > It need not be the same node; the reserve_slab is node agnostic.
> > So here the free page watermarks are good again, and we can forget all
> > about the ->reserve_slab. We just push it on the free/partial lists and
> > forget about it.
> > 
> > But like you said above: unfreeze_slab() should be good, since I don't
> > use the lockless_freelist.
> 
> You could completely bypass the regular allocation functions and do
> 
> object = s->reserve_slab->freelist;
> s->reserve_slab->freelist = object[s->reserve_slab->offset];

That is basically what happens at the end; if an object is returned from
the reserve slab.

But its wanted to try the normal cpu_slab path first to detect that the
situation has subsided and we can resume normal operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
