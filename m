Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4E8656B009B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:06:48 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id j5so904351iaf.14
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 21:06:47 -0700 (PDT)
Date: Tue, 2 Apr 2013 21:02:46 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v3] memcg: Add memory.pressure_level events
Message-ID: <20130403040246.GA32229@lizard.gateway.2wire.net>
References: <20130322071351.GA3971@lizard.gateway.2wire.net>
 <20130326134656.4e0e0aefcf881bffae769b1e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130326134656.4e0e0aefcf881bffae769b1e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Mar 26, 2013 at 01:46:56PM -0700, Andrew Morton wrote:
[...]
> > +The file memory.pressure_level is only used to setup an eventfd,
> > +read/write operations are no implemented.
[...]
> Did we tell people how to use the eventfd interface anywhere?

Good point. In v4 I added a detailed instructions on how to setup the file
descriptors.

> >  1. Add support for accounting huge pages (as a separate controller)
> >  2. Make per-cgroup scanner reclaim not-shared pages first
> > diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> > --- /dev/null
> > +++ b/include/linux/vmpressure.h
> > @@ -0,0 +1,47 @@
> > +#ifndef __LINUX_VMPRESSURE_H
> > +#define __LINUX_VMPRESSURE_H
> > +
> > +#include <linux/mutex.h>
> > +#include <linux/list.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/gfp.h>
> > +#include <linux/types.h>
> > +#include <linux/cgroup.h>
> > +
> > +struct vmpressure {
> > +	unsigned int scanned;
> > +	unsigned int reclaimed;
> > +	/* The lock is used to keep the scanned/reclaimed above in sync. */
> > +	struct mutex sr_lock;
> > +
> > +	struct list_head events;
> 
> A comment describing what goes at `events' would be nice.  Reference
> "struct vmpressure_event".

Done.

> > +	/* Have to grab the lock on events traversal or modifications. */
> > +	struct mutex events_lock;
> > +
> > +	struct work_struct work;
> > +};
> >
> > ...
> >
> > +/*
> > + * The window size is the number of scanned pages before we try to analyze
> > + * the scanned/reclaimed ratio (or difference).
> > + *
> > + * It is used as a rate-limit tunable for the "low" level notification,
> > + * and for averaging medium/critical levels. Using small window sizes can
> > + * cause lot of false positives, but too big window size will delay the
> > + * notifications.
> > + *
> > + * TODO: Make the window size depend on machine size, as we do for vmstat
> > + * thresholds.
> 
> Here "the window size" refers to vmpressure_win, yes?

Yup.

(To make it clear, in the new version I added a direct reference to the
vmpressure_win.)

> > + */
> > +static const unsigned int vmpressure_win = SWAP_CLUSTER_MAX * 16;
> > +static const unsigned int vmpressure_level_med = 60;
> > +static const unsigned int vmpressure_level_critical = 95;
> > +static const unsigned int vmpressure_level_critical_prio = 3;
> 
> vmpressure_level_critical_prio is a bit mysterious and undocumented. 
> Please document it here and/or at vmpressure_prio().

I added documentation in v4.

> > +void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
> > +		unsigned long scanned, unsigned long reclaimed)
> 
> Exported function and a primary inteface.  Needs nice documentation, please ;)

Sure thing, all exported function now come with kernel-doc comments.

[...]
> > +	 */
> > +	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
> 
> I'm surprised at __GFP_HIGHMEM's inclusion.  On some machines the great
> majority of user memory is in highmem.  What's up?

In the new revision I included this comment:

        /*
         * Here we only want to account pressure that userland is able to
         * help us with. For example, suppose that DMA zone is under
         * pressure; if we notify userland about that kind of pressure,
         * then it will be mostly a waste as it will trigger unnecessary
         * freeing of memory by userland (since userland is more likely to
         * have HIGHMEM/MOVABLE pages instead of the DMA fallback). That
         * is why we include only movable, highmem and FS/IO pages.
         * Indirect reclaim (kswapd) sets sc->gfp_mask to GFP_KERNEL, so
         * we account it too.
         */
        if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
                return;

> > +	if (!scanned)
> > +		return;
> > +
> > +	mutex_lock(&vmpr->sr_lock);
> > +	vmpr->scanned += scanned;
> > +	vmpr->reclaimed += reclaimed;
> 
> See, here we're accumulating into a 32-bit variable quantities which used
> to be held in 64-bit variables.    The overflow risk gets higher...

I see. I fixed this.

> > +	mutex_unlock(&vmpr->sr_lock);
> > +
> > +	if (scanned < vmpressure_win || work_pending(&vmpr->work))
> > +		return;
> > +	schedule_work(&vmpr->work);
> > +}
> > +
> > +void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
> 
> Documentation please.

Yup, done.

> > +{
> > +	if (prio > vmpressure_level_critical_prio)
> > +		return;
> > +
> > +	/*
> > +	 * OK, the prio is below the threshold, updating vmpressure
> 
> But you never told me what that threshold is for!  And I have no means
> of working out why you chose "3", nor the effects of altering it, etc.

True. This is explained it in a comment now.

[...]
> > +int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
> > +			      struct eventfd_ctx *eventfd, const char *args)
> 
> Document the interface, please.

Done.

> > +{
> > +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> > +	struct vmpressure_event *ev;
> > +	int lvl;
> 
> These abbreviations are rather unlinuxy.  wk->work, vmpr->vmpressure,
> lvl->level, etc.

Yeah, I agree. Although, 'vmpressure' as a function-scope variable is
kinda too long, the code becomes really hard to read. But in memcg struct
and global namespace I now use the full 'vmpressure' name.

> > +	for (lvl = 0; lvl < VMPRESSURE_NUM_LEVELS; lvl++) {
> > +		if (!strcmp(vmpressure_str_levels[lvl], args))
> > +			break;
> > +	}
> > +
> > +	if (lvl >= VMPRESSURE_NUM_LEVELS)
> > +		return -EINVAL;
> > +
> > +	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
> > +	if (!ev)
> > +		return -ENOMEM;
> > +
> > +	ev->efd = eventfd;
> > +	ev->level = lvl;
> > +
> > +	mutex_lock(&vmpr->events_lock);
> > +	list_add(&ev->node, &vmpr->events);
> 
> What's the upper bound on the length of this list?

As of now, it is controlled by the cgroup core, so I would say the number
of opened FDs, and if that is a problem, it should be fixed for everyone.
The good thing is that the list is per-cgroup, it is not global.


Thanks for the review, Andrew!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
