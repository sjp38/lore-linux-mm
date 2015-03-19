Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id A8F9A6B0070
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 17:14:48 -0400 (EDT)
Received: by ykfc206 with SMTP id c206so56786137ykf.1
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 14:14:48 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id xd14si2928313pac.211.2015.03.19.07.05.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 07:05:12 -0700 (PDT)
Received: by pabyw6 with SMTP id yw6so76711904pab.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:05:11 -0700 (PDT)
From: Roman Pen <r.peniaev@gmail.com>
Subject: [RFC v2 0/3] mm/vmalloc: fix possible exhaustion of vmalloc space
Date: Thu, 19 Mar 2015 23:04:38 +0900
Message-Id: <1426773881-5757-1-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Pen <r.peniaev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hello all.

Recently I came across high fragmentation of vm_map_ram allocator: vmap_block
has free space, but still new blocks continue to appear.  Further investigation
showed that certain mapping/unmapping sequences can exhaust vmalloc space.  On
small 32bit systems that's not a big problem, cause purging will be called soon
on a first allocation failure (alloc_vmap_area), but on 64bit machines, e.g.
x86_64 has 45 bits of vmalloc space, that can be a disaster.

1) I came up with a simple allocation sequence, which exhausts virtual space
very quickly:

  while (iters) {

		/* Map/unmap big chunk */
		vaddr = vm_map_ram(pages, 16, -1, PAGE_KERNEL);
        vm_unmap_ram(vaddr, 16);

		/* Map/unmap small chunks.
		 *
		 * -1 for hole, which should be left at the end of each block
		 * to keep it partially used, with some free space available */
		for (i = 0; i < (VMAP_BBMAP_BITS - 16) / 8 - 1; i++) {
			vaddr = vm_map_ram(pages, 8, -1, PAGE_KERNEL);
            vm_unmap_ram(vaddr, 8);
        }
  }

The idea behind is simple:

 1. We have to map a big chunk, e.g. 16 pages.

 2. Then we have to occupy the remaining space with smaller chunks, i.e.
    8 pages. At the end small hole should remain to keep block in free list,
    but do not let big chunk to occupy remaining space.

 3. Goto 1 - allocation request of 16 pages can't be completed (only 8 slots
    are left free in the block in the #2 step), new block will be allocated,
    all further requests will lay into newly allocated block.

To have some measurement numbers for all further tests I setup ftrace and
enabled 4 basic calls in a function profile:

	echo vm_map_ram              > /sys/kernel/debug/tracing/set_ftrace_filter;
	echo alloc_vmap_area        >> /sys/kernel/debug/tracing/set_ftrace_filter;
	echo vm_unmap_ram           >> /sys/kernel/debug/tracing/set_ftrace_filter;
	echo free_vmap_block        >> /sys/kernel/debug/tracing/set_ftrace_filter;

So for this scenario I got these results:

