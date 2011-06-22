Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 330B3900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:53:15 -0400 (EDT)
Date: Wed, 22 Jun 2011 17:53:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/7] memcg: update numa information based on event counter
Message-ID: <20110622155309.GH14343@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125400.1145a4e2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616125400.1145a4e2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 16-06-11 12:54:00, KAMEZAWA Hiroyuki wrote:
> From 88090fe10e225ad8769ba0ea01692b7314e8b973 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 15 Jun 2011 16:19:46 +0900
> Subject: [PATCH 4/7] memcg: update numa information based on event counter
> 
> commit 889976 adds an numa node round-robin for memcg. But the information
> is updated once per 10sec.
> 
> This patch changes the update trigger from jiffies to memcg's event count.
> After this patch, numa scan information will be updated when
> 
>   - the number of pagein/out events is larger than 3% of limit
>   or
>   - the number of pagein/out events is larger than 16k
>     (==64MB pagein/pageout if pagesize==4k.)
> 
> The counter of mem->numascan_update the sum of percpu events counter.
> When a task hits limit, it checks mem->numascan_update. If it's over
> min(3% of limit, 16k), numa information will be updated.

Yes, I like the event based approach more than the origin (time) based
one.

> 
> This patch also adds mutex for updating information. This will allow us
> to avoid unnecessary scan.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   51 +++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 45 insertions(+), 6 deletions(-)
> 
> Index: mmotm-0615/mm/memcontrol.c
> ===================================================================
> --- mmotm-0615.orig/mm/memcontrol.c
> +++ mmotm-0615/mm/memcontrol.c
> @@ -108,10 +108,12 @@ enum mem_cgroup_events_index {
>  enum mem_cgroup_events_target {
>  	MEM_CGROUP_TARGET_THRESH,
>  	MEM_CGROUP_TARGET_SOFTLIMIT,
> +	MEM_CGROUP_TARGET_NUMASCAN,

Shouldn't it be defined only for MAX_NUMNODES > 1

>  	MEM_CGROUP_NTARGETS,
>  };
>  #define THRESHOLDS_EVENTS_TARGET (128)
>  #define SOFTLIMIT_EVENTS_TARGET (1024)
> +#define NUMASCAN_EVENTS_TARGET  (1024)
>  
>  struct mem_cgroup_stat_cpu {
>  	long count[MEM_CGROUP_STAT_NSTATS];
> @@ -288,8 +290,9 @@ struct mem_cgroup {
>  	int last_scanned_node;
>  #if MAX_NUMNODES > 1
>  	nodemask_t	scan_nodes;
> -	unsigned long   next_scan_node_update;
> +	struct mutex	numascan_mutex;
>  #endif
> +	atomic_t	numascan_update;

Why it is out of ifdef?

>  	/*
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
> @@ -741,6 +744,9 @@ static void __mem_cgroup_target_update(s
>  	case MEM_CGROUP_TARGET_SOFTLIMIT:
>  		next = val + SOFTLIMIT_EVENTS_TARGET;
>  		break;
> +	case MEM_CGROUP_TARGET_NUMASCAN:
> +		next = val + NUMASCAN_EVENTS_TARGET;
> +		break;

MAX_NUMNODES > 1

>  	default:
>  		return;
>  	}
> @@ -764,6 +770,13 @@ static void memcg_check_events(struct me
>  			__mem_cgroup_target_update(mem,
>  				MEM_CGROUP_TARGET_SOFTLIMIT);
>  		}
> +		if (unlikely(__memcg_event_check(mem,
> +			MEM_CGROUP_TARGET_NUMASCAN))) {
> +			atomic_add(MEM_CGROUP_TARGET_NUMASCAN,
> +				&mem->numascan_update);
> +			__mem_cgroup_target_update(mem,
> +				MEM_CGROUP_TARGET_NUMASCAN);
> +		}
>  	}

again MAX_NUMNODES > 1

>  }
>  
> @@ -1616,17 +1629,32 @@ mem_cgroup_select_victim(struct mem_cgro
>  /*
>   * Always updating the nodemask is not very good - even if we have an empty
>   * list or the wrong list here, we can start from some node and traverse all
> - * nodes based on the zonelist. So update the list loosely once per 10 secs.
> + * nodes based on the zonelist.
>   *
> + * The counter of mem->numascan_update is updated once per
> + * NUMASCAN_EVENTS_TARGET. We update the numa information when we see
> + * the number of event is larger than 3% of limit or  64MB pagein/pageout.
>   */
> +#define NUMASCAN_UPDATE_RATIO	(3)
> +#define NUMASCAN_UPDATE_THRESH	(16384UL) /* 16k events of pagein/pageout */
>  static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>  {
>  	int nid;
> -
> -	if (time_after(mem->next_scan_node_update, jiffies))
> +	unsigned long long limit;
> +	/* if no limit, we never reach here */
> +	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> +	limit /= PAGE_SIZE;
> +	/* 3% of limit */
> +	limit = (limit * NUMASCAN_UPDATE_RATIO/100UL);
> +	limit = min_t(unsigned long long, limit, NUMASCAN_UPDATE_THRESH);
> +	/*
> +	 * If the number of pagein/out event is larger than 3% of limit or
> +	 * 64MB pagein/out, refresh numa information.
> +	 */
> +	if (atomic_read(&mem->numascan_update) < limit ||
> +	    !mutex_trylock(&mem->numascan_mutex))
>  		return;

I am not sure whether a mutex is not overkill here. What about using an
atomic operation instead?

> -
> -	mem->next_scan_node_update = jiffies + 10*HZ;
> +	atomic_set(&mem->numascan_update, 0);
>  	/* make a nodemask where this memcg uses memory from */
>  	mem->scan_nodes = node_states[N_HIGH_MEMORY];
>  
> @@ -1642,6 +1670,7 @@ static void mem_cgroup_may_update_nodema
>  			continue;
>  		node_clear(nid, mem->scan_nodes);
>  	}
> +	mutex_unlock(&mem->numascan_mutex);
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
