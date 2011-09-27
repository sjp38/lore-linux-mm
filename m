Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD739000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 10:53:28 -0400 (EDT)
Date: Tue, 27 Sep 2011 10:52:46 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v2 -mm] limit direct reclaim for higher order allocations
Message-ID: <20110927105246.164e2fc7@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, aarcange@redhat.com

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
-v2: shrink_zones now uses the same thresholds as used by compaction itself,
     not only is this conceptually nicer, it also results in kswapd doing
     some actual work; before all the page freeing work was done by THP
     allocators, I seem to see fewer application stalls after this change.

 mm/vmscan.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7719ec..117eb4d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2083,6 +2083,16 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
+			if (COMPACTION_BUILD) {
+				/*
+				 * If we already have plenty of memory free
+				 * for compaction, don't free any more.
+				 */
+				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
+					(compaction_suitable(zone, sc->order) ||
+					 compaction_deferred(zone)))
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
