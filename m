Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6D216B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 10:29:21 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z65so12102512itc.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 07:29:21 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d20si4072310itb.24.2016.10.07.07.29.20
        for <linux-mm@kvack.org>;
        Fri, 07 Oct 2016 07:29:21 -0700 (PDT)
Date: Fri, 7 Oct 2016 23:29:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
Message-ID: <20161007142919.GA3060@bbox>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
 <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

Hi Vlastimil,

On Fri, Oct 07, 2016 at 02:30:04PM +0200, Vlastimil Babka wrote:
> On 10/07/2016 07:45 AM, Minchan Kim wrote:
> >In page freeing path, migratetype is racy so that a highorderatomic
> >page could free into non-highorderatomic free list.
> 
> Yes. If page from a pageblock went to a pcplist before that pageblock was
> reserved as highatomic, free_pcppages_bulk() will misplace it.

As well, high-order freeing path has a problem, too.


    CPU 1                               CPU 2
    
                                        __free_pages_ok
                                        /* got highatomic mt */
    unreserve_highatomic_pageblock      mt = get_pfnblock_migratetype
    spin_lock_irqsave(&zone->lock);
    move_freepages_block
    /* change from highatomic to something
    set_pageblock_migratetype(page)
    spin_unlock_irqrestore(&zone->lock)
    
                                        spin_lock(&zone->lock);
                                        /* highatomic mt is stale */
                                        __free_one_page(page, mt);
 
Acutually, I tried to solve this problem with fixing the free path
but it needs to add a branch to verify highorderatomic mt in
both order-0 and high-order page freeing path. On highorder page freeing
path wouldn't be a problem but I don't want to add the branch in pcp
freeing path which is hot.

> 
> >If that page
> >is allocated, VM can change the pageblock from higorderatomic to
> >something.
> 
> More specifically, steal_suitable_fallback(). Yes.

As well, __isolate_free_page, too.

> 
> >In that case, we should adjust nr_reserved_highatomic.
> >Otherwise, VM cannot reserve highorderatomic pageblocks any more
> >although it doesn't reach 1% limit. It means highorder atomic
> >allocation failure would be higher.
> >
> >So, this patch decreases the account as well as migratetype
> >if it was MIGRATE_HIGHATOMIC.
> >
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Hm wouldn't it be simpler just to prevent the pageblock's migratetype to be
> changed if it's highatomic? Possibly also not do move_freepages_block() in

It could be. Actually, I did it with modifying can_steal_fallback which returns
false it found the pageblock is highorderatomic but changed to this way again
because I don't have any justification to prevent changing pageblock.
If you give concrete justification so others isn't against on it, I am happy to
do what you suggested.

> that case. Most accurate would be to put such misplaced page on the proper
> freelist and retry the fallback, but that might be overkill.
> 
> >---
> > mm/page_alloc.c | 44 ++++++++++++++++++++++++++++++++++++++------
> > 1 file changed, 38 insertions(+), 6 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 55ad0229ebf3..e7cbb3cc22fa 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -282,6 +282,9 @@ EXPORT_SYMBOL(nr_node_ids);
> > EXPORT_SYMBOL(nr_online_nodes);
> > #endif
> >
> >+static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
> >+					int migratetype);
> >+
> > int page_group_by_mobility_disabled __read_mostly;
> >
> > #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> >@@ -1935,7 +1938,14 @@ static void change_pageblock_range(struct page *pageblock_page,
> > 	int nr_pageblocks = 1 << (start_order - pageblock_order);
> >
> > 	while (nr_pageblocks--) {
> >-		set_pageblock_migratetype(pageblock_page, migratetype);
> >+		if (get_pageblock_migratetype(pageblock_page) !=
> >+			MIGRATE_HIGHATOMIC)
> >+			set_pageblock_migratetype(pageblock_page,
> >+							migratetype);
> >+		else
> >+			dec_highatomic_pageblock(page_zone(pageblock_page),
> >+							pageblock_page,
> >+							migratetype);
> > 		pageblock_page += pageblock_nr_pages;
> > 	}
> > }
> >@@ -1996,8 +2006,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
> >
> > 	/* Claim the whole block if over half of it is free */
> > 	if (pages >= (1 << (pageblock_order-1)) ||
> >-			page_group_by_mobility_disabled)
> >-		set_pageblock_migratetype(page, start_type);
> >+			page_group_by_mobility_disabled) {
> >+		int mt = get_pageblock_migratetype(page);
> >+
> >+		if (mt != MIGRATE_HIGHATOMIC)
> >+			set_pageblock_migratetype(page, start_type);
> >+		else
> >+			dec_highatomic_pageblock(zone, page, start_type);
> >+	}
> > }
> >
> > /*
> >@@ -2037,6 +2053,17 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
> > 	return -1;
> > }
> >
> >+static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
> >+					int migratetype)
> >+{
> >+	if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> >+		return;
> >+
> >+	zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
> >+					zone->nr_reserved_highatomic);
> >+	set_pageblock_migratetype(page, migratetype);
> >+}
> >+
> > /*
> >  * Reserve a pageblock for exclusive use of high-order atomic allocations if
> >  * there are no empty page blocks that contain a page with a suitable order
> >@@ -2555,9 +2582,14 @@ int __isolate_free_page(struct page *page, unsigned int order)
> > 		struct page *endpage = page + (1 << order) - 1;
> > 		for (; page < endpage; page += pageblock_nr_pages) {
> > 			int mt = get_pageblock_migratetype(page);
> >-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> >-				set_pageblock_migratetype(page,
> >-							  MIGRATE_MOVABLE);
> >+			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
> >+				if (mt != MIGRATE_HIGHATOMIC)
> >+					set_pageblock_migratetype(page,
> >+							MIGRATE_MOVABLE);
> >+				else
> >+					dec_highatomic_pageblock(zone, page,
> >+							MIGRATE_MOVABLE);
> >+			}
> > 		}
> > 	}
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
