Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 199E46B025B
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 10:17:45 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAC007NBFOZ5GC0@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 14 Sep 2012 23:17:43 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAC00DSRFPH7740@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Sep 2012 23:17:43 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v3 2/5] cma: fix counting of isolated pages
Date: Fri, 14 Sep 2012 14:41:49 +0200
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-3-git-send-email-b.zolnierkie@samsung.com>
 <20120914022620.GG5085@bbox>
In-reply-to: <20120914022620.GG5085@bbox>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201209141441.50263.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Friday 14 September 2012 04:26:20 Minchan Kim wrote:
> On Tue, Sep 04, 2012 at 03:26:22PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > Isolated free pages shouldn't be accounted to NR_FREE_PAGES counter.
> > Fix it by properly decreasing/increasing NR_FREE_PAGES counter in
> > set_migratetype_isolate()/unset_migratetype_isolate() and removing
> > counter adjustment for isolated pages from free_one_page() and
> > split_free_page().
> > 
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Cc: Michal Nazarewicz <mina86@mina86.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  mm/page_alloc.c     |  7 +++++--
> >  mm/page_isolation.c | 13 ++++++++++---
> >  2 files changed, 15 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index e9da55c..3acdf0f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -691,7 +691,8 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
> >  	zone->pages_scanned = 0;
> >  
> >  	__free_one_page(page, zone, order, migratetype);
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> > +	if (migratetype != MIGRATE_ISOLATE)
> 
> We can add unlikely.

Ok.

> > +		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> >  	spin_unlock(&zone->lock);
> >  }
> >  
> > @@ -1414,7 +1415,9 @@ int split_free_page(struct page *page, bool check_wmark)
> >  	list_del(&page->lru);
> >  	zone->free_area[order].nr_free--;
> >  	rmv_page_order(page);
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> > +
> > +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> 
> The get_pageblock_migratetype isn't cheap.
> You can use get_freepage_migratetype.

get_freepage_migratetype() is not yet upstream and I don't want to add
more dependencies to these patches so I'll update this later.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
