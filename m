Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2629000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 10:30:14 -0400 (EDT)
Date: Mon, 19 Sep 2011 16:29:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/11] mm: vmscan: distinguish between memcg triggering
 reclaim and memcg being scanned
Message-ID: <20110919142955.GG21847@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-4-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315825048-3437-4-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-09-11 12:57:20, Johannes Weiner wrote:
> Memory cgroup hierarchies are currently handled completely outside of
> the traditional reclaim code, which is invoked with a single memory
> cgroup as an argument for the whole call stack.
> 
> Subsequent patches will switch this code to do hierarchical reclaim,
> so there needs to be a distinction between a) the memory cgroup that
> is triggering reclaim due to hitting its limit and b) the memory
> cgroup that is being scanned as a child of a).
> 
> This patch introduces a struct mem_cgroup_zone that contains the
> combination of the memory cgroup and the zone being scanned, which is
> then passed down the stack instead of the zone argument.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Looks good to me. Some minor comments bellow
Anyways:
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/vmscan.c |  251 +++++++++++++++++++++++++++++++++--------------------------
>  1 files changed, 142 insertions(+), 109 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 354f125..92f4e22 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
[...]
> @@ -1853,13 +1865,13 @@ static int vmscan_swappiness(struct scan_control *sc)
>   *
>   * nr[0] = anon pages to scan; nr[1] = file pages to scan
>   */
> -static void get_scan_count(struct zone *zone, struct scan_control *sc,
> -					unsigned long *nr, int priority)
> +static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
> +			   unsigned long *nr, int priority)
>  {
>  	unsigned long anon, file, free;
>  	unsigned long anon_prio, file_prio;
>  	unsigned long ap, fp;
> -	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> +	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
>  	u64 fraction[2], denominator;
>  	enum lru_list l;
>  	int noswap = 0;

You can save some patch lines by:
	struct zone *zone = mz->zone;
and not doing zone => mz->zone changes that follow.

> @@ -1889,16 +1901,16 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
>  		goto out;
>  	}
>  
> -	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> -		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> -	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> -		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> +	anon  = zone_nr_lru_pages(mz, LRU_ACTIVE_ANON) +
> +		zone_nr_lru_pages(mz, LRU_INACTIVE_ANON);
> +	file  = zone_nr_lru_pages(mz, LRU_ACTIVE_FILE) +
> +		zone_nr_lru_pages(mz, LRU_INACTIVE_FILE);
>  
>  	if (global_reclaim(sc)) {
> -		free  = zone_page_state(zone, NR_FREE_PAGES);
> +		free  = zone_page_state(mz->zone, NR_FREE_PAGES);
>  		/* If we have very few page cache pages,
>  		   force-scan anon pages. */
> -		if (unlikely(file + free <= high_wmark_pages(zone))) {
> +		if (unlikely(file + free <= high_wmark_pages(mz->zone))) {
>  			fraction[0] = 1;
>  			fraction[1] = 0;
>  			denominator = 1;
[...]
> @@ -2390,6 +2413,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +static void age_active_anon(struct zone *zone, struct scan_control *sc,
> +			    int priority)
> +{
> +	struct mem_cgroup_zone mz = {
> +		.mem_cgroup = NULL,
> +		.zone = zone,
> +	};
> +
> +	if (inactive_anon_is_low(&mz))
> +		shrink_active_list(SWAP_CLUSTER_MAX, &mz, sc, priority, 0);
> +}
> +

I do not like this very much because we are using a similar construct in
shrink_mem_cgroup_zone so we are duplicating that code. 
What about adding age_mem_cgroup_active_anon (something like shrink_zone).

>  /*
>   * pgdat_balanced is used when checking if a node is balanced for high-order
>   * allocations. Only zones that meet watermarks and are in a zone allowed
> @@ -2510,7 +2545,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		 */
>  		.nr_to_reclaim = ULONG_MAX,
>  		.order = order,
> -		.mem_cgroup = NULL,
> +		.target_mem_cgroup = NULL,
>  	};
>  	struct shrink_control shrink = {
>  		.gfp_mask = sc.gfp_mask,
> @@ -2549,9 +2584,7 @@ loop_again:
>  			 * Do some background aging of the anon list, to give
>  			 * pages a chance to be referenced before reclaiming.
>  			 */
> -			if (inactive_anon_is_low(zone, &sc))
> -				shrink_active_list(SWAP_CLUSTER_MAX, zone,
> -							&sc, priority, 0);
> +			age_active_anon(zone, &sc, priority);
>  
>  			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), 0, 0)) {

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
