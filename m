Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id AB25D6B0248
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 03:17:57 -0500 (EST)
Date: Tue, 13 Dec 2011 17:10:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX] memcg: fix memsw uncharged twice in do_swap_page
Message-Id: <20111213171016.2590def8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1323762925-14695-1-git-send-email-lliubbo@gmail.com>
References: <1323762925-14695-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, bsingharora@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hi,

On Tue, 13 Dec 2011 15:55:25 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> As the document memcg_test.txt said:
> In do_swap_page(), following events occur when pte is unchanged.
> 	(1) the page (SwapCache) is looked up.
> 	(2) lock_page()
> 	(3) try_charge_swapin()
> 	(4) reuse_swap_page() (may call delete_swap_cache())
> 	(5) commit_charge_swapin()
> 	(6) swap_free().
> 
> And below situation:
> (C) The page has been charged before (2) and reuse_swap_page() doesn't
> 	call delete_from_swap_cache().
> 
> In this case, __mem_cgroup_commit_charge_swapin() may uncharge memsw twice.
> See below two uncharge place:
> 
> __mem_cgroup_commit_charge_swapin {
> 	=> __mem_cgroup_commit_charge_lrucare
> 		=> __mem_cgroup_commit_charge()    <== PageCgroupUsed
> 			=> __mem_cgroup_cancel_charge()
> 						<== 1.uncharge memsw here
> 
> 	if (do_swap_account && PageSwapCache(page)) {
> 		if (swap_memcg) {
IIRC, if the page(swapcache) has been already charged as memory, swap_cgroup_record(ent, 0)
returns 0, so swap_memcg is NULL.

Thanks,
Daisuke Nishimura.

> 			if (!mem_cgroup_is_root(swap_memcg))
> 				res_counter_uncharge(&swap_memcg->memsw,
> 						PAGE_SIZE);
> 						<== 2.uncharged memsw again here
> 
> 			mem_cgroup_swap_statistics(swap_memcg, false);
> 			mem_cgroup_put(swap_memcg);
> 		}
> 	}
> }
> 
> This patch added a return val for __mem_cgroup_commit_charge(), if canceled then
> don't uncharge memsw again.
> 
> But i didn't find a definite testcase can confirm this situaction current.
> Maybe i missed something. Welcome point.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/memcontrol.c |   56 +++++++++++++++++++++++++++++++-----------------------
>  1 files changed, 32 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bc396e7..6ead0cd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2416,7 +2416,10 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	return memcg;
>  }
>  
> -static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
> +/*
> + * return -1 if cancel charge else return 0
> + */
> +static int __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  				       struct page *page,
>  				       unsigned int nr_pages,
>  				       struct page_cgroup *pc,
> @@ -2426,7 +2429,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
>  		__mem_cgroup_cancel_charge(memcg, nr_pages);
> -		return;
> +		return -1;
>  	}
>  	/*
>  	 * we don't need page_cgroup_lock about tail pages, becase they are not
> @@ -2463,6 +2466,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  	 * if they exceeds softlimit.
>  	 */
>  	memcg_check_events(memcg, page);
> +	return 0;
>  }
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -2690,20 +2694,21 @@ static void
>  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
>  					enum charge_type ctype);
>  
> -static void
> +static int
>  __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
>  					enum charge_type ctype)
>  {
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> +	int ret;
>  	/*
>  	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
>  	 * is already on LRU. It means the page may on some other page_cgroup's
>  	 * LRU. Take care of it.
>  	 */
>  	mem_cgroup_lru_del_before_commit(page);
> -	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
> +	ret = __mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
>  	mem_cgroup_lru_add_after_commit(page);
> -	return;
> +	return ret;
>  }
>  
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> @@ -2792,13 +2797,14 @@ static void
>  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
>  					enum charge_type ctype)
>  {
> +	int ret;
>  	if (mem_cgroup_disabled())
>  		return;
>  	if (!memcg)
>  		return;
>  	cgroup_exclude_rmdir(&memcg->css);
>  
> -	__mem_cgroup_commit_charge_lrucare(page, memcg, ctype);
> +	ret = __mem_cgroup_commit_charge_lrucare(page, memcg, ctype);
>  	/*
>  	 * Now swap is on-memory. This means this page may be
>  	 * counted both as mem and swap....double count.
> @@ -2807,25 +2813,27 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
>  	 * may call delete_from_swap_cache() before reach here.
>  	 */
>  	if (do_swap_account && PageSwapCache(page)) {
> -		swp_entry_t ent = {.val = page_private(page)};
> -		struct mem_cgroup *swap_memcg;
> -		unsigned short id;
> +		if(!ret) {
> +			swp_entry_t ent = {.val = page_private(page)};
> +			struct mem_cgroup *swap_memcg;
> +			unsigned short id;
>  
> -		id = swap_cgroup_record(ent, 0);
> -		rcu_read_lock();
> -		swap_memcg = mem_cgroup_lookup(id);
> -		if (swap_memcg) {
> -			/*
> -			 * This recorded memcg can be obsolete one. So, avoid
> -			 * calling css_tryget
> -			 */
> -			if (!mem_cgroup_is_root(swap_memcg))
> -				res_counter_uncharge(&swap_memcg->memsw,
> -						     PAGE_SIZE);
> -			mem_cgroup_swap_statistics(swap_memcg, false);
> -			mem_cgroup_put(swap_memcg);
> +			id = swap_cgroup_record(ent, 0);
> +			rcu_read_lock();
> +			swap_memcg = mem_cgroup_lookup(id);
> +			if (swap_memcg) {
> +				/*
> +				 * This recorded memcg can be obsolete one. So, avoid
> +				 * calling css_tryget
> +				 */
> +				if (!mem_cgroup_is_root(swap_memcg))
> +					res_counter_uncharge(&swap_memcg->memsw,
> +							PAGE_SIZE);
> +				mem_cgroup_swap_statistics(swap_memcg, false);
> +				mem_cgroup_put(swap_memcg);
> +			}
> +			rcu_read_unlock();
>  		}
> -		rcu_read_unlock();
>  	}
>  	/*
>  	 * At swapin, we may charge account against cgroup which has no tasks.
> -- 
> 1.7.0.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
