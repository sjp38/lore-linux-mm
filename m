Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE0188D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 23:49:46 -0500 (EST)
Date: Fri, 28 Jan 2011 13:40:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 12:24:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> and arrangement for THP is not enough yet.
> 
> This is one of fixes for supporing THP. This adds
> mem_cgroup_check_margin() and checks whether there are required amount of
> free resource after memory reclaim. By this, THP page allocation
> can know whether it really succeeded or not and avoid infinite-loop
> and hangup.
> 
> Total fixes for do_charge()/reclaim memory will follow this patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch looks good to me, but some nitpicks.

> ---
>  include/linux/res_counter.h |   11 +++++++++++
>  mm/memcontrol.c             |   25 ++++++++++++++++++++++++-
>  2 files changed, 35 insertions(+), 1 deletion(-)
> 
> Index: mmotm-0125/include/linux/res_counter.h
> ===================================================================
> --- mmotm-0125.orig/include/linux/res_counter.h
> +++ mmotm-0125/include/linux/res_counter.h
> @@ -182,6 +182,17 @@ static inline bool res_counter_check_und
>  	return ret;
>  }
>  
> +static inline s64 res_counter_check_margin(struct res_counter *cnt)
> +{
> +	s64 ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = cnt->limit - cnt->usage;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}
> +
>  static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
>  {
>  	bool ret;
> Index: mmotm-0125/mm/memcontrol.c
> ===================================================================
> --- mmotm-0125.orig/mm/memcontrol.c
> +++ mmotm-0125/mm/memcontrol.c
> @@ -1111,6 +1111,22 @@ static bool mem_cgroup_check_under_limit
>  	return false;
>  }
>  
> +static s64  mem_cgroup_check_margin(struct mem_cgroup *mem)
> +{
> +	s64 mem_margin;
> +
> +	if (do_swap_account) {
> +		s64 memsw_margin;
> +
> +		mem_margin = res_counter_check_margin(&mem->res);
> +		memsw_margin = res_counter_check_margin(&mem->memsw);
> +		if (mem_margin > memsw_margin)
> +			mem_margin = memsw_margin;
> +	} else
> +		mem_margin = res_counter_check_margin(&mem->res);
> +	return mem_margin;
> +}
> +
How about

	mem_margin = res_counter_check_margin(&mem->res);
	if (do_swap_account)
		memsw_margin = res_counter_check_margin(&mem->memsw);
	else
		memsw_margin = RESOURCE_MAX;

	return min(mem_margin, memsw_margin);

?
I think using min() makes it more clear what this function does.

>  static unsigned int get_swappiness(struct mem_cgroup *memcg)
>  {
>  	struct cgroup *cgrp = memcg->css.cgroup;
> @@ -1853,7 +1869,14 @@ static int __mem_cgroup_do_charge(struct
>  	 * Check the limit again to see if the reclaim reduced the
>  	 * current usage of the cgroup before giving up
>  	 */
> -	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
> +	if (mem_cgroup_check_margin(mem_over_limit) >= csize)
> +		return CHARGE_RETRY;
> +
> +	/*
> + 	 * If the charge size is a PAGE_SIZE, it's not hopeless while
> + 	 * we can reclaim a page.
> + 	 */
> +	if (csize == PAGE_SIZE && ret)
>  		return CHARGE_RETRY;
>  
>  	/*
> 
checkpatch complains some whitespace warnings.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
