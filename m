Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 714F06B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 10:01:09 -0400 (EDT)
Date: Fri, 8 May 2009 23:01:07 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH 2/2] memcg fix stale swap cache account leak v6
Message-Id: <20090508230107.8dd680b3.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
	<20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

On Fri, 8 May 2009 14:09:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In general, Linux's swp_entry handling is done by combination of lazy techniques
> and global LRU. It works well but when we use mem+swap controller, some more
> strict control is appropriate. Otherwise, swp_entry used by a cgroup will be
> never freed until global LRU works. In a system where memcg is well-configured,
> global LRU doesn't work frequently.
> 
>   Example A) Assume a swap cache which is not mapped.
>               CPU0                            CPU1
> 	   zap_pte()....                  shrink_page_list()
> 	    free_swap_and_cache()           lock_page()
> 		page seems busy.
> 
>   Example B) Assume swapin-readahead.
> 	      CPU0			      CPU1
> 	   zap_pte()			  read_swap_cache_async()
> 					  swap_duplicate().
>            swap_entry_free() = 1
> 	   find_get_page()=> NULL.
> 					  add_to_swap_cache().
> 					  issue swap I/O. 
> 
> There are many patterns of this kind of race (but no problems).
> 
> free_swap_and_cache() is called for freeing swp_entry. But it is a best-effort
> function. If the swp_entry/page seems busy, swp_entry is not freed.
> This is not a problem because global-LRU will find SwapCache at page reclaim.
> 
> If memcg is used, on the other hand, global LRU may not work. Then, above
> unused SwapCache will not be freed.
> (unmapped SwapCache occupy swp_entry but never be freed if not on memcg's LRU)
> 
> So, even if there are no tasks in a cgroup, swp_entry usage still remains.
> In bad case, OOM by mem+swap controller is triggered by this "leak" of
> swp_entry as Nishimura reported.
> 
> Considering this issue, swapin-readahead itself is not very good for memcg.
> It read swap cache which will not be used. (and _unused_ swapcache will
> not be accounted.) Even if we account swap cache at add_to_swap_cache(),
> we need to account page to several _unrelated_ memcg. This is bad.
> 
> This patch tries to fix racy case of free_swap_and_cache() and page status.
> 
> After this patch applied, following test works well.
> 
>   # echo 1-2M > ../memory.limit_in_bytes
>   # run tasks under memcg.
>   # kill all tasks and make memory.tasks empty
>   # check memory.memsw.usage_in_bytes == memory.usage_in_bytes and
>     there is no _used_ swp_entry.
> 
> What this patch does is
>  - avoid swapin-readahead when memcg is activated.
I agree that disabling readahead would be the easiest way to avoid type-1.
And this patch looks good to me about it.

But if we go in this way to avoid type-1, I think my patch(*1) would be
enough to avoid type-2 and is simpler than this one.
I've confirmed in my test that no leak can be seen with my patch and
with setting page-cluster to 0.

*1 http://marc.info/?l=linux-kernel&m=124115252607665&w=2

>  - try to free swapcache immediately after Writeback is done.
>  - Handle racy case of __remove_mapping() in vmscan.c
> 
And IIUC, this patch still cannot avoid type-2 in some cases.
(for example, if stale swap cache hits "goto keep_locked" before pageout()
is called in shrink_page_list().)

In fact, I can see some leak in my test.


Thanks,
Daisuke Nishimura.

> TODO:
>  - tmpfs should use real readahead rather than swapin readahead...
> 
> Changelog: v5 -> v6
>  - works only when memcg is activated.
>  - check after I/O works only after writeback.
>  - avoid swapin-readahead when memcg is activated.
>  - fixed page refcnt issue.
> Changelog: v4->v5
>  - completely new design.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/page_io.c    |  125 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/swap_state.c |   20 +++++++-
>  mm/vmscan.c     |   31 ++++++++++++-
>  3 files changed, 171 insertions(+), 5 deletions(-)
> 
> Index: mmotm-2.6.30-May05/mm/page_io.c
> ===================================================================
> --- mmotm-2.6.30-May05.orig/mm/page_io.c
> +++ mmotm-2.6.30-May05/mm/page_io.c
> @@ -19,6 +19,130 @@
>  #include <linux/writeback.h>
>  #include <asm/pgtable.h>
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * When memory cgroup is used, race between writeback-swap and zap-swap can
> + * be a leak of swp_entry. So we have to check the status of swap at the end of
> + * swap-io. If memory cgroup is not used, Global LRU will find unused swap
> + * finally, in lazy way. (this is too lazy for memcg.)
> + */
> +
> +struct swapio_check {
> +	spinlock_t	lock;
> +	void		*swap_bio_list;
> +	struct delayed_work work;
> +} stale_swap_check;
> +
> +/*
> + * Check swap is really used or not after Writeback. And free swp_entry or
> + * drop swap cache if we can.
> + */
> +static void mem_cgroup_check_stale_swap(struct work_struct *work)
> +{
> +	struct bio *bio;
> +	struct page *page;
> +	struct swapio_check *sc;
> +	int nr = SWAP_CLUSTER_MAX;
> +	swp_entry_t entry;
> +
> +	sc = &stale_swap_check;
> +
> +	while (nr--) {
> +		cond_resched();
> +		spin_lock_irq(&sc->lock);
> +		bio = sc->swap_bio_list;
> +		if (bio)
> +			sc->swap_bio_list = bio->bi_next;
> +		spin_unlock_irq(&sc->lock);
> +		if (!bio)
> +			break;
> +		entry.val = (unsigned long)bio->bi_private;
> +		bio_put(bio);
> +		/* The page is not found if it's already reclaimed */
> +		page = find_get_page(&swapper_space, entry.val);
> +		if (!page)
> +			continue;
> +		if (!PageSwapCache(page) || page_mapped(page)) {
> +			page_cache_release(page);
> +			continue;
> +		}
> +		/*
> +		 * "synchronous" freeing of swap cache after write back.
> +		 */
> +		lock_page(page);
> +		if (PageSwapCache(page) && !PageWriteback(page) &&
> +		    !page_mapped(page))
> +			delete_from_swap_cache(page);
> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +	if (sc->swap_bio_list)
> +		schedule_delayed_work(&sc->work, HZ/10);
> +}
> +
> +/*
> + * We can't call try_to_free_swap directly here because of caller's context.
> + */
> +static void mem_cgroup_swapio_check_again(struct bio *bio, struct page *page)
> +{
> +	unsigned long flags;
> +	struct swapio_check *sc;
> +	swp_entry_t entry;
> +	int ret;
> +
> +	/* If memcg is not mounted, global LRU will work fine. */
> +	if (!mem_cgroup_activated())
> +		return;
> +	/* reuse bio if this bio is ready to be freed. */
> +	ret = atomic_inc_return(&bio->bi_cnt);
> +	/* Any other reference other than us ? */
> +	if (unlikely(ret > 2)) {
> +		bio_put(bio);
> +		return;
> +	}
> +	/*
> +	 * We don't grab this page....remember swp_entry instead of page. By
> +	 * this, aggressive memory freeing routine can free this page.
> +	 */
> +	entry.val = page_private(page);
> +	bio->bi_private = (void *)entry.val;
> +
> +	sc = &stale_swap_check;
> +	spin_lock_irqsave(&sc->lock, flags);
> +	/* link bio to remember swp_entry */
> +	bio->bi_next = sc->swap_bio_list;
> +	sc->swap_bio_list = bio;
> +	spin_unlock_irqrestore(&sc->lock, flags);
> +	/*
> +	 * Swap Writeback is tend to be continuous. Do check in batched manner.
> +	 */
> +	if (!delayed_work_pending(&sc->work))
> +		schedule_delayed_work(&sc->work, HZ/10);
> +}
> +
> +static int __init setup_stale_swap_check(void)
> +{
> +	struct swapio_check *sc;
> +
> +	sc = &stale_swap_check;
> +	spin_lock_init(&sc->lock);
> +	sc->swap_bio_list = NULL;
> +	INIT_DELAYED_WORK(&sc->work, mem_cgroup_check_stale_swap);
> +	return 0;
> +}
> +late_initcall(setup_stale_swap_check);
> +
> +
> +#else /* CONFIG_CGROUP_MEM_RES_CTRL */
> +
> +static inline
> +void mem_cgroup_swapio_check_again(struct bio *bio, struct page *page)
> +{
> +}
> +#endif
> +
> +
> +
>  static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
>  				struct page *page, bio_end_io_t end_io)
>  {
> @@ -66,6 +190,7 @@ static void end_swap_bio_write(struct bi
>  				(unsigned long long)bio->bi_sector);
>  		ClearPageReclaim(page);
>  	}
> +	mem_cgroup_swapio_check_again(bio, page);
>  	end_page_writeback(page);
>  	bio_put(bio);
>  }
> Index: mmotm-2.6.30-May05/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-May05.orig/mm/vmscan.c
> +++ mmotm-2.6.30-May05/mm/vmscan.c
> @@ -586,6 +586,30 @@ void putback_lru_page(struct page *page)
>  }
>  #endif /* CONFIG_UNEVICTABLE_LRU */
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTRL
> +/*
> + * Even if we don't call this, global LRU will finally find this SwapCache and
> + * free swap entry in the next loop. But, when memcg is used, we may have
> + * smaller chance to call global LRU's memory reclaim code.
> + * Freeing unused swap entry in aggressive way is good for avoid "leak" of swap
> + * entry accounting.
> + */
> +static inline void unuse_swapcache_check_again(struct page *page)
> +{
> +	/*
> +	 * The page is locked, but have extra reference from somewhere.
> +	 * In typical case, rotate_reclaimable_page()'s extra refcnt makes
> +	 * __remove_mapping fail. (see mm/swap.c)
> +	 */
> +	if (PageSwapCache(page))
> +		try_to_free_swap(page);
> +}
> +#else
> +static inline void unuse_swapcache_check_again(struct page *page)
> +{
> +}
> +#endif
> +
>  
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
> @@ -758,9 +782,12 @@ static unsigned long shrink_page_list(st
>  			}
>  		}
>  
> -		if (!mapping || !__remove_mapping(mapping, page))
> +		if (!mapping)
>  			goto keep_locked;
> -
> +		if (!__remove_mapping(mapping, page)) {
> +			unuse_swapcache_check_again(page);
> +			goto keep_locked;
> +		}
>  		/*
>  		 * At this point, we have no other references and there is
>  		 * no way to pick any more up (removed from LRU, removed
> Index: mmotm-2.6.30-May05/mm/swap_state.c
> ===================================================================
> --- mmotm-2.6.30-May05.orig/mm/swap_state.c
> +++ mmotm-2.6.30-May05/mm/swap_state.c
> @@ -349,9 +349,9 @@ struct page *read_swap_cache_async(swp_e
>  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	int nr_pages;
> +	int nr_pages = 1;
>  	struct page *page;
> -	unsigned long offset;
> +	unsigned long offset = 0;
>  	unsigned long end_offset;
>  
>  	/*
> @@ -360,8 +360,22 @@ struct page *swapin_readahead(swp_entry_
>  	 * No, it's very unlikely that swap layout would follow vma layout,
>  	 * more likely that neighbouring swap pages came from the same node:
>  	 * so use the same "addr" to choose the same node for each swap read.
> +	 *
> +	 * But, when memcg is used, swapin readahead give us some bad
> +	 * effects. There are 2 big problems in general.
> +	 * 1. Swapin readahead tend to use/read _not required_ memory.
> +	 *    And _not required_ memory is only freed by global LRU.
> +	 * 2. We can't charge pages for swap-cache readahead because
> +	 *    we should avoid account memory in a cgroup which a
> +	 *    thread call this function is not related to.
> +	 * And swapin-readahead have racy condition with
> +	 * free_swap_and_cache(). This also annoys memcg.
> +	 * Then, if memcg is really used, we avoid readahead.
>  	 */
> -	nr_pages = valid_swaphandles(entry, &offset);
> +
> +	if (!mem_cgroup_activated())
> +		nr_pages = valid_swaphandles(entry, &offset);
> +
>  	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
>  		/* Ok, do the async read-ahead now */
>  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
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
