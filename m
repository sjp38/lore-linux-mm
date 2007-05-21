Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705210932500.25871@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
	 <1179385718.27354.17.camel@twins>
	 <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
	 <20070517175327.GX11115@waste.org>
	 <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
	 <1179429499.2925.26.camel@lappy>
	 <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
	 <1179437209.2925.29.camel@lappy>
	 <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
	 <1179482054.2925.52.camel@lappy>
	 <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
	 <1179650384.7019.33.camel@twins>
	 <Pine.LNX.4.64.0705210932500.25871@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 21 May 2007 21:33:58 +0200
Message-Id: <1179776038.5735.39.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Jackson <pj@sgi.com>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-21 at 09:45 -0700, Christoph Lameter wrote:
> On Sun, 20 May 2007, Peter Zijlstra wrote:
> 
> > I care about kernel allocations only. In particular about those that
> > have PF_MEMALLOC semantics.
> 
> Hmmmm.. I wish I was more familiar with PF_MEMALLOC. ccing Nick.
> 
> >  - set page->reserve nonzero for each page allocated with
> >    ALLOC_NO_WATERMARKS; which by the previous point implies that all
> >    available zones are below ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER
> 
> Ok that adds a new field to the page struct. I suggested a page flag in 
> slub before.

No it doesn't; it overloads page->index. Its just used as extra return
value, it need not be persistent. Definitely not worth a page-flag.

> >  - when a page->reserve slab is allocated store it in s->reserve_slab
> >    and do not update the ->cpu_slab[] (this forces subsequent allocs to
> >    retry the allocation).
> 
> Right that should work.
>  
> > All ALLOC_NO_WATERMARKS enabled slab allocations are served from
> > ->reserve_slab, up until the point where a !page->reserve slab alloc
> > succeeds, at which point the ->reserve_slab is pushed into the partial
> > lists and ->reserve_slab set to NULL.
> 
> So the original issue is still not fixed. A slab alloc may succeed without
> watermarks if that particular allocation is restricted to a different set 
> of nodes. Then the reserve slab is dropped despite the memory scarcity on
> another set of nodes?

I can't see how. This extra ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER alloc will
first deplete all other zones. Once that starts failing no node should
still have pages accessible by any allocation context other than
PF_MEMALLOC.

> > Since only the allocation of a new slab uses the gfp zone flags, and
> > other allocations placement hints they have to be uniform over all slab
> > allocs for a given kmem_cache. Thus the s->reserve_slab/page->reserve
> > status is kmem_cache wide.
> 
> No the gfp zone flags are not uniform and placement of page allocator 
> allocs through SLUB do not always have the same allocation constraints.

It has to; since it can serve the allocation from a pre-existing slab
allocation. Hence any page allocation must be valid for all other users.

> SLUB will check the node of the page that was allocated when the page 
> allocator returns and put the page into that nodes slab list. This varies
> depending on the allocation context.

Yes, it keeps slabs on per node lists. I'm just not seeing how this puts
hard constraints on the allocations.

As far as I can see there cannot be a hard constraint here, because
allocations form interrupt context are at best node local. And node
affine zone lists still have all zones, just ordered on locality.

> Allocations can be particular to uses of a slab in particular situations. 
> A kmalloc cache can be used to allocate from various sets of nodes in 
> different circumstances. kmalloc will allow serving a limited number of 
> objects from the wrong nodes for performance reasons but the next 
> allocation from the page allocator (or from the partial lists) will occur 
> using the current set of allowed nodes in order to ensure a rough 
> obedience to the memory policies and cpusets. kmalloc_node behaves 
> differently and will enforce using memory from a particular node.

>From what I can see, it takes pretty much any page it can get once you
hit it with PF_MEMALLOC. If the page allocation doesn't use ALLOC_CPUSET
the page can come from pretty much anywhere.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
