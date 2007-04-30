Date: Mon, 30 Apr 2007 10:37:36 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patchset comments
In-Reply-To: <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704301016180.32439@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
 <Pine.LNX.4.64.0704281425550.12304@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Apr 2007, Christoph Lameter wrote:

> On Sat, 28 Apr 2007, Mel Gorman wrote:
>
>> Because I wanted to build memory compaction on top of this when movable memory
>> is not just memory that can go to swap but includes mlocked pages as well
>
> Ahh. Ok.
>
>>> MIGRATE_RESERVE
>> The standard allocator keeps high-order pages free until memory pressure
>> forces them to be split. In practice, this means that pages for
>> min_free_kbytes are kept as contiguous pages for quite a long time but once
>> split never become contiguous again. This lets short-lived high-order atomic
>> allocations to work for quite a while which is why setting min_free_kbytes to
>> 16384 seems to let jumbo frames work for a long time. Grouping by mobility is
>> more concerned with the type of page so it breaks up the min_free_kbytes pages
>> early removing a desirable property of the standard allocator for high-order
>> atomic allocations. MIGRATE_RESERVE brings that desirable property back.
>
> Hmmmm... A special pool for atomic allocs...
>

That is not it's intention although it doubles up at that. The intention 
is to preserve free pages kept for min_free_kbytes as contiguous pages 
because it's a property of the current allocator that atomic allocations 
depend on today.

>>> Trouble ahead. Why do we need it? To crash when the
>>> kernel does too many unmovable allocs?
>> It's needed for a few reasons but the two main ones are;
>>
>> a) grouping pages by mobility does not give guaranteed bounds on how much
>>    contiguous memory will be movable. While it could, it would be very
>>    complex and would replicate the behavior of zones to the extent I'll
>>    get a slap in the head for even trying. Partitioning memory gives hard
>>    guarantees on memory availability
>
> And crashes the kernel if the availability is no longer guaranteed?
>

OOM.

>> b) Early feedback was that grouping pages by mobility should be
>>    done only with zones but that is very restrictive. Different people
>>    liked each approach for different reasons so it constantly went in
>>    circles. That is why both can sit side-by-side now
>>
>> The zone is also of interest to the memory hot-remove people.
>
> Indeed that is a good thing.... It would be good if a movable area
> would be a dynamic split of a zone and not be a separate zone that has to
> be configured on the kernel command line.
>

There are problems with doing that. In particular, the zone can only be 
sized on one direction and can only be sized at the zone boundary because 
zones do not currently overlap and I believe there will be assumptions 
made about them not overlapping within a node. It's worth looking into in 
the future but I'm putting it at the bottom of the TODO list.

>> Granted, if kernelcore= is given too small a value, it'll cause problems.
>
> That is what I thought.
>
>>> 1. alloc_zeroed_user_highpage is no longer used
>>> 	Its noted in the patches but it was not removed nor marked
>>> 	as depreciated.
>> Indeed. Rather than marking it deprecated I was going to wait until it was
>> unused for one cycle and then mark it deprecated and see who complains.
>
> I'd say remove it immediately. This is confusing.
>

Ok.

>>> 2. submit_bh allocates bios using __GFP_MOVABLE
>>>
>>> 	How can a bio be moved? Or does that indicate that the
>>> 	bio can be reclaimed?
>>>
>>
>> I consider the pages allocated for the buffer to be movable because the
>> buffers can be cleaned and discarded by standard reclaim. When/if page
>> migration is used, this will have to be revisisted but for the moment I
>> believe it's correct.
>
> This would make it __GFP_RECLAIMABLE. The same is true for the caches that
> can be reclaimed. They are not marked __GFP_MOVABLE.
>

As we are currently depend on reclaim to free contiguous pages, it works 
out better *at the moment* to have buffers with other pages reclaimed via 
the LRU.

>> If the RECLAIMABLE areas could be properly targeted, it would make sense to
>> mark these pages RECLAIMABLE instead but that is not the situation today.
>
> What is the problem with targeting?
>

It's currently not possible to target effectively.

>>> 	That is because they are large order allocs and do not
>>> 	cause fragmentation if all other allocs are smaller. But that
>>> 	assumption may turn out to be problematic. Huge pages allocs
>>> 	as movable may make higher order allocation problematic if
>>> 	MAX_ORDER becomes much larger than the huge page order. In
>>> 	particular on IA64 the huge page order is dynamically settable
>>> 	on bootup. They can be quite small and thus cause fragmentation
>>> 	in the movable blocks.
>>
>> You're right here. I have always considered huge page allocations to be the
>> highest order anything in the system will ever care about. I was not aware of
>> any situation except at boot-time where that is different. What sort of
>> situation do you forsee where the huge page size is not the largest high-order
>> allocation used by the system? Even the large blocksize stuff doesn't seem to
>> apply here.
>
> Boot an IA64 box with the parameter hugepagesz=64k for example. That will
> give you a huge page size of 64k on a system with MAX_ORDER = 1G. The
> default for the huge page size is 256k which is a quarter of max order.
> But some people boot with 1G huge pages.
>

Right, that's fair enough. Now that I recognise the problem, I can start 
kicking it.

>>> 6. First in bdget() we set the mapping for a block device up using
>>> 	GFP_MOVABLE. However, then in grow_dev_page for an actual
>>> 	allocation we will use__GFP_RECLAIMABLE for the block device.
>>> 	We should use one type I would think and its GFP_MOVABLE as
>>> 	far as I can tell.
>>>
>>
>> I'll revisit this one. I think it should be __GFP_RECLAIMABLE in both cases
>> because I have a vague memory that pages due to grow_dev_page caused problems
>> fragmentation wise because they could not be reclaimed. That might simply have
>> been an unrelated bug at the time.
>
> It depends on who allocates these pages. If they are mapped by the user
> then they are movable. If a filesystem gets them for metadata then they
> are reclaimable.
>
>> This will simplify one of the patches. Are all slabs with SLAB_RECLAIM_ACCOUNT
>> guaranteed to have a shrinker available either directly or indirectly?
>
> I have not checked that recently but historically yes. There is no point
> in accounting slabs for reclaim if you cannot reclaim them.
>

Right, I'll go with the assumption that they somehow all get reclaimed 
via shrink_icache_memory() for the moment.

>>> 8. Same occurs for inodes. The reclaim flag should not be specified
>>> 	for individual allocations since reclaim is a slab wide
>>> 	activity. It also has no effect if the objects is taken off
>>> 	a queue.
>>>
>>
>> If SLAB_RECLAIM_ACCOUNT always uses __GFP_RECLAIMABLE, this will be caught
>> too, right?
>
> Correct.
>
>>> 10. Radix tree as reclaimable? radix_tree_node_alloc()
>>>
>>> 	Ummm... Its reclaimable in a sense if all the pages are removed
>>> 	but I'd say not in general.
>>>
>>
>> I considered them to be indirectly reclaimable. Maybe it wasn't the best
>> choice.
>
> Maybe we need to ask Nick about this one.

Nick, at what point are nodes allocated with radix_tree_node_alloc() 
freed?

My current understanding is that some get freed when pages are removed 
from the page cache but I haven't looked closely enough to be certain.

>>> 11. shmem_alloc_page() shmem pages are only __GFP_RECLAIMABLE? They can be
>>>        swapped out and moved by page migration, so GFP_MOVABLE?
>>>
>>
>> Because they might be ramfs pages which are not movable -
>> http://lkml.org/lkml/2006/11/24/150
>
> URL does not provide any useful information regarding the issue.
>

Not all pages allocated via shmem_alloc_page() are movable because they 
may pages for ramfs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
