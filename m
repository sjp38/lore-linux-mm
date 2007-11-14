Date: Wed, 14 Nov 2007 18:41:11 +0000
Subject: Re: [RFC] Page allocator: Get rid of the list of cold pages
Message-ID: <20071114184111.GE773@skynet.ie>
References: <Pine.LNX.4.64.0711122041320.30747@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711122041320.30747@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (12/11/07 20:42), Christoph Lameter didst pronounce:
> We have repeatedly discussed if the cold pages still have a point.

Yep, no one would put their neck out and say whether it is or not.

> There is
> one way to join the two lists: Use a single list and put the cold pages at the
> end and the hot pages at the beginning. That way a single list can serve for
> both types of allocations.
> 

For sure.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 


What was this based against? It didn't apply cleanly to 2.6.24-rc2 but it
was fairly trivial to fix up the rejects. I tested on a few machines just
to see what happened. The performance results for kernbench, dbench, tbench
and aim9[1] and were generally good.

First up is elm3b6 (from tko). It's a 4-way Opteron with 8GiB of RAM.
The results were

KernBench Timing Comparison
---------------------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
User   CPU time                         445.99                    445.60 0.09%
System CPU time                          41.72                     41.37 0.84%
Total  CPU time                         487.71                    486.97 0.15%
Elapsed    time                         125.93                    125.93 0.00%

KernBench Deviation Comparison
------------------------------
User   CPU stddev                         0.14                      0.10 28.57%
System CPU stddev                         0.22                      0.01 95.45%
Total  CPU stddev                         0.09                      0.11 -22.22%
Elapsed    stddev                         0.07                      0.10 -42.86%

AIM9 Comparison
---------------
                 2.6.24-rc2-clean  2.6.24-rc2-one-percpu
 1 creat-clo            139360.11              152057.99   12697.88 9.11% File Creations and Closes/second
 2 page_test            242747.88              272322.95   29575.07 12.18% System Allocations & Pages/second
 3 brk_test             918260.58             1287183.33  368922.75 40.18% System Memory Allocations/second
 4 jmp_test           11710264.96            11718963.51    8698.55 0.07% Non-local gotos/second
 5 signal_test          460523.25              477037.16   16513.91 3.59% Signal Traps/second
 6 exec_test               174.33                 176.52       2.19 1.26% Program Loads/second
 7 fork_test              3013.49                3237.25     223.76 7.43% Task Creations/second
 8 link_test             46963.45               51495.15    4531.70 9.65% Link/Unlink Pairs/second

DBench Comparison
-----------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
Throughput  1 procs                    206.819                   206.269 -0.27%

TBench Comparison
-----------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
Throughput 1 proc                      170.291                   147.613 -13.32%

Generally good there. I wouldn't worry too much about dbench and tbench on
this machine because it tends to be flaky anyway on this machine. I thought
it was interesting that both the System CPU and User CPU times were improved
for kernbench. It implies that the allocator is doing less work but not
getting punished by worse cache hotness.

Next up is a 2-way opteron with 2GB of RAM.

KernBench Timing Comparison
---------------------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
User   CPU time                         268.90                    269.33 -0.16%
System CPU time                          37.88                     36.35 4.04%
Total  CPU time                         306.78                    305.68 0.36%
Elapsed    time                         155.99                    155.43 0.36%

KernBench Deviation Comparison
------------------------------
User   CPU stddev                         0.02                      0.15 -650.00%
System CPU stddev                         0.09                      0.09 0.00%
Total  CPU stddev                         0.07                      0.05 28.57%
Elapsed    stddev                         0.11                      0.11 0.00%

AIM9 Comparison
---------------
                 2.6.24-rc2-clean  2.6.24-rc2-one-percpu
 1 creat-clo            149125.15              154624.23    5499.08 3.69% File Creations and Closes/second
 2 page_test            170566.57              169433.43   -1133.14 -0.66% System Allocations & Pages/second
 3 brk_test            2508498.58             1879603.40 -628895.18 -25.07% System Memory Allocations/second
 4 jmp_test           24270950.00            24286333.33   15383.33 0.06% Non-local gotos/second
 5 signal_test          574466.67              500466.67  -74000.00 -12.88% Signal Traps/second
 6 exec_test               230.04                 228.63      -1.41 -0.61% Program Loads/second
 7 fork_test              3470.51                3528.82      58.31 1.68% Task Creations/second
 8 link_test             53508.53               53700.65     192.12 0.36% Link/Unlink Pairs/second

DBench Comparison
-----------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
Throughput  1 procs                    260.708                    209.52 -19.63%

TBench Comparison
-----------------
                              2.6.24-rc2-clean     2.6.24-rc2-one-percpu %diff
Throughput 1 proc                      254.032                   293.737 15.63%

