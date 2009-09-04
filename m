Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF9C6B0083
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 19:54:31 -0400 (EDT)
Date: Fri, 4 Sep 2009 16:53:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090904165305.c19429ce.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
	<20090903140602.e0169ffc.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca>
	<20090903154704.da62dd76.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 14:39:32 -0700 (PDT)
Vincent Li <macli@brc.ubc.ca> wrote:

> 
> Ok, I followed the patches above to make following testing code:
> 
> ---
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index eaf46bd..863820a 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -388,6 +388,24 @@ TRACE_EVENT(mm_page_alloc_extfrag,
>  		__entry->alloc_migratetype == __entry->fallback_migratetype)
>  );
>  
> +TRACE_EVENT(mm_vmscan_isolate_pages,
> +
> +	TP_PROTO(int nr_taken_zeros),
> +
> +	TP_ARGS(nr_taken_zeros),
> +
> +	TP_STRUCT__entry(
> +		__field(int,		nr_taken_zeros)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nr_taken_zeros	= nr_taken_zeros;
> +	),
> +
> +	TP_printk("nr_taken_zeros=%d",
> +		__entry->nr_taken_zeros)
> +);
> +
>  #endif /* _TRACE_KMEM_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ad93096..c2cf4dd 100644
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
> @@ -1306,6 +1307,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	unsigned long nr_rotated = 0;
>  	unsigned long nr_deactivated = 0;
> +	int nr_taken_zeros = 0;
>  
>  	lru_add_drain();
>  	spin_lock_irq(&zone->lru_lock);
> @@ -1321,8 +1323,11 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	}
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
>  
> -	if (nr_taken == 0)
> +	if (nr_taken == 0) {
> +		nr_taken_zeros++;
> +		trace_mm_vmscan_isolate_pages(nr_taken_zeros);
>  		goto done;
> +	}
>  
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  	if (file)

Well you want to count two things: 1: how many times nr_taken==0 and 2:
how many times nr_taken!=0.

> Then I got test result with:
> 
> root@kernelhack:/usr/src/mmotm-0903# perf  stat --repeat 5  -e \ 
> kmem:mm_vmscan_isolate_pages hackbench 100
> 
> Running with 100*40 (== 4000) tasks.
> Time: 52.736
> Running with 100*40 (== 4000) tasks.
> Time: 64.982
> Running with 100*40 (== 4000) tasks.
> Time: 56.866
> Running with 100*40 (== 4000) tasks.
> Time: 37.137
> Running with 100*40 (== 4000) tasks.
> Time: 48.415
> 
>  Performance counter stats for 'hackbench 100' (5 runs):
> 
>           14189  kmem:mm_vmscan_isolate_pages   ( +-   9.084% )
> 
>    52.680621973  seconds time elapsed   ( +-   0.689% )
> 
> Is the testing patch written write? I don't understand what the number 
> 14189 means? Does it make any sense?

I don't think you need nr_taken_zeros at all.  You'd want something like

	if (nr_taken == 0)
		trace_mm_vmscan_nr_taken_zero();
	else
		trace_mm_vmscan_nr_taken_nonzero();

which would pointlessly generate a huge stream of events which would
have to be added up downstream, which is dumb.

I don't know if the tracing code is capable of maintaining the counters
for you.  Perhaps you _do_ need nr_taken_zeros.  In which case you want

	if (nr_taken == 0) {
		nr_taken_zeros++;
		trace_mm_vmscan_isolate_pages_zero(nr_taken_zeros);
	} else {
		nr_taken_nonzeros++;
		trace_mm_vmscan_isolate_pages_nonzero(nr_taken_nonzeros);
	}

which is awkward.  Mel will know.

> > 
> > The way I used to do stuff like this is:
> > 
> > int akpm1;
> > int akpm2;
> > 
> > 	...
> > 	if (nr_taken)
> > 		akpm1++;
> > 	else
> > 		akpm2++;
> > 
> > then inspect the values of akpm1 and akpm2 in the running kernel using kgdb.

That's looking more attractive ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
