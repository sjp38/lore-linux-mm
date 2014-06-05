Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 479FD6B0095
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 20:02:14 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id to1so232834ieb.30
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 17:02:14 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id w8si8556717icw.73.2014.06.04.17.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 17:02:13 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id at1so29536iec.3
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 17:02:13 -0700 (PDT)
Date: Wed, 4 Jun 2014 17:02:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
In-Reply-To: <1401898310-14525-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 4 Jun 2014, Vlastimil Babka wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index ae7db5f..3dce5a7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -640,11 +640,18 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		}
>  
>  		/*
> -		 * Skip if free. page_order cannot be used without zone->lock
> -		 * as nothing prevents parallel allocations or buddy merging.
> +		 * Skip if free. We read page order here without zone lock
> +		 * which is generally unsafe, but the race window is small and
> +		 * the worst thing that can happen is that we skip some
> +		 * potential isolation targets.

Should we only be doing the low_pfn adjustment based on the order for 
MIGRATE_ASYNC?  It seems like sync compaction, including compaction that 
is triggered from the command line, would prefer to scan over the 
following pages.

>  		 */
> -		if (PageBuddy(page))
> +		if (PageBuddy(page)) {
> +			unsigned long freepage_order = page_order_unsafe(page);

I don't assume that we want a smp_wmb() in set_page_order() for this 
little race and to recheck PageBuddy() here after smp_rmb().

I think this is fine for MIGRATE_ASYNC.

> +
> +			if (freepage_order > 0 && freepage_order < MAX_ORDER)
> +				low_pfn += (1UL << freepage_order) - 1;
>  			continue;
> +		}
>  
>  		/*
>  		 * Check may be lockless but that's ok as we recheck later.
> @@ -733,6 +740,13 @@ next_pageblock:
>  		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
>  	}
>  
> +	/*
> +	 * The PageBuddy() check could have potentially brought us outside
> +	 * the range to be scanned.
> +	 */
> +	if (unlikely(low_pfn > end_pfn))
> +		end_pfn = low_pfn;
> +
>  	acct_isolated(zone, locked, cc);
>  
>  	if (locked)
> diff --git a/mm/internal.h b/mm/internal.h
> index 1a8a0d4..6aa1f74 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -164,7 +164,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   * general, page_zone(page)->lock must be held by the caller to prevent the
>   * page from being allocated in parallel and returning garbage as the order.
>   * If a caller does not hold page_zone(page)->lock, it must guarantee that the
> - * page cannot be allocated or merged in parallel.
> + * page cannot be allocated or merged in parallel. Alternatively, it must
> + * handle invalid values gracefully, and use page_order_unsafe() below.
>   */
>  static inline unsigned long page_order(struct page *page)
>  {
> @@ -172,6 +173,23 @@ static inline unsigned long page_order(struct page *page)
>  	return page_private(page);
>  }
>  
> +/*
> + * Like page_order(), but for callers who cannot afford to hold the zone lock,
> + * and handle invalid values gracefully. ACCESS_ONCE is used so that if the
> + * caller assigns the result into a local variable and e.g. tests it for valid
> + * range  before using, the compiler cannot decide to remove the variable and
> + * inline the function multiple times, potentially observing different values
> + * in the tests and the actual use of the result.
> + */
> +static inline unsigned long page_order_unsafe(struct page *page)
> +{
> +	/*
> +	 * PageBuddy() should be checked by the caller to minimize race window,
> +	 * and invalid values must be handled gracefully.
> +	 */
> +	return ACCESS_ONCE(page_private(page));
> +}
> +
>  /* mm/util.c */
>  void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
>  		struct vm_area_struct *prev, struct rb_node *rb_parent);

I don't like this change at all, I don't think we should have header 
functions that imply the context in which the function will be called.  I 
think it would make much more sense to just do 
ACCESS_ONCE(page_order(page)) in the migration scanner with a comment.  
These are __attribute__((pure)) semantics for page_order().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
