Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F0966B00A3
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 00:30:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N5PhYL021461
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 14:25:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A438B45DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:25:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 873E845DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:25:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A508E18008
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:25:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 025D71DB8038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:25:40 +0900 (JST)
Date: Mon, 23 Mar 2009 14:24:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [cleanup][PATCH mmotm] memcg: cleanup cache_charge
Message-Id: <20090323142414.770d13bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323141226.68be59ec.nishimura@mxp.nes.nec.co.jp>
References: <20090323141226.68be59ec.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 14:12:26 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Current mem_cgroup_cache_charge is a bit complicated especially
> in the case of shmem's swap-in.
> 
> This patch cleans it up by using try_charge_swapin and commit_charge_swapin.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Seems nice :) and sorry for my dirty codes :(

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |   60 +++++++++++++++++++++---------------------------------
>  1 files changed, 23 insertions(+), 37 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 55dea59..2fc6d6c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1238,6 +1238,10 @@ int mem_cgroup_newpage_charge(struct page *page,
>  				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
>  }
>  
> +static void
> +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> +					enum charge_type ctype);
> +
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> @@ -1274,16 +1278,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		unlock_page_cgroup(pc);
>  	}
>  
> -	if (do_swap_account && PageSwapCache(page)) {
> -		mem = try_get_mem_cgroup_from_swapcache(page);
> -		if (mem)
> -			mm = NULL;
> -		  else
> -			mem = NULL;
> -		/* SwapCache may be still linked to LRU now. */
> -		mem_cgroup_lru_del_before_commit_swapcache(page);
> -	}
> -
>  	if (unlikely(!mm && !mem))
>  		mm = &init_mm;
>  
> @@ -1291,32 +1285,16 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		return mem_cgroup_charge_common(page, mm, gfp_mask,
>  				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
>  
> -	ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> -				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
> -	if (mem)
> -		css_put(&mem->css);
> -	if (PageSwapCache(page))
> -		mem_cgroup_lru_add_after_commit_swapcache(page);
> +	/* shmem */
> +	if (PageSwapCache(page)) {
> +		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
> +		if (!ret)
> +			__mem_cgroup_commit_charge_swapin(page, mem,
> +					MEM_CGROUP_CHARGE_TYPE_SHMEM);
> +	} else
> +		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
> +					MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
>  
> -	if (do_swap_account && !ret && PageSwapCache(page)) {
> -		swp_entry_t ent = {.val = page_private(page)};
> -		unsigned short id;
> -		/* avoid double counting */
> -		id = swap_cgroup_record(ent, 0);
> -		rcu_read_lock();
> -		mem = mem_cgroup_lookup(id);
> -		if (mem) {
> -			/*
> -			 * We did swap-in. Then, this entry is doubly counted
> -			 * both in mem and memsw. We uncharge it, here.
> -			 * Recorded ID can be obsolete. We avoid calling
> -			 * css_tryget()
> -			 */
> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> -			mem_cgroup_put(mem);
> -		}
> -		rcu_read_unlock();
> -	}
>  	return ret;
>  }
>  
> @@ -1359,7 +1337,9 @@ charge_cur_mm:
>  	return __mem_cgroup_try_charge(mm, mask, ptr, true);
>  }
>  
> -void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> +static void
> +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> +					enum charge_type ctype)
>  {
>  	struct page_cgroup *pc;
>  
> @@ -1369,7 +1349,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
>  		return;
>  	pc = lookup_page_cgroup(page);
>  	mem_cgroup_lru_del_before_commit_swapcache(page);
> -	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +	__mem_cgroup_commit_charge(ptr, pc, ctype);
>  	mem_cgroup_lru_add_after_commit_swapcache(page);
>  	/*
>  	 * Now swap is on-memory. This means this page may be
> @@ -1400,6 +1380,12 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
>  
>  }
>  
> +void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> +{
> +	__mem_cgroup_commit_charge_swapin(page, ptr,
> +					MEM_CGROUP_CHARGE_TYPE_MAPPED);
> +}
> +
>  void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
>  {
>  	if (mem_cgroup_disabled())
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
