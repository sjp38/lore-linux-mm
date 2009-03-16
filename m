Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3BB3F6B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:35:25 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 50E5982D22D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:40:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Jzgy-nVhhoeY for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:40:20 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C75EE82D2A0
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:34:27 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:26:07 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 26/35] Use the per-cpu allocator for orders up to
 PAGE_ALLOC_COSTLY_ORDER
In-Reply-To: <1237196790-7268-27-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161222070.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-27-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> -static void free_hot_cold_page(struct page *page, int cold)
> +static void free_hot_cold_page(struct page *page, int order, int cold)
>  {
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
>  	unsigned long flags;
>  	int clearMlocked = PageMlocked(page);
>
> +	/* SLUB can return lowish-order compound pages that need handling */
> +	if (order > 0 && unlikely(PageCompound(page)))
> +		if (unlikely(destroy_compound_page(page, order)))
> +			return;
> +

Isnt that also true for stacks and generic network objects ==- 8k?

>  again:
>  	cpu  = get_cpu();
> -	if (likely(order == 0)) {
> +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
>  		struct per_cpu_pages *pcp;
> +		int batch;
> +		int delta;
>
>  		pcp = &zone_pcp(zone, cpu)->pcp;
> +		batch = max(1, pcp->batch >> order);
>  		local_irq_save(flags);
>  		if (!pcp->count) {
> -			pcp->count = rmqueue_bulk(zone, 0,
> -					pcp->batch, &pcp->list, migratetype);
> +			delta = rmqueue_bulk(zone, order, batch,
> +					&pcp->list, migratetype);
> +			bulk_add_pcp_page(pcp, order, delta);
>  			if (unlikely(!pcp->count))
>  				goto failed;

The pcp adds a series of order N pages if an order N alloc occurs and the
queue is empty?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
