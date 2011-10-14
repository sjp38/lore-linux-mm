Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D536B6B017A
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 19:38:16 -0400 (EDT)
Received: by iagf6 with SMTP id f6so2480982iag.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 16:38:14 -0700 (PDT)
Date: Fri, 14 Oct 2011 16:38:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] mm: MIGRATE_CMA migration type added
Message-Id: <20111014163811.8d410590.akpm@linux-foundation.org>
In-Reply-To: <1317909290-29832-5-git-send-email-m.szyprowski@samsung.com>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<1317909290-29832-5-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>Mel Gorman <mel@csn.ul.ie>

On Thu, 06 Oct 2011 15:54:44 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> From: Michal Nazarewicz <m.nazarewicz@samsung.com>
> 
> The MIGRATE_CMA migration type has two main characteristics:
> (i) only movable pages can be allocated from MIGRATE_CMA
> pageblocks and (ii) page allocator will never change migration
> type of MIGRATE_CMA pageblocks.
> 
> This guarantees that page in a MIGRATE_CMA page block can
> always be migrated somewhere else (unless there's no memory left
> in the system).
> 
> It is designed to be used with Contiguous Memory Allocator
> (CMA) for allocating big chunks (eg. 10MiB) of physically
> contiguous memory.  Once driver requests contiguous memory,
> CMA will migrate pages from MIGRATE_CMA pageblocks.
> 
> To minimise number of migrations, MIGRATE_CMA migration type
> is the last type tried when page allocator falls back to other
> migration types then requested.
> 
>
> ...
>
> +#ifdef CONFIG_CMA_MIGRATE_TYPE
> +#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> +#else
> +#  define is_migrate_cma(migratetype) false
> +#endif

Implement in C, please.

>
> ...
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -115,6 +115,16 @@ static bool suitable_migration_target(struct page *page)
>  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
>  		return false;
>  
> +	/* Keep MIGRATE_CMA alone as well. */
> +	/*
> +	 * XXX Revisit.  We currently cannot let compaction touch CMA
> +	 * pages since compaction insists on changing their migration
> +	 * type to MIGRATE_MOVABLE (see split_free_page() called from
> +	 * isolate_freepages_block() above).
> +	 */

Talk to us about this.

How serious is this shortcoming in practice?  What would a fix look
like?  Is anyone working on an implementation, or planning to do so?


> +	if (is_migrate_cma(migratetype))
> +		return false;
> +
>  	/* If the page is a large free page, then allow migration */
>  	if (PageBuddy(page) && page_order(page) >= pageblock_order)
>  		return true;
>
> ...
>
> +void __init init_cma_reserved_pageblock(struct page *page)
> +{
> +	struct page *p = page;
> +	unsigned i = pageblock_nr_pages;
> +
> +	prefetchw(p);
> +	do {
> +		if (--i)
> +			prefetchw(p + 1);
> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	} while (++p, i);
> +
> +	set_page_refcounted(page);
> +	set_pageblock_migratetype(page, MIGRATE_CMA);
> +	__free_pages(page, pageblock_order);
> +	totalram_pages += pageblock_nr_pages;
> +}

I wonder if the prefetches do any good.  it doesn't seem very important
in an __init function.

> +#endif
>  
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
