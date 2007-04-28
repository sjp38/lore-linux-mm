Date: Sat, 28 Apr 2007 14:21:40 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Antifrag patchset comments
In-Reply-To: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704281229040.20054@skynet.skynet.ie>
References: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2007, Christoph Lameter wrote:

> I just had a look at the patches in mm....
>
> Ok so we have the unmovable allocations and then 3 special types
>
> RECLAIMABLE
> 	Memory can be reclaimed? Ahh this is used for buffer heads
> 	and the like. Allocations that can be reclaimed by some
> 	sort of system action that cannot be directly targeted
> 	at an object?
>

Exactly. Inode caches currently fall into the same category. When 
shrink_slab() is called the amount of memory in RECLAIMABLE areas will be 
reduced.

> 	It seems that you also included temporary allocs here?
>

Temporary and short-lived allocations are also treated as reclaimable to 
stop more areas than necessary being marked UNMOVABLE. The fewer UNMOVABLE 
blocks there are, the better.

> MOVABLE
> 	Memory can be moved by going to the page and reclaiming it?
>

Or potentially with page migration although that code does not exist. 
MOVABLE memory means just that - it can be moved while the data is still 
preserved. Moving it to swap is still moving.

> 	So right now this is only a higher form of RECLAIMABLE.
>

The names used to be RCLM_NORCLM, RCLM_EASY and RCLM_KERN which confused 
more people, hence the current naming.

> 	We currently do not move memory.... so why have it?
>

Because I wanted to build memory compaction on top of this when movable 
memory is not just memory that can go to swap but includes mlocked pages 
as well

> MIGRATE_RESERVE
>
> 	Some atomic reserve to preserve contiguity of allocations?
> 	Or just a fallback if other pools are all used? What is this?
>

The standard allocator keeps high-order pages free until memory pressure 
forces them to be split. In practice, this means that pages for 
min_free_kbytes are kept as contiguous pages for quite a long time but 
once split never become contiguous again. This lets short-lived high-order 
atomic allocations to work for quite a while which is why setting 
min_free_kbytes to 16384 seems to let jumbo frames work for a long time. 
Grouping by mobility is more concerned with the type of page so it breaks 
up the min_free_kbytes pages early removing a desirable property of the 
standard allocator for high-order atomic allocations. MIGRATE_RESERVE 
brings that desirable property back.

The number of blocks marked MIGRATE_RESERVE depends on min_free_kbytes and 
the area is only used when the alternative is to fail the allocation. The 
effect is that pages kept free for min_free_kbytes tend to exist in these 
MIGRATE_RESERVE areas as contiguous areas. This is an improvement over 
what the standard allocator does because it makes no effort to keep the 
minimum number of free pages contiguous.

> So have 4 categories. Any additional category causes more overhead on
> the pcp lists since we will have to find the correct type on the lists.
> Why do we have MIGRATE_RESERVE?
>

It resolved a problem with order-1 atomic allocations used by a network 
adapter when it was using bittorrent heavily. They affected user hasn't 
complained since.

> Then we have ZONE_MOVABLE whose purpose is to guarantee that a large
> portion of memory is always reclaimable and movable. Which is pawned off
> the highest available allocation zone.

Right. This is a separate issue to grouping pages by mobility. The memory 
partition does not require grouping pages by mobility to be available and 
vice-versa. All they share is the marking of allocations __GFP_MOVABLE.

> Very similar to memory policies
> same problems. Some nodes do not have the highest zone (many x86_64
> NUMA are in that strange situation).

yep. Dealing with only the highest zone made the code manageable, 
particularly where HIGHMEM was involved although the issue between NORMAL 
and DMA32 isn't much better.

> Memory policies do not work quite
> right there and it seems that the antifrag methods will be switched off
> for such a node.

Not quite. If the zone doesn't exist in a node, it will not be in the 
zonelists and things plod along as normal. Grouping pages by mobility 
works independent of memory partitioning so it'll still work in these 
nodes whether the zone is there is not.

> Trouble ahead. Why do we need it? To crash when the
> kernel does too many unmovable allocs?
>

It's needed for a few reasons but the two main ones are;

a) grouping pages by mobility does not give guaranteed bounds on how much
    contiguous memory will be movable. While it could, it would be very
    complex and would replicate the behavior of zones to the extent I'll
    get a slap in the head for even trying. Partitioning memory gives hard
    guarantees on memory availability

b) Early feedback was that grouping pages by mobility should be
    done only with zones but that is very restrictive. Different people
    liked each approach for different reasons so it constantly went in
    circles. That is why both can sit side-by-side now

The zone is also of interest to the memory hot-remove people.

Granted, if kernelcore= is given too small a value, it'll cause problems.

> > Other things:
>
>
> 1. alloc_zeroed_user_highpage is no longer used
>
> 	Its noted in the patches but it was not removed nor marked
> 	as depreciated.
>

Indeed. Rather than marking it deprecated I was going to wait until it was 
unused for one cycle and then mark it deprecated and see who complains.

