Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 747D16B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 05:00:37 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Apr 2012 09:49:23 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3U8rVEb2056256
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 18:53:33 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3U90LC6013817
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 19:00:22 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in move_parent
In-Reply-To: <4F9A34B2.8080103@jp.fujitsu.com>
References: <4F9A327A.6050409@jp.fujitsu.com> <4F9A34B2.8080103@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Mon, 30 Apr 2012 14:30:10 +0530
Message-ID: <87vckh8uhx.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> By using res_counter_uncharge_until(), we can avoid 
> unnecessary charging.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> ---
>  mm/memcontrol.c |   63 ++++++++++++++++++++++++++++++++++++------------------
>  1 files changed, 42 insertions(+), 21 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 613bb15..ed53d64 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2420,6 +2420,24 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>  }
>
>  /*
> + * Cancel chages in this cgroup....doesn't propagates to parent cgroup.
> + * This is useful when moving usage to parent cgroup.
> + */
> +static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
> +					unsigned int nr_pages)
> +{
> +	if (!mem_cgroup_is_root(memcg)) {
> +		unsigned long bytes = nr_pages * PAGE_SIZE;
> +
> +		res_counter_uncharge_until(&memcg->res,
> +					memcg->res.parent, bytes);
> +		if (do_swap_account)
> +			res_counter_uncharge_until(&memcg->memsw,
> +						memcg->memsw.parent, bytes);
> +	}
> +}
> +
> +/*
>   * A helper function to get mem_cgroup from ID. must be called under
>   * rcu_read_lock(). The caller must check css_is_removed() or some if
>   * it's concern. (dropping refcnt from swap can be called against removed
> @@ -2677,16 +2695,28 @@ static int mem_cgroup_move_parent(struct page *page,
>  	nr_pages = hpage_nr_pages(page);
>
>  	parent = mem_cgroup_from_cont(pcg);
> -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &parent, false);
> -	if (ret)
> -		goto put_back;
> +	if (!parent->use_hierarchy) {
> +		ret = __mem_cgroup_try_charge(NULL,
> +					gfp_mask, nr_pages, &parent, false);
> +		if (ret)
> +			goto put_back;
> +	}
>
>  	if (nr_pages > 1)
>  		flags = compound_lock_irqsave(page);
>
> -	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent, true);
> -	if (ret)
> -		__mem_cgroup_cancel_charge(parent, nr_pages);
> +	if (parent->use_hierarchy) {
> +		ret = mem_cgroup_move_account(page, nr_pages,
> +					pc, child, parent, false);
> +		if (!ret)
> +			__mem_cgroup_cancel_local_charge(child, nr_pages);
> +	} else {
> +		ret = mem_cgroup_move_account(page, nr_pages,
> +					pc, child, parent, true);
> +
> +		if (ret)
> +			__mem_cgroup_cancel_charge(parent, nr_pages);
> +	}
>

May be a comment around this ? I had to look closer to find why
there is a if (!ret) and if (ret) difference. 


>  	if (nr_pages > 1)
>  		compound_unlock_irqrestore(page, flags);
> @@ -3295,6 +3325,7 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
>  	struct cgroup *pcgrp = cgroup->parent;
>  	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
>  	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
> +	struct res_counter *counter;
>
>  	if (!get_page_unless_zero(page))
>  		goto out;
> @@ -3305,28 +3336,18 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
>  		goto err_out;
>
>  	csize = PAGE_SIZE << compound_order(page);
> -	/*
> -	 * If we have use_hierarchy set we can never fail here. So instead of
> -	 * using res_counter_uncharge use the open-coded variant which just
> -	 * uncharge the child res_counter. The parent will retain the charge.
> -	 */
> -	if (parent->use_hierarchy) {
> -		unsigned long flags;
> -		struct res_counter *counter;
> -
> -		counter = &memcg->hugepage[idx];
> -		spin_lock_irqsave(&counter->lock, flags);
> -		res_counter_uncharge_locked(counter, csize);
> -		spin_unlock_irqrestore(&counter->lock, flags);
> -	} else {
> +	/* If parent->use_hierarchy == 0, we need to charge parent */
> +	if (!parent->use_hierarchy) {
>  		ret = res_counter_charge(&parent->hugepage[idx],
>  					 csize, &fail_res);
>  		if (ret) {
>  			ret = -EBUSY;
>  			goto err_out;
>  		}
> -		res_counter_uncharge(&memcg->hugepage[idx], csize);
>  	}
> +	counter = &memcg->hugepage[idx];
> +	res_counter_uncharge_until(counter, counter->parent, csize);
> +
>  	pc->mem_cgroup = parent;
>  err_out:
>  	unlock_page_cgroup(pc);

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
