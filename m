Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53E9B2806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:53:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c2so9632843pga.1
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:26 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id y70si1639197plh.90.2017.04.19.00.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:53:25 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id o123so2900985pga.1
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:25 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC 4/4] mm: Add documentation for coherent memory
Date: Wed, 19 Apr 2017 17:52:42 +1000
Message-Id: <20170419075242.29929-5-bsingharora@gmail.com>
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com, Balbir Singh <bsingharora@gmail.com>

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 Documentation/vm/00-INDEX            |  2 ++
 Documentation/vm/coherent-memory.txt | 59 ++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)
 create mode 100644 Documentation/vm/coherent-memory.txt

diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 11d3d8d..99175e9 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -6,6 +6,8 @@ balance
 	- various information on memory balancing.
 cleancache.txt
 	- Intro to cleancache and page-granularity victim cache.
+coherent-memory.txt
+	- Introduction to coherent memory handling (N_COHERENT_MEMORY)
 frontswap.txt
 	- Outline frontswap, part of the transcendent memory frontend.
 highmem.txt
diff --git a/Documentation/vm/coherent-memory.txt b/Documentation/vm/coherent-memory.txt
new file mode 100644
index 0000000..bd60e5b
--- /dev/null
+++ b/Documentation/vm/coherent-memory.txt
@@ -0,0 +1,59 @@
+Introduction
+
+This document describes a new type of node called N_COHERENT_MEMORY.
+This memory is cache coherent with system memory and we would like
+this to show up as a NUMA node, however there are certain algorithms
+that might not be currently suitable for N_COHERENT_MEMORY
+
+1. AutoNUMA balancing
+2. kswapd reclaim
+
+The reason for exposing this device memory as NUMA is to simplify
+the programming model, where memory allocation via malloc() or
+mmap() for example would seamlessly work across both kinds of
+memory. Since we expect the size of device memory to be smaller
+than system RAM, we would like to control the allocation of such
+memory. The proposed mechanism reuses nodemasks and explicit
+specification of the coherent node in the nodemask for allocation
+from device memory. This implementation also allows for kernel
+level allocation via __GFP_THISNODE and existing techniques
+such as page migration to work.
+
+Assumptions:
+
+1. Nodes with N_COHERENT_MEMORY don't have CPUs on them, so
+effectively they are CPUless memory nodes
+2. Nodes with N_COHERENT_MEMORY are marked as movable_nodes.
+Slub allocations from these nodes will fail otherwise.
+
+Implementation Details
+
+A new node state N_COHERENT_MEMORY is created. Each architecture
+can then mark devices as being N_COHERENT_MEMORY and the implementation
+makes sure this node set is disjoint from the N_MEMORY node state
+nodes. A typical node zonelist (FALLBACK) with N_COHERENT_MEMORY would
+be:
+
+Assuming we have 2 nodes and 1 coherent memory node
+
+Node1:	Node 1 --> Node 2
+
+Node2:	Node 2 --> Node 1
+
+Node3:	Node 3 --> Node 2 --> Node 1
+
+This effectively means that allocations that have Node 1 and Node 2
+in the nodemask will not allocate from Node 3. Allocations with __GFP_THISNODE
+use the NOFALLBACK list and should allocate from Node 3, if it
+is specified.  Since Node 3 has no CPUs, we don't expect any default
+allocations occurring from it.
+
+However to support allocation from the coherent node, changes have been
+made to mempolicy, specifically policy_nodemask() and policy_zonelist()
+such that
+
+1. MPOL_BIND with the coherent node (Node 3 in the above example) will
+not filter out N_COHERENT_MEMORY if any of the nodes in the nodemask
+is in N_COHERENT_MEMORY
+2. MPOL_PREFERRED will use the FALLBACK list of the coherent node (Node 3)
+if a policy that specifies a preference to it is used.
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
