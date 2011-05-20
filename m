Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CD3B4900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:50:17 -0400 (EDT)
Date: Fri, 20 May 2011 14:50:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/8] memcg static scan reclaim for asyncrhonous reclaim
Message-Id: <20110520145008.1ea51f41.akpm@linux-foundation.org>
In-Reply-To: <20110520124753.56730b37.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124753.56730b37.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Fri, 20 May 2011 12:47:53 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Ostatic scan rate async memory reclaim for memcg.
> 
> This patch implements a routine for asynchronous memory reclaim for memory
> cgroup, which will be triggered when the usage is near to the limit.
> This patch includes only code codes for memory freeing.
> 
> Asynchronous memory reclaim can be a help for reduce latency because
> memory reclaim goes while an application need to wait or compute something.
> 
> To do memory reclaim in async, we need some thread or worker.
> Unlike node or zones, memcg can be created on demand and there may be
> a system with thousands of memcgs. So, the number of jobs for memcg
> asynchronous memory reclaim can be big number in theory. So, node kswapd
> codes doesn't fit well. And some scheduling on memcg layer will be appreciated.
> 
> This patch implements a static scan rate memory reclaim.
> When shrink_mem_cgroup_static_scan() is called, it scans pages at most
> MEMCG_STATIC_SCAN_LIMIT(2048) pages and returnes how memory shrinking
> was hard. When the function returns false, the caller can assume memory
> reclaim on the memcg seemed difficult and can add some scheduling delay
> for the job.

Fully and carefully define the new term "static scan rate"?

> Note:
>   - I think this concept can be used for enhancing softlimit, too.
>     But need more study.
> 
>
> ...
>
> +		total_scan += nr[l];
> +	}
> +	/*
> +	 * Asynchronous reclaim for memcg uses static scan rate for avoiding
> +	 * too much cpu consumption in a memcg. Adjust the scan count to fit
> +	 * into scan_limit.
> +	 */
> +	if (total_scan > sc->scan_limit) {
> +		for_each_evictable_lru(l) {
> +			if (!nr[l] < SWAP_CLUSTER_MAX)

That statement doesn't do what you think it does!

> +				continue;
> +			nr[l] = div64_u64(nr[l] * sc->scan_limit, total_scan);
> +			nr[l] = max((unsigned long)SWAP_CLUSTER_MAX, nr[l]);
> +		}
>  	}

This gets included in CONFIG_CGROUP_MEM_RES_CTLR=n kernels.  Needlessly?

It also has the potential to affect non-memcg behaviour at runtime.

>  }
>  
> @@ -1938,6 +1955,11 @@ restart:
>  		 */
>  		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
>  			break;
> +		/*
> +		 * static scan rate memory reclaim ?

I still don't know what "static scan rate" means :(

> +		 */
> +		if (sc->nr_scanned > sc->scan_limit)
> +			break;
>  	}
>  	sc->nr_reclaimed += nr_reclaimed;
>  
>
> ...
>
> +static void shrink_mem_cgroup_node(int nid,
> +		int priority, struct scan_control *sc)
> +{
> +	unsigned long this_scanned = 0;
> +	unsigned long this_reclaimed = 0;
> +	int i;
> +
> +	for (i = 0; i < NODE_DATA(nid)->nr_zones; i++) {
> +		struct zone *zone = NODE_DATA(nid)->node_zones + i;
> +
> +		if (!populated_zone(zone))
> +			continue;
> +		if (!mem_cgroup_zone_reclaimable_pages(sc->mem_cgroup, nid, i))
> +			continue;
> +		/* If recent scan didn't go good, do writepate */
> +		sc->nr_scanned = 0;
> +		sc->nr_reclaimed = 0;
> +		shrink_zone(priority, zone, sc);
> +		this_scanned += sc->nr_scanned;
> +		this_reclaimed += sc->nr_reclaimed;
> +		if (this_reclaimed >= sc->nr_to_reclaim)
> +			break;
> +		if (sc->scan_limit < this_scanned)
> +			break;
> +		if (need_resched())
> +			break;

Whoa!  Explain?

> +	}
> +	sc->nr_scanned = this_scanned;
> +	sc->nr_reclaimed = this_reclaimed;
> +	return;
> +}
> +
> +#define MEMCG_ASYNCSCAN_LIMIT		(2048)

Needs documentation.  What happens if I set it to 1024?

> +bool mem_cgroup_shrink_static_scan(struct mem_cgroup *mem, long required)

Exported function has no interface documentation.

