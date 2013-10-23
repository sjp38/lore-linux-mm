Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 058AB6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 10:43:01 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so1062365pab.10
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:43:01 -0700 (PDT)
Received: from psmtp.com ([74.125.245.110])
        by mx.google.com with SMTP id mj9si15658188pab.132.2013.10.23.07.42.55
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 07:43:00 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 24 Oct 2013 00:42:53 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 638653578057
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 01:42:44 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9NEPFR610944920
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 01:25:21 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9NEgb1E000722
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 01:42:38 +1100
Message-ID: <5267DF4D.2050708@linux.vnet.ibm.com>
Date: Wed, 23 Oct 2013 20:08:05 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 01/40] mm: Introduce memory regions data-structure
 to capture region boundaries within nodes
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <20130925231346.26184.65521.stgit@srivatsabhat.in.ibm.com> <20131023095442.GA2043@cmpxchg.org>
In-Reply-To: <20131023095442.GA2043@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.gross@intel.com

On 10/23/2013 03:24 PM, Johannes Weiner wrote:
> On Thu, Sep 26, 2013 at 04:43:48AM +0530, Srivatsa S. Bhat wrote:
>> The memory within a node can be divided into regions of memory that can be
>> independently power-managed. That is, chunks of memory can be transitioned
>> (manually or automatically) to low-power states based on the frequency of
>> references to that region. For example, if a memory chunk is not referenced
>> for a given threshold amount of time, the hardware (memory controller) can
>> decide to put that piece of memory into a content-preserving low-power state.
>> And of course, on the next reference to that chunk of memory, it will be
>> transitioned back to full-power for read/write operations.
>>
>> So, the Linux MM can take advantage of this feature by managing the available
>> memory with an eye towards power-savings - ie., by keeping the memory
>> allocations/references consolidated to a minimum no. of such power-manageable
>> memory regions. In order to do so, the first step is to teach the MM about
>> the boundaries of these regions - and to capture that info, we introduce a new
>> data-structure called "Memory Regions".
>>
>> [Also, the concept of memory regions could potentially be extended to work
>> with different classes of memory like PCM (Phase Change Memory) etc and
>> hence, it is not limited to just power management alone].
>>
>> We already sub-divide a node's memory into zones, based on some well-known
>> constraints. So the question is, where do we fit in memory regions in this
>> hierarchy. Instead of artificially trying to fit it into the hierarchy one
>> way or the other, we choose to simply capture the region boundaries in a
>> parallel data-structure, since most likely the region boundaries won't
>> naturally fit inside the zone boundaries or vice-versa.
>>
>> But of course, memory regions are sub-divisions *within* a node, so it makes
>> sense to keep the data-structures in the node's struct pglist_data. (Thus
>> this placement makes memory regions parallel to zones in that node).
>>
>> Once we capture the region boundaries in the memory regions data-structure,
>> we can influence MM decisions at various places, such as page allocation,
>> reclamation etc, in order to perform power-aware memory management.
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/mmzone.h |   12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index bd791e4..d3288b0 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -35,6 +35,8 @@
>>   */
>>  #define PAGE_ALLOC_COSTLY_ORDER 3
>>  
>> +#define MAX_NR_NODE_REGIONS	512
>> +
>>  enum {
>>  	MIGRATE_UNMOVABLE,
>>  	MIGRATE_RECLAIMABLE,
>> @@ -708,6 +710,14 @@ struct node_active_region {
>>  extern struct page *mem_map;
>>  #endif
>>  
>> +struct node_mem_region {
>> +	unsigned long start_pfn;
>> +	unsigned long end_pfn;
>> +	unsigned long present_pages;
>> +	unsigned long spanned_pages;
>> +	struct pglist_data *pgdat;
>> +};
>> +
>>  /*
>>   * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
>>   * (mostly NUMA machines?) to denote a higher-level memory zone than the
>> @@ -724,6 +734,8 @@ typedef struct pglist_data {
>>  	struct zone node_zones[MAX_NR_ZONES];
>>  	struct zonelist node_zonelists[MAX_ZONELISTS];
>>  	int nr_zones;
>> +	struct node_mem_region node_regions[MAX_NR_NODE_REGIONS];
>> +	int nr_node_regions;
>>  #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
>>  	struct page *node_mem_map;
>>  #ifdef CONFIG_MEMCG
> 
> Please don't write patches that add data structures but do not use
> them.
> 
> This is a pattern throughout the whole series.  You add a data
> structure in one patch, individual helper functions in followup
> patches, optimizations and statistics in yet more patches, even
> unrelated cleanups and documentation like the fls() vs __fls() stuff,
> until finally you add the actual algorithm, also bit by bit.  I find
> it really hard to review when I have to jump back and forth between
> several different emails to piece things together.
> 

Hmm, sorry about that! I was trying to keep the amount of code in each
patch small enough that it is easy to review. I didn't realize that the
split was making it difficult to connect the different pieces together
while reviewing the code.

> Prepare the code base as necessary (the fls stuff, instrumentation for
> existing code, cleanups), then add the most basic data structure and
> code in one patch, then follow up with new statistics, optimizations
> etc. (unless the optimizations can be reasonably folded into the
> initial implementation in the first place).  This might not always be
> possible of course, but please strive for it.
> 

Sure, I'll try that in the next posting. But for this patch series, let
me atleast describe the high-level goal that a given group of patches
try to achieve, so that it becomes easier to review them.

So here it is:

Patches 1 - 4 do the most basic, first phase of work required to make the
MM subsystem aware of the underlying topology, by building the notion of
independently power-manageable regions, and carving out suitable chunks
from the zones. Thus at the end of patch 4, we have a zone-level
representation of memory regions, and we can determine the memory region
to which any given page belongs. So far, no real influence has been made
in any of the MM decisions such as page allocation.

Patches 5 and 6 start the real work of trying to influence the page
allocator's decisions - they integrate the notion of "memory regions"
within the buddy freelists themselves, by using appropriate data-structures.

These 2 patches also brings about an important change in the mechanics of
how pages are added and deleted from the buddy freelists. In particular,
deleting a page is no longer as simple as list_del(&page->lru). We need to
provide more information than that, as suggested by the prototype of
del_from_freelist(). We need to know exactly which freelist the page
belongs to, and for that we need to accurately keep track of the page's
migratetype even when it is in the buddy allocator.

That gives rise to patches 7 and 8. They fix up things related to migratetype
tracking, to prevent the mechanics of del_from_freelist() from falling
apart. So by now, we have a stable implementation of maintaining freepages
in the buddy allocator, sorted into different region buckets.

So, next come the optimizations. Patch 9 introduces a variable named
'next_region' per freelist, to avoid looking up the page-to-region translation
every time. That's one level of optimization.

Patch 11 adds another optimization by improving the sorting speed by using
a bitmap-based radix tree approach. When developing the patch, I had a hard
time figuring out that __fls() had completely different semantics than fls().
So I thought I should add a comment explaining that part, before I start
using __fls() in patch 11 (because I didn't find any documentation about
that subtle difference anywhere). That's why I put in patch 10 to do that.
But yes, I agree that its a bit extraneous, and ideally should go in as an
independent patch.

So by patch 11, we have a reasonably well-contained memory power management
infrastructure. So I felt it would be best to enable per-region statistics
as soon as possible in the patch series, so that we can measure the improvement
brought-about by each subsequent optimization or change, so that we can make
a good evaluation of how beneficial they are. So patches 12, 13 and 14
implement that and export per-region statistics. IMHO this ordering is quite
important since we are still yet to completely agree on which parts of the
patchset are useful in a wide variety of cases and which are not. So exposing
the statistics as early as possible in the patchset enables this sort of
evaluation.

Patch 15 is a fundamental change in how we allocate pages from the page
allocator, so I kept that patch separate, to make it noticeable, since it
has the potential to have direct impacts on performance.

By patch 15, we have the maximum amount of tweaking/tuning/optimization
for the sorted-buddy infrastructure. So from patch 16 onwards, we start
adding some very different stuff, designed to augment the sorted-buddy page
allocator.

Patch 16 inserts a new layer between the page allocator and the memory
hardware, known as the "region allocator". The idea is that the region
allocator allocates entire regions, from which the page allocator can further
split up things and allocate in smaller chunks (pages). The goal here is
to avoid the fragmentation of pages of different migratetypes among
various memory regions, and instead make it easy to have 'n' entire regions
for all MIGRATE_UNMOVABLE allocations, 'm' entire regions for MIGRATE_MOVABLE
and so on. This has pronounced impact in improving the success of the targeted
region compaction/evacuation framework (which comes later in the patchset).
For example, it can avoid cases where a single unmovable page is stuck in
a region otherwise populated by mostly movable or reclaimable allocations.
So basically you can think of this as a way of extending the 'pageblock_order'
fragmentation avoidance mechanism such that it can incorporate memory region
topology. That is, it will help us avoid mixing pages of different migratetypes
within a single region, and thus keep entire regions homogeneous with respect
to the allocation type.

Patches 17 and 18 add the infrastructure necessary to perform bulk movements
of pages between the page allocator and the region allocator, since that's
how the 2 entities will interact with each other. Then patches 19 and 20
provide helpers to talk to the region allocator itself, in terms of requesting
or giving back memory.

Now since we have _two_ different allocators (page and region), they need
to coordinate in their strategy. The page allocator chooses the lowest numbered
region to allocate. Patch 22 adds this same strategy to the region allocator
as well.

I admit that patches 23 and 24 are a bit oddly placed.

Patches 25 and 26 finally connect the page and the region allocators, now
that we have all the infrastructure ready. This is kept separate because this
has a policy associated with it and hence needs discussion (as in, how often
does the page allocator try to move regions back to the region allocator,
and at what points in the code (fast/hot vs slow paths etc)).

Patches 27 to 32 are mostly policy changes that drastically change how
fallbacks are handled. These are important to keep the region allocator sane
and simple. If for example, an unmovable page allocation falls back to
movable and then never returns the page to movable freelist even upon free,
then it will be very hard to account for that page as part of the region.
So it will enormously complicate the interaction between the page allocator
and the region allocator. Patches 27 to 32 help avoid that.

Patch 33 is the final patch related to the region allocator - it just adds a
caching logic to avoid frequent interactions between the page allocator and
the region allocator (ping-pong kind of interactions).

Patches 34 to 40 introduce the targeted compaction/region evacuation logic,
which is meant to augment the sorted-buddy and the region allocator, in causing
power-savings. Basically they carve out the reusable compaction bits from
CMA and build a per-node kthread infrastructure to free lightly allocated
regions. Then, the final patch 40 adds the trigger to wakeup these kthreads
from the page allocator, at appropriate opportunity points.

Hope this explanation helps to make it easier to review the patches!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
