Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id D06E1828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:47:38 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id u188so305888072wmu.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:47:38 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id p1si3190735wjx.81.2016.01.13.08.47.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 08:47:37 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id l65so37823905wmf.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:47:37 -0800 (PST)
Date: Wed, 13 Jan 2016 17:47:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/7] mm: memcontrol: replace mem_cgroup_lruvec_online
 with mem_cgroup_online
Message-ID: <20160113164733.GG17512@dhcp22.suse.cz>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <d8fc0b5bb025b8b8ab2630aaf3a5cd6dc89a693c.1450352792.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8fc0b5bb025b8b8ab2630aaf3a5cd6dc89a693c.1450352792.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 17-12-15 15:29:56, Vladimir Davydov wrote:
> mem_cgroup_lruvec_online() takes lruvec, but it only needs memcg. Since
> get_scan_count(), which is the only user of this function, now possesses
> pointer to memcg, let's pass memcg directly to mem_cgroup_online()
> instead of picking it out of lruvec and rename the function accordingly.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 27 ++++++++++-----------------
>  mm/vmscan.c                |  2 +-
>  2 files changed, 11 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6e0126230878..166661708410 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -355,6 +355,13 @@ static inline bool mem_cgroup_disabled(void)
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
>  }
>  
> +static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
> +{
> +	if (mem_cgroup_disabled())
> +		return true;
> +	return !!(memcg->css.flags & CSS_ONLINE);
> +}
> +
>  /*
>   * For memory reclaim.
>   */
> @@ -363,20 +370,6 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>  void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
>  		int nr_pages);
>  
> -static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
> -{
> -	struct mem_cgroup_per_zone *mz;
> -	struct mem_cgroup *memcg;
> -
> -	if (mem_cgroup_disabled())
> -		return true;
> -
> -	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
> -	memcg = mz->memcg;
> -
> -	return !!(memcg->css.flags & CSS_ONLINE);
> -}
> -
>  static inline
>  unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>  {
> @@ -589,13 +582,13 @@ static inline bool mem_cgroup_disabled(void)
>  	return true;
>  }
>  
> -static inline bool
> -mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
> +static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
>  {
>  	return true;
>  }
>  
> -static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
> +static inline bool
> +mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>  {
>  	return true;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index acc6bff84e26..b220e6cda25d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1988,7 +1988,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	if (current_is_kswapd()) {
>  		if (!zone_reclaimable(zone))
>  			force_scan = true;
> -		if (!mem_cgroup_lruvec_online(lruvec))
> +		if (!mem_cgroup_online(memcg))
>  			force_scan = true;
>  	}
>  	if (!global_reclaim(sc))
> -- 
> 2.1.4
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
