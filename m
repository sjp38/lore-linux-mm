Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 494896B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 15:58:13 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so2282646lbg.16
        for <linux-mm@kvack.org>; Tue, 06 May 2014 12:58:12 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id og9si5534160lbb.192.2014.05.06.12.58.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 12:58:11 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2935780lbi.37
        for <linux-mm@kvack.org>; Tue, 06 May 2014 12:58:11 -0700 (PDT)
Date: Tue, 6 May 2014 21:58:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140506195807.GD30921@dhcp22.suse.cz>
References: <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502120715.GI3446@dhcp22.suse.cz>
 <20140502130118.GK23420@cmpxchg.org>
 <20140502141515.GJ3446@dhcp22.suse.cz>
 <20140502150434.GM23420@cmpxchg.org>
 <20140502151120.GN3446@dhcp22.suse.cz>
 <20140502153451.GN23420@cmpxchg.org>
 <20140502154852.GO3446@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502154852.GO3446@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Andrew, could you queue/fold this one, please?

On Fri 02-05-14 17:48:52, Michal Hocko wrote:
[...]
> From 3101ce41cc8c0c9691d98054e8811c66a77cd079 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 2 May 2014 17:47:32 +0200
> Subject: [PATCH] mmotm: memcg-mm-introduce-lowlimit-reclaim-fix.patch
> 
> mem_cgroup_reclaim_eligible -> mem_cgroup_within_guarantee
> follow_low_limit -> honor_memcg_guarantee
> and as suggested by Johannes.
> ---
>  include/linux/memcontrol.h |  6 +++---
>  mm/memcontrol.c            | 15 ++++++++-------
>  mm/vmscan.c                | 25 ++++++++++++++++---------
>  3 files changed, 27 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c59056f4bc6..c00ccc5f70b9 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -92,7 +92,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  bool task_in_mem_cgroup(struct task_struct *task,
>  			const struct mem_cgroup *memcg);
>  
> -extern bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> +extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
> @@ -291,10 +291,10 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
>  	return &zone->lruvec;
>  }
>  
> -static inline bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> +static inline bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root)
>  {
> -	return true;
> +	return false;
>  }
>  
>  static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7a276c0d141e..58982d18f6ea 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2810,26 +2810,27 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>  }
>  
>  /**
> - * mem_cgroup_reclaim_eligible - checks whether given memcg is eligible for the
> - * reclaim
> + * mem_cgroup_within_guarantee - checks whether given memcg is within its
> + * memory guarantee
>   * @memcg: target memcg for the reclaim
>   * @root: root of the reclaim hierarchy (null for the global reclaim)
>   *
> - * The given group is reclaimable if it is above its low limit and the same
> - * applies for all parents up the hierarchy until root (including).
> + * The given group is within its reclaim gurantee if it is below its low limit
> + * or the same applies for any parent up the hierarchy until root (including).
> + * Such a group might be excluded from the reclaim.
>   */
> -bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> +bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root)
>  {
>  	do {
>  		if (!res_counter_low_limit_excess(&memcg->res))
> -			return false;
> +			return true;
>  		if (memcg == root)
>  			break;
>  
>  	} while ((memcg = parent_mem_cgroup(memcg)));
>  
> -	return true;
> +	return false;
>  }
>  
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0f428158254e..5f923999bb79 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2215,8 +2215,18 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	}
>  }
>  
> +/**
> + * __shrink_zone - shrinks a given zone
> + *
> + * @zone: zone to shrink
> + * @sc: scan control with additional reclaim parameters
> + * @honor_memcg_guarantee: do not reclaim memcgs which are within their memory
> + * guarantee
> + *
> + * Returns the number of reclaimed memcgs.
> + */
>  static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
> -		bool follow_low_limit)
> +		bool honor_memcg_guarantee)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
>  	unsigned nr_scanned_groups = 0;
> @@ -2236,12 +2246,9 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  		do {
>  			struct lruvec *lruvec;
>  
> -			/*
> -			 * Memcg might be under its low limit so we have to
> -			 * skip it during the first reclaim round
> -			 */
> -			if (follow_low_limit &&
> -					!mem_cgroup_reclaim_eligible(memcg, root)) {
> +			/* Memcg might be protected from the reclaim */
> +			if (honor_memcg_guarantee &&
> +					mem_cgroup_within_guarantee(memcg, root)) {
>  				/*
>  				 * It would be more optimal to skip the memcg
>  				 * subtree now but we do not have a memcg iter
> @@ -2289,8 +2296,8 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  	if (!__shrink_zone(zone, sc, true)) {
>  		/*
>  		 * First round of reclaim didn't find anything to reclaim
> -		 * because of low limit protection so try again and ignore
> -		 * the low limit this time.
> +		 * because of the memory guantees for all memcgs in the
> +		 * reclaim target so try again and ignore guarantees this time.
>  		 */
>  		__shrink_zone(zone, sc, false);
>  	}
> -- 
> 2.0.0.rc0
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
