Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id C8F4A6B0037
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:45:15 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id z11so1748638lbi.31
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:45:14 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id v6si3306936lav.10.2014.07.17.06.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 06:45:12 -0700 (PDT)
Received: by mail-lb0-f172.google.com with SMTP id z11so1748569lbi.31
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:45:12 -0700 (PDT)
Date: Thu, 17 Jul 2014 15:45:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140717134509.GB8011@dhcp22.suse.cz>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716155814.GZ29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed 16-07-14 11:58:14, Johannes Weiner wrote:
> On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
[...]
> > +/* memcg knobs for new cgroups API (default aka unified hierarchy) */
> > +static struct cftype dfl_mem_cgroup_files[] = {
> > +	{
> > +		.name = "usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> The _in_bytes suffix is pointless, we just need to document that
> everything in memcg is in bytes, unless noted otherwise.
> 
> How about "memory.current"?

I wanted old users to change the minimum possible when moving to unified
hierarchy so I didn't touch the old names.
Why should we make the end users life harder? If there is general
agreement I have no problem with renaming I just do not think it is
really necessary because there is no real reason why configurations
which do not use any of the deprecated or unified-hierarchy-only
features shouldn't run in both unified and legacy hierarchies without
any changes.

I do realize that this is a _new_ API so we can do such radical changes
but I am also aware that some people have to maintain their stacks on
top of different kernels and it really sucks to maintain two different
configurations. In such a case it would be easier for those users to
stay with the legacy mode which is a fair option but I would much rather
see them move to the new API sooner rather than later.

memory.usage would be much better fit IMO.

> > +	{
> > +		.name = "max_usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
> > +		.write = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read_u64,
> 
> What is this actually good for?  We have lazy cache shrinking, which
> means that the high watermark of most workloads depends on the group
> max limit.

Well that is a good questions. I was going back and forth disabling this
and failcnt before posting this RFC and ended up adding them as they
never were controversial.
I have no problem ditching them, though, because the usefulness is quite
dubious. If someone wants to see whether the hard limit can be decreased
without putting too much reclaim pressure then we have a notification
mechanism for it.

> > +	},
> > +	{
> > +		.name = "limit_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
> > +		.write = mem_cgroup_write,
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> We already agreed that there will be a max, a high, a min, and a low
> limit, why would you want to reintroduce the max limit as "limit"?

Same as above. I didn't rename knobs for easier transition. On the
other hand it is true that the name doesn't fit so nicely with the new
upcoming limits scheme. Is this reason sufficient to make users lives
harder?

> How about "memory.max"?
> 
> memory.min
> memory.low
> memory.high
> memory.max
> memory.current
> 
> > +	{
> > +		.name = "failcnt",
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
> > +		.write = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> This indicates the number of times the function res_counter_charge()
> was called and didn't succeed.
> 
> Let that sink in.
> 
> This is way too dependent on the current implementation. 

Well not really. It doesn't depend on the res_counter directly. We just
happen to use it this way. Whatever we will use in future there will
still be a moment when the hard (or whatever we call it) limit is hit.
Whether somebody depends on it is a question. I wouldn't be surprised if
somebody does but I also think that making any decisions based on the
counter are dubious at best. But hey, users are really creative...

> If you want a measure of how much pressure the group is under, look at
> vmpressure, or add scanned/reclaimed reclaim statistics.  NAK.

OK, I will not miss this one either. As you say there is a better way to
measure the pressure and make decisions based on that.

> > +	{
> > +		.name = "stat",
> > +		.seq_show = memcg_stat_show,
> > +	},
> 
> This file is a complete mess.

It is!

> pgpgin/pgpgout originally refers to IO, here it means pages charged
> and uncharged.  It's questionable whether we even need counters for
> charges and uncharges.
> 
> mapped_file vs. NR_FILE_MAPPED is another eyesore.
> 
> We should generally try harder to be consistent with /proc/vmstat.
> And rename it to "memory.vmstat" while we are at it.

I definitely agree that we should converge to vmstat-like counters. We
should also fix the counters which do not make much sense. I just do not
want to end up with two sets of stats depending on whether we are in
default or legacy hierarchy.

> Also, having local counters no longer makes sense as there won't be
> tasks in intermediate nodes anymore and we are getting rid of
> reparenting. 

I am not sure we should get rid of reparenting. It makes sense to have
pages from the gone memcgs in the parent so they are the first candidate
to reclaim.

> All counters should appear once, in their hierarchical form.

Each memcg has its local state (e.g. LRUs) so we should reflect that in
the stat file IMO. Or are there any plans to use different mem_cgroup
structure for the intermediate nodes? I haven't heard anything like
that.

> The exception is the root_mem_cgroup, which should probably
> have a separate file for the local counters.
> 
> > +	{
> > +		.name = "cgroup.event_control",		/* XXX: for compat */
> > +		.write = memcg_write_event_control,
> > +		.flags = CFTYPE_NO_PREFIX,
> > +		.mode = S_IWUGO,
> 
> Why?

For the oom, thresholds and vmpressure notifications, obviously. Or do
we have any other means to do the same? Does it really make sense to
push all the current users to use something else?

I understand that cgroup core didn't want to support such a generic
tool. But I think it serves its purpose for memcg and it works
reasonably well.

I am surely open to discuss alternatives.

> > +	},
> > +	{
> > +		.name = "swappiness",
> > +		.read_u64 = mem_cgroup_swappiness_read,
> > +		.write_u64 = mem_cgroup_swappiness_write,
> 
> Do we actually need this?

Swappiness is a natural property of LRU (anon/file) scanning and LRUs
belong to memcg so they should have a way to tell their preference.
Consider container setups for example. There will never be
one-swappiness-suits-all of them.
 
> > +	},
> > +	{
> > +		.name = "move_charge_at_immigrate",
> > +		.read_u64 = mem_cgroup_move_charge_read,
> > +		.write_u64 = mem_cgroup_move_charge_write,
> 
> This creates significant pain because pc->mem_cgroup becomes a moving
> target during the lifetime of the page.  When this feature was added,
> there was no justification - except that "some users feel [charges
> staying in the group] to be strange" - and it was lacking the
> necessary synchronization to make this work properly, so the cost of
> this feature was anything but obvious during the initial submission.

Actually I think that move charge with tasks should be enabled by
default. If the task moving between groups should be supported (and I
think it should be) then leaving the charges and pages behind is more
than strange. Why does the task move in the first place? Just to get rid
of the responsibility for its previous memory consumption?

So I am OK with the knob removing but I think we should move charge by
default in the unified hierarchy.

> I generally don't see why tasks should be moving between groups aside
> from the initial setup phase.  And then they shouldn't have consumed
> any amounts of memory that they couldn't afford to leave behind in the
> root/parent.
> 
> So what is the usecase for this that would justify the immense cost in
> terms of both performance and code complexity?

One of them would be cooperation with other controllers where moving
task has its own meaning (e.g. to a cpu group with a different share or a
cpuset with a slightly different cpu/node set etc...). Memory controller
shouldn't disallow task moving.

Another one would be memory "load" balancing. Say you have 2 (high and low
priority) sets of tasks running on your system/container. High priority
tasks shouldn't be reclaimed much because that would increase their
latencies or whatever. Low prio tasks can get reclaimed or even OOM
killed. Load balancer, admin, user putting task to/from the background
or any other mechanism can decide to change the "priority" of the task
simply by moving it to the appropriate memcg.

> 
> > +	},
> > +	{
> > +		.name = "oom_control",
> > +		.seq_show = mem_cgroup_oom_control_read,
> > +		.write_u64 = mem_cgroup_oom_control_write,
> > +		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> 
> This needs a usecase description as well.

There are more of them I think. Btw. I have seen users who started using
memory cgroups just because they were able to control OOM from userspace.

The strongest use case is to handle OOM conditions gracefully. This
includes 1) allow proper shutdown of the service 2) allow killing OOM
victim's related processes which do not make any sense on their own
3) make a more workload aware victim selection.

I am fully aware that there has been a lot of abuse in the past and
users pushing the feature to its limits but that doesn't qualify to
removing otherwise very useful feature.

> 
> > +	},
> > +	{
> > +		.name = "pressure_level",
> 
> "memory.pressure"?
> 
> > +	},
> > +#ifdef CONFIG_NUMA
> > +	{
> > +		.name = "numa_stat",
> > +		.seq_show = memcg_numa_stat_show,
> > +	},
> 
> This would also be a chance to clean up this file, which is suddenly
> specifying memory size in pages rather than bytes.

