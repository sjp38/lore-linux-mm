Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 15BEB6B02A6
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:33:55 -0400 (EDT)
Date: Thu, 29 Jul 2010 19:33:20 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100729183320.GH18923@n2100.arm.linux.org.uk>
References: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com> <alpine.DEB.2.00.1007281005440.21717@router.home> <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007291222410.17734@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 12:30:23PM -0500, Christoph Lameter wrote:
> On Fri, 30 Jul 2010, Minchan Kim wrote:
> 
> > But Russell doesn't want it.
> > Please, look at the discussion.
> >
> > http://www.spinics.net/lists/arm-kernel/msg93026.html
> >
> > In fact, we didn't determine the approache at that time.
> > But I think we can't give up ARM's usecase although sparse model
> > dosn't be desinged to the such granularity. and I think this approach
> 
> The sparse model goes down to page size memmap granularity. The problem
> that you may have is with aligning the maximum allocation unit of the
> page allocator with the section size of sparsemem. If you reduce your
> maximum allocation units then you can get more granularity.

Then why is there no advantage to adding 512kB memory modules in a machine
with memory spaced at 64MB apart with sparsemem - the mem_map array for
each sparsemem section is 512kB in size.  So the additional 512kB memory
modules give you nothing because they're completely full of mem_map array.

_That's_ the kind of problem that makes sparsemem unsuitable for... sparse
memory layouts found in the embedded world.

And that also makes flatmem unsuitable for use on ARM when you have such
memory layouts - four banks of discrete memory spaced at 64MB over a 256MB
range, which can have a size down to 512kB each.

And no, setting the sparse section size to 512kB doesn't work - memory is
offset by 256MB already, so you need a sparsemem section array of 1024
entries just to cover that - with the full 256MB populated, that's 512
unused entries followed by 512 used entries.  That too is going to waste
memory like nobodies business.

Basically, what's come out of this discussion is that the kernel really
_sucks_ when it comes to handling sparse memory layouts found in on ARM.

> > can solve ARM's FLATMEM's pfn_valid problem which is doing binar search.
> 
> OMG.

No, it is NOT that expensive.  Most people go "omg, binary search on
a cached architecture, that's insane".  That statement is soo far from
reality that the statement itself is insane.

The binary search operates on a very small amount of data, and results
in two or possibly three cache lines at the most being loaded, assuming
a full 8 banks of memory information passed.  Most systems pass one or
maybe two banks - so the _entire_ thing fits within one cache line - a
cache line which will have already been loaded.

So no, this binary search is not as expensive as you think it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
