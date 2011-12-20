Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 96E3A6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 10:05:28 -0500 (EST)
Date: Tue, 20 Dec 2011 16:05:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/4] memcg: simplify corner case handling of LRU.
Message-ID: <20111220150523.GN10565@tiehlicka.suse.cz>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214165032.ae8416b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214165032.ae8416b2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed 14-12-11 16:50:32, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch simplifies LRU handling of racy case (memcg+SwapCache).
> At charging, SwapCache tend to be on LRU already. So, before
> overwriting pc->mem_cgroup, the page must be removed from LRU and
> added to LRU later.
> 
> This patch does
>         spin_lock(zone->lru_lock);
>         if (PageLRU(page))
>                 remove from LRU
>         overwrite pc->mem_cgroup
>         if (PageLRU(page))
>                 add to new LRU.
>         spin_unlock(zone->lru_lock);
> 
> And guarantee all pages are not on LRU at modifying pc->mem_cgroup.
> This patch also unfies lru handling of replace_page_cache() and
> swapin.
> 
> Changelog:
>  - modify PageLRU flag correctly.
>  - handle replace_page_cache.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |  109 ++++++++-----------------------------------------------
>  1 files changed, 16 insertions(+), 93 deletions(-)

Wow, really nice. I always hated {before,after}_commit thingies. It was
just too complex.

After ClearPageLRU && SetPageLRU cleanup mentioned by Johannes already
feel free to add my 
Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 947c62c..7a857e8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1071,86 +1071,6 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
>  }
>  
>  /*
> - * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
> - * while it's linked to lru because the page may be reused after it's fully
> - * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
> - * It's done under lock_page and expected that zone->lru_lock isnever held.
> - */
> -static void mem_cgroup_lru_del_before_commit(struct page *page)
> -{
> -	enum lru_list lru;
> -	unsigned long flags;
> -	struct zone *zone = page_zone(page);
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -
> -	/*
> -	 * Doing this check without taking ->lru_lock seems wrong but this
> -	 * is safe. Because if page_cgroup's USED bit is unset, the page
> -	 * will not be added to any memcg's LRU. If page_cgroup's USED bit is
> -	 * set, the commit after this will fail, anyway.
> -	 * This all charge/uncharge is done under some mutual execustion.
> -	 * So, we don't need to taking care of changes in USED bit.
> -	 */
> -	if (likely(!PageLRU(page)))
> -		return;
> -
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	lru = page_lru(page);
> -	/*
> -	 * The uncharged page could still be registered to the LRU of
> -	 * the stale pc->mem_cgroup.
> -	 *
> -	 * As pc->mem_cgroup is about to get overwritten, the old LRU
> -	 * accounting needs to be taken care of.  Let root_mem_cgroup
> -	 * babysit the page until the new memcg is responsible for it.
> -	 *
> -	 * The PCG_USED bit is guarded by lock_page() as the page is
> -	 * swapcache/pagecache.
> -	 */
> -	if (PageLRU(page) && PageCgroupAcctLRU(pc) && !PageCgroupUsed(pc)) {
> -		del_page_from_lru_list(zone, page, lru);
> -		add_page_to_lru_list(zone, page, lru);
> -	}
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> -}
> -
> -static void mem_cgroup_lru_add_after_commit(struct page *page)
> -{
> -	enum lru_list lru;
> -	unsigned long flags;
> -	struct zone *zone = page_zone(page);
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	/*
> -	 * putback:				charge:
> -	 * SetPageLRU				SetPageCgroupUsed
> -	 * smp_mb				smp_mb
> -	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
> -	 *
> -	 * Ensure that one of the two sides adds the page to the memcg
> -	 * LRU during a race.
> -	 */
> -	smp_mb();
> -	/* taking care of that the page is added to LRU while we commit it */
> -	if (likely(!PageLRU(page)))
> -		return;
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	lru = page_lru(page);
> -	/*
> -	 * If the page is not on the LRU, someone will soon put it
> -	 * there.  If it is, and also already accounted for on the
> -	 * memcg-side, it must be on the right lruvec as setting
> -	 * pc->mem_cgroup and PageCgroupUsed is properly ordered.
> -	 * Otherwise, root_mem_cgroup has been babysitting the page
> -	 * during the charge.  Move it to the new memcg now.
> -	 */
> -	if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
> -		del_page_from_lru_list(zone, page, lru);
> -		add_page_to_lru_list(zone, page, lru);
> -	}
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> -}
> -
> -/*
>   * Checks whether given mem is same or in the root_mem_cgroup's
>   * hierarchy subtree
>   */
> @@ -2695,14 +2615,27 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
>  					enum charge_type ctype)
>  {
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> +	struct zone *zone = page_zone(page);
> +	unsigned long flags;
> +	bool removed = false;
> +
>  	/*
>  	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
>  	 * is already on LRU. It means the page may on some other page_cgroup's
>  	 * LRU. Take care of it.
>  	 */
> -	mem_cgroup_lru_del_before_commit(page);
> +	spin_lock_irqsave(&zone->lru_lock, flags);
> +	if (PageLRU(page)) {
> +		del_page_from_lru_list(zone, page, page_lru(page));
> +		ClearPageLRU(page);
> +		removed = true;
> +	}
>  	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
> -	mem_cgroup_lru_add_after_commit(page);
> +	if (removed) {
> +		add_page_to_lru_list(zone, page, page_lru(page));
> +		SetPageLRU(page);
> +	}
> +	spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	return;
>  }
>  
> @@ -3303,9 +3236,7 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,


>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc;
> -	struct zone *zone;
>  	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
> -	unsigned long flags;
>  
>  	pc = lookup_page_cgroup(oldpage);
>  	/* fix accounting on old pages */
> @@ -3318,20 +3249,12 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
>  	if (PageSwapBacked(oldpage))
>  		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
>  
> -	zone = page_zone(newpage);
> -	pc = lookup_page_cgroup(newpage);
>  	/*
>  	 * Even if newpage->mapping was NULL before starting replacement,
>  	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
>  	 * LRU while we overwrite pc->mem_cgroup.
>  	 */
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	if (PageLRU(newpage))
> -		del_page_from_lru_list(zone, newpage, page_lru(newpage));
> -	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type);
> -	if (PageLRU(newpage))
> -		add_page_to_lru_list(zone, newpage, page_lru(newpage));
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +	__mem_cgroup_commit_charge_lrucare(newpage, memcg, type);
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
