Date: Fri, 6 Jun 2008 18:05:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-Id: <20080606180506.081f686a.akpm@linux-foundation.org>
In-Reply-To: <20080606202859.291472052@redhat.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 16:28:51 -0400
Rik van Riel <riel@redhat.com> wrote:

> 
> From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> Infrastructure to manage pages excluded from reclaim--i.e., hidden
> from vmscan.  Based on a patch by Larry Woodman of Red Hat. Reworked
> to maintain "nonreclaimable" pages on a separate per-zone LRU list,
> to "hide" them from vmscan.
> 
> Kosaki Motohiro added the support for the memory controller noreclaim
> lru list.
> 
> Pages on the noreclaim list have both PG_noreclaim and PG_lru set.
> Thus, PG_noreclaim is analogous to and mutually exclusive with
> PG_active--it specifies which LRU list the page is on.  
> 
> The noreclaim infrastructure is enabled by a new mm Kconfig option
> [CONFIG_]NORECLAIM_LRU.

Having a config option for this really sucks, and needs extra-special
justification, rather than none.

Plus..

akpm:/usr/src/25> find . -name '*.[ch]' | xargs grep CONFIG_NORECLAIM_LRU 
./drivers/base/node.c:#ifdef CONFIG_NORECLAIM_LRU
./drivers/base/node.c:#ifdef CONFIG_NORECLAIM_LRU
./fs/proc/proc_misc.c:#ifdef CONFIG_NORECLAIM_LRU
./fs/proc/proc_misc.c:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/mmzone.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/mmzone.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/mmzone.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/page-flags.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/page-flags.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/pagemap.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/swap.h:#ifdef CONFIG_NORECLAIM_LRU
./include/linux/vmstat.h:#ifdef CONFIG_NORECLAIM_LRU
./kernel/sysctl.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/internal.h:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/page_alloc.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/vmscan.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/vmscan.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/vmscan.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/vmstat.c:#ifdef CONFIG_NORECLAIM_LRU
./mm/vmstat.c:#ifdef CONFIG_NORECLAIM_LRU


> A new function 'page_reclaimable(page, vma)' in vmscan.c tests whether
> or not a page is reclaimable.  Subsequent patches will add the various
> !reclaimable tests.  We'll want to keep these tests light-weight for
> use in shrink_active_list() and, possibly, the fault path.
> 
> To avoid races between tasks putting pages [back] onto an LRU list and
> tasks that might be moving the page from nonreclaimable to reclaimable
> state, one should test reclaimability under page lock and place
> nonreclaimable pages directly on the noreclaim list before dropping the
> lock.  Otherwise, we risk "stranding" reclaimable pages on the noreclaim
> list.  It's OK to use the pagevec caches for reclaimable pages.  The new
> function 'putback_lru_page()'--inverse to 'isolate_lru_page()'--handles
> this transition, including potential page truncation while the page is
> unlocked.
> 

The changelog doesn't even mention, let alone explain and justify the
fact that this feature is not available on 32-bit systems.  This is a
large drawback - it means that a (hopefully useful) feature is
unavailable to the large majority of Linux systems and that it reduces
the testing coverage and that it adversely impacts MM maintainability.

> Index: linux-2.6.26-rc2-mm1/mm/Kconfig
> ===================================================================
> --- linux-2.6.26-rc2-mm1.orig/mm/Kconfig	2008-05-29 16:21:04.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/mm/Kconfig	2008-06-06 16:05:15.000000000 -0400
> @@ -205,3 +205,13 @@ config NR_QUICK
>  config VIRT_TO_BUS
>  	def_bool y
>  	depends on !ARCH_NO_VIRT_TO_BUS
> +
> +config NORECLAIM_LRU
> +	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL, 64BIT only)"
> +	depends on EXPERIMENTAL && 64BIT
> +	help
> +	  Supports tracking of non-reclaimable pages off the [in]active lists
> +	  to avoid excessive reclaim overhead on large memory systems.  Pages
> +	  may be non-reclaimable because:  they are locked into memory, they
> +	  are anonymous pages for which no swap space exists, or they are anon
> +	  pages that are expensive to unmap [long anon_vma "related vma" list.]

Aunt Tillie might be struggling with some of that.

