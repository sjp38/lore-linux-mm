Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 382C26B00B5
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 11:58:37 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so1151832wgg.0
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 08:58:36 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fu18si24471218wjc.113.2014.07.16.08.58.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 08:58:27 -0700 (PDT)
Date: Wed, 16 Jul 2014 11:58:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140716155814.GZ29639@cmpxchg.org>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
> Starting with 8f9ac36d2cbb (cgroup: distinguish the default and legacy
> hierarchies when handling cftypes) memory cgroup controller doesn't
> export any knobs because all of them are marked as legacy. The idea is
> that only selected knobs are exported for the new cgroup API.
> 
> This patch exports the core knobs for the memory controller. The
> following knobs are not and won't be available in the default (aka
> unified) hierarchy:
> - use_hierarchy - was one of the biggest mistakes when memory controller
>   was introduced. It allows for creating hierarchical cgroups structure
>   which doesn't have any hierarchical accounting. This leads to really
>   strange configurations where other co-mounted controllers behave
>   hierarchically while memory controller doesn't.
>   All controllers have to be hierarchical with the new cgroups API so
>   this knob doesn't make any sense here.
> - force_empty - has been introduced primarily to drop memory before it
>   gets reparented on the group removal.  This alone doesn't sound
>   fully justified because reparented pages which are not in use can be
>   reclaimed also later when there is a memory pressure on the parent
>   level.
>   Another use-case would be something like per-memcg /proc/sys/vm/drop_caches
>   which doesn't sound like a great idea either. We are trying to get
>   away from using it on the global level so we shouldn't allow that on
>   per-memcg level as well.
> - soft_limit_in_bytes - has been originally introduced to help to
>   recover from the overcommit situations where the overall hard limits
>   on the system are higher than the available memory. A group which has
>   the largest excess on the soft limit is reclaimed to help to reduce
>   memory pressure during the global memory pressure.
>   The primary problem with this tunable is that every memcg is soft
>   unlimited by default which is reverse to what would be expected from
>   such a knob.
>   Another problem is that soft limit is considered only during the
>   global memory pressure rather than on an external memory pressure in
>   general (e.g. triggered by the limit hit on a parent up the
>   hierarchy).
>   There are other issues which are tight to the implementation (e.g.
>   priority-0 reclaim used for the soft limit reclaim etc.) which are
>   really hard to fix without breaking potential users.
>   There will be a replacement for the soft limit in the unified
>   hierarchy and users will be encouraged to switch their configuration
>   to the new scheme. Until this is available users are suggested to stay
>   with the legacy cgroup API.
> 
> TCP kmem sub-controller is not exported at this stage because this one has
> seen basically no traction since it was merged and it is not entirely
> clear why kmem controller cannot be used for the same purpose. Having 2
> controllers for tracking kernel memory allocations sounds like too much.
> If there are use-cases and reasons for not merging it into kmem then we
> can reconsider and allow it for the new cgroups API later.

There is a reason why we start out empty on the default hierarchy: the
old interface is a complete cesspool.  We're not blindly carrying over
any of it.

Everything that is added in .dfl_ctypes is a new interface and it
needs to be treated as such: it needs a valid usecase to back it up,
and it needs to be evaluated whether the exported information or
control knob is a good way to support that usecase.

