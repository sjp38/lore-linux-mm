Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B2949000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:55:16 -0400 (EDT)
Date: Mon, 26 Sep 2011 09:55:07 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] limit direct reclaim for higher order allocations
Message-ID: <20110926095507.34a2c48c@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

When suffering from memory fragmentation due to unfreeable pages,
THP page faults will repeatedly try to compact memory.  Due to
the unfreeable pages, compaction fails.

Needless to say, at that point page reclaim also fails to create
free contiguous 2MB areas.  However, that doesn't stop the current
code from trying, over and over again, and freeing a minimum of
4MB (2UL << sc->order pages) at every single invocation.

This resulted in my 12GB system having 2-3GB free memory, a
corresponding amount of used swap and very sluggish response times.

This can be avoided by having the direct reclaim code not reclaim
from zones that already have plenty of free memory available for
compaction.

If compaction still fails due to unmovable memory, doing additional
reclaim will only hurt the system, not help.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
I believe Mel has another idea in mind on how to fix this issue. 
I believe it will be good to compare both approaches side by side...

 mm/vmscan.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7719ec..56811a1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2083,6 +2083,22 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
+			if (COMPACTION_BUILD) {
+				/*
+				 * If we already have plenty of memory free
+				 * for compaction, don't free any more.
+				 */
+				unsigned long balance_gap;
+				balance_gap = min(low_wmark_pages(zone),
+					(zone->present_pages +
+					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+					KSWAPD_ZONE_BALANCE_GAP_RATIO);
+				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
+					zone_watermark_ok_safe(zone, 0,
+					high_wmark_pages(zone) + balance_gap +
+					(2UL << sc->order), 0, 0))
+					continue;
+			}
 			/*
 			 * This steals pages from memory cgroups over softlimit
 			 * and returns the number of reclaimed pages and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
