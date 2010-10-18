Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA8EF6B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 00:39:51 -0400 (EDT)
Date: Mon, 18 Oct 2010 13:29:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/2] memcg: avoiding unnecessary get_page at
 move_charge
Message-Id: <20101018132901.a05808d1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101015171109.d4575c95.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
	<20101015171109.d4575c95.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Oct 2010 17:11:09 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> CC'ed to Mel and Chrisotph, KOSAKi because I wanted to be double-cheked
> that I miss something important at isolate_lru_page().
> 
> Checking perofrmance of memcg's move_account with perf, you may notice
> that put_page() is too much.
> #
> # Overhead  Command      Shared Object                                 Symbol
> # ........  .......  .................  .....................................
> #
>     14.24%     echo  [kernel.kallsyms]  [k] put_page
>     12.80%     echo  [kernel.kallsyms]  [k] isolate_lru_page
>      9.67%     echo  [kernel.kallsyms]  [k] is_target_pte_for_mc
>      8.11%     echo  [kernel.kallsyms]  [k] ____pagevec_lru_add
>      7.22%     echo  [kernel.kallsyms]  [k] putback_lru_page
> 
> This is because mc_handle_present_pte() do get_page(). Then,
> page->count is updated 4 times.
> 	get_page_unless_zero() #1
> 	isolate_lru_page()
> 	putback_lru_page()
> 	put_page()
> 
> But above is called all under pte_offset_map_lock().
> get_page_unless_zero() #1 is not necessary because we do all under a
> pte_offset_map_lock().
> 
> isolate_lru_page()'s comment says 
>  # Restrictions:
>  # (1) Must be called with an elevated refcount on the page. This is a
>  #     fundamentnal difference from isolate_lru_pages (which is called
>  #     without a stable reference).
> 
> So, current implemnation does get_page_unless_zero() explicitly but
> holding pte_lock() implies a stable reference. I removed #1.
> 
> Then, Performance will be
> [Before Patch]
> [root@bluextal kamezawa]# time echo 2530 > /cgroup/B/tasks
> 
> real    0m0.792s
> user    0m0.000s
> sys     0m0.780s
> 
> [After Patch]
> [root@bluextal kamezawa]# time echo 2257 > /cgroup/B/tasks
> 
> real    0m0.694s
> user    0m0.000s
> sys     0m0.683s
> 
Very nice!

Some nitpicks.

