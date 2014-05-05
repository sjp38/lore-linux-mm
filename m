Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id CB9BF6B009C
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:31:50 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1884411eei.33
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:31:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si10578205eeo.34.2014.05.05.08.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:31:49 -0700 (PDT)
Date: Mon, 5 May 2014 17:31:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] mm/memcontrol.c: introduce helper
 mem_cgroup_zoneinfo_zone()
Message-ID: <20140505153144.GD32598@dhcp22.suse.cz>
References: <1397862103-31982-1-git-send-email-nasa4836@gmail.com>
 <20140422095923.GD29311@dhcp22.suse.cz>
 <20140428150426.GB24807@dhcp22.suse.cz>
 <20140501125450.GA23420@cmpxchg.org>
 <20140502150516.d42792bad53d86fb727816bd@linux-foundation.org>
 <20140502232908.GQ23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502232908.GQ23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jianyu Zhan <nasa4836@gmail.com>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.com

On Fri 02-05-14 19:29:08, Johannes Weiner wrote:
[...]
> From: Jianyu Zhan <nasa4836@gmail.com>
> Subject: [patch] mm: memcontrol: clean up memcg zoneinfo lookup
> 
> Memcg zoneinfo lookup sites have either the page, the zone, or the
> node id and zone index, but sites that only have the zone have to look
> up the node id and zone index themselves, whereas sites that already
> have those two integers use a function for a simple pointer chase.
> 
> Provide mem_cgroup_zone_zoneinfo() that takes a zone pointer and let
> sites that already have node id and zone index - all for each node,
> for each zone iterators - use &memcg->nodeinfo[nid]->zoneinfo[zid].
> 
> Rename page_cgroup_zoneinfo() to mem_cgroup_page_zoneinfo() to match.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

