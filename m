Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4922A6B0116
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:12:30 -0400 (EDT)
Date: Wed, 29 Jun 2011 15:12:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [FIX][PATCH 2/3] memcg: fix numa scan information update to be
 triggered by memory event
Message-ID: <20110629131222.GB24262@tiehlicka.suse.cz>
References: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110628174150.6b32e51c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110628174150.6b32e51c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue 28-06-11 17:41:50, KAMEZAWA Hiroyuki wrote:
> From 646ca5cd1e1ab0633892b86a1bbb6cf600d79d58 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Tue, 28 Jun 2011 17:09:25 +0900
> Subject: [PATCH 2/3] Fix numa scan information update to be triggered by memory event
> 
> commit 889976 adds an numa node round-robin for memcg. But the information
> is updated once per 10sec.
> 
> This patch changes the update trigger from jiffies to memcg's event count.
> After this patch, numa scan information will be updated when we see
> 1024 events of pagein/pageout under a memcg.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

See the note about wasted memory for MAX_NUMNODES==1 bellow.

> 
> Changelog:
>   - simplified
>   - removed mutex
>   - removed 3% check. To use heuristics, we cannot avoid magic value.
>     So, removed heuristics.
> ---
>  mm/memcontrol.c |   29 +++++++++++++++++++++++++----
>  1 files changed, 25 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c624312..3e7d5e6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -108,10 +108,12 @@ enum mem_cgroup_events_index {
>  enum mem_cgroup_events_target {
>  	MEM_CGROUP_TARGET_THRESH,
>  	MEM_CGROUP_TARGET_SOFTLIMIT,
> +	MEM_CGROUP_TARGET_NUMAINFO,

This still wastes sizeof(unsigned long) per CPU space for non NUMA
machines (resp. MAX_NUMNODES==1).

[...]
> @@ -703,6 +709,14 @@ static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
>  			__mem_cgroup_target_update(mem,
>  				MEM_CGROUP_TARGET_SOFTLIMIT);
>  		}
> +#if MAX_NUMNODES > 1
> +		if (unlikely(__memcg_event_check(mem,
> +			MEM_CGROUP_TARGET_NUMAINFO))) {
> +			atomic_inc(&mem->numainfo_events);
> +			__mem_cgroup_target_update(mem,
> +				MEM_CGROUP_TARGET_NUMAINFO);
> +		}
> +#endif
>  	}
>  }
>  
> @@ -1582,11 +1596,15 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *mem,
>  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  {
>  	int nid;
> -
> -	if (time_after(mem->next_scan_node_update, jiffies))
> +	/*
> +	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
> +	 * pagein/pageout changes since the last update.
> +	 */
> +	if (!atomic_read(&mem->numainfo_events))
> +		return;

At first I was worried about memory barriers here because
atomic_{set,inc} used for numainfo_events do not imply mem. barriers
but that is not a problem because memcg_check_events will always make
numainfo_events > 0 (even if it doesn't see atomic_set from this
function and we are not interested in the exact value).

> +	if (atomic_inc_return(&mem->numainfo_updating) > 1)
>  		return;

OK, this one should be barrier safe as well as this enforces barrier on
both sides (before and after operation) so the atomic_set shouldn't
break it AFAIU.

>  
> -	mem->next_scan_node_update = jiffies + 10*HZ;
>  	/* make a nodemask where this memcg uses memory from */
>  	mem->scan_nodes = node_states[N_HIGH_MEMORY];
>  
> @@ -1595,6 +1613,9 @@ static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  		if (!test_mem_cgroup_node_reclaimable(mem, nid, false))
>  			node_clear(nid, mem->scan_nodes);
>  	}
> +
> +	atomic_set(&mem->numainfo_events, 0);
> +	atomic_set(&mem->numainfo_updating, 0);
>  }
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
