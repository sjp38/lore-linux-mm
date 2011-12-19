Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3F77B6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 10:14:37 -0500 (EST)
Date: Mon, 19 Dec 2011 16:14:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] memcg: simplify corner case handling of LRU.
Message-ID: <20111219151431.GB1415@cmpxchg.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214165032.ae8416b2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214165032.ae8416b2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, Dec 14, 2011 at 04:50:32PM +0900, KAMEZAWA Hiroyuki wrote:
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

Not quite.  It also clears PageLRU in between.

Since it doesn't release the lru lock until the page is back on the
list, couldn't we just leave that bit alone like
mem_cgroup_replace_page_cache() did?

That said, thanks for removing this mind-boggling complexity, the code
is much better off with this patch.

Feel free to add my

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Relevant hunks for reference:

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
