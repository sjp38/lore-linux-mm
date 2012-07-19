Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 729546B007B
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:53 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/34] mm: limit direct reclaim for higher order allocations
Date: Thu, 19 Jul 2012 15:36:19 +0100
Message-Id: <1342708604-26540-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

commit e0887c19b2daa140f20ca8104bdc5740f39dbb86 upstream.

Stable note: Not tracked on Bugzilla. THP and compaction was found to
	aggressively reclaim pages and stall systems under different
	situations that was addressed piecemeal over time. Paragraph
	3 of this changelog is the motivation for this patch.

When suffering from memory fragmentation due to unfreeable pages, THP page
faults will repeatedly try to compact memory.  Due to the unfreeable
pages, compaction fails.

Needless to say, at that point page reclaim also fails to create free
contiguous 2MB areas.  However, that doesn't stop the current code from
trying, over and over again, and freeing a minimum of 4MB (2UL <<
sc->order pages) at every single invocation.

This resulted in my 12GB system having 2-3GB free memory, a corresponding
amount of used swap and very sluggish response times.

This can be avoided by having the direct reclaim code not reclaim from
zones that already have plenty of free memory available for compaction.

If compaction still fails due to unmovable memory, doing additional
reclaim will only hurt the system, not help.

[jweiner@redhat.com: change comment to explain the order check]
Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ca1cd5..d11b6c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2059,6 +2059,22 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
+			if (COMPACTION_BUILD) {
+				/*
+				 * If we already have plenty of memory
+				 * free for compaction, don't free any
+				 * more.  Even though compaction is
+				 * invoked for any non-zero order,
+				 * only frequent costly order
+				 * reclamation is disruptive enough to
+				 * become a noticable problem, like
+				 * transparent huge page allocations.
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
