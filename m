Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A7006B01FA
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 22:51:30 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G2pRVG029094
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 11:51:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF42445DE51
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:51:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C3D245DE4F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:51:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 718401DB8038
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:51:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 280541DB803A
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:51:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/10] vmscan: Remove unnecessary temporary variables in shrink_zone()
In-Reply-To: <1271352103-2280-8-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-8-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416115053.27A1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 11:51:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> Two variables are declared that are unnecessary in shrink_zone() as they
> already exist int the scan_control. Remove them
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

ok.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/vmscan.c |    8 ++------
>  1 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a374879..a232ad6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1633,8 +1633,6 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
>  	unsigned long nr_to_scan;
> -	unsigned long nr_reclaimed = sc->nr_reclaimed;
> -	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
>  	enum lru_list l;
>  
>  	calc_scan_trybatch(zone, sc, nr);
> @@ -1647,7 +1645,7 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  						   nr[l], SWAP_CLUSTER_MAX);
>  				nr[l] -= nr_to_scan;
>  
> -				nr_reclaimed += shrink_list(l, nr_to_scan,
> +				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
>  							    zone, sc);
>  			}
>  		}
> @@ -1659,13 +1657,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  		 * with multiple processes reclaiming pages, the total
>  		 * freeing target can get unreasonably large.
>  		 */
> -		if (nr_reclaimed >= nr_to_reclaim &&
> +		if (sc->nr_reclaimed >= sc->nr_to_reclaim &&
>  		    sc->priority < DEF_PRIORITY)
>  			break;
>  	}
>  
> -	sc->nr_reclaimed = nr_reclaimed;
> -
>  	/*
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
