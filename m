Subject: Re: [Experimental][PATCH] putback_lru_page rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080620101352.e1200b8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213813266.6497.14.camel@lts-notebook>
	 <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213886722.6398.29.camel@lts-notebook>
	 <20080620101352.e1200b8e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Date: Fri, 20 Jun 2008 13:10:43 -0400
Message-Id: <1213981843.6474.68.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-20 at 10:13 +0900, KAMEZAWA Hiroyuki wrote:
> Lee-san, this is an additonal one..
> Not-tested-yet, just by review.

OK, I'll test this on my x86_64 platform, which doesn't seem to hit the
soft lockups.

> 
> Fixing page_lock() <-> zone->lock nesting of bad-behavior.
> 
> Before:
>       lock_page()(TestSetPageLocked())
>       spin_lock(zone->lock)
>       unlock_page()
>       spin_unlock(zone->lock)  

Couple of comments:
* I believe that the locks are acquired in the right order--at least as
documented in the comments in mm/rmap.c.  
* The unlocking appears out of order because this function attempts to
hold the zone lock across a few pages in the pagevec, but must switch to
a different zone lru lock when it finds a page on a different zone from
the zone whose lock it is holding--like in the pagevec draining
functions, altho' they don't need to lock the page.

> After:
>       spin_lock(zone->lock)
>       spin_unlock(zone->lock)

Right.  With your reworked check_move_unevictable_page() [with retry],
we don't need to lock the page here, any more.  That means we can revert
all of the changes to pass the mapping back to sys_shmctl() and move the
call to scan_mapping_unevictable_pages() back to shmem_lock() after
clearing the address_space's unevictable flag.  We only did that to
avoid sleeping while holding the shmem_inode_info lock and the
shmid_kernel's ipc_perm spinlock.  

Shall I handle that, after we've tested this patch?

> 
> Including nit-pick fix. (I'll ask Kosaki-san to merge this to his 5/5)
> 
> Hmm...
> 
> ---
>  mm/vmscan.c |   25 +++++--------------------
>  1 file changed, 5 insertions(+), 20 deletions(-)
> 
> Index: test-2.6.26-rc5-mm3/mm/vmscan.c
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/vmscan.c
> +++ test-2.6.26-rc5-mm3/mm/vmscan.c
> @@ -1106,7 +1106,7 @@ static unsigned long shrink_inactive_lis
>  		if (nr_taken == 0)
>  			goto done;
>  
> -		spin_lock(&zone->lru_lock);
> +		spin_lock_irq(&zone->lru_lock);

1) It appears that the spin_lock() [no '_irq'] was there because irqs
are disabled a few lines above so that we could use non-atomic
__count[_zone]_vm_events().  
i>>?2) I think this predates the split lru or unevictable lru patches, so
these changes are unrelated.
>  		/*
>  		 * Put back any unfreeable pages.
>  		 */
> @@ -1136,9 +1136,8 @@ static unsigned long shrink_inactive_lis
>  			}
>  		}
>    	} while (nr_scanned < max_scan);
> -	spin_unlock(&zone->lru_lock);
> +	spin_unlock_irq(&zone->lru_lock);
>  done:
> -	local_irq_enable();
>  	pagevec_release(&pvec);
>  	return nr_reclaimed;
>  }
> @@ -2438,7 +2437,7 @@ static void show_page_path(struct page *
>   */
>  static void check_move_unevictable_page(struct page *page, struct zone *zone)
>  {
> -
> +retry:
>  	ClearPageUnevictable(page); /* for page_evictable() */
We can remove this comment            ^^^^^^^^^^^^^^^^^^^^^^^^^^
page_evictable() no longer asserts !PageUnevictable(), right?

>  	if (page_evictable(page, NULL)) {
>  		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
> @@ -2455,6 +2454,8 @@ static void check_move_unevictable_page(
>  		 */
>  		SetPageUnevictable(page);
>  		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
> +		if (page_evictable(page, NULL))
> +			goto retry;
>  	}
>  }
>  
> @@ -2494,16 +2495,6 @@ void scan_mapping_unevictable_pages(stru
>  				next = page_index;
>  			next++;
>  
> -			if (TestSetPageLocked(page)) {
> -				/*
> -				 * OK, let's do it the hard way...
> -				 */
> -				if (zone)
> -					spin_unlock_irq(&zone->lru_lock);
> -				zone = NULL;
> -				lock_page(page);
> -			}
> -
>  			if (pagezone != zone) {
>  				if (zone)
>  					spin_unlock_irq(&zone->lru_lock);
> @@ -2514,8 +2505,6 @@ void scan_mapping_unevictable_pages(stru
>  			if (PageLRU(page) && PageUnevictable(page))
>  				check_move_unevictable_page(page, zone);
>  
> -			unlock_page(page);
> -
>  		}
>  		if (zone)
>  			spin_unlock_irq(&zone->lru_lock);
> @@ -2551,15 +2540,11 @@ void scan_zone_unevictable_pages(struct 
>  		for (scan = 0;  scan < batch_size; scan++) {
>  			struct page *page = lru_to_page(l_unevictable);
>  
> -			if (TestSetPageLocked(page))
> -				continue;
> -
>  			prefetchw_prev_lru_page(page, l_unevictable, flags);
>  
>  			if (likely(PageLRU(page) && PageUnevictable(page)))
>  				check_move_unevictable_page(page, zone);
>  
> -			unlock_page(page);
>  		}
>  		spin_unlock_irq(&zone->lru_lock);
>  
> 

I'll let you know how it goes.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
