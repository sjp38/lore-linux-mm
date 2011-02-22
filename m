Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0F55C8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:05:32 -0500 (EST)
Date: Tue, 22 Feb 2011 16:04:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110222160449.GF15652@csn.ul.ie>
References: <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com> <20110222142559.GD15652@csn.ul.ie> <20110222144200.GY13092@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110222144200.GY13092@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, alex.shi@intel.com

On Tue, Feb 22, 2011 at 03:42:00PM +0100, Andrea Arcangeli wrote:
> I suggest to boot with transparent_hugepage=madvise, or to set the
> default to madvise in make menuconfig. That will still enable the
> anti-frag logic in the buddy allocator in full. If the problem goes
> away with the madvise setting, then it's not related to
> min_free_kbytes. With the 700M fix for kswapd however it's hard to
> imagine the increase min_free_kbytes to cause out of memory conditions
> even if it uses a little more memory to allow for increased
> performance thanks to hugepages.
> 

We didn't really agree on a fix though, did we? At least, I don't see a
patch we all agreed on in the thread. I stuck my ack on your patch but Rik
nak'd it because he wanted the balance gap to be preserved. We had sortof
agreed on a balance gap but didn't post a patch that implemented it. AFAIK,
an implementation of what was discussed is blow. If this is not the agreed
fix, what is? If we agree on it, can Shaohua confirm the fix works?

This is against 2.6.38-rc6 which still isn't fixed and I don't see a
candidate fix in mmotm either.

==== CUT HERE ====
mm: vmscan: kswapd should not free an excessive number of pages when balancing small zones

When reclaiming for order-0 pages, kswapd requires that all zones be
balanced. Each cycle through balance_pgdat() does background ageing on all
zones if necessary and applies equal pressure on the inactive zone unless
a lot of pages are free already.

A "lot of free pages" is defined as a "balance gap" above the high watermark
which is currently 7*high_watermark. Historically this was reasonable as
min_free_kbytes was small. However, on systems using huge pages, it is
recommended that min_free_kbytes is higher and it is tuned with hugeadm
--set-recommended-min_free_kbytes. With the introduction of transparent
huge page support, this recommended value is also applied. On X86-64 with
4G of memory, min_free_kbytes becomes 67584 so one would expect around 68M
of memory to be free. The Normal zone is approximately 35000 pages so under
even normal memory pressure such as copying a large file, it gets exhausted
quickly. As it is getting exhausted, kswapd applies pressure equally to all
zones, including the DMA32 zone. DMA32 is approximately 700,000 pages with
a high watermark of around 23,000 pages. In this situation, kswapd will
reclaim around (23000*8 where 8 is the high watermark + balance gap of 7 *
high watermark) pages or 718M of pages before the zone is ignored. What
the user sees is that free memory far higher than it should be.

To avoid an excessive number of pages being reclaimed from the larger zones,
explicitely defines the "balance gap" to be either 1% of the zone or the
low watermark for the zone, whichever is smaller.  While kswapd will check
all zones to apply pressure, it'll ignore zones that meets the (high_wmark +
balance_gap) watermark.

To test this, 80G were copied from a partition and the amount of memory
being used was recorded. A comparison of a patch and unpatched kernel
can be seen at
http://www.csn.ul.ie/~mel/postings/minfree-20110222/memory-usage-hydra.ps
and shows that kswapd is not reclaiming as much memory with the patch
applied.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/swap.h |    9 +++++++++
 mm/vmscan.c          |   16 +++++++++++++---
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4d55932..a57c6e7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -155,6 +155,15 @@ enum {
 #define SWAP_CLUSTER_MAX 32
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
+/*
+ * Ratio between the present memory in the zone and the "gap" that
+ * we're allowing kswapd to shrink in addition to the per-zone high
+ * wmark, even for zones that already have the high wmark satisfied,
+ * in order to provide better per-zone lru behavior. We are ok to
+ * spend not more than 1% of the memory for this zone balancing "gap".
+ */
+#define KSWAPD_ZONE_BALANCE_GAP_RATIO 100
+
 #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
 #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
 #define SWAP_HAS_CACHE	0x40	/* Flag page is cached, in first swap_map */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 17497d0..0c83530 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2388,6 +2388,7 @@ loop_again:
 			int compaction;
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
+			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
 				continue;
@@ -2404,11 +2405,20 @@ loop_again:
 			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
 
 			/*
-			 * We put equal pressure on every zone, unless one
-			 * zone has way too many pages free already.
+			 * We put equal pressure on every zone, unless
+			 * one zone has way too many pages free
+			 * already. The "too many pages" is defined
+			 * as the high wmark plus a "gap" where the
+			 * gap is either the low watermark or 1%
+			 * of the zone, whichever is smaller.
 			 */
+			balance_gap = min(low_wmark_pages(zone),
+				(zone->present_pages +
+					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+				KSWAPD_ZONE_BALANCE_GAP_RATIO);
 			if (!zone_watermark_ok_safe(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
+					high_wmark_pages(zone) + balance_gap,
+					end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
