Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DI0NwT021730
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 14:00:23 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DHwvMS518900
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:58:57 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DHwu87025840
	for <linux-mm@kvack.org>; Thu, 13 Sep 2007 13:58:56 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/5] [hugetlb] Dynamic huge page pool resizing
Date: Thu, 13 Sep 2007 10:58:55 -0700
Message-Id: <20070913175855.27074.27030.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>


In most real-world scenarios, configuring the size of the hugetlb pool
correctly is a difficult task.  If too few pages are allocated to the pool,
applications using MAP_SHARED may fail to mmap() a hugepage region and
applications using MAP_PRIVATE may receive SIGBUS.  Isolating too much memory
in the hugetlb pool means it is not available for other uses, especially those
programs not using huge pages.

The obvious answer is to let the hugetlb pool grow and shrink in response to
the runtime demand for huge pages.  The work Mel Gorman has been doing to
establish a memory zone for movable memory allocations makes dynamically
resizing the hugetlb pool reliable within the limits of that zone.  This patch
series implements dynamic pool resizing for private and shared mappings while
being careful to maintain existing semantics.  Please reply with your comments
and feedback; even just to say whether it would be a useful feature to you.
Thanks.

How it works
============

Upon depletion of the hugetlb pool, rather than reporting an error immediately,
first try and allocate the needed huge pages directly from the buddy allocator.
Care must be taken to avoid unbounded growth of the hugetlb pool, so the
hugetlb filesystem quota is used to limit overall pool size.  Additionally we
classify hugepages as locked memory (since that is what it actually is), and
only grow the pool where the process does not exceed its locked_vm limit.

The real work begins when we decide there is a shortage of huge pages.  What
happens next depends on whether the pages are for a private or shared mapping.
Private mappings are straightforward.  At fault time, if alloc_huge_page()
fails, we allocate a page from the buddy allocator and increment the source
node's surplus_huge_pages counter.  When free_huge_page() is called for a page
on a node with a surplus, the page is freed directly to the buddy allocator
instead of the hugetlb pool.

Because shared mappings require all the pages to be reserved up front, some
additional work must be done at mmap() to support them.  We determine the
reservation shortage and allocate the required number of pages all at once.
These pages are then added to the hugetlb pool and marked reserved.  Where that
is not possible the mmap() will fail.  As with private mappings, the
appropriate surplus counters are updated.  Since reserved huge pages won't
necessarily be used by the process, we can't be sure that free_huge_page() will
always be called to return surplus pages to the buddy allocator.  To prevent
the huge page pool from bloating, we must free unused surplus pages when their
reservation has ended.

Controlling it
==============

With the entire patch series applied, pool resizing is off by default so unless
specific action is taken, the semantics are unchanged.

To take advantage of the flexibility afforded by this patch series one must
tolerate a change in semantics.  To control hugetlb pool growth, the following
techniques can be employed:

 * A sysctl tunable to enable/disable the feature entirely
 * The size= mount option for hugetlbfs filesystems to limit pool size
 * The locked memory ulimit to limit individual users or processes

Future Improvements
===================

I am aware of the following issues and plan to address then in the future as
separate changes since they are not critical and to keep this patch series as
small as possible.

 * Modifying the pool size (via sysctl) while there is a pool surplus could be
   made smarter.  Right now the surplus is ignored which can result in unneeded
   alloc_fresh_huge_page() calls.

Changelog
=========

9/12/2007 - Version 2
 - Integrated the cpuset_mems_nr() best-effort reservation check
 - Surplus pool allocations respect cpuset and numa policy restrictions
 - Unused surplus pages that are part of a reservation are freed when the
   reservation is released

7/13/2007 - Initial Post

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
