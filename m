Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B59A06B005C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:21:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G3Ljnp016584
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Jul 2009 12:21:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F8C245DE4E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:21:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 818C945DE62
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:21:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 47290E38011
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:21:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB068E3800B
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:21:43 +0900 (JST)
Date: Thu, 16 Jul 2009 12:19:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are
 isolated already
Message-Id: <20090716121956.fc50949f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090715223854.7548740a@bree.surriel.com>
References: <20090715223854.7548740a@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 22:38:53 -0400
Rik van Riel <riel@redhat.com> wrote:

> When way too many processes go into direct reclaim, it is possible
> for all of the pages to be taken off the LRU.  One result of this
> is that the next process in the page reclaim code thinks there are
> no reclaimable pages left and triggers an out of memory kill.
> 
> One solution to this problem is to never let so many processes into
> the page reclaim path that the entire LRU is emptied.  Limiting the
> system to only having half of each inactive list isolated for
> reclaim should be safe.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> This patch goes on top of Kosaki's "Account the number of isolated pages"
> patch series.
> 
>  mm/vmscan.c |   25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> Index: mmotm/mm/vmscan.c
> ===================================================================
> --- mmotm.orig/mm/vmscan.c	2009-07-08 21:37:01.000000000 -0400
> +++ mmotm/mm/vmscan.c	2009-07-08 21:39:02.000000000 -0400
> @@ -1035,6 +1035,27 @@ int isolate_lru_page(struct page *page)
>  }
>  
>  /*
> + * Are there way too many processes in the direct reclaim path already?
> + */
> +static int too_many_isolated(struct zone *zone, int file)
> +{
> +	unsigned long inactive, isolated;
> +
> +	if (current_is_kswapd())
> +		return 0;
> +
> +	if (file) {
> +		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> +		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> +	} else {
> +		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> +		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> +	}
> +
> +	return isolated > inactive;
> +}

Why this means "too much" ?
And, could you put this check under scanning_global_lru(sc) ?

Thanks,
-Kame


> +
> +/*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
>   */
> @@ -1049,6 +1070,10 @@ static unsigned long shrink_inactive_lis
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int lumpy_reclaim = 0;
>  
> +	while (unlikely(too_many_isolated(zone, file))) {
> +		schedule_timeout_interruptible(HZ/10);
> +	}
> +
>  	/*
>  	 * If we need a large contiguous chunk of memory, or have
>  	 * trouble getting a small set of contiguous pages, we
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
