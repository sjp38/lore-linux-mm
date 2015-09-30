Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5766B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:27:03 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so33294602pab.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:27:03 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id hc1si43960804pbc.117.2015.09.30.01.27.02
        for <linux-mm@kvack.org>;
        Wed, 30 Sep 2015 01:27:02 -0700 (PDT)
Date: Wed, 30 Sep 2015 17:28:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 4/9] mm/compaction: remove compaction deferring
Message-ID: <20150930082822.GB29589@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-5-git-send-email-iamjoonsoo.kim@lge.com>
 <560514F2.2060407@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560514F2.2060407@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Sep 25, 2015 at 11:33:38AM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> > Now, we have a way to determine compaction depleted state and compaction
> > activity will be limited according this state and depletion depth so
> > compaction overhead would be well controlled without compaction deferring.
> > So, this patch remove compaction deferring completely and enable
> > compaction activity limit.
> > 
> > Various functions are renamed and tracepoint outputs are changed due to
> > this removing.
> 
> It's more like renaming "deferred" to "failed" and the whole result is somewhat
> hard to follow, as the changelog doesn't describe a lot. So if I understand
> correctly:
> - compaction has to fail 4 times to cause __reset_isolation_suitable(), which
> also resets the fail counter back to 0
> - thus after each 4 failures, depletion depth is adjusted
> - when successes cross the depletion threshold, compaction_depleted() becomes
> false and then compact_zone will clear the flag
> - with flag clear, scan limit is no longer applied at all, but depletion depth
> stays as it is... it will be set to 0 when the flag is set again

Correct! I will add this description at some place.

> 
> Maybe the switch from "depleted with some depth" to "not depleted at all" could
> be more gradual?
> Also I have a suspicion that the main feature of this (IIUC) which is the scan
> limiting (and which I do consider improvement! and IIRC David wished for
> something like that too) could be achieved with less code churn that is renaming
> "deferred" to "failed" and adding another "depleted" state. E.g.
> compact_defer_shift looks similar to compact_depletion_depth, and deferring
> could be repurposed for scan limiting instead of binary go/no-go decisions. BTW
> the name "depleted" also suggests a binary state, so it's not that much better
> name than "deferred" IMHO.

Okay. I will try to change current deferred logic to scan limit logic
and make code less churn.
Naming? I will think more.

> Also I think my objection from patch 2 stays - __reset_isolation_suitable()
> called from kswapd will set zone->compact_success = 0, potentially increase
> depletion depth etc, with no connection to the number of failed compactions.
> 
> [...]
> 
> > @@ -1693,13 +1667,13 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
> >  		if (cc->order == -1)
> >  			__reset_isolation_suitable(zone);
> >  
> > -		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
> > +		if (cc->order == -1)
> 
> This change means kswapd no longer compacts from balance_pgdat() ->
> compact_pgdat(). Probably you meant to call compact_zone unconditionally here?

Yes, that's what I want. I will fix it.

> >  			compact_zone(zone, cc);
> >  
> >  		if (cc->order > 0) {
> >  			if (zone_watermark_ok(zone, cc->order,
> >  						low_wmark_pages(zone), 0, 0))
> > -				compaction_defer_reset(zone, cc->order, false);
> > +				compaction_failed_reset(zone, cc->order, false);
> >  		}
> >  
> >  		VM_BUG_ON(!list_empty(&cc->freepages));
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 0e9cc98..c67f853 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2827,7 +2827,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  		struct zone *zone = page_zone(page);
> >  
> >  		zone->compact_blockskip_flush = false;
> > -		compaction_defer_reset(zone, order, true);
> > +		compaction_failed_reset(zone, order, true);
> >  		count_vm_event(COMPACTSUCCESS);
> >  		return page;
> >  	}
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 37e90db..a561b5f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2469,10 +2469,10 @@ static inline bool compaction_ready(struct zone *zone, int order)
> >  	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
> >  
> >  	/*
> > -	 * If compaction is deferred, reclaim up to a point where
> > +	 * If compaction is depleted, reclaim up to a point where
> >  	 * compaction will have a chance of success when re-enabled
> >  	 */
> > -	if (compaction_deferred(zone, order))
> > +	if (test_bit(ZONE_COMPACTION_DEPLETED, &zone->flags))
> >  		return watermark_ok;
> 
> Hm this is a deviation from the "replace go/no-go with scan limit" principle.
> Also compaction_deferred() could recover after some retries, and this flag won't.

This means that if compaction success possibility is depleted there is
no need to reclaim more pages above watermark because more reclaim effort
is waste in this situation. It is same with compaction_deferred case.
Recover is done by attemping actual compaction by kswapd or direct
compaction because there is no blocker like as compaction_deferring
logic. I think that this code change is okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