> perf's log is
>     10.82%     echo  [kernel.kallsyms]  [k] isolate_lru_page
>     10.01%     echo  [kernel.kallsyms]  [k] mem_cgroup_move_account
>      8.75%     echo  [kernel.kallsyms]  [k] is_target_pte_for_mc
>      8.52%     echo  [kernel.kallsyms]  [k] ____pagevec_lru_add
>      6.90%     echo  [kernel.kallsyms]  [k] putback_lru_page
>      6.36%     echo  [kernel.kallsyms]  [k] mem_cgroup_add_lru_list
>      6.22%     echo  [kernel.kallsyms]  [k] mem_cgroup_del_lru_list
>      5.68%     echo  [kernel.kallsyms]  [k] lookup_page_cgroup
>      5.28%     echo  [kernel.kallsyms]  [k] __lru_cache_add
>      5.00%     echo  [kernel.kallsyms]  [k] release_pages
>      3.79%     echo  [kernel.kallsyms]  [k] _raw_spin_lock_irq
>      3.52%     echo  [kernel.kallsyms]  [k] memcg_check_events
>      3.38%     echo  [kernel.kallsyms]  [k] bit_spin_lock
>      3.25%     echo  [kernel.kallsyms]  [k] put_page
> 
> seems nice. I updated isolate_lru_page()'s comment, too.
> 
> # Note: isolate_lru_page() is necessary before account move for avoinding
>         memcg's LRU manipulation.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   63 +++++++++++++++++++++++++++++++++++---------------------
>  mm/vmscan.c     |    3 +-
>  2 files changed, 42 insertions(+), 24 deletions(-)
> 
> Index: mmotm-1013/mm/memcontrol.c
> ===================================================================
> --- mmotm-1013.orig/mm/memcontrol.c
> +++ mmotm-1013/mm/memcontrol.c
> @@ -1169,7 +1169,6 @@ static void mem_cgroup_end_move(struct m
>   *			  under hierarchy of moving cgroups. This is for
>   *			  waiting at hith-memory prressure caused by "move".
>   */
> -
>  static bool mem_cgroup_stealed(struct mem_cgroup *mem)
>  {
>  	VM_BUG_ON(!rcu_read_lock_held());
> @@ -4471,11 +4470,14 @@ one_by_one:
>   * Returns
>   *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
>   *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
> - *     move charge. if @target is not NULL, the page is stored in target->page
> - *     with extra refcnt got(Callers should handle it).
> + *     move charge and it's mapped.. if @target is not NULL, the page is
> + *     stored in target->pagewithout extra refcnt.
                               ^^ needs ' '.

>   *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
>   *     target for charge migration. if @target is not NULL, the entry is stored
>   *     in target->ent.
> + *   3(MC_TARGET_UNMAPPED_PAGE): if the page corresponding to this pte is a
> + *     target for move charge. if @target is not NULL, the page is stored in
> + *     target->page with extra refcnt got(Callers should handle it).
>   *
>   * Called with pte lock held.
>   */
> @@ -4486,8 +4488,9 @@ union mc_target {
>  
>  enum mc_target_type {
>  	MC_TARGET_NONE,	/* not used */
> -	MC_TARGET_PAGE,
> +	MC_TARGET_PAGE, /* a page mapped */
>  	MC_TARGET_SWAP,
> +	MC_TARGET_UNMAPPED_PAGE, /* a page unmapped */
>  };
>  
I prefer the order of "MC_TARGET_PAGE", "MC_TARGET_UNMAPPED_PAGE", and "MC_TARGET_SWAP".

>  static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> @@ -4504,9 +4507,10 @@ static struct page *mc_handle_present_pt
>  	} else if (!move_file())
>  		/* we ignore mapcount for file pages */
>  		return NULL;
> -	if (!get_page_unless_zero(page))
> -		return NULL;
> -
> +	/*
> + 	 * Because we're under pte_lock and the page is mapped,
> +	 * get_page() isn't necessary
> +	 */
>  	return page;
>  }
>  
> @@ -4570,14 +4574,18 @@ static int is_target_pte_for_mc(struct v
>  	struct page *page = NULL;
>  	struct page_cgroup *pc;
>  	int ret = 0;
> +	bool present = true;
>  	swp_entry_t ent = { .val = 0 };
>  
>  	if (pte_present(ptent))
>  		page = mc_handle_present_pte(vma, addr, ptent);
> -	else if (is_swap_pte(ptent))
> -		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
> -	else if (pte_none(ptent) || pte_file(ptent))
> -		page = mc_handle_file_pte(vma, addr, ptent, &ent);
> +	else {
> +		present = false;
> +	 	if (is_swap_pte(ptent))
> +			page = mc_handle_swap_pte(vma, addr, ptent, &ent);
> +		else if (pte_none(ptent) || pte_file(ptent))
> +			page = mc_handle_file_pte(vma, addr, ptent, &ent);
> +	}
>  
>  	if (!page && !ent.val)
>  		return 0;
> @@ -4589,11 +4597,15 @@ static int is_target_pte_for_mc(struct v
>  		 * the lock.
>  		 */
>  		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
> -			ret = MC_TARGET_PAGE;
> +			if (present)
> +				ret = MC_TARGET_PAGE;
> +			else
> +				ret = MC_TARGET_UNMAPPED_PAGE;
>  			if (target)
>  				target->page = page;
>  		}
> -		if (!ret || !target)
> +		/* We got refcnt but the page is not for target */
> +		if (!present && (!ret || !target))
>  			put_page(page);
>  	}
>  	/* There is a swap entry and a page doesn't exist or isn't charged */
> @@ -4780,19 +4792,24 @@ retry:
>  		type = is_target_pte_for_mc(vma, addr, ptent, &target);
>  		switch (type) {
>  		case MC_TARGET_PAGE:
> +		case MC_TARGET_UNMAPPED_PAGE:
>  			page = target.page;
> -			if (isolate_lru_page(page))
> -				goto put;
> -			pc = lookup_page_cgroup(page);
> -			if (!mem_cgroup_move_account(pc,
> +			if (!isolate_lru_page(page)) {
> +				pc = lookup_page_cgroup(page);
> +				if (!mem_cgroup_move_account(pc,
>  						mc.from, mc.to, false)) {
> -				mc.precharge--;
> -				/* we uncharge from mc.from later. */
> -				mc.moved_charge++;
> +					mc.precharge--;
> +					/* we uncharge from mc.from later. */
> +					mc.moved_charge++;
> +				}
> +				putback_lru_page(page);
>  			}
> -			putback_lru_page(page);
> -put:			/* is_target_pte_for_mc() gets the page */
> -			put_page(page);
> +			/*
> +			 * Because we holds pte_lock, we have a stable reference			 * to the page if mapped. If not mapped, we have an

You need a new line :)


Thanks,
Daisuke Nishimura.

> +			 * elevated refcnt. drop it.
> +			 */
> +			if (type == MC_TARGET_UNMAPPED_PAGE)
> +				put_page(page);
>  			break;
>  		case MC_TARGET_SWAP:
>  			ent = target.ent;
> Index: mmotm-1013/mm/vmscan.c
> ===================================================================
> --- mmotm-1013.orig/mm/vmscan.c
> +++ mmotm-1013/mm/vmscan.c
> @@ -1166,7 +1166,8 @@ static unsigned long clear_active_flags(
>   * found will be decremented.
>   *
>   * Restrictions:
> - * (1) Must be called with an elevated refcount on the page. This is a
> + * (1) Must be called with an elevated refcount on the page, IOW, the
> + *     caller must guarantee that there is a stable reference. This is a
>   *     fundamentnal difference from isolate_lru_pages (which is called
>   *     without a stable reference).
>   * (2) the lru_lock must not be held.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
