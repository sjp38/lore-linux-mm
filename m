Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9476B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:22:12 -0500 (EST)
Date: Thu, 15 Jan 2009 15:16:57 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-Id: <20090115151657.84eb1a03.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <496ED2B7.5050902@cn.fujitsu.com>
References: <496ED2B7.5050902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 14:07:51 +0800, Li Zefan <lizf@cn.fujitsu.com> wrote:
> 1. task p1 is in /memcg/0
> 2. p1 does mmap(4096*2, MAP_LOCKED)
> 3. echo 4096 > /memcg/0/memory.limit_in_bytes
> 
> The above 'echo' will never return, unless p1 exited or freed the memory.
> The cause is we can't reclaim memory from p1, so the while loop in
> mem_cgroup_resize_limit() won't break.
> 
But it can be interrupted, right ?

I don't think this would be a big problem.


Thanks,
Daisuke Nishimura.

> This patch fixes it by decrementing retry_count regardless the return value
> of mem_cgroup_hierarchical_reclaim().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  mm/memcontrol.c |   15 ++++-----------
>  1 files changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fb62b43..1995098 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1524,11 +1524,10 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  {
>  
>  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> -	int progress;
>  	u64 memswlimit;
>  	int ret = 0;
>  
> -	while (retry_count) {
> +	while (retry_count--) {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
>  			break;
> @@ -1551,9 +1550,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
> -							   false);
> -  		if (!progress)			retry_count--;
> +		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, false);
>  	}
>  
>  	return ret;
> @@ -1563,13 +1560,13 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> -	u64 memlimit, oldusage, curusage;
> +	u64 memlimit;
>  	int ret;
>  
>  	if (!do_swap_account)
>  		return -EINVAL;
>  
> -	while (retry_count) {
> +	while (retry_count--) {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
>  			break;
> @@ -1592,11 +1589,7 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true);
> -		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
> -		if (curusage >= oldusage)
> -			retry_count--;
>  	}
>  	return ret;
>  }
> -- 
> 1.5.4.rc3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
