Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2176B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 04:45:39 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so7106808wgh.4
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 01:45:38 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id hs6si18210550wjb.68.2015.01.09.01.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 01:45:38 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id n3so1117430wiv.1
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 01:45:38 -0800 (PST)
Date: Fri, 9 Jan 2015 10:45:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmscan: force scan offline memory cgroups
Message-ID: <20150109094535.GB7596@dhcp22.suse.cz>
References: <20150108170349.GA32079@phnom.home.cmpxchg.org>
 <1420790983-20270-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420790983-20270-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 09-01-15 11:09:43, Vladimir Davydov wrote:
> Since commit b2052564e66d ("mm: memcontrol: continue cache reclaim from
> offlined groups") pages charged to a memory cgroup are not reparented
> when the cgroup is removed. Instead, they are supposed to be reclaimed
> in a regular way, along with pages accounted to online memory cgroups.
> 
> However, an lruvec of an offline memory cgroup will sooner or later get
> so small that it will be scanned only at low scan priorities (see
> get_scan_count()). Therefore, if there are enough reclaimable pages in
> big lruvecs, pages accounted to offline memory cgroups will never be
> scanned at all, wasting memory.
> 
> Fix this by unconditionally forcing scanning dead lruvecs from kswapd.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> Changes in v2:
>  - code style fixes (Johannes)
> 
>  include/linux/memcontrol.h |    6 ++++++
>  mm/memcontrol.c            |   14 ++++++++++++++
>  mm/vmscan.c                |    8 ++++++--
>  3 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 76b4084b8d08..68f3b44ef27c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -102,6 +102,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
>   * For memory reclaim.
>   */
>  int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
> +bool mem_cgroup_lruvec_online(struct lruvec *lruvec);
>  int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
>  void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
> @@ -266,6 +267,11 @@ mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>  	return 1;
>  }
>  
> +bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
> +{
> +	return true;
> +}
> +
>  static inline unsigned long
>  mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bfa1a849d113..67c936bbaa13 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1367,6 +1367,20 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>  	return inactive * inactive_ratio < active;
>  }
>  
> +bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct mem_cgroup *memcg;
> +
> +	if (mem_cgroup_disabled())
> +		return true;
> +
> +	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
> +	memcg = mz->memcg;
> +
> +	return !!(memcg->css.flags & CSS_ONLINE);
> +}
> +
>  #define mem_cgroup_from_counter(counter, member)	\
>  	container_of(counter, struct mem_cgroup, member)
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e29f411b38ac..38173d9a2a87 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1935,8 +1935,12 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
>  	 * latencies, so it's better to scan a minimum amount there as
>  	 * well.
>  	 */
> -	if (current_is_kswapd() && !zone_reclaimable(zone))
> -		force_scan = true;
> +	if (current_is_kswapd()) {
> +		if (!zone_reclaimable(zone))
> +			force_scan = true;
> +		if (!mem_cgroup_lruvec_online(lruvec))
> +			force_scan = true;
> +	}
>  	if (!global_reclaim(sc))
>  		force_scan = true;
>  
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
