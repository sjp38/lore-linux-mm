Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8A79F6B0212
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 02:27:05 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G6R3cV012764
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 15:27:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6B9145DE54
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:27:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F0C45DE51
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:27:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A3E84E08001
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:27:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 514771DB8017
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:26:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/10] vmscan: Split shrink_zone to reduce stack usage
In-Reply-To: <1271352103-2280-7-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-7-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416115016.279E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 15:26:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> shrink_zone() calculculates how many pages it needs to shrink from each
> LRU list in a given pass. It uses a number of temporary variables to
> work this out that then remain on the stack. This patch splits the
> function so that some of the stack variables can be discarded.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> ---
>  mm/vmscan.c |   29 +++++++++++++++++++----------
>  1 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1ace7c6..a374879 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1595,19 +1595,14 @@ static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
>  	return nr;
>  }
>  
> -/*
> - * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
> - */
> -static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +/* Calculate how many pages from each LRU list should be scanned */
> +static void calc_scan_trybatch(struct zone *zone,
> +				 struct scan_control *sc, unsigned long *nr)
>  {
> -	unsigned long nr[NR_LRU_LISTS];
> -	unsigned long nr_to_scan;
> -	unsigned long percent[2];	/* anon @ 0; file @ 1 */
>  	enum lru_list l;
> -	unsigned long nr_reclaimed = sc->nr_reclaimed;
> -	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> +	unsigned long percent[2];	/* anon @ 0; file @ 1 */
> +	int noswap = 0 ;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> -	int noswap = 0;
>  
>  	/* If we have no swap space, do not bother scanning anon pages. */
>  	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> @@ -1629,6 +1624,20 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  		nr[l] = nr_scan_try_batch(scan,
>  					  &reclaim_stat->nr_saved_scan[l]);
>  	}
> +}
> +
> +/*
> + * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
> + */
> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +{
> +	unsigned long nr[NR_LRU_LISTS];
> +	unsigned long nr_to_scan;
> +	unsigned long nr_reclaimed = sc->nr_reclaimed;
> +	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> +	enum lru_list l;
> +
> +	calc_scan_trybatch(zone, sc, nr);
>  
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