The KernBench figures looked ok although the page_test and brk_test were
of minor concern. These tests can be variable but are very sensitive to
cache affects which might explain why User CPU time was slightly down for
kernbench. This is worth trying on a few more machines. Unlike elm3b6, this
machine also showed improvements for hackbench but I'm not sure what sort
of conclusion to draw from that.

I'm still waiting on results to come in from a PPC64 machine but initially
indicators are this is not a bad idea because you are not abandoning the
idea of giving hot pages when requested, just altering a little how they
are found. I suspect your main motivation is reducing the size of a per-cpu
structure?

You should be able to see improvements in a number of cases that have little
to do with hotness/coldness. Currently, if a caller asks for a hot page and
there are no hot pages, they go to the main allocator, acquire locks etc. It
makes a lot more sense that they get a cold per-cpu page instead. Where you
may get hit is that your combined per-cpu lists are smaller than the separate
ones as you do not update the pcp->high value to be hot+cold.

However, the opposite is also true. Currently, if someone is doing a lot of
file-readahead, they regularly will go to the main allocator as the cold
per-cpu lists get emptied. Now they will be able to take hot pages for a
cold user instead which may be noticable in some cases.

However, in the event we cannot prove whether separate hot/cold lists are
worth it or not, we might as well collapse them for smaller per-cpu structures.

[1] Not exactly comprehensive testing I know, but it is easily available.

