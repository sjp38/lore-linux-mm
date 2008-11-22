Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAME3iJi020115
	for <linux-mm@kvack.org>; Sat, 22 Nov 2008 19:33:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAME3AlD3485900
	for <linux-mm@kvack.org>; Sat, 22 Nov 2008 19:33:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAME3fd2030498
	for <linux-mm@kvack.org>; Sat, 22 Nov 2008 19:33:42 +0530
Message-ID: <4928113B.8090504@linux.vnet.ibm.com>
Date: Sat, 22 Nov 2008 19:33:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH mmotm] memcg: fix for hierarchical reclaim
References: <20081122114446.42ddca46.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081122114446.42ddca46.d-nishimura@mtf.biglobe.ne.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> mem_cgroup_from_res_counter should handle both mem->res and mem->memsw.
> This bug leads to NULL pointer dereference BUG at mem_cgroup_calc_reclaim.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks for catching this, could you please point me to the steps to reproduce
the problem

> ---
> This is fix for memory-cgroup-hierarchical-reclaim-v4.patch.
> 
>  mm/memcontrol.c |   23 +++++++++--------------
>  1 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d177ed7..ac445cf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -468,11 +468,8 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  	return nr_taken;
>  }
> 
> -static struct mem_cgroup *
> -mem_cgroup_from_res_counter(struct res_counter *counter)
> -{
> -	return container_of(counter, struct mem_cgroup, res);
> -}
> +#define mem_cgroup_from_res_counter(counter, member)	\
> +	container_of(counter, struct mem_cgroup, member)
> 
>  /*
>   * This routine finds the DFS walk successor. This routine should be
> @@ -665,18 +662,16 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  			/* mem+swap counter fails */
>  			res_counter_uncharge(&mem->res, PAGE_SIZE);
>  			noswap = true;
> -		}
> +			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> +									memsw);
> +		} else
> +			/* mem counter fails */
> +			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> +									res);
> +
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
> 
> -		/*
> -		 * Is one of our ancestors over their limit?
> -		 */
> -		if (fail_res)
> -			mem_over_limit = mem_cgroup_from_res_counter(fail_res);
> -		else
> -			mem_over_limit = mem;
> -
>  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
>  							noswap);
> 

Seems reasonable, but I want to test it.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
