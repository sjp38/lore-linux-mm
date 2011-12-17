Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7D8276B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 11:08:35 -0500 (EST)
Received: by yhgm50 with SMTP id m50so2085966yhg.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 08:08:34 -0800 (PST)
Date: Sun, 18 Dec 2011 01:08:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111217160822.GA10064@barrios-laptop.redhat.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323877293-15401-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 14, 2011 at 03:41:33PM +0000, Mel Gorman wrote:
> It was observed that scan rates from direct reclaim during tests
> writing to both fast and slow storage were extraordinarily high. The
> problem was that while pages were being marked for immediate reclaim
> when writeback completed, the same pages were being encountered over
> and over again during LRU scanning.
> 
> This patch isolates file-backed pages that are to be reclaimed when
> clean on their own LRU list.

Please include your test result about reducing CPU usage.
It makes this separate LRU list how vaule is.

> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/mmzone.h        |    2 +
>  include/linux/vm_event_item.h |    1 +
>  mm/page_alloc.c               |    5 ++-
>  mm/swap.c                     |   74 ++++++++++++++++++++++++++++++++++++++---
>  mm/vmscan.c                   |   11 ++++++
>  mm/vmstat.c                   |    2 +
>  6 files changed, 89 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ac5b522..80834eb 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -84,6 +84,7 @@ enum zone_stat_item {
>  	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
>  	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
>  	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
> +	NR_IMMEDIATE,		/*  "     "     "   "       "         */
>  	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
>  	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
>  	NR_ANON_PAGES,	/* Mapped anonymous pages */
> @@ -136,6 +137,7 @@ enum lru_list {
>  	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
>  	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
>  	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
> +	LRU_IMMEDIATE,
>  	LRU_UNEVICTABLE,
>  	NR_LRU_LISTS
>  };
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 03b90cdc..9696fda 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -36,6 +36,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
>  		KSWAPD_SKIP_CONGESTION_WAIT,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		PGRESCUED,
>  #ifdef CONFIG_COMPACTION
>  		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
>  		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ecaba97..5cf9077 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2590,7 +2590,7 @@ void show_free_areas(unsigned int filter)
>  
>  	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
>  		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> -		" unevictable:%lu"
> +		" immediate:%lu unevictable:%lu"
>  		" dirty:%lu writeback:%lu unstable:%lu\n"
>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>  		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
> @@ -2600,6 +2600,7 @@ void show_free_areas(unsigned int filter)
>  		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_FILE),
>  		global_page_state(NR_ISOLATED_FILE),
> +		global_page_state(NR_IMMEDIATE),
>  		global_page_state(NR_UNEVICTABLE),
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
> @@ -2627,6 +2628,7 @@ void show_free_areas(unsigned int filter)
>  			" inactive_anon:%lukB"
>  			" active_file:%lukB"
>  			" inactive_file:%lukB"
> +			" immediate:%lukB"
>  			" unevictable:%lukB"
>  			" isolated(anon):%lukB"
>  			" isolated(file):%lukB"
> @@ -2655,6 +2657,7 @@ void show_free_areas(unsigned int filter)
>  			K(zone_page_state(zone, NR_INACTIVE_ANON)),
>  			K(zone_page_state(zone, NR_ACTIVE_FILE)),
>  			K(zone_page_state(zone, NR_INACTIVE_FILE)),
> +			K(zone_page_state(zone, NR_IMMEDIATE)),
>  			K(zone_page_state(zone, NR_UNEVICTABLE)),
>  			K(zone_page_state(zone, NR_ISOLATED_ANON)),
>  			K(zone_page_state(zone, NR_ISOLATED_FILE)),
> diff --git a/mm/swap.c b/mm/swap.c
> index a91caf7..9973975 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,6 +39,7 @@ int page_cluster;
>  
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_putback_immediate_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>  
>  /*
> @@ -255,24 +256,80 @@ static void pagevec_move_tail(struct pagevec *pvec)
>  }
>  
>  /*
> + * Similar pair of functions to pagevec_move_tail except it is called when
> + * moving a page from the LRU_IMMEDIATE to one of the [in]active_[file|anon]
> + * lists
> + */
> +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	if (PageLRU(page)) {
> +		enum lru_list lru = page_lru(page);
> +		list_move(&page->lru, &zone->lru[lru].list);
> +	}
> +}
> +
> +static void pagevec_putback_immediate(struct pagevec *pvec)
> +{
> +	pagevec_lru_move_fn(pvec, pagevec_putback_immediate_fn, NULL);
> +}
> +
> +/*
>   * Writeback is about to end against a page which has been marked for immediate
>   * reclaim.  If it still appears to be reclaimable, move it to the tail of the
>   * inactive list.
>   */
>  void rotate_reclaimable_page(struct page *page)
>  {
> +	struct zone *zone = page_zone(page);
> +	struct list_head *page_list;
> +	struct pagevec *pvec;
> +	unsigned long flags;
> +
> +	page_cache_get(page);
> +	local_irq_save(flags);
> +	__mod_zone_page_state(zone, NR_IMMEDIATE, -1);
> +

I am not sure underflow never happen.
We do SetPageReclaim at several places but dont' increase NR_IMMEDIATE.

>  	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
>  	    !PageUnevictable(page) && PageLRU(page)) {
> -		struct pagevec *pvec;
> -		unsigned long flags;
>  
> -		page_cache_get(page);
> -		local_irq_save(flags);
>  		pvec = &__get_cpu_var(lru_rotate_pvecs);
>  		if (!pagevec_add(pvec, page))
>  			pagevec_move_tail(pvec);
> -		local_irq_restore(flags);
> +	} else {
> +		pvec = &__get_cpu_var(lru_putback_immediate_pvecs);
> +		if (!pagevec_add(pvec, page))
> +			pagevec_putback_immediate(pvec);

Nitpick about naming.
It doesn't say immediate is from or to. So I got confused
which is source. I know comment of function already say it
but good naming can reduce unnecessary comment.
How about pagevec_putback_from_immediate_list?

> +	}
> +
> +	/*
> +	 * There is a potential race that if a page is set PageReclaim
> +	 * and moved to the LRU_IMMEDIATE list after writeback completed,
> +	 * it can be left on the LRU_IMMEDATE list with no way for
> +	 * reclaim to find it.
> +	 *
> +	 * This race should be very rare but count how often it happens.
> +	 * If it is a continual race, then it's very unsatisfactory as there
> +	 * is no guarantee that rotate_reclaimable_page() will be called
> +	 * to rescue these pages but finding them in page reclaim is also
> +	 * problematic due to the problem of deciding when the right time
> +	 * to scan this list is.
> +	 */
> +	page_list = &zone->lru[LRU_IMMEDIATE].list;
> +	if (!zone_page_state(zone, NR_IMMEDIATE) && !list_empty(page_list)) {

How about this

if (zone_page_state(zone, NR_IMMEDIATE)) {
	page_list = &zone->lru[LRU_IMMEDIATE].list;
	if (!list_empty(page_list))
...
...
}

It can reduce a unnecessary reference.

> +		struct page *page;
> +
> +		spin_lock(&zone->lru_lock);
> +		while (!list_empty(page_list)) {
> +			page = list_entry(page_list->prev, struct page, lru);
> +			list_move(&page->lru, &zone->lru[page_lru(page)].list);
> +			__count_vm_event(PGRESCUED);
> +		}
> +		spin_unlock(&zone->lru_lock);
>  	}
> +
> +	local_irq_restore(flags);
>  }
>  
>  static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> @@ -475,6 +532,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
>  		 * is _really_ small and  it's non-critical problem.
>  		 */
>  		SetPageReclaim(page);
> +
> +		/*
> +		 * Move to the LRU_IMMEDIATE list to avoid being scanned
> +		 * by page reclaim uselessly.
> +		 */
> +		list_move_tail(&page->lru, &zone->lru[LRU_IMMEDIATE].list);
> +		__mod_zone_page_state(zone, NR_IMMEDIATE, 1);

