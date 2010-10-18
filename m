Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 600CD6B00B9
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 11:44:39 -0400 (EDT)
Date: Mon, 18 Oct 2010 10:44:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
 per cpu page cache flushed
In-Reply-To: <20101018182035.3AFB.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010181034530.1294@router.home>
References: <20101014114541.8B89.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010151224370.24683@router.home> <20101018182035.3AFB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010, KOSAKI Motohiro wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 39c24eb..699cdea 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -185,6 +185,7 @@ struct per_cpu_pageset {
>  #ifdef CONFIG_SMP
>  	s8 stat_threshold;
>  	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
> +	s8 vm_stat_drifted[NR_VM_ZONE_STAT_ITEMS];
>  #endif
>  };

Significantly increases cache footprint for per_cpu_pagesets.

> @@ -168,10 +175,14 @@ void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
>  				int delta)
>  {
>  	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
> -
>  	s8 *p = pcp->vm_stat_diff + item;
>  	long x;
>
> +	if (unlikely(!vm_stat_drift_take(zone, item))) {
> +		zone_page_state_add(delta, zone, item);
> +		return;
> +	}
> +
>  	x = delta + *p;
>
>  	if (unlikely(x > pcp->stat_threshold || x < -pcp->stat_threshold)) {
> @@ -224,6 +235,11 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
>  	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
>  	s8 *p = pcp->vm_stat_diff + item;
>
> +	if (unlikely(!vm_stat_drift_take(zone, item))) {
> +		zone_page_state_add(1, zone, item);
> +		return;
> +	}
> +
>  	(*p)++;
>
>  	if (unlikely(*p > pcp->stat_threshold)) {
> @@ -245,6 +261,11 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
>  	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
>  	s8 *p = pcp->vm_stat_diff + item;
>
> +	if (unlikely(!vm_stat_drift_take(zone, item))) {
> +		zone_page_state_add(-1, zone, item);
> +		return;
> +	}
> +
>  	(*p)--;
>
>  	if (unlikely(*p < - pcp->stat_threshold)) {

Increased overhead for basic VM counter management.

Instead of all of this why not simply set the stat_threshold to 0 for
select cpus?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
