Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3E16B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 06:12:45 -0400 (EDT)
Date: Thu, 26 Aug 2010 11:12:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-ID: <20100826101227.GE20944@csn.ul.ie>
References: <cover.1282286941.git.m.nazarewicz@samsung.com> <1282310110.2605.976.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1282310110.2605.976.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 03:15:10PM +0200, Peter Zijlstra wrote:
> On Fri, 2010-08-20 at 11:50 +0200, Michal Nazarewicz wrote:
> > Hello everyone,
> > 
> > The following patchset implements a Contiguous Memory Allocator.  For
> > those who have not yet stumbled across CMA an excerpt from
> > documentation:
> > 
> >    The Contiguous Memory Allocator (CMA) is a framework, which allows
> >    setting up a machine-specific configuration for physically-contiguous
> >    memory management. Memory for devices is then allocated according
> >    to that configuration.
> > 
> >    The main role of the framework is not to allocate memory, but to
> >    parse and manage memory configurations, as well as to act as an
> >    in-between between device drivers and pluggable allocators. It is
> >    thus not tied to any memory allocation method or strategy.
> > 
> > For more information please refer to the second patch from the
> > patchset which contains the documentation.
> 

I'm only taking a quick look at this - slow as ever so pardon me if I
missed anything.

> So the idea is to grab a large chunk of memory at boot time and then
> later allow some device to use it?
>
> I'd much rather we'd improve the regular page allocator to be smarter
> about this. We recently added a lot of smarts to it like memory
> compaction, which allows large gobs of contiguous memory to be freed for
> things like huge pages.
> 

Quick glance tells me that buffer sizes of 20MB are being thrown about
which the core page allocator doesn't handle very well (and couldn't
without major modification). Fragmentation avoidance only works well on
sizes < MAX_ORDER_NR_PAGES which likely will be 2MB or 4MB.

That said, there are things the core VM can do to help. One is related
to ZONE_MOVABLE and the second is on the use of MIGRATE_ISOLATE.

ZONE_MOVABLE is setup when the command line has kernelcore= or movablecore=
specified. In ZONE_MOVABLE only pages that can be migrated are allocated
(or huge pages if specifically configured to be allowed).  The zone is setup
during initialisation by slicing pieces from the end of existing zones and
for various reasons, it would be best to maintain that behaviour unless CMA
had a specific requirement for memory in the middle of an existing zone.

So lets say the maximum amount of contiguous memory required by all
devices is 64M and ZONE_MOVABLE is 64M. During normal operation, normal
order-0 pages can be allocated from this zone meaning the memory is not
pinned and unusable by anybody else. This avoids wasting memory. When a
device needs a new buffer, compaction would need some additional smarts
to compact or reclaim the size of memory needed by the driver but
because all the pages in the zone are movable, it should be possible.
Ideally it would have swap to reclaim because if not, compaction needs
to know how to move pages outside a zone (something it currently
avoids).

Essentially, cma_alloc() would be a normal alloc_pages that uses
ZONE_MOVABLE for buffers < MAX_ORDER_NR_PAGES but would need additional
compaction smarts for the larger buffers. I think it would reuse as much
of the existing VM as possible but without reviewing the code, I don't
know for sure how useful the suggestion is.

> If you want guarantees you can free stuff, why not add constraints to
> the page allocation type and only allow MIGRATE_MOVABLE pages inside a
> certain region, those pages are easily freed/moved aside to satisfy
> large contiguous allocations.
> 

Relatively handy to do something like this. It can also be somewhat
contrained by doing something similar to MIGRATE_ISOLATE to have
contiguous regions of memory in a zone unusable by non-movable
allocationos. It would be a lot trickier when interacting with reclaim
though so using ZONE_MOVABLE would have less gotchas.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
