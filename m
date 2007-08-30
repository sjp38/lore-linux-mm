Date: Thu, 30 Aug 2007 05:16:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] radix-tree: be a nice citizen
Message-ID: <20070830031626.GA26257@wotan.suse.de>
References: <20070829085039.GA32236@wotan.suse.de> <20070829015702.7c8567c2.akpm@linux-foundation.org> <20070829090301.GB32236@wotan.suse.de> <20070829022044.9730888e.akpm@linux-foundation.org> <20070829094503.GC32236@wotan.suse.de> <20070829154531.fd6d67bc.akpm@linux-foundation.org> <20070830012237.GA19405@wotan.suse.de> <20070829190804.c4a4587d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070829190804.c4a4587d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 29, 2007 at 07:08:04PM -0700, Andrew Morton wrote:
> On Thu, 30 Aug 2007 03:22:37 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Wed, Aug 29, 2007 at 03:45:31PM -0700, Andrew Morton wrote:
> > > On Wed, 29 Aug 2007 11:45:03 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > > Yeah I'm sure the radix_tree_insert isn't failing, but the
> > > > first kmem_cache_alloc in radix_tree_node_alloc is failing (page
> > > > allocator is giving the backtrace). Because it is GFP_ATOMIC and
> > > > being done under the spinlock.
> > > 
> > > OK, that's expected.  Add a __GFP_NOWARN to the caller's gfp_t?
> > 
> > It eats GFP_ATOMIC reserves
> 
> Really?  The caller does a great pile of GFP_HIGHUSER pagecache allocations
> for each page which he allocates for ratnodes.  I guess if we're a highmem
> machine then we could be low on ZONE_NORMAL, but have plenty of
> ZONE_HIGHMEM available, so maybe in that situation the kernel could end up
> chewing away a significant amount of the lowmem reserve, dunno.

Yeah, and not just that. We can be allocating pages from ZONE_NORMAL but
nodes from ZONE_DMA, or allocating pages off-node and nodes from atomic
reserves.

 
> But I'm more suspecting that your ZONE_NORMAL got eaten by something else
> (networking?) and the radix-tree allocation failure you saw was collateral
> damage?

It was, but it reminded me it should be fixed. There is a reasonable
chance it will actually happen now and again with heavy loads and
more than a single zone and node. Barely noticable? Probably, but
every little bit helps.


> > (and yes, we could ad a ~__GFP_HIGH, but
> > the allocator still has a small reserve for non-sleeping GFP_KERNEL
> > allocations, so it would eat that).
> 
> spose so.
> 
> I'm still struggling to see whether the value of the proposed fix is worth
> the additional overhead?

What aditional overhead? Nothing jumps out at me... we've already touched
the per-cpu data in preload()...

If anything, I would have thought this behaviour is preferable because now
we don't have to worry about potentially taking a heavily contended
zone->lock and a lot of cachelines misses splitting up a huge buddy page to
4K, and filling a pcp->batch worth of pages, all while holding tree_lock ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
