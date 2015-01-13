Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 456466B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 10:50:48 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so22273604wid.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 07:50:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hb7si42688404wjc.5.2015.01.13.07.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 07:50:47 -0800 (PST)
Date: Tue, 13 Jan 2015 10:50:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150113155040.GC8180@phnom.home.cmpxchg.org>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
 <20150112153716.d54e90c634b70d49e8bb8688@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112153716.d54e90c634b70d49e8bb8688@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 03:37:16PM -0800, Andrew Morton wrote:
> On Thu,  8 Jan 2015 23:15:04 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Introduce the basic control files to account, partition, and limit
> > memory using cgroups in default hierarchy mode.
> > 
> > This interface versioning allows us to address fundamental design
> > issues in the existing memory cgroup interface, further explained
> > below.  The old interface will be maintained indefinitely, but a
> > clearer model and improved workload performance should encourage
> > existing users to switch over to the new one eventually.
> > 
> > The control files are thus:
> > 
> >   - memory.current shows the current consumption of the cgroup and its
> >     descendants, in bytes.
> > 
> >   - memory.low configures the lower end of the cgroup's expected
> >     memory consumption range.  The kernel considers memory below that
> >     boundary to be a reserve - the minimum that the workload needs in
> >     order to make forward progress - and generally avoids reclaiming
> >     it, unless there is an imminent risk of entering an OOM situation.
> 
> The code appears to be ascribing a special meaning to low==0: you can
> write "none" to set this.  But I'm not seeing any description of this?

Ah, yes.

The memory.limit_in_bytes and memory.soft_limit_in_bytes currently
show 18446744073709551615 per default, which is a silly way of saying
"this limit is inactive".  And echoing -1 into the control file is an
even sillier way of setting this state.  So the new interface just
calls this state "none".  Internally, 0 and Very High Number represent
this unconfigured state for memory.low and memory.high, respectively.

I added a bullet point at the end of the changelog below.

