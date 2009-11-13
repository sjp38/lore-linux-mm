Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8F3306B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:01:45 -0500 (EST)
Date: Sat, 14 Nov 2009 03:00:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when deciding if kswapd is in trouble
In-Reply-To: <20091113135443.GF29804@csn.ul.ie>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com> <20091113135443.GF29804@csn.ul.ie>
Message-Id: <20091114023138.3DA5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> This makes a lot of sense. Tests look good and I added stats to make sure
> the logic was triggering. On X86, kswapd avoided a congestion_wait 11723
> times and X86-64 avoided it 5084 times. I think we should hold onto the
> stats temporarily until all these bugs are ironed out.
> 
> Would you like to sign off the following?
> 
> If you are ok to sign off, this patch should replace my patch 5 in
> the series.

I'm sorry, I found my bug.
Please see below.

> 
> ==== CUT HERE ====
> 
> vmscan: Stop kswapd waiting on congestion when the min watermark is not being met
> 
> If reclaim fails to make sufficient progress, the priority is raised.
> Once the priority is higher, kswapd starts waiting on congestion.  However,
> if the zone is below the min watermark then kswapd needs to continue working
> without delay as there is a danger of an increased rate of GFP_ATOMIC
> allocation failure.
> 
> This patch changes the conditions under which kswapd waits on
> congestion by only going to sleep if the min watermarks are being met.
> 
> [mel@csn.ul.ie: Add stats to track how relevant the logic is]
> Needs-signed-off-by-original-author
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 9716003..7d66695 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  #endif
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
>  		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
> +		KSWAPD_NO_CONGESTION_WAIT,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ffa1766..70967e1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1966,6 +1966,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>  	 * free_pages == high_wmark_pages(zone).
>  	 */
>  	int temp_priority[MAX_NR_ZONES];
> +	int has_under_min_watermark_zone = 0;

This is wrong declaration place.  It must change to

        for (priority = DEF_PRIORITY; priority >= 0; priority--) {
                int end_zone = 0;       /* Inclusive.  0 = ZONE_DMA */
                unsigned long lru_pages = 0;
+                int has_under_min_watermark_zone = 0;


because, has_under_min_watermark_zone should be initialized every priority.


>  loop_again:
>  	total_scanned = 0;
> @@ -2085,6 +2086,15 @@ loop_again:
>  			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
>  			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>  				sc.may_writepage = 1;
> +
> +			/*
> +			 * We are still under min water mark. it mean we have
> +			 * GFP_ATOMIC allocation failure risk. Hurry up!
> +			 */
> +			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +					      end_zone, 0))
> +				has_under_min_watermark_zone = 1;
> +
>  		}
>  		if (all_zones_ok)
>  			break;		/* kswapd: all done */
> @@ -2092,8 +2102,13 @@ loop_again:
>  		 * OK, kswapd is getting into trouble.  Take a nap, then take
>  		 * another pass across the zones.
>  		 */
> -		if (total_scanned && priority < DEF_PRIORITY - 2)
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
> +

This blank line is unnecesary.

> +			if (!has_under_min_watermark_zone)

Probably "if (has_under_min_watermark_zone)" is correct.


> +				count_vm_event(KSWAPD_NO_CONGESTION_WAIT);
> +			else
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		}

Otherthing looks pretty good to me. please feel free to add my s-o-b or reviewed-by.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
