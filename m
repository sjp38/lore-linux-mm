Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DAFD86B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:35:03 -0500 (EST)
Received: by wmnn186 with SMTP id n186so133447948wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:35:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qm2si47535882wjc.191.2015.12.14.10.35.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 10:35:02 -0800 (PST)
Date: Mon, 14 Dec 2015 19:34:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151214183458.GA4167@dhcp22.suse.cz>
References: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
 <1448974607-10208-2-git-send-email-mhocko@kernel.org>
 <20151211161615.GA5593@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151211161615.GA5593@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri 11-12-15 11:16:15, Johannes Weiner wrote:
> On Tue, Dec 01, 2015 at 01:56:45PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
[...]
> This makes sense to me and the patch looks good. Just a few nitpicks.

Thanks for the review!

> Could you change the word "refactor" in the title? This is not a
> non-functional change.

Sure. I will go with rework.

> > @@ -2984,6 +2984,13 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
> >  	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
> >  }
> >  
> > +/*
> > + * Number of backoff steps for potentially reclaimable pages if the direct reclaim
> > + * cannot make any progress. Each step will reduce 1/MAX_STALL_BACKOFF of the
> > + * reclaimable memory.
> > + */
> > +#define MAX_STALL_BACKOFF 16
> 
> "stall backoff" is a fairly non-descript and doesn't give a good clue
> at what exactly the variable is going to be doing.

The idea was to reflect that this is a step in which we do a backoff
rather than absolute amount.

> How about MAX_DISCOUNT_RECLAIMABLE?

this would indicate an absolute value to me. What about MAX_RECLAIM_RETRIES?

> > @@ -3155,13 +3165,53 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_NORETRY)
> >  		goto noretry;
> >  
> > -	/* Keep reclaiming pages as long as there is reasonable progress */
> > +	/*
> > +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > +	 * and even then do not retry endlessly unless explicitly told so
> > +	 */
> >  	pages_reclaimed += did_some_progress;
> > -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> > -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> > -		/* Wait for some write requests to complete then retry */
> > -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> > -		goto retry;
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (!(gfp_mask & __GFP_NOFAIL) &&
> > +		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
> > +			goto noretry;
> > +
> > +		if (did_some_progress)
> > +			goto retry;
> > +	}
> 
> I'm a bit bothered by this change as goto noretry is not the inverse
> of not doing goto retry: goto noretry jumps over _may_oom().
> 
> Of course, _may_oom() would filter a higher-order allocation anyway,
> and we could say that it's such a fundamental concept that will never
> change in the kernel that it's not a problem to repeat this clause
> here. But you could probably say the same thing about not invoking OOM
> for < ZONE_NORMAL, for !__GFP_FS, for __GFP_THISNODE, and I'm a bit
> wary of these things spreading out of _may_oom() again after I just
> put effort into consolidating all the OOM clauses in there.

You are right. Our OOM rules are complex already and any partial rules
outside of _may_oom are adding to the confusion even more.

> It should be possible to keep the original branch and then nest the
> decaying retry logic in there.
> 
> > +	/*
> > +	 * Be optimistic and consider all pages on reclaimable LRUs as usable
> > +	 * but make sure we converge to OOM if we cannot make any progress after
> > +	 * multiple consecutive failed attempts.
> > +	 */
> > +	if (did_some_progress)
> > +		stall_backoff = 0;
> > +	else
> > +		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
> 
> The rest of the backoff logic would be nasty to shift out by another
> tab, but it could easily live in its own function.

Yeah, I'll go this way. It looks much better this way!

[...]
> > +	/*
> > +	 * Keep reclaiming pages while there is a chance this will lead somewhere.
> > +	 * If none of the target zones can satisfy our allocation request even
> > +	 * if all reclaimable pages are considered then we are screwed and have
> > +	 * to go OOM.
> > +	 */
> > +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> > +		unsigned long free = zone_page_state_snapshot(zone, NR_FREE_PAGES);
> > +		unsigned long target;
> > +
> > +		target = zone_reclaimable_pages(zone);
> > +		target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);
> > +		target += free;
> 
> target is also a little non-descript. Maybe available?
> 
> 		available += zone_reclaimable_pages(zone);
> 		available -= DIV_ROUND_UP(discount_reclaimable * available,
> 					  MAX_DISCOUNT_RECLAIMABLE);
> 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> 
> But yeah, this is mostly bikeshed territory now.

Thanks for the feeback. Here is the cumulative diff after all my current
changes.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e267faad4649..f77e283fb8c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2984,6 +2984,75 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
 }
 
+/*
+ * Maximum number of reclaim retries without any progress before OOM killer
+ * is consider as the only way to move forward.
+ */
+#define MAX_RECLAIM_RETRIES 16
+
+/*
+ * Checks whether it makes sense to retry the reclaim to make a forward progress
+ * for the given allocation request.
+ * The reclaim feedback represented by did_some_progress (any progress during
+ * the last reclaim round), pages_reclaimed (cumulative number of reclaimed
+ * pages) and no_progress_loops (number of reclaim rounds without any progress
+ * in a row) is considered as well as the reclaimable pages on the applicable
+ * zone list (with a backoff mechanism which is a function of no_progress_loops).
+ *
+ * Returns true if a retry is viable or false to enter the oom path.
+ */
+static inline bool
+should_reclaim_retry(gfp_t gfp_mask, unsigned order,
+		     struct alloc_context *ac, int alloc_flags,
+		     bool did_some_progress, unsigned long pages_reclaimed,
+		     int no_progress_loops)
+{
+	struct zone *zone;
+	struct zoneref *z;
+
+	/*
+	 * Make sure we converge to OOM if we cannot make any progress
+	 * several times in the row.
+	 */
+	if (no_progress_loops > MAX_RECLAIM_RETRIES)
+		return false;
+
+	/* Do not retry high order allocations unless they are __GFP_REPEAT */
+	if (order > PAGE_ALLOC_COSTLY_ORDER) {
+		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
+			return false;
+
+		if (did_some_progress)
+			return true;
+	}
+
+	/*
+	 * Keep reclaiming pages while there is a chance this will lead somewhere.
+	 * If none of the target zones can satisfy our allocation request even
+	 * if all reclaimable pages are considered then we are screwed and have
+	 * to go OOM.
+	 */
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
+		unsigned long available;
+
+		available = zone_reclaimable_pages(zone);
+		available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES);
+		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
+
+		/*
+		 * Would the allocation succeed if we reclaimed the whole available?
+		 */
+		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+				ac->high_zoneidx, alloc_flags, available)) {
+			/* Wait for some write requests to complete then retry */
+			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			return true;
+		}
+	}
+
+	return false;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -2996,6 +3065,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	int no_progress_loops = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3155,23 +3225,28 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;
 
-	/* Keep reclaiming pages as long as there is reasonable progress */
-	pages_reclaimed += did_some_progress;
-	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
-	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
-		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
-		goto retry;
+	if (did_some_progress) {
+		no_progress_loops = 0;
+		pages_reclaimed += did_some_progress;
+	} else {
+		no_progress_loops++;
 	}
 
+	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
+				 did_some_progress > 0, pages_reclaimed,
+				 no_progress_loops))
+		goto retry;
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
 		goto got_pg;
 
 	/* Retry as long as the OOM killer is making progress */
-	if (did_some_progress)
+	if (did_some_progress) {
+		no_progress_loops = 0;
 		goto retry;
+	}
 
 noretry:
 	/*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
