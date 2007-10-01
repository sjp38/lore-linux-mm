Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l91FHcgG001195
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 11:17:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91FHcFO429972
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:17:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91FHbg8004036
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 09:17:38 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing V6
Date: Mon, 01 Oct 2007 08:17:36 -0700
Message-Id: <20071001151736.12825.75984.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>


This release contains no significant changes to any of the patches.  I have
been running regression and performance tests on a variety of machines and
configurations.  Andrew, these patches relax restrictions related to sizing the
hugetlb pool.  The patches have reached stability in content, function, and
performance and I believe they are ready for wider testing.  Please consider
for merging into -mm.  I have included performance results at the end of this
mail.

Changelog
=========

10/01/2007 - Version 6
 - Rebased to 2.6.23-rc8-mm2

9/27/2007 - Version 5
 - Stream performance results added

9/24/2007 - Version 4
 - Smart handling of surplus pages when explictly resizing the pool
 - Fixed some counting bugs found in patch review

9/17/2007 - Version 3
 - fixed gather_surplus_pages 'needed' check
 - Removed 'locked_vm' changes from this series since that is really a
   separate logical change

9/12/2007 - Version 2
 - Integrated the cpuset_mems_nr() best-effort reservation check
 - Surplus pool allocations respect cpuset and numa policy restrictions
 - Unused surplus pages that are part of a reservation are freed when the
   reservation is released

7/13/2007 - Initial Post


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
hugetlb filesystem quota is used to limit overall pool size.

The real work begins when we decide there is a shortage of huge pages.  What
happens next depends on whether the pages are for a private or shared mapping.
Private mappings are straightforward.  At fault time, if alloc_huge_page()
fails, we allocate a page from the buddy allocator and increment the source
node's surplus_huge_pages counter.  When free_huge_page() is called for a page
on a node with a surplus, the page is freed directly to the buddy allocator
instead of the hugetlb pool.

Because shared mappings require all of the pages to be reserved up front, some
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

Performance
===========

When contiguous memory is readily available, it is expected that the cost of
dynamicly resizing the pool will be small.  This series has been performance
tested with 'stream' to measure this cost.

Stream (http://www.cs.virginia.edu/stream/) was linked with libhugetlbfs to
enable remapping of the text and data/bss segments into huge pages.

Stream with small array
-----------------------
Baseline: 	nr_hugepages = 0, No libhugetlbfs segment remapping
Preallocated:	nr_hugepages = 5, Text and data/bss remapping
Dynamic:	nr_hugepages = 0, Text and data/bss remapping

				Rate (MB/s)
Function	Baseline	Preallocated	Dynamic
Copy:		4695.6266	5942.8371	5982.2287
Scale:		4451.5776	5017.1419	5658.7843
Add:		5815.8849	7927.7827	8119.3552
Triad:		5949.4144	8527.6492	8110.6903

Stream with large array
-----------------------
Baseline: 	nr_hugepages =  0, No libhugetlbfs segment remapping
Preallocated:	nr_hugepages = 67, Text and data/bss remapping
Dynamic:	nr_hugepages =  0, Text and data/bss remapping

				Rate (MB/s)
Function	Baseline	Preallocated	Dynamic
Copy:		2227.8281	2544.2732	2546.4947
Scale:		2136.3208	2430.7294	2421.2074
Add:		2773.1449	4004.0021	3999.4331
Triad:		2748.4502	3777.0109	3773.4970

* All numbers are averages taken from 10 consecutive runs with a maximum
  standard deviation of 1.3 percent noted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
