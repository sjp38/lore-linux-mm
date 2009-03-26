Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 130C06B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 01:12:37 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2Q60tIG017991
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 17:00:55 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2Q61Dxg999604
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 17:01:13 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2Q60tch012403
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 17:00:55 +1100
Date: Thu, 26 Mar 2009 11:30:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-ID: <20090326060028.GA24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp> <20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-26 14:12:46]:

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
> mem_cgroup_shrink_usage() should do something proper...
> My brief thinking is a patch like this, how do you think ?
> 
> Maybe renaming this function is appropriate...
> ==
> mem_cgroup_shrink_usage() is called by shmem, but its purpose is
> not different from try_charge().
> 
> In current behavior, it ignores upward hierarchy and doesn't update
> OOM status of memcg. That's bad. We can simply call try_charge()
> and drop charge later.
>

This seems much better than the original patch from Daisuke, which
added too much code and changes, hard to review for correctness and
changes outside of memcontrol.c make it more risky.
 
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

Could you please add a comment/changelog to indicate why we try to
charge when we want to shrink? Is the limit setup so that a try_charge
will cause reclaim, BTW?
 
> +	if (!ret) {
> +		css_put(&mem->css); /* refcnt by charge *//

Does this compile?

> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		if (do_swap_account)
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +	}
>  	css_put(&mem->css);
> -	if (!retry)
> -		return -ENOMEM;
> -	return 0;
> +	return ret;
>  }
> 
>  static DEFINE_MUTEX(set_limit_mutex);
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
