Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 267E26B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:35:54 -0400 (EDT)
Date: Tue, 31 Jul 2012 17:35:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V7 1/2] mm: memcg softlimit reclaim rework
Message-ID: <20120731153550.GA16924@tiehlicka.suse.cz>
References: <1343687533-24117-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343687533-24117-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Sprry for my long silence in the last rounds. I was following
discussions but didn't get to step in.

On Mon 30-07-12 15:32:13, Ying Han wrote:
> This patch reverts all the existing softlimit reclaim implementations and
> instead integrates the softlimit reclaim into existing global reclaim logic.
> 
> The new softlimit reclaim includes the following changes:
 
The patch seems to be doing too many things but I do not want to get
into "split it this way or that way" now. It is probably better to have
it like this for now and take care about these details later.

[...]
> 3. forbid setting soft limit on root cgroup
> 
> Setting a soft limit in the root cgroup does not make sense, as soft limits are
> enforced hierarchically and the root cgroup is the hierarchical parent of every
> other cgroup.  It would not provide the discrimination between groups that soft
> limits are usually used for.
> 
> With the current implementation of soft limits, it would only make global reclaim
> more aggressive compared to target reclaim, but we absolutely don't want anyone
> to rely on this behaviour.

Hmm, maybe this one can go in sooner without the rest.

[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3e0d0cd..59e633c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1866,7 +1866,22 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  	do {
>  		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
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
> +		if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY - 2 ||
> +				mem_cgroup_over_soft_limit(memcg))
> +			shrink_lruvec(lruvec, sc);
>  
>  		/*
>  		 * Limit reclaim has historically picked one memcg and
[...]

Looks quite straightforward. I have to think about it some more but I
like it for starter. Do you have any test results from the overcommitted
system?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
