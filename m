From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/3] Lumpy Reclaim V6
Message-ID: <exportbomb.1177081388@pinky>
Date: Fri, 20 Apr 2007 16:03:03 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Following this email are three patches to the lumpy reclaim
algorithm.  These apply on top of the lumpy patches in 2.6.21-rc6-mm1
(lumpy V5); making lumpy V6.  The first enables kswapd to apply
reclaim at the order of the allocations which trigger background
reclaim.  The second increases pressure on the area at the end of
the inactive list.  The last introduces a new symbolic constant
representing the boundary between easily reclaimed areas and those
where extra pressure is applicable.  Andrew, please consider for -mm.

Comparitive testing between lumpy-V5 and lumpy-V6 shows a
considerable improvement when under extreme load.  lumpy-V5 relies on
the pages in an area being rotated onto the inactive list together
and remaining inactive long enough to be reclaimed from that list.
Under high load a significant portion of the pages return to active
or are referenced before this can occur.  Lumpy-V6 targets all
LRU pages in the area greatly increasing the chance of reclaiming
it completely.

kswapd-use-reclaim-order-in-background-reclaim: When an allocator
  has to dip below the low water mark for a zone, kswapd is awoken
  to start background reclaim.  Make kswapd use the highest order
  of these allocations to define the order at which it reclaims.

lumpy-increase-pressure-at-the-end-of-the-inactive-list: when
  reclaiming at higher order target all pages in the contigious
  area for reclaim, including active and recently referenced pages.
  This increases the chances of that area becoming free.

introduce-HIGH_ORDER-delineating-easily-reclaimable-orders:
  The memory allocator treats lower and higher order allocations
  slightly differently.  Lumpy reclaim also changes behaviour at
  this same boundary.  Pull out the magic numbers and replace them
  with a symbolic constant.

Against: 2.6.21-rc6-mm1

-apw

Changes in lumpy V5:

   Andy Whitcroft:
      lumpy: back out removal of active check in isolate_lru_pages
      lumpy: only count taken pages as scanned

Changes in lumpy V4:

   Andy Whitcroft:
      lumpy: isolate_lru_pages wants to specifically take active
						      or inactive pages
      lumpy: ensure that we compare PageActive and active safely
      lumpy: update commentry on subtle comparisons and rounding assumptions
      lumpy: only check for valid pages when holes are present

Changes in lumpy V3:

   Adrian Bunk:
      lumpy-reclaim-cleanup

   Andrew Morton:
      lumpy-reclaim-v2-page_to_pfn-fix
      lumpy-reclaim-v2-tidy

   Andy Whitcroft:
      lumpy: ensure we respect zone boundaries
      lumpy: take the other active/inactive pages in the area

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
