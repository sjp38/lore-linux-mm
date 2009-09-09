Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A94C06B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 05:59:20 -0400 (EDT)
Date: Wed, 9 Sep 2009 10:59:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
	sc->isolate_pages() return value.
Message-ID: <20090909095918.GE24614@csn.ul.ie>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca> <20090903140602.e0169ffc.akpm@linux-foundation.org> <alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca> <20090903154704.da62dd76.akpm@linux-foundation.org> <alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca> <20090904165305.c19429ce.akpm@linux-foundation.org> <20090908132100.GA17446@csn.ul.ie> <alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 03:39:59PM -0700, Vincent Li wrote:
> On Tue, 8 Sep 2009, Mel Gorman wrote:
> 
> > On Fri, Sep 04, 2009 at 04:53:05PM -0700, Andrew Morton wrote:
> > > On Fri, 4 Sep 2009 14:39:32 -0700 (PDT)
> > > Vincent Li <macli@brc.ubc.ca> wrote:
> > > 
> > > Well you want to count two things: 1: how many times nr_taken==0 and 2:
> > > how many times nr_taken!=0.
> > > 
> > 
> > Indeed. I'm not aware of the specifics that led to this patch, but minimally
> > one would be interested in the exact value of nr_taken as it can be used to
> > answer more than one question.
> > 
> > > > Then I got test result with:
> > > > 
> > > > root@kernelhack:/usr/src/mmotm-0903# perf  stat --repeat 5  -e \ 
> > > > kmem:mm_vmscan_isolate_pages hackbench 100
> > > > 
> > > > Running with 100*40 (== 4000) tasks.
> > > > Time: 52.736
> > > > Running with 100*40 (== 4000) tasks.
> > > > Time: 64.982
> > > > Running with 100*40 (== 4000) tasks.
> > > > Time: 56.866
> > > > Running with 100*40 (== 4000) tasks.
> > > > Time: 37.137
> > > > Running with 100*40 (== 4000) tasks.
> > > > Time: 48.415
> > > > 
> > > >  Performance counter stats for 'hackbench 100' (5 runs):
> > > > 
> > > >           14189  kmem:mm_vmscan_isolate_pages   ( +-   9.084% )
> > > > 
> > > >    52.680621973  seconds time elapsed   ( +-   0.689% )
> > > > 
> > > > Is the testing patch written write? I don't understand what the number 
> > > > 14189 means? Does it make any sense?
> > > 
> > 
> > Broadly speaking
> > 
> > "For each of the 5 runs of hackbench, there were 14189 times the
> > kmem:mm_vmscan_isolate_pages was sampled  +/- 9.084%"
> > 
> > Without knowing how many times nr_taken_zero was positive, it's
> > difficult to tell whether 14189 is common or not.
> > 
> > > I don't think you need nr_taken_zeros at all.  You'd want something like
> > > 
> > > 	if (nr_taken == 0)
> > > 		trace_mm_vmscan_nr_taken_zero();
> > > 	else
> > > 		trace_mm_vmscan_nr_taken_nonzero();
> > > 
> > > which would pointlessly generate a huge stream of events which would
> > > have to be added up downstream, which is dumb.
> > > 
> > 
> > Dumb it might be, but perf acts as that aggregator. For the purposes of
> > debugging, it would be fine although it would not be a very suitable pair
> > of events to merge to mainline. A more sensible trace point for mainline
> > would record what nr_taken was so a higher-level tool could answer the zero
> > vs non-zero question or optionally do things like figure out how many pages
> > were being taken of the lists and being put back.
> > 
> > For this question though, use the two tracepoints with no additional parameters
> > and have perf how many times each event occurred.
> 
> Thank you for the explaintion. I am not sure I follow your discussion 
> correctly, no additional parameters means something like:
> 
> TRACE_EVENT(mm_vmscan_nr_taken_zero,
>        TP_PROTO( ),
>        TP_ARGS( ),
>        TP_STRUCT__entry( ),
>        TP_fast_assign( ),
>        TP_printk( )
> );