> >   - memory.high configures the upper end of the cgroup's expected
> >     memory consumption range.  A cgroup whose consumption grows beyond
> >     this threshold is forced into direct reclaim, to work off the
> >     excess and to throttle new allocations heavily, but is generally
> >     allowed to continue and the OOM killer is not invoked.
> > 
> >   - memory.max configures the hard maximum amount of memory that the
> >     cgroup is allowed to consume before the OOM killer is invoked.
> > 
> >   - memory.events shows event counters that indicate how often the
> >     cgroup was reclaimed while below memory.low, how often it was
> >     forced to reclaim excess beyond memory.high, how often it hit
> >     memory.max, and how often it entered OOM due to memory.max.  This
> >     allows users to identify configuration problems when observing a
> >     degradation in workload performance.  An overcommitted system will
> >     have an increased rate of low boundary breaches, whereas increased
> >     rates of high limit breaches, maximum hits, or even OOM situations
> >     will indicate internally overcommitted cgroups.
> > 
> > For existing users of memory cgroups, the following deviations from
> > the current interface are worth pointing out and explaining:
> > 
> >   - The original lower boundary, the soft limit, is defined as a limit
> >     that is per default unset.  As a result, the set of cgroups that
> >     global reclaim prefers is opt-in, rather than opt-out.  The costs
> >     for optimizing these mostly negative lookups are so high that the
> >     implementation, despite its enormous size, does not even provide
> >     the basic desirable behavior.  First off, the soft limit has no
> >     hierarchical meaning.  All configured groups are organized in a
> >     global rbtree and treated like equal peers, regardless where they
> >     are located in the hierarchy.  This makes subtree delegation
> >     impossible.  Second, the soft limit reclaim pass is so aggressive
> >     that it not just introduces high allocation latencies into the
> >     system, but also impacts system performance due to overreclaim, to
> >     the point where the feature becomes self-defeating.
> > 
> >     The memory.low boundary on the other hand is a top-down allocated
> >     reserve.  A cgroup enjoys reclaim protection when it and all its
> >     ancestors are below their low boundaries, which makes delegation
> >     of subtrees possible.  Secondly, new cgroups have no reserve per
> >     default and in the common case most cgroups are eligible for the
> >     preferred reclaim pass.  This allows the new low boundary to be
> >     efficiently implemented with just a minor addition to the generic
> >     reclaim code, without the need for out-of-band data structures and
> >     reclaim passes.  Because the generic reclaim code considers all
> >     cgroups except for the ones running low in the preferred first
> >     reclaim pass, overreclaim of individual groups is eliminated as
> >     well, resulting in much better overall workload performance.
> > 
> >   - The original high boundary, the hard limit, is defined as a strict
> >     limit that can not budge, even if the OOM killer has to be called.
> >     But this generally goes against the goal of making the most out of
> >     the available memory.  The memory consumption of workloads varies
> >     during runtime, and that requires users to overcommit.  But doing
> >     that with a strict upper limit requires either a fairly accurate
> >     prediction of the working set size or adding slack to the limit.
> >     Since working set size estimation is hard and error prone, and
> >     getting it wrong results in OOM kills, most users tend to err on
> >     the side of a looser limit and end up wasting precious resources.
> > 
> >     The memory.high boundary on the other hand can be set much more
> >     conservatively.  When hit, it throttles allocations by forcing
> >     them into direct reclaim to work off the excess, but it never
> >     invokes the OOM killer.  As a result, a high boundary that is
> >     chosen too aggressively will not terminate the processes, but
> >     instead it will lead to gradual performance degradation.  The user
> >     can monitor this and make corrections until the minimal memory
> >     footprint that still gives acceptable performance is found.
> > 
> >     In extreme cases, with many concurrent allocations and a complete
> >     breakdown of reclaim progress within the group, the high boundary
> >     can be exceeded.  But even then it's mostly better to satisfy the
> >     allocation from the slack available in other groups or the rest of
> >     the system than killing the group.  Otherwise, memory.max is there
> >     to limit this type of spillover and ultimately contain buggy or
> >     even malicious applications.
> > 
> >   - The existing control file names are unwieldy and inconsistent in
> >     many different ways.  For example, the upper boundary hit count is
> >     exported in the memory.failcnt file, but an OOM event count has to
> >     be manually counted by listening to memory.oom_control events, and
> >     lower boundary / soft limit events have to be counted by first
> >     setting a threshold for that value and then counting those events.
> >     Also, usage and limit files encode their units in the filename.
> >     That makes the filenames very long, even though this is not
> >     information that a user needs to be reminded of every time they
> >     type out those names.
> > 
> >     To address these naming issues, as well as to signal clearly that
> >     the new interface carries a new configuration model, the naming
> >     conventions in it necessarily differ from the old interface.

  - The existing limit files indicate the state of an unset limit with
    a very high number, and a configured limit can be unset by echoing
    -1 into those files.  But that very high number is implementation
    and architecture dependent and not very descriptive.  And while -1
    can be understood as an underflow into the highest possible value,
    -2 or -10M etc. do not work, so it's quite inconsistent.

    memory.low and memory.high will indicate "none" if the boundary is
    not configured, and a configured boundary can be unset by writing
    "none" into these files as well.

Does that sound good?

> This all sounds pretty major.  How much trouble is this change likely to
> cause existing memcg users?

That is actually entirely up to the user in question.

1. The old cgroup interface remains in place as long as there are
users, so, technically, nothing has to change unless they want to.

2. While default settings and behavior of memory.low slightly differ
from memory.soft_limit_in_bytes, the new interface is compatible with
most existing usecases.  Anybody who currently only hard limits can
set memory.max to the same value as memory.limit_in_bytes and be done.
A configuration that uses soft limits should be easy to translate to
memory.low, AFAIK it's already only used for the reserve semantics.

3. That being said, even though they are not forced to, of course we
want users to rethink their approach to machine partitioning because
that is likely going to improve their workload performance and their
memory utilization.  If they go down this route, they have to figure
out the workloads' minimal amount of memory to run acceptably and set
memory.low.  Then they need to figure out the amount of slack they
want to afford each workload during idle times - this trades the
available cache window in the group against startup/allocation latency
in other groups - and set the memory.high accordingly.  The job
launcher/admin can then parcel off the system's memory by considering
some value between the low and high boundary as the average target
size of each group, depending on the desired level of overcommit.

> > include/linux/memcontrol.h |  32 ++++++
> > mm/memcontrol.c            | 247 +++++++++++++++++++++++++++++++++++++++++++--
> > mm/vmscan.c                |  22 +++-
> 
> No Documentation/cgroups/memory.txt?

That file has a bit of an identity crisis, where interface description
is entangled with irrelevant (and out-of-date) implementation details.

It would be a lot better to have a single cgroup interface document
that covers the generic interface and all available controllers with
consistent language and level of detail.  Better for users, probably
also better for developers to cross check if new interfaces integrate
nicely into the existing model.  I'll kick something off.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
