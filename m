Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 51D4B6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:13:13 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so442930qga.36
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:13:13 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id u10si4678667qcc.6.2014.08.13.17.13.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 17:13:12 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 13 Aug 2014 20:13:12 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0BB52C90026
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:13:01 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s7E0D8LC59834440
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 00:13:08 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7E0D7kq017470
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:13:08 -0400
Date: Wed, 13 Aug 2014 17:13:01 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/4] Improve slab consumption with memoryless nodes
Message-ID: <20140814001301.GI11121@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

Anton noticed (http://www.spinics.net/lists/linux-mm/msg67489.html) that
on ppc LPARs with memoryless nodes, a large amount of memory was
consumed by slabs and was marked unreclaimable. He tracked it down to
slab deactivations in the SLUB core when we allocate remotely, leading
to poor efficiency always when memoryless nodes are present.

After much discussion, Joonsoo provided a few patches that help
significantly. They don't resolve the problem altogether:

 - memory hotplug still needs testing, that is when a memoryless node
   becomes memory-ful, we want to dtrt
 - there are other reasons for going off-node than memoryless nodes,
   e.g., fully exhausted local nodes

Neither case is resolved with this series, but I don't think that should
block their acceptance, as they can be explored/resolved with follow-on
patches.

The series consists of:

[1/4] topology: add support for node_to_mem_node() to determine the fallback node
[2/4] slub: fallback to node_to_mem_node() node if allocating on memoryless node

 - Joonsoo's patches to cache the nearest node with memory for each
   NUMA node

[3/4] Partial revert of 81c98869faa5 (""kthread: ensure locality of task_struct allocations")

 - At Tejun's request, keep the knowledge of memoryless node fallback to
   the allocator core.

[4/4] powerpc: reorder per-cpu NUMA information's initialization

 - Fix what appears to be a bug with when the NUMA topology information
   is stored in the powerpc initialization code.

 arch/powerpc/kernel/smp.c | 12 ++++++------
 arch/powerpc/mm/numa.c    | 13 ++++++++++---
 include/linux/topology.h  | 17 +++++++++++++++++
 kernel/kthread.c          |  2 +-
 mm/page_alloc.c           |  1 +
 mm/slub.c                 | 24 ++++++++++++++++++------
 6 files changed, 53 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
