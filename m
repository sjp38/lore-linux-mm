From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/8] Create optional ZONE_MOVABLE to partition memory between movable and non-movable pages v2
Date: Thu,  1 Mar 2007 10:08:02 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog since v1
o Rebased to 2.6.20-rc6-mm2
o Added necessary changes to per-zone VM stats for new zone (Christoph)
o Removed unnecessary changes to __ZONE_SHIFT (Christoph)
o Added paranoid check for overflow in cmdline_parse_kernelcore (Andy)

The following 8 patches against 2.6.20-mm2 create a zone called ZONE_MOVABLE
that is only usable by allocations that specify both __GFP_HIGHMEM and
__GFP_MOVABLE. This has the effect of keeping all non-movable pages within a
single memory partition while allowing movable allocations to be satisfied
from either partition. The patches may be applied with the list-based
anti-fragmentation patches that groups pages together based on mobility.

The size of the zone is determined by a kernelcore= parameter specified at
boot-time. This specifies how much memory is usable by non-movable allocations
and the remainder is used for ZONE_MOVABLE. Any range of pages within
ZONE_MOVABLE can be released by migrating the pages or by reclaiming.

When selecting a zone to take pages from for ZONE_MOVABLE, there are two
things to consider. First, only memory from the highest populated zone is
used for ZONE_MOVABLE. On the x86, this is probably going to be ZONE_HIGHMEM
but it would be ZONE_DMA on ppc64 or possibly ZONE_DMA32 on x86_64. Second,
the amount of memory usable by the kernel will be spread evenly throughout
NUMA nodes where possible. If the nodes are not of equal size, the amount
of memory usable by the kernel on some nodes may be greater than others.

By default, the zone is not as useful for hugetlb allocations because they
are pinned and non-migratable (currently at least). A sysctl is provided that
allows huge pages to be allocated from that zone. This means that the huge
page pool can be resized to the size of ZONE_MOVABLE during the lifetime of
the system assuming that pages are not mlocked. Despite huge pages being
non-movable, we do not introduce additional external fragmentation of note
as huge pages are always the largest contiguous block we care about.

Credit goes to Andy Whitcroft for catching a large variety of problems during
review of the patches.
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
