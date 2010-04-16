Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A88BE6B01F3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 22:47:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G2luBe016487
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 11:47:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F68945DE4F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:47:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 321BD45DE54
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:47:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1182BE08001
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:47:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD554E08002
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:47:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/10] vmscan: Remove unnecessary temporary vars in do_try_to_free_pages
In-Reply-To: <1271352103-2280-6-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-6-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416114711.2798.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 11:47:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> Remove temporary variable that is only used once and does not help
> clarify code.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> ---
>  mm/vmscan.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 838ac8b..1ace7c6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1685,13 +1685,12 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>   */
>  static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  {
> -	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  	struct zoneref *z;
>  	struct zone *zone;
>  
>  	sc->all_unreclaimable = 1;
> -	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> -					sc->nodemask) {
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> +				gfp_zone(sc->gfp_mask), sc->nodemask) {
>  		if (!populated_zone(zone))
>  			continue;
>  		/*
> @@ -1741,7 +1740,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	unsigned long lru_pages = 0;
>  	struct zoneref *z;
>  	struct zone *zone;
> -	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
>  	unsigned long writeback_threshold;
>  
>  	delayacct_freepages_start();
> @@ -1752,7 +1750,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	 * mem_cgroup will not do shrink_slab.
>  	 */
>  	if (scanning_global_lru(sc)) {
> -		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +		for_each_zone_zonelist(zone, z, zonelist, gfp_zone(sc->gfp_mask)) {
>  
>  			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  				continue;
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
