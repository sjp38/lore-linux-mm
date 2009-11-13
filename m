Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 389696B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 04:54:38 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD9sYFx031127
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 18:54:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 08FFC2AEA83
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 18:54:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C28D11F7045
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 18:54:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C30AEE1800C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 18:54:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 46AF61DB803E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 18:54:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when deciding if kswapd is in trouble
In-Reply-To: <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
Message-Id: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Nov 2009 18:54:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> If reclaim fails to make sufficient progress, the priority is raised.
> Once the priority is higher, kswapd starts waiting on congestion.
> However, on systems with large numbers of high-order atomics due to
> crappy network cards, it's important that kswapd keep working in
> parallel to save their sorry ass.
> 
> This patch takes into account the order kswapd is reclaiming at before
> waiting on congestion. The higher the order, the longer it is before
> kswapd considers itself to be in trouble. The impact is that kswapd
> works harder in parallel rather than depending on direct reclaimers or
> atomic allocations to fail.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ffa1766..5e200f1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1946,7 +1946,7 @@ static int sleeping_prematurely(int order, long remaining)
>  static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>  {
>  	int all_zones_ok;
> -	int priority;
> +	int priority, congestion_priority;
>  	int i;
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> @@ -1967,6 +1967,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>  	 */
>  	int temp_priority[MAX_NR_ZONES];
>  
> +	/*
> +	 * When priority reaches congestion_priority, kswapd will sleep
> +	 * for a short time while congestion clears. The higher the
> +	 * order being reclaimed, the less likely kswapd will go to
> +	 * sleep as high-order allocations are harder to reclaim and
> +	 * stall direct reclaimers longer
> +	 */
> +	congestion_priority = DEF_PRIORITY - 2;
> +	congestion_priority -= min(congestion_priority, sc.order);

This calculation mean

	sc.order	congestion_priority	scan-pages
	---------------------------------------------------------
	0		10			1/1024 * zone-mem
	1		9			1/512  * zone-mem
	2		8			1/256  * zone-mem
	3		7			1/128  * zone-mem
	4		6			1/64   * zone-mem
	5		5			1/32   * zone-mem
	6		4			1/16   * zone-mem
	7		3			1/8    * zone-mem
	8		2			1/4    * zone-mem
	9		1			1/2    * zone-mem
	10		0			1      * zone-mem
	11+		0			1      * zone-mem

I feel this is too agressive. The intention of this congestion_wait()
is to prevent kswapd use 100% cpu time. but the above promotion seems
break it.

example,
ia64 have 256MB hugepage (i.e. order=14). it mean kswapd never sleep.

example2,
order-3 (i.e. PAGE_ALLOC_COSTLY_ORDER) makes one of most inefficent
reclaim, because it doesn't use lumpy recliam.
I've seen 128GB size zone, it mean 1/128 = 1GB. oh well, kswapd definitely
waste cpu time 100%.


> +
>  loop_again:
>  	total_scanned = 0;
>  	sc.nr_reclaimed = 0;
> @@ -2092,7 +2102,7 @@ loop_again:
>  		 * OK, kswapd is getting into trouble.  Take a nap, then take
>  		 * another pass across the zones.
>  		 */
> -		if (total_scanned && priority < DEF_PRIORITY - 2)
> +		if (total_scanned && priority < congestion_priority)
>  			congestion_wait(BLK_RW_ASYNC, HZ/10);

Instead, How about this?



---
 mm/vmscan.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 64e4388..937e90d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1938,6 +1938,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	 * free_pages == high_wmark_pages(zone).
 	 */
 	int temp_priority[MAX_NR_ZONES];
+	int has_under_min_watermark_zone = 0;
 
 loop_again:
 	total_scanned = 0;
@@ -2057,6 +2058,15 @@ loop_again:
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
+
+			/*
+			 * We are still under min water mark. it mean we have
+			 * GFP_ATOMIC allocation failure risk. Hurry up!
+			 */
+			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
+					      end_zone, 0))
+				has_under_min_watermark_zone = 1;
+
 		}
 		if (all_zones_ok)
 			break;		/* kswapd: all done */
@@ -2064,7 +2074,8 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
+		if (total_scanned && (priority < DEF_PRIORITY - 2) &&
+		    !has_under_min_watermark_zone)
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
