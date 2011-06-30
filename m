Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA256B0092
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 22:24:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4AC073EE0C0
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 11:23:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FA9345DE61
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 11:23:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1473045DE7E
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 11:23:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04DFA1DB8038
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 11:23:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5E6F1DB803A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 11:23:58 +0900 (JST)
Message-ID: <4E0BDE2B.50006@jp.fujitsu.com>
Date: Thu, 30 Jun 2011 11:23:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in
 sleeping_prematurely
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, P@draigBrady.com, James.Bottomley@HansenPartnership.com, colin.king@canonical.com, minchan.kim@gmail.com, luto@mit.edu, riel@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/06/24 23:44), Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
> 
> A problem occurs if the highest zone is small.  balance_pgdat()
> only considers unreclaimable zones when priority is DEF_PRIORITY
> but sleeping_prematurely considers all zones. It's possible for this
> sequence to occur
> 
>   1. kswapd wakes up and enters balance_pgdat()
>   2. At DEF_PRIORITY, marks highest zone unreclaimable
>   3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
>   4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
>         highest zone, clearing all_unreclaimable. Highest zone
>         is still unbalanced
>   5. kswapd returns and calls sleeping_prematurely
>   6. sleeping_prematurely looks at *all* zones, not just the ones
>      being considered by balance_pgdat. The highest small zone
>      has all_unreclaimable cleared but but the zone is not
>      balanced. all_zones_ok is false so kswapd stays awake
> 
> This patch corrects the behaviour of sleeping_prematurely to check
> the zones balance_pgdat() checked.
> 
> Reported-and-tested-by: PA!draig Brady <P@draigBrady.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8ff834e..841e3bf 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2323,7 +2323,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  		return true;
>  
>  	/* Check the watermark levels */
> -	for (i = 0; i < pgdat->nr_zones; i++) {
> +	for (i = 0; i <= classzone_idx; i++) {
>  		struct zone *zone = pgdat->node_zones + i;
>  
>  		if (!populated_zone(zone))

sorry for the delay.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
