Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EFC9B6B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 01:03:12 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n0961u6x016255
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 17:01:56 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n095x0d2925792
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:59:01 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n095w2Bn014469
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:58:03 +1100
Date: Fri, 9 Jan 2009 11:28:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/4] memcg: make oom less frequently
Message-ID: <20090109055804.GF9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:15:20]:

> In previous implementation, mem_cgroup_try_charge checked the return
> value of mem_cgroup_try_to_free_pages, and just retried if some pages
> had been reclaimed.
> But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> only checks whether the usage is less than the limit.
> 
> This patch tries to change the behavior as before to cause oom less frequently.
> 
> To prevent try_charge from getting stuck in infinite loop,
> MEM_CGROUP_RECLAIM_RETRIES_MAX is defined.
> 
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   16 ++++++++++++----
>  1 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 804c054..fedd76b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -42,6 +42,7 @@
> 
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
> +#define MEM_CGROUP_RECLAIM_RETRIES_MAX	32

Why 32 are you seeing frequent OOMs? I had 5 iterations to allow

1. pages to move to swap cache, which added back pressure to memcg in
the original implementation, since the pages came back
2. It look longer to move, recalim those pages.

Ideally 3 would suffice, but I added an additional 2 retries for
safety.

> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 0 */
> @@ -770,10 +771,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	 * but there might be left over accounting, even after children
>  	 * have left.
>  	 */
> -	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
> +	ret += try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
>  					   get_swappiness(root_mem));
>  	if (mem_cgroup_check_under_limit(root_mem))
> -		return 0;
> +		return 1;	/* indicate reclaim has succeeded */
>  	if (!root_mem->use_hierarchy)
>  		return ret;
> 
> @@ -785,10 +786,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  			next_mem = mem_cgroup_get_next_node(root_mem);
>  			continue;
>  		}
> -		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
> +		ret += try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
>  						   get_swappiness(next_mem));
>  		if (mem_cgroup_check_under_limit(root_mem))
> -			return 0;
> +			return 1;	/* indicate reclaim has succeeded */
>  		next_mem = mem_cgroup_get_next_node(root_mem);
>  	}
>  	return ret;
> @@ -820,6 +821,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  {
>  	struct mem_cgroup *mem, *mem_over_limit;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	int nr_retries_max = MEM_CGROUP_RECLAIM_RETRIES_MAX;
>  	struct res_counter *fail_res;
> 
>  	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
> @@ -871,8 +873,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
> 
> +		if (!nr_retries_max--)
> +			goto oom;
> +
>  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
>  							noswap);
> +		if (ret)
> +			continue;
> 
>  		/*
>  		 * try_to_free_mem_cgroup_pages() might not give us a full
> @@ -886,6 +893,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  			continue;
> 
>  		if (!nr_retries--) {
> +oom:
>  			if (oom) {
>  				mutex_lock(&memcg_tasklist);
>  				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