OK, this looks better. The naming is more descriptive and it even
removes some code. Good. The opencoded zoneinfo dereference is not that
nice but I guess I can live with it.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 89 +++++++++++++++++++++++++--------------------------------
>  1 file changed, 39 insertions(+), 50 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 29501f040568..83cbd5a0e62f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -677,9 +677,11 @@ static void disarm_static_keys(struct mem_cgroup *memcg)
>  static void drain_all_stock_async(struct mem_cgroup *memcg);
>  
>  static struct mem_cgroup_per_zone *
> -mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
> +mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
>  {
> -	VM_BUG_ON((unsigned)nid >= nr_node_ids);
> +	int nid = zone_to_nid(zone);
> +	int zid = zone_idx(zone);
> +
>  	return &memcg->nodeinfo[nid]->zoneinfo[zid];
>  }
>  
> @@ -689,12 +691,12 @@ struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
>  }
>  
>  static struct mem_cgroup_per_zone *
> -page_cgroup_zoneinfo(struct mem_cgroup *memcg, struct page *page)
> +mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)
>  {
>  	int nid = page_to_nid(page);
>  	int zid = page_zonenum(page);
>  
> -	return mem_cgroup_zoneinfo(memcg, nid, zid);
> +	return &memcg->nodeinfo[nid]->zoneinfo[zid];
>  }
>  
>  static struct mem_cgroup_tree_per_zone *
> @@ -773,16 +775,14 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>  	unsigned long long excess;
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup_tree_per_zone *mctz;
> -	int nid = page_to_nid(page);
> -	int zid = page_zonenum(page);
> -	mctz = soft_limit_tree_from_page(page);
>  
> +	mctz = soft_limit_tree_from_page(page);
>  	/*
>  	 * Necessary to update all ancestors when hierarchy is used.
>  	 * because their event counter is not touched.
>  	 */
>  	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> -		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +		mz = mem_cgroup_page_zoneinfo(memcg, page);
>  		excess = res_counter_soft_limit_excess(&memcg->res);
>  		/*
>  		 * We have to update the tree if mz is on RB-tree or
> @@ -805,14 +805,14 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>  
>  static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>  {
> -	int node, zone;
> -	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup_tree_per_zone *mctz;
> +	struct mem_cgroup_per_zone *mz;
> +	int nid, zid;
>  
> -	for_each_node(node) {
> -		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
> -			mz = mem_cgroup_zoneinfo(memcg, node, zone);
> -			mctz = soft_limit_tree_node_zone(node, zone);
> +	for_each_node(nid) {
> +		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +			mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
> +			mctz = soft_limit_tree_node_zone(nid, zid);
>  			mem_cgroup_remove_exceeded(memcg, mz, mctz);
>  		}
>  	}
> @@ -947,8 +947,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>  	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
>  }
>  
> -unsigned long
> -mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
> +unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>  {
>  	struct mem_cgroup_per_zone *mz;
>  
> @@ -956,46 +955,38 @@ mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>  	return mz->lru_size[lru];
>  }
>  
> -static unsigned long
> -mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
> -			unsigned int lru_mask)
> -{
> -	struct mem_cgroup_per_zone *mz;
> -	enum lru_list lru;
> -	unsigned long ret = 0;
> -
> -	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> -
> -	for_each_lru(lru) {
> -		if (BIT(lru) & lru_mask)
> -			ret += mz->lru_size[lru];
> -	}
> -	return ret;
> -}
> -
> -static unsigned long
> -mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
> -			int nid, unsigned int lru_mask)
> +static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
> +						  int nid,
> +						  unsigned int lru_mask)
>  {
> -	u64 total = 0;
> +	unsigned long nr = 0;
>  	int zid;
>  
> -	for (zid = 0; zid < MAX_NR_ZONES; zid++)
> -		total += mem_cgroup_zone_nr_lru_pages(memcg,
> -						nid, zid, lru_mask);
> +	VM_BUG_ON((unsigned)nid >= nr_node_ids);
> +
> +	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +		struct mem_cgroup_per_zone *mz;
> +		enum lru_list lru;
>  
> -	return total;
> +		for_each_lru(lru) {
> +			if (!(BIT(lru) & lru_mask))
> +				continue;
> +			mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
> +			nr += mz->lru_size[lru];
> +		}
> +	}
> +	return nr;
>  }
>  
>  static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
>  			unsigned int lru_mask)
>  {
> +	unsigned long nr = 0;
>  	int nid;
> -	u64 total = 0;
>  
>  	for_each_node_state(nid, N_MEMORY)
> -		total += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
> -	return total;
> +		nr += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
> +	return nr;
>  }
>  
>  static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
> @@ -1234,11 +1225,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  		int uninitialized_var(seq);
>  
>  		if (reclaim) {
> -			int nid = zone_to_nid(reclaim->zone);
> -			int zid = zone_idx(reclaim->zone);
>  			struct mem_cgroup_per_zone *mz;
>  
> -			mz = mem_cgroup_zoneinfo(root, nid, zid);
> +			mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
>  			iter = &mz->reclaim_iter[reclaim->priority];
>  			if (prev && reclaim->generation != iter->generation) {
>  				iter->last_visited = NULL;
> @@ -1345,7 +1334,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  		goto out;
>  	}
>  
> -	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
> +	mz = mem_cgroup_zone_zoneinfo(memcg, zone);
>  	lruvec = &mz->lruvec;
>  out:
>  	/*
> @@ -1404,7 +1393,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup)
>  		pc->mem_cgroup = memcg = root_mem_cgroup;
>  
> -	mz = page_cgroup_zoneinfo(memcg, page);
> +	mz = mem_cgroup_page_zoneinfo(memcg, page);
>  	lruvec = &mz->lruvec;
>  out:
>  	/*
> @@ -5412,7 +5401,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  
>  		for_each_online_node(nid)
>  			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> -				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +				mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
>  				rstat = &mz->lruvec.reclaim_stat;
>  
>  				recent_rotated[0] += rstat->recent_rotated[0];
> -- 
> 1.9.2
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
