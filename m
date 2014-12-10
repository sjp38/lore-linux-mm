Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5AA6B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 01:34:49 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so2178661pad.37
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 22:34:49 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id t3si3491407pdc.177.2014.12.09.22.34.46
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 22:34:47 -0800 (PST)
Date: Wed, 10 Dec 2014 15:38:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper
 buddy list when steal
Message-ID: <20141210063840.GC13371@js1304-P5Q-DELUXE>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com>
 <54856F88.8090300@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54856F88.8090300@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 08, 2014 at 10:29:44AM +0100, Vlastimil Babka wrote:
> On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> >There is odd behaviour when we steal freepages from other migratetype
> >buddy list. In try_to_steal_freepages(), we move all freepages in
> >the pageblock that founded freepage is belong to to the request
> >migratetype in order to mitigate fragmentation. If the number of moved
> >pages are enough to change pageblock migratetype, there is no problem. If
> >not enough, we don't change pageblock migratetype and add broken freepages
> >to the original migratetype buddy list rather than request migratetype
> >one. For me, this is odd, because we already moved all freepages in this
> >pageblock to the request migratetype. This patch fixes this situation to
> >add broken freepages to the request migratetype buddy list in this case.
> 
> I'd rather split the fix from the refactoring. And maybe my
> description is longer, but easier to understand? (I guess somebody
> else should judge this)

Your patch is much better to understand than mine. :)
No need to judge from somebody else.
After your patch is merged, I will resubmit these on top of it.

