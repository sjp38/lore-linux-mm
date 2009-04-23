Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F1AAE6B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 04:46:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3N8knfZ008292
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Apr 2009 17:46:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E907045DE51
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 17:46:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C500D45DD79
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 17:46:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD78A1DB803A
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 17:46:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D22BE38001
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 17:46:48 +0900 (JST)
Date: Thu, 23 Apr 2009 17:45:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for mem+swap controller
Message-Id: <20090423174516.31e75286.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090423131438.062cfb13.nishimura@mxp.nes.nec.co.jp>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
	<20090423131438.062cfb13.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Apr 2009 13:14:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > I'll dig and try more including another aproach..
> > 
> How about this patch ?
> 
> It seems to have been working fine for several hours.
> I should add more and more comments and clean it up, of course :)
> (I think it would be better to unify definitions of new functions to swapfile.c,
> and checking page_mapped() might be enough for mem_cgroup_free_unused_swapcache().)
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hmm, I still think this patch is overkill. 



> ---
>  include/linux/memcontrol.h |    5 +++
>  include/linux/swap.h       |   11 ++++++++
>  mm/memcontrol.c            |   62 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/swap_state.c            |    8 +++++
>  mm/swapfile.c              |   32 ++++++++++++++++++++++-
>  mm/vmscan.c                |    8 +++++
>  6 files changed, 125 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 25b9ca9..8b674c2 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -101,6 +101,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone);
>  struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> +extern void mem_cgroup_free_unused_swapcache(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  					struct task_struct *p);
>  
> @@ -259,6 +260,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return NULL;
>  }
>  
> +static inline void mem_cgroup_free_unused_swapcache(struct page *page)
> +{
> +}
> +
>  static inline void
>  mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 62d8143..cdfa982 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -336,11 +336,22 @@ static inline void disable_swap_token(void)
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
> +extern int mem_cgroup_fixup_swapin(struct page *page);
> +extern void mem_cgroup_fixup_swapfree(struct page *page);
>  #else
>  static inline void
>  mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
>  {
>  }
> +static inline int
> +mem_cgroup_fixup_swapin(struct page *page)
> +{
> +	return 0;
> +}
> +static inline void
> +mem_cgroup_fixup_swapfree(struct page *page)
> +{
> +}
>  #endif
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 79c32b8..f90967b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1536,6 +1536,68 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  }
>  #endif
>  
> +struct mem_cgroup_swap_fixup_work {
> +	struct work_struct work;
> +	struct page *page;
> +};
> +
> +static void mem_cgroup_fixup_swapfree_cb(struct work_struct *work)
> +{
> +	struct mem_cgroup_swap_fixup_work *my_work;
> +	struct page *page;
> +
> +	my_work = container_of(work, struct mem_cgroup_swap_fixup_work, work);
> +	page = my_work->page;
> +
> +	lock_page(page);
> +	if (PageSwapCache(page))
> +		mem_cgroup_free_unused_swapcache(page);
> +	unlock_page(page);
> +
> +	kfree(my_work);
> +	put_page(page);
> +}
> +
> +void mem_cgroup_fixup_swapfree(struct page *page)
> +{
> +	struct mem_cgroup_swap_fixup_work *my_work;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	if (!PageSwapCache(page) || page_mapped(page))
> +		return;
> +
> +	my_work = kmalloc(sizeof(*my_work), GFP_ATOMIC); /* cannot sleep */
> +	if (my_work) {
> +		get_page(page);	/* put_page will be called in callback */
> +		my_work->page = page;
> +		INIT_WORK(&my_work->work, mem_cgroup_fixup_swapfree_cb);
> +		schedule_work(&my_work->work);
> +	}
> +
> +	return;
> +}
> +
> +/*
> + * called from shrink_page_list() and mem_cgroup_fixup_swapfree_cb() to free
> + * !PageCgroupUsed SwapCache, because memcg cannot handle these SwapCache well.
> + */
> +void mem_cgroup_free_unused_swapcache(struct page *page)
> +{
> +		struct page_cgroup *pc;
> +
> +		VM_BUG_ON(!PageLocked(page));
> +		VM_BUG_ON(!PageSwapCache(page));
> +
> +		pc = lookup_page_cgroup(page);
> +		/*
> +		 * Used bit of swapcache is solid under page lock.
> +		 */
> +		if (!PageCgroupUsed(pc))
> +			try_to_free_swap(page);
> +}
> +
>  /*
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 3ecea98..57d9678 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -310,6 +310,14 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		SetPageSwapBacked(new_page);
>  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
>  		if (likely(!err)) {
> +			if (unlikely(mem_cgroup_fixup_swapin(new_page)))
> +				/*
> +				 * new_page is not used by anyone.
> +				 * And it has been already removed from
> +				 * SwapCache and freed.
> +				 */
> +				return NULL;
> +

Can't we check refcnt of swp_entry here, again ?
if (refcnt == 1), we can make this as STALE.
(and can free swap cache here)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