It mekes below count of PGDEACTIVATE wrong in lru_deactivate_fn.
Before this patch, all is from active to inacive so it was right.
But with this patch, it can be from acdtive to immediate.

>  	} else {
>  		/*
>  		 * The page's writeback ends up during pagevec
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 298ceb8..cb28a07 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1404,6 +1404,17 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
>  		}
>  		SetPageLRU(page);
>  		lru = page_lru(page);
> +
> +		/*
> +		 * If reclaim has tagged a file page reclaim, move it to
> +		 * a separate LRU lists to avoid it being scanned by other
> +		 * users. It is expected that as writeback completes that
> +		 * they are taken back off and moved to the normal LRU
> +		 */
> +		if (lru == LRU_INACTIVE_FILE &&
> +				PageReclaim(page) && PageWriteback(page))
> +			lru = LRU_IMMEDIATE;
> +
>  		add_page_to_lru_list(zone, page, lru);
>  		if (is_active_lru(lru)) {
>  			int file = is_file_lru(lru);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 8fd603b..dbfec4c 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -688,6 +688,7 @@ const char * const vmstat_text[] = {
>  	"nr_active_anon",
>  	"nr_inactive_file",
>  	"nr_active_file",
> +	"nr_immediate",
>  	"nr_unevictable",
>  	"nr_mlock",
>  	"nr_anon_pages",
> @@ -756,6 +757,7 @@ const char * const vmstat_text[] = {
>  	"allocstall",
>  
>  	"pgrotated",
> +	"pgrescued",
>  
>  #ifdef CONFIG_COMPACTION
>  	"compact_blocks_moved",
> -- 
> 1.7.3.4
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
