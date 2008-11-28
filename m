Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mASB0fLc030446
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Nov 2008 20:00:41 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A0D845DE53
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 20:00:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E16A745DE51
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 20:00:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C49AD1DB8040
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 20:00:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 49E311DB803A
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 20:00:40 +0900 (JST)
Date: Fri, 28 Nov 2008 19:59:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mmotm 2/2] avoid oom
Message-Id: <20081128195953.0f69d9ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081128180937.5d7b16c5.nishimura@mxp.nes.nec.co.jp>
References: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
	<20081128180937.5d7b16c5.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008 18:09:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> In previous implementation, mem_cgroup_try_charge checked the return
> value of mem_cgroup_try_to_free_pages, and just retried if some pages
> had been reclaimed.
> But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> only checks whether the usage is less than the limit.
> I see oom easily in some tests which didn't cause oom before.
> 
> This patch tries to change the behavior as before.
> 
> I've tested this patch with only one (except root) mem cgroup directory,
> and a mem cgroup directory(use_hierarchy=1) which has 4 children with running
> test programs on itself and each children's directories.
> 
> Of course, even after this patch is applied, oom happens if trying to use
> too much memory.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> 
>  mm/memcontrol.c |   19 ++++++++++++-------
>  1 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e7806fc..ab134b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -592,6 +592,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  {
>  	struct mem_cgroup *next_mem;
>  	int ret = 0;
> +	int child = 0;
>  
>  	/*
>  	 * Reclaim unconditionally and don't check for return value.
> @@ -600,9 +601,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	 * but there might be left over accounting, even after children
>  	 * have left.
>  	 */
> -	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
> +	ret += try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
>  	if (mem_cgroup_check_under_limit(root_mem))
> -		return 0;
> +		return 1;	/* indicate success of reclaim */
>  
>  	next_mem = mem_cgroup_get_first_node(root_mem);
>  
> @@ -614,14 +615,17 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  			cgroup_unlock();
>  			continue;
>  		}
> -		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
> +		child++;
> +		ret += try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
>  		if (mem_cgroup_check_under_limit(root_mem))
> -			return 0;
> +			return 1;	/* indicate success of reclaim */
>  		cgroup_lock();
>  		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
>  		cgroup_unlock();
>  	}
> -	return ret;
> +
> +	/* reclaimed at least one page on average from root and each child */
> +	return ret > child;
>  }
>  
I can't understand why this heuristic...

just (ret != 0) is ?

Thanks,
-Kame



>  /*
> @@ -684,8 +688,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> -		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> -							noswap);
> +		if (mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> +							noswap))
> +			continue;
>  
>  		/*
>  		 * try_to_free_mem_cgroup_pages() might not give us a full
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
