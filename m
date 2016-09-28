Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C07E280251
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:25:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so71076792pfj.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:25:46 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q7si6571262pay.70.2016.09.27.22.25.44
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 22:25:45 -0700 (PDT)
Date: Wed, 28 Sep 2016 14:34:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 3/6] mm/cma: populate ZONE_CMA
Message-ID: <20160928053408.GD22706@js1304-P5Q-DELUXE>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1472447255-10584-4-git-send-email-iamjoonsoo.kim@lge.com>
 <d53d9318-1644-4750-6756-ccfb7325cdaa@suse.cz>
 <20160922054546.GC27958@js1304-P5Q-DELUXE>
 <20160922065048.GD27958@js1304-P5Q-DELUXE>
 <24b9e9e5-0580-b19d-9501-44a19555b4b7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24b9e9e5-0580-b19d-9501-44a19555b4b7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 22, 2016 at 05:59:46PM +0200, Vlastimil Babka wrote:
> On 09/22/2016 08:50 AM, Joonsoo Kim wrote:
> >On Thu, Sep 22, 2016 at 02:45:46PM +0900, Joonsoo Kim wrote:
> >>>
> >>> > /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
> >>> > void __init init_cma_reserved_pageblock(struct page *page)
> >>> > {
> >>> > 	unsigned i = pageblock_nr_pages;
> >>> >+	unsigned long pfn = page_to_pfn(page);
> >>> > 	struct page *p = page;
> >>> >+	int nid = page_to_nid(page);
> >>> >+
> >>> >+	/*
> >>> >+	 * ZONE_CMA will steal present pages from other zones by changing
> >>> >+	 * page links so page_zone() is changed. Before that,
> >>> >+	 * we need to adjust previous zone's page count first.
> >>> >+	 */
> >>> >+	adjust_present_page_count(page, -pageblock_nr_pages);
> >>> >
> >>> > 	do {
> >>> > 		__ClearPageReserved(p);
> >>> > 		set_page_count(p, 0);
> >>> >-	} while (++p, --i);
> >>> >+
> >>> >+		/* Steal pages from other zones */
> >>> >+		set_page_links(p, ZONE_CMA, nid, pfn);
> >>> >+	} while (++p, ++pfn, --i);
> >>> >+
> >>> >+	adjust_present_page_count(page, pageblock_nr_pages);
> >>>
> >>> This seems to assign pages to ZONE_CMA on the proper node, which is
> >>> good. But then ZONE_CMA on multiple nodes will have unnecessary
> >>> holes in the spanned pages, as each will contain only a subset.
> >>
> >>True, I will fix it and respin the series.
> >
> >I now realize that it's too late to send full series for next
> >merge window. I will send full series after next merge window is closed.
> 
> I think there might still be rc8 thus another week.

Indeed. I will send full series, soon.

> 
> >Anyway, I'd like to confirm that following incremental patch will solve
> >your concern.
> 
> Yeah that should work, as long as single cma areas don't include multiple nodes?

Single cma areas cannot include multiple nodes at least until now.
There is a check that single cma area is on a single zone.

Thanks.

> 
> >Thanks.
> >
> >
> >------>8--------------
> > mm/cma.c | 25 ++++++++++++++++---------
> > 1 file changed, 16 insertions(+), 9 deletions(-)
> >
> >diff --git a/mm/cma.c b/mm/cma.c
> >index d69bdf7..8375554 100644
> >--- a/mm/cma.c
> >+++ b/mm/cma.c
> >@@ -146,22 +146,29 @@ static int __init cma_init_reserved_areas(void)
> > {
> >        int i;
> >        struct zone *zone;
> >-       unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> >+       pg_data_t *pgdat;
> >
> >        if (!cma_area_count)
> >                return 0;
> >
> >-       for (i = 0; i < cma_area_count; i++) {
> >-               if (start_pfn > cma_areas[i].base_pfn)
> >-                       start_pfn = cma_areas[i].base_pfn;
> >-               if (end_pfn < cma_areas[i].base_pfn + cma_areas[i].count)
> >-                       end_pfn = cma_areas[i].base_pfn + cma_areas[i].count;
> >-       }
> >+       for_each_online_pgdat(pgdat) {
> >+               unsigned long start_pfn = UINT_MAX, end_pfn = 0;
> >
> >-       for_each_zone(zone) {
> >-               if (!is_zone_cma(zone))
> >+               for (i = 0; i < cma_area_count; i++) {
> >+                       if (page_to_nid(pfn_to_page(cma_areas[i].base_pfn)) !=
> 
> We have pfn_to_nid() (although the implementation is just like this).

Will fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
