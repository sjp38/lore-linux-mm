Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7C35C28003D
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 10:02:20 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gq15so6328482lab.15
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 07:02:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tn9si16833444lbb.72.2014.10.31.07.02.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 07:02:18 -0700 (PDT)
Message-ID: <5453965F.2070800@suse.cz>
Date: Fri, 31 Oct 2014 15:02:07 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3/4] mm/page_alloc: move freepage counting logic to
 __free_one_page()
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com> <1414740330-4086-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414740330-4086-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 10/31/2014 08:25 AM, Joonsoo Kim wrote:
> All the caller of __free_one_page() has similar freepage counting logic,
> so we can move it to __free_one_page(). This reduce line of code and help
> future maintenance. This is also preparation step for "mm/page_alloc:
> restrict max order of merging on isolated pageblock" which fix the
> freepage counting problem on freepage with more than pageblock order.
>
> Changes from v4:
> Only freepage counting logic is moved. Others remains as is.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Looks like most of the cleanup was still possible, especially getting 
rid of the skip_counting labels is nice.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c |   14 +++-----------
>   1 file changed, 3 insertions(+), 11 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6df23fe..2bc7768 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -579,6 +579,8 @@ static inline void __free_one_page(struct page *page,
>   			return;
>
>   	VM_BUG_ON(migratetype == -1);
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>
>   	page_idx = pfn & ((1 << MAX_ORDER) - 1);
>
> @@ -725,14 +727,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			/* must delete as __free_one_page list manipulates */
>   			list_del(&page->lru);
>   			mt = get_freepage_migratetype(page);
> -			if (unlikely(has_isolate_pageblock(zone))) {
> +			if (unlikely(has_isolate_pageblock(zone)))
>   				mt = get_pageblock_migratetype(page);
> -				if (is_migrate_isolate(mt))
> -					goto skip_counting;
> -			}
> -			__mod_zone_freepage_state(zone, 1, mt);
>
> -skip_counting:
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>   			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
>   			trace_mm_page_pcpu_drain(page, 0, mt);
> @@ -755,12 +752,7 @@ static void free_one_page(struct zone *zone,
>   	if (unlikely(has_isolate_pageblock(zone) ||
>   		is_migrate_isolate(migratetype))) {
>   		migratetype = get_pfnblock_migratetype(page, pfn);
> -		if (is_migrate_isolate(migratetype))
> -			goto skip_counting;
>   	}
> -	__mod_zone_freepage_state(zone, 1 << order, migratetype);
> -
> -skip_counting:
>   	__free_one_page(page, pfn, zone, order, migratetype);
>   	spin_unlock(&zone->lock);
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
