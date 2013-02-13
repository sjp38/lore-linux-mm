Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 736876B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 01:42:56 -0500 (EST)
Received: by mail-bk0-f74.google.com with SMTP id jk13so51417bkc.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2013 22:42:54 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
References: <20130211000220.GA28247@lizard.gateway.2wire.net>
Date: Tue, 12 Feb 2013 22:42:51 -0800
In-Reply-To: <20130211000220.GA28247@lizard.gateway.2wire.net> (Anton
	Vorontsov's message of "Sun, 10 Feb 2013 16:02:20 -0800")
Message-ID: <xr9338x01zpw.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Sun, Feb 10 2013, Anton Vorontsov wrote:

> With this patch userland applications that want to maintain the
> interactivity/memory allocation cost can use the new pressure level
> notifications. The levels are defined like this:
>
> The "low" level means that the system is reclaiming memory for new
> allocations. Monitoring reclaiming activity might be useful for
> maintaining overall system's cache level. Upon notification, the program
> (typically "Activity Manager") might analyze vmstat and act in advance
> (i.e. prematurely shutdown unimportant services).
>
> The "medium" level means that the system is experiencing medium memory
> pressure, there is some mild swapping activity. Upon this event
> applications may decide to analyze vmstat/zoneinfo/memcg or internal
> memory usage statistics and free any resources that can be easily
> reconstructed or re-read from a disk.
>
> The "critical" level means that the system is actively thrashing, it is
> about to out of memory (OOM) or even the in-kernel OOM killer is on its
> way to trigger. Applications should do whatever they can to help the
> system. It might be too late to consult with vmstat or any other
> statistics, so it's advisable to take an immediate action.
>
> The events are propagated upward until the event is handled, i.e. the
> events are not pass-through. Here is what this means: for example you have
> three cgroups: A->B->C. Now you set up an event listener on cgroup A and
> cgroup B, and suppose group C experiences some pressure. In this
> situation, only group B will receive the notification, i.e. group A will
> not receive it. This is done to avoid excessive "broadcasting" of
> messages, which disturbs the system and which is especially bad if we are
> low on memory or thrashing. So, organize the cgroups wisely, or propagate
> the events manually (or, ask us to implement the pass-through events,
> explaining why would you need them.)
>
> The file mempressure.level is used to show the current memory pressure
> level, and cgroups event control file can be used to setup an eventfd
> notification with a specific memory pressure level threshold.
>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>
> Hi all,
>
> Here comes another iteration of the memory pressure saga. The previous
> version of the patch (and discussion) can be found here:
>
> 	http://lkml.org/lkml/2013/1/4/55
>
> And here are changes in this revision:
>
> - Andrew Morton was concerned that the mempressure stuff was tied to
>   memcg, which was non-issue since mempressure wasn't actually bolted into
>   memcg at that time. But now it is. :) So now you need memcg to use
>   mempressure. Why? It makes things easier, simpler (e.g. this ends any
>   questions on how two different cgroups would interact, which can be
>   complex when two are distinct entities). Plus, as I understood it,
>   that's how cgroup folks want to see it eventually;
>
> - Only cgroups API implemented. Let's start with making memcg people
>   happy, i.e. handling the most complex cases, and then we can start with
>   any niche solutions;
>
> - Implemented Minchan Kim's idea of checking gfp mask. Unfortunately, it
>   is not as simple as checking '__GFP_HIGHMEM | __GFP_MOVABLE', since we
>   also need to account files caches and kswapd reclaim. But even so we can
>   filter out DMA or atomic allocations, which are not interesting for
>   userland. Plus it opens doors for other gfp tuning, so definitely a good
>   stuff;
>
> - Per Leonid Moiseichuk's comments decreased vmpressure_level_critical to
>   95. I didn't look close enough, but it seems that we the minimum step is
>   indeed ~3%, and 99% makes it actually 100%. 95% should be fine;
>
> - Per Kamezawa Hiroyuki added some words into documentation about that
>   it's always a good idea to consult with vmstat/zoneinfo/memcg statistics
>   before taking any action (with the exception of critical level). Also
>   added 'TODO' wrt. automatic window adjustment;
>
> - Documented events propagation strategy;
>
> - Removed ulong/uint usage, per Andrew's comments;
>
> - Glauber Costa didn't like too short and non-descriptive mpc_ naming,
>   suggesting mempressure_ instead. And Andrew suggested mpcg_. I went with
>   something completely different: vmpressure_/vmpr_. :) Also renamed
>   xxx2yyy() to xxx_to_yyy() per Glauber Costa suggestion.
>
> - _OOM level renamed to _CRITICAL. Andrew wanted _HIGH affix, but by using
>   'critical' I want to denote that this level is the last one (e.g. we
>   might want to introduce _HIGH some time later, if we can find a good
>   definition for it);
>
> - This patch does not include shrinker interface. In the last series I
>   showed that implementing shrinker is possible, and that it actually can
>   be useful. At the same time I explained that shrinker is not a
>   substitution for the pressure levels. So, once we settle on the simple
>   thing, I might continue my shrinker efforts (which, btw, QEMU guys found
>   interesting and potentionally useful).
>
>   For those who curious, the shrinker patch is here:
>
>   http://lkml.org/lkml/2013/1/4/56
>
> - Now tested with various debugging & preempt checks enabled, plus added
>   small comments on locks usage, thanks to Andrew;
>
> - Rebased onto the current linux-next;
>
> - While the thing somewhat changed, I preserved Kirill's ack. Kirill at
>   least liked the idea, and I desperately need Acks. :-D
>
> Thanks!
>
> Anton
>
>  Documentation/cgroups/memory.txt |  66 ++++++++-
>  init/Kconfig                     |  13 ++
>  mm/Makefile                      |   1 +
>  mm/internal.h                    |  34 +++++
>  mm/memcontrol.c                  |  25 ++++
>  mm/vmpressure.c                  | 300 +++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                      |   6 +
>  7 files changed, 444 insertions(+), 1 deletion(-)
>  create mode 100644 mm/vmpressure.c
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index addb1f1..006ef58 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -40,6 +40,7 @@ Features:
>   - soft limit
>   - moving (recharging) account at moving a task is selectable.
>   - usage threshold notifier
> + - memory pressure notifier
>   - oom-killer disable knob and oom-notifier
>   - Root cgroup has no limit controls.
>  
> @@ -65,6 +66,7 @@ Brief summary of control files.
>   memory.stat			 # show various statistics
>   memory.use_hierarchy		 # set/show hierarchical account enabled
>   memory.force_empty		 # trigger forced move charge to parent
> + memory.pressure_level		 # show the memory pressure level
>   memory.swappiness		 # set/show swappiness parameter of vmscan
>  				 (See sysctl's vm.swappiness)
>   memory.move_charge_at_immigrate # set/show controls of moving charges
> @@ -778,7 +780,69 @@ At reading, current status of OOM is shown.
>  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>  				 be stopped.)
>  
> -11. TODO
> +11. Memory Pressure
> +
> +To maintain the interactivity/memory allocation cost, one can use the
> +pressure level notifications, and the levels are defined like this:
> +
> +The "low" level means that the system is reclaiming memory for new
> +allocations. Monitoring reclaiming activity might be useful for
> +maintaining overall system's cache level. Upon notification, the program
> +(typically "Activity Manager") might analyze vmstat and act in advance
> +(i.e. prematurely shutdown unimportant services).
> +
> +The "medium" level means that the system is experiencing medium memory
> +pressure, there is some mild swapping activity. Upon this event
> +applications may decide to analyze vmstat/zoneinfo/memcg or internal
> +memory usage statistics and free any resources that can be easily
> +reconstructed or re-read from a disk.
> +
> +The "critical" level means that the system is actively thrashing, it is
> +about to out of memory (OOM) or even the in-kernel OOM killer is on its
> +way to trigger. Applications should do whatever they can to help the
> +system. It might be too late to consult with vmstat or any other
> +statistics, so it's advisable to take an immediate action.
> +
> +The events are propagated upward until the event is handled, i.e. the
> +events are not pass-through. Here is what this means: for example you have
> +three cgroups: A->B->C. Now you set up an event listener on cgroup A and
> +cgroup B, and suppose group C experiences some pressure. In this
> +situation, only group B will receive the notification, i.e. group A will
> +not receive it. This is done to avoid excessive "broadcasting" of
> +messages, which disturbs the system and which is especially bad if we are
> +low on memory or thrashing. So, organize the cgroups wisely, or propagate
> +the events manually (or, ask us to implement the pass-through events,
> +explaining why would you need them.)
> +
> +The file mempressure.level is used to show the current memory pressure
> +level, and cgroups event control file can be used to setup an eventfd
> +notification with a specific memory pressure level threshold.
> +
> + Read:
> +   Reads mempory presure levels: low, medium or critical.
> + Write:
> +   Not implemented.
> + Test:
> +   Here is a script: make a new cgroup, set up a memory limit, set up a
> +   notification on the parent cgroup, make child cgroup experience a
> +   critical pressure. Expected result is that the parent cgroup gets a
> +   notification:
> +
> +   (Note that we are seting up a listener on parent's cgroup, and then
> +   creating a child cgroup, showing how event propagation works.)
> +
> +   # cd /sys/fs/cgroup/memory/
> +   # cgroup_event_listener memory.pressure_level low &
> +   # mkdir foo
> +   # cd foo
> +   # echo 8000000 > memory.limit_in_bytes
> +   # echo $$ > tasks
> +   # dd if=/dev/zero | read x
> +
> +   (Expect a bunch of notifications, and eventually, the oom-killer will
> +   trigger.)
> +
> +12. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/init/Kconfig b/init/Kconfig
> index ccd1ca5..6d61ef5 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -908,6 +908,19 @@ config MEMCG_DEBUG_ASYNC_DESTROY
>  	  This is a developer-oriented debugging facility only, and no
>  	  guarantees of interface stability will be given.
>  
> +config MEMCG_PRESSURE
> +	bool "Memory Resource Controller Pressure Monitor"
> +	help
> +	  The memory pressure monitor provides a facility for userland
> +	  programs to watch for memory pressure on per-cgroup basis. This
> +	  is useful if you have programs that want to respond to the
> +	  pressure, possibly improving memory management.
> +
> +	  For more information see Memory Pressure section in
> +	  Documentation/cgroups/memory.txt.
> +
> +	  If unsure, say N.
> +
>  config CGROUP_HUGETLB
>  	bool "HugeTLB Resource Controller for Control Groups"
>  	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
> diff --git a/mm/Makefile b/mm/Makefile
> index 3a46287..51f7f52 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -51,6 +51,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>  obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o
> +obj-$(CONFIG_MEMCG_PRESSURE) += vmpressure.o
>  obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
>  obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
> diff --git a/mm/internal.h b/mm/internal.h
> index 1c0c4cc..eb50685 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -374,4 +374,38 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
>  #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
>  
> +struct vmpressure {
> +#ifdef CONFIG_MEMCG_PRESSURE
> +	unsigned int scanned;
> +	unsigned int reclaimed;
> +	/* The lock is used to keep the scanned/reclaimed above in sync. */
> +	struct mutex sr_lock;
> +
> +	struct list_head events;
> +	/* Have to grab the lock on events traversal or modifications. */
> +	struct mutex events_lock;
> +
> +	struct work_struct work;
> +#endif /* CONFIG_MEMCG_PRESSURE */
> +};
> +
> +struct mem_cgroup;
> +#ifdef CONFIG_MEMCG_PRESSURE
> +extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +		       unsigned long scanned, unsigned long reclaimed);
> +extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
> +extern void vmpressure_init(struct vmpressure *vmpr);
> +extern struct vmpressure *memcg_to_vmpr(struct mem_cgroup *memcg);
> +extern struct cgroup_subsys_state *vmpr_to_css(struct vmpressure *vmpr);
> +extern struct vmpressure *css_to_vmpr(struct cgroup_subsys_state *css);
> +extern void __init enable_pressure_cgroup(void);
> +#else
> +static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +			      unsigned long scanned, unsigned long reclaimed) {}
> +static inline void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg,
> +				   int prio) {}
> +static inline void vmpressure_init(struct vmpressure *vmpr) {}
> +static inline void __init enable_pressure_cgroup(void) {}
> +#endif /* CONFIG_MEMCG_PRESSURE */
> +
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 25ac5f4..60f277a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -370,6 +370,9 @@ struct mem_cgroup {
>  	atomic_t	numainfo_events;
>  	atomic_t	numainfo_updating;
>  #endif
> +
> +	struct vmpressure vmpr;
> +
>  	/*
>  	 * Per cgroup active and inactive list, similar to the
>  	 * per zone LRU lists.
> @@ -575,6 +578,26 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>  	return (memcg == root_mem_cgroup);
>  }
>  
> +/* Some nice accessors for the vmpressure. */
> +#ifdef CONFIG_MEMCG_PRESSURE
> +struct vmpressure *memcg_to_vmpr(struct mem_cgroup *memcg)
> +{
> +	if (!memcg)
> +		memcg = root_mem_cgroup;
> +	return &memcg->vmpr;
> +}
> +
> +struct cgroup_subsys_state *vmpr_to_css(struct vmpressure *vmpr)
> +{
> +	return &container_of(vmpr, struct mem_cgroup, vmpr)->css;
> +}
> +
> +struct vmpressure *css_to_vmpr(struct cgroup_subsys_state *css)
> +{
> +	return &mem_cgroup_from_css(css)->vmpr;
> +}
> +#endif /* CONFIG_MEMCG_PRESSURE */
> +
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> @@ -6291,6 +6314,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
>  	spin_lock_init(&memcg->move_lock);
> +	vmpressure_init(&memcg->vmpr);
>  
>  	return &memcg->css;
>  
> @@ -7018,6 +7042,7 @@ static int __init mem_cgroup_init(void)
>  {
>  	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>  	enable_swap_cgroup();
> +	enable_pressure_cgroup();
>  	mem_cgroup_soft_limit_tree_init();
>  	memcg_stock_init();
>  	return 0;
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> new file mode 100644
> index 0000000..7922503
> --- /dev/null
> +++ b/mm/vmpressure.c
> @@ -0,0 +1,300 @@
> +/*
> + * Linux VM pressure
> + *
> + * Copyright 2012 Linaro Ltd.
> + *		  Anton Vorontsov <anton.vorontsov@linaro.org>
> + *
> + * Based on ideas from Andrew Morton, David Rientjes, KOSAKI Motohiro,
> + * Leonid Moiseichuk, Mel Gorman, Minchan Kim and Pekka Enberg.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation.
> + */
> +
> +#include <linux/cgroup.h>
> +#include <linux/fs.h>
> +#include <linux/sched.h>
> +#include <linux/mm.h>
> +#include <linux/vmstat.h>
> +#include <linux/eventfd.h>
> +#include <linux/swap.h>
> +#include <linux/printk.h>
> +#include "internal.h"
> +
> +/*
> + * Generic VM Pressure routines (no cgroups or any other API details)
> + */
> +
> +/*
> + * The window size is the number of scanned pages before we try to analyze
> + * the scanned/reclaimed ratio (or difference).
> + *
> + * It is used as a rate-limit tunable for the "low" level notification,
> + * and for averaging medium/critical levels. Using small window sizes can
> + * cause lot of false positives, but too big window size will delay the
> + * notifications.
> + *
> + * TODO: Make the window size depend on machine size, as we do for vmstat
> + * thresholds.
> + */
> +static const unsigned int vmpressure_win = SWAP_CLUSTER_MAX * 16;
> +static const unsigned int vmpressure_level_med = 60;
> +static const unsigned int vmpressure_level_critical = 95;
> +static const unsigned int vmpressure_level_critical_prio = 3;
> +
> +enum vmpressure_levels {
> +	VMPRESSURE_LOW = 0,
> +	VMPRESSURE_MEDIUM,
> +	VMPRESSURE_CRITICAL,
> +	VMPRESSURE_NUM_LEVELS,
> +};
> +
> +static const char *vmpressure_str_levels[] = {
> +	[VMPRESSURE_LOW] = "low",
> +	[VMPRESSURE_MEDIUM] = "medium",
> +	[VMPRESSURE_CRITICAL] = "critical",
> +};
> +
> +static enum vmpressure_levels vmpressure_level(unsigned int pressure)
> +{
> +	if (pressure >= vmpressure_level_critical)
> +		return VMPRESSURE_CRITICAL;
> +	else if (pressure >= vmpressure_level_med)
> +		return VMPRESSURE_MEDIUM;
> +	return VMPRESSURE_LOW;
> +}
> +
> +static unsigned long vmpressure_calc_level(unsigned int win,
> +					   unsigned int s, unsigned int r)

Should seems like the return type of this function should be enum
vmpressure_levels?  If yes, then the 'return 0' below should be
VMPRESSURE_LOW.  And it would be nice if there was a little comment
describing the meaning of the win, s, and r parameters.  The "We
calculate ..." comment below makes me think that win is the number of
pages scanned, which makes me wonder what the s param is.

> +{
> +	unsigned long p;
> +
> +	if (!s)
> +		return 0;
> +
> +	/*
> +	 * We calculate the ratio (in percents) of how many pages were
> +	 * scanned vs. reclaimed in a given time frame (window). Note that
> +	 * time is in VM reclaimer's "ticks", i.e. number of pages
> +	 * scanned. This makes it possible to set desired reaction time
> +	 * and serves as a ratelimit.
> +	 */
> +	p = win - (r * win / s);
> +	p = p * 100 / win;
> +
> +	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
> +
> +	return vmpressure_level(p);
> +}
> +
> +void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +		unsigned long scanned, unsigned long reclaimed)
> +{
> +	struct vmpressure *vmpr = memcg_to_vmpr(memcg);
> +
> +	/*
> +	 * So far we are only interested application memory, or, in case
> +	 * of low pressure, in FS/IO memory reclaim. We are also
> +	 * interested indirect reclaim (kswapd sets sc->gfp_mask to
> +	 * GFP_KERNEL).
> +	 */
> +	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
> +		return;
> +
> +	if (!scanned)
> +		return;
> +
> +	mutex_lock(&vmpr->sr_lock);
> +	vmpr->scanned += scanned;
> +	vmpr->reclaimed += reclaimed;
> +	mutex_unlock(&vmpr->sr_lock);
> +
> +	if (scanned < vmpressure_win || work_pending(&vmpr->work))
> +		return;
> +	schedule_work(&vmpr->work);
> +}
> +
> +void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
> +{
> +	if (prio > vmpressure_level_critical_prio)
> +		return;
> +
> +	/* OK, the prio is below the threshold, we're about to oom. */
> +	vmpressure(gfp, memcg, vmpressure_win, 0);
> +}
> +
> +static struct vmpressure *wk_to_vmpr(struct work_struct *wk)
> +{
> +	return container_of(wk, struct vmpressure, work);
> +}
> +
> +static struct vmpressure *cg_to_vmpr(struct cgroup *cg)
> +{
> +	return css_to_vmpr(cgroup_subsys_state(cg, mem_cgroup_subsys_id));
> +}
> +
> +struct vmpressure_event {
> +	struct eventfd_ctx *efd;
> +	enum vmpressure_levels level;
> +	struct list_head node;
> +};
> +
> +static bool vmpressure_event(struct vmpressure *vmpr,
> +			     unsigned long s, unsigned long r)
> +{
> +	struct vmpressure_event *ev;
> +	int level = vmpressure_calc_level(vmpressure_win, s, r);
> +	bool signalled = 0;
s/bool/int/
> +
> +	mutex_lock(&vmpr->events_lock);
> +
> +	list_for_each_entry(ev, &vmpr->events, node) {
> +		if (level >= ev->level) {
> +			eventfd_signal(ev->efd, 1);
> +			signalled++;
> +		}
> +	}
> +
> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return signalled;
"return signalled != 0" or "return !!signaled"
> +}
> +
> +static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
> +{
> +	struct cgroup *cg = vmpr_to_css(vmpr)->cgroup->parent;
> +
> +	if (!cg)
> +		return NULL;
> +	return cg_to_vmpr(cg);
> +}
> +
> +static void vmpressure_wk_fn(struct work_struct *wk)
> +{
> +	struct vmpressure *vmpr = wk_to_vmpr(wk);
> +	unsigned long s;
> +	unsigned long r;
> +
> +	mutex_lock(&vmpr->sr_lock);
> +	s = vmpr->scanned;
> +	r = vmpr->reclaimed;
> +	vmpr->scanned = 0;
> +	vmpr->reclaimed = 0;
> +	mutex_unlock(&vmpr->sr_lock);
> +
> +	do {
> +		if (vmpressure_event(vmpr, s, r))
> +			break;
> +		/*
> +		 * If not handled, propagate the event upward into the
> +		 * hierarchy.
> +		 */
> +	} while ((vmpr = vmpressure_parent(vmpr)));
> +}
> +
> +/* cgroups "frontend" for vmpressure. */
> +
> +static ssize_t vmpressure_read_level(struct cgroup *cg, struct cftype *cft,
> +				     struct file *file, char __user *buf,
> +				     size_t sz, loff_t *ppos)
> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	unsigned int level;
> +	const char *str;
> +	ssize_t len = 0;
> +
> +	if (*ppos >= sz)
> +		return 0;
> +
> +	mutex_lock(&vmpr->sr_lock);
> +
> +	level = vmpressure_calc_level(vmpressure_win,
> +			vmpr->scanned, vmpr->reclaimed);
> +
> +	mutex_unlock(&vmpr->sr_lock);
> +
> +	str = vmpressure_str_levels[level];
> +	len += strlen(str) + 1;
> +	if (len > sz)
> +		return -EINVAL;
> +
> +	if (copy_to_user(buf, str, len - 1))
> +		return -EFAULT;
> +	if (copy_to_user(buf + len - 1, "\n", 1))
> +		return -EFAULT;
> +
> +	*ppos += sz;
> +	return len;
> +}
> +
> +static int vmpressure_register_level(struct cgroup *cg, struct cftype *cft,
> +				     struct eventfd_ctx *eventfd,
> +				     const char *args)
> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	struct vmpressure_event *ev;
> +	int lvl;
> +
> +	for (lvl = 0; lvl < VMPRESSURE_NUM_LEVELS; lvl++) {
> +		if (!strcmp(vmpressure_str_levels[lvl], args))
> +			break;
> +	}
> +
> +	if (lvl >= VMPRESSURE_NUM_LEVELS)
> +		return -EINVAL;
> +
> +	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
> +	if (!ev)
> +		return -ENOMEM;
> +
> +	ev->efd = eventfd;
> +	ev->level = lvl;
> +
> +	mutex_lock(&vmpr->events_lock);
> +	list_add(&ev->node, &vmpr->events);
> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return 0;
> +}
> +
> +static void vmpressure_unregister_level(struct cgroup *cg, struct cftype *cft,
> +					struct eventfd_ctx *eventfd)
> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	struct vmpressure_event *ev;
> +
> +	mutex_lock(&vmpr->events_lock);
> +	list_for_each_entry(ev, &vmpr->events, node) {
> +		if (ev->efd != eventfd)
> +			continue;
> +		list_del(&ev->node);
> +		kfree(ev);
> +		break;
> +	}
> +	mutex_unlock(&vmpr->events_lock);
> +}
> +
> +static struct cftype vmpressure_cgroup_files[] = {
> +	{
> +		.name = "pressure_level",
> +		.read = vmpressure_read_level,
> +		.register_event = vmpressure_register_level,
> +		.unregister_event = vmpressure_unregister_level,
> +	},
> +	{},
> +};
> +
> +void vmpressure_init(struct vmpressure *vmpr)
> +{
> +	mutex_init(&vmpr->sr_lock);
> +	mutex_init(&vmpr->events_lock);
> +	INIT_LIST_HEAD(&vmpr->events);
> +	INIT_WORK(&vmpr->work, vmpressure_wk_fn);
> +}
> +
> +void __init enable_pressure_cgroup(void)
> +{
> +	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys,
> +				   vmpressure_cgroup_files));
> +}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 88c5fed..34f09b9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1982,6 +1982,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  			}
>  			memcg = mem_cgroup_iter(root, memcg, &reclaim);
>  		} while (memcg);
> +
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> +			   sc->nr_scanned - nr_scanned, nr_reclaimed);

(sc->nr_scanned - nr_scanned) is the number of pages scanned in above
while loop but nr_reclaimed is the starting position of the reclaim
counter before the loop.  It seems like you want:
	vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
		   sc->nr_scanned - nr_scanned, 
		   sc->nr_reclaimed - nr_reclaimed);

> +
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
>  }
> @@ -2167,6 +2171,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		count_vm_event(ALLOCSTALL);
>  
>  	do {
> +		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> +				sc->priority);
>  		sc->nr_scanned = 0;
>  		aborted_reclaim = shrink_zones(zonelist, sc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
