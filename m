Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4RGCWLT008298
	for <linux-mm@kvack.org>; Wed, 28 May 2008 02:12:32 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RGGhUA257644
	for <linux-mm@kvack.org>; Wed, 28 May 2008 02:16:43 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RGCXie020412
	for <linux-mm@kvack.org>; Wed, 28 May 2008 02:12:34 +1000
Message-ID: <483C32AE.1020908@linux.vnet.ibm.com>
Date: Tue, 27 May 2008 21:41:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 1/4] memcg: drop pages at rmdir (v1)
References: <20080527140116.fb04b06b.kamezawa.hiroyu@jp.fujitsu.com> <20080527140533.b4b6f73f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080527140533.b4b6f73f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Now, when we remove memcg, we call force_empty().
> This call drops all page_cgroup accounting in this mem_cgroup but doesn't
> drop pages. So, some page caches can be remaind as "not accounted" memory
> while they are alive. (because it's accounted only when add_to_page_cache())
> If they are not used by other memcg, global LRU will drop them.
> 
> This patch tries to drop pages at removing memcg. Other memcg will
> reload and re-account page caches. (but this will increase page-in
> after rmdir().)
> 

The approach seems fair, but I am not sure about the overhead of flushing out
cached pages. Might well be worth it.

> Consideration: should we recharge all pages to the parent at last ?
>                But it's not precise logic.
> 

We should look into this - I should send out the multi-hierarchy patches soon.
We should discuss this after that.

> Changelog v1->v2
>  - renamed res_counter_empty().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/res_counter.h |   11 +++++++++++
>  mm/memcontrol.c             |   19 +++++++++++++++++++
>  2 files changed, 30 insertions(+)
> 
> Index: mm-2.6.26-rc2-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.26-rc2-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.26-rc2-mm1/mm/memcontrol.c
> @@ -791,6 +791,20 @@ int mem_cgroup_shrink_usage(struct mm_st
>  	return 0;
>  }
> 
> +
> +static void mem_cgroup_drop_all_pages(struct mem_cgroup *mem)
> +{
> +	int progress;
> +	while (!res_counter_empty(&mem->res)) {
> +		progress = try_to_free_mem_cgroup_pages(mem,
> +					GFP_HIGHUSER_MOVABLE);
> +		if (!progress) /* we did as much as possible */
> +			break;
> +		cond_resched();
> +	}
> +	return;
> +}
> +
>  /*
>   * This routine traverse page_cgroup in given list and drop them all.
>   * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
> @@ -848,7 +862,12 @@ static int mem_cgroup_force_empty(struct
>  	if (mem_cgroup_subsys.disabled)
>  		return 0;
> 
> +	if (atomic_read(&mem->css.cgroup->count) > 0)
> +		goto out;
> +
>  	css_get(&mem->css);
> +	/* drop pages as much as possible */
> +	mem_cgroup_drop_all_pages(mem);
>  	/*
>  	 * page reclaim code (kswapd etc..) will move pages between
>  	 * active_list <-> inactive_list while we don't take a lock.
> Index: mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> ===================================================================
> --- mm-2.6.26-rc2-mm1.orig/include/linux/res_counter.h
> +++ mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> @@ -153,4 +153,15 @@ static inline void res_counter_reset_fai
>  	cnt->failcnt = 0;
>  	spin_unlock_irqrestore(&cnt->lock, flags);
>  }
> +/* returns 0 if usage is 0. */
> +static inline int res_counter_empty(struct res_counter *cnt)
> +{
> +	unsigned long flags;
> +	int ret;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = (cnt->usage == 0) ? 0 : 1;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
>  #endif
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