> Index: linux-2.6.26-rc2-mm1/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.26-rc2-mm1.orig/include/linux/page-flags.h	2008-05-29 16:21:04.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/include/linux/page-flags.h	2008-06-06 16:05:15.000000000 -0400
> @@ -94,6 +94,9 @@ enum pageflags {
>  	PG_reclaim,		/* To be reclaimed asap */
>  	PG_buddy,		/* Page is free, on buddy lists */
>  	PG_swapbacked,		/* Page is backed by RAM/swap */
> +#ifdef CONFIG_NORECLAIM_LRU
> +	PG_noreclaim,		/* Page is "non-reclaimable"  */
> +#endif

I fear that we're messing up the terminology here.

Go into your 2.6.25 tree and do `grep -i reclaimable */*.c'.  The term
already means a few different things, but in the vmscan context,
"reclaimable" means that the page is unreferenced, clean and can be
stolen.  "reclaimable" also means a lot of other things, and we just
made that worse.

Can we think of a new term which uniquely describes this new concept
and use that, rather than flogging the old horse?

>
> ...
>
> +/**
> + * add_page_to_noreclaim_list
> + * @page:  the page to be added to the noreclaim list
> + *
> + * Add page directly to its zone's noreclaim list.  To avoid races with
> + * tasks that might be making the page reclaimble while it's not on the
> + * lru, we want to add the page while it's locked or otherwise "invisible"
> + * to other tasks.  This is difficult to do when using the pagevec cache,
> + * so bypass that.
> + */

How does a task "make a page reclaimable"?  munlock()?  fsync()? 
exit()?

Choice of terminology matters...

> +void add_page_to_noreclaim_list(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	spin_lock_irq(&zone->lru_lock);
> +	SetPageNoreclaim(page);
> +	SetPageLRU(page);
> +	add_page_to_lru_list(zone, page, LRU_NORECLAIM);
> +	spin_unlock_irq(&zone->lru_lock);
> +}
> +
>  /*
>   * Drain pages out of the cpu's pagevecs.
>   * Either "cpu" is the current CPU, and preemption has already been
> @@ -339,6 +370,7 @@ void release_pages(struct page **pages, 
>  
>  		if (PageLRU(page)) {
>  			struct zone *pagezone = page_zone(page);
> +
>  			if (pagezone != zone) {
>  				if (zone)
>  					spin_unlock_irqrestore(&zone->lru_lock,
> @@ -415,6 +447,7 @@ void ____pagevec_lru_add(struct pagevec 
>  {
>  	int i;
>  	struct zone *zone = NULL;
> +	VM_BUG_ON(is_noreclaim_lru(lru));
>  
>  	for (i = 0; i < pagevec_count(pvec); i++) {
>  		struct page *page = pvec->pages[i];
> @@ -426,6 +459,7 @@ void ____pagevec_lru_add(struct pagevec 
>  			zone = pagezone;
>  			spin_lock_irq(&zone->lru_lock);
>  		}
> +		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));

If this ever triggers, you'll wish that it had been coded with two
separate assertions.

>  		VM_BUG_ON(PageLRU(page));
>  		SetPageLRU(page);
>  		if (is_active_lru(lru))
>
> ...
>
> +/**
> + * putback_lru_page
> + * @page to be put back to appropriate lru list
> + *
> + * Add previously isolated @page to appropriate LRU list.
> + * Page may still be non-reclaimable for other reasons.
> + *
> + * lru_lock must not be held, interrupts must be enabled.
> + * Must be called with page locked.
> + *
> + * return 1 if page still locked [not truncated], else 0
> + */

The kerneldoc function description is missing.

> +int putback_lru_page(struct page *page)
> +{
> +	int lru;
> +	int ret = 1;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(PageLRU(page));
> +
> +	lru = !!TestClearPageActive(page);
> +	ClearPageNoreclaim(page);	/* for page_reclaimable() */
> +
> +	if (unlikely(!page->mapping)) {
> +		/*
> +		 * page truncated.  drop lock as put_page() will
> +		 * free the page.
> +		 */
> +		VM_BUG_ON(page_count(page) != 1);
> +		unlock_page(page);
> +		ret = 0;
> +	} else if (page_reclaimable(page, NULL)) {
> +		/*
> +		 * For reclaimable pages, we can use the cache.
> +		 * In event of a race, worst case is we end up with a
> +		 * non-reclaimable page on [in]active list.
> +		 * We know how to handle that.
> +		 */
> +		lru += page_file_cache(page);
> +		lru_cache_add_lru(page, lru);
> +		mem_cgroup_move_lists(page, lru);
> +	} else {
> +		/*
> +		 * Put non-reclaimable pages directly on zone's noreclaim
> +		 * list.
> +		 */
> +		add_page_to_noreclaim_list(page);
> +		mem_cgroup_move_lists(page, LRU_NORECLAIM);
> +	}
> +
> +	put_page(page);		/* drop ref from isolate */
> +	return ret;		/* ret => "page still locked" */
> +}

<stares for a while>

<penny drops>

So THAT'S what the magical "return 2" is doing in page_file_cache()!

<looks>

OK, after all the patches are applied, the "2" becomes LRU_FILE and the
enumeration of `enum lru_list' reflects that.

> +/*
> + * Cull page that shrink_*_list() has detected to be non-reclaimable
> + * under page lock to close races with other tasks that might be making
> + * the page reclaimable.  Avoid stranding a reclaimable page on the
> + * noreclaim list.
> + */
> +static inline void cull_nonreclaimable_page(struct page *page)
> +{
> +	lock_page(page);
> +	if (putback_lru_page(page))
> +		unlock_page(page);
> +}

Again, the terminology is quite overloaded and confusing.  What does
"non-reclaimable" mean in this context?  _Any_ page which was dirty or
which had an elevated refcount?  Surely not referenced pages, which the
scanner also can treat as non-reclaimable.

Did you check whether all these inlined functions really should have
been inlined?  Even ones like this are probably too large.

>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>
> ...
>
> @@ -647,6 +721,14 @@ int __isolate_lru_page(struct page *page
>  	if (mode != ISOLATE_BOTH && (!page_file_cache(page) != !file))
>  		return ret;
>  
> +	/*
> +	 * Non-reclaimable pages shouldn't make it onto either the active
> +	 * nor the inactive list. However, when doing lumpy reclaim of
> +	 * higher order pages we can still run into them.

I guess that something along the lines of "when this function is being
called for lumpy reclaim we can still .." would be clearer.

> +	 */
> +	if (PageNoreclaim(page))
> +		return ret;
> +
>  	ret = -EBUSY;
>  	if (likely(get_page_unless_zero(page))) {
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
