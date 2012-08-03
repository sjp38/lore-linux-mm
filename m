Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CA07A6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 11:22:37 -0400 (EDT)
Date: Fri, 3 Aug 2012 17:22:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
Message-ID: <20120803152234.GE8434@dhcp22.suse.cz>
References: <1343942658-13307-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343942658-13307-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 02-08-12 14:24:18, Ying Han wrote:
[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3e0d0cd..88487b3 100644
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
> +		 * - reclaim priority is less than DEF_PRIORITY
> +		 * - mem_cgroup or its ancestor ( not including root cgroup)
> +		 * exceeds its soft limit
> +		 *
> +		 * Note: The priority check is a balance of how hard to
> +		 * preserve the pages under softlimit. If the memcgs of the
> +		 * zone having trouble to reclaim pages above their softlimit,
> +		 * we have to reclaim under softlimit instead of burning more
> +		 * cpu cycles.
> +		 */
> +		if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY ||
> +				mem_cgroup_over_soft_limit(memcg))
> +			shrink_lruvec(lruvec, sc);
>  
>  		/*
>  		 * Limit reclaim has historically picked one memcg and

I am thinking that we could add a constant for the priority
limit. Something like
#define MEMCG_LOW_SOFTLIMIT_PRIORITY	DEF_PRIORITY

Although it doesn't seem necessary at the moment, because there is just
one location where it matters but it could help in the future.
What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
