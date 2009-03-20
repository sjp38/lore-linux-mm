Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 580E56B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 23:48:09 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2K3m5WO002582
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Mar 2009 12:48:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B48F645DE52
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99EFA45DE51
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 786B81DB8040
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D7F11DB8037
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:05 +0900 (JST)
Date: Fri, 20 Mar 2009 12:46:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090319165735.27274.96091.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 22:27:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Organize cgroups over soft limit in a RB-Tree
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v7...v6
> 1. Refactor the check and update logic. The goal is to allow the
>    check logic to be modular, so that it can be revisited in the future
>    if something more appropriate is found to be useful.
> 
One of my motivation to this was "reducing if" in res_counter charege...
But ..plz see comment.

> Changelog v6...v5
> 1. Update the key before inserting into RB tree. Without the current change
>    it could take an additional iteration to get the key correct.
> 
> Changelog v5...v4
> 1. res_counter_uncharge has an additional parameter to indicate if the
>    counter was over its soft limit, before uncharge.
> 
> Changelog v4...v3
> 1. Optimizations to ensure we don't uncessarily get res_counter values
> 2. Fixed a bug in usage of time_after()
> 
> Changelog v3...v2
> 1. Add only the ancestor to the RB-Tree
> 2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put
> 
> Changelog v2...v1
> 1. Add support for hierarchies
> 2. The res_counter that is highest in the hierarchy is returned on soft
>    limit being exceeded. Since we do hierarchical reclaim and add all
>    groups exceeding their soft limits, this approach seems to work well
>    in practice.
> 
> This patch introduces a RB-Tree for storing memory cgroups that are over their
> soft limit. The overall goal is to
> 
> 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
>    We are careful about updates, updates take place only after a particular
>    time interval has passed
> 2. We remove the node from the RB-Tree when the usage goes below the soft
>    limit
> 
> The next set of patches will exploit the RB-Tree to get the group that is
> over its soft limit by the largest amount and reclaim from it, when we
> face memory contention.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/res_counter.h |    6 +-
>  kernel/res_counter.c        |   18 +++++
>  mm/memcontrol.c             |  149 ++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 151 insertions(+), 22 deletions(-)
> 
> 
> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> index 5c821fd..5bbf8b1 100644
> --- a/include/linux/res_counter.h
> +++ b/include/linux/res_counter.h
> @@ -112,7 +112,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
>  int __must_check res_counter_charge_locked(struct res_counter *counter,
>  		unsigned long val);
>  int __must_check res_counter_charge(struct res_counter *counter,
> -		unsigned long val, struct res_counter **limit_fail_at);
> +		unsigned long val, struct res_counter **limit_fail_at,
> +		struct res_counter **soft_limit_at);
>  
>  /*
>   * uncharge - tell that some portion of the resource is released
> @@ -125,7 +126,8 @@ int __must_check res_counter_charge(struct res_counter *counter,
>   */
>  
>  void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
> -void res_counter_uncharge(struct res_counter *counter, unsigned long val);
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> +				bool *was_soft_limit_excess);
>  
>  static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
>  {
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 4e6dafe..51ec438 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -37,17 +37,27 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  }
>  
>  int res_counter_charge(struct res_counter *counter, unsigned long val,
> -			struct res_counter **limit_fail_at)
> +			struct res_counter **limit_fail_at,
> +			struct res_counter **soft_limit_fail_at)
>  {
>  	int ret;
>  	unsigned long flags;
>  	struct res_counter *c, *u;
>  
>  	*limit_fail_at = NULL;
> +	if (soft_limit_fail_at)
> +		*soft_limit_fail_at = NULL;
>  	local_irq_save(flags);
>  	for (c = counter; c != NULL; c = c->parent) {
>  		spin_lock(&c->lock);
>  		ret = res_counter_charge_locked(c, val);
> +		/*
> +		 * With soft limits, we return the highest ancestor
> +		 * that exceeds its soft limit
> +		 */
> +		if (soft_limit_fail_at &&
> +			!res_counter_soft_limit_check_locked(c))
> +			*soft_limit_fail_at = c;

Is this correct way to go ? In following situation,

     A/       softlimit=1G usage=1.2G
       B1/     sfotlimit=400M usage=1G
         C/
       B2/    softlimit=400M usage=200M

"A" will be victim and both of B1 and B2 will be reclaim target, right ?

and I wonder we don't need *softlimit_failed_at*... here.

<snip>


> +static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem,
> +					bool over_soft_limit)
> +{
> +	unsigned long next_update;
> +
> +	if (!over_soft_limit)
> +		return false;
> +
> +	next_update = mem->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
> +	if (time_after(jiffies, next_update))
> +		return true;
> +
> +	return false;
> +}

If I write, this function will be

static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem, struct res_counter *failed_at)
{
	next_update = mem->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
	if (!time_after(jiffies, next_update))
		return true;
	/* check softlimit */
        for (c = &mem->res; !c; c= c->parent) {
		if (!res_counter_check_under_soft_limit(c)) {
			failed_at =c;
		}
	}
	return false;
}


	/*
	 * Insert just the ancestor, we should trickle down to the correct
	 * cgroup for reclaim, since the other nodes will be below their
	 * soft limit
	 */
        if (mem_cgroup_soft_limit_check(mem, &soft_fail_res)) {
		mem_over_soft_limit =
			mem_cgroup_from_res_counter(soft_fail_res, res);
		mem_cgroup_update_tree(mem_over_soft_limit);
	}

Then, we really do softlimit check once in interval.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
