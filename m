Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 10D1C6B017A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 03:19:37 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E7Jrqo006438
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 16:19:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5171545DE52
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:19:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DFF245DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:19:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1882C1DB803E
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:19:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C00771DB8037
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:19:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Prevent shrinking of active anon lru list in case of no swap space
In-Reply-To: <20090514141025.239cafe5.minchan.kim@barrios-desktop>
References: <20090514141025.239cafe5.minchan.kim@barrios-desktop>
Message-Id: <20090514155504.9B66.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 16:19:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> 
> Now shrink_active_list is called several places.
> But if we don't have a swap space, we can't reclaim anon pages.
> So, we don't need deactivating anon pages in anon lru list.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>

hm, The analysis seems right. but

In general branch should put into non frequency path.
why caller modification as following patch is wrong?

                        /*
                         * Do some background aging of the anon list, to give
                         * pages a chance to be referenced before reclaiming.
                         */
-                        if (inactive_anon_is_low(zone, &sc))
+                        if (inactive_anon_is_low(zone, &sc) && (nr_swap_pages <= 0))
                                shrink_active_list(SWAP_CLUSTER_MAX, zone,
                                                        &sc, priority, 0);




> ---
>  mm/vmscan.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2f9d555..e4d71f4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1238,6 +1238,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	enum lru_list lru;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  
> +	/* 
> +	 * we can't shrink anon list in case of no swap space.
> +	 */
> +	if (file == 0 && nr_swap_pages <= 0)
> +		return;
> +
>
>  	lru_add_drain();
>  	spin_lock_irq(&zone->lru_lock);
>  	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
> -- 
> 1.5.4.3
> 
> 
> -- 
> Kinds Regards
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
