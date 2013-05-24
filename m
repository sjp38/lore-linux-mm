Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0A6496B0032
	for <linux-mm@kvack.org>; Fri, 24 May 2013 16:23:35 -0400 (EDT)
Message-ID: <519FCC46.2000703@codeaurora.org>
Date: Fri, 24 May 2013 13:23:34 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in __zone_watermark_ok()
References: <518B5556.4010005@samsung.com>
In-Reply-To: <518B5556.4010005@samsung.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: linux-mm@kvack.org, =?UTF-8?B?J+uwleqyveuvvCc=?= <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, minchan@kernel.org, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On 5/9/2013 12:50 AM, Tomasz Stanislawski wrote:
> The watermark check consists of two sub-checks.
> The first one is:
>
> 	if (free_pages <= min + lowmem_reserve)
> 		return false;
>
> The check assures that there is minimal amount of RAM in the zone.  If CMA is
> used then the free_pages is reduced by the number of free pages in CMA prior
> to the over-mentioned check.
>
> 	if (!(alloc_flags & ALLOC_CMA))
> 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>
> This prevents the zone from being drained from pages available for non-movable
> allocations.
>
> The second check prevents the zone from getting too fragmented.
>
> 	for (o = 0; o < order; o++) {
> 		free_pages -= z->free_area[o].nr_free << o;
> 		min >>= 1;
> 		if (free_pages <= min)
> 			return false;
> 	}
>
> The field z->free_area[o].nr_free is equal to the number of free pages
> including free CMA pages.  Therefore the CMA pages are subtracted twice.  This
> may cause a false positive fail of __zone_watermark_ok() if the CMA area gets
> strongly fragmented.  In such a case there are many 0-order free pages located
> in CMA. Those pages are subtracted twice therefore they will quickly drain
> free_pages during the check against fragmentation.  The test fails even though
> there are many free non-cma pages in the zone.
>
> This patch fixes this issue by subtracting CMA pages only for a purpose of
> (free_pages <= min + lowmem_reserve) check.
>
> Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>   mm/page_alloc.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8fcced7..0d4fef2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1626,6 +1626,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>   	long min = mark;
>   	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
>   	int o;
> +	long free_cma = 0;
>
>   	free_pages -= (1 << order) - 1;
>   	if (alloc_flags & ALLOC_HIGH)
> @@ -1635,9 +1636,10 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>   #ifdef CONFIG_CMA
>   	/* If allocation can't use CMA areas don't use free CMA pages */
>   	if (!(alloc_flags & ALLOC_CMA))
> -		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> +		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
>   #endif
> -	if (free_pages <= min + lowmem_reserve)
> +
> +	if (free_pages - free_cma <= min + lowmem_reserve)
>   		return false;
>   	for (o = 0; o < order; o++) {
>   		/* At the next order, this order's pages become unavailable */
>

I haven't seen any response to this patch but it has been of some 
benefit to some of our use cases. You're welcome to add

Tested-by: Laura Abbott <lauraa@codeaurora.org>

if the patch hasn't been  picked up yet.

Thanks,
Laura
-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