> ---
>  include/linux/mmzone.h |    2 -
>  mm/page_alloc.c        |   55 +++++++++++++++++++++++--------------------------
>  mm/vmstat.c            |   24 ++++++++-------------
>  3 files changed, 36 insertions(+), 45 deletions(-)
> 
> Index: linux-2.6/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mmzone.h	2007-11-12 20:16:24.814260361 -0800
> +++ linux-2.6/include/linux/mmzone.h	2007-11-12 20:17:35.267759790 -0800
> @@ -113,7 +113,7 @@ struct per_cpu_pages {
>  };
>  
>  struct per_cpu_pageset {
> -	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
> +	struct per_cpu_pages pcp;
>  #ifdef CONFIG_NUMA
>  	s8 expire;
>  #endif
> Index: linux-2.6/mm/vmstat.c
> ===================================================================
> --- linux-2.6.orig/mm/vmstat.c	2007-11-12 20:16:24.822260116 -0800
> +++ linux-2.6/mm/vmstat.c	2007-11-12 20:29:18.912816791 -0800
> @@ -332,7 +332,7 @@ void refresh_cpu_vm_stats(int cpu)
>  		 * Check if there are pages remaining in this pageset
>  		 * if not then there is nothing to expire.
>  		 */
> -		if (!p->expire || (!p->pcp[0].count && !p->pcp[1].count))
> +		if (!p->expire || !p->pcp.count)
>  			continue;
>  
>  		/*
> @@ -347,11 +347,8 @@ void refresh_cpu_vm_stats(int cpu)
>  		if (p->expire)
>  			continue;
>  
> -		if (p->pcp[0].count)
> -			drain_zone_pages(zone, p->pcp + 0);
> -
> -		if (p->pcp[1].count)
> -			drain_zone_pages(zone, p->pcp + 1);
> +		if (p->pcp.count)
> +			drain_zone_pages(zone, &p->pcp);
>  #endif
>  	}
>  }
> @@ -685,20 +682,17 @@ static void zoneinfo_show_print(struct s
>  		   "\n  pagesets");
>  	for_each_online_cpu(i) {
>  		struct per_cpu_pageset *pageset;
> -		int j;
>  
>  		pageset = CPU_PTR(zone->pageset, i);
> -		for (j = 0; j < ARRAY_SIZE(pageset->pcp); j++) {
> -			seq_printf(m,
> -				   "\n    cpu: %i pcp: %i"
> +		seq_printf(m,
> +				   "\n    cpu: %i"
>  				   "\n              count: %i"
>  				   "\n              high:  %i"
>  				   "\n              batch: %i",
> -				   i, j,
> -				   pageset->pcp[j].count,
> -				   pageset->pcp[j].high,
> -				   pageset->pcp[j].batch);
> -			}
> +				   i,
> +				   pageset->pcp.count,
> +				   pageset->pcp.high,
> +				   pageset->pcp.batch);
>  #ifdef CONFIG_SMP
>  		seq_printf(m, "\n  vm stats threshold: %d",
>  				pageset->stat_threshold);

All pretty straight-forward.

> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2007-11-12 20:16:24.830259956 -0800
> +++ linux-2.6/mm/page_alloc.c	2007-11-12 20:26:44.766259839 -0800
> @@ -885,24 +885,21 @@ static void __drain_pages(unsigned int c
>  {
>  	unsigned long flags;
>  	struct zone *zone;
> -	int i;
>  
>  	for_each_zone(zone) {
>  		struct per_cpu_pageset *pset;
> +		struct per_cpu_pages *pcp;
>  
>  		if (!populated_zone(zone))
>  			continue;
>  
>  		pset = CPU_PTR(zone->pageset, cpu);
> -		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
> -			struct per_cpu_pages *pcp;
>  
> -			pcp = &pset->pcp[i];
> -			local_irq_save(flags);
> -			free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> -			pcp->count = 0;
> -			local_irq_restore(flags);
> -		}
> +		pcp = &pset->pcp;
> +		local_irq_save(flags);
> +		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> +		pcp->count = 0;
> +		local_irq_restore(flags);

Not that this is performance critical or anything, but it's less messing
with IRQ flags.

>  	}
>  }
>  
> @@ -993,9 +990,12 @@ static void fastcall free_hot_cold_page(
>  	kernel_map_pages(page, 1, 0);
>  
>  	local_irq_save(flags);
> -	pcp = &THIS_CPU(zone->pageset)->pcp[cold];
> +	pcp = &THIS_CPU(zone->pageset)->pcp;
>  	__count_vm_event(PGFREE);
> -	list_add(&page->lru, &pcp->list);
> +	if (cold)
> +		list_add_tail(&page->lru, &pcp->list);
> +	else
> +		list_add(&page->lru, &pcp->list);

There is scope here for a list function that adds to the head or tail depending
on the value of a parameter. I know Andy has the prototype of such a function
lying around so you may be able to share.

>  	set_page_private(page, get_pageblock_migratetype(page));
>  	pcp->count++;
>  	if (pcp->count >= pcp->high) {
> @@ -1051,7 +1051,7 @@ again:
>  		struct per_cpu_pages *pcp;
>  
>  		local_irq_save(flags);
> -		pcp = &THIS_CPU(zone->pageset)->pcp[cold];
> +		pcp = &THIS_CPU(zone->pageset)->pcp;
>  		if (!pcp->count) {
>  			pcp->count = rmqueue_bulk(zone, 0,
>  					pcp->batch, &pcp->list, migratetype);
> @@ -1060,9 +1060,15 @@ again:
>  		}
>  
>  		/* Find a page of the appropriate migrate type */
> -		list_for_each_entry(page, &pcp->list, lru)
> -			if (page_private(page) == migratetype)
> -				break;
> +		if (cold) {
> +			list_for_each_entry_reverse(page, &pcp->list, lru)
> +				if (page_private(page) == migratetype)
> +					break;
> +		} else {
> +			list_for_each_entry(page, &pcp->list, lru)
> +				if (page_private(page) == migratetype)
> +					break;
> +		}
>  

The code looks ok but it might be nice to add a comment explaining how hot/cold
pages are added to the list in the header and point the reader to it here.

>  		/* Allocate more to the pcp list if necessary */
>  		if (unlikely(&page->lru == &pcp->list)) {
> @@ -1787,12 +1793,9 @@ void show_free_areas(void)
>  
>  			pageset = CPU_PTR(zone->pageset, cpu);
>  
> -			printk("CPU %4d: Hot: hi:%5d, btch:%4d usd:%4d   "
> -			       "Cold: hi:%5d, btch:%4d usd:%4d\n",
> -			       cpu, pageset->pcp[0].high,
> -			       pageset->pcp[0].batch, pageset->pcp[0].count,
> -			       pageset->pcp[1].high, pageset->pcp[1].batch,
> -			       pageset->pcp[1].count);
> +			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
> +			       cpu, pageset->pcp.high,
> +			       pageset->pcp.batch, pageset->pcp.count);
>  		}
>  	}
>  
> @@ -2590,17 +2593,11 @@ inline void setup_pageset(struct per_cpu
>  
>  	memset(p, 0, sizeof(*p));
>  
> -	pcp = &p->pcp[0];		/* hot */
> +	pcp = &p->pcp;
>  	pcp->count = 0;
>  	pcp->high = 6 * batch;
>  	pcp->batch = max(1UL, 1 * batch);
>  	INIT_LIST_HEAD(&pcp->list);
> -
> -	pcp = &p->pcp[1];		/* cold*/
> -	pcp->count = 0;
> -	pcp->high = 2 * batch;
> -	pcp->batch = max(1UL, batch/2);
> -	INIT_LIST_HEAD(&pcp->list);

Before - per-cpu high count was 8 * batch. After, it is 6 * batch. This
may be noticable in some corner case involving page readahead requesting
cold pages.

>  }
>  
>  /*
> @@ -2613,7 +2610,7 @@ static void setup_pagelist_highmark(stru
>  {
>  	struct per_cpu_pages *pcp;
>  
> -	pcp = &p->pcp[0]; /* hot list */
> +	pcp = &p->pcp;
>  	pcp->high = high;
>  	pcp->batch = max(1UL, high/4);
>  	if ((high/4) > (PAGE_SHIFT * 8))
> 

All in all, pretty straight-forward. I think it's worth wider testing at
least. I think it'll be hard to show for sure whether this is having a
negative performance impact or not but initial results look ok.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
