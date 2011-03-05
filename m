Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0D88D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 10:21:11 -0500 (EST)
Received: by pzk33 with SMTP id 33so709310pzk.14
        for <linux-mm@kvack.org>; Sat, 05 Mar 2011 07:21:09 -0800 (PST)
Date: Sun, 6 Mar 2011 00:20:57 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-ID: <20110305152056.GA1918@barrios-desktop>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299325456-2687-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
> Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
> kernel may hang up, because shrink_zones() will do nothing, but
> all_unreclaimable() will say, that zone has reclaimable pages.
> 
> do_try_to_free_pages()
> 	shrink_zones()
> 		 for_each_zone
> 			if (zone->all_unreclaimable)
> 				continue
> 	if !all_unreclaimable(zonelist, sc)
> 		return 1
> 
> __alloc_pages_slowpath()
> retry:
> 	did_some_progress = do_try_to_free_pages(page)
> 	...
> 	if (!page && did_some_progress)
> 		retry;
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  mm/vmscan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6771ea7..1c056f7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  			gfp_zone(sc->gfp_mask), sc->nodemask) {
> +		if (zone->all_unreclaimable)
> +			continue;
>  		if (!populated_zone(zone))
>  			continue;
>  		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))


zone_reclaimable checks it. Isn't it enough?
Does the hang up really happen or see it by code review?

> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
