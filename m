Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l99BALQx031899
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 21:10:21 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99BANvo737370
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 21:10:23 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99BA6Uh006697
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 21:10:07 +1000
Message-ID: <470B617C.1060504@linux.vnet.ibm.com>
Date: Tue, 09 Oct 2007 16:39:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [3/6]
 add helper function for page_cgroup
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com> <20071009185132.a870b0f0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009185132.a870b0f0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch adds follwoing functions.
>    - clear_page_cgroup(page, pc)
>    - page_cgroup_assign_new_page_group(page, pc)
> 
> Mainly for cleaunp.
> 
> A manner "check page->cgroup again after lock_page_cgroup()" is
> implemented in straight way.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> 
>  mm/memcontrol.c |   76 ++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 49 insertions(+), 27 deletions(-)
> 
> Index: devel-2.6.23-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> +++ devel-2.6.23-rc8-mm2/mm/memcontrol.c
> @@ -162,6 +162,35 @@ static void __always_inline unlock_page_
>  	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
>  }
> 
> +static inline int
> +page_cgroup_assign_new_page_cgroup(struct page *page, struct page_cgroup *pc)
> +{
> +	int ret = 0;
> +
> +	lock_page_cgroup(page);
> +	if (!page_get_page_cgroup(page))
> +		page_assign_page_cgroup(page, pc);
> +	else
> +		ret = 1;
> +	unlock_page_cgroup(page);
> +	return ret;
> +}
> +

Some comment on when the assignment can fail, for example if page
already has a page_cgroup associated with it, would be nice.

> +
> +static inline struct page_cgroup *
> +clear_page_cgroup(struct page *page, struct page_cgroup *pc)
> +{
> +	struct page_cgroup *ret;
> +	/* lock and clear */
> +	lock_page_cgroup(page);
> +	ret = page_get_page_cgroup(page);
> +	if (likely(ret == pc))
> +		page_assign_page_cgroup(page, NULL);
> +	unlock_page_cgroup(page);
> +	return ret;
> +}
> +

We could add a comment stating that clearing would fail if the page's
cgroup is not pc

> +
>  static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
>  {
>  	if (active)
> @@ -260,7 +289,7 @@ int mem_cgroup_charge(struct page *page,
>  				gfp_t gfp_mask)
>  {
>  	struct mem_cgroup *mem;
> -	struct page_cgroup *pc, *race_pc;
> +	struct page_cgroup *pc;
>  	unsigned long flags;
>  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> 
> @@ -353,24 +382,16 @@ noreclaim:
>  		goto free_pc;
>  	}
> 
> -	lock_page_cgroup(page);
> -	/*
> -	 * Check if somebody else beat us to allocating the page_cgroup
> -	 */
> -	race_pc = page_get_page_cgroup(page);
> -	if (race_pc) {
> -		kfree(pc);
> -		pc = race_pc;
> -		atomic_inc(&pc->ref_cnt);
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -		css_put(&mem->css);
> -		goto done;
> -	}
> -
>  	atomic_set(&pc->ref_cnt, 1);
>  	pc->mem_cgroup = mem;
>  	pc->page = page;
> -	page_assign_page_cgroup(page, pc);
> +	if (page_cgroup_assign_new_page_cgroup(page, pc)) {
> +		/* race ... undo and retry */
> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		css_put(&mem->css);
> +		kfree(pc);
> +		goto retry;

This part is a bit confusing, why do we want to retry. If someone
else charged the page already, we just continue, we let the other
task take the charge and add this page to it's cgroup

> +	}
> 
>  	spin_lock_irqsave(&mem->lru_lock, flags);
>  	list_add(&pc->lru, &mem->active_list);
> @@ -421,17 +442,18 @@ void mem_cgroup_uncharge(struct page_cgr
> 
>  	if (atomic_dec_and_test(&pc->ref_cnt)) {
>  		page = pc->page;
> -		lock_page_cgroup(page);
> -		mem = pc->mem_cgroup;
> -		css_put(&mem->css);
> -		page_assign_page_cgroup(page, NULL);
> -		unlock_page_cgroup(page);
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -
> - 		spin_lock_irqsave(&mem->lru_lock, flags);
> - 		list_del_init(&pc->lru);
> - 		spin_unlock_irqrestore(&mem->lru_lock, flags);
> -		kfree(pc);
> +		/*
> +		 * Obetaion page->cgroup and clear it under lock.
                   ^^^^^^^^
                   Not sure if I've come across this word before

> +		 */
> +		if (clear_page_cgroup(page, pc) == pc) {

OK.. so we've come so far and seen that pc has changed underneath us,
what do we do with this pc?

> +			mem = pc->mem_cgroup;
> +			css_put(&mem->css);
> +			res_counter_uncharge(&mem->res, PAGE_SIZE);
> +			spin_lock_irqsave(&mem->lru_lock, flags);
> +			list_del_init(&pc->lru);
> +			spin_unlock_irqrestore(&mem->lru_lock, flags);
> +			kfree(pc);
> +		}
>  	}
>  }
> 
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
