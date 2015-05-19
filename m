Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E42A6B0095
	for <linux-mm@kvack.org>; Tue, 19 May 2015 03:43:50 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so12567206pab.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 00:43:49 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id c6si13515469pbu.220.2015.05.19.00.43.47
        for <linux-mm@kvack.org>;
        Tue, 19 May 2015 00:43:49 -0700 (PDT)
Date: Tue, 19 May 2015 16:44:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage if
 steal
Message-ID: <20150519074411.GB12092@js1304-P5Q-DELUXE>
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
 <5551B11C.4080000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5551B11C.4080000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Tue, May 12, 2015 at 09:51:56AM +0200, Vlastimil Babka wrote:
> On 04/27/2015 09:23 AM, Joonsoo Kim wrote:
> >When we steal whole pageblock, we don't need to break highest order
> >freepage. Perhaps, there is small order freepage so we can use it.
> >
> >This also gives us some code size reduction because expand() which
> >is used in __rmqueue_fallback() and inlined into __rmqueue_fallback()
> >is removed.
> >
> >    text    data     bss     dec     hex filename
> >   37413    1440     624   39477    9a35 mm/page_alloc.o
> >   37249    1440     624   39313    9991 mm/page_alloc.o
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/page_alloc.c | 40 +++++++++++++++++++++-------------------
> >  1 file changed, 21 insertions(+), 19 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index ed0f1c6..044f16c 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -1239,14 +1239,14 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
> >  }
> >
> >  /* Remove an element from the buddy allocator from the fallback list */
> 
> This is no longer accurate description.

Okay. Will fix.

> 
> >-static inline struct page *
> >+static inline bool
> >  __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  {
> >  	struct free_area *area;
> >  	unsigned int current_order;
> >  	struct page *page;
> >  	int fallback_mt;
> >-	bool can_steal;
> >+	bool can_steal_pageblock;
> >
> >  	/* Find the largest possible block of pages in the other list */
> >  	for (current_order = MAX_ORDER-1;
> >@@ -1254,26 +1254,24 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  				--current_order) {
> >  		area = &(zone->free_area[current_order]);
> >  		fallback_mt = find_suitable_fallback(area, current_order,
> >-				start_migratetype, false, &can_steal);
> >+						start_migratetype, false,
> >+						&can_steal_pageblock);
> >  		if (fallback_mt == -1)
> >  			continue;
> >
> >  		page = list_entry(area->free_list[fallback_mt].next,
> >  						struct page, lru);
> 
> >-		if (can_steal)
> >+		BUG_ON(!page);
> 
> Please no new BUG_ON. VM_BUG_ON maybe for debugging, otherwise just
> let it panic on null pointer exception accessing page->lru later on.

Okay. I will remove it.

> >+
> >+		if (can_steal_pageblock)
> >  			steal_suitable_fallback(zone, page, start_migratetype);
> >
> >-		/* Remove the page from the freelists */
> >-		area->nr_free--;
> >-		list_del(&page->lru);
> >-		rmv_page_order(page);
> >+		list_move(&page->lru, &area->free_list[start_migratetype]);
> 
> This list_move is redundant if we are stealing whole pageblock,
> right? Just put it in an else of the if above, and explain in
> comment?


I tried to put list_move() in an else of the if above and I got a
panic problem due to failure of stealing whole pageblock. In that
time, I didn't want to deep dive into the problem so used a simple
solution like as above. But, now I find the reason why steal sometimes
fail so I can fix it. I will fix it on next spin.

> 
> >-		expand(zone, page, order, current_order, area,
> >-					start_migratetype);
> >  		/*
> >  		 * The freepage_migratetype may differ from pageblock's
> >  		 * migratetype depending on the decisions in
> >-		 * try_to_steal_freepages(). This is OK as long as it
> >+		 * find_suitable_fallback(). This is OK as long as it
> >  		 * does not differ for MIGRATE_CMA pageblocks. For CMA
> >  		 * we need to make sure unallocated pages flushed from
> >  		 * pcp lists are returned to the correct freelist.
> 
> The whole thing with set_freepage_migratetype(page,
> start_migratetype); below this comment is now redundant, as
> rmqueue_smallest will do it too.
> The comment itself became outdated and misplaced too. I guess
> MIGRATE_CMA is now handled just by the fact that is is not set as
> fallback in the fallbacks array?

Okay. All comment seems to be redundant. I will remove it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
