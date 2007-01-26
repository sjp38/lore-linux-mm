Date: Fri, 26 Jan 2007 08:21:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0701260812150.6141@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007, Mel Gorman wrote:

> The following 8 patches against 2.6.20-rc4-mm1 create a zone called
> ZONE_MOVABLE that is only usable by allocations that specify both __GFP_HIGHMEM
> and __GFP_MOVABLE. This has the effect of keeping all non-movable pages
> within a single memory partition while allowing movable allocations to be
> satisified from either partition.

For arches that do not have HIGHMEM other zones would be okay too it 
seems.

> The size of the zone is determined by a kernelcore= parameter specified at
> boot-time. This specifies how much memory is usable by non-movable allocations
> and the remainder is used for ZONE_MOVABLE. Any range of pages within
> ZONE_MOVABLE can be released by migrating the pages or by reclaiming.

The user has to manually fiddle around with the size of the unmovable 
partition until it works?

> When selecting a zone to take pages from for ZONE_MOVABLE, there are two
> things to consider. First, only memory from the highest populated zone is
> used for ZONE_MOVABLE. On the x86, this is probably going to be ZONE_HIGHMEM
> but it would be ZONE_DMA on ppc64 or possibly ZONE_DMA32 on x86_64. Second,
> the amount of memory usable by the kernel will be spreadly evenly throughout
> NUMA nodes where possible. If the nodes are not of equal size, the amount
> of memory usable by the kernel on some nodes may be greater than others.

So how is the amount of movable memory on a node calculated? Evenly 
distributed? There are some NUMA architectures that are not that 
symmetric.

> By default, the zone is not as useful for hugetlb allocations because they
> are pinned and non-migratable (currently at least). A sysctl is provided that
> allows huge pages to be allocated from that zone. This means that the huge
> page pool can be resized to the size of ZONE_MOVABLE during the lifetime of
> the system assuming that pages are not mlocked. Despite huge pages being
> non-movable, we do not introduce additional external fragmentation of note
> as huge pages are always the largest contiguous block we care about.

The user already has to specify the partitioning of the system at bootup 
and could take the huge page sizes into account.

Also huge pages may have variable sizes that can be specified on bootup 
for IA64. The assumption that a huge page is always the largest 
contiguous block is *not true*.

The huge page sizes on i386 and x86_64 platforms are contigent on 
their page table structure. This can be completely different on other 
platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
