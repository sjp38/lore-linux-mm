Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 560804405C6
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 01:23:31 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so12339580pfg.4
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 22:23:31 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id k195si2090459pga.230.2017.02.15.22.23.29
        for <linux-mm@kvack.org>;
        Wed, 15 Feb 2017 22:23:30 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170215092247.15989-1-mgorman@techsingularity.net> <20170215092247.15989-4-mgorman@techsingularity.net>
In-Reply-To: <20170215092247.15989-4-mgorman@techsingularity.net>
Subject: Re: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due to mismatched classzone_idx
Date: Thu, 16 Feb 2017 14:23:08 +0800
Message-ID: <001501d2881d$242aa790$6c7ff6b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Shantanu Goel' <sgoel01@yahoo.com>, 'Chris Mason' <clm@fb.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'LKML' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On February 15, 2017 5:23 PM Mel Gorman wrote: 
>   */
>  static int kswapd(void *p)
>  {
> -	unsigned int alloc_order, reclaim_order, classzone_idx;
> +	unsigned int alloc_order, reclaim_order;
> +	unsigned int classzone_idx = MAX_NR_ZONES - 1;
>  	pg_data_t *pgdat = (pg_data_t*)p;
>  	struct task_struct *tsk = current;
> 
> @@ -3447,20 +3466,23 @@ static int kswapd(void *p)
>  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>  	set_freezable();
> 
> -	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
> -	pgdat->kswapd_classzone_idx = classzone_idx = 0;
> +	pgdat->kswapd_order = 0;
> +	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>  	for ( ; ; ) {
>  		bool ret;
> 
> +		alloc_order = reclaim_order = pgdat->kswapd_order;
> +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
> +
>  kswapd_try_sleep:
>  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
>  					classzone_idx);
> 
>  		/* Read the new order and classzone_idx */
>  		alloc_order = reclaim_order = pgdat->kswapd_order;
> -		classzone_idx = pgdat->kswapd_classzone_idx;
> +		classzone_idx = kswapd_classzone_idx(pgdat, 0);
>  		pgdat->kswapd_order = 0;
> -		pgdat->kswapd_classzone_idx = 0;
> +		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> 
>  		ret = try_to_freeze();
>  		if (kthread_should_stop())
> @@ -3486,9 +3508,6 @@ static int kswapd(void *p)
>  		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
>  		if (reclaim_order < alloc_order)
>  			goto kswapd_try_sleep;

If we fail order-5 request,  can we then give up order-5, and
try order-3 if requested, after napping?

> -
> -		alloc_order = reclaim_order = pgdat->kswapd_order;
> -		classzone_idx = pgdat->kswapd_classzone_idx;
>  	}
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
