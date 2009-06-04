Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C87066B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:38:13 -0400 (EDT)
Date: Thu, 4 Jun 2009 14:33:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-Id: <20090604143318.a86eafb1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jun 2009 14:10:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Removes memory.limit < memsw.limit at setting limit check completely.
> 
> The limitation "memory.limit <= memsw.limit" was added just because
> it seems sane ...if memory.limit > memsw.limit, only memsw.limit works.
> 
> But To implement this limitation, we needed to use private mutex and make
> the code a bit complated.
> As Nishimura pointed out, in real world, there are people who only want
> to use memsw.limit.
> 
> Then, this patch removes the check. user-land library or middleware can check
> this in userland easily if this really concerns.
> 
> And this is a good change to charge-and-reclaim.
> 
> Now, memory.limit is always checked before memsw.limit
> and it may do swap-out. But, if memory.limit == memsw.limit, swap-out is
> finally no help and hits memsw.limit again. So, let's allow the condition
> memory.limit > memsw.limit. Then we can skip unnecesary swap-out.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I welcome this change very much :)

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

> ---
>  Documentation/cgroups/memory.txt |   15 +++++++++++----
>  mm/memcontrol.c                  |   33 +--------------------------------
>  2 files changed, 12 insertions(+), 36 deletions(-)
> 
> Index: mmotm-2.6.30-Jun3/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.30-Jun3.orig/mm/memcontrol.c
> +++ mmotm-2.6.30-Jun3/mm/memcontrol.c
> @@ -1713,14 +1713,11 @@ int mem_cgroup_shmem_charge_fallback(str
>  	return ret;
>  }
>  
> -static DEFINE_MUTEX(set_limit_mutex);
> -
>  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count;
>  	int progress;
> -	u64 memswlimit;
>  	int ret = 0;
>  	int children = mem_cgroup_count_children(memcg);
>  	u64 curusage, oldusage;
> @@ -1739,20 +1736,7 @@ static int mem_cgroup_resize_limit(struc
>  			ret = -EINTR;
>  			break;
>  		}
> -		/*
> -		 * Rather than hide all in some function, I do this in
> -		 * open coded manner. You see what this really does.
> -		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> -		 */
> -		mutex_lock(&set_limit_mutex);
> -		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -		if (memswlimit < val) {
> -			ret = -EINVAL;
> -			mutex_unlock(&set_limit_mutex);
> -			break;
> -		}
>  		ret = res_counter_set_limit(&memcg->res, val);
> -		mutex_unlock(&set_limit_mutex);
>  
>  		if (!ret)
>  			break;
> @@ -1774,7 +1758,7 @@ static int mem_cgroup_resize_memsw_limit
>  					unsigned long long val)
>  {
>  	int retry_count;
> -	u64 memlimit, oldusage, curusage;
> +	u64 oldusage, curusage;
>  	int children = mem_cgroup_count_children(memcg);
>  	int ret = -EBUSY;
>  
> @@ -1786,24 +1770,9 @@ static int mem_cgroup_resize_memsw_limit
>  			ret = -EINTR;
>  			break;
>  		}
> -		/*
> -		 * Rather than hide all in some function, I do this in
> -		 * open coded manner. You see what this really does.
> -		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> -		 */
> -		mutex_lock(&set_limit_mutex);
> -		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -		if (memlimit > val) {
> -			ret = -EINVAL;
> -			mutex_unlock(&set_limit_mutex);
> -			break;
> -		}
>  		ret = res_counter_set_limit(&memcg->memsw, val);
> -		mutex_unlock(&set_limit_mutex);
> -
>  		if (!ret)
>  			break;
> -
>  		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		/* Usage is reduced ? */
> Index: mmotm-2.6.30-Jun3/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.30-Jun3.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.30-Jun3/Documentation/cgroups/memory.txt
> @@ -155,11 +155,18 @@ usage of mem+swap is limited by memsw.li
>  Note: why 'mem+swap' rather than swap.
>  The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
>  to move account from memory to swap...there is no change in usage of
> -mem+swap.
> +mem+swap. In other words, when we want to limit the usage of swap
> +without affecting global LRU, mem+swap limit is better than just limiting
> +swap from OS point of view.
> +
> +
> +memory.limit v.s. memsw.limit
> +
> +There are no guarantee that memsw.limit is bigger than memory.limit
> +in the kernel. The user should notice what he really wants and use
> +proper size for limitation. Of course, if memsw.limit < memory.limit,
> +only memsw.limit works sane.
>  
> -In other words, when we want to limit the usage of swap without affecting
> -global LRU, mem+swap limit is better than just limiting swap from OS point
> -of view.
>  
>  2.5 Reclaim
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
