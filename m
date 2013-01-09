Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 64E556B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:56:45 -0500 (EST)
Message-ID: <50ED30CE.8070208@parallels.com>
Date: Wed, 9 Jan 2013 12:56:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add mempressure cgroup
References: <20130104082751.GA22227@lizard.gateway.2wire.net> <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi.

I have a couple of small questions.

On 01/04/2013 12:29 PM, Anton Vorontsov wrote:
> This commit implements David Rientjes' idea of mempressure cgroup.
> 
> The main characteristics are the same to what I've tried to add to vmevent
> API; internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
> pressure index calculation. But we don't expose the index to the userland.
> Instead, there are three levels of the pressure:
> 
>  o low (just reclaiming, e.g. caches are draining);
>  o medium (allocation cost becomes high, e.g. swapping);
>  o oom (about to oom very soon).
> 
> The rationale behind exposing levels and not the raw pressure index
> described here: http://lkml.org/lkml/2012/11/16/675
> 
> For a task it is possible to be in both cpusets, memcg and mempressure
> cgroups, so by rearranging the tasks it is possible to watch a specific
> pressure (i.e. caused by cpuset and/or memcg).
> 
> Note that while this adds the cgroups support, the code is well separated
> and eventually we might add a lightweight, non-cgroups API, i.e. vmevent.
> But this is another story.
Andrew already said he would like to see this exposed to non cgroup
users, I'll just add to that: I'd like the interfaces to be consistent.

We need to make sure that cgroups and non-cgroup users will act on this
in the same way. So it is important that this is included in the
proposition, so we can judge and avoid a future kludge.

> diff --git a/Documentation/cgroups/mempressure.txt b/Documentation/cgroups/mempressure.txt
> new file mode 100644
> index 0000000..dbc0aca
> --- /dev/null
> +++ b/Documentation/cgroups/mempressure.txt
> @@ -0,0 +1,50 @@
> +  Memory pressure cgroup
> +~~~~~~~~~~~~~~~~~~~~~~~~~~
> +  Before using the mempressure cgroup, make sure you have it mounted:
> +
> +   # cd /sys/fs/cgroup/
> +   # mkdir mempressure
> +   # mount -t cgroup cgroup ./mempressure -o mempressure
> +
> +  It is possible to combine cgroups, for example you can mount memory
> +  (memcg) and mempressure cgroups together:
> +
> +   # mount -t cgroup cgroup ./mempressure -o memory,mempressure
> +

Most of the time these days, the groups are mounted separately. The
tasks, however, still belong to one or more controllers regardless of
where they are mounted.

Can you describe a bit better (not only in reply, but also update the
docs) what happens when:

1) both cpusets and memcg are present. Which one takes precedence? Will
there be a way to differentiate which kind of pressure is being seen so
I as a task can adjust my actions accordingly?

2) the task belongs to memcg (or cpuset), but the controllers itself are
mounted separately. Is it equivalent to mounted them jointly? Will this
fact just be ignored by the pressure levels?

I can guess the answer to some of them by the code, but I think it is
quite important to have all this crystal clear.

> +    ("low", "medium", "oom" are permitted.)
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index f204a7a..b9802e2 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -37,6 +37,12 @@ SUBSYS(mem_cgroup)
>  
>  /* */
>  
> +#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_MEMPRESSURE)
> +SUBSYS(mpc_cgroup)
> +#endif

It might be just me, but if one does not know what this is about, "mpc"
immediately fetches something communication-related to mind. I would
suggest changing this to just plain "mempressure_cgroup", or something
more descriptive.

