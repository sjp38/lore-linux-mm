Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76Gj82g014615
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:45:08 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76Gj8Bn231664
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:45:08 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76Gj7wo025934
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 10:45:08 -0600
Date: Mon, 6 Aug 2007 09:45:06 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
Message-ID: <20070806164506.GP15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806164410.GO15714@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [09:44:10 -0700], Nishanth Aravamudan wrote:
> hugetlb: fix cpuset-constrained pool resizing
> 
> With the previous 3 patches in this series applied, if a process is in a
> constrained cpuset, and tries to grow the hugetlb pool, hugepages may be
> allocated on nodes outside of the process' cpuset. More concretely,
> growing the pool via
> 
> echo some_value > /proc/sys/vm/nr_hugepages
> 
> interleaves across all nodes with memory such that hugepage allocations
> occur on nodes outside the cpuset. Similarly, this process is able to
> change the values in values in
> /sys/devices/system/node/nodeX/nr_hugepages, even when X is not in the
> cpuset. This directly violates the isolation that cpusets is supposed to
> guarantee.
> 
> For pool growth: fix the sysctl case by only interleaving across the
> nodes in current's cpuset; fix the sysfs attribute case by verifying the
> requested node is in current's cpuset. For pool shrinking: both cases
> are mostly already covered by the cpuset_zone_allowed_softwall() check
> in dequeue_huge_page_node(), but make sure that we only iterate over the
> cpusets's nodes in try_to_free_low().
> 
> Before:
> 
> Trying to resize the pool back to     100 from the top cpuset
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    100
> Node 0 HugePages_Free:      0
> Done.     100 free
> /cpuset/set1 /cpuset ~
> Trying to resize the pool to     200 from a cpuset restricted to node 1
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    150
> Node 0 HugePages_Free:     50
> Done.     200 free
> Trying to shrink the pool on node 0 down to 0 from a cpuset restricted
> to node 1
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    150
> Node 0 HugePages_Free:      0
> Done.     150 free
> 
> After:
> 
> Trying to resize the pool back to     100 from the top cpuset
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    100
> Node 0 HugePages_Free:      0
> Done.     100 free
> /cpuset/set1 /cpuset ~
> Trying to resize the pool to     200 from a cpuset restricted to node 1
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    200
> Node 0 HugePages_Free:      0
> Done.     200 free
> Trying to grow the pool on node 0 up to 50 from a cpuset restricted to
> node 1
> Node 3 HugePages_Free:      0
> Node 2 HugePages_Free:      0
> Node 1 HugePages_Free:    200
> Node 0 HugePages_Free:      0
> Done.     200 free

This patch was also tested on: 2-node IA64, 4-node ppc64 (2 memoryless
nodes), 4-node ppc64 (no memoryless nodes), 4-node x86_64, !NUMA x86,
1-node x86 (NUMA-Q)

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
