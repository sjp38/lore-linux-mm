From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC no patch yet] bootmem2: Another try
References: <20080505095938.326928514@symbol.fehenstaub.lan>
Date: Wed, 07 May 2008 14:29:20 +0200
In-Reply-To: <20080505095938.326928514@symbol.fehenstaub.lan> (Johannes
	Weiner's message of "Mon, 05 May 2008 11:59:38 +0200")
Message-ID: <87ve1qcn6n.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

my idea is now as follows:

Bootmem2 is block-oriented where a block represents a contiguous range
of physical memory.  Every block has a bitmap that keeps track of the
pages on it.

On top of this block interface, bootmem2 implements the node model
where a node can provide one or more memory blocks.

On configurations with multiple blocks per node, the arch code has to
register each block on its own.

free_bootmem and reserve_bootmem require that the requested range is
contiguous but they might go across node boundaries (two blocks on two
nodes can be contiguous).  For example:

node 0: block 0 = 0-2G, block 1 = 4-6G
node 1: block 2 = 2-4G, block 3 = 6-8G

free_bootmem(1.5G, 3G) is valid here, the range spans two nodes and two
blocks but is contiguous.

free_bootmem_node and reserve_bootmem_node are more strict, the ranges
have to be completely within one block of the specified node (two
blocks on one node are never contiguous).

alloc_bootmem_node tries to get memory between goal and limit from a
specific node and falls back to any free memory range on that node on
failure.

alloc_bootmem tries to get memory from between goal and limit and
falls back to any free memory range in the system on failure.

What do you say?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
