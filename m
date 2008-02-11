Date: Tue, 12 Feb 2008 00:56:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080211235607.GA27320@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080209143518.ced71a48.akpm@linux-foundation.org> <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com> <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com> <20080211071828.GD8717@wotan.suse.de> <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com> <20080211234029.GB14980@wotan.suse.de> <Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2008 at 03:42:34PM -0800, Christoph Lameter wrote:
> On Tue, 12 Feb 2008, Nick Piggin wrote:
> 
> > It might be possible but would take quite a bit of rework (eg. have a
> > look at pcp->count and the horrible anti fragmentation loops).
> 
> Yeah. May influece the way we have to handle freelists. Sigh.
> 
> > > The fastpath use will be reduced to 50% since every other 
> > > allocation will have to go to the page allocator. Maybe we can do that 
> > > if the page allocator performance is up to snuff.
> > 
> > The page allocator has to do quite a lot more than the slab allocator
> > does. It has to check watermarks and all the NUMA and zone and anti
> > fragmentation stuff, and does quite a lot of branches and stores to
> > tes tand set up the struct page.
> > 
> > So it's never going to be as fast as a simple slab allocation.
> 
> Well but does it have to do all of that on *each* allocation?

NUMA -- because of policies and zlc
cpuset -- zone softwall stuff
Anti fragmentation -- we can't allocate pages of a different migration type
watermarks -- because of watermarks

Actually eg. my patch to avoid watermark checking for fastpath allocations
is not even very nice itself, because it can result in problems like Peter
wsa running into with slab because one PF_MEMALLOC task can refill a batch
and others can use up the rest of the memory even if they aren't allowed
to.

struct page initialization and checking -- yeah we could skip most of
this in the allocation fastpath. I don't think such a patch would be too
popular though. 

So yeah there are non-trivial issues.


> The slab 
> allocators also do quite a number of things including NUMA handling but 
> all of that is in the slow path and its not done for every single 
> allocation.

Yeah but a lot of things it either doesn't have to worry about (eg. zones,
anti fragmentation), or it sweeps under the carpet (policies, watermarks).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
