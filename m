Date: Fri, 27 Apr 2007 20:46:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Antifrag patchset comments
Message-ID: <Pine.LNX.4.64.0704271854480.6208@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just had a look at the patches in mm....

Ok so we have the unmovable allocations and then 3 special types

RECLAIMABLE
	Memory can be reclaimed? Ahh this is used for buffer heads
	and the like. Allocations that can be reclaimed by some
	sort of system action that cannot be directly targeted
	at an object?

	It seems that you also included temporary allocs here?

MOVABLE
	Memory can be moved by going to the page and reclaiming it?

	So right now this is only a higher form of RECLAIMABLE.

	We currently do not move memory.... so why have it?

MIGRATE_RESERVE

	Some atomic reserve to preserve contiguity of allocations?
	Or just a fallback if other pools are all used? What is this?

So have 4 categories. Any additional category causes more overhead on
the pcp lists since we will have to find the correct type on the lists.
Why do we have MIGRATE_RESERVE?


Then we have ZONE_MOVABLE whose purpose is to guarantee that a large 
portion of memory is always reclaimable and movable. Which is pawned off
the highest available allocation zone. Very similar to memory policies
same problems. Some nodes do not have the highest zone (many x86_64 
NUMA are in that strange situation). Memory policies do not work quite 
right there and it seems that the antifrag methods will be switched off
for such a node. Trouble ahead. Why do we need it? To crash when the
kernel does too many unmovable allocs?


Other things:


1. alloc_zeroed_user_highpage is no longer used

	Its noted in the patches but it was not removed nor marked
	as depreciated.

2. submit_bh allocates bios using __GFP_MOVABLE

	How can a bio be moved? Or does that indicate that the
	bio can be reclaimed?

3. Highmem pages for user space are marked __GFP_MOVABLE

	Looks okay to me. So I guess that __GFP_MOVABLE
	implies GFP_RECLAIMABLE? Hmmm... It seems that 
	mlocked pages are therefore also movable and reclaimable
	(not true!). So we still have that problem spot?

4. Default inode alloc mod is set to GFP_HIGH_MOVABLE....

	Good.

5. Hugepages are set to movable in some cases.

	That is because they are large order allocs and do not
	cause fragmentation if all other allocs are smaller. But that
	assumption may turn out to be problematic. Huge pages allocs
	as movable may make higher order allocation problematic if 
	MAX_ORDER becomes much larger than the huge page order. In
	particular on IA64 the huge page order is dynamically settable
	on bootup. They can be quite small and thus cause fragmentation
	in the movable blocks.

	I think it may be possible to make huge pages supported by
	page migration in some way which may justify putting it into
	the movable section for all cases. But right now this seems to
	be more an x86_64/i386'ism.

6. First in bdget() we set the mapping for a block device up using
	GFP_MOVABLE. However, then in grow_dev_page for an actual
	allocation we will use__GFP_RECLAIMABLE for the block device.
	We should use one type I would think and its GFP_MOVABLE as
	far as I can tell.

7. dentry allocation uses GFP_KERNEL|__GFP_RECLAIMABLE.
	Why not set this by default in the slab allocators if 
	kmem_cache_create sets up a slab with SLAB_RECLAIM_ACCOUNT?

8. Same occurs for inodes. The reclaim flag should not be specified
	for individual allocations since reclaim is a slab wide
	activity. It also has no effect if the objects is taken off
	a queue.

9. proc_loginuid_write(), do_proc_readlink(), proc_pid_att_write() etc.

	Why are these allocation reclaimable? Should be GFP_KERNEL alloc there?

	These are temporary allocs. What is the benefit of 
	__GFP_RECLAIMABLE?


10. Radix tree as reclaimable? radix_tree_node_alloc()

	Ummm... Its reclaimable in a sense if all the pages are removed
	but I'd say not in general.

11. shmem_alloc_page() shmem pages are only __GFP_RECLAIMABLE? They can be 
        swapped out and moved by page migration, so GFP_MOVABLE?

12. skbs slab allocs marked GFP_RECLAIMABLE.

	Ok the queues are temporary. GFP_RECLAIMABLE means temporary
	alloc that will go away? This is a slab that is not using
	SLAB_ACCOUNT_RECLAIMABLE. Do we need a SLAB_RECLAIMABLE flag?

13. In the patches it was mentioned that it is no longer necessary 
    to set min_free_kbytes? What is the current state of that?

14. I am a bit concerned about an increase in the alloc types. There are
    two that I am not sure what their purpose is which is
    MIGRATION_RESERVE and MIGRATION_HIGHATOMIC. HIGHATOMIC seems to have
    been removed again.

15. Tuning for particular workloads.

Another concern is are patches here that indicate that new alloc types 
were created to accomodate certain workloads? The exceptions worry me.

16. Both memory policies and antifrag seem to 
   determine the highest zone. Memory policies call this the policy
   zone. Could you consolidate that code?

17. MAX_ORDER issues. At least on IA64 the antifrag measures will 
    require a reduction in max order. However, we currently have MAX_ORDER 
    of 1G because there are applications using huge pages of 1 Gigabyte size 
    (TLB pressure issues on IA64). OTOH, Machines exist that only have 1GB 
    RAM per node, so it may be difficult to create multiple MAX_ORDER blocks 
    as  needed.

I have not gotten my head around how the code in page_alloc.c actually 
works. This is just from reviewing comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
