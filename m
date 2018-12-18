Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50B0C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:55:35 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p15so14687655pfk.7
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:55:35 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l81si13296481pfj.230.2018.12.18.01.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:55:34 -0800 (PST)
Subject: Re: [PATCH 08/14] mm, compaction: Use the page allocator bulk-free
 helper for lists of pages
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-9-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e5a93476-c31d-5c5e-7649-2b23188aaaac@suse.cz>
Date: Tue, 18 Dec 2018 10:55:31 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-9-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:03 AM, Mel Gorman wrote:
> release_pages() is a simpler version of free_unref_page_list() but it
> tracks the highest PFN for caching the restart point of the compaction
> free scanner. This patch optionally tracks the highest PFN in the core
> helper and converts compaction to use it.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nit below:

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2961,18 +2961,26 @@ void free_unref_page(struct page *page)
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

That will warn just once, but then page will remain with elevated count
and free_unref_page_prepare() will warn either immediately or later
depending on DEBUG_VM, for each page.
Also IIRC it's legal for basically anyone to do get_page_unless_zero()
and later put_page(), and this would now cause warning. Maybe just test
for put_page_testzero() result without warning, and continue? Hm but
then we should still do a list_del() and that becomes racy after
dropping our ref...

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
