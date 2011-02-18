Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7117A8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:59:00 -0500 (EST)
Date: Fri, 18 Feb 2011 16:58:27 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 4/4] add profile information for invalidated page
Message-ID: <20110218165827.GB13246@csn.ul.ie>
References: <cover.1297940291.git.minchan.kim@gmail.com> <7563767d6b6e841a8ac5f8315ee166e0f039723c.1297940291.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7563767d6b6e841a8ac5f8315ee166e0f039723c.1297940291.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Feb 18, 2011 at 12:08:22AM +0900, Minchan Kim wrote:
> This patch adds profile information about invalidated page reclaim.
> It's just for profiling for test so it is never for merging.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/vmstat.h |    4 ++--
>  mm/swap.c              |    3 +++
>  mm/vmstat.c            |    3 +++
>  3 files changed, 8 insertions(+), 2 deletions(-)
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
> index 0a33714..980c17b 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -397,6 +397,7 @@ static void lru_deactivate(struct page *page, struct zone *zone)
>  		 * is _really_ small and  it's non-critical problem.
>  		 */
>  		SetPageReclaim(page);
> +		__count_vm_event(PGRECLAIM);
>  	} else {
>  		/*
>  		 * The page's writeback ends up during pagevec

Is this name potentially misleading?

Pages that are reclaimed are accounted for with _steal. It's not particularly
obvious but that's the name it was given. I'd worry that an administrator that
was not aware of *_steal would read pgreclaim as "pages that were reclaimed"
when this is not necessarily the case.

Is there a better name for this? pginvalidate_deferred
or pginvalidate_delayed maybe?

> @@ -409,6 +410,8 @@ static void lru_deactivate(struct page *page, struct zone *zone)
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> +
> +	__count_vm_event(PGINVALIDATE);
>  	update_page_reclaim_stat(zone, page, file, 0);
>  }
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 0c3b504..cbe032b 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -896,6 +896,9 @@ static const char * const vmstat_text[] = {
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
> 1.7.1
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
