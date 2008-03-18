Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2IGkP7l027002
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 22:16:25 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2IGkPdu1028216
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 22:16:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2IGkO8N013828
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 16:46:25 GMT
Date: Tue, 18 Mar 2008 22:14:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/7] memcg: move_lists
Message-ID: <20080318164437.GC24473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314190731.b3635ae9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080314190731.b3635ae9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:07:31]:

> Modifies mem_cgroup_move_lists() to use get_page_cgroup().
> No major algorithm changes just adjusted to new locks.
> 
> Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/memcontrol.c |   16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> Index: mm-2.6.25-rc5-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-rc5-mm1/mm/memcontrol.c
> @@ -309,6 +309,10 @@ void mem_cgroup_move_lists(struct page *
>  	struct mem_cgroup_per_zone *mz;
>  	unsigned long flags;
> 
> +	/* This GFP will be ignored..*/
> +	pc = get_page_cgroup(page, GFP_ATOMIC, false);
> +	if (!pc)
> +		return;

Splitting get_page_cgroup will help avoid thse kinds of hacks. Please
see my earlier comment.

>  	/*
>  	 * We cannot lock_page_cgroup while holding zone's lru_lock,
>  	 * because other holders of lock_page_cgroup can be interrupted
> @@ -316,17 +320,15 @@ void mem_cgroup_move_lists(struct page *
>  	 * safely get to page_cgroup without it, so just try_lock it:
>  	 * mem_cgroup_isolate_pages allows for page left on wrong list.
>  	 */
> -	if (!try_lock_page_cgroup(page))
> +	if (!spin_trylock_irqsave(&pc->lock, flags))
>  		return;
> -
> -	pc = page_get_page_cgroup(page);
> -	if (pc) {
> +	if (pc->refcnt) {
>  		mz = page_cgroup_zoneinfo(pc);
> -		spin_lock_irqsave(&mz->lru_lock, flags);
> +		spin_lock(&mz->lru_lock);
>  		__mem_cgroup_move_lists(pc, active);
> -		spin_unlock_irqrestore(&mz->lru_lock, flags);
> +		spin_unlock(&mz->lru_lock);
>  	}
> -	unlock_page_cgroup(page);
> +	spin_unlock_irqrestore(&pc->lock, flags);
>  }
> 
>  /*
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