My bad, I was expecting something like

TRACE_EVENT(mm_vmscan_nr_taken_zero,
	TP_PROTO(void),
	TP_ARGS(),
	TP_printk("nr_taken_zero");
);

to work in the same way it does for DECLARE_TRACE but that is not the
case.

> ? which looks strange to me and does not compile. I guess that is not what 
> you mean.
> 

No, it's what I meant all right. As you were not using the value of
nr_taken, the information was redundant to store in the trace record.

> I ended up with a following patch:
> 
> ----PATCH BEGIN---
> 
> ---
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index eaf46bd..1f9e7bf 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -388,6 +388,42 @@ TRACE_EVENT(mm_page_alloc_extfrag,
>  		__entry->alloc_migratetype == __entry->fallback_migratetype)
>  );
>  
> +TRACE_EVENT(mm_vmscan_nr_taken_zero,
> +
> +	TP_PROTO(unsigned long nr_taken),
> +
> +	TP_ARGS(nr_taken),
> +
> +	TP_STRUCT__entry(
> +		__field(        unsigned long,          nr_taken        )
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nr_taken       = nr_taken;
> +	),
> +
> +	TP_printk("nr_taken=%lu",
> +	__entry->nr_taken)
> +);
> +
> +TRACE_EVENT(mm_vmscan_nr_taken_nonzero,
> +
> +	TP_PROTO(unsigned long nr_taken),
> +
> +	TP_ARGS(nr_taken),
> +
> +	TP_STRUCT__entry(
> +		__field(        unsigned long,          nr_taken        )
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nr_taken       = nr_taken;
> +	),
> +
> +	TP_printk("nr_taken=%lu",
> +		__entry->nr_taken)
> +);
> +
>  #endif /* _TRACE_KMEM_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ad93096..eec4099 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -40,6 +40,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/delayacct.h>
>  #include <linux/sysctl.h>
> +#include <trace/events/kmem.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -1322,7 +1323,9 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
>  
>  	if (nr_taken == 0)
> -		goto done;
> +		trace_mm_vmscan_nr_taken_zero(nr_taken);
> +	else
> +		trace_mm_vmscan_nr_taken_nonzero(nr_taken);
>  
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  	if (file)
> @@ -1388,7 +1391,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  							nr_rotated);
>  	__mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_FILE,
>  							nr_deactivated);
> -done:
>  	spin_unlock_irq(&zone->lru_lock);
>  }
> 
> ----PATCH END---
>  
> /usr/src/mmotm-0903# perf stat --repeat 5 -e kmem:mm_vmscan_nr_taken_zero \
>  -e kmem:mm_vmscan_nr_taken_nonzero hackbench 100
> 
> Running with 100*40 (== 4000) tasks.
> Time: 41.599
> Running with 100*40 (== 4000) tasks.
> Time: 80.192
> Running with 100*40 (== 4000) tasks.
> Time: 26.451
> Running with 100*40 (== 4000) tasks.
> Time: 65.428
> Running with 100*40 (== 4000) tasks.
> Time: 30.054
> 
>  Performance counter stats for 'hackbench 100' (5 runs):
> 
>           10330  kmem:mm_vmscan_nr_taken_zero   ( +-  11.732% )
>            2601  kmem:mm_vmscan_nr_taken_nonzero   ( +-  10.876% )
> 
>    49.509328260  seconds time elapsed   ( +-   0.934% )
> 
> Sampling of nr_taken_zero is way bigger than sampling of nr_taken_nonzero 
> in the 5 hackbench runs. I thought the sampling result would be the 
> opposite. 
> 
> Maybe I get it all wrong :-).
> 

As pointed out in another mail, the remaining question would be if this
situation is specific to a fork-bomb situation like hackbench or whether
it happens in reclaim generally.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
