Subject: Re: [Experimental][PATCH] putback_lru_page rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 18 Jun 2008 14:21:06 -0400
Message-Id: <1213813266.6497.14.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-18 at 18:40 +0900, KAMEZAWA Hiroyuki wrote:
> Lee-san, how about this ?
> Tested on x86-64 and tried Nisimura-san's test at el. works good now.

I have been testing with my work load on both ia64 and x86_64 and it
seems to be working well.  I'll let them run for a day or so.

> -Kame
> ==
> putback_lru_page()/unevictable page handling rework.
> 
> Now, putback_lru_page() requires that the page is locked.
> And in some special case, implicitly unlock it.
> 
> This patch tries to make putback_lru_pages() to be lock_page() free.
> (Of course, some callers must take the lock.)
> 
> The main reason that putback_lru_page() assumes that page is locked
> is to avoid the change in page's status among Mlocked/Not-Mlocked.
> 
> Once it is added to unevictable list, the page is removed from
> unevictable list only when page is munlocked. (there are other special
> case. but we ignore the special case.)
> So, status change during putback_lru_page() is fatal and page should 
> be locked.
> 
> putback_lru_page() in this patch has a new concepts.
> When it adds page to unevictable list, it checks the status is 
> changed or not again. if changed, retry to putback.

Given that the race that would activate this retry is likely quite rare,
this approach makes sense.  

> 
> This patche changes also caller side and cleaning up lock/unlock_page().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>

A couple of minor comments below, but:

Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

