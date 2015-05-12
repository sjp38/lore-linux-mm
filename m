Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DE1586B006C
	for <linux-mm@kvack.org>; Tue, 12 May 2015 04:36:43 -0400 (EDT)
Received: by widdi4 with SMTP id di4so141632461wid.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 01:36:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei3si26351326wjd.20.2015.05.12.01.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 May 2015 01:36:42 -0700 (PDT)
Message-ID: <5551BB98.2040703@suse.cz>
Date: Tue, 12 May 2015 10:36:40 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/page_alloc: stop fallback allocation if we already
 get some freepage
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com> <1430119421-13536-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1430119421-13536-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On 04/27/2015 09:23 AM, Joonsoo Kim wrote:
> Sometimes we try to get more freepages from buddy list than how much
> we really need, in order to refill pcp list. This may speed up following
> allocation request, but, there is a possibility to increase fragmentation
> if we steal freepages from other migratetype buddy list excessively. This
> patch changes this behaviour to stop fallback allocation in order to
> reduce fragmentation if we already get some freepages.
>
> CPU: 8
> RAM: 512 MB with zram swap
> WORKLOAD: kernel build with -j12
> OPTION: page owner is enabled to measure fragmentation
> After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'
>
> * Before
> Number of blocks type (movable)
> DMA32: 208.4
>
> Number of mixed blocks (movable)
> DMA32: 139
>
> Mixed blocks means that there is one or more allocated page for
> unmovable/reclaimable allocation in movable pageblock. Results shows that
> more than half of movable pageblock is tainted by other migratetype
> allocation.
>
> * After
> Number of blocks type (movable)
> DMA32: 207
>
> Number of mixed blocks (movable)
> DMA32: 111.2
>
> This result shows that non-mixed block increase by 38% in this case.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I agree that keeping fragmentation low is more important than filling up 
the pcplists. Wouldn't expect such large difference though. Are the 
results stable?

> ---
>   mm/page_alloc.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 044f16c..fbe2211 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1292,7 +1292,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>    * Call me with the zone->lock already held.
>    */
>   static struct page *__rmqueue(struct zone *zone, unsigned int order,
> -						int migratetype)
> +					int migratetype, int index)
>   {
>   	struct page *page;
>   	bool steal_fallback;
> @@ -1301,6 +1301,10 @@ retry:
>   	page = __rmqueue_smallest(zone, order, migratetype);
>
>   	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
> +		/* We already get some freepages so don't do agressive steal */
> +		if (index != 0)
> +			goto out;
> +
>   		if (migratetype == MIGRATE_MOVABLE)
>   			page = __rmqueue_cma_fallback(zone, order);
>
> @@ -1338,7 +1342,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>
>   	spin_lock(&zone->lock);
>   	for (i = 0; i < count; ++i) {
> -		struct page *page = __rmqueue(zone, order, migratetype);
> +		struct page *page = __rmqueue(zone, order, migratetype, i);
>   		if (unlikely(page == NULL))
>   			break;
>
> @@ -1749,7 +1753,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>   			WARN_ON_ONCE(order > 1);
>   		}
>   		spin_lock_irqsave(&zone->lock, flags);
> -		page = __rmqueue(zone, order, migratetype);
> +		page = __rmqueue(zone, order, migratetype, 0);
>   		spin_unlock(&zone->lock);
>   		if (!page)
>   			goto failed;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
