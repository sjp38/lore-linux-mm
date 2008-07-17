Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m6HJI4m3013894
	for <linux-mm@kvack.org>; Fri, 18 Jul 2008 05:18:04 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6HJHbjI1593590
	for <linux-mm@kvack.org>; Fri, 18 Jul 2008 05:17:38 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6HJHb8X000497
	for <linux-mm@kvack.org>; Fri, 18 Jul 2008 05:17:37 +1000
Message-ID: <487F9ACB.3080109@linux.vnet.ibm.com>
Date: Thu, 17 Jul 2008 14:17:31 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mmtom][BUGFIX] vmscan-second-chance-replacement-for-anonymous-pages-fix.patch
References: <20080717122751.92525032.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080717122751.92525032.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Under memcg, active anon tend not to go to inactive anon.
> This will cause OOM in memcg easily when tons of anon was used at once.
> This check was lacked in split-lru.
> 
> This patch is a fix agaisnt
> vmscan-second-chance-replacement-for-anonymous-pages.patch
> 
> 
> Changelog: v1 -> v2:
>  - avoid adding "else".
> 
> Signed-off-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> 
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mmtom-stamp-2008-07-15-15-39/mm/vmscan.c
> ===================================================================
> --- mmtom-stamp-2008-07-15-15-39.orig/mm/vmscan.c
> +++ mmtom-stamp-2008-07-15-15-39/mm/vmscan.c
> @@ -1351,7 +1351,7 @@ static unsigned long shrink_zone(int pri
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
> +	if (!scan_global_lru(sc) || inactive_anon_is_low(zone))
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> 
>  	throttle_vm_writeout(sc->gfp_mask);

I have not seen this, but looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
