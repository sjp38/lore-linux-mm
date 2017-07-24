Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82C356B0292
	for <linux-mm@kvack.org>; Sun, 23 Jul 2017 23:53:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v68so119189372pfi.13
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 20:53:12 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q69si5159000pfd.582.2017.07.23.20.53.10
        for <linux-mm@kvack.org>;
        Sun, 23 Jul 2017 20:53:11 -0700 (PDT)
Date: Mon, 24 Jul 2017 12:53:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC] mm: allow isolation for pages not inserted into lru
 lists yet
Message-ID: <20170724035309.GA24526@bbox>
References: <150039362282.196778.7901790444249317003.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150039362282.196778.7901790444249317003.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Shaohua Li <shli@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org

Hi,

On Tue, Jul 18, 2017 at 07:00:23PM +0300, Konstantin Khlebnikov wrote:
> Pages are added into lru lists via per-cpu page vectors in order
> to combine these insertions and reduce lru lock contention.
> 
> These pending pages cannot be isolated and moved into another lru.
> This breaks in some cases page activation and makes mlock-munlock
> much more complicated.
> 
> Also this breaks newly added swapless MADV_FREE: if it cannot move
> anon page into file lru then page could never be freed lazily.

Yes, it's really unforunate.

> 
> This patch rearranges lru list handling to allow lru isolation for
> such pages. It set PageLRU earlier and initialize page->lru to mark
> pages still pending for lru insert.

At a first glance, it seems to work but it's rather hacky to me.

Could you make mark_page_lazyfree be aware of it?
IOW, mark_page_lazyfree can clear PG_active|referenced|swapbacked under
lru_lock if it was not in the LRU. With it, pagevec handler for LRU
can move pages into proper list when drain happens.

> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
