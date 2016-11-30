Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E22EB6B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:16:16 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so51186071wmw.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:16:16 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id r190si7340287wmr.61.2016.11.30.06.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 06:16:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id ED1141C2526
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:16:14 +0000 (GMT)
Date: Wed, 30 Nov 2016 14:16:13 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130141613.gnf63khbrzrps7ip@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <20161130130549.GE18432@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161130130549.GE18432@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Nov 30, 2016 at 02:05:50PM +0100, Michal Hocko wrote:
> On Sun 27-11-16 13:19:54, Mel Gorman wrote:
> [...]
> > @@ -2588,18 +2594,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> >  	struct page *page;
> >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> >  
> > -	if (likely(order == 0)) {
> > +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
> >  		struct per_cpu_pages *pcp;
> >  		struct list_head *list;
> >  
> >  		local_irq_save(flags);
> >  		do {
> > +			unsigned int pindex;
> > +
> > +			pindex = order_to_pindex(migratetype, order);
> >  			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > -			list = &pcp->lists[migratetype];
> > +			list = &pcp->lists[pindex];
> >  			if (list_empty(list)) {
> > -				pcp->count += rmqueue_bulk(zone, 0,
> > +				int nr_pages = rmqueue_bulk(zone, order,
> >  						pcp->batch, list,
> >  						migratetype, cold);
> > +				pcp->count += (nr_pages << order);
> >  				if (unlikely(list_empty(list)))
> >  					goto failed;
> 
> just a nit, we can reorder the check and the count update because nobody
> could have stolen pages allocated by rmqueue_bulk.

Ok, it's minor but I can do that.

> I would also consider
> nr_pages a bit misleading because we get a number or allocated elements.
> Nothing to lose sleep over...
> 

I didn't think of a clearer name because in this sort of context, I consider
a high-order page to be a single page.

> >  			}
> 
> But...  Unless I am missing something this effectively means that we do
> not exercise high order atomic reserves. Shouldn't we fallback to
> the locked __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC) for
> order > 0 && ALLOC_HARDER ? Or is this just hidden in some other code
> path which I am not seeing?
> 

Good spot, would this be acceptable to you?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 91dc68c2a717..94808f565f74 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2609,9 +2609,18 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				int nr_pages = rmqueue_bulk(zone, order,
 						pcp->batch, list,
 						migratetype, cold);
-				pcp->count += (nr_pages << order);
-				if (unlikely(list_empty(list)))
+				if (unlikely(list_empty(list))) {
+					/*
+					 * Retry high-order atomic allocs
+					 * from the buddy list which may
+					 * use MIGRATE_HIGHATOMIC.
+					 */
+					if (order && (alloc_flags & ALLOC_HARDER))
+						goto try_buddylist;
+
 					goto failed;
+				}
+				pcp->count += (nr_pages << order);
 			}
 
 			if (cold)
@@ -2624,6 +2633,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 
 		} while (check_new_pcp(page));
 	} else {
+try_buddylist:
 		/*
 		 * We most definitely don't want callers attempting to
 		 * allocate greater than order-1 page units with __GFP_NOFAIL.
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