BEFORE (all new blocks are put to the head of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                          126000    30683.30 us     0.243 us        30819.36 us 
  vm_unmap_ram                        126000    22003.24 us     0.174 us        340.886 us  
  alloc_vmap_area                       1000    4132.065 us     4.132 us        0.903 us    


AFTER (all new blocks are put to the tail of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                          126000    28713.13 us     0.227 us        24944.70 us 
  vm_unmap_ram                        126000    20403.96 us     0.161 us        1429.872 us 
  alloc_vmap_area                        993    3916.795 us     3.944 us        29.370 us   
  free_vmap_block                        992    654.157 us      0.659 us        1.273 us    


SUMMARY:
The most interesting numbers in those tables are numbers of block allocations
and deallocations: alloc_vmap_area and free_vmap_block calls, which show that
before the change blocks were not freed, and virtual space and physical memory
(vmap_block structure allocations, etc) were consumed.

Average time which were spent in vm_map_ram/vm_unmap_ram became slightly better.
That can be explained with a reasonable amount of blocks in a free list, which
we need to iterate to find a suitable free block.


2) Another scenario is a random allocation:

  while (iters) {

		/* Randomly take number from a range [1..32/64] */
		nr = rand(1, VMAP_MAX_ALLOC);
		vaddr = vm_map_ram(pages, nr, -1, PAGE_KERNEL);
		vm_unmap_ram(vaddr, nr);
  }

I chose mersenne twister PRNG to generate persistent random state to guarantee
that both runs have the same random sequence.  For each vm_map_ram call random
number from [1..32/64] was taken to represent amount of pages which I do map.

I did 10'000 vm_map_ram calls and got these two tables:

BEFORE (all new blocks are put to the head of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                           10000    10170.01 us     1.017 us        993.609 us  
  vm_unmap_ram                         10000    5321.823 us     0.532 us        59.789 us   
  alloc_vmap_area                        420    2150.239 us     5.119 us        3.307 us    
  free_vmap_block                         37    159.587 us      4.313 us        134.344 us  


AFTER (all new blocks are put to the tail of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                           10000    7745.637 us     0.774 us        395.229 us  
  vm_unmap_ram                         10000    5460.573 us     0.546 us        67.187 us   
  alloc_vmap_area                        414    2201.650 us     5.317 us        5.591 us    
  free_vmap_block                        412    574.421 us      1.394 us        15.138 us   


SUMMARY:
'BEFORE' table shows, that 420 blocks were allocated and only 37 were freed.
Remained 383 blocks are still in a free list, consuming virtual space and
physical memory.

'AFTER' table shows, that 414 blocks were allocated and 412 were really freed.
2 blocks remained in a free list.

So fragmentation was dramatically reduced.  Why?  Because when we put newly
allocated block to the head, all further requests will occupy new block,
regardless remained space in other blocks.  In this scenario all requests come
randomly.  Eventually remained free space will be less than requested size,
free list will be iterated and it is possible that nothing will be found there -
finally new block will be created.  So exhaustion in random scenario happens
for the maximum possible allocation size: 32 pages for 32-bit system and 64
pages for 64-bit system.

Also average cost of vm_map_ram was reduced from 1.017 us to 0.774 us.  Again
this can be explained by iteration through smaller list of free blocks.


3) Next simple scenario is a sequential allocation, when the allocation order
is increased for each block.  This scenario forces allocator to reach maximum
amount of partially free blocks in a free list:

  while (iters) {

		/* Populate free list with blocks with remaining space */
		for (order = 0; order <= ilog2(VMAP_MAX_ALLOC); order++) {
			nr = VMAP_BBMAP_BITS / (1 << order);

			/* Leave a hole */
			nr -= 1;

			for (i = 0; i < nr; i++) {
				vaddr = vm_map_ram(pages, (1 << order), -1, PAGE_KERNEL);
				vm_unmap_ram(vaddr, (1 << order));
		}

		/* Completely occupy blocks from a free list */
		for (order = 0; order <= ilog2(VMAP_MAX_ALLOC); order++) {
			vaddr = vm_map_ram(pages, (1 << order), -1, PAGE_KERNEL);
			vm_unmap_ram(vaddr, (1 << order));
		}
  }

Results which I got:

BEFORE (all new blocks are put to the head of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                         2032000    399545.2 us     0.196 us        467123.7 us 
  vm_unmap_ram                       2032000    363225.7 us     0.178 us        111405.9 us 
  alloc_vmap_area                       7001    30627.76 us     4.374 us        495.755 us  
  free_vmap_block                       6993    7011.685 us     1.002 us        159.090 us  


AFTER (all new blocks are put to the tail of a free list)
# cat /sys/kernel/debug/tracing/trace_stat/function0
  Function                               Hit    Time            Avg             s^2
  --------                               ---    ----            ---             ---
  vm_map_ram                         2032000    394259.7 us     0.194 us        589395.9 us 
  vm_unmap_ram                       2032000    292500.7 us     0.143 us        94181.08 us 
  alloc_vmap_area                       7000    31103.11 us     4.443 us        703.225 us  
  free_vmap_block                       7000    6750.844 us     0.964 us        119.112 us  


SUMMARY:
No surprises here, almost all numbers are the same.


Fixing this fragmentation problem I also did some improvements in a allocation
logic of a new vmap block: occupy block immediately and get rid of extra search
in a free list.

Also I replaced dirty bitmap with min/max dirty range values to make the logic
simpler and slightly faster, since two longs comparison costs less, than loop
thru bitmap.


This patchset raises several questions:

 Q: Think the problem you comments is already known so that I wrote comments
    about it as "it could consume lots of address space through fragmentation".
    Could you tell me about your situation and reason why it should be avoided?
                                                                     Gioh Kim

 A: Indeed, there was a commit 364376383 which adds explicit comment about
    fragmentation.  But fragmentation which is described in this comment caused
    by mixing of long-lived and short-lived objects, when a whole block is pinned
    in memory because some page slots are still in use.  But here I am talking
    about blocks which are free, nobody uses them, and allocator keeps them alive
    forever, continuously allocating new blocks.


 Q: I think that if you put newly allocated block to the tail of a free
    list, below example would results in enormous performance degradation.

    new block: 1MB (256 pages)

    while (iters--) {
      vm_map_ram(3 or something else not dividable for 256) * 85
      vm_unmap_ram(3) * 85
    }

    On every iteration, it needs newly allocated block and it is put to the
    tail of a free list so finding it consumes large amount of time.
                                                                    Joonsoo Kim

 A: Second patch in current patchset gets rid of extra search in a free list,
    so new block will be immediately occupied..

    Also, the scenario above is impossible, cause vm_map_ram allocates virtual
    range in orders, i.e. 2^n.  I.e. passing 3 to vm_map_ram you will allocate
    4 slots in a block and 256 slots (capacity of a block) of course dividable
    on 4, so block will be completely occupied.

    But there is a worst case which we can achieve: each free block has a hole
    equal to order size.

    The maximum size of allocation is 64 pages for 64-bit system
    (if you try to map more, original alloc_vmap_area will be called).

    So the maximum order is 6.  That means that worst case, before allocator
    makes a decision to allocate a new block, is to iterate 7 blocks:

    HEAD
    1st block - has 1  page slot  free (order 0)
    2nd block - has 2  page slots free (order 1)
    3rd block - has 4  page slots free (order 2)
    4th block - has 8  page slots free (order 3)
    5th block - has 16 page slots free (order 4)
    6th block - has 32 page slots free (order 5)
    7th block - has 64 page slots free (order 6)
    TAIL

    So the worst scenario on 64-bit system is that each CPU queue can have 7
    blocks in a free list.

    This can happen only and only if you allocate blocks increasing the order.
    (as I did in the function written in the comment of the first patch)
    This is weird and rare case, but still it is possible.  Afterwards you will
    get 7 blocks in a list.

    All further requests should be placed in a newly allocated block or some
    free slots should be found in a free list.
    Seems it does not look dramatically awful.

I would like to receive comments on the following three patches.

Thanks.

Changelog since v1:

 - Indentation tweaks (fix checkpatch warnings).
 - Provided profiling measurements and testing scenarios.
 - Described the problem more explicitly.
 - Listed raised questions.

Roman Pen (3):
  mm/vmalloc: fix possible exhaustion of vmalloc space caused by
    vm_map_ram allocator
  mm/vmalloc: occupy newly allocated vmap block just after allocation
  mm/vmalloc: get rid of dirty bitmap inside vmap_block structure

 mm/vmalloc.c | 95 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 55 insertions(+), 40 deletions(-)

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: WANG Chao <chaowang@redhat.com>
Cc: Fabian Frederick <fabf@skynet.be>
Cc: Christoph Lameter <cl@linux.com>
Cc: Gioh Kim <gioh.kim@lge.com>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
