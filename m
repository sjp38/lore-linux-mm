Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 381418E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:39:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so1045246edb.22
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 04:39:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15-v6si2886483eja.157.2019.01.15.04.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 04:39:30 -0800 (PST)
Subject: Re: [PATCH 09/25] mm, compaction: Use the page allocator bulk-free
 helper for lists of pages
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-10-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a61312d7-8235-fe4d-6411-d3143d965f81@suse.cz>
Date: Tue, 15 Jan 2019 13:39:28 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-10-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> release_pages() is a simpler version of free_unref_page_list() but it
> tracks the highest PFN for caching the restart point of the compaction
> free scanner. This patch optionally tracks the highest PFN in the core
> helper and converts compaction to use it. The performance impact is
> limited but it should reduce lock contention slightly in some cases.
> The main benefit is removing some partially duplicated code.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

...

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2876,18 +2876,26 @@ void free_unref_page(struct page *page)
>  /*
>   * Free a list of 0-order pages
>   */
> -void free_unref_page_list(struct list_head *list)
> +void __free_page_list(struct list_head *list, bool dropref,
> +				unsigned long *highest_pfn)
>  {
>  	struct page *page, *next;
>  	unsigned long flags, pfn;
>  	int batch_count = 0;
>  
> +	if (highest_pfn)
> +		*highest_pfn = 0;
> +
>  	/* Prepare pages for freeing */
>  	list_for_each_entry_safe(page, next, list, lru) {
> +		if (dropref)
> +			WARN_ON_ONCE(!put_page_testzero(page));

I've thought about it again and still think it can cause spurious
warnings. We enter this function with one page pin, which means somebody
else might be doing pfn scanning and get_page_unless_zero() with
success, so there are two pins. Then we do the put_page_testzero() above
and go back to one pin, and warn. You said "this function simply does
not expect it and the callers do not violate the rule", but this is
rather about potential parallel pfn scanning activity and not about this
function's callers. Maybe there really is no parallel pfn scanner that
would try to pin a page with a state the page has when it's processed by
this function, but I wouldn't bet on it (any state checks preceding the
pin might also be racy etc.).

>  		pfn = page_to_pfn(page);
>  		if (!free_unref_page_prepare(page, pfn))
>  			list_del(&page->lru);
>  		set_page_private(page, pfn);
> +		if (highest_pfn && pfn > *highest_pfn)
> +			*highest_pfn = pfn;
>  	}
>  
>  	local_irq_save(flags);
> 
