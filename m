Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TNFUtr016309
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 19:15:30 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TNFUHB241392
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 19:15:30 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TNFUrf002811
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 19:15:30 -0400
Date: Tue, 29 Aug 2006 16:15:45 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: libnuma interleaving oddness
Message-ID: <20060829231545.GY5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com, ak@suse.de
Cc: linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

[Sorry for the double-post, correcting Christoph's address]

Hi,

While trying to add NUMA-awareness to libhugetlbfs' morecore
functionality (hugepage-backed malloc), I ran into an issue on a
ppc64-box with 8 memory nodes, running SLES10. I am using two functions
from libnuma: numa_available() and numa_interleave_memory().  When I ask
numa_interleave_memory() to interleave over all nodes (numa_all_nodes is
the nodemask from libnuma), it exhausts node 0, then moves to node 1,
then node 2, etc, until the allocations are satisfied. If I custom
generate a nodemask, such that bits 1 through 7 are set, but bit 0 is
not, then I get proper interleaving, where the first hugepage is on node
1, the second is on node 2, etc. Similarly, if I set bits 0 through 6 in
a custom nodemask, interleaving works across the requested 7 nodes. But
it has yet to work across all 8.

I don't know if this is a libnuma bug (I extracted out the code from
libnuma, it looked sane; and even reimplemented it in libhugetlbfs for
testing purposes, but got the same results) or a NUMA kernel bug (mbind
is some hairy code...) or a ppc64 bug or maybe not a bug at all.
Regardless, I'm getting somewhat inconsistent behavior. I can provide
more debugging output, or whatever is requested, but I wasn't sure what
to include. I'm hoping someone has heard of or seen something similar?

The test application I'm using makes some mallopt calls then justs
mallocs large chunks in a loop (4096 * 100 bytes). libhugetlbfs is
LD_PRELOAD'd so that we can override malloc.

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
