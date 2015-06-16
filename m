Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEFD6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:42:29 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so6379878pdj.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 22:42:29 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ra5si20997197pbb.209.2015.06.15.22.42.27
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 22:42:28 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:44:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/6] mm, compaction: always skip compound pages by order
 in migrate scanner
Message-ID: <20150616054436.GD12641@js1304-P5Q-DELUXE>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433928754-966-5-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:32AM +0200, Vlastimil Babka wrote:
> The compaction migrate scanner tries to skip compound pages by their order, to
> reduce number of iterations for pages it cannot isolate. The check is only done
> if PageLRU() is true, which means it applies to THP pages, but not e.g.
> hugetlbfs pages or any other non-LRU compound pages, which we have to iterate
> by base pages.
> 
> This limitation comes from the assumption that it's only safe to read
> compound_order() when we have the zone's lru_lock and THP cannot be split under
> us. But the only danger (after filtering out order values that are not below
> MAX_ORDER, to prevent overflows) is that we skip too much or too little after
> reading a bogus compound_order() due to a rare race. This is the same reasoning
> as patch 99c0fd5e51c4 ("mm, compaction: skip buddy pages by their order in the
> migrate scanner") introduced for unsafely reading PageBuddy() order.
> 
> After this patch, all pages are tested for PageCompound() and we skip them by
> compound_order().  The test is done after the test for balloon_page_movable()
> as we don't want to assume if balloon pages (or other pages with own isolation
> and migration implementation if a generic API gets implemented) are compound
> or not.
> 
> When tested with stress-highalloc from mmtests on 4GB system with 1GB hugetlbfs
> pages, the vmstat compact_migrate_scanned count decreased by 15%.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 36 +++++++++++++++++-------------------
>  1 file changed, 17 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d334bb3..e37d361 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -680,6 +680,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> +		bool is_lru;
> +
>  		/*
>  		 * Periodically drop the lock (if held) regardless of its
>  		 * contention, to give chance to IRQs. Abort async compaction
> @@ -723,39 +725,35 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		 * It's possible to migrate LRU pages and balloon pages
>  		 * Skip any other type of page
>  		 */
> -		if (!PageLRU(page)) {
> +		is_lru = PageLRU(page);
> +		if (!is_lru) {
>  			if (unlikely(balloon_page_movable(page))) {
>  				if (balloon_page_isolate(page)) {
>  					/* Successfully isolated */
>  					goto isolate_success;
>  				}
>  			}
> -			continue;
>  		}
>  
>  		/*
> -		 * PageLRU is set. lru_lock normally excludes isolation
> -		 * splitting and collapsing (collapsing has already happened
> -		 * if PageLRU is set) but the lock is not necessarily taken
> -		 * here and it is wasteful to take it just to check transhuge.
> -		 * Check PageCompound without lock and skip the whole pageblock
> -		 * if it's a transhuge page, as calling compound_order()
> -		 * without preventing THP from splitting the page underneath us
> -		 * may return surprising results.
> -		 * If we happen to check a THP tail page, compound_order()
> -		 * returns 0. It should be rare enough to not bother with
> -		 * using compound_head() in that case.
> +		 * Regardless of being on LRU, compound pages such as THP and
> +		 * hugetlbfs are not to be compacted. We can potentially save
> +		 * a lot of iterations if we skip them at once. The check is
> +		 * racy, but we can consider only valid values and the only
> +		 * danger is skipping too much.
>  		 */
>  		if (PageCompound(page)) {
> -			int nr;
> -			if (locked)
> -				nr = 1 << compound_order(page);
> -			else
> -				nr = pageblock_nr_pages;
> -			low_pfn += nr - 1;
> +			unsigned int comp_order = compound_order(page);
> +
> +			if (comp_order > 0 && comp_order < MAX_ORDER)
> +				low_pfn += (1UL << comp_order) - 1;
> +
>  			continue;
>  		}

How about moving this PageCompound() check up to the PageLRU check?
Is there any relationship between balloon page and PageCompound()?
It will remove is_lru and code would be more understandable.

Otherwise,

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
