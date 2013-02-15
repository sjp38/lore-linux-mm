Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0F1976B0007
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 03:08:23 -0500 (EST)
Date: Fri, 15 Feb 2013 09:08:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 3/6] memcg: relax memcg iter caching
Message-ID: <20130215080801.GA31032@dhcp22.suse.cz>
References: <1360848396-16564-1-git-send-email-mhocko@suse.cz>
 <1360848396-16564-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360848396-16564-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 14-02-13 14:26:33, Michal Hocko wrote:
> Now that per-node-zone-priority iterator caches memory cgroups rather
> than their css ids we have to be careful and remove them from the
> iterator when they are on the way out otherwise they might live for
> unbounded amount of time even though their group is already gone (until
> the global/targeted reclaim triggers the zone under priority to find out
> the group is dead and let it to find the final rest).
> 
> We can fix this issue by relaxing rules for the last_visited memcg.
> Instead of taking a reference to the css before it is stored into
> iter->last_visited we can just store its pointer and track the number of
> removed groups from each memcg's subhierarchy.
> 
> This number would be stored into iterator everytime when a memcg is
> cached. If the iter count doesn't match the curent walker root's one we
> will start from the root again. The group counter is incremented upwards
> the hierarchy every time a group is removed.
> 
> The iter_lock can be dropped because racing iterators cannot leak
> the reference anymore as the reference count is not elevated for
> last_visited when it is cached.
> 
> Locking rules got a bit complicated by this change though. The iterator
> primarily relies on rcu read lock which makes sure that once we see
> a valid last_visited pointer then it will be valid for the whole RCU
> walk. smp_rmb makes sure that dead_count is read before last_visited
> and last_dead_count while smp_wmb makes sure that last_visited is
> updated before last_dead_count so the up-to-date last_dead_count cannot
> point to an outdated last_visited. css_tryget then makes sure that
> the last_visited is still alive in case the iteration races with the
> cached group removal (css is invalidated before mem_cgroup_css_offline
> increments dead_count).
> 
> In short:
> mem_cgroup_iter
>  rcu_read_lock()
>  dead_count = atomic_read(parent->dead_count)
>  smp_rmb()
>  if (dead_count != iter->last_dead_count)
>  	last_visited POSSIBLY INVALID -> last_visited = NULL
>  if (!css_tryget(iter->last_visited))
>  	last_visited DEAD -> last_visited = NULL
>  next = find_next(last_visited)
>  css_tryget(next)
>  css_put(last_visited) 	// css would be invalidated and parent->dead_count
>  			// incremented if this was the last reference
>  iter->last_visited = next
>  smp_wmb()
>  iter->last_dead_count = dead_count
>  rcu_read_unlock()
> 
> cgroup_rmdir
>  cgroup_destroy_locked
>   atomic_add(CSS_DEACT_BIAS, &css->refcnt) // subsequent css_tryget fail
>    mem_cgroup_css_offline
>     mem_cgroup_invalidate_reclaim_iterators
>      while(parent = parent_mem_cgroup)
>      	atomic_inc(parent->dead_count)
>   css_put(css) // last reference held by cgroup core
> 
> Spotted-by: Ying Han <yinghan@google.com>
> Original-idea-by: Johannes Weiner <hannes@cmpxchg.org>