> 
> >This patch introduce new function that can help to decide if we can
> >steal the page without resulting in fragmentation. It will be used in
> >following patch for compaction finish criteria.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  include/trace/events/kmem.h |    7 +++--
> >  mm/page_alloc.c             |   72 +++++++++++++++++++++++++------------------
> >  2 files changed, 46 insertions(+), 33 deletions(-)
> >
> >diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> >index aece134..4ad10ba 100644
> >--- a/include/trace/events/kmem.h
> >+++ b/include/trace/events/kmem.h
> >@@ -268,11 +268,11 @@ TRACE_EVENT(mm_page_alloc_extfrag,
> >
> >  	TP_PROTO(struct page *page,
> >  		int alloc_order, int fallback_order,
> >-		int alloc_migratetype, int fallback_migratetype, int new_migratetype),
> >+		int alloc_migratetype, int fallback_migratetype),
> >
> >  	TP_ARGS(page,
> >  		alloc_order, fallback_order,
> >-		alloc_migratetype, fallback_migratetype, new_migratetype),
> >+		alloc_migratetype, fallback_migratetype),
> >
> >  	TP_STRUCT__entry(
> >  		__field(	struct page *,	page			)
> >@@ -289,7 +289,8 @@ TRACE_EVENT(mm_page_alloc_extfrag,
> >  		__entry->fallback_order		= fallback_order;
> >  		__entry->alloc_migratetype	= alloc_migratetype;
> >  		__entry->fallback_migratetype	= fallback_migratetype;
> >-		__entry->change_ownership	= (new_migratetype == alloc_migratetype);
> >+		__entry->change_ownership	= (alloc_migratetype ==
> >+					get_pageblock_migratetype(page));
> >  	),
> >
> >  	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 7c46d0f..7b4c9aa 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -1139,44 +1139,50 @@ static void change_pageblock_range(struct page *pageblock_page,
> >   * Returns the new migratetype of the pageblock (or the same old migratetype
> >   * if it was unchanged).
> >   */
> >-static int try_to_steal_freepages(struct zone *zone, struct page *page,
> >-				  int start_type, int fallback_type)
> >+static void try_to_steal_freepages(struct zone *zone, struct page *page,
> >+							int target_mt)
> >  {
> >+	int pages;
> >  	int current_order = page_order(page);
> >
> >-	/*
> >-	 * When borrowing from MIGRATE_CMA, we need to release the excess
> >-	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
> >-	 * is set to CMA so it is returned to the correct freelist in case
> >-	 * the page ends up being not actually allocated from the pcp lists.
> >-	 */
> >-	if (is_migrate_cma(fallback_type))
> >-		return fallback_type;
> >-
> >  	/* Take ownership for orders >= pageblock_order */
> >  	if (current_order >= pageblock_order) {
> >-		change_pageblock_range(page, current_order, start_type);
> >-		return start_type;
> >+		change_pageblock_range(page, current_order, target_mt);
> >+		return;
> 
> So here's a (current_order >= pageblock_order) check.
> 
> >  	}
> >
> >-	if (current_order >= pageblock_order / 2 ||
> >-	    start_type == MIGRATE_RECLAIMABLE ||
> >-	    page_group_by_mobility_disabled) {
> >-		int pages;
> >+	pages = move_freepages_block(zone, page, target_mt);
> >
> >-		pages = move_freepages_block(zone, page, start_type);
> >+	/* Claim the whole block if over half of it is free */
> >+	if (pages >= (1 << (pageblock_order-1)) ||
> >+			page_group_by_mobility_disabled) {
> >
> >-		/* Claim the whole block if over half of it is free */
> >-		if (pages >= (1 << (pageblock_order-1)) ||
> >-				page_group_by_mobility_disabled) {
> >+		set_pageblock_migratetype(page, target_mt);
> >+	}
> >+}
> >
> >-			set_pageblock_migratetype(page, start_type);
> >-			return start_type;
> >-		}
> >+static bool can_steal_freepages(unsigned int order,
> >+			int start_mt, int fallback_mt)
> >+{
> >+	/*
> >+	 * When borrowing from MIGRATE_CMA, we need to release the excess
> >+	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
> >+	 * is set to CMA so it is returned to the correct freelist in case
> >+	 * the page ends up being not actually allocated from the pcp lists.
> >+	 */
> >+	if (is_migrate_cma(fallback_mt))
> >+		return false;
> >
> >-	}
> >+	/* Can take ownership for orders >= pageblock_order */
> >+	if (order >= pageblock_order)
> >+		return true;
> 
> And another check.
> 
> >+
> >+	if (order >= pageblock_order / 2 ||
> >+		start_mt == MIGRATE_RECLAIMABLE ||
> >+		page_group_by_mobility_disabled)
> >+		return true;
> >
> >-	return fallback_type;
> >+	return false;
> >  }
> >
> >  /* Remove an element from the buddy allocator from the fallback list */
> >@@ -1187,6 +1193,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  	unsigned int current_order;
> >  	struct page *page;
> >  	int migratetype, new_type, i;
> >+	bool can_steal;
> >
> >  	/* Find the largest possible block of pages in the other list */
> >  	for (current_order = MAX_ORDER-1;
> >@@ -1194,6 +1201,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  				--current_order) {
> >  		for (i = 0;; i++) {
> >  			migratetype = fallbacks[start_migratetype][i];
> >+			new_type = migratetype;
> >
> >  			/* MIGRATE_RESERVE handled later if necessary */
> >  			if (migratetype == MIGRATE_RESERVE)
> >@@ -1207,9 +1215,13 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  					struct page, lru);
> >  			area->nr_free--;
> 
> So wouldn't it be better to handle the "order >= pageblock_order"
> case separately at this level? I think it would be better also for
> the compaction case (I'll comment on the later patch why).

I will also comment on the later patch.

Thanks.

> 
> >-			new_type = try_to_steal_freepages(zone, page,
> >-							  start_migratetype,
> >-							  migratetype);
> >+			can_steal = can_steal_freepages(current_order,
> >+					start_migratetype, migratetype);
> >+			if (can_steal) {
> >+				new_type = start_migratetype;
> >+				try_to_steal_freepages(zone, page,
> >+							start_migratetype);
> >+			}
> >
> >  			/* Remove the page from the freelists */
> >  			list_del(&page->lru);
> >@@ -1225,7 +1237,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >  			set_freepage_migratetype(page, new_type);
> >
> >  			trace_mm_page_alloc_extfrag(page, order, current_order,
> >-				start_migratetype, migratetype, new_type);
> >+					start_migratetype, migratetype);
> >
> >  			return page;
> >  		}
> >
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
