Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 893906B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 02:54:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L6thBF001169
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 15:55:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 376A145DE54
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CDDD45DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E62AD1DB8038
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DD651DB805B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:42 +0900 (JST)
Date: Tue, 21 Apr 2009 15:54:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: fix shrink_usage
Message-Id: <20090421155411.1afc9ca1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421142918.16026817.nishimura@mxp.nes.nec.co.jp>
References: <20090421142641.aa4efa2f.nishimura@mxp.nes.nec.co.jp>
	<20090421142918.16026817.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 14:29:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Current mem_cgroup_shrink_usage has two problems.
> 
> 1. It doesn't call mem_cgroup_out_of_memory and doesn't update last_oom_jiffies,
>    so pagefault_out_of_memory invokes global OOM.
> 2. Considering hierarchy, shrinking has to be done from the mem_over_limit,
>    not from the memcg which the page would be charged to.
> 
> mem_cgroup_try_charge_swapin does all of these works properly,
> so we use it and call cancel_charge_swapin when it succeeded.
> 
> The name of "shrink_usage" is not appropriate for this behavior,
> so we change it too.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you!.
-Kame

> ---
>  include/linux/memcontrol.h |    4 ++--
>  mm/memcontrol.c            |   33 ++++++++++++---------------------
>  mm/shmem.c                 |    8 ++++++--
>  3 files changed, 20 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 18146c9..928b714 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -56,7 +56,7 @@ extern void mem_cgroup_move_lists(struct page *page,
>  				  enum lru_list from, enum lru_list to);
>  extern void mem_cgroup_uncharge_page(struct page *page);
>  extern void mem_cgroup_uncharge_cache_page(struct page *page);
> -extern int mem_cgroup_shrink_usage(struct page *page,
> +extern int mem_cgroup_shmem_charge_fallback(struct page *page,
>  			struct mm_struct *mm, gfp_t gfp_mask);
>  
>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> @@ -155,7 +155,7 @@ static inline void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>  }
>  
> -static inline int mem_cgroup_shrink_usage(struct page *page,
> +static inline int mem_cgroup_shmem_charge_fallback(struct page *page,
>  			struct mm_struct *mm, gfp_t gfp_mask)
>  {
>  	return 0;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2fc6d6c..619b0c1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1618,37 +1618,28 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  }
>  
>  /*
> - * A call to try to shrink memory usage under specified resource controller.
> - * This is typically used for page reclaiming for shmem for reducing side
> - * effect of page allocation from shmem, which is used by some mem_cgroup.
> + * A call to try to shrink memory usage on charge failure at shmem's swapin.
> + * Calling hierarchical_reclaim is not enough because we should update
> + * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
> + * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
> + * not from the memcg which this page would be charged to.
> + * try_charge_swapin does all of these works properly.
>   */
> -int mem_cgroup_shrink_usage(struct page *page,
> +int mem_cgroup_shmem_charge_fallback(struct page *page,
>  			    struct mm_struct *mm,
>  			    gfp_t gfp_mask)
>  {
>  	struct mem_cgroup *mem = NULL;
> -	int progress = 0;
> -	int retry = MEM_CGROUP_RECLAIM_RETRIES;
> +	int ret;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
> -	if (page)
> -		mem = try_get_mem_cgroup_from_swapcache(page);
> -	if (!mem && mm)
> -		mem = try_get_mem_cgroup_from_mm(mm);
> -	if (unlikely(!mem))
> -		return 0;
>  
> -	do {
> -		progress = mem_cgroup_hierarchical_reclaim(mem,
> -					gfp_mask, true, false);
> -		progress += mem_cgroup_check_under_limit(mem);
> -	} while (!progress && --retry);
> +	ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
> +	if (!ret)
> +		mem_cgroup_cancel_charge_swapin(mem); /* it does !mem check */
>  
> -	css_put(&mem->css);
> -	if (!retry)
> -		return -ENOMEM;
> -	return 0;
> +	return ret;
>  }
>  
>  static DEFINE_MUTEX(set_limit_mutex);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d94d2e9..2419562 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1325,8 +1325,12 @@ repeat:
>  			shmem_swp_unmap(entry);
>  			spin_unlock(&info->lock);
>  			if (error == -ENOMEM) {
> -				/* allow reclaim from this memory cgroup */
> -				error = mem_cgroup_shrink_usage(swappage,
> +				/*
> +				 * reclaim from proper memory cgroup and
> +				 * call memcg's OOM if needed.
> +				 */
> +				error = mem_cgroup_shmem_charge_fallback(
> +								swappage,
>  								current->mm,
>  								gfp);
>  				if (error) {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
