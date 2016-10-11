Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9F16B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 03:09:49 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hm5so9747443pac.4
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 00:09:49 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z7si2047836pax.181.2016.10.11.00.09.47
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 00:09:48 -0700 (PDT)
Date: Tue, 11 Oct 2016 16:09:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161011070945.GA21238@bbox>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
 <20161007090917.GA18447@dhcp22.suse.cz>
 <20161007144345.GC3060@bbox>
 <20161010074139.GB20420@dhcp22.suse.cz>
 <20161011050141.GB30973@bbox>
 <20161011065048.GB31996@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011065048.GB31996@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue, Oct 11, 2016 at 08:50:48AM +0200, Michal Hocko wrote:
> On Tue 11-10-16 14:01:41, Minchan Kim wrote:
> > Hi Michal,
> > 
> > On Mon, Oct 10, 2016 at 09:41:40AM +0200, Michal Hocko wrote:
> > > On Fri 07-10-16 23:43:45, Minchan Kim wrote:
> > > > On Fri, Oct 07, 2016 at 11:09:17AM +0200, Michal Hocko wrote:
> [...]
> > > > > @@ -2102,10 +2109,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > > > >  			set_pageblock_migratetype(page, ac->migratetype);
> > > > >  			move_freepages_block(zone, page, ac->migratetype);
> > > > >  			spin_unlock_irqrestore(&zone->lock, flags);
> > > > > -			return;
> > > > > +			return true;
> > > > 
> > > > Such cut-off makes reserved pageblock remained before the OOM.
> > > > We call it as premature OOM kill.
> > > 
> > > Not sure I understand. The above should get rid of all atomic reserves
> > > before we go OOM. We can do it all at once but that sounds too
> > 
> > The problem is there is race between page freeing path and unreserve
> > logic so that some pages could be in highatomic free list even though
> > zone->nr_reserved_highatomic is already zero.
> 
> Does it make any sense to handle such an unlikely case?

I agree if it's really hard to solve but why should we remain
such hole in the algorithm if we can fix easily?

> 
> > So, at least, it would be better to have a draining step at some point
> > where was (no_progress_loops == MAX_RECLAIM RETRIES) in my patch.
> > 
> > Also, your patch makes retry loop greater than MAX_RECLAIM_RETRIES
> > if unreserve_highatomic_pageblock returns true. Theoretically,
> > it would make live lock. You might argue it's *really really* rare
> > but I don't want to add such subtle thing.
> > Maybe, we could drain when no_progress_loops == MAX_RECLAIM_RETRIES.
> 
> What would be the scenario when we would really livelock here? How can
> we have unreserve_highatomic_pageblock returning true for ever?

Other context freeing highorder page/reallocating repeatedly while
a process stucked direct reclaim is looping with should_reclaim_retry.

> 
> > > aggressive to me. If we just do one at the time we have a chance to
> > > keep some reserves if the OOM situation is really ephemeral.
> > > 
> > > Does this patch work in your usecase?
> > 
> > I didn't test but I guess it works but it has problems I mentioned
> > above. 
> 
> Please do not make this too over complicated and be practical. I do not
> really want to dismiss your usecase but I am really not convinced that
> such a "perfectly fit into all memory" situations are sustainable and
> justify to make the whole code more complex. I agree that we can at
> least try to do something to release those reserves but let's do it
> as simple as possible.

If you think it's too complicated, how about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd91b8955b26..e3ce442e9976 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2098,7 +2098,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
  * intense memory pressure but failed atomic allocations should be easier
  * to recover from than an OOM.
  */
-static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
+static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
+						bool drain)
 {
 	struct zonelist *zonelist = ac->zonelist;
 	unsigned long flags;
@@ -2106,11 +2107,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	struct zone *zone;
 	struct page *page;
 	int order;
+	bool ret = false;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		/* Preserve at least one pageblock */
-		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+		if (!drain && zone->nr_reserved_highatomic <= pageblock_nr_pages)
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
@@ -2154,12 +2156,24 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 * may increase.
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
-			move_freepages_block(zone, page, ac->migratetype);
-			spin_unlock_irqrestore(&zone->lock, flags);
-			return;
+			ret = move_freepages_block(zone, page,
+						ac->migratetype);
+			/*
+			 * By race with page freeing functions, !highatomic
+			 * pageblocks can have free pages in highatomic free
+			 * list so if drain is true, try to unreserve every
+			 * free pages in highatomic free list without bailing
+			 * out.
+			 */
+			if (!drain) {
+				spin_unlock_irqrestore(&zone->lock, flags);
+				return ret;
+			}
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
+
+	return ret;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -3358,7 +3372,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	 * Shrink them them and try again
 	 */
 	if (!page && !drained) {
-		unreserve_highatomic_pageblock(ac);
+		unreserve_highatomic_pageblock(ac, false);
 		drain_all_pages(NULL);
 		drained = true;
 		goto retry;
@@ -3475,8 +3489,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
 	 */
-	if (*no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
+		if (unreserve_highatomic_pageblock(ac, true))
+			return true;
 		return false;
+	}
 
 	/*
 	 * Keep reclaiming pages while there is a chance this will lead
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
