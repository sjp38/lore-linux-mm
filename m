Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 323FB6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 19:28:06 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so992040qwf.44
        for <linux-mm@kvack.org>; Tue, 08 Sep 2009 16:28:14 -0700 (PDT)
Date: Wed, 9 Sep 2009 08:27:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090909082759.7144aaa5.minchan.kim@barrios-desktop>
In-Reply-To: <alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
	<20090903140602.e0169ffc.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca>
	<20090903154704.da62dd76.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca>
	<20090904165305.c19429ce.akpm@linux-foundation.org>
	<20090908132100.GA17446@csn.ul.ie>
	<alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009 15:39:59 -0700 (PDT)
Vincent Li <macli@brc.ubc.ca> wrote:

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
> 
> ? which looks strange to me and does not compile. I guess that is not what 
> you mean.
> 
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

You're right. the experiment said so. 
But hackbench performs fork-bomb test 
so that it makes corner case, I think.
Such a case shows the your patch is good.
But that case is rare. 

The thing remained is to test your patch
in normal case. so you need to test hackbench with 
smaller parameters to make for the number of task 
to fit your memory size but does happen reclaim.

> 
> 
> > 
> > > I don't know if the tracing code is capable of maintaining the counters
> > > for you.  Perhaps you _do_ need nr_taken_zeros.  In which case you want
> > > 
> > > 	if (nr_taken == 0) {
> > > 		nr_taken_zeros++;
> > > 		trace_mm_vmscan_isolate_pages_zero(nr_taken_zeros);
> > > 	} else {
> > > 		nr_taken_nonzeros++;
> > > 		trace_mm_vmscan_isolate_pages_nonzero(nr_taken_nonzeros);
> > > 	}
> > > 
> > > which is awkward.  Mel will know.
> > > 
> > 
> > I am not aware of a way of maintaining counters within tracing. The difficulty
> > is figuring out when that event should be recorded. Worse, the count is
> > being aggregated for all processes that enter this path so there is noise
> > in the value that cannot be filtered out. An aggregated counter like this
> > makes sense when reporting to /proc or for discovering via kgdb, but less
> > suitable for tracing.
> > 
> > > > > 
> > > > > The way I used to do stuff like this is:
> > > > > 
> > > > > int akpm1;
> > > > > int akpm2;
> > > > > 
> > > > > 	...
> > > > > 	if (nr_taken)
> > > > > 		akpm1++;
> > > > > 	else
> > > > > 		akpm2++;
> > > > > 
> > > > > then inspect the values of akpm1 and akpm2 in the running kernel using kgdb.
> > > 
> > > That's looking more attractive ;)
> > > 
> > 
> > It's simplier but it's global in nature so it's harder to figure out how much
> > of the counter is for the target workload and how much of it is everything
> > else. The main advantage of using the two tracepoints is that you know exactly
> > how many of the events were due to hackbench and not the rest of the system.
> > 
> > -- 
> > Mel Gorman
> > Part-time Phd Student                          Linux Technology Center
> > University of Limerick                         IBM Dublin Software Lab
> > 
> > 
> 
> Vincent Li
> Biomedical Research Center
> University of British Columbia


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
