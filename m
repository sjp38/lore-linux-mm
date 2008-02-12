Date: Mon, 11 Feb 2008 16:08:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080211235607.GA27320@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802111559100.29273@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
 <20080211071828.GD8717@wotan.suse.de> <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
 <20080211234029.GB14980@wotan.suse.de> <Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
 <20080211235607.GA27320@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Nick Piggin wrote:

> > Well but does it have to do all of that on *each* allocation?
> 
> NUMA -- because of policies and zlc
> cpuset -- zone softwall stuff
> Anti fragmentation -- we can't allocate pages of a different migration type
> watermarks -- because of watermarks
> 
> Actually eg. my patch to avoid watermark checking for fastpath allocations
> is not even very nice itself, because it can result in problems like Peter
> wsa running into with slab because one PF_MEMALLOC task can refill a batch
> and others can use up the rest of the memory even if they aren't allowed
> to.
> 
> struct page initialization and checking -- yeah we could skip most of
> this in the allocation fastpath. I don't think such a patch would be too
> popular though. 
> 
> So yeah there are non-trivial issues.

We just need to make sure that repeated allocations of the same type do 
not require checking on every alloc.

So if there are no memory policies in effect and no cpuset redirection 
(can be figured out via a thread flag) and if we are doing the same 
allocation as last time (likely) then take the fastpath.

> > The slab 
> > allocators also do quite a number of things including NUMA handling but 
> > all of that is in the slow path and its not done for every single 
> > allocation.
> 
> Yeah but a lot of things it either doesn't have to worry about (eg. zones,
> anti fragmentation), or it sweeps under the carpet (policies, watermarks).

Most of these things should be handled in the page allocator right. But 
the page allocator needs to be effective at these allocations. IMHO a 
slowdown up to factor 10 vs. the slabs is not acceptable (and that was 
just an SMP test, NUMA is likely much worse!).

The pcps are likely also not effective because they use linked lists 
meaning memory in 3 pages has to be updated to extract a page from the 
lists.

So I think what would be useful is to have a single linked list of limited 
size that is taken off the freelist. All the pages are of the same flavor 
and watermark checks are only performed when the pages are taken off.

Then just do

	if (no policies or cpuset and freelist contains right flavor and is not empty)
		acquire from freelist
	else
		refill freelist

That should be doable in less than 100 cycles.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
