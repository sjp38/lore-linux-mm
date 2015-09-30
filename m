Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EFB686B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:46:54 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so186757594wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:46:54 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id a5si28440wjy.77.2015.09.30.01.46.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 01:46:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 8617AC0005
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:46:52 +0000 (UTC)
Date: Wed, 30 Sep 2015 09:46:50 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150930084650.GM3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <20150921120317.GC3068@techsingularity.net>
 <20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150929140507.82b5e02f300038e4bb5b2493@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 29, 2015 at 02:05:07PM -0700, Andrew Morton wrote:
> >  static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  			unsigned long mark, int classzone_idx, int alloc_flags,
> > @@ -2317,7 +2319,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  {
> >  	long min = mark;
> >  	int o;
> > -	long free_cma = 0;
> > +	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
> 
> hmpf.  Setting a bool to 0x10 is a bit grubby.
>   

Should be safe, but I see your point. For any other type it would be
truncated and look like a bug.

> >  	/* free_pages may go negative - that's OK */
> >  	free_pages -= (1 << order) - 1;
> > @@ -2330,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  	 * the high-atomic reserves. This will over-estimate the size of the
> >  	 * atomic reserve but it avoids a search.
> >  	 */
> > -	if (likely(!(alloc_flags & ALLOC_HARDER)))
> > +	if (likely(!alloc_harder))
> >  		free_pages -= z->nr_reserved_highatomic;
> >  	else
> >  		min -= min / 4;
> > @@ -2338,22 +2340,43 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
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
> 
> because?
> 

The wizard of oz because because!

This should fix it up better than clicking my shoes three times.

---8<---
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: only enforce watermarks for order-0
 allocations -fix

This patch is updating comments for clarity and converts a bool to an
int. The code as-is is ok as the compiler is meant to cast it correctly
but it looks odd to people who know the value would be truncated and
lost for other types.

This is a fix to the mmotm patch
mm-page_alloc-only-enforce-watermarks-for-order-0-allocations.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 25731624d734..fedec98aafca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2332,7 +2332,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 {
 	long min = mark;
 	int o;
-	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
+	const int alloc_harder = (alloc_flags & ALLOC_HARDER);
 
 	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
@@ -2356,14 +2356,19 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif
 
+	/*
+	 * Check watermarks for an order-0 allocation request. If these
+	 * are not met, then a high-order request also cannot go ahead
+	 * even if a suitable page happened to be free.
+	 */
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return false;
 
-	/* order-0 watermarks are ok */
+	/* If this is an order-0 request then the watermark is fine */
 	if (!order)
 		return true;
 
-	/* Check at least one high-order page is free */
+	/* For a high-order request, check at least one suitable page is free */
 	for (o = order; o < MAX_ORDER; o++) {
 		struct free_area *area = &z->free_area[o];
 		int mt;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
