Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA09360
	for <linux-mm@kvack.org>; Wed, 8 Jul 1998 18:13:45 -0400
Date: Wed, 8 Jul 1998 23:11:11 +0100
Message-Id: <199807082211.XAA14327@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980708205506.15562A-100000@mirkwood.dummy.home>
References: <199807081345.OAA01509@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980708205506.15562A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 8 Jul 1998 20:57:27 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> When my zone allocator is finished, it'll be a piece of
> cake to implement lazy page reclamation.

I've already got a working implementation.  The issue of lazy
reclamation is pretty much independent of the allocator underneath; I
don't see it being at all hard to run the lazy reclamation stuff on top
of any form of zoned allocation.

> With lazy reclamation, we simply place an upper limit
> on the number of _active_ pages. A process that's really
> thrashing away will simply be moving it's pages to/from
> the inactive list.

Exactly.  We _do_ want to be able to increase the RSS limit dynamically
to avoid moving too many pages in and out of the working set, but if the
process's working set is _that_ large, then performance will be
dominated so much by L2 cache trashing and CPU TLB misses that the extra
minor page faults we'd get are unlikely to be a catastrophic performance
problem.  

In short, if there's no contention on memory, there's no need to impose
RSS limits at all: it's just an extra performance cost.  But as soon as
physical memory contention becomes important, the RSS management is an
obvious way of restricting the performance impact of the large processes
on the rest of the system.

> And when memory pressure increases, other processes will
> start taking pages away from the inactive pages collection
> of our memory hog.

Precisely. 

> That looks quite OK to me...

Yep.  That's one of the main motivations behind the swap cache work in
2.1: the way the swapper now works, we can unhook pages from the
process's page tables and send them to swap once the RSS limit is
exceeded, but keep a copy of those pages in the swap cache so that if
the process wants a page back before we've got around to reusing the
memory, it's just a minor fault to bring it back in.  All of this code
is already present in 2.1 now.  The only thing missing is the
maintenance of the LRU list of lazy pages for reuse.

--Stephen



--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
