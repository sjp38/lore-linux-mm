Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7GKaAP4020530
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 16:36:10 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7GKVYuL192912
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 14:31:34 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7GKVXuA030574
	for <linux-mm@kvack.org>; Wed, 16 Aug 2006 14:31:34 -0600
Subject: Re: [RFC][PATCH] "challenged" memory controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <20060815192047.EE4A0960@localhost.localdomain>
References: <20060815192047.EE4A0960@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 16 Aug 2006 13:31:32 -0700
Message-Id: <1155760292.12953.15.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dave@sr71.net
Cc: linux-mm@kvack.org, balbir@in.ibm.com, ckrm-tech <ckrm-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave,

It will be helpful if you could Cc: ckrm-tech on future resource
management related patches.

Generic comments (might already be in your list):
- Nice sized patch.
- we need both min and max to do effective resource management. 
  Having limit is good, but not sufficient.
- What happens to accounting when a task is moved from one "group"
   to another ?
- What happens when a "group" is removed ?
- How does the limit and hierarchy play together ?
- How about shared pages ?

This code specific comments:
- In the reclamation path walking through the whole page list in 
   search of pages belonging to naughty "group" will be costly.
- With the logic of (forced) limiting a "group" at allocation, how will
   we find naughty "groups" during reclamation ?

See inlined comments below

regards,

chandra
On Tue, 2006-08-15 at 12:20 -0700, dave@sr71.net wrote:

<snip>

