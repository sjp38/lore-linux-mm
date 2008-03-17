Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2H1lSqX004509
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 07:17:28 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2H1lRaW1183826
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 07:17:28 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2H1lRFG010308
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 01:47:27 GMT
Date: Mon, 17 Mar 2008 07:16:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/7] charge/uncharge
Message-ID: <20080317014601.GB24473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:06:22]:

> Because bit spin lock is removed and spinlock is added to page_cgroup.
> There are some amount of changes.
> 
> This patch does
> 	- modify charge/uncharge to adjust it to the new lock.
> 	- Added simple lock rule comments.
> 
> Major changes from current(-mm) version is
> 	- pc->refcnt is set as "1" after the charge is done.
> 
> Changelog
>   - Rebased to rc5-mm1
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>

Hi, KAMEZAWA-San,

The build continues to be broken, even after this patch is applied.
We will have to find another way to refactor the code, so that we
don't break git-bisect.
 
> 
>  mm/memcontrol.c |  136 +++++++++++++++++++++++++-------------------------------
>  1 file changed, 62 insertions(+), 74 deletions(-)
> 
> Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> @@ -34,6 +34,16 @@
> 
>  #include <asm/uaccess.h>
> 
> +/*
> + * Lock Rule
> + * zone->lru_lcok (global LRU)
> + *	-> pc->lock (page_cgroup's lock)
> + *		-> mz->lru_lock (mem_cgroup's per_zone lock.)
> + *
> + * At least, mz->lru_lock and pc->lock should be acquired irq off.
> + *
> + */
> +

I think the rule applies to even the zone's lru_lock, so we could just
state that these two locks should be acquired with irq's off.

