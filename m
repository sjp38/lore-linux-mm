Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 578F86B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:17:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i11so1348637pgq.10
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 05:17:47 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x12-v6si1894078plr.334.2018.03.14.05.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 05:17:46 -0700 (PDT)
Date: Wed, 14 Mar 2018 12:17:06 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm] mm, memcg: evaluate root and leaf memcgs fairly on
 oom
Message-ID: <20180314121700.GA20850@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, David!

Overall I like this idea.
Some questions below.

On Tue, Mar 13, 2018 at 05:21:09PM -0700, David Rientjes wrote:
> There are several downsides to the current implementation that compares
> the root mem cgroup with leaf mem cgroups for the cgroup-aware oom killer.
> 
> For example, /proc/pid/oom_score_adj is accounted for processes attached
> to the root mem cgroup but not leaves.  This leads to wild inconsistencies
> that unfairly bias for or against the root mem cgroup.
> 
> Assume a 728KB bash shell is attached to the root mem cgroup without any
> other processes having a non-default /proc/pid/oom_score_adj.  At the time
> of system oom, the root mem cgroup evaluated to 43,474 pages after boot.
> If the bash shell adjusts its /proc/self/oom_score_adj to 1000, however,
> the root mem cgroup evaluates to 24,765,482 pages lol.  It would take a
> cgroup 95GB of memory to outweigh the root mem cgroup's evaluation.
> 
> The reverse is even more confusing: if the bash shell adjusts its
> /proc/self/oom_score_adj to -999, the root mem cgroup evaluates to 42,268
> pages, a basically meaningless transformation.
> 
> /proc/pid/oom_score_adj is discounted, however, for processes attached to
> leaf mem cgroups.  If a sole process using 250MB of memory is attached to
> a mem cgroup, it evaluates to 250MB >> PAGE_SHIFT.  If its
> /proc/pid/oom_score_adj is changed to -999, or even 1000, the evaluation
> remains the same for the mem cgroup.
> 
> The heuristic that is used for the root mem cgroup also differs from leaf
> mem cgroups.
> 
> For the root mem cgroup, the evaluation is the sum of all process's
> /proc/pid/oom_score.  Besides factoring in oom_score_adj, it is based on
> the sum of rss + swap + page tables for all processes attached to it.
> For leaf mem cgroups, it is based on the amount of anonymous or
> unevictable memory + unreclaimable slab + kernel stack + sock + swap.
> 
> There's also an exemption for root mem cgroup processes that do not
> intersect the allocating process's mems_allowed.  Because the current
> heuristic is based on oom_badness(), the evaluation of the root mem
> cgroup disregards all processes attached to it that have disjoint
> mems_allowed making oom selection specifically dependant on the
> allocating process for system oom conditions!
> 
> This patch introduces completely fair comparison between the root mem
> cgroup and leaf mem cgroups.  It compares them with the same heuristic
> and does not prefer one over the other.  It disregards oom_score_adj
> as the cgroup-aware oom killer should, if enabled by memory.oom_policy.
> The goal is to target the most memory consuming cgroup on the system,
> not consider per-process adjustment.
> 
> The fact that the evaluation of all mem cgroups depends on the mempolicy
> of the allocating process, which is completely undocumented for the
> cgroup-aware oom killer, will be addressed in a subsequent patch.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Based on top of oom policy patch series at
>  https://marc.info/?t=152090280800001
> 
>  Documentation/cgroup-v2.txt |   7 +-
>  mm/memcontrol.c             | 147 ++++++++++++++++++------------------
>  2 files changed, 74 insertions(+), 80 deletions(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1328,12 +1328,7 @@ OOM killer to kill all processes attached to the cgroup, except processes
>  with /proc/pid/oom_score_adj set to -1000 (oom disabled).
>  
>  The root cgroup is treated as a leaf memory cgroup as well, so it is
> -compared with other leaf memory cgroups. Due to internal implementation
> -restrictions the size of the root cgroup is the cumulative sum of
> -oom_badness of all its tasks (in other words oom_score_adj of each task
> -is obeyed). Relying on oom_score_adj (apart from OOM_SCORE_ADJ_MIN) can
> -lead to over- or underestimation of the root cgroup consumption and it is
> -therefore discouraged. This might change in the future, however.
> +compared with other leaf memory cgroups.
>  
>  Please, note that memory charges are not migrating if tasks
>  are moved between different memory cgroups. Moving tasks with
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -94,6 +94,8 @@ int do_swap_account __read_mostly;
>  #define do_swap_account		0
>  #endif
>  
> +static atomic_long_t total_sock_pages;
> +
>  /* Whether legacy memory+swap accounting is active */
>  static bool do_memsw_account(void)
>  {
> @@ -2607,9 +2609,9 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  }
>  
>  static long memcg_oom_badness(struct mem_cgroup *memcg,
> -			      const nodemask_t *nodemask,
> -			      unsigned long totalpages)
> +			      const nodemask_t *nodemask)
>  {
> +	const bool is_root_memcg = memcg == root_mem_cgroup;
>  	long points = 0;
>  	int nid;
>  	pg_data_t *pgdat;
> @@ -2618,92 +2620,65 @@ static long memcg_oom_badness(struct mem_cgroup *memcg,
>  		if (nodemask && !node_isset(nid, *nodemask))
>  			continue;
>  
> -		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> -				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> -
>  		pgdat = NODE_DATA(nid);
> -		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> -					    NR_SLAB_UNRECLAIMABLE);
> +		if (is_root_memcg) {
> +			points += node_page_state(pgdat, NR_ACTIVE_ANON) +
> +				  node_page_state(pgdat, NR_INACTIVE_ANON);
> +			points += node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
> +		} else {
> +			points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +							       LRU_ALL_ANON);
> +			points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> +						    NR_SLAB_UNRECLAIMABLE);
> +		}
>  	}
>  
> -	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> -		(PAGE_SIZE / 1024);
> -	points += memcg_page_state(memcg, MEMCG_SOCK);
> -	points += memcg_page_state(memcg, MEMCG_SWAP);
> -
> +	if (is_root_memcg) {
> +		points += global_zone_page_state(NR_KERNEL_STACK_KB) /
> +				(PAGE_SIZE / 1024);
> +		points += atomic_long_read(&total_sock_pages);
                                            ^^^^^^^^^^^^^^^^
BTW, where do we change this counter?

I also doubt that global atomic variable can work here,
we probably need something better scaling.

Thanks!
