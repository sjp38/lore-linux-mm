Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DFGNOD021585
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:16:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFGMTE152384
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:22 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFGMY5016502
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 09:16:22 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/5] [RFC] Dynamic hugetlb pool resizing
Date: Fri, 13 Jul 2007 08:16:21 -0700
Message-Id: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>


In most real-world scenarios, configuring the size of the hugetlb pool
correctly is a difficult task.  If too few pages are allocated to the pool,
then some applications will not be able to use huge pages or, in some cases,
programs that overcommit huge pages could receive SIGBUS.  Isolating too much
memory in the hugetlb pool means it is not available for other uses, especially
those programs not yet using huge pages.

The obvious answer is to let the hugetlb pool grow and shrink in response to
the runtime demand for huge pages.  The work Mel Gorman has been doing to
establish a memory zone for movable memory allocations makes dynamically
resizing the hugetlb pool reliable.  This patch series is an RFC to show how we
might ease the burden of hugetlb pool configuration.  Comments?

How It Works
============

The goal is: upon depletion of the hugetlb pool, rather than reporting an error
immediately, first try and allocate the needed huge pages directly from the
buddy allocator.  We must be careful to avoid unbounded growth of the hugetlb
pool so we begin by accounting for huge pages as locked memory (since that is
what it actually is).  We will only allow a process to grow the hugetlb pool if
those allocations will not cause it to exceed its locked_vm ulimit.
Additionally, a sysctl parameter could be introduced that could govern if pool
resizing is permitted.

The real work begins when we decide there is a shortage of huge pages.  What
happens next depends on whether the pages are for a private or shared mapping.
Private mappings are straightforward.  At fault time, if alloc_huge_page()
fails, we allocate a page from buddy and increment the appropriate
surplus_huge_pages counter.  Because of strict reservation, shared mappings are
a bit more tricky since we must guarantee the pages at mmap time.  For this
case we determine the number of pages we are short and allocate them all at
once.  They are then all added to the pool but marked as reserved
(resv_huge_pages) and surplus (surplus_huge_pages).

We want the hugetlb pool to gravitate back to its original size, so
free_huge_page() must know how to free pages back to buddy when there are
surplus pages.  This is done by using per-node surplus_pages counters so thet
the number of pages doesn't become imbalanced across NUMA nodes.

Issues
======

In rare cases, I have seen the size of the hugetlb pool increase or decrease by
a few pages.  I am continuing to debug the issue, but it is a relatively minor
issue since it doesn't adversely affect the stability of the system.

Recently, a cpuset check was added to the shared memory reservation code to
roughly detect cases where there are not enough pages within a cpuset to
satisfy an allocation.  I am not quite sure how to integrate this logic into
the dynamic pool resizing patches but I am sure someone more familiar with
cpusets will have some good ideas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
