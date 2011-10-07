Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 738146B002E
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 11:17:28 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: vmscan: Limit direct reclaim for higher order allocations
Date: Fri,  7 Oct 2011 16:17:22 +0100
Message-Id: <1318000643-27996-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1318000643-27996-1-git-send-email-mgorman@suse.de>
References: <1318000643-27996-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org
Cc: Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Rik van Riel <riel@redhat.com>

When suffering from memory fragmentation due to unfreeable pages,
THP page faults will repeatedly try to compact memory.  Due to the
unfreeable pages, compaction fails.

Needless to say, at that point page reclaim also fails to create
free contiguous 2MB areas.  However, that doesn't stop the current
code from trying, over and over again, and freeing a minimum of 4MB
(2UL << sc->order pages) at every single invocation.

This resulted in my 12GB system having 2-3GB free memory, a
corresponding amount of used swap and very sluggish response times.

This can be avoided by having the direct reclaim code not reclaim from
zones that already have plenty of free memory available for compaction.

If compaction still fails due to unmovable memory, doing additional
reclaim will only hurt the system, not help.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b55699c..3817fa9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2066,6 +2066,16 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
