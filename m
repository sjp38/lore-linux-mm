Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id D37D16B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 09:43:44 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id t61so2254242wes.22
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 06:43:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si4290707wik.48.2014.02.03.06.43.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 06:43:42 -0800 (PST)
Date: Mon, 3 Feb 2014 15:43:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
Message-ID: <20140203144341.GI2495@dhcp22.suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
 <xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
 <20140130123044.GB13509@dhcp22.suse.cz>
 <xr931tzphu50.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr931tzphu50.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Thu 30-01-14 16:28:27, Greg Thelen wrote:
> On Thu, Jan 30 2014, Michal Hocko wrote:
> 
> > On Wed 29-01-14 11:08:46, Greg Thelen wrote:
> > [...]
> >> The series looks useful.  We (Google) have been using something similar.
> >> In practice such a low_limit (or memory guarantee), doesn't nest very
> >> well.
> >> 
> >> Example:
> >>   - parent_memcg: limit 500, low_limit 500, usage 500
> >>     1 privately charged non-reclaimable page (e.g. mlock, slab)
> >>   - child_memcg: limit 500, low_limit 500, usage 499
> >
> > I am not sure this is a good example. Your setup basically say that no
> > single page should be reclaimed. I can imagine this might be useful in
> > some cases and I would like to allow it but it sounds too extreme (e.g.
> > a load which would start trashing heavily once the reclaim starts and it
> > makes more sense to start it again rather than crowl - think about some
> > mathematical simulation which might diverge).
> 
> Pages will still be reclaimed the usage_in_bytes is exceeds
> limit_in_bytes.  I see the low_limit as a way to tell the kernel: don't
> reclaim my memory due to external pressure, but internal pressure is
> different.

That sounds strange and very confusing to me. What if the internal
pressure comes from children memcgs? Lowlimit is intended for protecting
a group from reclaim and it shouldn't matter whether the reclaim is a
result of the internal or external pressure.

> >> If a streaming file cache workload (e.g. sha1sum) starts gobbling up
> >> page cache it will lead to an oom kill instead of reclaiming. 
> >
> > Does it make any sense to protect all of such memory although it is
> > easily reclaimable?
> 
> I think protection makes sense in this case.  If I know my workload
> needs 500 to operate well, then I reserve 500 using low_limit.  My app
> doesn't want to run with less than its reservation.
> 
> >> One could argue that this is working as intended because child_memcg
> >> was promised 500 but can only get 499.  So child_memcg is oom killed
> >> rather than being forced to operate below its promised low limit.
> >> 
> >> This has led to various internal workarounds like:
> >> - don't charge any memory to interior tree nodes (e.g. parent_memcg);
> >>   only charge memory to cgroup leafs.  This gets tricky when dealing
> >>   with reparented memory inherited to parent from child during cgroup
> >>   deletion.
> >
> > Do those need any protection at all?
> 
> Interior tree nodes don't need protection from their children.  But
> children and interior nodes need protection from siblings and parents.

Why? They contains only reparented pages in the above case. Those would
be #1 candidate for reclaim in most cases, no?

> >> - don't set low_limit on non leafs (e.g. do not set low limit on
> >>   parent_memcg).  This constrains the cgroup layout a bit.  Some
> >>   customers want to purchase $MEM and setup their workload with a few
> >>   child cgroups.  A system daemon hands out $MEM by setting low_limit
> >>   for top-level containers (e.g. parent_memcg).  Thereafter such
> >>   customers are able to partition their workload with sub memcg below
> >>   child_memcg.  Example:
> >>      parent_memcg
> >>          \
> >>           child_memcg
> >>             /     \
> >>         server   backup
> >
> > I think that the low_limit makes sense where you actually want to
> > protect something from reclaim. And backup sounds like a bad fit for
> > that.
> 
> The backup job would presumably have a small low_limit, but it may still
> have a minimum working set required to make useful forward progress.
> 
> Example:
>   parent_memcg
>       \
>        child_memcg limit 500, low_limit 500, usage 500
>          /     \
>          |   backup   limit 10, low_limit 10, usage 10
>          |
>       server limit 490, low_limit 490, usage 490
> 
> One could argue that problems appear when
> server.low_limit+backup.lower_limit=child_memcg.limit.  So the safer
> configuration is leave some padding:
>   server.low_limit + backup.low_limit + padding = child_memcg.limit
> but this just defers the problem.  As memory is reparented into parent,
> then padding must grow.

Which all sounds like a drawback of internal vs. external pressure
semantic which you have mentioned above.

> >>   Thereafter customers often want some weak isolation between server and
> >>   backup.  To avoid undesired oom kills the server/backup isolation is
> >>   provided with a softer memory guarantee (e.g. soft_limit).  The soft
> >>   limit acts like the low_limit until priority becomes desperate.
> >
> > Johannes was already suggesting that the low_limit should allow for a
> > weaker semantic as well. I am not very much inclined to that but I can
> > leave with a knob which would say oom_on_lowlimit (on by default but
> > allowed to be set to 0). We would fallback to the full reclaim if
> > no groups turn out to be reclaimable.
> 
> I like the strong semantic of your low_limit at least at level:1 cgroups
> (direct children of root).  But I have also encountered situations where
> a strict guarantee is too strict and a mere preference is desirable.
> Perhaps the best plan is to continue with the proposed strict low_limit
> and eventually provide an additional mechanism which provides weaker
> guarantees (e.g. soft_limit or something else if soft_limit cannot be
> altered).  These two would offer good support for a variety of use
> cases.
> 
> I thinking of something like:
> 
> bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> 		struct mem_cgroup *root,
> 		int priority)
> {
> 	do {
> 		if (memcg == root)
> 			break;
> 		if (!res_counter_low_limit_excess(&memcg->res))
> 			return false;
> 		if ((priority >= DEF_PRIORITY - 2) &&
> 		    !res_counter_soft_limit_exceed(&memcg->res))
> 			return false;
> 	} while ((memcg = parent_mem_cgroup(memcg)));
> 	return true;
> }

Mixing soft limit into the picture is more than confusing because it
has its own meaning now and we shouldn't recycle it until it is dead
completely.
Another thing which seems to be more serious is that such a reclaim
logic would inherently lead to a potential over reclaim because 2
priority cycles would be wasted with no progress and when we finally
find somebody then it gets hammered more at lower priority.

What I would like much more is to fallback to ignore low_limit if
nothing is reclaimable due to low_limit. That would be controlled on a
memcg level (something like memory.low_limit_fallback).

> But this soft_limit,priority extension can be added later.

Yes, I would like to have the strong semantic first and then deal with a
weaker form. Either by a new limit or a flag.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
