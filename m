Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1536B006C
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:21:19 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id hz20so2737732lab.11
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:21:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si22938763laj.42.2014.10.22.04.21.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 04:21:16 -0700 (PDT)
Date: Wed, 22 Oct 2014 13:21:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaimable check from soft
 reclaim
Message-ID: <20141022112116.GA30802@dhcp22.suse.cz>
References: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
 <20141021182239.GA24899@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021182239.GA24899@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 21-10-14 14:22:39, Johannes Weiner wrote:
[...]
> From 27bd24b00433d9f6c8d60ba2b13dbff158b06c13 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 21 Oct 2014 09:53:54 -0400
> Subject: [patch] mm: memcontrol: do not filter reclaimable nodes in NUMA
>  round-robin
> 
> The round-robin node reclaim currently tries to include only nodes
> that have memory of the memcg in question, which is quite elaborate.
> 
> Just use plain round-robin over the nodes that are allowed by the
> task's cpuset, which are the most likely to contain that memcg's
> memory.  But even if zones without memcg memory are encountered,
> direct reclaim will skip over them without too much hassle.

I do not think that using the current's node mask is correct. Different
tasks in the same memcg might be bound to different nodes and then a set
of nodes might be reclaimed much more if a particular task hits limit
more often. It also doesn't make much sense from semantical POV, we are
reclaiming memcg so the mask should be union of all tasks allowed nodes.

What we do currently is overly complicated though and I agree that there
is no good reason for it.
Let's just s@cpuset_current_mems_allowed@node_online_map@ and round
robin over all nodes. As you said we do not have to optimize for empty
zones.

Anyway I very much welcome all these simplifications (my todo list is
shrinking ;). Thanks!

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 97 +++------------------------------------------------------
>  1 file changed, 5 insertions(+), 92 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d353d9e1fdca..293db8234179 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -54,6 +54,7 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/cpu.h>
>  #include <linux/oom.h>
> +#include <linux/cpuset.h>
>  #include <linux/lockdep.h>
>  #include <linux/file.h>
>  #include "internal.h"
> @@ -129,12 +130,10 @@ static const char * const mem_cgroup_lru_names[] = {
>  enum mem_cgroup_events_target {
>  	MEM_CGROUP_TARGET_THRESH,
>  	MEM_CGROUP_TARGET_SOFTLIMIT,
> -	MEM_CGROUP_TARGET_NUMAINFO,
>  	MEM_CGROUP_NTARGETS,
>  };
>  #define THRESHOLDS_EVENTS_TARGET 128
>  #define SOFTLIMIT_EVENTS_TARGET 1024
> -#define NUMAINFO_EVENTS_TARGET	1024
>  
>  struct mem_cgroup_stat_cpu {
>  	long count[MEM_CGROUP_STAT_NSTATS];
> @@ -352,11 +351,6 @@ struct mem_cgroup {
>  #endif
>  
>  	int last_scanned_node;
> -#if MAX_NUMNODES > 1
> -	nodemask_t	scan_nodes;
> -	atomic_t	numainfo_events;
> -	atomic_t	numainfo_updating;
> -#endif
>  
>  	/* List of events which userspace want to receive */
>  	struct list_head event_list;
> @@ -965,9 +959,6 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
>  		case MEM_CGROUP_TARGET_SOFTLIMIT:
>  			next = val + SOFTLIMIT_EVENTS_TARGET;
>  			break;
> -		case MEM_CGROUP_TARGET_NUMAINFO:
> -			next = val + NUMAINFO_EVENTS_TARGET;
> -			break;
>  		default:
>  			break;
>  		}
> @@ -986,22 +977,10 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  	/* threshold event is triggered in finer grain than soft limit */
>  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit;
> -		bool do_numainfo __maybe_unused;
> -
> -		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> -						MEM_CGROUP_TARGET_SOFTLIMIT);
> -#if MAX_NUMNODES > 1
> -		do_numainfo = mem_cgroup_event_ratelimit(memcg,
> -						MEM_CGROUP_TARGET_NUMAINFO);
> -#endif
>  		mem_cgroup_threshold(memcg);
> -		if (unlikely(do_softlimit))
> +		if (mem_cgroup_event_ratelimit(memcg,
> +					       MEM_CGROUP_TARGET_SOFTLIMIT))
>  			mem_cgroup_update_tree(memcg, page);
> -#if MAX_NUMNODES > 1
> -		if (unlikely(do_numainfo))
> -			atomic_inc(&memcg->numainfo_events);
> -#endif
>  	}
>  }
>  
> @@ -1708,61 +1687,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			 NULL, "Memory cgroup out of memory");
>  }
>  
> -/**
> - * test_mem_cgroup_node_reclaimable
> - * @memcg: the target memcg
> - * @nid: the node ID to be checked.
> - * @noswap : specify true here if the user wants flle only information.
> - *
> - * This function returns whether the specified memcg contains any
> - * reclaimable pages on a node. Returns true if there are any reclaimable
> - * pages in the node.
> - */
> -static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
> -		int nid, bool noswap)
> -{
> -	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
> -		return true;
> -	if (noswap || !total_swap_pages)
> -		return false;
> -	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
> -		return true;
> -	return false;
> -
> -}
>  #if MAX_NUMNODES > 1
> -
> -/*
> - * Always updating the nodemask is not very good - even if we have an empty
> - * list or the wrong list here, we can start from some node and traverse all
> - * nodes based on the zonelist. So update the list loosely once per 10 secs.
> - *
> - */
> -static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
> -{
> -	int nid;
> -	/*
> -	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
> -	 * pagein/pageout changes since the last update.
> -	 */
> -	if (!atomic_read(&memcg->numainfo_events))
> -		return;
> -	if (atomic_inc_return(&memcg->numainfo_updating) > 1)
> -		return;
> -
> -	/* make a nodemask where this memcg uses memory from */
> -	memcg->scan_nodes = node_states[N_MEMORY];
> -
> -	for_each_node_mask(nid, node_states[N_MEMORY]) {
> -
> -		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
> -			node_clear(nid, memcg->scan_nodes);
> -	}
> -
> -	atomic_set(&memcg->numainfo_events, 0);
> -	atomic_set(&memcg->numainfo_updating, 0);
> -}
> -
>  /*
>   * Selecting a node where we start reclaim from. Because what we need is just
>   * reducing usage counter, start from anywhere is O,K. Considering
> @@ -1779,21 +1704,9 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
>  {
>  	int node;
>  
> -	mem_cgroup_may_update_nodemask(memcg);
> -	node = memcg->last_scanned_node;
> -
> -	node = next_node(node, memcg->scan_nodes);
> +	node = next_node(memcg->last_scanned_node, cpuset_current_mems_allowed);
>  	if (node == MAX_NUMNODES)
> -		node = first_node(memcg->scan_nodes);
> -	/*
> -	 * We call this when we hit limit, not when pages are added to LRU.
> -	 * No LRU may hold pages because all pages are UNEVICTABLE or
> -	 * memcg is too small and all pages are not on LRU. In that case,
> -	 * we use curret node.
> -	 */
> -	if (unlikely(node == MAX_NUMNODES))
> -		node = numa_node_id();
> -
> +		node = first_node(cpuset_current_mems_allowed);
>  	memcg->last_scanned_node = node;
>  	return node;
>  }
> -- 
> 2.1.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
