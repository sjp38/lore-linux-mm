Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 587458D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:02:58 -0500 (EST)
Date: Tue, 8 Mar 2011 09:59:39 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix to leave pages on wrong LRU with FUSE.
Message-Id: <20110308095939.58100cfd.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110307150049.d42d046d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110307150049.d42d046d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, miklos@szeredi.hu, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Mon, 7 Mar 2011 15:00:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> At this point, I'm not sure this is a fix for 
>    https://bugzilla.kernel.org/show_bug.cgi?id=30432.
> 
> The behavior seems very similar to SwapCache case and this is a possible
> bug and this patch can be a fix. Nishimura-san, how do you think ?
> 
As long as I can read the source code, I also think this is a possible bug.

> But I'm not sure how to test this....please review.
> 
> =
> fs/fuse/dev.c::fuse_try_move_page() does
> 
>    (1) remove a page from page cache by ->steal()
>    (2) re-add the page to page cache 
>    (3) link the page to LRU if it was _not_ on LRU at (1)
> 
> 
> This implies the page can be _on_ LRU when add_to_page_cache_locked() is called.
> So, the page is added to a memory cgroup while it's on LRU.
> 
> This is the same behavior as SwapCache, 'newly charged pages may be on LRU'
> and needs special care as
>  - remove page from old memcg's LRU before overwrite pc->mem_cgroup.
>  - add page to new memcg's LRU after overwrite pc->mem_cgroup.
> 
> So, reusing SwapCache code with renaming for fix.
> 
> Note: a page on pagevec(LRU).
> 
> If a page is not PageLRU(page) but on pagevec(LRU), it may be added to LRU
> while we overwrite page->mapping. But in that case, PCG_USED bit of
> the page_cgroup is not set and the page_cgroup will not be added to
> wrong memcg's LRU. So, this patch's logic will work fine.
> (It has been tested with SwapCache.)
> 
As for SwapCache, mem_cgroup_lru_add_after_commit() will be allways called,
and it will link the page to LRU. But, if I read this patch correctly,
a page cache on pagevec may not be added to a *proper* memcg's LRU.

      lru_add_drain()           mem_cgroup_cache_charge()
  ----------------------------------------------------------
                                  if (!PageLRU())
    SetPageLRU()
    add_page_to_lru_list()
      mem_cgroup_add_lru_list()
      -> do nothing
                                    mem_cgroup_charge_common()
                                      mem_cgroup_commit_charge()
                                      -> set PCG_USED

Right ?

Thanks,
Daisuke Nishimura.

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   42 +++++++++++++++++++++++-------------------
>  1 file changed, 23 insertions(+), 19 deletions(-)
> 
> Index: mmotm-0303/mm/memcontrol.c
> ===================================================================
> --- mmotm-0303.orig/mm/memcontrol.c
> +++ mmotm-0303/mm/memcontrol.c
> @@ -926,13 +926,12 @@ void mem_cgroup_add_lru_list(struct page
>  }
>  
>  /*
> - * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
> - * lru because the page may.be reused after it's fully uncharged (because of
> - * SwapCache behavior).To handle that, unlink page_cgroup from LRU when charge
> - * it again. This function is only used to charge SwapCache. It's done under
> - * lock_page and expected that zone->lru_lock is never held.
> + * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
> + * while it's linked to lru because the page may be reused after it's fully
> + * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
> + * It's done under lock_page and expected that zone->lru_lock isnever held.
>   */
> -static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
> +static void mem_cgroup_lru_del_before_commit(struct page *page)
>  {
>  	unsigned long flags;
>  	struct zone *zone = page_zone(page);
> @@ -948,7 +947,7 @@ static void mem_cgroup_lru_del_before_co
>  	spin_unlock_irqrestore(&zone->lru_lock, flags);
>  }
>  
> -static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
> +static void mem_cgroup_lru_add_after_commit(struct page *page)
>  {
>  	unsigned long flags;
>  	struct zone *zone = page_zone(page);
> @@ -2428,7 +2427,7 @@ int mem_cgroup_newpage_charge(struct pag
>  }
>  
>  static void
> -__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> +__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
>  					enum charge_type ctype);
>  
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> @@ -2468,17 +2467,22 @@ int mem_cgroup_cache_charge(struct page 
>  	if (unlikely(!mm))
>  		mm = &init_mm;
>  
> -	if (page_is_file_cache(page))
> -		return mem_cgroup_charge_common(page, mm, gfp_mask,
> +	if (page_is_file_cache(page) && !PageLRU(page)) {
> +		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
>  				MEM_CGROUP_CHARGE_TYPE_CACHE);
> -
> -	/* shmem */
> -	if (PageSwapCache(page)) {
> +	} else if (page_is_file_cache(page)) {
> +		struct mem_cgroup *mem;
> +		/* Page on LRU should be moved to the _new_ LRU */
> +		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &mem, true);
> +		if (!ret)
> +			__mem_cgroup_commit_charge_lrucare(page, mem,
> +					MEM_CGROUP_CHARGE_TYPE_CACHE);
> +	} else if (PageSwapCache(page)) {
>  		struct mem_cgroup *mem;
> -
>  		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
> +
>  		if (!ret)
> -			__mem_cgroup_commit_charge_swapin(page, mem,
> +			__mem_cgroup_commit_charge_lrucare(page, mem,
>  					MEM_CGROUP_CHARGE_TYPE_SHMEM);
>  	} else
>  		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> @@ -2529,7 +2533,7 @@ charge_cur_mm:
>  }
>  
>  static void
> -__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> +__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
>  					enum charge_type ctype)
>  {
>  	struct page_cgroup *pc;
> @@ -2540,9 +2544,9 @@ __mem_cgroup_commit_charge_swapin(struct
>  		return;
>  	cgroup_exclude_rmdir(&ptr->css);
>  	pc = lookup_page_cgroup(page);
> -	mem_cgroup_lru_del_before_commit_swapcache(page);
> +	mem_cgroup_lru_del_before_commit(page);
>  	__mem_cgroup_commit_charge(ptr, page, 1, pc, ctype);
> -	mem_cgroup_lru_add_after_commit_swapcache(page);
> +	mem_cgroup_lru_add_after_commit(page);
>  	/*
>  	 * Now swap is on-memory. This means this page may be
>  	 * counted both as mem and swap....double count.
> @@ -2580,7 +2584,7 @@ __mem_cgroup_commit_charge_swapin(struct
>  
>  void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
>  {
> -	__mem_cgroup_commit_charge_swapin(page, ptr,
> +	__mem_cgroup_commit_charge_lrucare(page, ptr,
>  					MEM_CGROUP_CHARGE_TYPE_MAPPED);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
