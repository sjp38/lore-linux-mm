Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B7C046B0255
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:13:11 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so218625651wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:13:11 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id cw6si43667148wjc.208.2015.07.29.06.05.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 06:05:33 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id DF466992CB
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 13:05:01 +0000 (UTC)
Date: Wed, 29 Jul 2015 14:04:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150729130459.GD19352@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-11-git-send-email-mgorman@suse.com>
 <55B8C629.80303@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55B8C629.80303@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 29, 2015 at 02:25:13PM +0200, Vlastimil Babka wrote:
> On 07/20/2015 10:00 AM, Mel Gorman wrote:
> 
> [...]
> 
> >  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  			unsigned long mark, int classzone_idx, int alloc_flags,
> > @@ -2259,7 +2261,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  {
> >  	long min = mark;
> >  	int o;
> > -	long free_cma = 0;
> > +	const bool atomic = (alloc_flags & ALLOC_HARDER);
> >  
> >  	/* free_pages may go negative - that's OK */
> >  	free_pages -= (1 << order) - 1;
> > @@ -2271,7 +2273,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  	 * If the caller is not atomic then discount the reserves. This will
> >  	 * over-estimate how the atomic reserve but it avoids a search
> >  	 */
> > -	if (likely(!(alloc_flags & ALLOC_HARDER)))
> > +	if (likely(!atomic))
> >  		free_pages -= z->nr_reserved_highatomic;
> >  	else
> >  		min -= min / 4;
> > @@ -2279,22 +2281,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  #ifdef CONFIG_CMA
> >  	/* If allocation can't use CMA areas don't use free CMA pages */
> >  	if (!(alloc_flags & ALLOC_CMA))
> > -		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> > +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> >  #endif
> >  
> > -	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> > +	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
> >  		return false;
> > -	for (o = 0; o < order; o++) {
> > -		/* At the next order, this order's pages become unavailable */
> > -		free_pages -= z->free_area[o].nr_free << o;
> >  
> > -		/* Require fewer higher order pages to be free */
> > -		min >>= 1;
> > +	/* order-0 watermarks are ok */
> > +	if (!order)
> > +		return true;
> > +
> > +	/* Check at least one high-order page is free */
> > +	for (o = order; o < MAX_ORDER; o++) {
> > +		struct free_area *area = &z->free_area[o];
> > +		int mt;
> > +
> > +		if (atomic && area->nr_free)
> > +			return true;
> 
> This may be a false positive due to MIGRATE_CMA or MIGRATE_ISOLATE pages being
> the only free ones. But maybe it doesn't matter that much?
> 

I don't think it does. If it it's a false positive then a high-order
atomic allocation may fail which is still meant to be a situation the
caller can cope with.

For MIGRATE_ISOLATE, it's a transient situation.

If this can be demonstrated as a problem for users of CMA then it would be
best to be certain there is a use case that requires more reliable high-order
atomic allocations *and* CMA at the same time. Ordinarily, CMA users are
also not atomic because they cannot migrate. If such an important use case
can be identified then it's a one-liner patch and a changelog that adds

	if (!IS_ENABLED(CONFIG_CMA) && atomic && area->nr_free)

> >  
> > -		if (free_pages <= min)
> > -			return false;
> > +		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
> > +			if (!list_empty(&area->free_list[mt]))
> > +				return true;
> > +		}
> 
> This may be a false negative for ALLOC_CMA allocations, if the only free pages
> are of MIGRATE_CMA. Arguably that's the worse case than a false positive?
> 

I also think this is unlikely that there are many high-order atomic
allocations and CMA at the same time. If it's identified to be the case
then CMA also needs to check the pageblock type inside when CONFIG_CMA
is enabled. Again, it's something I would prefer to see that has a
concrete use case first.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