OK, we should merge it with stat file.

> > +#ifdef CONFIG_MEMCG_KMEM
> > +	{
> > +		.name = "kmem.limit_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > +		.write = mem_cgroup_write,
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> Does it really make sense to have a separate limit for kmem only?
> IIRC, the reason we introduced this was that this memory is not
> reclaimable and so we need to limit it.

My recollection is different. Basically there are users who really do
not care about kmem accounting and do not want to pay runtime overhead.
Documentation/cgroups/memory.txt then describes different usecases in
chapter 2.7.3. I am not user of kmem myself and considering the current
state of the extension I have never encourage anybody to use it for
anything but playing so I cannot tell you which of the scenario is used
most widespread.
I do not have any objections to leave the kmem extension in the legacy
mode for now and add it later when it matures. In fact my original
patch did that but then I've decided to keep it because the current
limitations seem to be more implementation than semantic specific. And
Vladimir is doing a really great job to fill the gaps.

> But the opposite effect happened: because it's not reclaimable, the
> separate kmem limit is actually unusable for any values smaller than
> the overall memory limit: because there is no reclaim mechanism for
> that limit, once you hit it, it's over, there is nothing you can do
> anymore.  The problem isn't so much unreclaimable memory, the problem
> is unreclaimable limits.

This is the limitation of the current implementation.

> If the global case produces memory pressure through kernel memory
> allocations, we reclaim page cache, anonymous pages, inodes, dentries
> etc.  I think the same should happen for kmem: kmem should just be
> accounted and limited in the overall memory limit of a group, and when
> pressure arises, we go after anything that's reclaimable.
> 
> > +	{
> > +		.name = "kmem.max_usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_MAX_USAGE),
> > +		.write = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read_u64,
> 
> As per above, I don't see that a high watermark is meaningful with
> lazy cache shrinking.

Sure, if other max_usage_in_bytes goes away this one will go as well.

> > +	{
> > +		.name = "kmem.usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> We could just include slab counters, kernel stack pages etc. in the
> statistics file, like /proc/vmstat does.

Agreed.
 
> > +	{
> > +		.name = "kmem.failcnt",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_FAILCNT),
> > +		.write = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read_u64,
> 
> NAK as per above.
> 
> > +#ifdef CONFIG_SLABINFO
> > +	{
> > +		.name = "kmem.slabinfo",
> > +		.seq_show = mem_cgroup_slabinfo_read,
> > +	},
> > +#endif
> > +#endif
> > +	{ },	/* terminate */
> > +};
> > +
> >  #ifdef CONFIG_MEMCG_SWAP
> >  static struct cftype memsw_cgroup_files[] = {
> >  	{
> > @@ -6266,7 +6364,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
> >  	.cancel_attach = mem_cgroup_cancel_attach,
> >  	.attach = mem_cgroup_move_task,
> >  	.bind = mem_cgroup_bind,
> > -	.legacy_cftypes = mem_cgroup_files,
> > +	.legacy_cftypes = legacy_mem_cgroup_files,
> > +	.dfl_cftypes = dfl_mem_cgroup_files,

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
