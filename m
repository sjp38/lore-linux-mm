Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E24F08D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 21:31:48 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAQ2ViTl021643
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Nov 2010 11:31:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A98645DE55
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:31:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D6E5945DE50
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:31:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF065E78007
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:31:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D8701DB801A
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:31:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <1290736844.12777.10.camel@sli10-conroe>
References: <20101125161524.GE26037@csn.ul.ie> <1290736844.12777.10.camel@sli10-conroe>
Message-Id: <20101126110244.B6DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 26 Nov 2010 11:31:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> record the order seems not sufficient. in balance_pgdat(), the for look
> exit only when:
> priority <0 or sc.nr_reclaimed >= SWAP_CLUSTER_MAX.
> but we do if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
>                         order = sc.order = 0;
> this means before we set order to 0, we already reclaimed a lot of
> pages, so I thought we need set order to 0 earlier before there are
> enough free pages. below is a debug patch.
> 
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d31d7ce..ee5d2ed 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2117,6 +2117,26 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  }
>  #endif
>  
> +static int all_zone_enough_free_pages(pg_data_t *pgdat)
> +{
> +	int i;
> +
> +	for (i = 0; i < pgdat->nr_zones; i++) {
> +		struct zone *zone = pgdat->node_zones + i;
> +
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		if (zone->all_unreclaimable)
> +			continue;
> +
> +		if (!zone_watermark_ok(zone, 0, high_wmark_pages(zone) * 8,
> +								0, 0))
> +			return 0;
> +	}
> +	return 1;
> +}
> +
>  /* is kswapd sleeping prematurely? */
>  static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  {
> @@ -2355,7 +2375,8 @@ out:
>  		 * back to sleep. High-order users can still perform direct
>  		 * reclaim if they wish.
>  		 */
> -		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
> +		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX ||
> +		    (order > 0 && all_zone_enough_free_pages(pgdat)))
>  			order = sc.order = 0;

Ummm. this doesn't work. this place is processed every 32 pages reclaimed.
(see below code and comment). Theresore your patch break high order reclaim
logic.


                /*
                 * We do this so kswapd doesn't build up large priorities for
                 * example when it is freeing in parallel with allocators. It
                 * matches the direct reclaim path behaviour in terms of impact
                 * on zone->*_priority.
                 */
                if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
                        break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
