Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB6366B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:21:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so6577989wms.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:21:34 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 207si2452617wma.80.2017.01.12.09.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 09:21:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 1FAAC1C2183
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 17:21:32 +0000 (GMT)
Date: Thu, 12 Jan 2017 17:21:31 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] mm, page_alloc: Split buffered_rmqueue
Message-ID: <20170112172131.wd64o44kqg6e4nou@techsingularity.net>
References: <20170112104300.24345-1-mgorman@techsingularity.net>
 <20170112104300.24345-2-mgorman@techsingularity.net>
 <63cb1f14-ab02-31a2-f386-16c1b52f61fe@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <63cb1f14-ab02-31a2-f386-16c1b52f61fe@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Jan 12, 2017 at 04:44:20PM +0100, Vlastimil Babka wrote:
> On 01/12/2017 11:42 AM, Mel Gorman wrote:
> > buffered_rmqueue removes a page from a given zone and uses the per-cpu
> > list for order-0. This is fine but a hypothetical caller that wanted
> > multiple order-0 pages has to disable/reenable interrupts multiple
> > times. This patch structures buffere_rmqueue such that it's relatively
> > easy to build a bulk order-0 page allocator. There is no functional
> > change.
> 
> Strictly speaking, this will now skip VM_BUG_ON_PAGE(bad_range(...)) for
> order-0 allocations. Do we care?
> 

Not very much but it still could be done.

> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> > ---
> >  mm/page_alloc.c | 126 ++++++++++++++++++++++++++++++++++----------------------
> >  1 file changed, 77 insertions(+), 49 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2c6d5f64feca..d8798583eaf8 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2610,68 +2610,96 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
> >  #endif
> >  }
> > 
> > +/* Remote page from the per-cpu list, caller must protect the list */
> 
>     ^ Remove
> 
> > +static struct page *__rmqueue_pcplist(struct zone *zone, unsigned int order,
> > +			gfp_t gfp_flags, int migratetype, bool cold,
> 
> order and gfp_flags seem unused here
> 

This on top?


diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8798583eaf8..3b48e0315eb5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2610,10 +2610,10 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
 #endif
 }
 
-/* Remote page from the per-cpu list, caller must protect the list */
-static struct page *__rmqueue_pcplist(struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype, bool cold,
-			struct per_cpu_pages *pcp, struct list_head *list)
+/* Remove page from the per-cpu list, caller must protect the list */
+static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
+			bool cold, struct per_cpu_pages *pcp,
+			struct list_head *list)
 {
 	struct page *page;
 
@@ -2652,8 +2652,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	local_irq_save(flags);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	list = &pcp->lists[migratetype];
-	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
-							cold, pcp, list);
+	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone, gfp_flags);
@@ -2674,9 +2673,11 @@ struct page *rmqueue(struct zone *preferred_zone,
 	unsigned long flags;
 	struct page *page;
 
-	if (likely(order == 0))
-		return rmqueue_pcplist(preferred_zone, zone, order,
+	if (likely(order == 0)) {
+		page = rmqueue_pcplist(preferred_zone, zone, order,
 				gfp_flags, migratetype);
+		goto out;
+	}
 
 	/*
 	 * We most definitely don't want callers attempting to
@@ -2705,6 +2706,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
 
+out:
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 	return page;
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
