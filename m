From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [PATCH 0/3] bootmem2 III
References: <20080509151713.939253437@saeurebad.de>
	<20080509184044.GA19109@one.firstfloor.org>
	<87lk2gtzta.fsf@saeurebad.de> <48275493.40601@firstfloor.org>
Date: Tue, 13 May 2008 14:40:44 +0200
In-Reply-To: <48275493.40601@firstfloor.org> (Andi Kleen's message of "Sun, 11
	May 2008 22:18:27 +0200")
Message-ID: <874p92qsvn.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

Andi Kleen <andi@firstfloor.org> writes:

> Johannes Weiner wrote:
>
>>> On Fri, May 09, 2008 at 05:17:13PM +0200, Johannes Weiner wrote:
>>>> here is bootmem2, a memory block-oriented boot time allocator.
>>>>
>>>> Recent NUMA topologies broke the current bootmem's assumption that
>>>> memory nodes provide non-overlapping and contiguous ranges of pages.
>>> I'm still not sure that's a really good rationale for bootmem2.
>>> e.g. the non continuous nodes are really special cases and there tends
>>> to be enough memory at the beginning which is enough for boot time
>>> use, so for those systems it would be quite reasonably to only 
>>> put the continuous starts of the nodes into bootmem.
>> 
>> Hm, that would put the logic into arch-code.  I have no strong opinion
>> about it.
>
> In fact I suspect the current code will already work like that
> implicitely. The aliasing is only a problem for the new "arbitary node
> free_bootmem" right?

And that alloc_bootmem_node() can not garuantee node-locality which is
the much worse part, I think.

>>> That said the bootmem code has gotten a little crufty and a clean
>>> rewrite might be a good idea.
>> 
>> I agree completely.
>
> The trouble is just that bootmem is used in early boot and early boot is
> very subtle and getting it working over all architectures could be a
> challenge. Not wanting to discourage you, but it's not exactly the
> easiest part of the kernel to hack on.

Bootmem seemed pretty self-contained to me, at least in the beginning.
The bad thing is that I can test only the most simple configuration with
it.

I was wondering yesterday if it would be feasible to enforce
contiguousness for nodes.  So that arch-code does not create one pgdat
for each node but one for each contiguous block.  I have not yet looked
deeper into it, but I suspect that other mm code has similar problems
with nodes spanning other nodes.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
