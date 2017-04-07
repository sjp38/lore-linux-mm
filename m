Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7815C6B039F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 08:20:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i18so10253289wrb.21
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 05:20:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si7539303wrc.285.2017.04.07.05.20.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 05:20:42 -0700 (PDT)
Date: Fri, 7 Apr 2017 14:20:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm: memcontrol: clean up memory.events counting
 function
Message-ID: <20170407122038.GD16413@dhcp22.suse.cz>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404220148.28338-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 04-04-17 18:01:45, Johannes Weiner wrote:
> We only ever count single events, drop the @nr parameter. Rename the
> function accordingly. Remove low-information kerneldoc.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 18 +++++-------------
>  mm/memcontrol.c            |  8 ++++----
>  mm/vmscan.c                |  2 +-
>  3 files changed, 10 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index cfa91a3ca0ca..bc0c16e284c0 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -287,17 +287,10 @@ static inline bool mem_cgroup_disabled(void)
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
>  }
>  
> -/**
> - * mem_cgroup_events - count memory events against a cgroup
> - * @memcg: the memory cgroup
> - * @idx: the event index
> - * @nr: the number of events to account for
> - */
> -static inline void mem_cgroup_events(struct mem_cgroup *memcg,
> -		       enum mem_cgroup_events_index idx,
> -		       unsigned int nr)
> +static inline void mem_cgroup_event(struct mem_cgroup *memcg,
> +				    enum mem_cgroup_events_index idx)
>  {
> -	this_cpu_add(memcg->stat->events[idx], nr);
> +	this_cpu_inc(memcg->stat->events[idx]);
>  	cgroup_file_notify(&memcg->events_file);
>  }
>  
> @@ -614,9 +607,8 @@ static inline bool mem_cgroup_disabled(void)
>  	return true;
>  }
>  
> -static inline void mem_cgroup_events(struct mem_cgroup *memcg,
> -				     enum mem_cgroup_events_index idx,
> -				     unsigned int nr)
> +static inline void mem_cgroup_event(struct mem_cgroup *memcg,
> +				    enum mem_cgroup_events_index idx)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 108d5b097db1..1ffa3ad201ea 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1825,7 +1825,7 @@ static void reclaim_high(struct mem_cgroup *memcg,
>  	do {
>  		if (page_counter_read(&memcg->memory) <= memcg->high)
>  			continue;
> -		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
> +		mem_cgroup_event(memcg, MEMCG_HIGH);
>  		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
>  	} while ((memcg = parent_mem_cgroup(memcg)));
>  }
> @@ -1916,7 +1916,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (!gfpflags_allow_blocking(gfp_mask))
>  		goto nomem;
>  
> -	mem_cgroup_events(mem_over_limit, MEMCG_MAX, 1);
> +	mem_cgroup_event(mem_over_limit, MEMCG_MAX);
>  
>  	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
>  						    gfp_mask, may_swap);
> @@ -1959,7 +1959,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (fatal_signal_pending(current))
>  		goto force;
>  
> -	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
> +	mem_cgroup_event(mem_over_limit, MEMCG_OOM);
>  
>  	mem_cgroup_oom(mem_over_limit, gfp_mask,
>  		       get_order(nr_pages * PAGE_SIZE));
> @@ -5142,7 +5142,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  			continue;
>  		}
>  
> -		mem_cgroup_events(memcg, MEMCG_OOM, 1);
> +		mem_cgroup_event(memcg, MEMCG_OOM);
>  		if (!mem_cgroup_out_of_memory(memcg, GFP_KERNEL, 0))
>  			break;
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3f62cf37097..18731310ca36 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2526,7 +2526,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  					sc->memcg_low_skipped = 1;
>  					continue;
>  				}
> -				mem_cgroup_events(memcg, MEMCG_LOW, 1);
> +				mem_cgroup_event(memcg, MEMCG_LOW);
>  			}
>  
>  			reclaimed = sc->nr_reclaimed;
> -- 
> 2.12.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
