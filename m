Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8456B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:02:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id s9so2124988wrc.16
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:02:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13si1018645wrh.413.2017.10.18.02.02.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 02:02:22 -0700 (PDT)
Subject: Re: [PATCH 1/8] mm, page_alloc: Enable/disable IRQs once when freeing
 a list of pages
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bcd95a87-3f63-9f5d-77a0-2b2115f53919@suse.cz>
Date: Wed, 18 Oct 2017 11:02:18 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> Freeing a list of pages current enables/disables IRQs for each page freed.
> This patch splits freeing a list of pages into two operations -- preparing
> the pages for freeing and the actual freeing. This is a tradeoff - we're
> taking two passes of the list to free in exchange for avoiding multiple
> enable/disable of IRQs.

There's also some overhead of storing pfn in page->private, but all that
seems negligible compared to irq disable/enable...

> sparsetruncate (tiny)
>                               4.14.0-rc4             4.14.0-rc4
>                            janbatch-v1r1            oneirq-v1r1
> Min          Time      149.00 (   0.00%)      141.00 (   5.37%)
> 1st-qrtle    Time      150.00 (   0.00%)      142.00 (   5.33%)
> 2nd-qrtle    Time      151.00 (   0.00%)      142.00 (   5.96%)
> 3rd-qrtle    Time      151.00 (   0.00%)      143.00 (   5.30%)
> Max-90%      Time      153.00 (   0.00%)      144.00 (   5.88%)
> Max-95%      Time      155.00 (   0.00%)      147.00 (   5.16%)
> Max-99%      Time      201.00 (   0.00%)      195.00 (   2.99%)
> Max          Time      236.00 (   0.00%)      230.00 (   2.54%)
> Amean        Time      152.65 (   0.00%)      144.37 (   5.43%)
> Stddev       Time        9.78 (   0.00%)       10.44 (  -6.72%)
> Coeff        Time        6.41 (   0.00%)        7.23 ( -12.84%)
> Best99%Amean Time      152.07 (   0.00%)      143.72 (   5.50%)
> Best95%Amean Time      150.75 (   0.00%)      142.37 (   5.56%)
> Best90%Amean Time      150.59 (   0.00%)      142.19 (   5.58%)
> Best75%Amean Time      150.36 (   0.00%)      141.92 (   5.61%)
> Best50%Amean Time      150.04 (   0.00%)      141.69 (   5.56%)
> Best25%Amean Time      149.85 (   0.00%)      141.38 (   5.65%)
> 
> With a tiny number of files, each file truncated has resident page cache
> and it shows that time to truncate is roughtly 5-6% with some minor jitter.
> 
>                                       4.14.0-rc4             4.14.0-rc4
>                                    janbatch-v1r1            oneirq-v1r1
> Hmean     SeqCreate ops         65.27 (   0.00%)       81.86 (  25.43%)
> Hmean     SeqCreate read        39.48 (   0.00%)       47.44 (  20.16%)
> Hmean     SeqCreate del      24963.95 (   0.00%)    26319.99 (   5.43%)
> Hmean     RandCreate ops        65.47 (   0.00%)       82.01 (  25.26%)
> Hmean     RandCreate read       42.04 (   0.00%)       51.75 (  23.09%)
> Hmean     RandCreate del     23377.66 (   0.00%)    23764.79 (   1.66%)
> 
> As expected, there is a small gain for the delete operation.

Looks good.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A nit below.

> @@ -2647,11 +2663,25 @@ void free_hot_cold_page(struct page *page, bool cold)
>  void free_hot_cold_page_list(struct list_head *list, bool cold)
>  {
>  	struct page *page, *next;
> +	unsigned long flags, pfn;
> +
> +	/* Prepare pages for freeing */
> +	list_for_each_entry_safe(page, next, list, lru) {
> +		pfn = page_to_pfn(page);
> +		if (!free_hot_cold_page_prepare(page, pfn))
> +			list_del(&page->lru);
> +		page->private = pfn;

We have (set_)page_private() helpers so better to use them (makes it a
bit easier to check for all places where page->private is used to e.g.
avoid a clash)?

> +	}
>  
> +	local_irq_save(flags);
>  	list_for_each_entry_safe(page, next, list, lru) {
> +		unsigned long pfn = page->private;
> +
> +		page->private = 0;

Same here.

>  		trace_mm_page_free_batched(page, cold);
> -		free_hot_cold_page(page, cold);
> +		free_hot_cold_page_commit(page, pfn, cold);
>  	}
> +	local_irq_restore(flags);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
