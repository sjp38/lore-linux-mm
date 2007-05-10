Date: Thu, 10 May 2007 23:44:41 +0100
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2, mode:0x84020
Message-ID: <20070510224441.GA15332@skynet.ie>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org> <20070510144319.48d2841a.akpm@linux-foundation.org> <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com> <20070510220657.GA14694@skynet.ie> <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com> <20070510221607.GA15084@skynet.ie> <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
From: mel@skynet.skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nicolas.Mailhot@LaPoste.net, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On (10/05/07 15:27), Christoph Lameter didst pronounce:
> On Thu, 10 May 2007, Mel Gorman wrote:
> 
> > On (10/05/07 15:11), Christoph Lameter didst pronounce:
> > > On Thu, 10 May 2007, Mel Gorman wrote:
> > > 
> > > > I see the gfpmask was 0x84020. That doesn't look like __GFP_WAIT was set,
> > > > right? Does that mean that SLUB is trying to allocate pages atomically? If so,
> > > > it would explain why this situation could still occur even though high-order
> > > > allocations that could sleep would succeed.
> > > 
> > > SLUB is following the gfp mask of the caller like all well behaved slab 
> > > allocators do. If the caller does not set __GFP_WAIT then the page 
> > > allocator also cannot wait.
> > 
> > Then SLUB should not use the higher orders for slab allocations that cannot
> > sleep during allocations. What could be done in the longer term is decide
> > how to tell kswapd to keep pages free at an order other than 0 when it is
> > known there are a large number of high-order long-lived allocations like this.
> 
> I cannot predict how allocations on a slab will be performed. In order 
> to avoid the higher order allocations in we would have to add a flag 
> that tells SLUB at slab creation creation time that this cache will be 
> used for atomic allocs and thus we can avoid configuring slabs in such a 
> way that they use higher order allocs.
> 

It is an option. I had the gfp flags passed in to kmem_cache_create() in
mind for determining this but SLUB creates slabs differently and different
flags could be passed into kmem_cache_alloc() of course.

> The other solution is not to use higher order allocations by dropping the 
> antifrag patches in mm that allow SLUB to use higher order allocations. 
> But then there would be no higher order allocations at all that would
> use the benefits of antifrag measures.

That would be an immediate solution.

Another alternative is that anti-frag used to also group high-order
allocations together and make it hard to fallback to those areas
for non-atomic allocations. It is currently backed out by the
patch dont-group-high-order-atomic-allocations.patch because
it was intended for rare high-order short-lived allocations
such as e1000 that are currently dealt with by MIGRATE_RESERVE
(bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch)
. The high-order atomic groupings may help here because the high-order
allocations are long-lived and would claim contiguous areas.

The last alternative I think I mentioned already is to have the minimum
order kswapd reclaims as the same order SLUB uses instead of 0 so that
min_free_kbytes is kept at higher orders than current.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
