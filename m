Date: Wed, 25 Jul 2007 19:30:52 +0100
Subject: [PATCH] Allow nodes to exist that only contain ZONE_MOVABLE
Message-ID: <20070725183052.GB1750@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

With the introduction of kernelcore=, a configurable zone is created on
request. In some cases, this value will be small enough that some nodes
contain only ZONE_MOVABLE. On some NUMA configurations when this occurs,
arch-independent zone-sizing will get the size of the memory holes within the
node incorrect. The value of present_pages goes negative and the boot fails.

This patch fixes the bug in the calculation of the size of the hole. The
test case is to boot test a NUMA machine with a low value of kernelcore=
before and after the patch is applied. While this bug exists in early kernel
it cannot be triggered in practice.

This patch has been boot-tested on a variety machines with and without
kernelcore= set.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 page_alloc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40954fb..6d3550c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2775,11 +2775,11 @@ unsigned long __meminit __absent_pages_in_range(int nid,
 	if (i == -1)
 		return 0;
 
+	prev_end_pfn = min(early_node_map[i].start_pfn, range_end_pfn);
+
 	/* Account for ranges before physical memory on this node */
 	if (early_node_map[i].start_pfn > range_start_pfn)
-		hole_pages = early_node_map[i].start_pfn - range_start_pfn;
-
-	prev_end_pfn = early_node_map[i].start_pfn;
+		hole_pages = prev_end_pfn - range_start_pfn;
 
 	/* Find all holes for the zone within the node */
 	for (; i != -1; i = next_active_region_index_in_nid(i, nid)) {
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
