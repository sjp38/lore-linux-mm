Date: Tue, 17 Jun 2008 11:32:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix double unlock_page() in 2.6.26-rc5-mm3 kernel BUG
 at mm/filemap.c:575!
Message-Id: <20080617113235.cc493c03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1213371046.9670.12.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<20080612015746.172c4b56.akpm@linux-foundation.org>
	<20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
	<20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
	<20080612191311.1331f337.akpm@linux-foundation.org>
	<1213371046.9670.12.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 11:30:46 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> 1)  modified putback_lru_page() to drop page lock only if both page_mapping()
>     NULL and page_count() == 1 [rather than VM_BUG_ON(page_count(page) != 1].

I'm sorry that I cannot catch the whole changes..

I cannot convice that this implicit behavior won't cause lock-up in future, again.
Even if there are enough comments...

Why the page should be locked when it is put back to LRU ?
I think this restriction is added by RvR patch set, right ?
I'm sorry that I cannot catch the whole changes..

Anyway, IMHO, lock <-> unlock should be visible as a pair as much as possible.

Thanks,
-Kame

>     I want to balance the put_page() from isolate_lru_page() here for vmscan
>     and, e.g., page migration rather than requiring explicit checks of the
>     page_mapping() and explicit put_page() in these areas.  However, the page
>     could be truncated while one of these subsystems holds it isolated from
>     the LRU.  So, need to handle this case.  Callers of putback_lru_page()
>     need to be aware of this and only call it with a page with NULL
>     page_mapping() when they will no longer reference the page afterwards.
>     This is the case for vmscan and page migration.
> 
> 2)  m[un]lock_vma_page() already will not be called for page with NULL
>     mapping.  Added VM_BUG_ON() to assert this.
> 
> 3)  modified clear_page_lock() to skip the isolate/putback shuffle for
>     pages with NULL mapping, as they are being truncated/freed.  Thus,
>     any future callers of clear_page_lock() need not be concerned about
>     the putback_lru_page() semantics for truncated pages.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  mm/mlock.c  |   29 +++++++++++++++++++----------
>  mm/vmscan.c |   12 +++++++-----
>  2 files changed, 26 insertions(+), 15 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/mm/mlock.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/mm/mlock.c	2008-06-12 11:42:59.000000000 -0400
> +++ linux-2.6.26-rc5-mm3/mm/mlock.c	2008-06-13 09:47:14.000000000 -0400
> @@ -59,27 +59,33 @@ void __clear_page_mlock(struct page *pag
>  
>  	dec_zone_page_state(page, NR_MLOCK);
>  	count_vm_event(NORECL_PGCLEARED);
> -	if (!isolate_lru_page(page)) {
> -		putback_lru_page(page);
> -	} else {
> -		/*
> -		 * Page not on the LRU yet.  Flush all pagevecs and retry.
> -		 */
> -		lru_add_drain_all();
> -		if (!isolate_lru_page(page))
> +	if (page->mapping) {	/* truncated ? */
> +		if (!isolate_lru_page(page)) {
>  			putback_lru_page(page);
> -		else if (PageUnevictable(page))
> -			count_vm_event(NORECL_PGSTRANDED);
> +		} else {
> +			/*
> +			 * Page not on the LRU yet.
> +			 * Flush all pagevecs and retry.
> +			 */
> +			lru_add_drain_all();
> +			if (!isolate_lru_page(page))
> +				putback_lru_page(page);
> +			else if (PageUnevictable(page))
> +				count_vm_event(NORECL_PGSTRANDED);
> +		}
>  	}
>  }
>  
>  /*
>   * Mark page as mlocked if not already.
>   * If page on LRU, isolate and putback to move to unevictable list.
> + *
> + * Called with page locked and page_mapping() != NULL.
>   */
>  void mlock_vma_page(struct page *page)
>  {
>  	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!page_mapping(page));
>  
>  	if (!TestSetPageMlocked(page)) {
>  		inc_zone_page_state(page, NR_MLOCK);
> @@ -92,6 +98,8 @@ void mlock_vma_page(struct page *page)
>  /*
>   * called from munlock()/munmap() path with page supposedly on the LRU.
>   *
> + * Called with page locked and page_mapping() != NULL.
> + *
>   * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
>   * [in try_to_munlock()] and then attempt to isolate the page.  We must
>   * isolate the page to keep others from messing with its unevictable
> @@ -110,6 +118,7 @@ void mlock_vma_page(struct page *page)
>  static void munlock_vma_page(struct page *page)
>  {
>  	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!page_mapping(page));
>  
>  	if (TestClearPageMlocked(page)) {
>  		dec_zone_page_state(page, NR_MLOCK);
> Index: linux-2.6.26-rc5-mm3/mm/vmscan.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/mm/vmscan.c	2008-06-12 11:39:09.000000000 -0400
> +++ linux-2.6.26-rc5-mm3/mm/vmscan.c	2008-06-13 09:44:44.000000000 -0400
> @@ -1,4 +1,4 @@
> -/*
> + /*
>   *  linux/mm/vmscan.c
>   *
>   *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
> @@ -488,6 +488,9 @@ int remove_mapping(struct address_space 
>   * lru_lock must not be held, interrupts must be enabled.
>   * Must be called with page locked.
>   *
> + * If page truncated [page_mapping() == NULL] and we hold the last reference,
> + * the page will be freed here.  For vmscan and page migration.
> + *
>   * return 1 if page still locked [not truncated], else 0
>   */
>  int putback_lru_page(struct page *page)
> @@ -502,12 +505,11 @@ int putback_lru_page(struct page *page)
>  	lru = !!TestClearPageActive(page);
>  	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */
>  
> -	if (unlikely(!page->mapping)) {
> +	if (unlikely(!page->mapping && page_count(page) == 1)) {
>  		/*
> -		 * page truncated.  drop lock as put_page() will
> -		 * free the page.
> +		 * page truncated and we hold last reference.
> +		 * drop lock as put_page() will free the page.
>  		 */
> -		VM_BUG_ON(page_count(page) != 1);
>  		unlock_page(page);
>  		ret = 0;
>  	} else if (page_evictable(page, NULL)) {
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
