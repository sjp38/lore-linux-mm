Date: Wed, 1 Nov 2006 18:13:21 +0000
Subject: Re: Page allocator: Single Zone optimizations
Message-ID: <20061101181320.GB27386@skynet.ie>
References: <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com> <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org> <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com> <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com> <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (27/10/06 19:31), Christoph Lameter didst pronounce:
> On Fri, 27 Oct 2006, Andrew Morton wrote:
> 
> > We need some way of preventing unreclaimable kernel memory allocations from
> > using certain physical pages.  That means zones.
> 
> Well then we may need zones for defragmentation and zeroed pages as well 
> etc etc. The problem is that such things make the VM much more 
> complex and not simpler and faster.
> 

You don't need new zones for defragmentation and pre-zeroed pages. I reposted
the anti-fragmentation patches which create sub-zone-freelists for pages
of each type of reclaimability. Previously, an additional list existed for
prezerod pages but I don't think I ever showed a performance improvement
with them so I dropped them after a while.

> > > Memory hot unplug 
> > > seems to have been dropped in favor of baloons.
> > 
> > Has it?  I don't recall seeing a vague proposal, let alone an implementation?
> 
> That is the impression that I got at the OLS. There were lots of talks 
> about baloons approaches.
> 

Memory hot-unplug is not quite dead but there not everything existed that
was required to really make it work. The most obvious problem was that kernel
allocations were in the middle of the region you were trying to unplug. The
anti-fragmentation patches introduce a __GFP_EASYRCLM flag that can be used
to flag allocations that can be really reclaimed.

Patches also exist to create a zone for hot-unplug but sizing it at boot
time was a total mess. This is a lot easier with architecture-independent
zone-sizing and I can bring forward some patches if people want to take a
look. However, no infrastrcture exists for moving memory between zones or
choosing what zone to hot-add memory to.

Power at least is able to hot-remove a MAX_ORDER_NR_PAGES block of pages and
give it back to the hypervisor (AFAIK, could be wrong) but fragmentation was
a problem. List-based anti-fragmentation was shown a long time ago to improve
the success rates of a memory-unplug but I haven't tried in a long time.

> > Userspace allocations are reclaimable: pagecache, anonymous memory.  These
> > happen to be allocated with __GFP_HIGHMEM set.
> 
> On certain platforms yes.
> 

The list-based anti-fragmentation patches flag the really-reclaimable
allocations as __GFP_EASYRCLM regardless of what zone they are allocated
from. mlock() is a problem but page migration could address it.

> > So right now __GFP_HIGHMEM is an excellent hint telling the page allocator
> > that it is safe to satisfy this request from removeable memory.
> 
> OK this works on i386 but most other platforms wont have a highmem 
> zone.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
