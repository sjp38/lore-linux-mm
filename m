Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0E7D6B0260
	for <linux-mm@kvack.org>; Mon, 10 May 2010 03:00:24 -0400 (EDT)
Subject: Re: numa aware lmb and sparc stuff
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100510060316.GA12250@linux-sh.org>
References: <1273466126.23699.23.camel@pasglop>
	 <20100510050158.GA24592@linux-sh.org> <1273469363.23699.26.camel@pasglop>
	 <20100510060316.GA12250@linux-sh.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 17:00:08 +1000
Message-ID: <1273474808.23699.64.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> I wouldn't call it a limitation so much as a subtle dependency. All of
> the current platforms that are supporting NUMA are doing so along with
> ARCH_POPULATES_NODE_MAP, so in those cases making the early_node_map
> dependence explicit and generic will permit the killing off of
> architecture-private data structures and accounting for region sizes and
> node mappings.

Right.

> The NUMA platforms that do not currently follow the
> ARCH_POPULATES_NODE_MAP semantics seem to already be in various states of
> disarray (generically broken, bitrotted, etc.). To that extent, perhaps
> it's also useful to have NUMA imply ARCH_POPULATES_NODE_MAP? New
> architectures that are going to opt for sparsemem or NUMA are likely
> going to end up down the ARCH_POPULATES_NODE_MAP path anyways I would
> imagine.

I tend to agree.

> That sounds fine, too. I'll certainly give it a go once the patches show
> up.

Thanks. I hope to have a first round out tonight, by no mean final, and
that doesn't handle yet all of Yinghai x86 and NO_BOOTMEM needs just
yet, but going through his patches, I'm finding that a lot of stuff in
there is either redundant or gratuitously obfuscated, so I have some
hope to get things done a bit more cleanly sooner than later :-)

I'm still not sure whether I may just implement _another_ NO_BOOTMEM
entirely: CONFIG_ARCH_BOOTMEM_USES_LMB to start with, and when x86 is
ported over to LMB, just plain kill the existing NO_BOOTMEM gunk, and
associated x86 crap that Yinghai made generic such as kernel/range.c
etc... we'll see.

Time is my main issue, and Ingo seems to have some kind of countdown
running that if we don't come up in the next few day with something
cleaner, he's going to merge all the junk for the sake of it :-)

> On a somewhat related note, is your intention with powerpc that sparsemem
> sections are always encapsulated within a single LMB region (assuming
> that the sparsemem and LMB section sizes are different)? 

To some extent yes. 16M is our huge page size and the minimum
granularity of LMB's as provided by firmware on pSeries. This is thus
also our granularity for memory hotswap, thus it made sense to use that
for our sparsemem section size.

But that's not necessarily directly related to the kernel LMB code which
will happily coalesce consecutive regions, among others. LMB doesn't
keep track of node information for now at least. I've been hesitating
about adding that or not (and preventing coalescing accross node
boundaries) but I see no obvious need right now.

> Do you simply never permit node sizes smaller than the sparsemem section
> size (ie, in the fake NUMA case)? I've been playing with this with both sparsemem and
> ARCH_HAS_HOLES_MEMORYMODEL where those sorts of combinations will be
> quite common. It would be good to have some LMB guidelines hammered out
> before people get too carried away with building infrastructure on top of
> it at least.

I'm not too familiar with the fake numa case (appart from knowing it's
broken and having patches queued up on patchwork that I haven't had a
chance to review yet) but I think it's fair to assume a node will be at
least a section I suppose.

Cheers,
Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
