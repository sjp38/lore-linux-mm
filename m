Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7B96B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:36:30 -0500 (EST)
Received: by wmww144 with SMTP id w144so66646232wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:36:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yo9si15018441wjc.233.2015.12.04.07.36.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 07:36:29 -0800 (PST)
Subject: Re: [PATCH v3 3/7] mm/compaction: initialize compact_order_failed to
 MAX_ORDER
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5661B2FC.9060202@suse.cz>
Date: Fri, 4 Dec 2015 16:36:28 +0100
MIME-Version: 1.0
In-Reply-To: <1449126681-19647-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> If compact_order_failed is initialized to 0 and order-9
> compaction is continually failed, defer counter will be updated
> to activate deferring. Although other defer counters will be properly
> updated, compact_order_failed will not be updated because failed order
> cannot be lower than compact_order_failed, 0. In this case,
> low order compaction such as 2, 3 could be deferred due to
> this wrongly initialized compact_order_failed value. This patch
> removes this possibility by initializing it to MAX_ORDER.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Good catch.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d0499ff..7002c66 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5273,6 +5273,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>   		zone_seqlock_init(zone);
>   		zone->zone_pgdat = pgdat;
>   		zone_pcp_init(zone);
> +#ifdef CONFIG_COMPACTION
> +		zone->compact_order_failed = MAX_ORDER;
> +#endif
>
>   		/* For bootup, initialized properly in watermark setup */
>   		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
