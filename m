Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AD726B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:29:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1TJHD018736
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:29:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DB9045DE64
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:29:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CDB9D45DE63
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:29:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA49F1DB803B
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:29:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81087E18004
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:29:18 +0900 (JST)
Date: Fri, 10 Dec 2010 10:23:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] mm: kswapd: Treat zone->all_unreclaimable in
 sleeping_prematurely similar to balance_pgdat()
Message-Id: <20101210102337.8ff1fad2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291893500-12342-6-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-6-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  9 Dec 2010 11:18:19 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> After DEF_PRIORITY, balance_pgdat() considers all_unreclaimable zones to
> be balanced but sleeping_prematurely does not. This can force kswapd to
> stay awake longer than it should. This patch fixes it.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Hmm, maybe the logic works well but I don't like very much.

How about adding below instead of pgdat->node_present_pages ?

static unsigned long required_balanced_pages(pgdat, classzone_idx)
{
	unsigned long present = 0;

	for_each_zone_in_node(zone, pgdat) {
		if (zone->all_unreclaimable) /* Ignore unreclaimable zone at checking balance */
			continue;
		if (zone_idx(zone) > classzone_idx)
			continue;
		present = zone->present_pages;
	}
	return present;
}

> ---
>  mm/vmscan.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bc233d8..d7b0a3c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2149,8 +2149,16 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  		if (!populated_zone(zone))
>  			continue;
>  
> -		if (zone->all_unreclaimable)
> +		/*
> +		 * balance_pgdat() skips over all_unreclaimable after
> +		 * DEF_PRIORITY. Effectively, it considers them balanced so
> +		 * they must be considered balanced here as well if kswapd
> +		 * is to sleep
> +		 */
> +		if (zone->all_unreclaimable) {
> +			balanced += zone->present_pages;
>  			continue;
> +		}
>  
>  		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
>  								0, 0))
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
