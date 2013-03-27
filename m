Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7CD5D6B006C
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 21:54:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9391A3EE0C5
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:54:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 451F045DEBF
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:54:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 256EE45DEBA
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:54:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B242E08003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:54:32 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9839E1DB803B
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:54:31 +0900 (JST)
Message-ID: <5152511A.1010707@jp.fujitsu.com>
Date: Wed, 27 Mar 2013 10:53:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] memcg: Add memory.pressure_level events
References: <20130322071351.GA3971@lizard.gateway.2wire.net>
In-Reply-To: <20130322071351.GA3971@lizard.gateway.2wire.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(2013/03/22 16:13), Anton Vorontsov wrote:
> With this patch userland applications that want to maintain the
> interactivity/memory allocation cost can use the pressure level
> notifications. The levels are defined like this:
>
> The "low" level means that the system is reclaiming memory for new
> allocations. Monitoring this reclaiming activity might be useful for
> maintaining cache level. Upon notification, the program (typically
> "Activity Manager") might analyze vmstat and act in advance (i.e.
> prematurely shutdown unimportant services).
>
> The "medium" level means that the system is experiencing medium memory
> pressure, the system might be making swap, paging out active file caches,
> etc. Upon this event applications may decide to further analyze
> vmstat/zoneinfo/memcg or internal memory usage statistics and free any
> resources that can be easily reconstructed or re-read from a disk.
>
> The "critical" level means that the system is actively thrashing, it is
> about to out of memory (OOM) or even the in-kernel OOM killer is on its
> way to trigger. Applications should do whatever they can to help the
> system. It might be too late to consult with vmstat or any other
> statistics, so it's advisable to take an immediate action.
>
> The events are propagated upward until the event is handled, i.e. the
> events are not pass-through. Here is what this means: for example you have
> three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
> and C, and suppose group C experiences some pressure. In this situation,
> only group C will receive the notification, i.e. groups A and B will not
> receive it. This is done to avoid excessive "broadcasting" of messages,
> which disturbs the system and which is especially bad if we are low on
> memory or thrashing. So, organize the cgroups wisely, or propagate the
> events manually (or, ask us to implement the pass-through events,
> explaining why would you need them.)
>
> Performance wise, the memory pressure notifications feature itself is
> lightweight and does not require much of bookkeeping, in contrast to the
> rest of memcg features. Unfortunately, as of current memcg implementation,
> pages accounting is an inseparable part and cannot be turned off. The good
> news is that there are some efforts[1] to improve the situation; plus,
> implementing the same, fully API-compatible[2] interface for
> CONFIG_MEMCG=n case (e.g. embedded) is also a viable option, so it will
> not require any changes on the userland side.
>
> [1] http://permalink.gmane.org/gmane.linux.kernel.cgroups/6291
> [2] http://lkml.org/lkml/2013/2/21/454
>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>
> Hi all,
>
> Here is a shiny new v3!
>
> In v3:
>
> - No changes in the code, just updated commit message to incorporate the
>    answer to Minchan Kim's comment regarding applicability to embedded use
>    cases in the light of memcg performance overhead, plus gave some
>    references to Glauber Costa's memcg work.
>
> - Rebased onto 3.9.0-rc3-next-20130321.
>
> In v2:
>
> - Addressed Glauber Costa's comments:
>    o Use parent_mem_cgroup() instead of own parent function (also suggested
>      by Kamezawa). This change also affected events distribution logic, so
>      it became more like memory thresholds notifications, i.e. we deliver
>      the event to the cgroup where the event originated, not to the parent
>      cgroup; (This also addreses Kamezawa's remark regarding which cgroup
>      receives which event.)
>    o Register vmpressure cgroup file directly in memcontrol.c.
>
>    - Addressed Greg Thelen's comments:
>      o Fixed bool/int inconsistency in the code;
>      o Fixed nr_scanned accounting;
>      o Don't use cryptic 's', 'r' abbreviations; get rid of confusing
>        'window' argument.
>
> - Addressed Kamezawa Hiroyuki's comments:
>    o Moved declarations from mm/internal.h into linux/vmpressue.h;
>    o Removed Kconfig symbol. Vmpressure is pretty lightweight (especially
>      comparing to the memcg accounting). If it ever causes any measurable
>      performance effect, we want to fix it, not paper it over with a
>      Kconfig option. :-)
>    o Removed read operation on pressure_level cgroup file. In apps, we only
>      use notifications, we don't need the content of the file, so let's
>      keep things simple for now. Plus this resolves questions like what
>      should we return there when the system is not reclaiming;
>    o Reworded documentation;
>    o Improved comments for vmpressure_prio().
>
> Old changelogs/submissions:
>    v2: http://lkml.org/lkml/2013/2/18/577
>    v1: http://lkml.org/lkml/2013/2/10/140
>    mempressure cgroup: http://lkml.org/lkml/2013/1/4/55
>
>   Documentation/cgroups/memory.txt |  61 +++++++++-
>   include/linux/vmpressure.h       |  47 ++++++++
>   mm/Makefile                      |   2 +-
>   mm/memcontrol.c                  |  28 +++++
>   mm/vmpressure.c                  | 252 +++++++++++++++++++++++++++++++++++++++
>   mm/vmscan.c                      |   8 ++
>   6 files changed, 396 insertions(+), 2 deletions(-)
>   create mode 100644 include/linux/vmpressure.h
>   create mode 100644 mm/vmpressure.c
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index addb1f1..0c004de 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -40,6 +40,7 @@ Features:
>    - soft limit
>    - moving (recharging) account at moving a task is selectable.
>    - usage threshold notifier
> + - memory pressure notifier
>    - oom-killer disable knob and oom-notifier
>    - Root cgroup has no limit controls.
>
> @@ -65,6 +66,7 @@ Brief summary of control files.
>    memory.stat			 # show various statistics
>    memory.use_hierarchy		 # set/show hierarchical account enabled
>    memory.force_empty		 # trigger forced move charge to parent
> + memory.pressure_level		 # set memory pressure notifications
>    memory.swappiness		 # set/show swappiness parameter of vmscan
>   				 (See sysctl's vm.swappiness)
>    memory.move_charge_at_immigrate # set/show controls of moving charges
> @@ -778,7 +780,64 @@ At reading, current status of OOM is shown.
>   	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>   				 be stopped.)
>
> -11. TODO
> +11. Memory Pressure
> +
> +The pressure level notifications can be used to monitor the memory
> +allocation cost; based on the pressure, applications can implement
> +different strategies of managing their memory resources. The pressure
> +levels are defined as following:
> +
> +The "low" level means that the system is reclaiming memory for new
> +allocations. Monitoring this reclaiming activity might be useful for
> +maintaining cache level. Upon notification, the program (typically
> +"Activity Manager") might analyze vmstat and act in advance (i.e.
> +prematurely shutdown unimportant services).
> +
> +The "medium" level means that the system is experiencing medium memory
> +pressure, the system might be making swap, paging out active file caches,
> +etc. Upon this event applications may decide to further analyze
> +vmstat/zoneinfo/memcg or internal memory usage statistics and free any
> +resources that can be easily reconstructed or re-read from a disk.
> +
> +The "critical" level means that the system is actively thrashing, it is
> +about to out of memory (OOM) or even the in-kernel OOM killer is on its
> +way to trigger. Applications should do whatever they can to help the
> +system. It might be too late to consult with vmstat or any other
> +statistics, so it's advisable to take an immediate action.
> +
> +The events are propagated upward until the event is handled, i.e. the
> +events are not pass-through. Here is what this means: for example you have
> +three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
> +and C, and suppose group C experiences some pressure. In this situation,
> +only group C will receive the notification, i.e. groups A and B will not
> +receive it. This is done to avoid excessive "broadcasting" of messages,
> +which disturbs the system and which is especially bad if we are low on
> +memory or thrashing. So, organize the cgroups wisely, or propagate the
> +events manually (or, ask us to implement the pass-through events,
> +explaining why would you need them.)
> +
> +The file memory.pressure_level is only used to setup an eventfd,
> +read/write operations are no implemented.
> +

