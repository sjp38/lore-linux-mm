Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DA28B6B006A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 07:32:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BBX2Ug029909
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 20:33:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 292E545DD74
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:33:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6C7C45DD78
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:33:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8372C1DB801F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:33:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7CB31DB8020
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 20:33:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Count the number of times zone_reclaim() scans and fails
In-Reply-To: <1244717273-15176-4-git-send-email-mel@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie> <1244717273-15176-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20090611203232.6D65.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 20:33:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On NUMA machines, the administrator can configure zone_reclaim_mode that
> is a more targetted form of direct reclaim. On machines with large NUMA
> distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> unmapped pages will be reclaimed if the zone watermarks are not being met.
> 
> There is a heuristic that determines if the scan is worthwhile but it is
> possible that the heuristic will fail and the CPU gets tied up scanning
> uselessly. Detecting the situation requires some guesswork and experimentation
> so this patch adds a counter "zreclaim_failed" to /proc/vmstat. If during
> high CPU utilisation this counter is increasing rapidly, then the resolution
> to the problem may be to set /proc/sys/vm/zone_reclaim_mode to 0.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> ---
>  include/linux/vmstat.h |    3 +++
>  mm/vmscan.c            |    3 +++
>  mm/vmstat.c            |    3 +++
>  3 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ff4696c..416f748 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -36,6 +36,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGSTEAL),
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
>  		FOR_ALL_ZONES(PGSCAN_DIRECT),
> +#ifdef CONFIG_NUMA
> +		PGSCAN_ZONERECLAIM_FAILED,
> +#endif
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
>  #ifdef CONFIG_HUGETLB_PAGE
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7b8eb3f..42c1013 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2492,6 +2492,9 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	ret = __zone_reclaim(zone, gfp_mask, order);
>  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
>  
> +	if (!ret)
> +		count_vm_event(PGSCAN_ZONERECLAIM_FAILED);
> +
>  	return ret;
>  }
>  #endif
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1e3aa81..02677d1 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -673,6 +673,9 @@ static const char * const vmstat_text[] = {
>  	TEXTS_FOR_ZONES("pgscan_kswapd")
>  	TEXTS_FOR_ZONES("pgscan_direct")
>  
> +#ifdef CONFIG_NUMA
> +	"zreclaim_failed",
> +#endif
>  	"pginodesteal",
>  	"slabs_scanned",
>  	"kswapd_steal",

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