>  struct cgroup_subsys mem_cgroup_subsys;
>  static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
> 
> @@ -479,33 +489,22 @@ static int mem_cgroup_charge_common(stru
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
> 
> +	pc = get_page_cgroup(page, gfp_mask, true);
> +	if (!pc || IS_ERR(pc))
> +		return PTR_ERR(pc);
> +
> +	spin_lock_irqsave(&pc->lock, flags);
>  	/*
> -	 * Should page_cgroup's go to their own slab?
> -	 * One could optimize the performance of the charging routine
> -	 * by saving a bit in the page_flags and using it as a lock
> -	 * to see if the cgroup page already has a page_cgroup associated
> -	 * with it
> -	 */
> -retry:
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> -	/*
> -	 * The page_cgroup exists and
> -	 * the page has already been accounted.
> +	 * Has the page already been accounted ?
>  	 */
> -	if (pc) {
> -		VM_BUG_ON(pc->page != page);
> -		VM_BUG_ON(pc->ref_cnt <= 0);
> -
> -		pc->ref_cnt++;
> -		unlock_page_cgroup(page);
> -		goto done;
> +	if (pc->refcnt > 0) {
> +		pc->refcnt++;
> +		spin_unlock_irqrestore(&pc->lock, flags);
> +		goto success;
>  	}
> -	unlock_page_cgroup(page);
> +	spin_unlock_irqrestore(&pc->lock, flags);
> 
> -	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
> -	if (pc == NULL)
> -		goto err;
> +	/* Note: pc->refcnt is still 0 here. */
>

I think the comment can be updated to say for new pc's the refcnt is
0.
 
>  	/*
>  	 * We always charge the cgroup the mm_struct belongs to.
> @@ -526,7 +525,7 @@ retry:
> 
>  	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
>  		if (!(gfp_mask & __GFP_WAIT))
> -			goto out;
> +			goto nomem;
> 
>  		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
>  			continue;
> @@ -543,45 +542,40 @@ retry:
> 
>  		if (!nr_retries--) {
>  			mem_cgroup_out_of_memory(mem, gfp_mask);
> -			goto out;
> +			goto nomem;
>  		}
>  		congestion_wait(WRITE, HZ/10);
>  	}
> -
> -	pc->ref_cnt = 1;
> +	/*
> + 	 * We have to acquire 2 spinlocks.
> +	 */
> +	spin_lock_irqsave(&pc->lock, flags);
> +	if (pc->refcnt) {
> +		/* Someone charged this page while we released the lock */
> +		++pc->refcnt;

We used pc->refcnt++ earlier, for consistency we could use that here
as well.

> +		spin_unlock_irqrestore(&pc->lock, flags);
> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		css_put(&mem->css);
> +		goto success;
> +	}
> +	/* Anyone doesn't touch this. */
> +	VM_BUG_ON(pc->mem_cgroup);
> +	VM_BUG_ON(!list_empty(&pc->lru));
> +	pc->refcnt = 1;
>  	pc->mem_cgroup = mem;
> -	pc->page = page;
>  	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
>  		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
> -
> -	lock_page_cgroup(page);
> -	if (page_get_page_cgroup(page)) {
> -		unlock_page_cgroup(page);
> -		/*
> -		 * Another charge has been added to this page already.
> -		 * We take lock_page_cgroup(page) again and read
> -		 * page->cgroup, increment refcnt.... just retry is OK.
> -		 */
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -		css_put(&mem->css);
> -		kfree(pc);
> -		goto retry;
> -	}
> -	page_assign_page_cgroup(page, pc);
> -
>  	mz = page_cgroup_zoneinfo(pc);
> -	spin_lock_irqsave(&mz->lru_lock, flags);
> +	spin_lock(&mz->lru_lock);
>  	__mem_cgroup_add_list(pc);
> -	spin_unlock_irqrestore(&mz->lru_lock, flags);
> +	spin_unlock(&mz->lru_lock);
> +	spin_unlock_irqrestore(&pc->lock, flags);
> 
> -	unlock_page_cgroup(page);
> -done:
> +success:
>  	return 0;
> -out:
> +nomem:
>  	css_put(&mem->css);
> -	kfree(pc);
> -err:
>  	return -ENOMEM;
>  }
> 
> @@ -617,33 +611,27 @@ void mem_cgroup_uncharge_page(struct pag
>  	/*
>  	 * Check if our page_cgroup is valid
>  	 */
> -	lock_page_cgroup(page);
> -	pc = page_get_page_cgroup(page);
> +	pc = get_page_cgroup(page, GFP_ATOMIC, false); /* No allocation */
>  	if (!pc)
> -		goto unlock;
> -
> -	VM_BUG_ON(pc->page != page);
> -	VM_BUG_ON(pc->ref_cnt <= 0);
> -
> -	if (--(pc->ref_cnt) == 0) {
> -		mz = page_cgroup_zoneinfo(pc);
> -		spin_lock_irqsave(&mz->lru_lock, flags);
> -		__mem_cgroup_remove_list(pc);
> -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> -
> -		page_assign_page_cgroup(page, NULL);
> -		unlock_page_cgroup(page);
> -
> -		mem = pc->mem_cgroup;
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -		css_put(&mem->css);
> -
> -		kfree(pc);
> +		return;
> +	spin_lock_irqsave(&pc->lock, flags);
> +	if (!pc->refcnt || --pc->refcnt > 0) {
> +		spin_unlock_irqrestore(&pc->lock, flags);
>  		return;
>  	}
> +	VM_BUG_ON(pc->page != page);
> +	mz = page_cgroup_zoneinfo(pc);
> +	mem = pc->mem_cgroup;
> 
> -unlock:
> -	unlock_page_cgroup(page);
> +	spin_lock(&mz->lru_lock);
> +	__mem_cgroup_remove_list(pc);
> +	spin_unlock(&mz->lru_lock);
> +
> +	pc->flags = 0;
> +	pc->mem_cgroup = 0;
> +	res_counter_uncharge(&mem->res, PAGE_SIZE);
> +	css_put(&mem->css);
> +	spin_unlock_irqrestore(&pc->lock, flags);
>  }
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
