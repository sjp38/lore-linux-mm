Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1A56B009B
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:02:12 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id x13so4923945qcv.27
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:02:11 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id f39si6712652qge.69.2014.09.09.12.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 12:02:11 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 15:02:09 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8B1E538C8067
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:02:05 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s89J25tt38011058
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 19:02:05 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s89J23IH019919
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 15:02:05 -0400
Date: Tue, 9 Sep 2014 12:01:54 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 0/3] Improve slab consumption with memoryless nodes
Message-ID: <20140909190154.GC22906@linux.vnet.ibm.com>
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

[1/3] topology: add support for node_to_mem_node() to determine the fallback node
[2/3] slub: fallback to node_to_mem_node() node if allocating on memoryless node

 - Joonsoo's patches to cache the nearest node with memory for each
   NUMA node

[3/3] Partial revert of 81c98869faa5 (""kthread: ensure locality of task_struct allocations")

 - At Tejun's request, keep the knowledge of memoryless node fallback to
   the allocator core.

 include/linux/topology.h | 17 +++++++++++++++++
 kernel/kthread.c         |  2 +-
 mm/page_alloc.c          |  1 +
 mm/slub.c                | 24 ++++++++++++++++++------
 4 files changed, 37 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