> 2. submit_bh allocates bios using __GFP_MOVABLE
>
> 	How can a bio be moved? Or does that indicate that the
> 	bio can be reclaimed?
>

I consider the pages allocated for the buffer to be movable because the 
buffers can be cleaned and discarded by standard reclaim. When/if page 
migration is used, this will have to be revisisted but for the moment I 
believe it's correct.

If the RECLAIMABLE areas could be properly targeted, it would make sense 
to mark these pages RECLAIMABLE instead but that is not the situation 
today.

> 3. Highmem pages for user space are marked __GFP_MOVABLE
>
> 	Looks okay to me. So I guess that __GFP_MOVABLE
> 	implies GFP_RECLAIMABLE? Hmmm... It seems that
> 	mlocked pages are therefore also movable and reclaimable
> 	(not true!). So we still have that problem spot?
>

No, at worst we have a naming ambiguity which has come up before. 
RECLAIMABLE refers to allocations that are reclaimable via shrink_slab() 
or short-lived. MOVABLE pages are reclaimable by pageout or movable with 
page migration.

> 4. Default inode alloc mod is set to GFP_HIGH_MOVABLE....
>
> 	Good.
>
> 5. Hugepages are set to movable in some cases.
>

Specifically, they are considered movable when they are allowed to be 
allocated from ZONE_MOVABLE. So for it to really cause fragmentation, 
there has to be high-order movable allocations in play using ZONE_MOVABLE. 
This is currently never the case but the large blocksize stuff may change 
that.

> 	That is because they are large order allocs and do not
> 	cause fragmentation if all other allocs are smaller. But that
> 	assumption may turn out to be problematic. Huge pages allocs
> 	as movable may make higher order allocation problematic if
> 	MAX_ORDER becomes much larger than the huge page order. In
> 	particular on IA64 the huge page order is dynamically settable
> 	on bootup. They can be quite small and thus cause fragmentation
> 	in the movable blocks.
>

You're right here. I have always considered huge page allocations to be 
the highest order anything in the system will ever care about. I was not 
aware of any situation except at boot-time where that is different. What 
sort of situation do you forsee where the huge page size is not the 
largest high-order allocation used by the system? Even the large blocksize 
stuff doesn't seem to apply here.

> 	I think it may be possible to make huge pages supported by
> 	page migration in some way which may justify putting it into
> 	the movable section for all cases.

That was the long-term aim. I figured there was no reason that hugepages 
could not be moved just that it was unnecessary to date.

>	But right now this seems to be more an x86_64/i386'ism.
>

Depends on whether IA64 really has situations where allocations of a 
higher-order than hugepage size are common.

> 6. First in bdget() we set the mapping for a block device up using
> 	GFP_MOVABLE. However, then in grow_dev_page for an actual
> 	allocation we will use__GFP_RECLAIMABLE for the block device.
> 	We should use one type I would think and its GFP_MOVABLE as
> 	far as I can tell.
>

I'll revisit this one. I think it should be __GFP_RECLAIMABLE in both 
cases because I have a vague memory that pages due to grow_dev_page caused 
problems fragmentation wise because they could not be reclaimed. That 
might simply have been an unrelated bug at the time.

I've put this on the TODO to investigate further.

> 7. dentry allocation uses GFP_KERNEL|__GFP_RECLAIMABLE.
> 	Why not set this by default in the slab allocators if
> 	kmem_cache_create sets up a slab with SLAB_RECLAIM_ACCOUNT?
>

Because .... errr..... it didn't occur to me.

/me adds an item to the TODO list

This will simplify one of the patches. Are all slabs with 
SLAB_RECLAIM_ACCOUNT guaranteed to have a shrinker available either 
directly or indirectly?

> 8. Same occurs for inodes. The reclaim flag should not be specified
> 	for individual allocations since reclaim is a slab wide
> 	activity. It also has no effect if the objects is taken off
> 	a queue.
>

If SLAB_RECLAIM_ACCOUNT always uses __GFP_RECLAIMABLE, this will be caught 
too, right?

> 9. proc_loginuid_write(), do_proc_readlink(), proc_pid_att_write() etc.
>
> 	Why are these allocation reclaimable? Should be GFP_KERNEL alloc there?
>
> 	These are temporary allocs. What is the benefit of
> 	__GFP_RECLAIMABLE?
>

Because they are temporary. I didn't want large bursts of proc activity to 
cause MAX_ORDER_NR_PAGES blocks to be marked unmovable.

>
> 10. Radix tree as reclaimable? radix_tree_node_alloc()
>
> 	Ummm... Its reclaimable in a sense if all the pages are removed
> 	but I'd say not in general.
>

I considered them to be indirectly reclaimable. Maybe it wasn't the best 
choice.

> 11. shmem_alloc_page() shmem pages are only __GFP_RECLAIMABLE? They can be
>        swapped out and moved by page migration, so GFP_MOVABLE?
>

