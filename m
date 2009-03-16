Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1A9B76B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:09:16 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F0B4A3047B3
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:15:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zdRcWrbo8aDq for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:15:50 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5AEAB3046DB
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:14:18 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:05:53 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 18/35] Do not disable interrupts in free_page_mlock()
In-Reply-To: <1237196790-7268-19-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161203230.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-19-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> @@ -570,6 +570,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	kernel_map_pages(page, 1 << order, 0);
>
>  	local_irq_save(flags);
> +	if (clearMlocked)
> +		free_page_mlock(page);
>  	__count_vm_events(PGFREE, 1 << order);
>  	free_one_page(page_zone(page), page, order,
>  					get_pageblock_migratetype(page));

Add an unlikely(clearMblocked) here?

> @@ -1036,6 +1039,9 @@ static void free_hot_cold_page(struct page *page, int cold)
>  	pcp = &zone_pcp(zone, get_cpu())->pcp;
>  	local_irq_save(flags);
>  	__count_vm_event(PGFREE);
> +	if (clearMlocked)
> +		free_page_mlock(page);
> +
>  	if (cold)
>  		list_add_tail(&page->lru, &pcp->list);
>  	else
>

Same here also make sure tha the __count_vm_events(PGFREE) comes after the
free_pages_mlock() to preserve symmetry with __free_pages_ok() and maybe
allow the compiler to do CSE between two invocations of
__count_vm_events().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
