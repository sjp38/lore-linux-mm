Date: Mon, 12 Nov 2007 16:04:51 +0000
Subject: Re: Page allocator: Clean up pcp draining functions
Message-ID: <20071112160451.GC6653@skynet.ie>
References: <Pine.LNX.4.64.0711091840410.18588@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711091840410.18588@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On (09/11/07 18:44), Christoph Lameter didst pronounce:
> - Add comments explaing how drain_pages() works.
> 
> - Eliminate useless functions
> 
> - Rename drain_all_local_pages to drain_all_pages(). It does drain
>   all pages not only those of the local processor.
> 
> - Eliminate useless interrupt off / on sequences. drain_pages()
>   disables interrupts on its own. The execution thread is
>   pinned to processor by the caller. So there is no need to
>   disable interrupts.
> 
> - Put drain_all_pages() declaration in gfp.h and remove the
>   declarations from suspend.h and from mm/memory_hotplug.c
> 
> - Make software suspend call drain_all_pages(). The draining
>   of processor local pages is may not the right approach if
>   software suspend wants to support SMP. If they call drain_all_pages
>   then we can make drain_pages() static.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/gfp.h     |    1 
>  include/linux/suspend.h |    1 
>  kernel/power/snapshot.c |    4 +-
>  mm/memory_hotplug.c     |    6 +--
>  mm/page_alloc.c         |   79 +++++++++++++++++++++++++-----------------------
>  5 files changed, 47 insertions(+), 44 deletions(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c	2007-11-08 21:57:36.218700063 -0800
> +++ linux-2.6/mm/page_alloc.c	2007-11-08 22:17:28.166753117 -0800
> @@ -901,7 +901,14 @@ void drain_zone_pages(struct zone *zone,
>  }
>  #endif
>  
> -static void __drain_pages(unsigned int cpu)
> +/*
> + * Drain pages of the indicated processor.
> + *
> + * The processor must either be the current processor and the
> + * thread pinned to the current processor or a processor that
> + * is not online.
> + */
> +static void drain_pages(unsigned int cpu)
>  {
>  	unsigned long flags;
>  	struct zone *zone;

Reflecting the comment, perhaps the following would not hurt?

VM_BUG_ON(cpu != smp_processor_id() && cpu_online(cpu))

> @@ -926,6 +933,22 @@ static void __drain_pages(unsigned int c
>  	}
>  }
>  
> +/*
> + * Spill all of this CPU's per-cpu pages back into the buddy allocator.
> + */
> +static void drain_local_pages(void *arg)
> +{
> +	drain_pages(smp_processor_id());
> +}
> +
> +/*
> + * Spill all the per-cpu pages from all CPUs back into the buddy allocator
> + */
> +void drain_all_pages(void)
> +{
> +	on_each_cpu(drain_local_pages, NULL, 0, 1);
> +}
> +
>  #ifdef CONFIG_HIBERNATION
>  
>  void mark_free_pages(struct zone *zone)
> @@ -963,37 +986,6 @@ void mark_free_pages(struct zone *zone)
>  #endif /* CONFIG_PM */
>  
>  /*
> - * Spill all of this CPU's per-cpu pages back into the buddy allocator.
> - */
> -void drain_local_pages(void)
> -{
> -	unsigned long flags;
> -
> -	local_irq_save(flags);	
> -	__drain_pages(smp_processor_id());
> -	local_irq_restore(flags);	
> -}

Ok, the new version does not save and restore the IRQ flags. However, as
you rightly point out, this is done in drain_pages() formerly called
__drain_pages() and seems functionally equivilant.

> -
> -void smp_drain_local_pages(void *arg)
> -{
> -	drain_local_pages();
> -}
> -

Appears unused - by rights it should have been declared static so fine
to go away here.

> -/*
> - * Spill all the per-cpu pages from all CPUs back into the buddy allocator
> - */
> -void drain_all_local_pages(void)
> -{
> -	unsigned long flags;
> -
> -	local_irq_save(flags);
> -	__drain_pages(smp_processor_id());
> -	local_irq_restore(flags);
> -
> -	smp_call_function(smp_drain_local_pages, NULL, 0, 1);
> -}
> -
> -/*
>   * Free a 0-order page
>   */
>  static void fastcall free_hot_cold_page(struct page *page, int cold)
> @@ -1575,7 +1567,7 @@ nofail_alloc:
>  	cond_resched();
>  
>  	if (order != 0)
> -		drain_all_local_pages();
> +		drain_all_pages();
>  

Seems equivilant.

>  	if (likely(did_some_progress)) {
>  		page = get_page_from_freelist(gfp_mask, order,
> @@ -3931,10 +3923,23 @@ static int page_alloc_cpu_notify(struct 
>  	int cpu = (unsigned long)hcpu;
>  
>  	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
> -		local_irq_disable();
> -		__drain_pages(cpu);
> +		drain_pages(cpu);
> +
> +		/*
> +		 * Spill the event counters of the dead processor
> +		 * into the current processors event counters.
> +		 * This artificially elevates the count of the current
> +		 * processor.
> +		 */

This comment addition does not appear to be related to the rest of the
patch.

>  		vm_events_fold_cpu(cpu);
> -		local_irq_enable();
> +
> +		/*
> +		 * Zero the differential counters of the dead processor
> +		 * so that the vm statistics are consistent.
> +		 *
> +		 * This is only okay since the processor is dead and cannot
> +		 * race with what we are doing.
> +		 */
>  		refresh_cpu_vm_stats(cpu);

Similar for this comment.

I do not have a problem with the two comments - I just want to be sure they
are not an accidental addition as your leader makes no mention of them.

>  	}
>  	return NOTIFY_OK;
> @@ -4435,7 +4440,7 @@ int set_migratetype_isolate(struct page 
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	if (!ret)
> -		drain_all_local_pages();
> +		drain_all_pages();
>  	return ret;
>  }
>  
> Index: linux-2.6/include/linux/suspend.h
> ===================================================================
> --- linux-2.6.orig/include/linux/suspend.h	2007-11-08 21:57:36.238700167 -0800
> +++ linux-2.6/include/linux/suspend.h	2007-11-08 22:09:54.324950025 -0800
> @@ -123,7 +123,6 @@ struct pbe {
>  };
>  
>  /* mm/page_alloc.c */
> -extern void drain_local_pages(void);
>  extern void mark_free_pages(struct zone *zone);
>  
>  /**
> Index: linux-2.6/kernel/power/snapshot.c
> ===================================================================
> --- linux-2.6.orig/kernel/power/snapshot.c	2007-11-08 21:57:36.250700201 -0800
> +++ linux-2.6/kernel/power/snapshot.c	2007-11-08 22:00:20.924949833 -0800
> @@ -1204,7 +1204,7 @@ asmlinkage int swsusp_save(void)
>  
>  	printk("swsusp: critical section: \n");
>  
> -	drain_local_pages();
> +	drain_all_pages();

Declaration in gfp.h, seems fine.

>  	nr_pages = count_data_pages();
>  	nr_highmem = count_highmem_pages();
>  	printk("swsusp: Need to copy %u pages\n", nr_pages + nr_highmem);
> @@ -1222,7 +1222,7 @@ asmlinkage int swsusp_save(void)
>  	/* During allocating of suspend pagedir, new cold pages may appear.
>  	 * Kill them.
>  	 */
> -	drain_local_pages();
> +	drain_all_pages();
>  	copy_data_pages(&copy_bm, &orig_bm);
>  
>  	/*
> Index: linux-2.6/include/linux/gfp.h
> ===================================================================
> --- linux-2.6.orig/include/linux/gfp.h	2007-11-08 22:10:17.841949824 -0800
> +++ linux-2.6/include/linux/gfp.h	2007-11-08 22:10:33.657034346 -0800
> @@ -228,5 +228,6 @@ extern void FASTCALL(free_cold_page(stru
>  
>  void page_alloc_init(void);
>  void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
> +void drain_all_pages(void);
>  
>  #endif /* __LINUX_GFP_H */
> Index: linux-2.6/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.orig/mm/memory_hotplug.c	2007-11-08 22:09:08.657449925 -0800
> +++ linux-2.6/mm/memory_hotplug.c	2007-11-08 22:12:07.377699532 -0800
> @@ -481,8 +481,6 @@ check_pages_isolated(unsigned long start
>  	return offlined;
>  }
>  
> -extern void drain_all_local_pages(void);
> -
>  int offline_pages(unsigned long start_pfn,
>  		  unsigned long end_pfn, unsigned long timeout)
>  {
> @@ -540,7 +538,7 @@ repeat:
>  		lru_add_drain_all();
>  		flush_scheduled_work();
>  		cond_resched();
> -		drain_all_local_pages();
> +		drain_all_pages();
>  	}
>  
>  	pfn = scan_lru_pages(start_pfn, end_pfn);
> @@ -563,7 +561,7 @@ repeat:
>  	flush_scheduled_work();
>  	yield();
>  	/* drain pcp pages , this is synchrouns. */
> -	drain_all_local_pages();
> +	drain_all_pages();
>  	/* check again */
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>  	if (offlined_pages < 0) {
> 

Other than the additional comments that are not mentioned in the leader,
I could not see any problem with this patch.

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
