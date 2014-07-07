Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37E4E6B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:19:58 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so4412656wgg.10
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:19:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id om6si50316240wjc.30.2014.07.07.08.19.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 08:19:54 -0700 (PDT)
Message-ID: <53BABA94.4040107@suse.cz>
Date: Mon, 07 Jul 2014 17:19:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/page_alloc: handle page on pcp correctly if
 it's pageblock is isolated
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
> If pageblock of page on pcp are isolated now, we should free it to isolate
> buddy list to prevent future allocation on it. But current code doesn't
> do this.
>
> Moreover, there is a freepage counting problem on current code. Although
> pageblock of page on pcp are isolated now, it could go normal buddy list,
> because get_onpcp_migratetype() will return non-isolate migratetype.

get_onpcp_migratetype() is only introduced in later patch.

> In this case, we should do either adding freepage count or changing
> migratetype to MIGRATE_ISOLATE, but, current code do neither.

I wouldn't say it "do neither". It already limits the freepage counting 
to !MIGRATE_ISOLATE case (and it's not converted to 
__mod_zone_freepage_state for some reason). So there's accounting 
mismatch in addition to buddy list misplacement.

> This patch fixes these two problems by handling pageblock migratetype
> before calling __free_one_page(). And, if we find the page on isolated
> pageblock, change migratetype to MIGRATE_ISOLATE to prevent future
> allocation of this page and freepage counting problem.

So although this is not an addition of a new pageblock migratetype check 
to the fast path (the check is already there), I would prefer removing 
the check :) With the approach of pcplists draining outlined in my reply 
to 00/10, we would allow a misplacement to happen (and the page 
accounted as freepage) immediately followed by move_frepages_block which 
would place the page onto isolate freelist with the rest. Anything newly 
freed will get isolate_migratetype determined in free_hot_cold_page or 
__free_pages_ok (where it would need moving the migratepage check under 
the disabled irq part) and be placed and buddy-merged properly.

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