`required' appears to have units of "number of pages".  Should be unsigned.

> +{
> +	int nid, priority, noscan;

`noscan' is poorly named and distressingly mysterious.  Basically I
don't have a clue what you're doing with this.

It should be unsigned.

> +	unsigned long total_scanned, total_reclaimed, reclaim_target;
> +	struct scan_control sc = {
> +		.gfp_mask      = GFP_HIGHUSER_MOVABLE,
> +		.may_unmap     = 1,
> +		.may_swap      = 1,
> +		.order         = 0,
> +		/* we don't writepage in our scan. but kick flusher threads */
> +		.may_writepage = 0,
> +	};
> +	struct mem_cgroup *victim, *check_again;
> +	bool congested = true;
> +
> +	total_scanned = 0;
> +	total_reclaimed = 0;
> +	reclaim_target = min(required, MEMCG_ASYNCSCAN_LIMIT/2L);
> +	sc.swappiness = mem_cgroup_swappiness(mem);
> +
> +	noscan = 0;
> +	check_again = NULL;
> +
> +	do {
> +		victim = mem_cgroup_select_victim(mem);
> +
> +		if (!mem_cgroup_test_reclaimable(victim)) {
> +			mem_cgroup_release_victim(victim);
> +			/*
> +			 * if selected a hopeless victim again, give up.
> +		 	 */
> +			if (check_again == victim)
> +				goto out;
> +			if (!check_again)
> +				check_again = victim;
> +		} else
> +			check_again = NULL;
> +	} while (check_again);

What's all this trying to do?

> +	current->flags |= PF_SWAPWRITE;
> +	/*
> +	 * We can use arbitrary priority for our run because we just scan
> +	 * up to MEMCG_ASYNCSCAN_LIMIT and reclaim only the half of it.
> +	 * But, we need to have early-give-up chance for avoid cpu hogging.
> +	 * So, start from a small priority and increase it.
> +	 */
> +	priority = DEF_PRIORITY;
> +
> +	while ((total_scanned < MEMCG_ASYNCSCAN_LIMIT) &&
> +		(total_reclaimed < reclaim_target)) {
> +
> +		/* select a node to scan */
> +		nid = mem_cgroup_select_victim_node(victim);
> +
> +		sc.mem_cgroup = victim;
> +		sc.nr_scanned = 0;
> +		sc.scan_limit = MEMCG_ASYNCSCAN_LIMIT - total_scanned;
> +		sc.nr_reclaimed = 0;
> +		sc.nr_to_reclaim = reclaim_target - total_reclaimed;
> +		shrink_mem_cgroup_node(nid, priority, &sc);
> +		if (sc.nr_scanned) {
> +			total_scanned += sc.nr_scanned;
> +			total_reclaimed += sc.nr_reclaimed;
> +			noscan = 0;
> +		} else
> +			noscan++;
> +		mem_cgroup_release_victim(victim);
> +		/* ok, check condition */
> +		if (total_scanned > total_reclaimed * 2)
> +			wakeup_flusher_threads(sc.nr_scanned);
> +
> +		if (mem_cgroup_async_should_stop(mem))
> +			break;
> +		/* If memory reclaim seems heavy, return that we're congested */
> +		if (total_scanned > MEMCG_ASYNCSCAN_LIMIT/4 &&
> +		    total_scanned > total_reclaimed*8)
> +			break;
> +		/*
> +		 * The whole system is busy or some status update
> +		 * is not synched. It's better to wait for a while.
> +		 */
> +		if ((noscan > 1) || (need_resched()))
> +			break;

So we bale out if there were two priority levels at which
shrink_mem_cgroup_node() didn't scan any pages?  What on earth???

And what was the point in calling shrink_mem_cgroup_node() if it didn't
scan anything?  I could understand using nr_reclaimed...

> +		/* ok, we can do deeper scanning. */
> +		priority--;
> +	}
> +	current->flags &= ~PF_SWAPWRITE;
> +	/*
> +	 * If we successfully freed the half of target, report that
> +	 * memory reclaim went smoothly.
> +	 */
> +	if (total_reclaimed > reclaim_target/2)
> +		congested = false;
> +out:
> +	return congested;
> +}
>  #endif



I dunno, the whole thing seems sprinkled full of arbitrary assumptions
and guess-and-giggle magic numbers.  I expect a lot of this stuff is
just unnecessary.  And if it _is_ necessary then I'd expect there to
be lots of situations and corner cases in which it malfunctions,
because the magic numbers weren't tuned to that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
