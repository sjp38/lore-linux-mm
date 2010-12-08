Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 057196B008C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 03:02:48 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB882hux024834
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Dec 2010 17:02:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADDCD45DE4D
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:02:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D19645DD74
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:02:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 800421DB803C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:02:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 381541DB8038
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:02:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v4 5/7] add profile information for invalidated page reclaim
In-Reply-To: <dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
Message-Id: <20101208165944.174D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Dec 2010 17:02:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> This patch adds profile information about invalidated page reclaim.
> It's just for profiling for test so it would be discard when the series
> are merged.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/vmstat.h |    4 ++--
>  mm/swap.c              |    3 +++
>  mm/vmstat.c            |    3 +++
>  3 files changed, 8 insertions(+), 2 deletions(-)

Today, we have tracepoint. tracepoint has no overhead if it's unused.
but vmstat has a overhead even if unused.

Then, all new vmstat proposal should be described why you think it is
frequently used from administrators.




> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 833e676..c38ad95 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -30,8 +30,8 @@
>  
>  enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGALLOC),
> -		PGFREE, PGACTIVATE, PGDEACTIVATE,
> -		PGFAULT, PGMAJFAULT,
> +		PGFREE, PGACTIVATE, PGDEACTIVATE, PGINVALIDATE,
> +		PGRECLAIM, PGFAULT, PGMAJFAULT,
>  		FOR_ALL_ZONES(PGREFILL),
>  		FOR_ALL_ZONES(PGSTEAL),
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
> diff --git a/mm/swap.c b/mm/swap.c
> index 0f23998..2f21e6e 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -317,6 +317,7 @@ static void lru_deactivate(struct page *page, struct zone *zone)
>  		 * is _really_ small and  it's non-critical problem.
>  		 */
>  		SetPageReclaim(page);
> +		__count_vm_event(PGRECLAIM);

Um. No.
This is not reclaim operation anyway. Userland folks shouldn't know
you override PG_reclaim. It's implementaion internal information.



>  	} else {
>  		/*
>  		 * The page's writeback ends up during pagevec
> @@ -328,6 +329,8 @@ static void lru_deactivate(struct page *page, struct zone *zone)
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> +
> +	__count_vm_event(PGINVALIDATE);
>  	update_page_reclaim_stat(zone, page, file, 0);

I have similar complains as above.
If you use PGINVALIDATE, other invalidate pass should update this counter too.


>  }
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 3555636..ef6102d 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -818,6 +818,9 @@ static const char * const vmstat_text[] = {
>  	"pgactivate",
>  	"pgdeactivate",
>  
> +	"pginvalidate",
> +	"pgreclaim",
> +
>  	"pgfault",
>  	"pgmajfault",
>  
> -- 
> 1.7.0.4
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
