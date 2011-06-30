Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4349B6B0082
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 05:06:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BECCC3EE0C0
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:06:18 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A16D145DEB7
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:06:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B12045DEBB
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:06:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EFD511DB8044
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:06:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B07CD1DB8047
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 18:06:17 +0900 (JST)
Message-ID: <4E0C3C77.8010608@jp.fujitsu.com>
Date: Thu, 30 Jun 2011 18:05:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, P@draigBrady.com, James.Bottomley@HansenPartnership.com, colin.king@canonical.com, minchan.kim@gmail.com, luto@mit.edu, riel@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/06/24 23:44), Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.  Unfortunately, if the highest zone is
> small, a problem occurs.
> 
> When balance_pgdat() returns, it may be at a lower classzone_idx than
> it started because the highest zone was unreclaimable. Before checking
> if it should go to sleep though, it checks pgdat->classzone_idx which
> when there is no other activity will be MAX_NR_ZONES-1. It interprets
> this as it has been woken up while reclaiming, skips scheduling and
> reclaims again. As there is no useful reclaim work to do, it enters
> into a loop of shrinking slab consuming loads of CPU until the highest
> zone becomes reclaimable for a long period of time.
> 
> There are two problems here. 1) If the returned classzone or order is
> lower, it'll continue reclaiming without scheduling. 2) if the highest
> zone was marked unreclaimable but balance_pgdat() returns immediately
> at DEF_PRIORITY, the new lower classzone is not communicated back to
> kswapd() for sleeping.
> 
> This patch does two things that are related. If the end_zone is
> unreclaimable, this information is communicated back. Second, if
> the classzone or order was reduced due to failing to reclaim, new
> information is not read from pgdat and instead an attempt is made to go
> to sleep. Due to this, it is also necessary that pgdat->classzone_idx
> be initialised each time to pgdat->nr_zones - 1 to avoid re-reads
> being interpreted as wakeups.
> 
> Reported-and-tested-by: PA!draig Brady <P@draigBrady.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |   34 +++++++++++++++++++++-------------
>  1 files changed, 21 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a76b6cc2..fe854d7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2448,7 +2448,6 @@ loop_again:
>  			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), 0, 0)) {
>  				end_zone = i;
> -				*classzone_idx = i;
>  				break;
>  			}
>  		}
> @@ -2528,8 +2527,11 @@ loop_again:
>  			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>  				sc.may_writepage = 1;
>  
> -			if (zone->all_unreclaimable)
> +			if (zone->all_unreclaimable) {
> +				if (end_zone && end_zone == i)
> +					end_zone--;
>  				continue;
> +			}
>  
>  			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), end_zone, 0)) {
> @@ -2709,8 +2711,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
>   */
>  static int kswapd(void *p)
>  {
> -	unsigned long order;
> -	int classzone_idx;
> +	unsigned long order, new_order;
> +	int classzone_idx, new_classzone_idx;
>  	pg_data_t *pgdat = (pg_data_t*)p;
>  	struct task_struct *tsk = current;
>  
> @@ -2740,17 +2742,23 @@ static int kswapd(void *p)
>  	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
>  	set_freezable();
>  
> -	order = 0;
> -	classzone_idx = MAX_NR_ZONES - 1;
> +	order = new_order = 0;
> +	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
>  	for ( ; ; ) {
> -		unsigned long new_order;
> -		int new_classzone_idx;
>  		int ret;
>  
> -		new_order = pgdat->kswapd_max_order;
> -		new_classzone_idx = pgdat->classzone_idx;
> -		pgdat->kswapd_max_order = 0;
> -		pgdat->classzone_idx = MAX_NR_ZONES - 1;
> +		/*
> +		 * If the last balance_pgdat was unsuccessful it's unlikely a
> +		 * new request of a similar or harder type will succeed soon
> +		 * so consider going to sleep on the basis we reclaimed at
> +		 */
> +		if (classzone_idx >= new_classzone_idx && order == new_order) {

I'm confusing this. If we take a following scenario, new_classzone_idx may be garbage.

1. new_classzone_idx = pgdat->classzone_idx
2. kswapd_try_to_sleep()
3. classzone_idx = pgdat->classzone_idx
4. balance_pgdat()

Wouldn't we need to reinitialize new_classzone_idx nad new_order at kswapd_try_to_sleep()
path too?



> +			new_order = pgdat->kswapd_max_order;
> +			new_classzone_idx = pgdat->classzone_idx;
> +			pgdat->kswapd_max_order =  0;
> +			pgdat->classzone_idx = pgdat->nr_zones - 1;
> +		}
> +
>  		if (order < new_order || classzone_idx > new_classzone_idx) {
>  			/*
>  			 * Don't sleep if someone wants a larger 'order'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
