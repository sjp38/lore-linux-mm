Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA886B025E
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 09:12:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so3552150wmu.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:12:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26si11859833wra.554.2017.10.19.06.12.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 06:12:35 -0700 (PDT)
Subject: Re: [PATCH 7/8] mm, Remove cold parameter from free_hot_cold_page*
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-8-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9e260f57-b871-81bd-66ee-b08fff949c7c@suse.cz>
Date: Thu, 19 Oct 2017 15:12:33 +0200
MIME-Version: 1.0
In-Reply-To: <20171018075952.10627-8-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On 10/18/2017 09:59 AM, Mel Gorman wrote:
> Most callers users of free_hot_cold_page claim the pages being released are
> cache hot. The exception is the page reclaim paths where it is likely that
> enough pages will be freed in the near future that the per-cpu lists are
> going to be recycled and the cache hotness information is lost.

Maybe it would make sense for reclaim to skip pcplists? (out of scope of
this series, of course).

> As no one
> really cares about the hotness of pages being released to the allocator,
> just ditch the parameter.
> 
> The APIs are renamed to indicate that it's no longer about hot/cold pages. It
> should also be less confusing as there are subtle differences between them.
> __free_pages drops a reference and frees a page when the refcount reaches
> zero. free_hot_cold_page handled pages whose refcount was already zero
> which is non-obvious from the name. free_unref_page should be more obvious.
> 
> No performance impact is expected as the overhead is marginal. The parameter
> is removed simply because it is a bit stupid to have a useless parameter
> copied everywhere.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A comment below, though.

...
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 167e163cf733..13582efc57a0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2590,7 +2590,7 @@ void mark_free_pages(struct zone *zone)
>  }
>  #endif /* CONFIG_PM */
>  
> -static bool free_hot_cold_page_prepare(struct page *page, unsigned long pfn)
> +static bool free_unref_page_prepare(struct page *page, unsigned long pfn)
>  {
>  	int migratetype;
>  
> @@ -2602,8 +2602,7 @@ static bool free_hot_cold_page_prepare(struct page *page, unsigned long pfn)
>  	return true;
>  }
>  
> -static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
> -				bool cold)
> +static void free_unref_page_commit(struct page *page, unsigned long pfn)
>  {
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
> @@ -2628,10 +2627,7 @@ static void free_hot_cold_page_commit(struct page *page, unsigned long pfn,
>  	}
>  
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> -	if (!cold)
> -		list_add(&page->lru, &pcp->lists[migratetype]);
> -	else
> -		list_add_tail(&page->lru, &pcp->lists[migratetype]);
> +	list_add_tail(&page->lru, &pcp->lists[migratetype]);

Did you intentionally use the cold version here? Patch 8/8 uses the hot
version in __rmqueue_pcplist() and that makes more sense to me. It
should be either negligible or better, not worse.

>  	pcp->count++;
>  	if (pcp->count >= pcp->high) {
>  		unsigned long batch = READ_ONCE(pcp->batch);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
