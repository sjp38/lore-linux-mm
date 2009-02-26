Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2187D6B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 04:14:05 -0500 (EST)
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: Lin Ming <ming.m.lin@intel.com>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 26 Feb 2009 17:10:27 +0800
Message-Id: <1235639427.11390.11.camel@minggr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

We tested this v2 patch series with 2.6.29-rc6 on different machines.

		4P qual-core	2P qual-core	2P qual-core HT
		tigerton	stockley	Nehalem
		------------------------------------------------
tbench		+3%		+2%		0%
oltp		-2%		0%		0%
aim7		0%		0%		0%
specjbb2005	+3%		0%		0%
hackbench	0%		0%		0%	

netperf:
TCP-S-112k	0%		-1%		0%
TCP-S-64k	0%		-1%		+1%
TCP-RR-1	0%		0%		+1%
UDP-U-4k	-2%		0%		-2%
UDP-U-1k	+3%		0%		0%
UDP-RR-1	0%		0%		0%
UDP-RR-512	-1%		0%		+1%

Lin Ming

On Tue, 2009-02-24 at 20:16 +0800, Mel Gorman wrote:
> Still a work in progress but enough has changed that I want to show what
> it current looks like. Performance is still improved a little but there are
> some large outstanding pieces of fruit
> 
> 1. Improving free_pcppages_bulk() does a lot of looping, maybe could be better
> 2. gfp_zone() is still using a cache line for data. I wasn't able to translate
>    Kamezawa-sans suggestion into usable code
> 
> The following two items should be picked up in a second or third pass at
> improving the page allocator
> 
> 1. Working out if knowing whether pages are cold/hot on free is worth it or
>    not
> 2. Precalculating zonelists for cpusets (Andi described how it could be done,
>    it's straight-forward, just will take time but it doesn't affect the
>    majority of users)
> 
> Changes since V1
>   o Remove the ifdef CONFIG_CPUSETS from inside get_page_from_freelist()
>   o Use non-lock bit operations for clearing the mlock flag
>   o Factor out alloc_flags calculation so it is only done once (Peter)
>   o Make gfp.h a bit prettier and clear-cut (Peter)
>   o Instead of deleting a debugging check, replace page_count() in the
>     free path with a version that does not check for compound pages (Nick)
>   o Drop the alteration for hot/cold page freeing until we know if it
>     helps or not
> 
> The complexity of the page allocator has been increasing for some time
> and it has now reached the point where the SLUB allocator is doing strange
> tricks to avoid the page allocator. This is obviously bad as it may encourage
> other subsystems to try avoiding the page allocator as well.
> 
> This series of patches is intended to reduce the cost of the page
> allocator by doing the following.
> 
> Patches 1-3 iron out the entry paths slightly and remove stupid sanity
> checks from the fast path.
> 
> Patch 4 uses a lookup table instead of a number of branches to decide what
> zones are usable given the GFP flags.
> 
> Patch 5 tidies up some flags
> 
> Patch 6 avoids repeated checks of the zonelist
> 
> Patch 7 breaks the allocator up into a fast and slow path where the fast
> path later becomes one long inlined function.
> 
> Patches 8-12 avoids calculating the same things repeatedly and instead
> calculates them once.
> 
> Patches 13-14 inline parts of the allocator fast path
> 
> Patch 15 avoids calling get_pageblock_migratetype() potentially twice on
> every page free
> 
> Patch 16 reduces the number of times interrupts are disabled by reworking
> what free_page_mlock() does and not using locked versions of bit operations.
> 
> Patch 17 avoids using the zonelist cache on non-NUMA machines
> 
> Patch 18 simplifies some debugging checks made during alloc and free.
> 
> Patch 19 avoids a list search in the allocator fast path.
> 
> Running all of these through a profiler shows me the cost of page allocation
> and freeing is reduced by a nice amount without drastically altering how the
> allocator actually works. Excluding the cost of zeroing pages, the cost of
> allocation is reduced by 25% and the cost of freeing by 12%.  Again excluding
> zeroing a page, much of the remaining cost is due to counters, debugging
> checks and interrupt disabling.  Of course when a page has to be zeroed,
> the dominant cost of a page allocation is zeroing it.
> 
> These patches reduce the text size of the kernel by 180 bytes on the one
> x86-64 machine I checked.
> 
> Range of results (positive is good) on 7 machines that completed tests.
> 
> o Kernbench elapsed time	-0.04	to	0.79%
> o Kernbench system time		0 	to	3.74%
> o tbench			-2.85%  to	5.52%
> o Hackbench-sockets		all differences within  noise
> o Hackbench-pipes		-2.98%  to	9.11%
> o Sysbench			-0.04%  to	5.50%
> 
> With hackbench-pipes, only 2 machines out of 7 showed results outside of
> the noise. In almost all cases the strandard deviation between runs of
> hackbench-pipes was reduced with the patches.
> 
> I still haven't run a page-allocator micro-benchmark to see what sort of
> figures that gives.
> 
>  arch/ia64/hp/common/sba_iommu.c   |    2 
>  arch/ia64/kernel/mca.c            |    3 
>  arch/ia64/kernel/uncached.c       |    3 
>  arch/ia64/sn/pci/pci_dma.c        |    3 
>  arch/powerpc/platforms/cell/ras.c |    2 
>  arch/x86/kvm/vmx.c                |    2 
>  drivers/misc/sgi-gru/grufile.c    |    2 
>  drivers/misc/sgi-xp/xpc_uv.c      |    2 
>  include/linux/cpuset.h            |    2 
>  include/linux/gfp.h               |   62 +--
>  include/linux/mm.h                |    1 
>  include/linux/mmzone.h            |    8 
>  init/main.c                       |    1 
>  kernel/profile.c                  |    8 
>  mm/filemap.c                      |    2 
>  mm/hugetlb.c                      |    4 
>  mm/internal.h                     |   11 
>  mm/mempolicy.c                    |    2 
>  mm/migrate.c                      |    2 
>  mm/page_alloc.c                   |  642 +++++++++++++++++++++++++-------------
>  mm/slab.c                         |    4 
>  mm/slob.c                         |    4 
>  mm/vmalloc.c                      |    1 
>  23 files changed, 490 insertions(+), 283 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
