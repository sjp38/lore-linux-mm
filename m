Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 70A046B0038
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 01:40:12 -0500 (EST)
Received: by pdev10 with SMTP id v10so17390890pde.7
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 22:40:12 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id f10si1682606pas.19.2015.02.12.22.40.10
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 22:40:11 -0800 (PST)
Message-ID: <54DD9C48.90803@lge.com>
Date: Fri, 13 Feb 2015 15:40:08 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC 07/16] mm/page_isolation: watch out zone range overlap
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com> <1423726340-4084-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>


> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index c8778f7..883e78d 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -210,8 +210,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>    * Returns 1 if all pages in the range are isolated.
>    */
>   static int
> -__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
> -				  bool skip_hwpoisoned_pages)
> +__test_page_isolated_in_pageblock(struct zone *zone, unsigned long pfn,
> +			unsigned long end_pfn, bool skip_hwpoisoned_pages)
>   {
>   	struct page *page;
>   
> @@ -221,6 +221,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>   			continue;
>   		}
>   		page = pfn_to_page(pfn);
> +		if (page_zone(page) != zone)
> +			break;
> +
>   		if (PageBuddy(page)) {
>   			/*
>   			 * If race between isolatation and allocation happens,
> @@ -281,7 +284,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>   	/* Check all pages are free or marked as ISOLATED */
>   	zone = page_zone(page);
>   	spin_lock_irqsave(&zone->lock, flags);
> -	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
> +	ret = __test_page_isolated_in_pageblock(zone, start_pfn, end_pfn,
>   						skip_hwpoisoned_pages);
>   	spin_unlock_irqrestore(&zone->lock, flags);
>   	return ret ? 0 : -EBUSY;
> 

What about checking zone at test_pages_isolated?
It might be a little bit early and without locking zone.

@@ -273,8 +273,14 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
         * are not aligned to pageblock_nr_pages.
         * Then we just check migratetype first.
         */
+
+       zone = page_zone(__first_valid_page(start_pfn, pageblock_nr_pages));
+
        for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
                page = __first_valid_page(pfn, pageblock_nr_pages);
+
+               if (page_zone(page) != zone)
+                       break;
                if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
                        break;
        }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
