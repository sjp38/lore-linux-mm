Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE066B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:12:09 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:17:14 -0500
Message-Id: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 0/6] Numa: Use Generic Per-cpu Variables for numa_*_id()
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC - 00/NN - numa:  Use generic per-cpu variables for numa_*_id()

In http://marc.info/?l=linux-mm&m=125683610312546&w=4 , I described a
performance problem with slab and memoryless nodes that we see on some
of our platforms.  I proposed modifying slab to use the "effective local
memory node"--the node that local mempolicy would select--as the "local"
node id for slab allocation purposes.  This will allow slab to cache objects
from its "local memory node" on the percpu queues, effectively eliminating
the problem.

Christoph Lameter suggested a more general approach using the generic
percpu support:  define a new interface--e.g., numa_mem_id()--that returns
the "effective local memory node" for the calling context [cpu].  For
nodes with memory, this will == the id of the node itself.  For memoryless
nodes, this will be the first node in the generic [!this_node] zonelist.

Christoph also suggested converting the current "numa_node_id()" interface
to use the generic percpu infrastructure.  x86[_64] supports a custom [arch-
specific] per cpu variable implementation of numa_node_id().  Most other
archs do a table lookup.

This series introduces a generic percpu implementation of numa_node_id()
and numa_mem_id() in separate patches based on an incomplete "starter patch"
from Christoph.  Both of these implementations are conditional on new respective
config options.  I know that new config options aren't popular, but this
allows other archs to adapt to the new implementations incrementally.

Additional patches provide x86_64 and ia64 arch specific changes to use the
new numa_node_id() implementation, and ia64 support for the numa_mem_id()
interface.  Finally, I've reimplemented the "slab memoryless node 'regression'
fix" patch linked above atop the new numa_mem_id() interface.

Ad hoc measurements on x86_64 using:  hackbench 400 process 200

2.6.32-rc5+mmotm-091101		no patch	this series
x86_64 avg of 40:		  4.605		  4.628  ~0.5%

Ia64 showed ~1.2% longer time with the series applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
