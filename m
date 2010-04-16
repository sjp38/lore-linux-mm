Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 962566B01EF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 19:14:43 -0400 (EDT)
Date: Sat, 17 Apr 2010 01:14:35 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/10] vmscan: Split shrink_zone to reduce stack usage
Message-ID: <20100416231435.GI20640@cmpxchg.org>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-7-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-7-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:39PM +0100, Mel Gorman wrote:
> shrink_zone() calculculates how many pages it needs to shrink from each
> LRU list in a given pass. It uses a number of temporary variables to
> work this out that then remain on the stack. This patch splits the
> function so that some of the stack variables can be discarded.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
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

Uh, that does not sound very nice!  How about calculate_scan_work() or
something like that?  Might as well use the function to abstract detail :)

Other than that (and with the noinline_for_stack):

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
