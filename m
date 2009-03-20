Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 951026B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 23:55:25 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2K3mhrq002861
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Mar 2009 12:48:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8FC845DE50
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4D8945DE4F
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89A3CE08002
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37CA21DB803A
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:48:42 +0900 (JST)
Date: Fri, 20 Mar 2009 12:47:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] Memory controller soft limit refactor reclaim flags
 (v7)
Message-Id: <20090320124717.8c5da82e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090319165744.27274.6335.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165744.27274.6335.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 22:27:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Impact: Refactor mem_cgroup_hierarchical_reclaim()
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> This patch refactors the arguments passed to
> mem_cgroup_hierarchical_reclaim() into flags, so that new parameters don't
> have to be passed as we make the reclaim routine more flexible
> 
seems nice :)

Thanks,
-Kame

> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |   27 ++++++++++++++++++++-------
>  1 files changed, 20 insertions(+), 7 deletions(-)
> 
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f5b61b8..992aac8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -227,6 +227,14 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>  #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
>  #define MEMFILE_ATTR(val)	((val) & 0xffff)
>  
> +/*
> + * Reclaim flags for mem_cgroup_hierarchical_reclaim
> + */
> +#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
> +#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
> +#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
> +#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
> +
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> @@ -889,11 +897,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>   * If shrink==true, for avoiding to free too much, this returns immedieately.
>   */
>  static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> -				   gfp_t gfp_mask, bool noswap, bool shrink)
> +						gfp_t gfp_mask,
> +						unsigned long reclaim_options)
>  {
>  	struct mem_cgroup *victim;
>  	int ret, total = 0;
>  	int loop = 0;
> +	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
> +	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>  
>  	while (loop < 2) {
>  		victim = mem_cgroup_select_victim(root_mem);
> @@ -1029,7 +1040,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  
>  	while (1) {
>  		int ret;
> -		bool noswap = false;
> +		unsigned long flags = 0;
>  
>  		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
>  						&soft_fail_res);
> @@ -1042,7 +1053,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  				break;
>  			/* mem+swap counter fails */
>  			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> -			noswap = true;
> +			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
>  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
>  									memsw);
>  		} else
> @@ -1054,7 +1065,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  			goto nomem;
>  
>  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> -							noswap, false);
> +							flags);
>  		if (ret)
>  			continue;
>  
> @@ -1766,7 +1777,7 @@ int mem_cgroup_shrink_usage(struct page *page,
>  
>  	do {
>  		progress = mem_cgroup_hierarchical_reclaim(mem,
> -					gfp_mask, true, false);
> +					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
>  		progress += mem_cgroup_check_under_limit(mem);
>  	} while (!progress && --retry);
>  
> @@ -1821,7 +1832,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  			break;
>  
>  		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> -						   false, true);
> +						   MEM_CGROUP_RECLAIM_SHRINK);
>  		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
>  		/* Usage is reduced ? */
>    		if (curusage >= oldusage)
> @@ -1869,7 +1880,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
> +		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> +						MEM_CGROUP_RECLAIM_NOSWAP |
> +						MEM_CGROUP_RECLAIM_SHRINK);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		/* Usage is reduced ? */
>  		if (curusage >= oldusage)
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
