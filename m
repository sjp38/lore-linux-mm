Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 182C26B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 19:05:00 -0400 (EDT)
Message-ID: <501712F7.2010307@redhat.com>
Date: Mon, 30 Jul 2012 19:04:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 1/2] mm: memcg softlimit reclaim rework
References: <1343687533-24117-1-git-send-email-yinghan@google.com>
In-Reply-To: <1343687533-24117-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 07/30/2012 06:32 PM, Ying Han wrote:

> +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> +		/* This is global reclaim, stop at root cgroup */
> +		if (mem_cgroup_is_root(memcg))
> +			break;
> +		if (res_counter_soft_limit_excess(&memcg->res))
> +			return true;
> +	}

I like the simplification of mem_cgroup_over_soft_limit.

> +++ b/mm/vmscan.c
> @@ -1866,7 +1866,22 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>   	do {
>   		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>
> -		shrink_lruvec(lruvec, sc);
> +		/*
> +		 * Reclaim from mem_cgroup if any of these conditions are met:
> +		 * - this is a targetted reclaim ( not global reclaim)
> +		 * - reclaim priority is less than  DEF_PRIORITY - 2
> +		 * - mem_cgroup or its ancestor ( not including root cgroup)
> +		 * exceeds its soft limit
> +		 *
> +		 * Note: The priority check is a balance of how hard to
> +		 * preserve the pages under softlimit. If the memcgs of the
> +		 * zone having trouble to reclaim pages above their softlimit,
> +		 * we have to reclaim under softlimit instead of burning more
> +		 * cpu cycles.
> +		 */
> +		if (!global_reclaim(sc) || sc->priority<  DEF_PRIORITY - 2 ||
> +				mem_cgroup_over_soft_limit(memcg))
> +			shrink_lruvec(lruvec, sc);

This seems like a bad idea.

Once priority hits DEF_PRIORITY-2, we also end up doing various
other things, like sleeping in the main reclaim loop to wait for
IO to finish. If we use DEF_PRIORITY-1 as the threshold to skip
reclaim when no group is over its soft limit, we may end up
sleeping for nothing, and slowing things down terribly.

Let me try to whip up a quick prototype of the LRU weighing idea
I described at LSF/MM in San Francisco...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
