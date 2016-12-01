Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE167280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 09:24:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o2so32064317wje.5
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 06:24:31 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id p75si836721wmd.162.2016.12.01.06.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 06:24:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 0C1161C2DF1
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 14:24:30 +0000 (GMT)
Date: Thu, 1 Dec 2016 14:24:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v4
Message-ID: <20161201142429.w6lazfn4g6ndpezl@techsingularity.net>
References: <20161201002440.5231-1-mgorman@techsingularity.net>
 <8c666476-f8b6-d468-6050-56e3b5ff84cd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8c666476-f8b6-d468-6050-56e3b5ff84cd@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 01, 2016 at 02:41:29PM +0100, Vlastimil Babka wrote:
> On 12/01/2016 01:24 AM, Mel Gorman wrote:
> 
> ...
> 
> > @@ -1096,28 +1097,29 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  	if (nr_scanned)
> >  		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
> > 
> > -	while (count) {
> > +	while (count > 0) {
> >  		struct page *page;
> >  		struct list_head *list;
> > +		unsigned int order;
> > 
> >  		/*
> >  		 * Remove pages from lists in a round-robin fashion. A
> >  		 * batch_free count is maintained that is incremented when an
> > -		 * empty list is encountered.  This is so more pages are freed
> > -		 * off fuller lists instead of spinning excessively around empty
> > -		 * lists
> > +		 * empty list is encountered. This is not exact due to
> > +		 * high-order but percision is not required.
> >  		 */
> >  		do {
> >  			batch_free++;
> > -			if (++migratetype == MIGRATE_PCPTYPES)
> > -				migratetype = 0;
> > -			list = &pcp->lists[migratetype];
> > +			if (++pindex == NR_PCP_LISTS)
> > +				pindex = 0;
> > +			list = &pcp->lists[pindex];
> >  		} while (list_empty(list));
> > 
> >  		/* This is the only non-empty list. Free them all. */
> > -		if (batch_free == MIGRATE_PCPTYPES)
> > +		if (batch_free == NR_PCP_LISTS)
> >  			batch_free = count;
> > 
> > +		order = pindex_to_order(pindex);
> >  		do {
> >  			int mt;	/* migratetype of the to-be-freed page */
> > 
> > @@ -1135,11 +1137,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			if (bulkfree_pcp_prepare(page))
> >  				continue;
> 
> Hmm I think that if this hits, we don't decrease count/increase nr_freed and
> pcp->count will become wrong.

Ok, I think you're right but I also think it's relatively trivial to fix
with

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 94808f565f74..8777aefc1b8e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1134,13 +1134,13 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (unlikely(isolated_pageblocks))
 				mt = get_pageblock_migratetype(page);
 
+			nr_freed += (1 << order);
+			count -= (1 << order);
 			if (bulkfree_pcp_prepare(page))
 				continue;
 
 			__free_one_page(page, page_to_pfn(page), zone, order, mt);
 			trace_mm_page_pcpu_drain(page, order, mt);
-			nr_freed += (1 << order);
-			count -= (1 << order);
 		} while (count > 0 && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);

> And if we are unlucky/doing full drain, all
> lists will get empty, but as count stays e.g. 1, we loop forever on the
> outer while()?
> 

Potentially yes. Granted the system is already in a bad state as pages
are being freed in a bad or unknown state but we haven't halted the
system for that in the past.

> BTW, I think there's a similar problem (but not introduced by this patch) in
> rmqueue_bulk() and its
> 
>     if (unlikely(check_pcp_refill(page)))
>             continue;
> 

Potentially yes. It's outside the scope of this patch but it needs
fixing.

If you agree with the above fix, I'll roll it into a v5 and append
another patch for this issue.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
