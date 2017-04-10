Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBF8A6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 16:53:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g57so48466482qta.5
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:53:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 21si13835971qkj.172.2017.04.10.13.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 13:53:14 -0700 (PDT)
Date: Mon, 10 Apr 2017 22:53:02 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Message-ID: <20170410225302.2ec8cf56@redhat.com>
In-Reply-To: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, willy@infradead.org, peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com


I will appreciate review of this patch. My micro-benchmarking show we
basically return to same page alloc+free cost as before 374ad05ab64d
("mm, page_alloc: only use per-cpu allocator for irq-safe requests").
Which sort of invalidates this attempt of optimizing the page allocator.
But Mel's micro-benchmarks still show an improvement.

Notice the slowdown comes from me checking irqs_disabled() ... if
someone can spot a way to get rid of that this, then this patch will be
a win.

I'm traveling out of Montreal today, and will rerun my benchmarks when
I get home.  Tariq will also do some more testing with 100G NIC (he
also participated in the Montreal conf, so he is likely in transit too).


On Mon, 10 Apr 2017 16:08:21 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists caching
> of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only use per-cpu
> allocator for irq-safe requests").
> 
> This unfortunately also included excluded SoftIRQ.  This hurt the performance
> for the use-case of refilling DMA RX rings in softirq context.
> 
> This patch re-allow softirq context, which should be safe by disabling
> BH/softirq, while accessing the list.  PCP-lists access from both hard-IRQ
> and NMI context must not be allowed.  Peter Zijlstra says in_nmi() code
> never access the page allocator, thus it should be sufficient to only test
> for !in_irq().
> 
> One concern with this change is adding a BH (enable) scheduling point at
> both PCP alloc and free. If further concerns are highlighted by this patch,
> the result wiill be to revert 374ad05ab64d and try again at a later date
> to offset the irq enable/disable overhead.
> 
> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Missing:

Reported-by: Tariq [...]

> ---
>  mm/page_alloc.c | 26 +++++++++++++++++---------
>  1 file changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6cbde310abed..d7e986967910 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2351,9 +2351,9 @@ static void drain_local_pages_wq(struct work_struct *work)
>  	 * cpu which is allright but we also have to make sure to not move to
>  	 * a different one.
>  	 */
> -	preempt_disable();
> +	local_bh_disable();
>  	drain_local_pages(NULL);
> -	preempt_enable();
> +	local_bh_enable();
>  }
>  
>  /*
> @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> -	if (in_interrupt()) {
> +	/*
> +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> +	 * But allow softirq context, via disabling BH.
> +	 */
> +	if (in_irq() || irqs_disabled()) {
>  		__free_pages_ok(page, 0);
>  		return;
>  	}
> @@ -2491,7 +2495,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  
>  	migratetype = get_pfnblock_migratetype(page, pfn);
>  	set_pcppage_migratetype(page, migratetype);
> -	preempt_disable();
> +	local_bh_disable();
>  
>  	/*
>  	 * We only track unmovable, reclaimable and movable on pcp lists.
> @@ -2522,7 +2526,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	}
>  
>  out:
> -	preempt_enable();
> +	local_bh_enable();
>  }
>  
>  /*
> @@ -2647,7 +2651,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  {
>  	struct page *page;
>  
> -	VM_BUG_ON(in_interrupt());
> +	VM_BUG_ON(in_irq() || irqs_disabled());
>  
>  	do {
>  		if (list_empty(list)) {
> @@ -2680,7 +2684,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  	struct page *page;
>  
> -	preempt_disable();
> +	local_bh_disable();
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
> @@ -2688,7 +2692,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  		zone_statistics(preferred_zone, zone);
>  	}
> -	preempt_enable();
> +	local_bh_enable();
>  	return page;
>  }
>  
> @@ -2704,7 +2708,11 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	unsigned long flags;
>  	struct page *page;
>  
> -	if (likely(order == 0) && !in_interrupt()) {
> +	/*
> +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> +	 * But allow softirq context, via disabling BH.
> +	 */
> +	if (likely(order == 0) && !(in_irq() || irqs_disabled()) ) {
>  		page = rmqueue_pcplist(preferred_zone, zone, order,
>  				gfp_flags, migratetype);
>  		goto out;



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