> @@ -5226,7 +5226,11 @@ out_kfree:
>  	return ret;
>  }
>  
> -static struct cftype mem_cgroup_files[] = {
> +/*
> + * memcg knobs for the legacy cgroup API. No new files should be
> + * added here.
> + */
> +static struct cftype legacy_mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> @@ -5334,6 +5338,100 @@ static struct cftype mem_cgroup_files[] = {
>  	{ },	/* terminate */
>  };
>  
> +/* memcg knobs for new cgroups API (default aka unified hierarchy) */
> +static struct cftype dfl_mem_cgroup_files[] = {
> +	{
> +		.name = "usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> +		.read_u64 = mem_cgroup_read_u64,
> +	},

The _in_bytes suffix is pointless, we just need to document that
everything in memcg is in bytes, unless noted otherwise.

How about "memory.current"?

> +	{
> +		.name = "max_usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,

What is this actually good for?  We have lazy cache shrinking, which
means that the high watermark of most workloads depends on the group
max limit.

> +	},
> +	{
> +		.name = "limit_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
> +		.write = mem_cgroup_write,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},

We already agreed that there will be a max, a high, a min, and a low
limit, why would you want to reintroduce the max limit as "limit"?

How about "memory.max"?

memory.min
memory.low
memory.high
memory.max
memory.current

> +	{
> +		.name = "failcnt",
> +		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},

This indicates the number of times the function res_counter_charge()
was called and didn't succeed.

Let that sink in.

This is way too dependent on the current implementation.  If you want
a measure of how much pressure the group is under, look at vmpressure,
or add scanned/reclaimed reclaim statistics.  NAK.

> +	{
> +		.name = "stat",
> +		.seq_show = memcg_stat_show,
> +	},

This file is a complete mess.

pgpgin/pgpgout originally refers to IO, here it means pages charged
and uncharged.  It's questionable whether we even need counters for
charges and uncharges.

mapped_file vs. NR_FILE_MAPPED is another eyesore.

We should generally try harder to be consistent with /proc/vmstat.
And rename it to "memory.vmstat" while we are at it.

Also, having local counters no longer makes sense as there won't be
tasks in intermediate nodes anymore and we are getting rid of
reparenting.  All counters should appear once, in their hierarchical
form.  The exception is the root_mem_cgroup, which should probably
have a separate file for the local counters.

> +	{
> +		.name = "cgroup.event_control",		/* XXX: for compat */
> +		.write = memcg_write_event_control,
> +		.flags = CFTYPE_NO_PREFIX,
> +		.mode = S_IWUGO,

Why?

> +	},
> +	{
> +		.name = "swappiness",
> +		.read_u64 = mem_cgroup_swappiness_read,
> +		.write_u64 = mem_cgroup_swappiness_write,

Do we actually need this?

> +	},
> +	{
> +		.name = "move_charge_at_immigrate",
> +		.read_u64 = mem_cgroup_move_charge_read,
> +		.write_u64 = mem_cgroup_move_charge_write,

This creates significant pain because pc->mem_cgroup becomes a moving
target during the lifetime of the page.  When this feature was added,
there was no justification - except that "some users feel [charges
staying in the group] to be strange" - and it was lacking the
necessary synchronization to make this work properly, so the cost of
this feature was anything but obvious during the initial submission.

I generally don't see why tasks should be moving between groups aside
from the initial setup phase.  And then they shouldn't have consumed
any amounts of memory that they couldn't afford to leave behind in the
root/parent.

So what is the usecase for this that would justify the immense cost in
terms of both performance and code complexity?

> +	},
> +	{
> +		.name = "oom_control",
> +		.seq_show = mem_cgroup_oom_control_read,
> +		.write_u64 = mem_cgroup_oom_control_write,
> +		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),

This needs a usecase description as well.

> +	},
> +	{
> +		.name = "pressure_level",

"memory.pressure"?

> +	},
> +#ifdef CONFIG_NUMA
> +	{
> +		.name = "numa_stat",
> +		.seq_show = memcg_numa_stat_show,
> +	},

This would also be a chance to clean up this file, which is suddenly
specifying memory size in pages rather than bytes.

> +#ifdef CONFIG_MEMCG_KMEM
> +	{
> +		.name = "kmem.limit_in_bytes",
> +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> +		.write = mem_cgroup_write,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},

Does it really make sense to have a separate limit for kmem only?
IIRC, the reason we introduced this was that this memory is not
reclaimable and so we need to limit it.

But the opposite effect happened: because it's not reclaimable, the
separate kmem limit is actually unusable for any values smaller than
the overall memory limit: because there is no reclaim mechanism for
that limit, once you hit it, it's over, there is nothing you can do
anymore.  The problem isn't so much unreclaimable memory, the problem
is unreclaimable limits.

If the global case produces memory pressure through kernel memory
allocations, we reclaim page cache, anonymous pages, inodes, dentries
etc.  I think the same should happen for kmem: kmem should just be
accounted and limited in the overall memory limit of a group, and when
pressure arises, we go after anything that's reclaimable.

> +	{
> +		.name = "kmem.max_usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_KMEM, RES_MAX_USAGE),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,

As per above, I don't see that a high watermark is meaningful with
lazy cache shrinking.

> +	{
> +		.name = "kmem.usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
> +		.read_u64 = mem_cgroup_read_u64,
> +	},

We could just include slab counters, kernel stack pages etc. in the
statistics file, like /proc/vmstat does.

> +	{
> +		.name = "kmem.failcnt",
> +		.private = MEMFILE_PRIVATE(_KMEM, RES_FAILCNT),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,

NAK as per above.

> +#ifdef CONFIG_SLABINFO
> +	{
> +		.name = "kmem.slabinfo",
> +		.seq_show = mem_cgroup_slabinfo_read,
> +	},
> +#endif
> +#endif
> +	{ },	/* terminate */
> +};
> +
>  #ifdef CONFIG_MEMCG_SWAP
>  static struct cftype memsw_cgroup_files[] = {
>  	{
> @@ -6266,7 +6364,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
>  	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
>  	.bind = mem_cgroup_bind,
> -	.legacy_cftypes = mem_cgroup_files,
> +	.legacy_cftypes = legacy_mem_cgroup_files,
> +	.dfl_cftypes = dfl_mem_cgroup_files,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
