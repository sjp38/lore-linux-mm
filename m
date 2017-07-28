Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62E796B0517
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:16:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so29744048wrb.13
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:16:25 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 10si12369049wmt.48.2017.07.28.03.16.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 03:16:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 567E0990A4
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 10:16:23 +0000 (UTC)
Date: Fri, 28 Jul 2017 11:16:22 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/6] mm, kswapd: don't reset kswapd_order prematurely
Message-ID: <20170728101622.uoirf7ryvtoddq7b@techsingularity.net>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <20170727160701.9245-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727160701.9245-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 27, 2017 at 06:06:57PM +0200, Vlastimil Babka wrote:
> This patch deals with a corner case found when testing kcompactd with a very
> simple testcase that first fragments memory (by creating a large shmem file and
> then punching hole in every even page) and then uses artificial order-9
> GFP_NOWAIT allocations in a loop. This is freshly after virtme-run boot in KVM
> and no other activity.
> 
> What happens is that kswapd always reclaims too little to get over
> compact_gap() in kswapd_shrink_node(), so it doesn't set sc->order to 0, thus
> "goto kswapd_try_sleep" in kswapd() doesn't happen. In the next iteration of
> kswapd() loop, alloc_order and reclaim_order is read again from
> pgdat->kswapd_order, which the previous iteration has reset to 0 and there was
> no other kswapd wakeup meanwhile (the workload inserts short sleeps between
> allocations). With the working order 0, node appears balanced and
> wakeup_kcompactd() does nothing.
> 

The risk with a change like this is that there is an introduction of
kswapd-stuck-at-100%-cpu reclaiming for high order pages. Consider for
example this part

> -static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
> +/*
> + * Return true if kswapd fully slept because pgdat was balanced and there was
> + * no premature wakeup.
> + */
> +static bool kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
>  				unsigned int classzone_idx)
>  {
>  	long remaining = 0;
>  	DEFINE_WAIT(wait);
> +	bool ret = false;
>  
>  	if (freezing(current) || kthread_should_stop())
> -		return;
> +		return false;
>  
>  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  

...

> @@ -3493,23 +3491,32 @@ static int kswapd(void *p)
>  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>  	set_freezable();
>  
> -	pgdat->kswapd_order = 0;
> +	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
>  	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>  	for ( ; ; ) {
>  		bool ret;
>  
> -		alloc_order = reclaim_order = pgdat->kswapd_order;
> +		alloc_order = reclaim_order = max(alloc_order, pgdat->kswapd_order);
>  		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
>  
>  kswapd_try_sleep:
> -		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> -					classzone_idx);
> -
> -		/* Read the new order and classzone_idx */
> -		alloc_order = reclaim_order = pgdat->kswapd_order;
> -		classzone_idx = kswapd_classzone_idx(pgdat, 0);
> -		pgdat->kswapd_order = 0;
> -		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> +		if (kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
> +							classzone_idx)) {
> +
> +			/* Read the new order and classzone_idx */
> +			alloc_order = reclaim_order = pgdat->kswapd_order;
> +			classzone_idx = kswapd_classzone_idx(pgdat, 0);
> +			pgdat->kswapd_order = 0;
> +			pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> +		} else {
> +			/*
> +			 * We failed to sleep, so continue on the current order
> +			 * and classzone_idx, unless they increased.
> +			 */
> +			alloc_order = max(alloc_order, pgdat->kswapd_order);
> +			reclaim_order = max(reclaim_order, pgdat->kswapd_order) ;
> +			classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
> +		}
>  
>  		ret = try_to_freeze();
>  		if (kthread_should_stop())

kswapd_try_to_sleep returns true only if it fully slept. Now, consider
a case where kswapd is woken for order-9, fails and there are streaming
allocators that are keeping kswapd awake between the low/high watermark.
Even though all subsequent wakeups are for potentially for order-0, the
false branch above keeps kswapd at order-9.

You should be very wary of keeping kswapd awake for high-order allocations
and somehow defer to either kcompactd or push it into direct reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
