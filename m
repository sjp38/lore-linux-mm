Date: Wed, 24 Sep 2008 15:50:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 3.6/13] memcg: add function to move account.
Message-Id: <20080924155011.6fcbc78e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080922200948.83b4ef26.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080922200948.83b4ef26.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Sep 2008 20:09:48 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Sorry, this patchs is after "3.5" , before "4"....
> 
> ==
> This patch provides a function to move account information of a page between
> mem_cgroups.
> 
> This moving of page_cgroup is done under
>  - the page is locked.
>  - lru_lock of source/destination mem_cgroup is held.
> 
> Then, a routine which touches pc->mem_cgroup without page_lock() should
> confirm pc->mem_cgroup is still valid or not. Typlical code can be following.
> 
> (while page is not under lock_page())
> 	mem = pc->mem_cgroup;
> 	mz = page_cgroup_zoneinfo(pc)
> 	spin_lock_irqsave(&mz->lru_lock);
> 	if (pc->mem_cgroup == mem)
> 		...../* some list handling */
> 	spin_unlock_irq(&mz->lru_lock);
> 

Is this check needed?
Both move_lists and move_account takes page_cgroup lock.


Thanks,
Daisuke Nishimura.

> If you find page_cgroup from mem_cgroup's LRU under mz->lru_lock, you don't
> have to worry about anything.
> 
> Changelog: (v3) -> (v4)
>   - no changes.
> Changelog: (v2) -> (v3)
>   - added lock_page_cgroup().
>   - splitted out from new-force-empty patch.
>   - added how-to-use text.
>   - fixed race in __mem_cgroup_uncharge_common().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/memcontrol.c |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 82 insertions(+), 3 deletions(-)
> 
> Index: mmotm-2.6.27-rc6+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.27-rc6+.orig/mm/memcontrol.c
> +++ mmotm-2.6.27-rc6+/mm/memcontrol.c
> @@ -424,6 +424,7 @@ int task_in_mem_cgroup(struct task_struc
>  void mem_cgroup_move_lists(struct page *page, enum lru_list lru)
>  {
>  	struct page_cgroup *pc;
> +	struct mem_cgroup *mem;
>  	struct mem_cgroup_per_zone *mz;
>  	unsigned long flags;
>  
> @@ -442,9 +443,14 @@ void mem_cgroup_move_lists(struct page *
>  
>  	pc = page_get_page_cgroup(page);
>  	if (pc) {
> +		mem = pc->mem_cgroup;
>  		mz = page_cgroup_zoneinfo(pc);
>  		spin_lock_irqsave(&mz->lru_lock, flags);
> -		__mem_cgroup_move_lists(pc, lru);
> +		/*
> +		 * check against the race with move_account.
> +		 */
> +		if (likely(mem == pc->mem_cgroup))
> +			__mem_cgroup_move_lists(pc, lru);
>  		spin_unlock_irqrestore(&mz->lru_lock, flags);
>  	}
>  	unlock_page_cgroup(page);
> @@ -565,6 +571,71 @@ unsigned long mem_cgroup_isolate_pages(u
>  	return nr_taken;
>  }
>  
> +/**
> + * mem_cgroup_move_account - move account of the page
> + * @page ... the target page of being moved.
> + * @pc   ... page_cgroup of the page.
> + * @from ... mem_cgroup which the page is moved from.
> + * @to   ... mem_cgroup which the page is moved to.
> + *
> + * The caller must confirm following.
> + * 1. lock the page by lock_page().
> + * 2. disable irq.
> + * 3. lru_lock of old mem_cgroup should be held.
> + * 4. pc is guaranteed to be valid and on mem_cgroup's LRU.
> + *
> + * Because we cannot call try_to_free_page() here, the caller must guarantee
> + * this moving of change never fails. Currently this is called only against
> + * root cgroup, which has no limitation of resource.
> + * Returns 0 at success, returns 1 at failure.
> + */
> +int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
> +	struct mem_cgroup *from, struct mem_cgroup *to)
> +{
> +	struct mem_cgroup_per_zone *from_mz, *to_mz;
> +	int nid, zid;
> +	int ret = 1;
> +
> +	VM_BUG_ON(!irqs_disabled());
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	nid = page_to_nid(page);
> +	zid = page_zonenum(page);
> +	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
> +	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
> +
> +	if (res_counter_charge(&to->res, PAGE_SIZE)) {
> +		/* Now, we assume no_limit...no failure here. */
> +		return ret;
> +	}
> +	if (!try_lock_page_cgroup(page)) {
> +		res_counter_uncharge(&to->res, PAGE_SIZE);
> +		return ret;
> +	}
> +
> +	if (page_get_page_cgroup(page) != pc) {
> +		res_counter_uncharge(&to->res, PAGE_SIZE);
> +		goto out;
> +	}
> +
> +	if (spin_trylock(&to_mz->lru_lock)) {
> +		__mem_cgroup_remove_list(from_mz, pc);
> +		css_put(&from->css);
> +		res_counter_uncharge(&from->res, PAGE_SIZE);
> +		pc->mem_cgroup = to;
> +		css_get(&to->css);
> +		__mem_cgroup_add_list(to_mz, pc);
> +		ret = 0;
> +		spin_unlock(&to_mz->lru_lock);
> +	} else {
> +		res_counter_uncharge(&to->res, PAGE_SIZE);
> +	}
> +out:
> +	unlock_page_cgroup(page);
> +
> +	return ret;
> +}
> +
>  /*
>   * Charge the memory controller for page usage.
>   * Return
> @@ -752,16 +823,24 @@ __mem_cgroup_uncharge_common(struct page
>  	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
>  	    && ((PageCgroupCache(pc) || page_mapped(page))))
>  		goto unlock;
> -
> +retry:
> +	mem = pc->mem_cgroup;
>  	mz = page_cgroup_zoneinfo(pc);
>  	spin_lock_irqsave(&mz->lru_lock, flags);
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED &&
> +	    unlikely(mem != pc->mem_cgroup)) {
> +		/* MAPPED account can be done without lock_page().
> +		   Check race with mem_cgroup_move_account() */
> +		spin_unlock_irqrestore(&mz->lru_lock, flags);
> +		goto retry;
> +	}
>  	__mem_cgroup_remove_list(mz, pc);
>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>  
>  	page_assign_page_cgroup(page, NULL);
>  	unlock_page_cgroup(page);
>  
> -	mem = pc->mem_cgroup;
> +
>  	res_counter_uncharge(&mem->res, PAGE_SIZE);
>  	css_put(&mem->css);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
