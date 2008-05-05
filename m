Message-Id: <20080505095938.326928514@symbol.fehenstaub.lan>
Date: Mon, 05 May 2008 11:59:38 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [rfc][patch 0/3] bootmem2: a memory block-oriented boot time allocator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

here is a bootmem allocator replacement that uses one bitmap for all
available pages and works with a model of contiguous memory blocks
that reside on nodes instead of nodes only as the current allocator
does.

The problem is that memory nodes are not anymore garuanteed to be
linear on certain configurations, they may overlap each other and a
node might span page ranges that are not physically residing on it.

Note that this is in no way theoretical only, bootmem suffers from
this fact right now: A pfn range has to be operated on on every node
that holds it (because a PFN is not unique anymore) and bootmem can
not garuantee that the memory allocated from a specific node actually
resides on that node.

For example:

	node 0: 0-2G, 4-6G
	node 1: 2-4G, 6-8G

Bootmem currently sees the 2-4G range twice (and has to operate on
both node's bitmaps) and if memory is allocated on node 1, it may
return memory that is between the 2-4G range and actually resides on
node 0.

Bootmem2 tries to fix these fundamental design issues by using one
bitmap for all pfns and therefor garuantees that a PFN stays unique as
it should.  Nodes are divided into contiguous memory blocks that are
certain to reside on one node.  A node-specific allocation request
must fit completely into one block of the the node to garuantee
locality.

For example:

	node 0: block 0: 0-2G, block 1: 4-6G
	node 1: block 2: 2-4G, block 3: 6-8G

The global bitmap represents 0-8G and every pfn is still unique.  An
allocation request on node 1 must fit into block 2 or block 3 and the
memory is therefor garuanteed to be reside on that node.

The important change in arch-code is that on setups with multiple
blocks per node, every block must be registered on its own to make
bootmem2 aware of them.  And the allocator setup in general changes to
a two-step process: register all blocks/nodes first, then enable it by
providing memory that is big enough to hold the bitmap for all pfns in
the system.

The implementation is similar to bootmem but the code is shorter (and
clearer, IMHO):

$ sloc.awk < mm/bootmem.c
455 lines of code, 65 lines of comments (520 lines total)

$ sloc.awk < mm/bootmem2.c
325 lines of code, 120 lines of comments (445 lines total)

bootmem is meant to stay until all users are migrated to bootmem2, it
can be dropped completely after that.

Note that this is in no way production code yet, but I would like to
have some comments on it since the core is essentially ready and
running on my machine (and I might be already caught in a deep forest
without seeing the trees).

Sparsemem hotplug is not supported, I have not yet looked deep enough
into its bootmem interface.  Yasunori, any suggestions?

Also, it would be a stupid idea if I'd migrate arch-code I can not
test at all, right now only x86_32 has been migrated, sorry :/

	Hannes

 arch/x86/Kconfig           |    1
 arch/x86/kernel/setup_32.c |    4
 arch/x86/mm/init_32.c      |    2
 include/linux/bootmem.h    |    6
 include/linux/bootmem2.h   |  207 +++++++++++++++++
 include/linux/numa.h       |   12 -
 mm/Kconfig                 |    3
 mm/Makefile                |    7
 mm/bootmem2.c              |  534 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |    4
 10 files changed, 772 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
