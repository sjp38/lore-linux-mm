Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDE06B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 08:44:19 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b201so9058265wmb.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 05:44:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u187si2904045wmg.138.2016.10.07.05.44.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 05:44:17 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm: prevent double decrease of nr_reserved_highatomic
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-3-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6bcd7066-2748-8a96-4479-f85b18765948@suse.cz>
Date: Fri, 7 Oct 2016 14:44:15 +0200
MIME-Version: 1.0
In-Reply-To: <1475819136-24358-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On 10/07/2016 07:45 AM, Minchan Kim wrote:
> There is race between page freeing and unreserved highatomic.
>
>  CPU 0				    CPU 1
>
>     free_hot_cold_page
>       mt = get_pfnblock_migratetype

so here mt == MIGRATE_HIGHATOMIC?

>       set_pcppage_migratetype(page, mt)
>     				    unreserve_highatomic_pageblock
>     				    spin_lock_irqsave(&zone->lock)
>     				    move_freepages_block
>     				    set_pageblock_migratetype(page)
>     				    spin_unlock_irqrestore(&zone->lock)
>       free_pcppages_bulk
>         __free_one_page(mt) <- mt is stale
>
> By above race, a page on CPU 0 could go non-highorderatomic free list
> since the pageblock's type is changed.
> By that, unreserve logic of
> highorderatomic can decrease reserved count on a same pageblock
> several times and then it will make mismatch between
> nr_reserved_highatomic and the number of reserved pageblock.

Hmm I see.

> So, this patch verifies whether the pageblock is highatomic or not
> and decrease the count only if the pageblock is highatomic.

Yeah I guess that's the easiest solution.

> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e7cbb3cc22fa..d110cd640264 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2133,13 +2133,25 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  				continue;
>
>  			/*
> -			 * It should never happen but changes to locking could
> -			 * inadvertently allow a per-cpu drain to add pages
> -			 * to MIGRATE_HIGHATOMIC while unreserving so be safe
> -			 * and watch for underflows.
> +			 * In page freeing path, migratetype change is racy so
> +			 * we can counter several free pages in a pageblock
> +			 * in this loop althoug we changed the pageblock type
> +			 * from highatomic to ac->migratetype. So we should
> +			 * adjust the count once.
>  			 */
> -			zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
> -				zone->nr_reserved_highatomic);
> +			if (get_pageblock_migratetype(page) ==
> +							MIGRATE_HIGHATOMIC) {
> +				/*
> +				 * It should never happen but changes to
> +				 * locking could inadvertently allow a per-cpu
> +				 * drain to add pages to MIGRATE_HIGHATOMIC
> +				 * while unreserving so be safe and watch for
> +				 * underflows.
> +				 */
> +				zone->nr_reserved_highatomic -= min(
> +						pageblock_nr_pages,
> +						zone->nr_reserved_highatomic);
> +			}
>
>  			/*
>  			 * Convert to ac->migratetype and avoid the normal
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
