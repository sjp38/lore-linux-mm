Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 45E826B007D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 09:13:22 -0500 (EST)
Date: Tue, 29 Jan 2013 15:13:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
Message-ID: <20130129141318.GC29574@dhcp22.suse.cz>
References: <510658E3.1020306@oracle.com>
 <510658EE.9050006@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510658EE.9050006@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, handai.szj@taobao.com

On Mon 28-01-13 18:54:38, Jeff Liu wrote:
> Root memcg with swap cgroup is special since we only do tracking but can
> not set limits against it.  In order to facilitate the implementation of
> the coming swap cgroup structures delay allocation mechanism, we can bypass
> the default swap statistics upon the root memcg and figure it out through
> the global stats instead as below:
> 
> root_memcg_swap_stat: total_swap_pages - nr_swap_pages - used_swap_pages_of_all_memcgs

How do you protect from races with swap{in,out}? Or they are tolerable?

> memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats

I am not sure I understand and if I do then it is not true:
root (swap = 10M, use_hierarchy = 0/1)
 \
  A (swap = 1M, use_hierarchy = 1)
   \
    B (swap = 2M)

total for A is 3M regardless of what root has "accounted" while
total for root should be 10 for use_hierarchy = 0 and 13 for the other
case (this is btw. broken in the tree already now because
for_each_mem_cgroup_tree resp. mem_cgroup_iter doesn't honor
use_hierarchy for the root cgroup - this is a separate topic though).

> In this way, we'll return an invalid CSS_ID(generally, it's 0) at swap
> cgroup related tracking infrastructures if only the root memcg is alive.
> That is to say, we have not yet allocate swap cgroup structures.
> As a result, the per pages swapin/swapout stats number agains the root
> memcg shoud be ZERO.
> 
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> CC: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> 
> ---
>  mm/memcontrol.c |   35 ++++++++++++++++++++++++++++++-----
>  1 file changed, 30 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 09255ec..afe5e86 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5231,12 +5231,34 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  	struct mem_cgroup *mi;
>  	unsigned int i;
> +	long long root_swap_stat = 0;
>
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> -			continue;
> +		long val = 0;
> +
> +		if (i != MEM_CGROUP_STAT_SWAP)
> +			val = mem_cgroup_read_stat(memcg, i);
> +		else {
> +			if (!do_swap_account)
> +				continue;


> +			if (!mem_cgroup_is_root(memcg))
> +				val = mem_cgroup_read_stat(memcg, i);
> +			else {
> +				/*
> +				 * The corresponding stat number of swap for
> +				 * root_mem_cgroup is 0 since we don't account
> +				 * it in any case.  Instead, we can fake the
> +				 * root number via: total_swap_pages -
> +				 * nr_swap_pages - total_swap_pages_of_all_memcg
> +				 */
> +				for_each_mem_cgroup(mi)
> +					val += mem_cgroup_read_stat(mi, i);
> +				val = root_swap_stat = (total_swap_pages -
> +							nr_swap_pages - val);
> +			}

This calls for a helper.

> +		}
>  		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
> -			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
> +			   val * PAGE_SIZE);
>  	}
>  
>  	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
> @@ -5260,8 +5282,11 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		long long val = 0;
>  
> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> -			continue;
> +		if (i == MEM_CGROUP_STAT_SWAP) {
> +			if (!do_swap_account)
> +				continue;
> +			val += root_swap_stat * PAGE_SIZE;
> +		}

This doesn't seem right because you are adding root swap amount to _all_
groups. This should be done only if (memcg == root_mem_cgroup).

>  		for_each_mem_cgroup_tree(mi, memcg)
>  			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
>  		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