Because they might be ramfs pages which are not movable - 
http://lkml.org/lkml/2006/11/24/150

> 12. skbs slab allocs marked GFP_RECLAIMABLE.
>
> 	Ok the queues are temporary. GFP_RECLAIMABLE means temporary
> 	alloc that will go away? This is a slab that is not using
> 	SLAB_ACCOUNT_RECLAIMABLE. Do we need a SLAB_RECLAIMABLE flag?
>

I'll add it to the TODO to see what it looks like.

> 13. In the patches it was mentioned that it is no longer necessary
>    to set min_free_kbytes? What is the current state of that?
>

I ran some tests yesterday. If min_free_kbytes is left untouched, the 
number of hugepages that can be allocated at the end of the test is very 
variable: +/- 5% of physical memory on x86_64. When it's set to 
4*MAX_ORDER_NR_PAGES, it's +/- 1% generally. I think it's safe to leave 
the min_free_kbytes as-is for the moment and see what happens. If issues 
are encountered, I'll be asking that min_free_kbytes be increased on that 
machine to see if it really makes a difference in practice or not.

>From the results I have on x86_64 with 1GB of RAM, grouping page by 
mobility was able to allocate 69% of memory as 2MB hugepages under heavy 
load. The standard allocator got 2%. At rest at the end of the test when 
nothing is running, 72% was available as huge pages when grouping pages by 
mobility in comparison to 30%.

On PPC64 with 4GB of RAM when grouping pages by mobility, 11% was 
available under load and 57% of memory was available as 16MB huge pages at 
the end of the test in comparison to 0% with the vanilla allocator under 
load and 8% at rest. With 1GB of RAM, grouping pages by mobility got 35% 
of memory as huge pages at the end of the test and the vanilla allocator 
got 0%. I hope to improve this figure more over time.

> 14. I am a bit concerned about an increase in the alloc types. There are
>    two that I am not sure what their purpose is which is
>    MIGRATION_RESERVE and MIGRATION_HIGHATOMIC. HIGHATOMIC seems to have
>    been removed again.
>

HIGHATOMIC has gone out the door for the moment as MIGRATE_RESERVE does 
the job of having some contiguous blocks available for high-order atomic 
allocations better.

> 15. Tuning for particular workloads.
>
> Another concern is are patches here that indicate that new alloc types
> were created to accomodate certain workloads? The exceptions worry me.
>

They are not intentionally aimed at certain workloads. The current tests 
are known to be very hostile for external fragmentation (e.g. 0% success 
on PPC64 at the end of tests with the standard allocator). Yesterday in 
preparation for testing large blocksize patches, I added ltp, dbench and 
fsxlinux into the tool normally used for testing grouping pages by 
mobility so the workloads will vary more in the future. I hope to get 
information on other workloads as the patches get more exposure.

> 16. Both memory policies and antifrag seem to
>   determine the highest zone. Memory policies call this the policy
>   zone. Could you consolidate that code?
>

Maybe but probably not - I'll look into it. The problem is that at the 
time kernelcore= is handled the zones are not initialised yet (again, this 
is indpendent of grouping pages by mobility) bind_zonelist() appears uses 
z->present_pages for example which isn't even set at the time ZONE_MOVABLE 
is setup.

> 17. MAX_ORDER issues. At least on IA64 the antifrag measures will
>    require a reduction in max order. However, we currently have MAX_ORDER
>    of 1G because there are applications using huge pages of 1 Gigabyte size
>    (TLB pressure issues on IA64).

Ok, this explains why MAX_ORDER is so much larger than what appeared to be 
the huge page size.

> OTOH, Machines exist that only have 1GB
>    RAM per node, so it may be difficult to create multiple MAX_ORDER blocks
>    as  needed.
>

*ponders*

This is the trickest feedback from your review so far. However, mobility 
types are grouping based on MAX_ORDER_NR_PAGES simply because it was the 
easiest to implement and made sense at the time.

Right now, __rmqueue_smallest() searches up to MAX_ORDER-1 and 2 bits are 
stored per MAX_ORDER_NR_PAGES tracking the mobility of the group. There is 
nothing to say that it searches up to some other arbitrary order. The 
pageblock flags would then need 2 bits per ARBITRARY_ORDER_NR_PAGES 
instead of MAX_ORDER_NR_PAGES.

I'll look into how it can be implemented. I have an IA64 box with just 1GB 
of RAM here that I can use to test the concept.

> I have not gotten my head around how the code in page_alloc.c actually
> works. This is just from reviewing comments.
>

Thanks a lot for looking through them. My TODO list so far from this is

1. Check that bdget() is really doing the right thing with respect to
    __GFP_RECLAIMABLE

2. Use SLAB_ACCOUNT_RECLAIMBLE to set __GFP_RECLAIMABLE instead of setting
    flags individually

3. Consider adding a SLAB_RECLAIMABLE where sockets make short-lived
   allocations

4. Group based on blocks smaller than MAX_ORDER_NR_PAGES

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