> diff --git a/mm/mempressure.c b/mm/mempressure.c
> new file mode 100644
> index 0000000..ea312bb
> --- /dev/null
> +++ b/mm/mempressure.c
> @@ -0,0 +1,330 @@
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
> +
> +static void mpc_vmpressure(struct mem_cgroup *memcg, ulong s, ulong r);
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
> + * and for averaging medium/oom levels. Using small window sizes can cause
> + * lot of false positives, but too big window size will delay the
> + * notifications.
> + */
> +static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;
> +static const uint vmpressure_level_med = 60;
> +static const uint vmpressure_level_oom = 99;
> +static const uint vmpressure_level_oom_prio = 4;
> +
> +enum vmpressure_levels {
> +	VMPRESSURE_LOW = 0,
> +	VMPRESSURE_MEDIUM,
> +	VMPRESSURE_OOM,
> +	VMPRESSURE_NUM_LEVELS,
> +};
> +
> +static const char *vmpressure_str_levels[] = {
> +	[VMPRESSURE_LOW] = "low",
> +	[VMPRESSURE_MEDIUM] = "medium",
> +	[VMPRESSURE_OOM] = "oom",
> +};
> +
> +static enum vmpressure_levels vmpressure_level(uint pressure)
> +{
> +	if (pressure >= vmpressure_level_oom)
> +		return VMPRESSURE_OOM;
> +	else if (pressure >= vmpressure_level_med)
> +		return VMPRESSURE_MEDIUM;
> +	return VMPRESSURE_LOW;
> +}
> +
> +static ulong vmpressure_calc_level(uint win, uint s, uint r)
> +{
> +	ulong p;
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
> +void vmpressure(struct mem_cgroup *memcg, ulong scanned, ulong reclaimed)
> +{
> +	if (!scanned)
> +		return;
> +	mpc_vmpressure(memcg, scanned, reclaimed);
> +}
> +
> +void vmpressure_prio(struct mem_cgroup *memcg, int prio)
> +{
> +	if (prio > vmpressure_level_oom_prio)
> +		return;
> +
> +	/* OK, the prio is below the threshold, send the pre-OOM event. */
> +	vmpressure(memcg, vmpressure_win, 0);
> +}
> +
> +/*
> + * Memory pressure cgroup code
> + */
> +
> +struct mpc_event {
> +	struct eventfd_ctx *efd;
> +	enum vmpressure_levels level;
> +	struct list_head node;
> +};
> +
> +struct mpc_state {
> +	struct cgroup_subsys_state css;
> +
> +	uint scanned;
> +	uint reclaimed;
> +	struct mutex sr_lock;
> +
> +	struct list_head events;
> +	struct mutex events_lock;
> +
> +	struct work_struct work;
> +};
> +
> +static struct mpc_state *wk2mpc(struct work_struct *wk)
> +{
> +	return container_of(wk, struct mpc_state, work);
> +}
> +
> +static struct mpc_state *css2mpc(struct cgroup_subsys_state *css)
> +{
> +	return container_of(css, struct mpc_state, css);
> +}
> +
> +static struct mpc_state *tsk2mpc(struct task_struct *tsk)
> +{
> +	return css2mpc(task_subsys_state(tsk, mpc_cgroup_subsys_id));
> +}
> +
> +static struct mpc_state *cg2mpc(struct cgroup *cg)
> +{
> +	return css2mpc(cgroup_subsys_state(cg, mpc_cgroup_subsys_id));
> +}

I think we would be better of with more descriptive names here as well.
Other cgroups would use the convention of using _to_ and _from_ in names
instead of 2.

For instance, task_to_mempressure is a lot more descriptive than
"tsk2mpc". There are no bonus points for manually compressing code.

> +
> +static void mpc_vmpressure(struct mem_cgroup *memcg, ulong s, ulong r)
> +{
> +	/*
> +	 * There are two options for implementing cgroup pressure
> +	 * notifications:
> +	 *
> +	 * - Store pressure counter atomically in the task struct. Upon
> +	 *   hitting 'window' wake up a workqueue that will walk every
> +	 *   task and sum per-thread pressure into cgroup pressure (to
> +	 *   which the task belongs). The cons are obvious: bloats task
> +	 *   struct, have to walk all processes and makes pressue less
> +	 *   accurate (the window becomes per-thread);
> +	 *
> +	 * - Store pressure counters in per-cgroup state. This is easy and
> +	 *   straightforward, and that's how we do things here. But this
> +	 *   requires us to not put the vmpressure hooks into hotpath,
> +	 *   since we have to grab some locks.
> +	 */
> +
> +#ifdef CONFIG_MEMCG
> +	if (memcg) {
> +		struct cgroup_subsys_state *css = mem_cgroup_css(memcg);
> +		struct cgroup *cg = css->cgroup;
> +		struct mpc_state *mpc = cg2mpc(cg);
> +
> +		if (mpc)
> +			__mpc_vmpressure(mpc, s, r);
> +		return;
> +	}
> +#endif
> +	task_lock(current);
> +	__mpc_vmpressure(tsk2mpc(current), s, r);
> +	task_unlock(current);
> +}

How about cpusets?

I still see no significant mention of it, and I would like to understand
how does it get into play in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
