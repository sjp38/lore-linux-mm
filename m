Message-Id: <20080509151713.939253437@saeurebad.de>
Date: Fri, 09 May 2008 17:17:13 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH 0/3] bootmem2 III
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

here is bootmem2, a memory block-oriented boot time allocator.

Recent NUMA topologies broke the current bootmem's assumption that
memory nodes provide non-overlapping and contiguous ranges of pages.

To cope with these configurations, bootmem2 operates on contiguous
memory blocks.

The node model is implemented on top of this scheme, every node
provides zero or more blocks of memory.

The usage of bootmem2 is almost the same as that of the current
allocator. On architectures that allow non-contiguous nodes the arch
code must register memory blocks instead of nodes, right now these
architectures are x86 and ia64.  For all other archs it is enough to
select bootmem2 and stop using pgdat->bdata.

bootmem can be dropped completely when those two architectures have
been migrated to bootmem2.

The first patch in this series makes the maximum number of memory
blocks (and the resulting number of blocks per node) available to
generic code as bootmem2 needs to work with those.

The second patch is bootmem2 itself.  Although the logical complexity
increased, I think the code is quite compact.  Every public interface
has been documented.

The third patch is trivial, it enables bootmem2 for x86_32 machines.

The allocator works on my X86_32 UMA computer, everything else is only
theory, please give it a test.

	Hannes

 arch/x86/Kconfig           |    1
 b/include/linux/bootmem2.h |  174 +++++++++++++
 b/mm/bootmem2.c            |  575 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/bootmem.h    |    6
 include/linux/numa.h       |   12
 mm/Kconfig                 |    3
 mm/Makefile                |    7
 mm/page_alloc.c            |    4
 8 files changed, 776 insertions(+), 6 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