> 
> ---
>  mm/internal.h |    2 -
>  mm/migrate.c  |   23 +++----------
>  mm/mlock.c    |   24 +++++++-------
>  mm/vmscan.c   |   96 +++++++++++++++++++++++++---------------------------------
>  4 files changed, 61 insertions(+), 84 deletions(-)
> 
> Index: test-2.6.26-rc5-mm3/mm/vmscan.c
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/vmscan.c
> +++ test-2.6.26-rc5-mm3/mm/vmscan.c
> @@ -486,73 +486,63 @@ int remove_mapping(struct address_space 
>   * Page may still be unevictable for other reasons.
>   *
>   * lru_lock must not be held, interrupts must be enabled.
> - * Must be called with page locked.
> - *
> - * return 1 if page still locked [not truncated], else 0
>   */
> -int putback_lru_page(struct page *page)
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +void putback_lru_page(struct page *page)
>  {
>  	int lru;
> -	int ret = 1;
>  	int was_unevictable;
>  
> -	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(PageLRU(page));
>  
> -	lru = !!TestClearPageActive(page);
>  	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */
>  
> -	if (unlikely(!page->mapping)) {
> -		/*
> -		 * page truncated.  drop lock as put_page() will
> -		 * free the page.
> -		 */
> -		VM_BUG_ON(page_count(page) != 1);
> -		unlock_page(page);
> -		ret = 0;
> -	} else if (page_evictable(page, NULL)) {
> -		/*
> -		 * For evictable pages, we can use the cache.
> -		 * In event of a race, worst case is we end up with an
> -		 * unevictable page on [in]active list.
> -		 * We know how to handle that.
> -		 */
> +redo:
> +	lru = !!TestClearPageActive(page);
> +	if (page_evictable(page, NULL)) {
>  		lru += page_is_file_cache(page);
>  		lru_cache_add_lru(page, lru);
> -		mem_cgroup_move_lists(page, lru);
> -#ifdef CONFIG_UNEVICTABLE_LRU
> -		if (was_unevictable)
> -			count_vm_event(NORECL_PGRESCUED);
> -#endif
>  	} else {
> -		/*
> -		 * Put unevictable pages directly on zone's unevictable
> -		 * list.
> -		 */
> +		lru = LRU_UNEVICTABLE;
>  		add_page_to_unevictable_list(page);
> -		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
> -#ifdef CONFIG_UNEVICTABLE_LRU
> -		if (!was_unevictable)
> -			count_vm_event(NORECL_PGCULLED);
> -#endif
>  	}
> +	mem_cgroup_move_lists(page, lru);
> +
> +	/*
> +	 * page's status can change while we move it among lru. If an evictable
> +	 * page is on unevictable list, it never be freed. To avoid that,
> +	 * check after we added it to the list, again.
> +	 */
> +	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
> +		if (!isolate_lru_page(page)) {
> +			put_page(page);
> +			goto redo;
> +		}
> +		/* This means someone else dropped this page from LRU
> +		 * So, it will be freed or putback to LRU again. There is
> +		 * nothing to do here.
> +		 */
> +	}
> +
> +	if (was_unevictable && lru != LRU_UNEVICTABLE)
> +		count_vm_event(NORECL_PGRESCUED);
> +	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
> +		count_vm_event(NORECL_PGCULLED);
>  
>  	put_page(page);		/* drop ref from isolate */
> -	return ret;		/* ret => "page still locked" */
>  }
> -
> -/*
> - * Cull page that shrink_*_list() has detected to be unevictable
> - * under page lock to close races with other tasks that might be making
> - * the page evictable.  Avoid stranding an evictable page on the
> - * unevictable list.
> - */
> -static void cull_unevictable_page(struct page *page)
> +#else
> +void putback_lru_page(struct page *page)
>  {
> -	lock_page(page);
> -	if (putback_lru_page(page))
> -		unlock_page(page);
> +	int lru;
> +	VM_BUG_ON(PageLRU(page));
> +
> +	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
> +	lru_cache_add_lru(page, lru);
> +	mem_cgroup_move_lists(page, lru);
> +	put_page(page);
>  }
> +#endif
>  
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
> @@ -746,8 +736,8 @@ free_it:
>  		continue;
>  
>  cull_mlocked:
> -		if (putback_lru_page(page))
> -			unlock_page(page);
> +		unlock_page(page);
> +		putback_lru_page(page);
>  		continue;
>  
>  activate_locked:
> @@ -1127,7 +1117,7 @@ static unsigned long shrink_inactive_lis
>  			list_del(&page->lru);
>  			if (unlikely(!page_evictable(page, NULL))) {
>  				spin_unlock_irq(&zone->lru_lock);
> -				cull_unevictable_page(page);
> +				putback_lru_page(page);
>  				spin_lock_irq(&zone->lru_lock);
>  				continue;
>  			}
> @@ -1231,7 +1221,7 @@ static void shrink_active_list(unsigned 
>  		list_del(&page->lru);
>  
>  		if (unlikely(!page_evictable(page, NULL))) {
> -			cull_unevictable_page(page);
> +			putback_lru_page(page);
>  			continue;
>  		}
>  
> @@ -2393,8 +2383,6 @@ int zone_reclaim(struct zone *zone, gfp_
>  int page_evictable(struct page *page, struct vm_area_struct *vma)
>  {
>  
> -	VM_BUG_ON(PageUnevictable(page));
> -
>  	if (mapping_unevictable(page_mapping(page)))
>  		return 0;
>  
> Index: test-2.6.26-rc5-mm3/mm/mlock.c
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/mlock.c
> +++ test-2.6.26-rc5-mm3/mm/mlock.c
> @@ -55,7 +55,6 @@ EXPORT_SYMBOL(can_do_mlock);
>   */
>  void __clear_page_mlock(struct page *page)
>  {
> -	VM_BUG_ON(!PageLocked(page));	/* for LRU isolate/putback */
>  
>  	dec_zone_page_state(page, NR_MLOCK);
>  	count_vm_event(NORECL_PGCLEARED);
> @@ -79,7 +78,6 @@ void __clear_page_mlock(struct page *pag
>   */
>  void mlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
>  
>  	if (!TestSetPageMlocked(page)) {
>  		inc_zone_page_state(page, NR_MLOCK);
> @@ -109,7 +107,6 @@ void mlock_vma_page(struct page *page)
>   */
>  static void munlock_vma_page(struct page *page)
>  {
> -	BUG_ON(!PageLocked(page));
>  
>  	if (TestClearPageMlocked(page)) {
>  		dec_zone_page_state(page, NR_MLOCK);
> @@ -169,7 +166,8 @@ static int __mlock_vma_pages_range(struc
>  
>  		/*
>  		 * get_user_pages makes pages present if we are
> -		 * setting mlock.
> +		 * setting mlock. and this extra reference count will
> +		 * disable migration of this page.
>  		 */
>  		ret = get_user_pages(current, mm, addr,
>  				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> @@ -197,14 +195,8 @@ static int __mlock_vma_pages_range(struc
>  		for (i = 0; i < ret; i++) {
>  			struct page *page = pages[i];
>  
> -			/*
> -			 * page might be truncated or migrated out from under
> -			 * us.  Check after acquiring page lock.
> -			 */
> -			lock_page(page);

Hmmm.  Still thinking about this.  No need to protect against in flight
truncation or migration?

> -			if (page->mapping)
> +			if (page_mapcount(page))
>  				mlock_vma_page(page);
> -			unlock_page(page);
>  			put_page(page);		/* ref from get_user_pages() */
>  
>  			/*
> @@ -240,6 +232,9 @@ static int __munlock_pte_handler(pte_t *
>  	struct page *page;
>  	pte_t pte;
>  
> +	/*
> +	 * page is never be unmapped by page-reclaim. we lock this page now.
> +	 */

I don't understand what you're trying to say here.  That is, what the
point of this comment is...

>  retry:
>  	pte = *ptep;
>  	/*
> @@ -261,7 +256,15 @@ retry:
>  		goto out;
>  
>  	lock_page(page);
> -	if (!page->mapping) {
> +	/*
> +	 * Because we lock page here, we have to check 2 cases.
> +	 * - the page is migrated.
> +	 * - the page is truncated (file-cache only)
> +	 * Note: Anonymous page doesn't clear page->mapping even if it
> +	 * is removed from rmap.
> +	 */
> +	if (!page->mapping ||
> +	     (PageAnon(page) && !page_mapcount(page))) {
>  		unlock_page(page);
>  		goto retry;
>  	}
> Index: test-2.6.26-rc5-mm3/mm/migrate.c
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/migrate.c
> +++ test-2.6.26-rc5-mm3/mm/migrate.c
> @@ -67,9 +67,7 @@ int putback_lru_pages(struct list_head *
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
>  		list_del(&page->lru);
> -		lock_page(page);
> -		if (putback_lru_page(page))
> -			unlock_page(page);
> +		putback_lru_page(page);
>  		count++;
>  	}
>  	return count;
> @@ -571,7 +569,6 @@ static int fallback_migrate_page(struct 
>  static int move_to_new_page(struct page *newpage, struct page *page)
>  {
>  	struct address_space *mapping;
> -	int unlock = 1;
>  	int rc;
>  
>  	/*
> @@ -610,12 +607,11 @@ static int move_to_new_page(struct page 
>  		 * Put back on LRU while holding page locked to
>  		 * handle potential race with, e.g., munlock()
>  		 */
> -		unlock = putback_lru_page(newpage);
> +		putback_lru_page(newpage);
>  	} else
>  		newpage->mapping = NULL;
>  
> -	if (unlock)
> -		unlock_page(newpage);
> +	unlock_page(newpage);
>  
>  	return rc;
>  }
> @@ -632,7 +628,6 @@ static int unmap_and_move(new_page_t get
>  	struct page *newpage = get_new_page(page, private, &result);
>  	int rcu_locked = 0;
>  	int charge = 0;
> -	int unlock = 1;
>  
>  	if (!newpage)
>  		return -ENOMEM;
> @@ -713,6 +708,7 @@ rcu_unlock:
>  		rcu_read_unlock();
>  
>  unlock:
> +	unlock_page(page);
>  
>  	if (rc != -EAGAIN) {
>   		/*
> @@ -722,18 +718,9 @@ unlock:
>   		 * restored.
>   		 */
>   		list_del(&page->lru);
> -		if (!page->mapping) {
> -			VM_BUG_ON(page_count(page) != 1);
> -			unlock_page(page);
> -			put_page(page);		/* just free the old page */
> -			goto end_migration;
> -		} else
> -			unlock = putback_lru_page(page);
> +		putback_lru_page(page);
>  	}
>  
> -	if (unlock)
> -		unlock_page(page);
> -
>  end_migration:
>  	if (!charge)
>  		mem_cgroup_end_migration(newpage);
> Index: test-2.6.26-rc5-mm3/mm/internal.h
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/internal.h
> +++ test-2.6.26-rc5-mm3/mm/internal.h
> @@ -43,7 +43,7 @@ static inline void __put_page(struct pag
>   * in mm/vmscan.c:
>   */
>  extern int isolate_lru_page(struct page *page);
> -extern int putback_lru_page(struct page *page);
> +extern void putback_lru_page(struct page *page);
>  
>  /*
>   * in mm/page_alloc.c
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
