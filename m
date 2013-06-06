Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E4D066B0036
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 00:38:58 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id g10so2806948pdj.13
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 21:38:58 -0700 (PDT)
Date: Wed, 5 Jun 2013 21:38:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: clean up memcg->nodeinfo
In-Reply-To: <1370487934-4547-1-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1306052137370.27104@chino.kir.corp.google.com>
References: <1370487934-4547-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 5 Jun 2013, Johannes Weiner wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ff7b40d..d169a8d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -187,10 +187,6 @@ struct mem_cgroup_per_node {
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
> @@ -384,14 +380,9 @@ struct mem_cgroup {
>  #endif
>  	/* when kmem shrinkers can sleep but can't proceed due to context */
>  	struct work_struct kmemcg_shrink_work;
> -	/*
> -	 * Per cgroup active and inactive list, similar to the
> -	 * per zone LRU lists.
> -	 *
> -	 * WARNING: This has to be the last element of the struct. Don't
> -	 * add new fields after this point.
> -	 */
> -	struct mem_cgroup_lru_info info;
> +
> +	struct mem_cgroup_per_node *nodeinfo[0];
> +	/* WARNING: nodeinfo has to be the last member here */

Nice cleanup, but would this be better as a flexible array member?  It 
would have an incomplete type like it should have instead of sizeof 
returning 0.

>  };
>  
>  static size_t memcg_size(void)
> @@ -777,7 +768,7 @@ static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
>  {
>  	VM_BUG_ON((unsigned)nid >= nr_node_ids);
> -	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
> +	return &memcg->nodeinfo[nid]->zoneinfo[zid];
>  }
>  
>  struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
> @@ -6595,13 +6586,13 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
