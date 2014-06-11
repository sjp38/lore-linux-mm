Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 709396B0155
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 11:37:08 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so4481730wgh.35
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 08:37:05 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id u9si22534949wif.62.2014.06.11.08.36.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 08:36:49 -0700 (PDT)
Date: Wed, 11 Jun 2014 11:36:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140611153631.GH2878@cmpxchg.org>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402473624-13827-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 11, 2014 at 10:00:24AM +0200, Michal Hocko wrote:
> Some users (e.g. Google) would like to have stronger semantic than low
> limit offers currently. The fallback mode is not desirable and they
> prefer hitting OOM killer rather than ignoring low limit for protected
> groups.
> 
> There are other possible usecases which can benefit from hard
> guarantees. There are loads which will simply start trashing if the
> memory working set drops under certain level and it is more appropriate
> to simply kill and restart such a load if the required memory cannot
> be provided. Another usecase would be a hard memory isolation for
> containers.
> 
> The min_limit is initialized to 0 and it has precedence over low_limit.
> If the reclaim is not able to find any memcg in the reclaimed hierarchy
> above min_limit then OOM killer is triggered to resolve the situation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 99137aecd95f..8e844bd42c51 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2220,13 +2220,12 @@ static inline bool should_continue_reclaim(struct zone *zone,
>   *
>   * @zone: zone to shrink
>   * @sc: scan control with additional reclaim parameters
> - * @honor_memcg_guarantee: do not reclaim memcgs which are within their memory
> - * guarantee
> + * @soft_guarantee: Use soft guarantee reclaim target for memcg reclaim.
>   *
>   * Returns the number of reclaimed memcgs.
>   */
>  static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
> -		bool honor_memcg_guarantee)
> +		bool soft_guarantee)
>  {
>  	unsigned long nr_reclaimed, nr_scanned;
>  	unsigned nr_scanned_groups = 0;
> @@ -2245,11 +2244,10 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
>  		do {
>  			struct lruvec *lruvec;
> -			bool within_guarantee;
>  
>  			/* Memcg might be protected from the reclaim */
> -			within_guarantee = mem_cgroup_within_guarantee(memcg, root);
> -			if (honor_memcg_guarantee && within_guarantee) {
> +			if (mem_cgroup_within_guarantee(memcg, root,
> +						soft_guarantee)) {
>  				/*
>  				 * It would be more optimal to skip the memcg
>  				 * subtree now but we do not have a memcg iter
> @@ -2259,8 +2257,8 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  				continue;
>  			}
>  
> -			if (within_guarantee)
> -				mem_cgroup_guarantee_breached(memcg);
> +			if (!soft_guarantee)
> +				mem_cgroup_soft_guarantee_breached(memcg);
>  
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  			nr_scanned_groups++;
> @@ -2297,20 +2295,27 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  
>  static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
> -	bool honor_guarantee = true;
> +	bool soft_guarantee = true;
>  
> -	while (!__shrink_zone(zone, sc, honor_guarantee)) {
> +	while (!__shrink_zone(zone, sc, soft_guarantee)) {
>  		/*
>  		 * The previous round of reclaim didn't find anything to scan
>  		 * because
> -		 * a) the whole reclaimed hierarchy is within guarantee so
> -		 *    we fallback to ignore the guarantee because other option
> -		 *    would be the OOM
> +		 * a) the whole reclaimed hierarchy is within soft guarantee so
> +		 *    we are switching to the hard guarantee reclaim target
>  		 * b) multiple reclaimers are racing and so the first round
>  		 *    should be retried
>  		 */
> -		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> -			honor_guarantee = false;
> +		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup,
> +					soft_guarantee)) {
> +			/*
> +			 * Nothing to reclaim even with hard guarantees so
> +			 * we have to OOM
> +			 */
> +			if (!soft_guarantee)
> +				break;
> +			soft_guarantee = false;
> +		}
>  	}
>  }
>  
> @@ -2574,7 +2579,8 @@ out:
>  	 * If the target memcg is not eligible for reclaim then we have no option
>  	 * but OOM
>  	 */
> -	if (!sc->nr_scanned && mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> +	if (!sc->nr_scanned &&
> +			mem_cgroup_all_within_guarantee(sc->target_mem_cgroup, false))
>  		return 0;

This code is truly dreadful.

Don't call it guarantee when it doesn't guarantee anything.  I thought
we agreed that min, low, high, max, is reasonable nomenclature, please
use it consistently.

With my proposed cleanups and scalability fixes in the other mail, the
vmscan.c changes to support the min watermark would be something like
the following.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 687076b7a1a6..cee19b6d04dc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2259,7 +2259,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 				 */
 				if (priority < DEF_PRIORITY - 2)
 					break;
-
+			case MEMCG_WMARK_MIN:
 				/* XXX: skip the whole subtree */
 				memcg = mem_cgroup_iter(root, memcg, &reclaim);
 				continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
