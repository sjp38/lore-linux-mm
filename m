Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D63CE6B009F
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 19:12:48 -0400 (EDT)
Date: Thu, 23 Apr 2009 16:06:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 19/22] Update NR_FREE_PAGES only as necessary
Message-Id: <20090423160610.a093ddf0.akpm@linux-foundation.org>
In-Reply-To: <1240408407-21848-20-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	<1240408407-21848-20-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 14:53:24 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> When pages are being freed to the buddy allocator, the zone
> NR_FREE_PAGES counter must be updated. In the case of bulk per-cpu page
> freeing, it's updated once per page. This retouches cache lines more
> than necessary. Update the counters one per per-cpu bulk free.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -460,7 +460,6 @@ static inline void __free_one_page(struct page *page,
>  		int migratetype)
>  {
>  	unsigned long page_idx;
> -	int order_size = 1 << order;
>  
>  	if (unlikely(PageCompound(page)))
>  		if (unlikely(destroy_compound_page(page, order)))
> @@ -470,10 +469,9 @@ static inline void __free_one_page(struct page *page,
>  
>  	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
>  
> -	VM_BUG_ON(page_idx & (order_size - 1));
> +	VM_BUG_ON(page_idx & ((1 << order) - 1));
>  	VM_BUG_ON(bad_range(zone, page));
>  

<head spins>

Is this all a slow and obscure way of doing

	VM_BUG_ON(order > MAX_ORDER);

?

If not, what _is_ it asserting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
