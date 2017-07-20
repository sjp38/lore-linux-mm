Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82CA56B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:45:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x43so12374497wrb.9
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:45:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si2004230wra.461.2017.07.20.02.45.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 02:45:28 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: allow isolation for pages not inserted into lru
 lists yet
References: <150039362282.196778.7901790444249317003.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9a95eec1-54c6-0c8d-101b-aa53e6af36e3@suse.cz>
Date: Thu, 20 Jul 2017 11:45:26 +0200
MIME-Version: 1.0
In-Reply-To: <150039362282.196778.7901790444249317003.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Shaohua Li <shli@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org

On 07/18/2017 06:00 PM, Konstantin Khlebnikov wrote:
> Pages are added into lru lists via per-cpu page vectors in order
> to combine these insertions and reduce lru lock contention.
> 
> These pending pages cannot be isolated and moved into another lru.
> This breaks in some cases page activation and makes mlock-munlock
> much more complicated.
> 
> Also this breaks newly added swapless MADV_FREE: if it cannot move
> anon page into file lru then page could never be freed lazily.
> 
> This patch rearranges lru list handling to allow lru isolation for
> such pages. It set PageLRU earlier and initialize page->lru to mark
> pages still pending for lru insert.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

I think it's not so simple and won't work as you expect after this
patch. See below.

> ---
>  include/linux/mm_inline.h |   10 ++++++++--
>  mm/swap.c                 |   26 ++++++++++++++++++++++++--
>  2 files changed, 32 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index e030a68ead7e..6618c588ee40 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -60,8 +60,14 @@ static __always_inline void add_page_to_lru_list_tail(struct page *page,
>  static __always_inline void del_page_from_lru_list(struct page *page,
>  				struct lruvec *lruvec, enum lru_list lru)
>  {
> -	list_del(&page->lru);
> -	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
> +	/*
> +	 * Empty list head means page is not drained to lru list yet.
> +	 */
> +	if (likely(!list_empty(&page->lru))) {
> +		list_del(&page->lru);
> +		update_lru_size(lruvec, lru, page_zonenum(page),
> +				-hpage_nr_pages(page));
> +	}
>  }
>  
>  /**
> diff --git a/mm/swap.c b/mm/swap.c
> index 23fc6e049cda..ba4c98074a09 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -400,13 +400,35 @@ void mark_page_accessed(struct page *page)
>  }
>  EXPORT_SYMBOL(mark_page_accessed);
>  
> +static void __pagevec_lru_add_drain_fn(struct page *page, struct lruvec *lruvec,
> +				       void *arg)
> +{
> +	/* Check for isolated or already added pages */
> +	if (likely(PageLRU(page) && list_empty(&page->lru))) {

I think it's now possible that page ends up on two (or more) cpu's
pagevecs, right. And they can race doing their local drains, and both
pass this check at the same moment. The lru lock should prevent at least
some disaster, but what if the first CPU succeeds, and then the page is
further isolated and e.g. reclaimed. Then the second CPU still assumes
it's PageLRU() etc, but it's not anymore...?

> +		int file = page_is_file_cache(page);
> +		int active = PageActive(page);
> +		enum lru_list lru = page_lru(page);
> +
> +		add_page_to_lru_list(page, lruvec, lru);
> +		update_page_reclaim_stat(lruvec, file, active);
> +		trace_mm_lru_insertion(page, lru);
> +	}
> +}
> +
>  static void __lru_cache_add(struct page *page)
>  {
>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>  
> +	/*
> +	 * Set PageLRU right here and initialize list head to
> +	 * allow page isolation while it on the way to the LRU list.
> +	 */
> +	VM_BUG_ON_PAGE(PageLRU(page), page);
> +	INIT_LIST_HEAD(&page->lru);
>  	get_page(page);

This elevates the page count, I think at least some LRU isolators will
skip the pages anyway because of that.

> +	SetPageLRU(page);
>  	if (!pagevec_add(pvec, page) || PageCompound(page))
> -		__pagevec_lru_add(pvec);
> +		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
>  	put_cpu_var(lru_add_pvec);
>  }
>  
> @@ -611,7 +633,7 @@ void lru_add_drain_cpu(int cpu)
>  	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
>  
>  	if (pagevec_count(pvec))
> -		__pagevec_lru_add(pvec);
> +		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
>  
>  	pvec = &per_cpu(lru_rotate_pvecs, cpu);
>  	if (pagevec_count(pvec)) {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
