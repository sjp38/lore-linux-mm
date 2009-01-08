Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D88E26B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 06:19:54 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n08BJqdI023282
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 20:19:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AFCFE45DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:19:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9552245DD72
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:19:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 746061DB8037
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:19:52 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 101A71DB803B
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:19:49 +0900 (JST)
Message-ID: <44480.10.75.179.62.1231413588.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
    <20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 8 Jan 2009 20:19:48 +0900 (JST)
Subject: Re: [RFC][PATCH 4/4] memcg: make oom less frequently
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> In previous implementation, mem_cgroup_try_charge checked the return
> value of mem_cgroup_try_to_free_pages, and just retried if some pages
> had been reclaimed.
> But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> only checks whether the usage is less than the limit.
>
> This patch tries to change the behavior as before to cause oom less
> frequently.
>
> To prevent try_charge from getting stuck in infinite loop,
> MEM_CGROUP_RECLAIM_RETRIES_MAX is defined.
>
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I think this is necessary change.
My version of hierarchy reclaim will do this.

But RETRIES_MAX is not clear ;) please use one counter.

And why MAX=32 ?
> +		if (ret)
> +			continue;
seems to do enough work.

While memory can be reclaimed, it's not dead lock.
To handle live-lock situation as "reclaimed memory is stolen very soon",
should we check signal_pending(current) or some flags ?

IMHO, using jiffies to detect how long we should retry is easy to understand
....like
 "if memory charging cannot make progress for XXXX minutes,
  trigger some notifier or show some flag to user via cgroupfs interface.
  to show we're tooooooo busy."

-Kame


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
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account
> = 0 */
> @@ -770,10 +771,10 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
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
> @@ -785,10 +786,10 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
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
> @@ -820,6 +821,7 @@ static int __mem_cgroup_try_charge(struct mm_struct
> *mm,
>  {
>  	struct mem_cgroup *mem, *mem_over_limit;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	int nr_retries_max = MEM_CGROUP_RECLAIM_RETRIES_MAX;
>  	struct res_counter *fail_res;
>
>  	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
> @@ -871,8 +873,13 @@ static int __mem_cgroup_try_charge(struct mm_struct
> *mm,
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
> @@ -886,6 +893,7 @@ static int __mem_cgroup_try_charge(struct mm_struct
> *mm,
>  			continue;
>
>  		if (!nr_retries--) {
> +oom:
>  			if (oom) {
>  				mutex_lock(&memcg_tasklist);
>  				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