I think Johannes deserves s-o-b rather than o-i-b here. I will post this
changed in the next version.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   69 +++++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 52 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e9f5c47..88d5882 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -144,12 +144,15 @@ struct mem_cgroup_stat_cpu {
>  };
>  
>  struct mem_cgroup_reclaim_iter {
> -	/* last scanned hierarchy member with elevated css ref count */
> +	/*
> +	 * last scanned hierarchy member. Valid only if last_dead_count
> +	 * matches memcg->dead_count of the hierarchy root group.
> +	 */
>  	struct mem_cgroup *last_visited;
> +	unsigned long last_dead_count;
> +
>  	/* scan generation, increased every round-trip */
>  	unsigned int generation;
> -	/* lock to protect the position and generation */
> -	spinlock_t iter_lock;
>  };
>  
>  /*
> @@ -357,6 +360,7 @@ struct mem_cgroup {
>  	struct mem_cgroup_stat_cpu nocpu_base;
>  	spinlock_t pcp_counter_lock;
>  
> +	atomic_t	dead_count;
>  #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
>  	struct tcp_memcontrol tcp_mem;
>  #endif
> @@ -1133,6 +1137,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  {
>  	struct mem_cgroup *memcg = NULL;
>  	struct mem_cgroup *last_visited = NULL;
> +	unsigned long uninitialized_var(dead_count);
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> @@ -1161,16 +1166,33 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  
>  			mz = mem_cgroup_zoneinfo(root, nid, zid);
>  			iter = &mz->reclaim_iter[reclaim->priority];
> -			spin_lock(&iter->iter_lock);
>  			last_visited = iter->last_visited;
>  			if (prev && reclaim->generation != iter->generation) {
> -				if (last_visited) {
> -					css_put(&last_visited->css);
> -					iter->last_visited = NULL;
> -				}
> -				spin_unlock(&iter->iter_lock);
> +				iter->last_visited = NULL;
>  				goto out_unlock;
>  			}
> +
> +			/*
> +                         * If the dead_count mismatches, a destruction
> +                         * has happened or is happening concurrently.
> +                         * If the dead_count matches, a destruction
> +                         * might still happen concurrently, but since
> +                         * we checked under RCU, that destruction
> +                         * won't free the object until we release the
> +                         * RCU reader lock.  Thus, the dead_count
> +                         * check verifies the pointer is still valid,
> +                         * css_tryget() verifies the cgroup pointed to
> +                         * is alive.
> +			 */
> +			dead_count = atomic_read(&root->dead_count);
> +			smp_rmb();
> +			last_visited = iter->last_visited;
> +			if (last_visited) {
> +				if ((dead_count != iter->last_dead_count) ||
> +					!css_tryget(&last_visited->css)) {
> +					last_visited = NULL;
> +				}
> +			}
>  		}
>  
>  		/*
> @@ -1210,16 +1232,14 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			if (css && !memcg)
>  				curr = mem_cgroup_from_css(css);
>  
> -			/* make sure that the cached memcg is not removed */
> -			if (curr)
> -				css_get(&curr->css);
>  			iter->last_visited = curr;
> +			smp_wmb();
> +			iter->last_dead_count = dead_count;
>  
>  			if (!css)
>  				iter->generation++;
>  			else if (!prev && memcg)
>  				reclaim->generation = iter->generation;
> -			spin_unlock(&iter->iter_lock);
>  		} else if (css && !memcg) {
>  			last_visited = mem_cgroup_from_css(css);
>  		}
> @@ -6098,12 +6118,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  		return 1;
>  
>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
> -		int prio;
> -
>  		mz = &pn->zoneinfo[zone];
>  		lruvec_init(&mz->lruvec);
> -		for (prio = 0; prio < DEF_PRIORITY + 1; prio++)
> -			spin_lock_init(&mz->reclaim_iter[prio].iter_lock);
>  		mz->usage_in_excess = 0;
>  		mz->on_tree = false;
>  		mz->memcg = memcg;
> @@ -6375,10 +6391,29 @@ free_out:
>  	return ERR_PTR(error);
>  }
>  
> +/*
> + * Announce all parents that a group from their hierarchy is gone.
> + */
> +static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *parent = memcg;
> +
> +	while ((parent = parent_mem_cgroup(parent)))
> +		atomic_inc(&parent->dead_count);
> +
> +	/*
> +	 * if the root memcg is not hierarchical we have to check it
> +	 * explicitely.
> +	 */
> +	if (!root_mem_cgroup->use_hierarchy)
> +		atomic_inc(&root_mem_cgroup->dead_count);
> +}
> +
>  static void mem_cgroup_css_offline(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
> +	mem_cgroup_invalidate_reclaim_iterators(memcg);
>  	mem_cgroup_reparent_charges(memcg);
>  	mem_cgroup_destroy_all_caches(memcg);
>  }
> -- 
> 1.7.10.4
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
