Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 21C6B900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:04:27 -0400 (EDT)
Message-ID: <4E0339CF.8080407@draigBrady.com>
Date: Thu, 23 Jun 2011 14:04:15 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <4E0069FE.4000708@draigBrady.com> <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com> <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com> <20110621130756.GH9396@suse.de> <4E00A96D.8020806@draigBrady.com> <20110622094401.GJ9396@suse.de> <4E01C19F.20204@draigBrady.com> <20110623114646.GM9396@suse.de>
In-Reply-To: <20110623114646.GM9396@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 23/06/11 12:46, Mel Gorman wrote:
> Based on the information you have provided from sysrq and the profile,
> I put together a theory as to what is going wrong for your machine at
> least although I somehow doubt the same fix will work for Dan. Can you
> try out the following please? It's against 2.6.38.8 (and presumably
> Fedora) but will apply with offset against 2.6.39 and 3.0-rc4.
> 
> ==== CUT HERE ====
> mm: vmscan: Correct check for kswapd sleeping in sleeping_prematurely
> 
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
> 
> A problem occurs if the highest zone is small that keeps kswapd awake.
> balance_pgdat() only considers unreclaimable zones when priority
> is DEF_PRIORITY but sleeping_prematurely considers all zones. It's
> possible for this sequence to occur
> 
>   1. kswapd wakes up and enters balance_pgdat()
>   2. At DEF_PRIORITY, marks highest zone unreclaimable
>   3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
>   4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
>         highest zone, clearing all_unreclaimable. Highest zone
>         is still unbalanced
>   5. kswapd returns and calls sleeping_prematurely before sleep
>   6. sleeping_prematurely looks at *all* zones, not just the ones
>      being considered by balance_pgdat. The highest small zone
>      has all_unreclaimable cleared but the zone is not
>      balanced. all_zones_ok is false so kswapd stays awake
> 
> The impact is that kswapd chews up a lot of CPU as it avoids most of
> the scheduling points and reclaims excessively from the lower zones.
> This patch corrects the behaviour of sleeping_prematurely to check
> the zones balance_pgdat() checked.
> 
> Reported-by: Padraig Brady <P@draigBrady.com>
> Not-signed-off-awaiting-confirmation: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a74bf72..a578535 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2261,7 +2261,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  		return true;
>  
>  	/* Check the watermark levels */
> -	for (i = 0; i < pgdat->nr_zones; i++) {
> +	for (i = 0; i <= classzone_idx; i++) {
>  		struct zone *zone = pgdat->node_zones + i;
>  
>  		if (!populated_zone(zone))

No joy :(

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
