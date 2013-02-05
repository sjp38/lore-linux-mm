Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id DA82F6B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 14:04:58 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dr13so415335wgb.26
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 11:04:57 -0800 (PST)
Date: Tue, 5 Feb 2013 20:04:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
Message-ID: <20130205190454.GC3959@dhcp22.suse.cz>
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
 <20130205185324.GB6481@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130205185324.GB6481@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Tue 05-02-13 13:53:24, Johannes Weiner wrote:
[...]
> Subject: [patch] memcg: reduce the size of struct memcg 244-fold morrr fix
> 
> Remove struct mem_cgroup_lru_info.  It only holds the nodeinfo array
> and is actively misleading because there is all kinds of per-node
> stuff in addition to the LRU info in there.  On that note, remove the
> incorrect comment as well.
> 
> Move comment about the nodeinfo[0] array having to be the last field
> in struct mem_cgroup after said array.  Should be more visible when
> attempting to append new members to the struct.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Yes, I like this. The info level is just artificatial and without any
good reason.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2382fe9..29cb9e9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -179,10 +179,6 @@ struct mem_cgroup_per_node {
>  	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
>  };
>  
> -struct mem_cgroup_lru_info {
> -	struct mem_cgroup_per_node *nodeinfo[0];
> -};
> -
>  /*
>   * Cgroups above their limits are maintained in a RB-Tree, independent of
>   * their hierarchy representation
> @@ -370,14 +366,8 @@ struct mem_cgroup {
>  	atomic_t	numainfo_events;
>  	atomic_t	numainfo_updating;
>  #endif
> -	/*
> -	 * Per cgroup active and inactive list, similar to the
> -	 * per zone LRU lists.
> -	 *
> -	 * WARNING: This has to be the last element of the struct. Don't
> -	 * add new fields after this point.
> -	 */
> -	struct mem_cgroup_lru_info info;
> +	struct mem_cgroup_per_node *nodeinfo[0];
> +	/* WARNING: nodeinfo has to be the last member in here */
>  };
>  
>  static inline size_t memcg_size(void)
> @@ -718,7 +708,7 @@ static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
>  {
>  	VM_BUG_ON((unsigned)nid >= nr_node_ids);
> -	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
> +	return &memcg->nodeinfo[nid]->zoneinfo[zid];
>  }
>  
>  struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
> @@ -6093,13 +6083,13 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  		mz->on_tree = false;
>  		mz->memcg = memcg;
>  	}
> -	memcg->info.nodeinfo[node] = pn;
> +	memcg->nodeinfo[node] = pn;
>  	return 0;
>  }
>  
>  static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  {
> -	kfree(memcg->info.nodeinfo[node]);
> +	kfree(memcg->nodeinfo[node]);
>  }
>  
>  static struct mem_cgroup *mem_cgroup_alloc(void)
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
