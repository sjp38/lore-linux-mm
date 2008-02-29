Date: Fri, 29 Feb 2008 15:40:56 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [patch 03/21] use an array for the LRU pagevecs
Message-ID: <20080229154056.GF28849@shadowen.org>
References: <20080228192908.126720629@redhat.com> <20080228192928.165393706@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080228192928.165393706@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2008 at 02:29:11PM -0500, Rik van Riel wrote:
> Turn the pagevecs into an array just like the LRUs.  This significantly
> cleans up the source code and reduces the size of the kernel by about
> 13kB after all the LRU lists have been created further down in the split
> VM patch series.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
>  include/linux/mmzone.h  |   15 +++++-
>  include/linux/pagevec.h |   13 ++++-
>  include/linux/swap.h    |   18 ++++++-
>  mm/migrate.c            |   11 ----
>  mm/swap.c               |   87 +++++++++++++++-----------------------
>  5 files changed, 76 insertions(+), 68 deletions(-)
> 
> Index: linux-2.6.25-rc2-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/include/linux/mmzone.h	2008-02-26 21:24:23.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/include/linux/mmzone.h	2008-02-27 14:19:08.000000000 -0500
> @@ -105,13 +105,24 @@ enum zone_stat_item {
>  #endif
>  	NR_VM_ZONE_STAT_ITEMS };
>  
> +#define LRU_BASE 0
> +
>  enum lru_list {
> -	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE */
> -	LRU_ACTIVE,	/*  "     "     "   "       "        */
> +	LRU_INACTIVE = LRU_BASE,	/* must match order of NR_[IN]ACTIVE */
> +	LRU_ACTIVE,			/*  "     "     "   "       "        */
>  	NR_LRU_LISTS };

Can this not be:

	enum lru_list {
		LRU_BASE = 0,
		LRU_INACTIVE = LRU_BASE,
		LRU_ACTIVE,
		NR_LRU_LISTS
	};

Also, can we not rely on enum's being based at 0 anyhow?  We assume
often that it will be, as we did here with NR_LRU_LISTS being meaningful
should it be.  Could it not then be:

	enum lru_list {
		LRU_BASE,
		LRU_INACTIVE = LRU_BASE,
		LRU_ACTIVE,
		NR_LRU_LISTS
	};

