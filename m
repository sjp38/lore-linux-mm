Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAE0p7mo012786
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 14 Nov 2008 09:51:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C74045DE53
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:51:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 73A0B45DE52
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:51:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C477E08002
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:51:07 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E50781DB8037
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:51:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <20081113171208.6985638e@bree.surriel.com>
References: <20081113171208.6985638e@bree.surriel.com>
Message-Id: <20081114093301.03BC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 14 Nov 2008 09:51:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> Sometimes the VM spends the first few priority rounds rotating back
> referenced pages and submitting IO.  Once we get to a lower priority,
> sometimes the VM ends up freeing way too many pages.
> 
> The fix is relatively simple: in shrink_zone() we can check how many
> pages we have already freed and break out of the loop.
> 
> However, in order to do this we do need to know how many pages we already
> freed, so move nr_reclaimed into scan_control.
> 
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Wow!
Honestly, I prepared the similar patche recently.




> ---
>  mm/vmscan.c |   60 ++++++++++++++++++++++++++++++------------------------------
>  1 file changed, 30 insertions(+), 30 deletions(-)
> 
> Index: linux-2.6.28-rc2-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.28-rc2-mm1.orig/mm/vmscan.c	2008-10-30 15:20:06.000000000 -0400
> +++ linux-2.6.28-rc2-mm1/mm/vmscan.c	2008-11-13 17:08:35.000000000 -0500
> @@ -53,6 +53,9 @@ struct scan_control {
>  	/* Incremented by the number of inactive pages that were scanned */
>  	unsigned long nr_scanned;
>  
> +	/* Number of pages that were freed */
> +	unsigned long nr_reclaimed;
> +
>  	/* This context's GFP mask */
>  	gfp_t gfp_mask;
>  
> @@ -1408,16 +1411,14 @@ static void get_scan_ratio(struct zone *
>  	percent[1] = 100 - percent[0];
>  }
>  
> -
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> -static unsigned long shrink_zone(int priority, struct zone *zone,
> +static void shrink_zone(int priority, struct zone *zone,
>  				struct scan_control *sc)
>  {
>  	unsigned long nr[NR_LRU_LISTS];
>  	unsigned long nr_to_scan;
> -	unsigned long nr_reclaimed = 0;
>  	unsigned long percent[2];	/* anon @ 0; file @ 1 */
>  	enum lru_list l;
>  
> @@ -1458,10 +1459,18 @@ static unsigned long shrink_zone(int pri
>  					(unsigned long)sc->swap_cluster_max);
>  				nr[l] -= nr_to_scan;
>  
> -				nr_reclaimed += shrink_list(l, nr_to_scan,
> +				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
>  							zone, sc, priority);
>  			}
>  		}
> +		/*
> +		 * On large memory systems, scan >> priority can become
> +		 * really large.  This is OK if we need to scan through
> +		 * that many pages (referenced, dirty, etc), but make
> +		 * sure to stop if we already freed enough.
> +		 */
> +		if (sc->nr_reclaimed > sc->swap_cluster_max)
> +			break;
>  	}

There is one risk.
__alloc_pages_internal() has following code,

        pages_reclaimed += did_some_progress;
        do_retry = 0;
        if (!(gfp_mask & __GFP_NORETRY)) {
                if (order <= PAGE_ALLOC_COSTLY_ORDER) {
                        do_retry = 1;
                } else {
                        if (gfp_mask & __GFP_REPEAT &&
                                pages_reclaimed < (1 << order))
                                        do_retry = 1;
                }
                if (gfp_mask & __GFP_NOFAIL)
                        do_retry = 1;
        }


So, reclaim shortcutting can increase the possibility of page allocation 
endless retry on high-order allocation.

Yes, it is the theorical issue.
But we should test it for avoid regression.


Otherthing, looks good to me.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