>  #endif /* _LINUX_CPUSET_H */
> diff -puN include/linux/gfp.h~challenged-memory-controller include/linux/gfp.h
> --- lxc/include/linux/gfp.h~challenged-memory-controller	2006-08-15 07:47:28.000000000 -0700
> +++ lxc-dave/include/linux/gfp.h	2006-08-15 07:47:34.000000000 -0700
> @@ -108,10 +108,6 @@ static inline enum zone_type gfp_zone(gf
>   * optimized to &contig_page_data at compile-time.
>   */
>  
> -#ifndef HAVE_ARCH_FREE_PAGE
> -static inline void arch_free_page(struct page *page, int order) { }
> -#endif
> -

Not a good idea. What happens for the arches that _have_ a
arch_free_page ?

May be you can define a function that calls arch_free_page() and also
does what you want to be done.

Thinking more... arch_free_page() may not be the right place to credit
the "group" for pages being freed, since the page may be freed
immediately after arch_free_page(). IMO, a better place would be some
other lower level function like free_bulk_pages().

>  extern struct page *
>  FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
>  
> diff -puN include/linux/mm.h~challenged-memory-controller include/linux/mm.h
> diff -puN include/linux/sched.h~challenged-memory-controller include/linux/sched.h
> diff -puN include/linux/swap.h~challenged-memory-controller include/linux/swap.h
> --- lxc/include/linux/swap.h~challenged-memory-controller	2006-08-15 07:47:28.000000000 -0700
> +++ lxc-dave/include/linux/swap.h	2006-08-15 07:47:34.000000000 -0700
> @@ -188,7 +188,7 @@ extern void swap_setup(void);
>  
>  /* linux/mm/vmscan.c */
>  extern unsigned long try_to_free_pages(struct zone **, gfp_t);
> -extern unsigned long shrink_all_memory(unsigned long nr_pages);
> +extern unsigned long shrink_all_memory(unsigned long nr_pages, struct cpuset *cs);

IMO shrink_all_memory() may not be the right function, because it tries
to free up slab etc., a better place might be shrink_zones() or
shrink_all_zones().

>  extern int vm_swappiness;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
>  extern long vm_total_pages;
> diff -puN kernel/cpuset.c~challenged-memory-controller kernel/cpuset.c
> --- lxc/kernel/cpuset.c~challenged-memory-controller	2006-08-14 13:22:12.000000000 -0700
> +++ lxc-dave/kernel/cpuset.c	2006-08-15 08:00:40.000000000 -0700
> @@ -21,6 +21,7 @@
>  #include <linux/cpu.h>
>  #include <linux/cpumask.h>
>  #include <linux/cpuset.h>
> +#include <linux/delay.h>
>  #include <linux/err.h>
>  #include <linux/errno.h>
>  #include <linux/file.h>
> @@ -46,6 +47,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/stat.h>
>  #include <linux/string.h>
> +#include <linux/swap.h>
>  #include <linux/time.h>
>  #include <linux/backing-dev.h>
>  #include <linux/sort.h>
> @@ -97,6 +99,8 @@ struct cpuset {
>  	 * recent time this cpuset changed its mems_allowed.
>  	 */
>  	int mems_generation;
> +	int mems_nr_pages;
> +	int mems_max_pages;
>  
>  	struct fmeter fmeter;		/* memory_pressure filter */
>  };
> @@ -112,6 +116,55 @@ typedef enum {
>  	CS_SPREAD_SLAB,
>  } cpuset_flagbits_t;
>  
> +int shrink_cpuset(struct cpuset *cs, gfp_t gfpmask, int tries)

gfpmask unused. 
> +{
> +	int nr_shrunk = 0;
> +	while (cpuset_amount_over_memory_max(cs)) {
> +		if (tries-- < 0)
> +			break;
> +		nr_shrunk += shrink_all_memory(10, cs);

what is the purpose of nr_shrunk ?

> +	}
> +	return 0;
> +}

since it always returns 0, why can't it be a void function ? 
> +
> +int cpuset_inc_nr_pages(struct cpuset *cs, int nr, gfp_t gfpmask)
> +{
> +	int ret;
> +	if (!cs)
> +		return 0;
> +	cs->mems_nr_pages += nr;

not decremented in failure case. better to increment in the success case
only. 
> +	if (cpuset_amount_over_memory_max(cs)) {
> +		if (!(gfpmask & __GFP_WAIT))
> +			return -ENOMEM;

we would be failing allocations in interrupt context, which may not be
good.
> +		ret = shrink_cpuset(cs, gfpmask, 50);
> +	}
> +	if (cpuset_amount_over_memory_max(cs))
> +		return -ENOMEM;
> +	return 0;
> +}

> +void cpuset_dec_nr_pages(struct cpuset *cs, int nr)
> +{
> +	if (!cs)
> +		return;
> +	cs->mems_nr_pages -= nr;
> +}
> +int cpuset_get_nr_pages(const struct cpuset *cs)
> +{
> +	return cs->mems_nr_pages;
> +}
> +int cpuset_amount_over_memory_max(const struct cpuset *cs)
> +{
> +	int amount;
> +
> +	if (!cs || cs->mems_max_pages < 0)
> +		return 0;
> +	amount = cs->mems_nr_pages - cs->mems_max_pages;
> +	if (amount < 0)
> +		amount = 0;
> +	return amount;
> +}

None of the callers use the return value. I don't see any reason for the
exact number. If there is no reason, can we simply return 
                   (cs->mems_nr_pages > cs->mems_max_pages) 
> +
> +
>  /* convenient tests for these bits */
>  static inline int is_cpu_exclusive(const struct cpuset *cs)
>  {
> @@ -173,6 +226,8 @@ static struct cpuset top_cpuset = {
>  	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
>  	.cpus_allowed = CPU_MASK_ALL,
>  	.mems_allowed = NODE_MASK_ALL,
> +	.mems_nr_pages = 0,
> +	.mems_max_pages = -1,

instead of have these as int and "-1" why not use unsigned int and
ULONG_MAX ?

>  	.count = ATOMIC_INIT(0),
>  	.sibling = LIST_HEAD_INIT(top_cpuset.sibling),
>  	.children = LIST_HEAD_INIT(top_cpuset.children),
> @@ -1021,6 +1076,17 @@ static int update_memory_pressure_enable
>  	return 0;
>  }
>  
> +static int update_memory_max_nr_pages(struct cpuset *cs, char *buf)
> +{
> +	int rate = simple_strtol(buf, NULL, 10);
> +	int shrunk;
> +	int loopnr = 0;

unused variables.
> +	cs->mems_max_pages = rate;
> +	while (cpuset_amount_over_memory_max(cs))
> +		shrunk = shrink_cpuset(cs, 0, 10);
> +	return 0;
> +}
> +
>  /*
>   * update_flag - read a 0 or a 1 in a file and update associated flag
>   * bit:	the bit to update (CS_CPU_EXCLUSIVE, CS_MEM_EXCLUSIVE,
> @@ -1109,6 +1175,7 @@ static int update_flag(cpuset_flagbits_t
>   */
>  
>  #define FM_COEF 933		/* coefficient for half-life of 10 secs */
> +#define FM_COEF 93		/* coefficient for half-life of 10 secs */

what is the purpose of this change ?

>  #define FM_MAXTICKS ((time_t)99) /* useless computing more ticks than this */
>  #define FM_MAXCNT 1000000	/* limit cnt to avoid overflow */
>  #define FM_SCALE 1000		/* faux fixed point scale */
> @@ -1263,6 +1330,8 @@ typedef enum {
>  	FILE_NOTIFY_ON_RELEASE,
>  	FILE_MEMORY_PRESSURE_ENABLED,
>  	FILE_MEMORY_PRESSURE,
> +	FILE_MEMORY_MAX,
> +	FILE_MEMORY_USED,
>  	FILE_SPREAD_PAGE,
>  	FILE_SPREAD_SLAB,
>  	FILE_TASKLIST,
> @@ -1321,6 +1390,9 @@ static ssize_t cpuset_common_file_write(
>  	case FILE_MEMORY_PRESSURE_ENABLED:
>  		retval = update_memory_pressure_enabled(cs, buffer);
>  		break;
> +	case FILE_MEMORY_MAX:
> +		retval = update_memory_max_nr_pages(cs, buffer);
> +		break;
>  	case FILE_MEMORY_PRESSURE:
>  		retval = -EACCES;
>  		break;
> @@ -1441,6 +1513,12 @@ static ssize_t cpuset_common_file_read(s
>  	case FILE_MEMORY_PRESSURE:
>  		s += sprintf(s, "%d", fmeter_getrate(&cs->fmeter));
>  		break;
> +	case FILE_MEMORY_MAX:
> +		s += sprintf(s, "%d", cs->mems_max_pages);
> +		break;
> +	case FILE_MEMORY_USED:
> +		s += sprintf(s, "%d", cs->mems_nr_pages);
> +		break;
>  	case FILE_SPREAD_PAGE:
>  		*s++ = is_spread_page(cs) ? '1' : '0';
>  		break;
> @@ -1785,6 +1863,16 @@ static struct cftype cft_cpu_exclusive =
>  	.private = FILE_CPU_EXCLUSIVE,
>  };
>  
> +static struct cftype cft_mem_used = {
> +	.name = "memory_nr_pages",
> +	.private = FILE_MEMORY_USED,
> +};
> +
> +static struct cftype cft_mem_max = {
> +	.name = "memory_max_pages",
> +	.private = FILE_MEMORY_MAX,
> +};
> +
>  static struct cftype cft_mem_exclusive = {
>  	.name = "mem_exclusive",
>  	.private = FILE_MEM_EXCLUSIVE,
> @@ -1830,6 +1918,10 @@ static int cpuset_populate_dir(struct de
>  		return err;
>  	if ((err = cpuset_add_file(cs_dentry, &cft_cpu_exclusive)) < 0)
>  		return err;
> +	if ((err = cpuset_add_file(cs_dentry, &cft_mem_max)) < 0)
> +		return err;
> +	if ((err = cpuset_add_file(cs_dentry, &cft_mem_used)) < 0)
> +		return err;
>  	if ((err = cpuset_add_file(cs_dentry, &cft_mem_exclusive)) < 0)
>  		return err;
>  	if ((err = cpuset_add_file(cs_dentry, &cft_notify_on_release)) < 0)
> @@ -1880,6 +1972,8 @@ static long cpuset_create(struct cpuset 
>  	INIT_LIST_HEAD(&cs->sibling);
>  	INIT_LIST_HEAD(&cs->children);
>  	cs->mems_generation = cpuset_mems_generation++;
> +	cs->mems_max_pages = parent->mems_max_pages;

IMO this is not intuitive. Having same default values (infinite) for all
"groups" sounds more intuitive.

> +	cs->mems_nr_pages = 0;
>  	fmeter_init(&cs->fmeter);
>  
>  	cs->parent = parent;
> @@ -1986,6 +2080,8 @@ int __init cpuset_init_early(void)
>  
>  	tsk->cpuset = &top_cpuset;
>  	tsk->cpuset->mems_generation = cpuset_mems_generation++;
> +	tsk->cpuset->mems_max_pages = -1;
> +	tsk->cpuset->mems_nr_pages = 0;
>  	return 0;
>  }
>  
> @@ -2005,6 +2101,8 @@ int __init cpuset_init(void)
>  
>  	fmeter_init(&top_cpuset.fmeter);
>  	top_cpuset.mems_generation = cpuset_mems_generation++;
> +	top_cpuset.mems_max_pages = -1;
> +	top_cpuset.mems_nr_pages = 0;
>  
>  	init_task.cpuset = &top_cpuset;
>  
> @@ -2438,7 +2536,6 @@ int cpuset_memory_pressure_enabled __rea
>  void __cpuset_memory_pressure_bump(void)
>  {
>  	struct cpuset *cs;
> -
>  	task_lock(current);
>  	cs = current->cpuset;
>  	fmeter_markevent(&cs->fmeter);
> diff -puN mm/page_alloc.c~challenged-memory-controller mm/page_alloc.c
> --- lxc/mm/page_alloc.c~challenged-memory-controller	2006-08-14 13:24:16.000000000 -0700
> +++ lxc-dave/mm/page_alloc.c	2006-08-15 07:57:13.000000000 -0700
> @@ -470,6 +470,11 @@ static void free_one_page(struct zone *z
>  	free_pages_bulk(zone, 1, &list, order);
>  }
>  
> +void arch_free_page(struct page *page, int order)
> +{
> +	cpuset_dec_nr_pages(page->cpuset, 1<<order);
> +}
> +
>  static void __free_pages_ok(struct page *page, unsigned int order)
>  {
>  	unsigned long flags;
> @@ -1020,6 +1025,9 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
>  
>  	might_sleep_if(wait);
>  
> +	if (cpuset_inc_nr_pages(current->cpuset, 1<<order, gfp_mask))
> +		return NULL;
> +

As pointed above, may need to handle interrupt context differently.

>  restart:
>  	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
>  
> @@ -1159,6 +1167,10 @@ got_pg:
>  	if (page)
>  		set_page_owner(page, order, gfp_mask);
>  #endif
> +	if (page)
> +		page->cpuset = current->cpuset;

getting a reference to cpuset without incrementing the reference count
of current->cpuset.

> +	else
> +		cpuset_dec_nr_pages(current->cpuset, 1<<order);
>  	return page;
>  }
>  
> diff -puN mm/rmap.c~challenged-memory-controller mm/rmap.c
> --- lxc/mm/rmap.c~challenged-memory-controller	2006-08-15 07:47:28.000000000 -0700
> +++ lxc-dave/mm/rmap.c	2006-08-15 08:01:26.000000000 -0700
> @@ -927,3 +927,8 @@ int try_to_unmap(struct page *page, int 
>  	return ret;
>  }
>  
> +extern int cpuset_amount_over_memory_max(const struct cpuset *cs);
> +int page_has_naughty_cpuset(struct page *page)
> +{
> +	return cpuset_amount_over_memory_max(page->cpuset);
> +}

why not have this function in vmscan.c itself ? can be inlined there.

BTW, is this function necessary ?

> diff -puN mm/vmscan.c~challenged-memory-controller mm/vmscan.c
> --- lxc/mm/vmscan.c~challenged-memory-controller	2006-08-15 07:47:28.000000000 -0700
> +++ lxc-dave/mm/vmscan.c	2006-08-15 08:05:03.000000000 -0700
> @@ -63,8 +63,9 @@ struct scan_control {
>  	int swap_cluster_max;
>  
>  	int swappiness;
> -
>  	int all_unreclaimable;
> +	int only_pages_with_naughty_cpusets;
> +	struct cpuset *only_this_cpuset;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -445,6 +446,10 @@ static unsigned long shrink_page_list(st
>  
>  		VM_BUG_ON(PageActive(page));
>  
> +		if (cpuset_amount_over_memory_max(sc->only_this_cpuset) &&
> +		    page->cpuset && page->cpuset != sc->only_this_cpuset) {
> +			goto keep_locked;
> +		}

since sc->only_this_cpuset will remain constant and page is the one that
will be changing in this loop, I think a small rearrangement of this
code would benefit performance.
 
>  		sc->nr_scanned++;
>  
>  		if (!sc->may_swap && page_mapped(page))
> @@ -793,9 +798,20 @@ force_reclaim_mapped:
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	while (!list_empty(&l_hold)) {
> +		extern int page_has_naughty_cpuset(struct page *page);
>  		cond_resched();
>  		page = lru_to_page(&l_hold);
>  		list_del(&page->lru);
> +		if (sc->only_this_cpuset &&
> +		    page->cpuset && page->cpuset != sc->only_this_cpuset) {
> +			list_add(&page->lru, &l_active);
> +			continue;
> +		}
> +		if (sc->only_pages_with_naughty_cpusets &&
> +		    !page_has_naughty_cpuset(page)) {
> +			list_add(&page->lru, &l_active);
> +			continue;
> +		}
>  		if (page_mapped(page)) {
>  			if (!reclaim_mapped ||
>  			    (total_swap_pages == 0 && PageAnon(page)) ||
> @@ -875,6 +891,7 @@ static unsigned long shrink_zone(int pri
>  	unsigned long nr_inactive;
>  	unsigned long nr_to_scan;
>  	unsigned long nr_reclaimed = 0;
> +	int nr_scans = 0;
>  
>  	atomic_inc(&zone->reclaim_in_progress);
>  
> @@ -897,6 +914,11 @@ static unsigned long shrink_zone(int pri
>  		nr_inactive = 0;
>  
>  	while (nr_active || nr_inactive) {
> +		nr_scans++;
> +		if (printk_ratelimit())
> +			printk("%s() scan nr: %d\n", __func__, nr_scans);
> +		if (nr_scans > 20)
> +			sc->only_pages_with_naughty_cpusets = 0;
>  		if (nr_active) {
>  			nr_to_scan = min(nr_active,
>  					(unsigned long)sc->swap_cluster_max);
> @@ -993,6 +1015,7 @@ unsigned long try_to_free_pages(struct z
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
>  		.may_swap = 1,
>  		.swappiness = vm_swappiness,
> +		.only_pages_with_naughty_cpusets = 1,
>  	};
>  
>  	delay_swap_prefetch();
> @@ -1090,6 +1113,7 @@ static unsigned long balance_pgdat(pg_da
>  		.may_swap = 1,
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
>  		.swappiness = vm_swappiness,
> +		.only_pages_with_naughty_cpusets = 1,
>  	};
>  
>  loop_again:
> @@ -1310,7 +1334,6 @@ void wakeup_kswapd(struct zone *zone, in
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
>  
> -#ifdef CONFIG_PM
>  /*
>   * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
>   * from LRU lists system-wide, for given pass and priority, and returns the
> @@ -1363,7 +1386,7 @@ static unsigned long shrink_all_zones(un
>   * LRU order by reclaiming preferentially
>   * inactive > active > active referenced > active mapped
>   */
> -unsigned long shrink_all_memory(unsigned long nr_pages)
> +unsigned long shrink_all_memory(unsigned long nr_pages, struct cpuset *cs)
>  {
>  	unsigned long lru_pages, nr_slab;
>  	unsigned long ret = 0;
> @@ -1376,6 +1399,8 @@ unsigned long shrink_all_memory(unsigned
>  		.swap_cluster_max = nr_pages,
>  		.may_writepage = 1,
>  		.swappiness = vm_swappiness,
> +		.only_pages_with_naughty_cpusets = 1,
> +		.only_this_cpuset = cs,
>  	};
>  
>  	delay_swap_prefetch();
> @@ -1462,7 +1487,6 @@ out:
>  
>  	return ret;
>  }
> -#endif
>  
>  #ifdef CONFIG_HOTPLUG_CPU
>  /* It's optimal to keep kswapds on the same CPUs as their memory, but
> @@ -1568,6 +1592,7 @@ static int __zone_reclaim(struct zone *z
>  					SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,
>  		.swappiness = vm_swappiness,
> +		.only_pages_with_naughty_cpusets = 1,
>  	};
>  
>  	disable_swap_token();
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
