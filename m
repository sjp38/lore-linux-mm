Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 7952B6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 20:54:07 -0400 (EDT)
Date: Sun, 14 Apr 2013 01:42:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130414004252.GA1330@suse.de>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1365509595-665-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>

On Tue, Apr 09, 2013 at 02:13:13PM +0200, Michal Hocko wrote:
> Memcg soft reclaim has been traditionally triggered from the global
> reclaim paths before calling shrink_zone. mem_cgroup_soft_limit_reclaim
> then picked up a group which exceeds the soft limit the most and
> reclaimed it with 0 priority to reclaim at least SWAP_CLUSTER_MAX pages.
> 

I didn't realise it scanned at priority 0 or else I forgot! Priority 0
scanning means memcg soft reclaim currently scans anon and file equally
with the full LRU of ecah type considered as scan candidates. Consequently,
it will reclaim SWAP_CLUSTER_MAX from each evictable LRU before stopping as
sc->nr_to_reclaim pages have been scanned. It's only partially related to
your series of course this is very blunt behaviour for memcg reclaim. In an
ideal world of infinite free time it might be worth checking what happens
if that thing scans at priority 1 or at least keep an eye on what happens
priority when/if you replace mem_cgroup_shrink_node_zone

> The infrastructure requires per-node-zone trees which hold over-limit
> groups and keep them up-to-date (via memcg_check_events) which is not
> cost free. Although this overhead hasn't turned out to be a bottle neck
> the implementation is suboptimal because mem_cgroup_update_tree has no
> idea which zones consumed memory over the limit so we could easily end
> up having a group on a node-zone tree having only few pages from that
> node-zone.
> 
> This patch doesn't try to fix node-zone trees management because it
> seems that integrating soft reclaim into zone shrinking sounds much
> easier and more appropriate for several reasons.
> First of all 0 priority reclaim was a crude hack which might lead to
> big stalls if the group's LRUs are big and hard to reclaim (e.g. a lot
> of dirty/writeback pages).

Scanning at priority 1 would still be vunerable to this but it might avoid
some of the stalls of anon/file balancing is treated properly.

> Soft reclaim should be applicable also to the targeted reclaim which is
> awkward right now without additional hacks.
> Last but not least the whole infrastructure eats a lot of code[1].
> 
> After this patch shrink_zone is done in 2. First it tries to do the

Done in 2 what? Passes I think.