I'll make an ack with this spec. some nitpicks below.

> +Test:
> +
> +   Here is a small script example that makes a new cgroup, sets up a
> +   memory limit, sets up a notification in the cgroup and then makes child
> +   cgroup experience a critical pressure:
> +
> +   # cd /sys/fs/cgroup/memory/
> +   # mkdir foo
> +   # cd foo
> +   # cgroup_event_listener memory.pressure_level low &
> +   # echo 8000000 > memory.limit_in_bytes
> +   # echo 8000000 > memory.memsw.limit_in_bytes
> +   # echo $$ > tasks
> +   # dd if=/dev/zero | read x
> +
> +   (Expect a bunch of notifications, and eventually, the oom-killer will
> +   trigger.)
> +
> +12. TODO
>
>   1. Add support for accounting huge pages (as a separate controller)
>   2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> new file mode 100644
> index 0000000..fa84783
> --- /dev/null
> +++ b/include/linux/vmpressure.h
> @@ -0,0 +1,47 @@
> +#ifndef __LINUX_VMPRESSURE_H
> +#define __LINUX_VMPRESSURE_H
> +
> +#include <linux/mutex.h>
> +#include <linux/list.h>
> +#include <linux/workqueue.h>
> +#include <linux/gfp.h>
> +#include <linux/types.h>
> +#include <linux/cgroup.h>
> +
> +struct vmpressure {
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
> +};
> +
> +struct mem_cgroup;
> +
> +#ifdef CONFIG_MEMCG
> +extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +		       unsigned long scanned, unsigned long reclaimed);
> +extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
> +#else
> +static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +			      unsigned long scanned, unsigned long reclaimed) {}
> +static inline void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg,
> +				   int prio) {}
> +#endif /* CONFIG_MEMCG */
> +
> +extern void vmpressure_init(struct vmpressure *vmpr);
> +extern struct vmpressure *memcg_to_vmpr(struct mem_cgroup *memcg);
> +extern struct cgroup_subsys_state *vmpr_to_css(struct vmpressure *vmpr);
> +extern struct vmpressure *css_to_vmpr(struct cgroup_subsys_state *css);
> +extern int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
> +				     struct eventfd_ctx *eventfd,
> +				     const char *args);
> +extern void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
> +					struct eventfd_ctx *eventfd);
> +
> +#endif /* __LINUX_VMPRESSURE_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index 3a46287..72c5acb 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -50,7 +50,7 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
>   obj-$(CONFIG_MIGRATION) += migrate.o
>   obj-$(CONFIG_QUICKLIST) += quicklist.o
>   obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
> -obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o
> +obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
>   obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
>   obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>   obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f608546..2482f2c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -49,6 +49,7 @@
>   #include <linux/fs.h>
>   #include <linux/seq_file.h>
>   #include <linux/vmalloc.h>
> +#include <linux/vmpressure.h>
>   #include <linux/mm_inline.h>
>   #include <linux/page_cgroup.h>
>   #include <linux/cpu.h>
> @@ -376,6 +377,9 @@ struct mem_cgroup {
>   	atomic_t	numainfo_events;
>   	atomic_t	numainfo_updating;
>   #endif
> +
> +	struct vmpressure vmpr;
> +

How about placing this just below "memsw_threshold" ?
memory objects around there is not performance critical.


>   	/*
>   	 * Per cgroup active and inactive list, similar to the
>   	 * per zone LRU lists.
> @@ -576,6 +580,24 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>   	return container_of(s, struct mem_cgroup, css);
>   }
>
> +/* Some nice accessors for the vmpressure. */
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
> +
>   static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>   {
>   	return (memcg == root_mem_cgroup);
> @@ -6074,6 +6096,11 @@ static struct cftype mem_cgroup_files[] = {
>   		.unregister_event = mem_cgroup_oom_unregister_event,
>   		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>   	},
> +	{
> +		.name = "pressure_level",
> +		.register_event = vmpressure_register_event,
> +		.unregister_event = vmpressure_unregister_event,
> +	},
>   #ifdef CONFIG_NUMA
>   	{
>   		.name = "numa_stat",
> @@ -6365,6 +6392,7 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>   	memcg->move_charge_at_immigrate = 0;
>   	mutex_init(&memcg->thresholds_lock);
>   	spin_lock_init(&memcg->move_lock);
> +	vmpressure_init(&memcg->vmpr);
>
>   	return &memcg->css;
>
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> new file mode 100644
> index 0000000..ae0ff8e
> --- /dev/null
> +++ b/mm/vmpressure.c
> @@ -0,0 +1,252 @@
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
> +#include <linux/vmpressure.h>
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
more comments are welcomed...

I'm not against the numbers themselves but I'm not sure how these numbers are
selected...I'm glad if you show some reasons in changelog or somewhere.

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
> +static enum vmpressure_levels vmpressure_calc_level(unsigned int scanned,
> +						    unsigned int reclaimed)
> +{
> +	unsigned long scale = scanned + reclaimed;
> +	unsigned long pressure;
> +
> +	if (!scanned)
> +		return VMPRESSURE_LOW;

Can you add comment here ? When !scanned happens ?

> +
> +	/*
> +	 * We calculate the ratio (in percents) of how many pages were
> +	 * scanned vs. reclaimed in a given time frame (window). Note that
> +	 * time is in VM reclaimer's "ticks", i.e. number of pages
> +	 * scanned. This makes it possible to set desired reaction time
> +	 * and serves as a ratelimit.
> +	 */
> +	pressure = scale - (reclaimed * scale / scanned);
> +	pressure = pressure * 100 / scale;
> +
> +	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, pressure,
> +		 scanned, reclaimed);
> +
> +	return vmpressure_level(pressure);
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

I'm not sure how other guys thinks but....could you place the definition
of work_fn above calling it ? you call vmpressure_wk_fn(), right ?

> +
> +void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
> +{
> +	if (prio > vmpressure_level_critical_prio)
> +		return;
> +
> +	/*
> +	 * OK, the prio is below the threshold, updating vmpressure
> +	 * information before diving into long shrinking of long range
> +	 * vmscan.
> +	 */
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
> +			     unsigned long scanned, unsigned long reclaimed)
> +{
> +	struct vmpressure_event *ev;
> +	int level = vmpressure_calc_level(scanned, reclaimed);
> +	bool signalled = false;
> +
> +	mutex_lock(&vmpr->events_lock);
> +
> +	list_for_each_entry(ev, &vmpr->events, node) {
> +		if (level >= ev->level) {
> +			eventfd_signal(ev->efd, 1);
> +			signalled = true;
> +		}
> +	}
> +
> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return signalled;
> +}
> +
> +static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
> +{
> +	struct cgroup *cg = vmpr_to_css(vmpr)->cgroup;
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cg);
> +
> +	memcg = parent_mem_cgroup(memcg);
> +	if (!memcg)
> +		return NULL;
> +	return memcg_to_vmpr(memcg);
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
> +int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
> +			      struct eventfd_ctx *eventfd, const char *args)
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
> +void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
> +				 struct eventfd_ctx *eventfd)
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
> +void vmpressure_init(struct vmpressure *vmpr)
> +{
> +	mutex_init(&vmpr->sr_lock);
> +	mutex_init(&vmpr->events_lock);
> +	INIT_LIST_HEAD(&vmpr->events);
> +	INIT_WORK(&vmpr->work, vmpressure_wk_fn);
> +}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index df78d17..616e2bb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -19,6 +19,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/init.h>
>   #include <linux/highmem.h>
> +#include <linux/vmpressure.h>
>   #include <linux/vmstat.h>
>   #include <linux/file.h>
>   #include <linux/writeback.h>
> @@ -1982,6 +1983,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>   			}
>   			memcg = mem_cgroup_iter(root, memcg, &reclaim);
>   		} while (memcg);
> +
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> +			   sc->nr_scanned - nr_scanned,
> +			   sc->nr_reclaimed - nr_reclaimed);
> +
>   	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>   					 sc->nr_scanned - nr_scanned, sc));
>   }
> @@ -2167,6 +2173,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>   		count_vm_event(ALLOCSTALL);
>
>   	do {
> +		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> +				sc->priority);
>   		sc->nr_scanned = 0;
>   		aborted_reclaim = shrink_zones(zonelist, sc);
>
>

When you answers Andrew's comment and fix problems, feel free to add

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
