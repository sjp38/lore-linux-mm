Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D0C496B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 20:59:44 -0500 (EST)
Received: by yxe36 with SMTP id 36so26382925yxe.11
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 17:59:43 -0800 (PST)
Date: Fri, 8 Jan 2010 10:58:41 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
Message-Id: <20100108105841.b9a030c4.minchan.kim@barrios-desktop>
In-Reply-To: <20100107135831.GA29564@csn.ul.ie>
References: <87a5b0801001070434m7f6b0fd6vfcdf49ab73a06cbb@mail.gmail.com>
	<20100107135831.GA29564@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Will Newton <will.newton@gmail.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel 

On Thu, 7 Jan 2010 13:58:31 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> vmscan: kswapd should notice that all zones are not ok if they are unreclaimble
> 
> In the event all zones are unreclaimble, it is possible for kswapd to
> never go to sleep because "all zones are ok even though watermarks are
> not reached". It gets into a situation where cond_reched() is not
> called.
> 
> This patch notes that if all zones are unreclaimable then the zones are
> not ok and cond_resched() should be called.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  mm/vmscan.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2ad8603..d3c0848 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2022,8 +2022,10 @@ loop_again:
>  				break;
>  			}
>  		}
> -		if (i < 0)
> +		if (i < 0) {
> +			all_zones_ok = 0;
>  			goto out;
> +		}
>  
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
> 
> --

Nice catch!
Don't we care following as although it is rare case?

---
                for (i = 0; i <= end_zone; i++) {
                        struct zone *zone = pgdat->node_zones + i; 
                        int nr_slab;
                        int nid, zid; 

                        if (!populated_zone(zone))
                                continue;

                        if (zone_is_all_unreclaimable(zone) &&
                                        priority != DEF_PRIORITY)
                                continue;  <==== here

---

And while I review all_zones_ok'usage in balance_pgdat, 
I feel it's not consistent and rather confused. 
How about this?

== CUT_HERE ==
