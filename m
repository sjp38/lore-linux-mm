Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 68BC0660019
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:25 -0400 (EDT)
Message-Id: <20100804024514.139976032@linux.com>
Date: Tue, 03 Aug 2010 21:45:14 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

The following is a first release of an allocator based on SLAB
and SLUB that integrates the best approaches from both allocators. The
per cpu queuing is like the two prior releases. The NUMA facilities
were much improved vs V2. Shared and alien cache support was added to
track the cache hot state of objects. 

After this patches SLUB will track the cpu cache contents
like SLAB attemped to. There are a number of architectural differences:

1. SLUB accurately tracks cpu caches instead of assuming that there
   is only a single cpu cache per node or system.

2. SLUB object expiration is tied into the page reclaim logic. There
   is no periodic cache expiration.

3. SLUB caches are dynamically configurable via the sysfs filesystem.

4. There is no per slab page metadata structure to maintain (aside
   from the object bitmap that usually fits into the page struct).

5. Keeps all the other good features of SLUB as well.

SLUB+Q is a merging of SLUB with some queuing concepts from SLAB and a
new way of managing objects in the slabs using bitmaps. It uses a percpu
queue so that free operations can be properly buffered and a bitmap for
managing the free/allocated state in the slabs. It is slightly more
inefficient than SLUB (due to the need to place large bitmaps --sized
a few words--in some slab pages if there are more than BITS_PER_LONG
objects in a slab) but in general does not increase space use too much.

The SLAB scheme of not touching the object during management is adopted.
SLUB+Q can efficiently free and allocate cache cold objects without
causing cache misses.

I have had limited time for benchmarking this release so far since I
was more focused on getting SLAB features merged in and making it
work reliably with all the usual SLUB bells and whistles. The queueing
scheme from the SLUB+Q V1/V2 releases was not changed so that the basic
SMP performance is still the same. V1 and V2 did not have NUMA clean
queues and therefore the performance on NUMA system was not great.

Since the basic queueing scheme from SLAB was taken we should be seeing
similar or better performance on NUMA. But then I am limited to two node
systems at this point. For those systems the alien caches are allocated
of similar size than the shared caches. Meaning that more optimizations
will now be geared to small NUMA systems.



Patches against 2.6.35

1,2 Some percpu stuff that I hope will independently be merged in the 2.6.36
	cycle.

3-13 Cleanup patches for SLUB that are general improvements. Some of those
	are already in the slab tree for 2.6.36.

14-18 Minimal set that realizes per cpu queues without fancy shared or alien
    queues.  This should be enough to be competitive with SMP against SLAB
    on modern hardware as the earlier measurements show.

19   NUMA policies applied at the object level. This will cause significantly
	more processing in the allocator hotpath for the NUMA case on
	particular slabs so that individual allocations can be redirected
	to different nodes.

20	Shared caches per cache sibling group between processors.

21	Alien caches per cache sibling group. Just adds a couple of
	shared caches and uses them for foreign nodes.

22	Cache expiration

23	Expire caches from page reclaim logic in mm/vmscan.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
