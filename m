Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 872B82806E4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 11:35:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o82so74457661pfj.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:35:25 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0137.outbound.protection.outlook.com. [104.47.2.137])
        by mx.google.com with ESMTPS id u59si9896450plb.848.2017.08.22.08.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 08:35:24 -0700 (PDT)
Subject: Re: [PATCH 2/2][RESEND] mm: make kswapd try harder to keep active
 pages in cache
References: <1503066528-1833-1-git-send-email-jbacik@fb.com>
 <1503066528-1833-2-git-send-email-jbacik@fb.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ac46d1df-7a5c-1a36-cf5e-cede3069f4cd@virtuozzo.com>
Date: Tue, 22 Aug 2017 18:38:01 +0300
MIME-Version: 1.0
In-Reply-To: <1503066528-1833-2-git-send-email-jbacik@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On 08/18/2017 05:28 PM, josef@toxicpanda.com wrote:

> @@ -3552,6 +3672,7 @@ static int kswapd(void *p)
>  	pgdat->kswapd_order = 0;
>  	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>  	for ( ; ; ) {
> +		unsigned long slab_diff, inactive_diff;
>  		bool ret;
>  
>  		alloc_order = reclaim_order = pgdat->kswapd_order;
> @@ -3579,6 +3700,23 @@ static int kswapd(void *p)
>  			continue;
>  
>  		/*
> +		 * We want to know where we're adding pages so we can make
> +		 * smarter decisions about where we're going to put pressure
> +		 * when shrinking.
> +		 */
> +		slab_diff = sum_zone_node_page_state(pgdat->node_id,
> +						     NR_SLAB_RECLAIMABLE);

This should be node_page_state().

sum_zone_node_page_state() counts sum of zone_stat_item counter across node, but
NR_SLAB_RECLAIMABLE is node_stat_item counter. So in fact you'll get NR_ZONE_UNEVICTABLE here,
(since value of NR_ZONE_UNEVICTABLE equals to NR_SLAB_RECLAIMABLE).


> +		inactive_diff = node_page_state(pgdat, NR_INACTIVE_FILE);
> +		if (nr_slab > slab_diff)
> +			slab_diff = 0;
> +		else
> +			slab_diff -= nr_slab;
> +		if (inactive_diff < nr_inactive)
> +			inactive_diff = 0;
> +		else
> +			inactive_diff -= nr_inactive;
> +
> +		/*
>  		 * Reclaim begins at the requested order but if a high-order
>  		 * reclaim fails then kswapd falls back to reclaiming for
>  		 * order-0. If that happens, kswapd will consider sleeping
> @@ -3588,7 +3726,11 @@ static int kswapd(void *p)
>  		 */
>  		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
>  						alloc_order);
> -		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
> +		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx,
> +					      inactive_diff, slab_diff);
> +		nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> +		nr_slab = sum_zone_node_page_state(pgdat->node_id,
> +						   NR_SLAB_RECLAIMABLE);

ditto.

>  		if (reclaim_order < alloc_order)
>  			goto kswapd_try_sleep;
>  	}
> @@ -3840,6 +3982,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>  		.may_swap = 1,
>  		.reclaim_idx = gfp_zone(gfp_mask),
> +		.slab_diff = 1,
> +		.inactive_diff = 1,

The only place where __node_reclaim() may use these fields is in the shrink_node():

		if (nr_inactive > total_high_wmark &&
		    sc->inactive_diff > sc->slab_diff) {

Obviously 1 vs 0 doesn't make any difference here. This makes we wonder, why are these fields initialized to 1?


>  	};
>  
>  	cond_resched();
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
