Date: Fri, 26 Jan 2007 16:48:04 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <Pine.LNX.4.64.0701260812150.6141@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701261629050.23091@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260812150.6141@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Christoph Lameter wrote:

> On Thu, 25 Jan 2007, Mel Gorman wrote:
>
>> The following 8 patches against 2.6.20-rc4-mm1 create a zone called
>> ZONE_MOVABLE that is only usable by allocations that specify both __GFP_HIGHMEM
>> and __GFP_MOVABLE. This has the effect of keeping all non-movable pages
>> within a single memory partition while allowing movable allocations to be
>> satisified from either partition.
>
> For arches that do not have HIGHMEM other zones would be okay too it
> seems.
>

It would, but it'd obscure the code to take advantage of that.

>> The size of the zone is determined by a kernelcore= parameter specified at
>> boot-time. This specifies how much memory is usable by non-movable allocations
>> and the remainder is used for ZONE_MOVABLE. Any range of pages within
>> ZONE_MOVABLE can be released by migrating the pages or by reclaiming.
>
> The user has to manually fiddle around with the size of the unmovable
> partition until it works?
>

They have to fiddle with the size of the unmovable partition if their 
workload uses more unmovable kernel allocations than expected. This was 
always going to be the restriction with using zones for partitioning 
memory. Resizing zones on the fly is not really an option because the 
resizing would only work reliably in one direction.

The anti-fragmentation code could potentially be used to have subzone 
groups that kept movable and unmovable allocations as far apart as 
possible and at opposite ends of a zone. That approach has been kicked a 
few times because of complexity.

>> When selecting a zone to take pages from for ZONE_MOVABLE, there are two
>> things to consider. First, only memory from the highest populated zone is
>> used for ZONE_MOVABLE. On the x86, this is probably going to be ZONE_HIGHMEM
>> but it would be ZONE_DMA on ppc64 or possibly ZONE_DMA32 on x86_64. Second,
>> the amount of memory usable by the kernel will be spreadly evenly throughout
>> NUMA nodes where possible. If the nodes are not of equal size, the amount
>> of memory usable by the kernel on some nodes may be greater than others.
>
> So how is the amount of movable memory on a node calculated?

Subtle difference. The amount of unmovable memory is calculated per node.

> Evenly
> distributed?

As evenly as possible.

> There are some NUMA architectures that are not that
> symmetric.
>

I know, it's why find_zone_movable_pfns_for_nodes() is as complex as it 
is. The mechanism spreads the unmovable memory evenly throughout all 
nodes. In the event some nodes are too small to hold their share, the 
remaining unmovable memory is divided between the nodes that are larger.

>> By default, the zone is not as useful for hugetlb allocations because they
>> are pinned and non-migratable (currently at least). A sysctl is provided that
>> allows huge pages to be allocated from that zone. This means that the huge
>> page pool can be resized to the size of ZONE_MOVABLE during the lifetime of
>> the system assuming that pages are not mlocked. Despite huge pages being
>> non-movable, we do not introduce additional external fragmentation of note
>> as huge pages are always the largest contiguous block we care about.
>
> The user already has to specify the partitioning of the system at bootup
> and could take the huge page sizes into account.
>

Not in all cases. Some systems will not know how many huge pages they need 
in advance because it is used as a batch system running jobs as requested. 
The zone allows an amount of memory to be set aside that can be 
*optionally* used for hugepages if desired or base pages if not. Between 
jobs, the hugepage pool can be resized up to the size of ZONE_MOVABLE.

The other case is ever supporting memory hot-remove. Any memory within 
ZONE_MOVABLE can potentially be removed by migrating pages and off-lined.

> Also huge pages may have variable sizes that can be specified on bootup
> for IA64. The assumption that a huge page is always the largest
> contiguous block is *not true*.
>

I didn't say they were the largest supported contiguous block, I said they 
were the largest contiguous block we *care* about. Right now, it is 
assumed that variable pages are not supported at runtime. If they were, 
some smarts would be needed to keep huge pages of the same size together 
to control external fragmentation but that's about it.

> The huge page sizes on i386 and x86_64 platforms are contigent on
> their page table structure. This can be completely different on other
> platforms.
>

The size doesn't really make much difference to the mechanism.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
