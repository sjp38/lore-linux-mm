Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF773900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:34:26 -0400 (EDT)
Date: Wed, 17 Aug 2011 16:34:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 4/6]  memg: calculate numa weight for vmscan
Message-ID: <20110817143418.GC7482@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809191100.6c4c3285.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809191100.6c4c3285.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

Sorry it took so long but I was quite busy recently.

On Tue 09-08-11 19:11:00, KAMEZAWA Hiroyuki wrote:
> caclculate node scan weight.
> 
> Now, memory cgroup selects a scan target node in round-robin.
> It's not very good...there is not scheduling based on page usages.
> 
> This patch is for calculating each node's weight for scanning.
> If weight of a node is high, the node is worth to be scanned.
> 
> The weight is now calucauted on following concept.
> 
>    - make use of swappiness.
>    - If inactive-file is enough, ignore active-file
>    - If file is enough (w.r.t swappiness), ignore anon
>    - make use of recent_scan/rotated reclaim stats.

The concept looks good (see the specific comments bellow). I would
appreciate if the description was more descriptive (especially in the
reclaim statistics part with the reasoning why it is better).
 
> Then, a node contains many inactive file pages will be a 1st victim.
> Node selection logic based on this weight will be in the next patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |  110 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 105 insertions(+), 5 deletions(-)
> 
> Index: mmotm-Aug3/mm/memcontrol.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/memcontrol.c
> +++ mmotm-Aug3/mm/memcontrol.c
[...]
> @@ -1568,18 +1570,108 @@ static bool test_mem_cgroup_node_reclaim
>  }
>  #if MAX_NUMNODES > 1
>  
> +static unsigned long
> +__mem_cgroup_calc_numascan_weight(struct mem_cgroup * memcg,
> +				int nid,
> +				unsigned long anon_prio,
> +				unsigned long file_prio,
> +				int lru_mask)
> +{
> +	u64 file, anon;
> +	unsigned long weight, mask;

mask is not used anywhere.

> +	unsigned long rotated[2], scanned[2];
> +	int zid;
> +
> +	scanned[0] = 0;
> +	scanned[1] = 0;
> +	rotated[0] = 0;
> +	rotated[1] = 0;
> +
> +	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +		struct mem_cgroup_per_zone *mz;
> +
> +		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +		scanned[0] += mz->reclaim_stat.recent_scanned[0];
> +		scanned[1] += mz->reclaim_stat.recent_scanned[1];
> +		rotated[0] += mz->reclaim_stat.recent_rotated[0];
> +		rotated[1] += mz->reclaim_stat.recent_rotated[1];
> +	}
> +	file = mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask & LRU_ALL_FILE);
> +
> +	if (total_swap_pages)

What about ((lru_mask & LRU_ALL_ANON) && total_swap_pages)? Why should
we go down the mem_cgroup_node_nr_lru_pages if are not getting anything?

> +		anon = mem_cgroup_node_nr_lru_pages(memcg,
> +					nid, mask & LRU_ALL_ANON);

btw. s/mask/lru_mask/

> +	else
> +		anon = 0;

Can be initialized during declaration (makes patch smaller).

> +	if (!(file + anon))
> +		node_clear(nid, memcg->scan_nodes);

In that case we can return with 0 right away.

> +
> +	/* 'scanned - rotated/scanned' means ratio of finding not active. */
> +	anon = anon * (scanned[0] - rotated[0]) / (scanned[0] + 1);
> +	file = file * (scanned[1] - rotated[1]) / (scanned[1] + 1);

OK, makes sense. We should not reclaim from nodes that are known to be
hard to reclaim from. We, however, have to be careful to not exclude the
node from reclaiming completely.

> +
> +	weight = (anon * anon_prio + file * file_prio) / 200;

Shouldn't we rather normalize the weight to the node size? This way we
are punishing bigger nodes, aren't we.

> +	return weight;
> +}
> +
> +/*
> + * Calculate each NUMA node's scan weight. scan weight is determined by
> + * amount of pages and recent scan ratio, swappiness.
> + */
> +static unsigned long
> +mem_cgroup_calc_numascan_weight(struct mem_cgroup *memcg)
> +{
> +	unsigned long weight, total_weight;
> +	u64 anon_prio, file_prio, nr_anon, nr_file;
> +	int lru_mask;
> +	int nid;
> +
> +	anon_prio = mem_cgroup_swappiness(memcg) + 1;
> +	file_prio = 200 - anon_prio + 1;

What is +1 good for. I do not see that anon_prio would be used as a
denominator.

> +
> +	lru_mask = BIT(LRU_INACTIVE_FILE);
> +	if (mem_cgroup_inactive_file_is_low(memcg))
> +		lru_mask |= BIT(LRU_ACTIVE_FILE);
> +	/*
> +	 * In vmscan.c, we'll scan anonymous pages with regard to memcg/zone's
> +	 * amounts of file/anon pages and swappiness and reclaim_stat. Here,
> +	 * we try to find good node to be scanned. If the memcg contains enough
> +	 * file caches, we'll ignore anon's weight.
> +	 * (Note) scanning anon-only node tends to be waste of time.
> +	 */
> +
> +	nr_file = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_FILE);
> +	nr_anon = mem_cgroup_nr_lru_pages(memcg, LRU_ALL_ANON);
> +
> +	/* If file cache is small w.r.t swappiness, check anon page's weight */
> +	if (nr_file * file_prio >= nr_anon * anon_prio)
> +		lru_mask |= BIT(LRU_INACTIVE_ANON);

Why we do not care about active anon (e.g. if inactive anon is low)?

> +
> +	total_weight = 0;

Can be initialized during declaration.

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
