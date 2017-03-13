Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0888D6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:32:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u9so12707153wme.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:32:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s83si9942610wms.147.2017.03.13.01.31.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 01:32:00 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7fe42f09-27cc-db21-58d5-affa4aff2849@suse.cz>
Date: Mon, 13 Mar 2017 09:31:58 +0100
MIME-Version: 1.0
In-Reply-To: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

On 03/13/2017 09:02 AM, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
> the IRQ context. but drain_pages_zone fails to clear away the irq. because
> preempt_disable have take effect. so it safely remove the code.
> 
> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/page_alloc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 05c3956..7b16095 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2294,11 +2294,9 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
>   */
>  static void drain_pages_zone(unsigned int cpu, struct zone *zone)
>  {
> -	unsigned long flags;
>  	struct per_cpu_pageset *pset;
>  	struct per_cpu_pages *pcp;
>  
> -	local_irq_save(flags);
>  	pset = per_cpu_ptr(zone->pageset, cpu);

NAK. we have to make sure that pset corresponds to the cpu we are
running on.

>  
>  	pcp = &pset->pcp;
> @@ -2306,7 +2304,6 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
>  		free_pcppages_bulk(zone, pcp->count, pcp);
>  		pcp->count = 0;
>  	}
> -	local_irq_restore(flags);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
