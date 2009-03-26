Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 589286B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 01:08:57 -0400 (EDT)
Date: Thu, 26 Mar 2009 14:51:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326145148.ba722e1e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
	<20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 14:12:46 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 26 Mar 2009 13:08:21 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This is another bug I've working on recently.
> > 
> > I want this (and the stale swapcache problem) to be fixed for 2.6.30.
> > 
> > Any comments?
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > Current mem_cgroup_shrink_usage has two problems.
> > 
> > 1. It doesn't call mem_cgroup_out_of_memory and doesn't update last_oom_jiffies,
> >    so pagefault_out_of_memory invokes global OOM.
> > 2. Considering hierarchy, shrinking has to be done from the mem_over_limit,
> >    not from the memcg where the page to be charged to.
> > 
> 
> Ah, i see. good cacth. 
> But it seems to be the patch is a bit big and includes duplications.
> Can't we divide this patch into 2 and reduce modification ?
> 
Will do if needed.
(returning mem_over_limit part and implementing
add_to_page_cache_store_memcg part, perhaps)

> mem_cgroup_shrink_usage() should do something proper...
> My brief thinking is a patch like this, how do you think ?
> 
I thought the same direction at first.
But it's similar to the old implementation before c9b0ed51 conceptually,
so I chose a new direction.

I withdraw my patch if you prefer this direction :)

> Maybe renaming this function is appropriate...
I think so too if we go in this direction.

Just a few comments below.

> ==
> mem_cgroup_shrink_usage() is called by shmem, but its purpose is
> not different from try_charge().
> 
> In current behavior, it ignores upward hierarchy and doesn't update
> OOM status of memcg. That's bad. We can simply call try_charge()
> and drop charge later.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> Index: test/mm/memcontrol.c
> ===================================================================
> --- test.orig/mm/memcontrol.c
> +++ test/mm/memcontrol.c
> @@ -1655,16 +1655,16 @@ int mem_cgroup_shrink_usage(struct page 
>  	if (unlikely(!mem))
>  		return 0;
>  
> -	do {
> -		progress = mem_cgroup_hierarchical_reclaim(mem,
> -					gfp_mask, true, false);
> -		progress += mem_cgroup_check_under_limit(mem);
> -	} while (!progress && --retry);
> +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, mem, true);
>  
I think we should simply call mem_cgroup_try_charge_swapin() w/o doing try_get.

> +	if (!ret) {
> +		css_put(&mem->css); /* refcnt by charge *//
It should be done after res_counter_uncharge().

> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		if (do_swap_account)
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +	}
>  	css_put(&mem->css);
This put isn't needed if we don't try_get.

> -	if (!retry)
> -		return -ENOMEM;
> -	return 0;
> +	return ret;
>  }
>  
>  static DEFINE_MUTEX(set_limit_mutex);
> 

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
