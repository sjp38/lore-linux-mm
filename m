Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53F296B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 08:31:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so5669250wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:31:41 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id lw10si1200396wjb.196.2016.06.08.05.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 05:31:39 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so2601493wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:31:39 -0700 (PDT)
Date: Wed, 8 Jun 2016 14:31:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/10] mm: remove unnecessary use-once cache bias from
 LRU balancing
Message-ID: <20160608123137.GG22570@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:32, Johannes Weiner wrote:
> When the splitlru patches divided page cache and swap-backed pages
> into separate LRU lists, the pressure balance between the lists was
> biased to account for the fact that streaming IO can cause memory
> pressure with a flood of pages that are used only once. New page cache
> additions would tip the balance toward the file LRU, and repeat access
> would neutralize that bias again. This ensured that page reclaim would
> always go for used-once cache first.
> 
> Since e9868505987a ("mm,vmscan: only evict file pages when we have
> plenty"), page reclaim generally skips over swap-backed memory
> entirely as long as there is used-once cache present, and will apply
> the LRU balancing when only repeatedly accessed cache pages are left -
> at which point the previous use-once bias will have been neutralized.
> 
> This makes the use-once cache balancing bias unnecessary. Remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 576c721f210b..814e3a2e54b4 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -264,7 +264,6 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  			    void *arg)
>  {
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> -		int file = page_is_file_cache(page);
>  		int lru = page_lru_base_type(page);
>  
>  		del_page_from_lru_list(page, lruvec, lru);
> @@ -274,7 +273,6 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  		trace_mm_lru_activate(page);
>  
>  		__count_vm_event(PGACTIVATE);
> -		update_page_reclaim_stat(lruvec, file, 1, hpage_nr_pages(page));
>  	}
>  }
>  
> @@ -797,8 +795,6 @@ EXPORT_SYMBOL(__pagevec_release);
>  void lru_add_page_tail(struct page *page, struct page *page_tail,
>  		       struct lruvec *lruvec, struct list_head *list)
>  {
> -	const int file = 0;
> -
>  	VM_BUG_ON_PAGE(!PageHead(page), page);
>  	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
>  	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
> @@ -833,20 +829,13 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>  				 void *arg)
>  {
> -	int file = page_is_file_cache(page);
> -	int active = PageActive(page);
>  	enum lru_list lru = page_lru(page);
> -	bool new = (bool)arg;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  
>  	SetPageLRU(page);
>  	add_page_to_lru_list(page, lruvec, lru);
>  
> -	if (new)
> -		update_page_reclaim_stat(lruvec, file, active,
> -					 hpage_nr_pages(page));
> -
>  	trace_mm_lru_insertion(page, lru);
>  }
>  
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
