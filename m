Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 585B86B0037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 04:25:38 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so5038122pab.20
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 01:25:38 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xf8si10984645pac.26.2014.07.07.01.25.35
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 01:25:36 -0700 (PDT)
Message-ID: <53BA597E.4000203@lge.com>
Date: Mon, 07 Jul 2014 17:25:34 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/page_alloc: handle page on pcp correctly if
 it's pageblock is isolated
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



2014-07-04 ?AEA 4:57, Joonsoo Kim  3/4 ' +-U:
> If pageblock of page on pcp are isolated now, we should free it to isolate
> buddy list to prevent future allocation on it. But current code doesn't
> do this.

I think it is strage that pcp can have isolated page.
I remember that The purpose of pcp is having frequently used pages (hot for cache),
but isolated page is not for frequently allocated and freed.

(Above is my guess. It can be wrong. I know CMA and hot-plug features are using isolated pages
so that I guess isolated pages are not for frequently allocated and freed memory.)

Anyway if isolated page is not good for pcp, what about preventing isolated page from inserting pcp?
I think fix of free_hot_cold_page() can be one of the preventing ways.
The free_hot_cold_page() checks migratetype and inserts CMA page into pcp.
Am I correct?

If I am correct I think inserting CMA page into pcp is harmful for both of CMA and pcp.
If CMA page is on pcp it will be used frequently and prevent making contiguous memory.
What about avoiding CMA page for pcp like following?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8c9eeec..1cbb816 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1413,13 +1413,8 @@ void free_hot_cold_page(struct page *page, bool cold)
         * areas back if necessary. Otherwise, we may have to free
         * excessively into the page allocator
         */
-       if (migratetype >= MIGRATE_PCPTYPES) {
-               if (unlikely(is_migrate_isolate(migratetype))) {
-                       free_one_page(zone, page, pfn, 0, migratetype);
-                       goto out;
-               }
-               migratetype = MIGRATE_MOVABLE;
-       }
+       if (migratetype > MIGRATE_PCPTYPES)
+               goto out;

        pcp = &this_cpu_ptr(zone->pageset)->pcp;
        if (!cold)


> 
> Moreover, there is a freepage counting problem on current code. Although
> pageblock of page on pcp are isolated now, it could go normal buddy list,
> because get_onpcp_migratetype() will return non-isolate migratetype.

I cannot find get_onpcp_migratetype() in v3.16.0-rc3 and also cannot google it.
Is it typo?

> In this case, we should do either adding freepage count or changing
> migratetype to MIGRATE_ISOLATE, but, current code do neither.
> 
> This patch fixes these two problems by handling pageblock migratetype
> before calling __free_one_page(). And, if we find the page on isolated
> pageblock, change migratetype to MIGRATE_ISOLATE to prevent future
> allocation of this page and freepage counting problem.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_alloc.c |   14 ++++++++------
>   1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index aeb51d1..99c05f7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -719,15 +719,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			page = list_entry(list->prev, struct page, lru);
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
> -			mt = get_freepage_migratetype(page);
> +
> +			if (unlikely(is_migrate_isolate_page(page))) {
> +				mt = MIGRATE_ISOLATE;
> +			} else {
> +				mt = get_freepage_migratetype(page);
> +				__mod_zone_freepage_state(zone, 1, mt);
> +			}
> +
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>   			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
>   			trace_mm_page_pcpu_drain(page, 0, mt);
> -			if (likely(!is_migrate_isolate_page(page))) {
> -				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
> -				if (is_migrate_cma(mt))
> -					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
> -			}
>   		} while (--to_free && --batch_free && !list_empty(list));
>   	}
>   	spin_unlock(&zone->lock);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