>  #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
>  
> +static inline int is_active_lru(enum lru_list l)
> +{
> +	if (l == LRU_ACTIVE)
> +		return 1;
> +	return 0;

Can this not be:

	return (l == LRU_ACTIVE);

> +}
> +
> +enum lru_list page_lru(struct page *page);
> +
>  struct per_cpu_pages {
>  	int count;		/* number of pages in the list */
>  	int high;		/* high watermark, emptying needed */
> Index: linux-2.6.25-rc2-mm1/mm/swap.c
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/swap.c	2008-02-26 21:24:23.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/swap.c	2008-02-27 14:31:35.000000000 -0500
> @@ -34,8 +34,7 @@
>  /* How many pages do we try to swap or page in/out together? */
>  int page_cluster;
>  
> -static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
> -static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
> +static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs) = { {0,}, };
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs) = { 0, };
>  
>  /*
> @@ -98,6 +97,19 @@ void put_pages_list(struct list_head *pa
>  EXPORT_SYMBOL(put_pages_list);
>  
>  /*
> + * Returns the LRU list a page should be on.
> + */
> +enum lru_list page_lru(struct page *page)
> +{
> +	enum lru_list lru = LRU_BASE;
> +
> +	if (PageActive(page))
> +		lru += LRU_ACTIVE;

This is introducing an assumption that LRU_BASE and LRU_INACTIVE are
synonymous?  Would it not be better to explicitly use LRU_INACTIVE:

So either:

	if (PageActive(page))
		lru = LRU_ACTIVE;
	else
		lru = LRU_INACTIVE;

Or if (as I assume) this is later going to have other mappings added in
you could do it more like the following.  This should produce identicle
asm, but removes any possiblity of LRU_BASE/INACTIVE slippage breaking
things:

	enum lru_list lru = LRU_INACTIVE;

	if (PageActive(page))
		lru += (LRU_ACTIVE - LRU_INACTIVE);
	
> +
> +	return lru;
> +}
> +
> +/*
>   * pagevec_move_tail() must be called with IRQ disabled.
>   * Otherwise this may cause nasty races.
>   */
> @@ -200,28 +212,24 @@ void mark_page_accessed(struct page *pag
>  
>  EXPORT_SYMBOL(mark_page_accessed);
>  
> -/**
> - * lru_cache_add: add a page to the page lists
> - * @page: the page to add
> - */
> -void lru_cache_add(struct page *page)
> +void __lru_cache_add(struct page *page, enum lru_list lru)
>  {
> -	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
> +	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
>  
>  	page_cache_get(page);
>  	if (!pagevec_add(pvec, page))
> -		__pagevec_lru_add(pvec);
> +		____pagevec_lru_add(pvec, lru);
>  	put_cpu_var(lru_add_pvecs);
>  }
>  
> -void lru_cache_add_active(struct page *page)
> +void lru_cache_add_lru(struct page *page, enum lru_list lru)
>  {
> -	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
> +	if (PageActive(page)) {
> +		ClearPageActive(page);
> +	}

{}'s are not needed here.

>  
> -	page_cache_get(page);
> -	if (!pagevec_add(pvec, page))
> -		__pagevec_lru_add_active(pvec);
> -	put_cpu_var(lru_add_active_pvecs);
> +	VM_BUG_ON(PageLRU(page) || PageActive(page));
> +	__lru_cache_add(page, lru);
>  }
>  
>  /*
> @@ -231,15 +239,15 @@ void lru_cache_add_active(struct page *p
>   */
>  static void drain_cpu_pagevecs(int cpu)
>  {
> +	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
>  	struct pagevec *pvec;
> +	int lru;
>  
> -	pvec = &per_cpu(lru_add_pvecs, cpu);
> -	if (pagevec_count(pvec))
> -		__pagevec_lru_add(pvec);
> -
> -	pvec = &per_cpu(lru_add_active_pvecs, cpu);
> -	if (pagevec_count(pvec))
> -		__pagevec_lru_add_active(pvec);
> +	for_each_lru(lru) {
> +		pvec = &pvecs[lru - LRU_BASE];
> +		if (pagevec_count(pvec))
> +			____pagevec_lru_add(pvec, lru);
> +	}
>  
>  	pvec = &per_cpu(lru_rotate_pvecs, cpu);
>  	if (pagevec_count(pvec)) {
> @@ -393,7 +401,7 @@ void __pagevec_release_nonlru(struct pag
>   * Add the passed pages to the LRU, then drop the caller's refcount
>   * on them.  Reinitialises the caller's pagevec.
>   */
> -void __pagevec_lru_add(struct pagevec *pvec)
> +void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
>  {
>  	int i;
>  	struct zone *zone = NULL;
> @@ -410,7 +418,9 @@ void __pagevec_lru_add(struct pagevec *p
>  		}
>  		VM_BUG_ON(PageLRU(page));
>  		SetPageLRU(page);
> -		add_page_to_inactive_list(zone, page);
> +		if (is_active_lru(lru))
> +			SetPageActive(page);
> +		add_page_to_lru_list(zone, page, lru);
>  	}
>  	if (zone)
>  		spin_unlock_irq(&zone->lru_lock);
> @@ -418,34 +428,7 @@ void __pagevec_lru_add(struct pagevec *p
>  	pagevec_reinit(pvec);
>  }
>  
> -EXPORT_SYMBOL(__pagevec_lru_add);
> -
> -void __pagevec_lru_add_active(struct pagevec *pvec)
> -{
> -	int i;
> -	struct zone *zone = NULL;
> -
> -	for (i = 0; i < pagevec_count(pvec); i++) {
> -		struct page *page = pvec->pages[i];
> -		struct zone *pagezone = page_zone(page);
> -
> -		if (pagezone != zone) {
> -			if (zone)
> -				spin_unlock_irq(&zone->lru_lock);
> -			zone = pagezone;
> -			spin_lock_irq(&zone->lru_lock);
> -		}
> -		VM_BUG_ON(PageLRU(page));
> -		SetPageLRU(page);
> -		VM_BUG_ON(PageActive(page));
> -		SetPageActive(page);
> -		add_page_to_active_list(zone, page);
> -	}
> -	if (zone)
> -		spin_unlock_irq(&zone->lru_lock);
> -	release_pages(pvec->pages, pvec->nr, pvec->cold);
> -	pagevec_reinit(pvec);
> -}
> +EXPORT_SYMBOL(____pagevec_lru_add);
>  
>  /*
>   * Try to drop buffers from the pages in a pagevec
> Index: linux-2.6.25-rc2-mm1/include/linux/pagevec.h
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/include/linux/pagevec.h	2007-07-08 19:32:17.000000000 -0400
> +++ linux-2.6.25-rc2-mm1/include/linux/pagevec.h	2008-02-27 13:41:27.000000000 -0500
> @@ -23,8 +23,7 @@ struct pagevec {
>  void __pagevec_release(struct pagevec *pvec);
>  void __pagevec_release_nonlru(struct pagevec *pvec);
>  void __pagevec_free(struct pagevec *pvec);
> -void __pagevec_lru_add(struct pagevec *pvec);
> -void __pagevec_lru_add_active(struct pagevec *pvec);
> +void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
>  void pagevec_strip(struct pagevec *pvec);
>  unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
>  		pgoff_t start, unsigned nr_pages);
> @@ -81,6 +80,16 @@ static inline void pagevec_free(struct p
>  		__pagevec_free(pvec);
>  }
>  
> +static inline void __pagevec_lru_add(struct pagevec *pvec)
> +{
> +	____pagevec_lru_add(pvec, LRU_INACTIVE);
> +}
> +
> +static inline void __pagevec_lru_add_active(struct pagevec *pvec)
> +{
> +	____pagevec_lru_add(pvec, LRU_ACTIVE);
> +}
> +
>  static inline void pagevec_lru_add(struct pagevec *pvec)
>  {
>  	if (pagevec_count(pvec))
> Index: linux-2.6.25-rc2-mm1/include/linux/swap.h
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/include/linux/swap.h	2008-02-19 16:23:08.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/include/linux/swap.h	2008-02-27 14:31:21.000000000 -0500
> @@ -171,8 +171,8 @@ extern unsigned int nr_free_pagecache_pa
>  
>  
>  /* linux/mm/swap.c */
> -extern void lru_cache_add(struct page *);
> -extern void lru_cache_add_active(struct page *);
> +extern void __lru_cache_add(struct page *, enum lru_list lru);
> +extern void lru_cache_add_lru(struct page *, enum lru_list lru);
>  extern void activate_page(struct page *);
>  extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
> @@ -180,6 +180,20 @@ extern int lru_add_drain_all(void);
>  extern int rotate_reclaimable_page(struct page *page);
>  extern void swap_setup(void);
>  
> +/**
> + * lru_cache_add: add a page to the page lists
> + * @page: the page to add
> + */
> +static inline void lru_cache_add(struct page *page)
> +{
> +	__lru_cache_add(page, LRU_INACTIVE);
> +}
> +
> +static inline void lru_cache_add_active(struct page *page)
> +{
> +	__lru_cache_add(page, LRU_ACTIVE);
> +}
> +
>  /* linux/mm/vmscan.c */
>  extern unsigned long try_to_free_pages(struct zone **zones, int order,
>  					gfp_t gfp_mask);
> Index: linux-2.6.25-rc2-mm1/mm/migrate.c
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/migrate.c	2008-02-25 17:10:54.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/migrate.c	2008-02-27 14:24:23.000000000 -0500
> @@ -54,16 +54,7 @@ int migrate_prep(void)
>  
>  static inline void move_to_lru(struct page *page)
>  {
> -	if (PageActive(page)) {
> -		/*
> -		 * lru_cache_add_active checks that
> -		 * the PG_active bit is off.
> -		 */
> -		ClearPageActive(page);
> -		lru_cache_add_active(page);
> -	} else {
> -		lru_cache_add(page);
> -	}
> +	lru_cache_add_lru(page, page_lru(page));
>  	put_page(page);
>  }

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
