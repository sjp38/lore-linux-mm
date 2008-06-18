Date: Wed, 18 Jun 2008 20:55:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Experimental][PATCH] putback_lru_page rework
Message-Id: <20080618205540.11a1644b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080618195009.37BF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	<20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	<20080618195009.37BF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jun 2008 20:36:52 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi kame-san,
> 
> > putback_lru_page() in this patch has a new concepts.
> > When it adds page to unevictable list, it checks the status is 
> > changed or not again. if changed, retry to putback.
> 
> it seems good idea :)
> this patch can reduce lock_page() call.
> 
yes.

> 
> > -	} else if (page_evictable(page, NULL)) {
> > -		/*
> > -		 * For evictable pages, we can use the cache.
> > -		 * In event of a race, worst case is we end up with an
> > -		 * unevictable page on [in]active list.
> > -		 * We know how to handle that.
> > -		 */
> 
> I think this comment is useful.
> Why do you want kill it?
> 
Oh, my mistake.



> > +	mem_cgroup_move_lists(page, lru);
> > +
> > +	/*
> > +	 * page's status can change while we move it among lru. If an evictable
> > +	 * page is on unevictable list, it never be freed. To avoid that,
> > +	 * check after we added it to the list, again.
> > +	 */
> > +	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
> > +		if (!isolate_lru_page(page)) {
> > +			put_page(page);
> > +			goto redo;
> 
> No.
> We should treat carefully unevictable -> unevictable moving too.
> 
This lru is the destination ;)


> 
> > +		}
> > +		/* This means someone else dropped this page from LRU
> > +		 * So, it will be freed or putback to LRU again. There is
> > +		 * nothing to do here.
> > +		 */
> > +	}
> > +
> > +	if (was_unevictable && lru != LRU_UNEVICTABLE)
> > +		count_vm_event(NORECL_PGRESCUED);
> > +	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
> > +		count_vm_event(NORECL_PGCULLED);
> >  
> >  	put_page(page);		/* drop ref from isolate */
> > -	return ret;		/* ret => "page still locked" */
> >  }
> > -
> > -/*
> > - * Cull page that shrink_*_list() has detected to be unevictable
> > - * under page lock to close races with other tasks that might be making
> > - * the page evictable.  Avoid stranding an evictable page on the
> > - * unevictable list.
> > - */
> > -static void cull_unevictable_page(struct page *page)
> > +#else
> > +void putback_lru_page(struct page *page)
> >  {
> > -	lock_page(page);
> > -	if (putback_lru_page(page))
> > -		unlock_page(page);
> > +	int lru;
> > +	VM_BUG_ON(PageLRU(page));
> > +
> > +	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
> > +	lru_cache_add_lru(page, lru);
> > +	mem_cgroup_move_lists(page, lru);
> > +	put_page(page);
> >  }
> > +#endif
> >  
> >  /*
> >   * shrink_page_list() returns the number of reclaimed pages
> > @@ -746,8 +736,8 @@ free_it:
> >  		continue;
> >  
> >  cull_mlocked:
> > -		if (putback_lru_page(page))
> > -			unlock_page(page);
> > +		unlock_page(page);
> > +		putback_lru_page(page);
> >  		continue;
> >  
> >  activate_locked:
> > @@ -1127,7 +1117,7 @@ static unsigned long shrink_inactive_lis
> >  			list_del(&page->lru);
> >  			if (unlikely(!page_evictable(page, NULL))) {
> >  				spin_unlock_irq(&zone->lru_lock);
> > -				cull_unevictable_page(page);
> > +				putback_lru_page(page);
> >  				spin_lock_irq(&zone->lru_lock);
> >  				continue;
> >  			}
> > @@ -1231,7 +1221,7 @@ static void shrink_active_list(unsigned 
> >  		list_del(&page->lru);
> >  
> >  		if (unlikely(!page_evictable(page, NULL))) {
> > -			cull_unevictable_page(page);
> > +			putback_lru_page(page);
> >  			continue;
> >  		}
> >  
> > @@ -2393,8 +2383,6 @@ int zone_reclaim(struct zone *zone, gfp_
> >  int page_evictable(struct page *page, struct vm_area_struct *vma)
> >  {
> >  
> > -	VM_BUG_ON(PageUnevictable(page));
> > -
> >  	if (mapping_unevictable(page_mapping(page)))
> >  		return 0;
> 
> Why do you remove this?
> 
I caught panci here ;)
maybe
==
  if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL))
==
check is.


> 
> 
> 
> > @@ -169,7 +166,8 @@ static int __mlock_vma_pages_range(struc
> >  
> >  		/*
> >  		 * get_user_pages makes pages present if we are
> > -		 * setting mlock.
> > +		 * setting mlock. and this extra reference count will
> > +		 * disable migration of this page.
> >  		 */
> >  		ret = get_user_pages(current, mm, addr,
> >  				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> > @@ -197,14 +195,8 @@ static int __mlock_vma_pages_range(struc
> >  		for (i = 0; i < ret; i++) {
> >  			struct page *page = pages[i];
> >  
> > -			/*
> > -			 * page might be truncated or migrated out from under
> > -			 * us.  Check after acquiring page lock.
> > -			 */
> > -			lock_page(page);
> > -			if (page->mapping)
> > +			if (page_mapcount(page))
> >  				mlock_vma_page(page);
> > -			unlock_page(page);
> >  			put_page(page);		/* ref from get_user_pages() */
> >  
> >  			/*
> > @@ -240,6 +232,9 @@ static int __munlock_pte_handler(pte_t *
> >  	struct page *page;
> >  	pte_t pte;
> >  
> > +	/*
> > +	 * page is never be unmapped by page-reclaim. we lock this page now.
> > +	 */
> >  retry:
> >  	pte = *ptep;
> >  	/*
> > @@ -261,7 +256,15 @@ retry:
> >  		goto out;
> >  
> >  	lock_page(page);
> > -	if (!page->mapping) {
> > +	/*
> > +	 * Because we lock page here, we have to check 2 cases.
> > +	 * - the page is migrated.
> > +	 * - the page is truncated (file-cache only)
> > +	 * Note: Anonymous page doesn't clear page->mapping even if it
> > +	 * is removed from rmap.
> > +	 */
> > +	if (!page->mapping ||
> > +	     (PageAnon(page) && !page_mapcount(page))) {
> >  		unlock_page(page);
> >  		goto retry;
> >  	}
> > Index: test-2.6.26-rc5-mm3/mm/migrate.c
> > ===================================================================
> > --- test-2.6.26-rc5-mm3.orig/mm/migrate.c
> > +++ test-2.6.26-rc5-mm3/mm/migrate.c
> > @@ -67,9 +67,7 @@ int putback_lru_pages(struct list_head *
> >  
> >  	list_for_each_entry_safe(page, page2, l, lru) {
> >  		list_del(&page->lru);
> > -		lock_page(page);
> > -		if (putback_lru_page(page))
> > -			unlock_page(page);
> > +		putback_lru_page(page);
> >  		count++;
> >  	}
> >  	return count;
> > @@ -571,7 +569,6 @@ static int fallback_migrate_page(struct 
> >  static int move_to_new_page(struct page *newpage, struct page *page)
> >  {
> >  	struct address_space *mapping;
> > -	int unlock = 1;
> >  	int rc;
> >  
> >  	/*
> > @@ -610,12 +607,11 @@ static int move_to_new_page(struct page 
> >  		 * Put back on LRU while holding page locked to
> >  		 * handle potential race with, e.g., munlock()
> >  		 */
> 
> this comment isn't true.
> 
yes.


> > -		unlock = putback_lru_page(newpage);
> > +		putback_lru_page(newpage);
> >  	} else
> >  		newpage->mapping = NULL;
> 
> originally move_to_lru() called in unmap_and_move().
> unevictable infrastructure patch move to this point for 
> calling putback_lru_page() under page locked.
> 
> So, your patch remove page locked dependency.
> move to unmap_and_move() again is better.
> 
> it become page lock holding time reducing.
> 
ok, will look into again.

Thanks,
-Kame


> >  
> > -	if (unlock)
> > -		unlock_page(newpage);
> > +	unlock_page(newpage);
> >  
> >  	return rc;
> >  }
> > @@ -632,7 +628,6 @@ static int unmap_and_move(new_page_t get
> >  	struct page *newpage = get_new_page(page, private, &result);
> >  	int rcu_locked = 0;
> >  	int charge = 0;
> > -	int unlock = 1;
> >  
> >  	if (!newpage)
> >  		return -ENOMEM;
> > @@ -713,6 +708,7 @@ rcu_unlock:
> >  		rcu_read_unlock();
> >  
> >  unlock:
> > +	unlock_page(page);
> >  
> >  	if (rc != -EAGAIN) {
> >   		/*
> > @@ -722,18 +718,9 @@ unlock:
> >   		 * restored.
> >   		 */
> >   		list_del(&page->lru);
> > -		if (!page->mapping) {
> > -			VM_BUG_ON(page_count(page) != 1);
> > -			unlock_page(page);
> > -			put_page(page);		/* just free the old page */
> > -			goto end_migration;
> > -		} else
> > -			unlock = putback_lru_page(page);
> > +		putback_lru_page(page);
> >  	}
> >  
> > -	if (unlock)
> > -		unlock_page(page);
> > -
> >  end_migration:
> >  	if (!charge)
> >  		mem_cgroup_end_migration(newpage);
> > Index: test-2.6.26-rc5-mm3/mm/internal.h
> > ===================================================================
> > --- test-2.6.26-rc5-mm3.orig/mm/internal.h
> > +++ test-2.6.26-rc5-mm3/mm/internal.h
> > @@ -43,7 +43,7 @@ static inline void __put_page(struct pag
> >   * in mm/vmscan.c:
> >   */
> >  extern int isolate_lru_page(struct page *page);
> > -extern int putback_lru_page(struct page *page);
> > +extern void putback_lru_page(struct page *page);
> >  
> >  /*
> >   * in mm/page_alloc.c
> > 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
