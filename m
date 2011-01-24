Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 841866B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 05:04:42 -0500 (EST)
Date: Mon, 24 Jan 2011 11:04:34 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/7] memcg : fix mem_cgroup_check_under_limit
Message-ID: <20110124100434.GS2232@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110121154141.680c96d9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110121154141.680c96d9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 03:41:41PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> but THP does HPAGE_SIZE charge.
> 
> This is one of fixes for supporing THP. This modifies
> mem_cgroup_check_under_limit to take page_size into account.
> 
> Total fixes for do_charge()/reclaim memory will follow this patch.
> 
> TODO: By this reclaim function can get page_size as argument.
> So...there may be something should be improvoed.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/res_counter.h |   11 +++++++++++
>  mm/memcontrol.c             |   27 ++++++++++++++-------------
>  2 files changed, 25 insertions(+), 13 deletions(-)
> 
> Index: mmotm-0107/include/linux/res_counter.h
> ===================================================================
> --- mmotm-0107.orig/include/linux/res_counter.h
> +++ mmotm-0107/include/linux/res_counter.h
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
> Index: mmotm-0107/mm/memcontrol.c
> ===================================================================
> --- mmotm-0107.orig/mm/memcontrol.c
> +++ mmotm-0107/mm/memcontrol.c
> @@ -1099,14 +1099,14 @@ unsigned long mem_cgroup_isolate_pages(u
>  #define mem_cgroup_from_res_counter(counter, member)	\
>  	container_of(counter, struct mem_cgroup, member)
>  
> -static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
> +static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem, int page_size)
>  {
>  	if (do_swap_account) {
> -		if (res_counter_check_under_limit(&mem->res) &&
> -			res_counter_check_under_limit(&mem->memsw))
> +		if (res_counter_check_margin(&mem->res) >= page_size &&
> +			res_counter_check_margin(&mem->memsw) >= page_size)
>  			return true;
>  	} else
> -		if (res_counter_check_under_limit(&mem->res))
> +		if (res_counter_check_margin(&mem->res) >= page_size)
>  			return true;
>  	return false;
>  }
> @@ -1367,7 +1367,8 @@ mem_cgroup_select_victim(struct mem_cgro
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  						struct zone *zone,
>  						gfp_t gfp_mask,
> -						unsigned long reclaim_options)
> +						unsigned long reclaim_options,
> +						int page_size)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
> @@ -1434,7 +1435,7 @@ static int mem_cgroup_hierarchical_recla
>  		if (check_soft) {
>  			if (res_counter_check_under_soft_limit(&root_mem->res))
>  				return total;
> -		} else if (mem_cgroup_check_under_limit(root_mem))
> +		} else if (mem_cgroup_check_under_limit(root_mem, page_size))
>  			return 1 + total;
>  	}
>  	return total;
> @@ -1844,7 +1845,7 @@ static int __mem_cgroup_do_charge(struct
>  		return CHARGE_WOULDBLOCK;
>  
>  	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -					gfp_mask, flags);
> +					gfp_mask, flags, csize);
>  	/*
>  	 * try_to_free_mem_cgroup_pages() might not give us a full
>  	 * picture of reclaim. Some pages are reclaimed and might be
> @@ -1852,7 +1853,7 @@ static int __mem_cgroup_do_charge(struct
>  	 * Check the limit again to see if the reclaim reduced the
>  	 * current usage of the cgroup before giving up
>  	 */
> -	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
> +	if (ret || mem_cgroup_check_under_limit(mem_over_limit, csize))
>  		return CHARGE_RETRY;

This is the only site that is really involved with THP.  But you need
to touch every site because you change mem_cgroup_check_under_limit()
instead of adding a new function.

I would suggest just adding another function for checking available
space explicitely and only changing this single call site to use it.

Just ignore the return value of mem_cgroup_hierarchical_reclaim() and
check for enough space unconditionally.

Everybody else is happy with PAGE_SIZE pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
