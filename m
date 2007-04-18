From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070418135336.27180.32695.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/2] Finish polish for grouping pages by mobility
Date: Wed, 18 Apr 2007 14:53:36 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following two patches are intended to polish off fragmentation avoidance
in its current incarnation. My TODO list is currently empty with these
patches applied and I intend to look through other patchesets for a while
and watch for bugs. In contrast to previous patches, these are removing code,
not adding it.

The first patch removes the CONFIG_PAGE_GROUP_BY_MOBILITY as a compile-time
option. Once applied, pages will always be grouped by mobility except when it
is determined there is not enough memory to make it work. The compile-time
option is removed because it was considered underdesirable to alter the
page allocators behavior between configurations.

The second patch stops grouping high-order atomic allocations together. I
have a strong feeling that the MIGRATE_RESERVE that keeps the min_free_kbytes
pages contiguous should be enough. If another order-3 failure with e1000 or
any other atomic allocation arrives, grouping high-alloc pages can be tried
again. That way, it'll be known if the feature works as expected or not.

With these two patches, the stack is a little funky because it adds stuff
early in the set and removes them again later. Andrew, if you like I can
send a drop in replacement stack with the config options never added.

The performance effect we've seen with kernbench remain in the -0.1% to +3%
range for total CPU time. Whether a performance regression or gain is seen
depends on the size of the TLB. Every workload has a working set but what
is often forgotten is that the kernel portion of the working set is backed
by large page table entries and does not necessarily exhibit the locality
principal the same way userspace does.

When grouping pages by mobility, kernel allocations are backed by fewer
large page table entries than when they are scattered throughout the physical
address space. This frees up TLB entries that can then be used by userspace
so there can be a performance gain in both user and system CPU times due to
increased TLB reach. The gain is seen when the size of the working set would
normally exceed TLB reach. That is why we generally see performance gains
on x86_64 but not always on PPC64 because of its much larger TLB [1]. It
is expected that the longer the system is running the more noticeable the
effect becomes but it has not been measured. Glancing through the performance
tests on test.kernel.org, there were some improvements when 2.6.21-rc2-mm2
was released which may or may not be due to fragmentation avoidance but it
is certainly interesting.

As always, the success rates of high-order allocations is drastically
improved, particularly when used in combination with Andy's intelligent
reclaim work.

[1] Size does matter
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