> soft reclaim if appropriate (only for global reclaim for now to keep
> compatible with the current state) and fall back to ignoring soft limit
> if no group is eligible to soft reclaim or nothing has been scanned
> during the first pass. Only groups which are over their soft limit or
> any of their parent up the hierarchy is over the limit are considered
> eligible during the first pass.
> 
> TODO: remove mem_cgroup_tree_per_zone, mem_cgroup_shrink_node_zone and co.
> but maybe it would be easier for review to remove that code in a separate
> patch...
> 
> ---
> [1] TODO: put size vmlinux before/after whole clean-up
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h |   10 +--
>  mm/memcontrol.c            |  161 ++++++--------------------------------------
>  mm/vmscan.c                |   67 +++++++++++-------
>  3 files changed, 64 insertions(+), 174 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d6183f0..1833c95 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -179,9 +179,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  	mem_cgroup_update_page_stat(page, idx, -1);
>  }
>  
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> -						gfp_t gfp_mask,
> -						unsigned long *total_scanned);
> +bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg);
>  
>  void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>  static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> @@ -358,11 +356,9 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  }
>  
>  static inline
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> -					    gfp_t gfp_mask,
> -					    unsigned long *total_scanned)
> +bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
>  {
> -	return 0;
> +	return false;
>  }
>  
>  static inline void mem_cgroup_split_huge_fixup(struct page *head)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f608546..33424d8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2060,57 +2060,28 @@ static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
>  }
>  #endif
>  
> -static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
> -				   struct zone *zone,
> -				   gfp_t gfp_mask,
> -				   unsigned long *total_scanned)
> -{
> -	struct mem_cgroup *victim = NULL;
> -	int total = 0;
> -	int loop = 0;
> -	unsigned long excess;
> -	unsigned long nr_scanned;
> -	struct mem_cgroup_reclaim_cookie reclaim = {
> -		.zone = zone,
> -		.priority = 0,
> -	};
> +/*
> + * A group is eligible for the soft limit reclaim if it is
> + * 	a) is over its soft limit
> + * 	b) any parent up the hierarchy is over its soft limit
> + */
> +bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *parent = memcg;
>  
> -	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
> -
> -	while (1) {
> -		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
> -		if (!victim) {
> -			loop++;
> -			if (loop >= 2) {
> -				/*
> -				 * If we have not been able to reclaim
> -				 * anything, it might because there are
> -				 * no reclaimable pages under this hierarchy
> -				 */
> -				if (!total)
> -					break;
> -				/*
> -				 * We want to do more targeted reclaim.
> -				 * excess >> 2 is not to excessive so as to
> -				 * reclaim too much, nor too less that we keep
> -				 * coming back to reclaim from this cgroup
> -				 */
> -				if (total >= (excess >> 2) ||
> -					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> -					break;
> -			}
> -			continue;
> -		}
> -		if (!mem_cgroup_reclaimable(victim, false))
> -			continue;
> -		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
> -						     zone, &nr_scanned);
> -		*total_scanned += nr_scanned;
> -		if (!res_counter_soft_limit_excess(&root_memcg->res))
> -			break;
> +	if (res_counter_soft_limit_excess(&memcg->res))
> +		return true;
> +
> +	/*
> +	 * If any parent up the hierarchy is over its soft limit then we
> +	 * have to obey and reclaim from this group as well.
> +	 */
> +	while((parent = parent_mem_cgroup(parent))) {
> +		if (res_counter_soft_limit_excess(&parent->res))
> +			return true;

Remove the initial if with this?

/*
 * If the target memcg or any of its parents are over their soft limit
 * then we have to obey and reclaim from this group as well
 */
do {
	if (res_counter_soft_limit_excess(&memcg->res))
		return true;
while ((memcg = parent_mem_cgroup(memcg));

>  	}
> -	mem_cgroup_iter_break(root_memcg, victim);
> -	return total;
> +
> +	return false;
>  }
>  
>  /*
> @@ -4724,98 +4695,6 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  	return ret;
>  }
>  
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> -					    gfp_t gfp_mask,
> -					    unsigned long *total_scanned)
> -{
> -	unsigned long nr_reclaimed = 0;
> -	struct mem_cgroup_per_zone *mz, *next_mz = NULL;
> -	unsigned long reclaimed;
> -	int loop = 0;
> -	struct mem_cgroup_tree_per_zone *mctz;
> -	unsigned long long excess;
> -	unsigned long nr_scanned;
> -
> -	if (order > 0)
> -		return 0;
> -
> -	mctz = soft_limit_tree_node_zone(zone_to_nid(zone), zone_idx(zone));
> -	/*
> -	 * This loop can run a while, specially if mem_cgroup's continuously
> -	 * keep exceeding their soft limit and putting the system under
> -	 * pressure
> -	 */
> -	do {
> -		if (next_mz)
> -			mz = next_mz;
> -		else
> -			mz = mem_cgroup_largest_soft_limit_node(mctz);
> -		if (!mz)
> -			break;
> -
> -		nr_scanned = 0;
> -		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, zone,
> -						    gfp_mask, &nr_scanned);
> -		nr_reclaimed += reclaimed;
> -		*total_scanned += nr_scanned;
> -		spin_lock(&mctz->lock);
> -
> -		/*
> -		 * If we failed to reclaim anything from this memory cgroup
> -		 * it is time to move on to the next cgroup
> -		 */
> -		next_mz = NULL;
> -		if (!reclaimed) {
> -			do {
> -				/*
> -				 * Loop until we find yet another one.
> -				 *
> -				 * By the time we get the soft_limit lock
> -				 * again, someone might have aded the
> -				 * group back on the RB tree. Iterate to
> -				 * make sure we get a different mem.
> -				 * mem_cgroup_largest_soft_limit_node returns
> -				 * NULL if no other cgroup is present on
> -				 * the tree
> -				 */
> -				next_mz =
> -				__mem_cgroup_largest_soft_limit_node(mctz);
> -				if (next_mz == mz)
> -					css_put(&next_mz->memcg->css);
> -				else /* next_mz == NULL or other memcg */
> -					break;
> -			} while (1);
> -		}
> -		__mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
> -		excess = res_counter_soft_limit_excess(&mz->memcg->res);
> -		/*
> -		 * One school of thought says that we should not add
> -		 * back the node to the tree if reclaim returns 0.
> -		 * But our reclaim could return 0, simply because due
> -		 * to priority we are exposing a smaller subset of
> -		 * memory to reclaim from. Consider this as a longer
> -		 * term TODO.
> -		 */
> -		/* If excess == 0, no tree ops */
> -		__mem_cgroup_insert_exceeded(mz->memcg, mz, mctz, excess);
> -		spin_unlock(&mctz->lock);
> -		css_put(&mz->memcg->css);
> -		loop++;
> -		/*
> -		 * Could not reclaim anything and there are no more
> -		 * mem cgroups to try or we seem to be looping without
> -		 * reclaiming anything.
> -		 */
> -		if (!nr_reclaimed &&
> -			(next_mz == NULL ||
> -			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
> -			break;
> -	} while (!nr_reclaimed);
> -	if (next_mz)
> -		css_put(&next_mz->memcg->css);
> -	return nr_reclaimed;
> -}
> -
>  /**
>   * mem_cgroup_force_empty_list - clears LRU of a group
>   * @memcg: group to clear
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index df78d17..ae3a387 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -138,11 +138,21 @@ static bool global_reclaim(struct scan_control *sc)
>  {
>  	return !sc->target_mem_cgroup;
>  }
> +
> +static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
> +{
> +	return global_reclaim(sc);
> +}
>  #else
>  static bool global_reclaim(struct scan_control *sc)
>  {
>  	return true;
>  }
> +
> +static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
> +{
> +	return false;
> +}
>  #endif
>  
>  static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
> @@ -1942,9 +1952,11 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	}
>  }
>  
> -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +static unsigned
> +__shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
> +	unsigned nr_shrunk = 0;
>  
>  	do {
>  		struct mem_cgroup *root = sc->target_mem_cgroup;
> @@ -1961,6 +1973,13 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  		do {
>  			struct lruvec *lruvec;
>  
> +			if (soft_reclaim &&
> +					!mem_cgroup_soft_reclaim_eligible(memcg)) {
> +				memcg = mem_cgroup_iter(root, memcg, &reclaim);
> +				continue;
> +			}
> +

Calling mem_cgroup_soft_reclaim_eligible means we do multiple searches
of the hierarchy while ascending the hierarchy. It's a stretch but it
may be a problem for very deep hierarchies. Would it be worth having
mem_cgroup_soft_reclaim_eligible return what the highest parent over its soft
limit was and stop the iterator when the highest parent is reached?  I think
this would avoid calling mem_cgroup_soft_reclaim_eligible multiple times.

> +			nr_shrunk++;
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  
>  			shrink_lruvec(lruvec, sc);
> @@ -1984,6 +2003,27 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  		} while (memcg);
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
> +
> +	return nr_shrunk;
> +}
> +
> +
> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +{
> +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> +	unsigned long nr_scanned = sc->nr_scanned;
> +	unsigned nr_shrunk;
> +
> +	nr_shrunk = __shrink_zone(zone, sc, do_soft_reclaim);
> +

The two pass thing is explained in the changelog very well but adding
comments on it here would not hurt.

Otherwise this patch looks like a great idea and memcg soft reclaim looks
a lot less like it's stuck on the side.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
