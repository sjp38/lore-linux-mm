Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A87E46B014F
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:46:58 -0400 (EDT)
Date: Tue, 26 Mar 2013 13:46:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] memcg: Add memory.pressure_level events
Message-Id: <20130326134656.4e0e0aefcf881bffae769b1e@linux-foundation.org>
In-Reply-To: <20130322071351.GA3971@lizard.gateway.2wire.net>
References: <20130322071351.GA3971@lizard.gateway.2wire.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, 22 Mar 2013 00:13:51 -0700 Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

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

Nicely presented patch, thanks.

The interface still seems a bit of a toy, but is a conservative
approach: anything less toy-like would expose (and hence be dependent
upon) more VM internals.

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
> + memory.pressure_level		 # set memory pressure notifications
>   memory.swappiness		 # set/show swappiness parameter of vmscan
>  				 (See sysctl's vm.swappiness)
>   memory.move_charge_at_immigrate # set/show controls of moving charges
> @@ -778,7 +780,64 @@ At reading, current status of OOM is shown.
>  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>  				 be stopped.)
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

Did we tell people how to use the eventfd interface anywhere?

>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
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

A comment describing what goes at `events' would be nice.  Reference
"struct vmpressure_event".

> +	/* Have to grab the lock on events traversal or modifications. */
> +	struct mutex events_lock;
> +
> +	struct work_struct work;
> +};
>
> ...
>
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

Here "the window size" refers to vmpressure_win, yes?

> + */
> +static const unsigned int vmpressure_win = SWAP_CLUSTER_MAX * 16;
> +static const unsigned int vmpressure_level_med = 60;
> +static const unsigned int vmpressure_level_critical = 95;
> +static const unsigned int vmpressure_level_critical_prio = 3;

vmpressure_level_critical_prio is a bit mysterious and undocumented. 
Please document it here and/or at vmpressure_prio().

> +
> +enum vmpressure_levels {
> +	VMPRESSURE_LOW = 0,
> +	VMPRESSURE_MEDIUM,
> +	VMPRESSURE_CRITICAL,
> +	VMPRESSURE_NUM_LEVELS,
> +};
>
> ...
>
> +static enum vmpressure_levels vmpressure_calc_level(unsigned int scanned,
> +						    unsigned int reclaimed)
> +{
> +	unsigned long scale = scanned + reclaimed;
> +	unsigned long pressure;
> +
> +	if (!scanned)
> +		return VMPRESSURE_LOW;
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

The types worry me.  The patch switches the vm's unsigned longs into
unsigneds.  We have a long and sorry history of overflowing 32-bit
counters in VM corner cases.  I suggest that this patch should
carefully use `unsigned longs' in all the appropriate places and do
away with its present truncation and overflow risks.

> +void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> +		unsigned long scanned, unsigned long reclaimed)

Exported function and a primary inteface.  Needs nice documentation, please ;)

> +{
> +	struct vmpressure *vmpr = memcg_to_vmpr(memcg);
> +
> +	/*
> +	 * So far we are only interested application memory, or, in case

"interested in"

> +	 * of low pressure, in FS/IO memory reclaim. We are also
> +	 * interested indirect reclaim (kswapd sets sc->gfp_mask to
> +	 * GFP_KERNEL).

This is all pretty obvious from reading the code.  Good comments
explain "why", not "what".  *why* did we make these decisions?

> +	 */
> +	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))

I'm surprised at __GFP_HIGHMEM's inclusion.  On some machines the great
majority of user memory is in highmem.  What's up?

> +		return;
> +
> +	if (!scanned)
> +		return;
> +
> +	mutex_lock(&vmpr->sr_lock);
> +	vmpr->scanned += scanned;
> +	vmpr->reclaimed += reclaimed;

See, here we're accumulating into a 32-bit variable quantities which used
to be held in 64-bit variables.    The overflow risk gets higher...

> +	mutex_unlock(&vmpr->sr_lock);
> +
> +	if (scanned < vmpressure_win || work_pending(&vmpr->work))
> +		return;
> +	schedule_work(&vmpr->work);
> +}
> +
> +void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)

Documentation please.

> +{
> +	if (prio > vmpressure_level_critical_prio)
> +		return;
> +
> +	/*
> +	 * OK, the prio is below the threshold, updating vmpressure

But you never told me what that threshold is for!  And I have no means
of working out why you chose "3", nor the effects of altering it, etc.

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

Here's where we go from 64-bit to 32-bit.

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
>
> ...
>
> +int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
> +			      struct eventfd_ctx *eventfd, const char *args)

Document the interface, please.

> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	struct vmpressure_event *ev;
> +	int lvl;

These abbreviations are rather unlinuxy.  wk->work, vmpr->vmpressure,
lvl->level, etc.

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

What's the upper bound on the length of this list?

> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return 0;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
