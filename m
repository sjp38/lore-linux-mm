Date: Thu, 15 May 2008 20:12:10 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/3] bootmem2 III
Message-ID: <20080515191210.GE21787@shadowen.org>
References: <20080509151713.939253437@saeurebad.de> <20080509184044.GA19109@one.firstfloor.org> <87lk2gtzta.fsf@saeurebad.de> <48275493.40601@firstfloor.org> <874p92qsvn.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874p92qsvn.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 02:40:44PM +0200, Johannes Weiner wrote:
> Hi,
> 
> Andi Kleen <andi@firstfloor.org> writes:
> 
> > Johannes Weiner wrote:
> >
> >>> On Fri, May 09, 2008 at 05:17:13PM +0200, Johannes Weiner wrote:
> >>>> here is bootmem2, a memory block-oriented boot time allocator.
> >>>>
> >>>> Recent NUMA topologies broke the current bootmem's assumption that
> >>>> memory nodes provide non-overlapping and contiguous ranges of pages.
> >>> I'm still not sure that's a really good rationale for bootmem2.
> >>> e.g. the non continuous nodes are really special cases and there tends
> >>> to be enough memory at the beginning which is enough for boot time
> >>> use, so for those systems it would be quite reasonably to only 
> >>> put the continuous starts of the nodes into bootmem.
> >> 
> >> Hm, that would put the logic into arch-code.  I have no strong opinion
> >> about it.
> >
> > In fact I suspect the current code will already work like that
> > implicitely. The aliasing is only a problem for the new "arbitary node
> > free_bootmem" right?
> 
> And that alloc_bootmem_node() can not garuantee node-locality which is
> the much worse part, I think.
> 
> >>> That said the bootmem code has gotten a little crufty and a clean
> >>> rewrite might be a good idea.
> >> 
> >> I agree completely.
> >
> > The trouble is just that bootmem is used in early boot and early boot is
> > very subtle and getting it working over all architectures could be a
> > challenge. Not wanting to discourage you, but it's not exactly the
> > easiest part of the kernel to hack on.
> 
> Bootmem seemed pretty self-contained to me, at least in the beginning.
> The bad thing is that I can test only the most simple configuration with
> it.
> 
> I was wondering yesterday if it would be feasible to enforce
> contiguousness for nodes.  So that arch-code does not create one pgdat
> for each node but one for each contiguous block.  I have not yet looked

That re-introduces the concept that a node is not a unit of numa locality,
but one of memory contiguity.  The kernel pretty much assumes that a node
exhibits memory locality.  

> deeper into it, but I suspect that other mm code has similar problems
> with nodes spanning other nodes.

One thing we do know is that we already have systems in the wild with
overlapping nodes.  PowerPC systems sometimes exhibit this behaviour, the
ones I have seen have node 1 embedded within node 0.  x86_64 also enables
this support.  This necessitated checks when initially freeing memory
into the allocator to make sure it ended up freed into the right node.
For non-sparsemem configurations these systems have some wasted mem_map,
but otherwise it does work.

Check out NODES_SPAN_OTHER_NODES for the code to avoid miss-placing
memory.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
