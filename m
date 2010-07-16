Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 234076B02AA
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 07:09:19 -0400 (EDT)
Date: Fri, 16 Jul 2010 12:08:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/7] vmscan: convert direct reclaim tracepoint to
	DEFINE_EVENT
Message-ID: <20100716110859.GH13117@csn.ul.ie>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com> <20100716191508.7375.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100716191508.7375.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 07:16:05PM +0900, KOSAKI Motohiro wrote:
> 
> TRACE_EVENT() is a bit old fashion. convert it.
> 

heh, it's not a question of fashion :). It was defined this way because
there wasn't a second user that would use the template. I didn't see the
advantage of creating a template for one user. Your series adds a second
one so it makes sense to convert.

> no functionally change.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/trace/events/vmscan.h |   19 +++++++++++++++++--
>  1 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index b26daa9..bd749c1 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -68,7 +68,7 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
>  		__entry->order)
>  );
>  
> -TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
> +DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
>  
>  	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
>  
> @@ -92,7 +92,15 @@ TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
>  		show_gfp_flags(__entry->gfp_flags))
>  );
>  
> -TRACE_EVENT(mm_vmscan_direct_reclaim_end,
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
> +
> +	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
> +
> +	TP_ARGS(order, may_writepage, gfp_flags)
> +);

Over 80 columns there.

> +
> +
> +DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_end_template,
>  
>  	TP_PROTO(unsigned long nr_reclaimed),
>  
> @@ -109,6 +117,13 @@ TRACE_EVENT(mm_vmscan_direct_reclaim_end,
>  	TP_printk("nr_reclaimed=%lu", __entry->nr_reclaimed)
>  );
>  
> +DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_direct_reclaim_end,
> +
> +	TP_PROTO(unsigned long nr_reclaimed),
> +
> +	TP_ARGS(nr_reclaimed)
> +);
> +

Over 80 columns here too.

I know I broke it multiple times in my last series because I thought it
wasn't enforced any more but I got called on it.


>  TRACE_EVENT(mm_vmscan_lru_isolate,
>  
>  	TP_PROTO(int order,

Otherwise, I can't spot a problem.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
