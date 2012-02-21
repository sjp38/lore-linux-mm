Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id BB5596B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 04:15:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3FECC3EE0BB
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:15:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F00645DE50
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:15:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A36B45DE55
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:15:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18E86E08003
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:15:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2CE91DB803E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:15:02 +0900 (JST)
Date: Tue, 21 Feb 2012 18:13:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
Message-Id: <20120221181321.637556cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201533260.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201533260.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:34:28 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:
	return NULL;
>  
> +	lruvec = page_lock_lruvec(page);
>  	lock_page_cgroup(pc);
>  

Do we need to take lrulock+irq disable per page in this very very hot path ?

Hmm.... How about adding NR_ISOLATED counter into lruvec ?

Then, we can delay freeing lruvec until all conunters goes down to zero.
as...

	bool we_can_free_lruvec = true;

	lock_lruvec(lruvec->lock);
	for_each_lru_lruvec(lru)
		if (!list_empty(&lruvec->lru[lru]))
			we_can_free_lruvec = false;
	if (lruvec->nr_isolated)
		we_can_free_lruvec = false;
	unlock_lruvec(lruvec)
	if (we_can_free_lruvec)
		kfree(lruvec);

If compaction, lumpy reclaim free a page taken from LRU,
it knows what it does and can decrement lruvec->nr_isolated properly
(it seems zone's NR_ISOLATED is decremented at putback.)


Thanks,
-Kame

>  	memcg = pc->mem_cgroup;
> @@ -2915,14 +2944,17 @@ __mem_cgroup_uncharge_common(struct page
>  	mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
>  
>  	ClearPageCgroupUsed(pc);
> +
>  	/*
> -	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
> -	 * freed from LRU. This is safe because uncharged page is expected not
> -	 * to be reused (freed soon). Exception is SwapCache, it's handled by
> -	 * special functions.
> +	 * Once an uncharged page is isolated from the mem_cgroup's lru,
> +	 * it no longer protects that mem_cgroup from rmdir: reset to root.
>  	 */
> +	if (!PageLRU(page) && pc->mem_cgroup != root_mem_cgroup)
> +		pc->mem_cgroup = root_mem_cgroup;
>  
>  	unlock_page_cgroup(pc);
> +	unlock_lruvec(lruvec);
> +
>  	/*
>  	 * even after unlock, we have memcg->res.usage here and this memcg
>  	 * will never be freed.
> @@ -2939,6 +2971,7 @@ __mem_cgroup_uncharge_common(struct page
>  
>  unlock_out:
>  	unlock_page_cgroup(pc);
> +	unlock_lruvec(lruvec);
>  	return NULL;
>  }
>  
> @@ -3327,7 +3360,9 @@ static struct page_cgroup *lookup_page_c
>  	 * the first time, i.e. during boot or memory hotplug;
>  	 * or when mem_cgroup_disabled().
>  	 */
> -	if (likely(pc) && PageCgroupUsed(pc))
> +	if (!pc || PageCgroupUsed(pc))
> +		return pc;
> +	if (pc->mem_cgroup && pc->mem_cgroup != root_mem_cgroup)
>  		return pc;
>  	return NULL;
>  }
> --- mmotm.orig/mm/swap.c	2012-02-18 11:57:42.679524592 -0800
> +++ mmotm/mm/swap.c	2012-02-18 11:57:49.107524745 -0800
> @@ -52,6 +52,7 @@ static void __page_cache_release(struct
>  		lruvec = page_lock_lruvec(page);
>  		VM_BUG_ON(!PageLRU(page));
>  		__ClearPageLRU(page);
> +		mem_cgroup_reset_uncharged_to_root(page);
>  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		unlock_lruvec(lruvec);
>  	}
> @@ -583,6 +584,7 @@ void release_pages(struct page **pages,
>  			page_relock_lruvec(page, &lruvec);
>  			VM_BUG_ON(!PageLRU(page));
>  			__ClearPageLRU(page);
> +			mem_cgroup_reset_uncharged_to_root(page);
>  			del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		}
>  
> --- mmotm.orig/mm/vmscan.c	2012-02-18 11:57:42.679524592 -0800
> +++ mmotm/mm/vmscan.c	2012-02-18 11:57:49.107524745 -0800
> @@ -1087,11 +1087,11 @@ int __isolate_lru_page(struct page *page
>  
>  	if (likely(get_page_unless_zero(page))) {
>  		/*
> -		 * Be careful not to clear PageLRU until after we're
> -		 * sure the page is not being freed elsewhere -- the
> -		 * page release code relies on it.
> +		 * Beware of interface change: now leave ClearPageLRU(page)
> +		 * to the caller, because memcg's lumpy and compaction
> +		 * cases (approaching the page by its physical location)
> +		 * may not have the right lru_lock yet.
>  		 */
> -		ClearPageLRU(page);
>  		ret = 0;
>  	}
>  
> @@ -1154,7 +1154,16 @@ static unsigned long isolate_lru_pages(u
>  
>  		switch (__isolate_lru_page(page, mode, file)) {
>  		case 0:
> +#ifdef CONFIG_DEBUG_VM
> +			/* check lock on page is lock we already got */
> +			page_relock_lruvec(page, &lruvec);
> +			BUG_ON(lruvec != home_lruvec);
> +			BUG_ON(page != lru_to_page(src));
> +			BUG_ON(page_lru(page) != lru);
> +#endif
> +			ClearPageLRU(page);
>  			isolated_pages = hpage_nr_pages(page);
> +			mem_cgroup_reset_uncharged_to_root(page);
>  			mem_cgroup_update_lru_size(lruvec, lru, -isolated_pages);
>  			list_move(&page->lru, dst);
>  			nr_taken += isolated_pages;
> @@ -1211,21 +1220,7 @@ static unsigned long isolate_lru_pages(u
>  			    !PageSwapCache(cursor_page))
>  				break;
>  
> -			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> -				mem_cgroup_page_relock_lruvec(cursor_page,
> -								&lruvec);
> -				isolated_pages = hpage_nr_pages(cursor_page);
> -				mem_cgroup_update_lru_size(lruvec,
> -					page_lru(cursor_page), -isolated_pages);
> -				list_move(&cursor_page->lru, dst);
> -
> -				nr_taken += isolated_pages;
> -				nr_lumpy_taken += isolated_pages;
> -				if (PageDirty(cursor_page))
> -					nr_lumpy_dirty += isolated_pages;
> -				scan++;
> -				pfn += isolated_pages - 1;
> -			} else {
> +			if (__isolate_lru_page(cursor_page, mode, file) != 0) {
>  				/*
>  				 * Check if the page is freed already.
>  				 *
> @@ -1243,13 +1238,50 @@ static unsigned long isolate_lru_pages(u
>  					continue;
>  				break;
>  			}
> +
> +			/*
> +			 * This locking call is a no-op in the non-memcg
> +			 * case, since we already hold the right lru_lock;
> +			 * but it may change the lock in the memcg case.
> +			 * It is then vital to recheck PageLRU (but not
> +			 * necessary to recheck isolation mode).
> +			 */
> +			mem_cgroup_page_relock_lruvec(cursor_page, &lruvec);
> +
> +			if (PageLRU(cursor_page) &&
> +			    !PageUnevictable(cursor_page)) {
> +				ClearPageLRU(cursor_page);
> +				isolated_pages = hpage_nr_pages(cursor_page);
> +				mem_cgroup_reset_uncharged_to_root(cursor_page);
> +				mem_cgroup_update_lru_size(lruvec,
> +					page_lru(cursor_page), -isolated_pages);
> +				list_move(&cursor_page->lru, dst);
> +
> +				nr_taken += isolated_pages;
> +				nr_lumpy_taken += isolated_pages;
> +				if (PageDirty(cursor_page))
> +					nr_lumpy_dirty += isolated_pages;
> +				scan++;
> +				pfn += isolated_pages - 1;
> +			} else {
> +				/* Cannot hold lru_lock while freeing page */
> +				unlock_lruvec(lruvec);
> +				lruvec = NULL;
> +				put_page(cursor_page);
> +				break;
> +			}
>  		}
>  
>  		/* If we break out of the loop above, lumpy reclaim failed */
>  		if (pfn < end_pfn)
>  			nr_lumpy_failed++;
>  
> -		lruvec = home_lruvec;
> +		if (lruvec != home_lruvec) {
> +			if (lruvec)
> +				unlock_lruvec(lruvec);
> +			lruvec = home_lruvec;
> +			lock_lruvec(lruvec);
> +		}
>  	}
>  
>  	*nr_scanned = scan;
> @@ -1301,6 +1333,7 @@ int isolate_lru_page(struct page *page)
>  			int lru = page_lru(page);
>  			get_page(page);
>  			ClearPageLRU(page);
> +			mem_cgroup_reset_uncharged_to_root(page);
>  			del_page_from_lru_list(page, lruvec, lru);
>  			ret = 0;
>  		}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
