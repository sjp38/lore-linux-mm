Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2532A6B00A9
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 00:46:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P4kL2t031979
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 13:46:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6810145DE4F
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:46:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 33BE745DE52
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:46:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E39901DB8055
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:46:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 876FDE38004
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 13:46:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: zone state overhead
In-Reply-To: <20101022141223.GF2160@csn.ul.ie>
References: <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie>
Message-Id: <20101025132824.9176.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 13:46:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> - * Return 1 if free pages are above 'mark'. This takes into account the order
> + * Return true if free pages are above 'mark'. This takes into account the order
>   * of the allocation.
>   */
> -int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> -		      int classzone_idx, int alloc_flags)
> +bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> +		      int classzone_idx, int alloc_flags, long free_pages)

static?


> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c5dfabf..ba0c70a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2082,7 +2082,7 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
>  		if (zone->all_unreclaimable)
>  			continue;
>  
> -		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
> +		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
>  								0, 0))
>  			return 1;
>  	}

Do we need to change balance_pgdat() too?
Otherwise, balance_pgdat() return immediately and can make semi-infinite busy loop.


> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 355a9e6..ddee139 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -81,6 +81,12 @@ EXPORT_SYMBOL(vm_stat);
>  
>  #ifdef CONFIG_SMP
>  
> +static int calculate_pressure_threshold(struct zone *zone)
> +{
> +	return max(1, (int)((high_wmark_pages(zone) - low_wmark_pages(zone) /
> +				num_online_cpus())));
> +}

On Shaohua's machine,

	CPU: 64
	MEM: 8GBx4 (=32GB)
	per-cpu vm-stat threashold: 98

	zone->min = sqrt(32x1024x1024x16)/4 = 5792 KB = 1448 pages
	zone->high - zone->low = zone->min/4 = 362pages
	pressure-vm-threshold = 362/64 ~= 5

Hrm, this reduction seems slightly dramatically (98->5). 
Shaohua, can you please rerun your problem workload on your 64cpus machine with
applying this patch?
Of cource, If there is no performance degression, I'm not against this one.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
