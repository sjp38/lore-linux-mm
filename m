Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEEEF2806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:53:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c16so8451669pfl.21
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:01 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id e124si1635584pfc.59.2017.04.19.00.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:53:00 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id g2so2895150pge.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:00 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Date: Wed, 19 Apr 2017 17:52:38 +1000
Message-Id: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com, Balbir Singh <bsingharora@gmail.com>

This is a request for comments on the discussed approaches
for coherent memory at mm-summit (some of the details are at
https://lwn.net/Articles/717601/). The latest posted patch
series is at https://lwn.net/Articles/713035/. I am reposting
this as RFC, Michal Hocko suggested using HMM for CDM, but
we believe there are stronger reasons to use the NUMA approach.
The earlier patches for Coherent Device memory were implemented
and designed by Anshuman Khandual.

Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
The patches do a great deal to enable CDM with HMM, but we
still believe that HMM with CDM is not a natural way to
represent coherent device memory and the mm will need
to be audited and enhanced for it to even work.

With HMM we'll see ZONE_DEVICE pages mapped into
user space and that would mean a thorough audit of all code
paths to make sure we are ready for such a use case and enabling
those use cases, like with HMM CDM patch 1, which changes
move_pages() and migration paths. I've done a quick
evaluation to check for features and found limitationd around
features like migration (page cache
migration), fault handling to the right location
(direct page cache allocation in the coherent memory), mlock
handling, RSS accounting, memcg enforcement for pages not on LRU, etc.

This series has a set of 4 patches

The first patch defines N_COHERENT_MEMORY and supports onlining of
N_COHERENT_MEMORY.  The second one enables marking of coherent
memory nodes in architecture specific code, the third patch
enables mempolicy MPOL_BIND and MPOL_PREFERRED changes to
explicitly specify a node for allocation. The fourth patch adds
documentation explaining the design and motivation behind
coherent memory. The primary motivation of these patches
is to avoid allocator overhead that Mel Gorman had concerns with,
but for explicit specification of a node in the nodemask,
mempolicy changes are required.

Introduction and design (taken from patch 4)

Introduction

CDM device memory is cache coherent with system memory and we would like
this to show up as a NUMA node, however there are certain algorithms
that might not be currently suitable for N_COHERENT_MEMORY

1. AutoNUMA balancing
2. kswapd reclaim

The reason for exposing this device memory as NUMA is to simplify
the programming model, where memory allocation via malloc() or
mmap() for example would seamlessly work across both kinds of
memory. Since we expect the size of device memory to be smaller
than system RAM, we would like to control the allocation of such
memory. The proposed mechanism reuses nodemasks and explicit
specification of the coherent node in the nodemask for allocation
from device memory. This implementation also allows for kernel
level allocation via __GFP_THISNODE and existing techniques
such as page migration to work.

Assumptions:

1. Nodes with N_COHERENT_MEMORY don't have CPUs on them, so
effectively they are CPUless memory nodes
2. Nodes with N_COHERENT_MEMORY are marked as movable_nodes.
Slub allocations from these nodes will fail otherwise.

Implementation Details

A new node state N_COHERENT_MEMORY is created. Each architecture
can then mark devices as being N_COHERENT_MEMORY and the implementation
makes sure this node set is disjoint from the N_MEMORY node state
nodes. A typical node zonelist (FALLBACK) with N_COHERENT_MEMORY would
be:

Assuming we have 2 nodes and 1 coherent memory node

Node1:	Node 1 --> Node 2

Node2:	Node 2 --> Node 1

Node3:	Node 3 --> Node 2 --> Node 1

This effectively means that allocations that have Node 1 and Node 2
in the nodemask will not allocate from Node 3. Allocations with
__GFP_THISNODE use the NOFALLBACK list and should allocate from Node 3,
if it is specified.  Since Node 3 has no CPUs, we don't expect any
default allocations occurring from it.

However to support allocation from the coherent node, changes have been
made to mempolicy, specifically policy_nodemask() and policy_zonelist()
such that

1. MPOL_BIND with the coherent node (Node 3 in the above example) will
not filter out N_COHERENT_MEMORY if any of the nodes in the nodemask
is in N_COHERENT_MEMORY
2. MPOL_PREFERRED will use the FALLBACK list of the coherent node (Node 3)
if a policy that specifies a preference to it is used.

Limitations

The limitation of this approach might be that in the future we would want
more granularity of inclusion of algorithms for example could we have
N_COHERENT_MEMORY devices that want to participate in autonuma balancing,
but not participate in kswapd reclaim or vice-versa? One way to solve
the problem would be to have tunables or extend the notion of
N_COHERENT_MEMORY.

Using coherent memory is not compatible with cpusets, since cpusets
would enforce mems_allowed and mems_allowed will not contain the
coherent node. With numactl for example, the user would have to use
"-a" to parse all nodes.

Coherent memory relies on the node being a movable_node which is a
requirement for device memory anyway due to the need to hotplug them.

Review Recommendations

Michal Hocko/Mel Gorman for the approach and allocator bits
Vlastimil Babka/Christoph Lameter for the mempolicy changes.

Testing

I tested these patches in a virtual machine where I was able to simulate
coherent device memory. I had 3 normal NUMA nodes and one N_COHERENT_MEMORY
node. I ran mmtests with the config-global-dhp__pagealloc-performance config
and noted the numbers for the following tests in particular
page_test, brk_test, exec_test and fork_test. Observations from these
tests show

1. page_test shows similar rates for with and without coherent memory
and same number of nodes
2. brk_test was faster with coherent memory (3 NUMA, 1 COHERENT) as compared
to 4 NUMA nodes, but had similar rates as the system with (3 NUMA, 0 COHERENT) 
3. exec_test was a bit slower on the system with coherent memory compared
to a system with no coherent memory
4. fork_test was a bit slower on the system with coherent memory compared
to a system with no coherent memory

I also did some basic tests with numactl -a memhog with various membind
and preferred policies. I wrote a small kernel module to allocate
memory with __GFP_THISNODE and GFP_HIGHUSER_MOVABLE (for memory on the
coherent node).

Balbir Singh (4):
  mm: create N_COHERENT_MEMORY
  arch/powerpc/mm: add support for coherent memory
  mm: Integrate N_COHERENT_MEMORY with mempolicy and the rest of the
    system
  linux/mm: Add documentation for coherent memory

 Documentation/memory-hotplug.txt     | 11 +++++++
 Documentation/vm/00-INDEX            |  2 ++
 Documentation/vm/coherent-memory.txt | 59 ++++++++++++++++++++++++++++++++++++
 arch/powerpc/mm/numa.c               |  8 +++++
 drivers/base/memory.c                |  3 ++
 drivers/base/node.c                  |  2 ++
 include/linux/memory_hotplug.h       |  1 +
 include/linux/nodemask.h             |  1 +
 mm/memory_hotplug.c                  |  8 +++--
 mm/mempolicy.c                       | 30 ++++++++++++++++--
 mm/page_alloc.c                      | 20 +++++++++---
 11 files changed, 136 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/vm/coherent-memory.txt

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
