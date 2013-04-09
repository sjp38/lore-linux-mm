Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6ADD36B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:57:17 -0400 (EDT)
Message-ID: <51641E62.2070704@parallels.com>
Date: Tue, 9 Apr 2013 17:57:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone shrinking
 code
References: <1365509595-665-1-git-send-email-mhocko@suse.cz> <1365509595-665-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1365509595-665-2-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On 04/09/2013 04:13 PM, Michal Hocko wrote:
> Memcg soft reclaim has been traditionally triggered from the global
> reclaim paths before calling shrink_zone. mem_cgroup_soft_limit_reclaim
> then picked up a group which exceeds the soft limit the most and
> reclaimed it with 0 priority to reclaim at least SWAP_CLUSTER_MAX pages.
> 
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
> Soft reclaim should be applicable also to the targeted reclaim which is
> awkward right now without additional hacks.
> Last but not least the whole infrastructure eats a lot of code[1].
> 
> After this patch shrink_zone is done in 2. First it tries to do the
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
Well, the concept is obviously headed right. Code comments:

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
>  	}
> -	mem_cgroup_iter_break(root_memcg, victim);
> -	return total;
> +
> +	return false;
>  }
>  
good work.
There is a confusion with parent here, but I believe Johnny had already
noted it.

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
> +	/*
> +	 * No group is over the soft limit or those that are do not have
> +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> +	 */
> +	if (do_soft_reclaim && (!nr_shrunk || sc->nr_scanned == nr_scanned)) {
> +		__shrink_zone(zone, sc, false);
> +		return;
> +	}
>  }

If I read this correctly, you stop shrinking when you reach a group in
which you manage to shrink some pages. Is it really what we want?

We have no guarantee that we're now under the soft limit, so shouldn't
we keep shrinking downwards until every parent of ours is within limits ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
