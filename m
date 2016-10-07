Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE528280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 05:09:21 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id bv10so22460599pad.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:09:21 -0700 (PDT)
Received: from mail-pf0-f195.google.com (mail-pf0-f195.google.com. [209.85.192.195])
        by mx.google.com with ESMTPS id x29si7819984pff.174.2016.10.07.02.09.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 02:09:21 -0700 (PDT)
Received: by mail-pf0-f195.google.com with SMTP id i85so2556698pfa.0
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:09:21 -0700 (PDT)
Date: Fri, 7 Oct 2016 11:09:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161007090917.GA18447@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475819136-24358-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Fri 07-10-16 14:45:35, Minchan Kim wrote:
> After fixing the race of highatomic page count, I still encounter
> OOM with many free memory reserved as highatomic.
> 
> One of reason in my testing was we unreserve free pages only if
> reclaim has progress. Otherwise, we cannot have chance to unreseve.
> 
> Other problem after fixing it was it doesn't guarantee every pages
> unreserving of highatomic pageblock because it just release *a*
> pageblock which could have few free pages so other context could
> steal it easily so that the process stucked with direct reclaim
> finally can encounter OOM although there are free pages which can
> be unreserved.
> 
> This patch changes the logic so that it unreserves pageblocks with
> no_progress_loop proportionally. IOW, in first retrial of reclaim,
> it will try to unreserve a pageblock. In second retrial of reclaim,
> it will try to unreserve 1/MAX_RECLAIM_RETRIES * reserved_pageblock
> and finally all reserved pageblock before the OOM.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/page_alloc.c | 57 ++++++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 44 insertions(+), 13 deletions(-)

This sounds much more complex then it needs to be IMHO. Why something as
simple as thhe following wouldn't work? Please note that I even didn't
try to compile this. It is just give you an idea.
---
 mm/page_alloc.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73f60ad6315f..e575a4f38555 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2056,7 +2056,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
  * intense memory pressure but failed atomic allocations should be easier
  * to recover from than an OOM.
  */
-static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
+static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
+		bool force)
 {
 	struct zonelist *zonelist = ac->zonelist;
 	unsigned long flags;
@@ -2067,8 +2068,14 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
 								ac->nodemask) {
-		/* Preserve at least one pageblock */
-		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+		if (!zone->nr_reserved_highatomic)
+			continue;
+
+		/*
+		 * Preserve at least one pageblock unless we are really running
+		 * out of memory
+		 */
+		if (!force && zone->nr_reserved_highatomic <= pageblock_nr_pages)
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
@@ -2102,10 +2109,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			set_pageblock_migratetype(page, ac->migratetype);
 			move_freepages_block(zone, page, ac->migratetype);
 			spin_unlock_irqrestore(&zone->lock, flags);
-			return;
+			return true;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
+
+	return false;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -3302,7 +3311,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 * Shrink them them and try again
 	 */
 	if (!page && !drained) {
-		unreserve_highatomic_pageblock(ac);
+		unreserve_highatomic_pageblock(ac, false);
 		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
@@ -3418,9 +3427,14 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	/*
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
+	 * Do last desparate attempt to throw high atomic reserves away
+	 * before we give up
 	 */
-	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
+		if (unreserve_highatomic_pageblock(ac, true))
+			return true;
 		return false;
+	}
 
 	/*
 	 * Keep reclaiming pages while there is a chance this will lead
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
