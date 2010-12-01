Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E2606B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:14:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10EJvi009535
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:14:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B334F45DE52
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8157945DE4F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 65B451DB8013
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EF721DB8017
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:14:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
In-Reply-To: <20101130101602.17475.32611.stgit@localhost6.localdomain6>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6> <20101130101602.17475.32611.stgit@localhost6.localdomain6>
Message-Id: <20101130204532.8322.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  1 Dec 2010 09:14:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Provide control using zone_reclaim() and a boot parameter. The
> code reuses functionality from zone_reclaim() to isolate unmapped
> pages and reclaim them as a priority, ahead of other mapped pages.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>  include/linux/swap.h |    5 ++-
>  mm/page_alloc.c      |    7 +++--
>  mm/vmscan.c          |   72 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 79 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index eba53e7..78b0830 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -252,11 +252,12 @@ extern int vm_swappiness;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
>  extern long vm_total_pages;
>  
> -#ifdef CONFIG_NUMA
> -extern int zone_reclaim_mode;
>  extern int sysctl_min_unmapped_ratio;
>  extern int sysctl_min_slab_ratio;
>  extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> +extern bool should_balance_unmapped_pages(struct zone *zone);
> +#ifdef CONFIG_NUMA
> +extern int zone_reclaim_mode;
>  #else
>  #define zone_reclaim_mode 0
>  static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 62b7280..4228da3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1662,6 +1662,9 @@ zonelist_scan:
>  			unsigned long mark;
>  			int ret;
>  
> +			if (should_balance_unmapped_pages(zone))
> +				wakeup_kswapd(zone, order);
> +

You don't have to add extra branch into fast path.


>  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  			if (zone_watermark_ok(zone, order, mark,
>  				    classzone_idx, alloc_flags))
> @@ -4136,10 +4139,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  
>  		zone->spanned_pages = size;
>  		zone->present_pages = realsize;
> -#ifdef CONFIG_NUMA
> -		zone->node = nid;
>  		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
>  						/ 100;
> +#ifdef CONFIG_NUMA
> +		zone->node = nid;
>  		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
>  #endif
>  		zone->name = zone_names[j];
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0ac444f..98950f4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -145,6 +145,21 @@ static DECLARE_RWSEM(shrinker_rwsem);
>  #define scanning_global_lru(sc)	(1)
>  #endif
>  
> +static unsigned long balance_unmapped_pages(int priority, struct zone *zone,
> +						struct scan_control *sc);
> +static int unmapped_page_control __read_mostly;
> +
> +static int __init unmapped_page_control_parm(char *str)
> +{
> +	unmapped_page_control = 1;
> +	/*
> +	 * XXX: Should we tweak swappiness here?
> +	 */
> +	return 1;
> +}
> +__setup("unmapped_page_control", unmapped_page_control_parm);
> +
> +
>  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
>  						  struct scan_control *sc)
>  {
> @@ -2223,6 +2238,12 @@ loop_again:
>  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
>  							&sc, priority, 0);
>  
> +			/*
> +			 * We do unmapped page balancing once here and once
> +			 * below, so that we don't lose out
> +			 */
> +			balance_unmapped_pages(priority, zone, &sc);

You can't invoke any reclaim from here. It is in zone balancing detection
phase. It mean your code reclaim pages from zones which has lots free pages too.

> +
>  			if (!zone_watermark_ok_safe(zone, order,
>  					high_wmark_pages(zone), 0, 0)) {
>  				end_zone = i;
> @@ -2258,6 +2279,11 @@ loop_again:
>  				continue;
>  
>  			sc.nr_scanned = 0;
> +			/*
> +			 * Balance unmapped pages upfront, this should be
> +			 * really cheap
> +			 */
> +			balance_unmapped_pages(priority, zone, &sc);


This code break page-cache/slab balancing logic. And this is conflict
against Nick's per-zone slab effort.

Plus, high-order + priority=5 reclaim Simon's case. (see "Free memory never 
fully used, swapping" threads)

>  
>  			/*
>  			 * Call soft limit reclaim before calling shrink_zone.
> @@ -2491,7 +2517,8 @@ void wakeup_kswapd(struct zone *zone, int order)
>  		pgdat->kswapd_max_order = order;
>  	if (!waitqueue_active(&pgdat->kswapd_wait))
>  		return;
> -	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
> +	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0) &&
> +		!should_balance_unmapped_pages(zone))
>  		return;
>  
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
> @@ -2740,6 +2767,49 @@ zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
>  }
>  
>  /*
> + * Routine to balance unmapped pages, inspired from the code under
> + * CONFIG_NUMA that does unmapped page and slab page control by keeping
> + * min_unmapped_pages in the zone. We currently reclaim just unmapped
> + * pages, slab control will come in soon, at which point this routine
> + * should be called balance cached pages
> + */
> +static unsigned long balance_unmapped_pages(int priority, struct zone *zone,
> +						struct scan_control *sc)
> +{
> +	if (unmapped_page_control &&
> +		(zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
> +		struct scan_control nsc;
> +		unsigned long nr_pages;
> +
> +		nsc = *sc;
> +
> +		nsc.swappiness = 0;
> +		nsc.may_writepage = 0;
> +		nsc.may_unmap = 0;
> +		nsc.nr_reclaimed = 0;

Don't you need to fill nsc.nr_to_reclaim field?

> +
> +		nr_pages = zone_unmapped_file_pages(zone) -
> +				zone->min_unmapped_pages;
> +		/* Magically try to reclaim eighth the unmapped cache pages */
> +		nr_pages >>= 3;

Please don't make magic.

> +
> +		zone_reclaim_unmapped_pages(zone, &nsc, nr_pages);
> +		return nsc.nr_reclaimed;
> +	}
> +	return 0;
> +}
> +
> +#define UNMAPPED_PAGE_RATIO 16

Please don't make magic ratio.

> +bool should_balance_unmapped_pages(struct zone *zone)
> +{
> +	if (unmapped_page_control &&
> +		(zone_unmapped_file_pages(zone) >
> +			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))
> +		return true;
> +	return false;
> +}
> +
> +/*
>   * Try to free up some pages from this zone through reclaim.
>   */
>  static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)


Hmm....

As far as I reviewed, I can't find any reason why this patch works as expected.
So, I think cleancache looks promising more than this idea. Have you seen Dan's
patch? I would suggested discuss him.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
