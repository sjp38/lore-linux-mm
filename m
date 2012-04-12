Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id DB7926B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:19:56 -0400 (EDT)
Date: Thu, 12 Apr 2012 02:19:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2 2/5] memcg: add function should_reclaim_mem_cgroup()
Message-ID: <20120412001942.GC1787@cmpxchg.org>
References: <1334181606-26777-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334181606-26777-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 03:00:06PM -0700, Ying Han wrote:
> Add the filter function should_reclaim_mem_cgroup() under the common function
> shrink_zone(). The later one is being called both from per-memcg reclaim as
> well as global reclaim.
> 
> Today the softlimit takes effect only under global memory pressure. The memcgs
> get free run above their softlimit until there is a global memory contention.
> This patch doesn't change the semantics.
> 
> Under the global reclaim, we skip reclaiming from a memcg under its softlimit.
> To prevent reclaim from trying too hard on hitting memcgs (above softlimit) w/
> only hard-to-reclaim pages, the reclaim proirity is used to skip the softlimit
> check. This is a trade-off of system performance and resource isolation.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/memcontrol.h |    7 +++++++
>  mm/memcontrol.c            |   10 +++++++++-
>  mm/vmscan.c                |   25 ++++++++++++++++++++++++-
>  3 files changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index db71193..3d14f90 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -110,6 +110,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
>  				   struct mem_cgroup_reclaim_cookie *);
>  void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
>  
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
> +
>  /*
>   * For memory reclaim.
>   */
> @@ -295,6 +297,11 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
>  {
>  }
>  
> +static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
> +{
> +	return true;
> +}
> +
>  static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
>  {
>  	return 0;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a64093..cffcded 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -358,12 +358,12 @@ enum charge_type {
>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  
> +static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>  #include <net/sock.h>
>  #include <net/ip.h>
>  
> -static bool mem_cgroup_is_root(struct mem_cgroup *memcg);

The prototype is hardly shorter than the friggin function itself!

I'll send a patch to remove this thing completely, doing memcg ==
root_mem_cgroup should be pretty obvious without a helper function.

> @@ -2133,6 +2133,27 @@ restart:
>  	throttle_vm_writeout(sc->gfp_mask);
>  }
>  
> +static bool should_reclaim_mem_cgroup(struct mem_cgroup *target_mem_cgroup,
> +				      struct mem_cgroup *memcg,
> +				      int priority)
> +{
> +	/* Reclaim from mem_cgroup if any of these conditions are met:
> +	 * - This is a global reclaim
> +	 * - reclaim priority is higher than DEF_PRIORITY - 3
> +	 * - mem_cgroup exceeds its soft limit
> +	 *
> +	 * The priority check is a balance of how hard to preserve the pages
> +	 * under softlimit. If the memcgs of the zone having trouble to reclaim
> +	 * pages above their softlimit, we have to reclaim under softlimit
> +	 * instead of burning more cpu cycles.
> +	 */
> +	if (target_mem_cgroup || priority <= DEF_PRIORITY - 3 ||
> +			mem_cgroup_soft_limit_exceeded(memcg))
> +		return true;

The comment is contradicting the code: global reclaim does not scan
unconditionally, hard limit reclaim does.  Global reclaim scans only
if the memcg is above soft limit or if the priority level dropped
sufficiently.

I suppose it's the comment that's wrong, not the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
