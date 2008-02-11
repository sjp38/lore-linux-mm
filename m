Date: Tue, 12 Feb 2008 00:40:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080211234029.GB14980@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080209143518.ced71a48.akpm@linux-foundation.org> <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com> <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com> <20080211071828.GD8717@wotan.suse.de> <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2008 at 11:21:59AM -0800, Christoph Lameter wrote:
> On Mon, 11 Feb 2008, Nick Piggin wrote:
> 
> > OK, it's a bit variable, so I used 20 10 second runs and took the average.
> > With this patch, I got a 1% increase of that average (with 2.6.25-rc1 and
> > slub).
> > 
> > It avoids some branches and tests; doesn't check the watermarks if there
> > are pcp pages; avoids atomic refcounting operations in the caller requests
> > it (this is really annoying because it adds another branch -- I don't think
> > we should be funneling all these options through flags, rather provide a
> > few helpers or something for it).
> 
> Hmmm... That is a bit weak. The slub patch gets you around 3-5%. I thought 
> maybe we could do something like the slub cmpxchg_local fastpath for the 
> page allocator?

It might be possible but would take quite a bit of rework (eg. have a
look at pcp->count and the horrible anti fragmentation loops).


> > I don't know if this will get back all the regression, but it should help
> > (although I guess we should do the same refcounting for slab, so that
> > might speed up a bit too).
> > 
> > BTW. could you please make kmalloc-2048 just use order-0 allocations by
> > default, like kmalloc-1024 and kmalloc-4096, and kmalloc-2048 with slub.
> 
> The mininum number of objects per slab is currently 4 that means that 1k 
> slabs can use order 0 allocs but 2k slabs must use order 2 in order to get 
> 4 objects. If I reduce that then the performance for 2k slabs may become 
> a problem.

It doesn't make sense that 4K allocations use order-0 but 2K do not. And
it is a regression because slab uses order-0 for 2K.


> The fastpath use will be reduced to 50% since every other 
> allocation will have to go to the page allocator. Maybe we can do that 
> if the page allocator performance is up to snuff.

The page allocator has to do quite a lot more than the slab allocator
does. It has to check watermarks and all the NUMA and zone and anti
fragmentation stuff, and does quite a lot of branches and stores to
tes tand set up the struct page.

So it's never going to be as fast as a simple slab allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
