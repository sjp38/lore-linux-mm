Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 05E616B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 05:17:34 -0400 (EDT)
Date: Fri, 20 Apr 2012 11:17:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 1/2] memcg: softlimit reclaim rework
Message-ID: <20120420091731.GE4191@tiehlicka.suse.cz>
References: <1334680682-12430-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334680682-12430-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue 17-04-12 09:38:02, Ying Han wrote:
> This patch reverts all the existing softlimit reclaim implementations and
> instead integrates the softlimit reclaim into existing global reclaim logic.
> 
> The new softlimit reclaim includes the following changes:
> 
> 1. add function should_reclaim_mem_cgroup()
> 
> Add the filter function should_reclaim_mem_cgroup() under the common function
> shrink_zone(). The later one is being called both from per-memcg reclaim as
> well as global reclaim.
> 
> Today the softlimit takes effect only under global memory pressure. The memcgs
> get free run above their softlimit until there is a global memory contention.
> This patch doesn't change the semantics.

I am not sure I understand but I think it does change the semantics.
Previously we looked at a group with the biggest excess and reclaim that
group _hierarchically_. Now we do not care about hierarchy for soft
limit reclaim. Moreover we do kind-of soft reclaim even from hard limit
reclaim.

> Under the global reclaim, we skip reclaiming from a memcg under its softlimit.
> To prevent reclaim from trying too hard on hitting memcgs (above softlimit) w/
> only hard-to-reclaim pages, the reclaim proirity is used to skip the softlimit
> check. This is a trade-off of system performance and resource isolation.
> 
> 2. detect no memcgs above softlimit under zone reclaim.
> 
> The function zone_reclaimable() marks zone->all_unreclaimable based on
> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is true,
> alloc_pages could go to OOM instead of getting stuck in page reclaim.
> 
> In memcg kernel, cgroup under its softlimit is not targeted under global
> reclaim. It could be possible that all memcgs are under their softlimit for
> a particular zone. So the direct reclaim do_try_to_free_pages() will always
> return 1 which causes the caller __alloc_pages_direct_reclaim() enter tight
> loop.
> 
> The reclaim priority check we put in should_reclaim_mem_cgroup() should help
> this case, but we still don't want to burn cpu cycles for first few priorities
> to get to that point. The idea is from LSF discussion where we detect it after
> the first round of scanning and restart the reclaim by not looking at softlimit
> at all. This allows us to make forward progress on shrink_zone() and free some
> pages on the zone.
> 
> In order to do the detection for scanning all the memcgs under shrink_zone(),
> i have to change the mem_cgroup_iter() from shared walk to full walk. Otherwise,
> it would be very easy to skip lots of memcgs above softlimit and it causes the
> flag "ignore_softlimit" being mistakenly set.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/memcontrol.h |   18 +--
>  include/linux/swap.h       |    4 -
>  mm/memcontrol.c            |  397 +-------------------------------------------
>  mm/vmscan.c                |  113 +++++--------
>  4 files changed, 55 insertions(+), 477 deletions(-)
> 
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1a51868..a5f690b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2128,24 +2128,51 @@ restart:
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
> +
> +	return false;
> +}
> +
>  static void shrink_zone(int priority, struct zone *zone,
>  			struct scan_control *sc)
>  {
>  	struct mem_cgroup *root = sc->target_mem_cgroup;
> -	struct mem_cgroup_reclaim_cookie reclaim = {
> -		.zone = zone,
> -		.priority = priority,
> -	};
>  	struct mem_cgroup *memcg;
> +	int above_softlimit, ignore_softlimit = 0;
> +
>  
> -	memcg = mem_cgroup_iter(root, NULL, &reclaim);
> +restart:
> +	above_softlimit = 0;
> +	memcg = mem_cgroup_iter(root, NULL, NULL);

I am afraid this will not work for hard-limit reclaim. We need the
cookie to remember the last memcg we were shrinking from the hierarchy
otherwise mem_cgroup_reclaim would hammer on the same group again and
again. Consider 
	A (hard limit 30M no pages)
	|- B (10M)
	\- C (20M)

then we could easily end up in OOM, right? And the OOM would be for the
A group which probably doesn't have any processes in it so we will not
make any fwd. process.

>  	do {
>  		struct mem_cgroup_zone mz = {
>  			.mem_cgroup = memcg,
>  			.zone = zone,
>  		};
>  
> -		shrink_mem_cgroup_zone(priority, &mz, sc);
> +		if (ignore_softlimit ||
> +		   should_reclaim_mem_cgroup(root, memcg, priority)) {
> +
> +			shrink_mem_cgroup_zone(priority, &mz, sc);
> +			above_softlimit = 1;
> +		}
> +
>  		/*
>  		 * Limit reclaim has historically picked one memcg and
>  		 * scanned it with decreasing priority levels until
> @@ -2160,8 +2187,13 @@ static void shrink_zone(int priority, struct zone *zone,
>  			mem_cgroup_iter_break(root, memcg);
>  			break;
>  		}
> -		memcg = mem_cgroup_iter(root, memcg, &reclaim);
> +		memcg = mem_cgroup_iter(root, memcg, NULL);
>  	} while (memcg);
> +
> +	if (!above_softlimit) {
> +		ignore_softlimit = 1;
> +		goto restart;
> +	}
>  }
>  
>  /* Returns true if compaction should go ahead for a high-order request */
[...]
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
