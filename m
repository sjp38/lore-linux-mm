Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f175.google.com (mail-gg0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id C9B9A6B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 23:50:41 -0500 (EST)
Received: by mail-gg0-f175.google.com with SMTP id c2so62486ggn.34
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 20:50:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ge8si3920573qab.146.2014.01.08.20.50.39
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 20:50:40 -0800 (PST)
Date: Wed, 8 Jan 2014 23:50:37 -0500
From: Johannes Weiner <jweiner@redhat.com>
Subject: [LSF/MM ATTEND] File caching & memory cgroups
Message-ID: <20140109045037.GB884@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,

I would like to attend LSF/MM to discuss memory management topics,
specifically the following issues:

Cache allocation on NUMA
------------------------

The default allocation policy on NUMA is to always try the local node
first, then fall back to remote nodes.  When all nodes are at their
low watermark, the kswapd of each node is woken up and the allocator
retries.

Here is the problem: as soon as kswapd starts freeing local memory,
subsequent local allocation attempts will succeed again.  But at the
same time, they'll prevent the local kswapd from restoring the high
watermark and going back to sleep.  If the paces of reclaim and
allocations match up, kswapd will keep the local node allocatable and
the stream of allocations will keep kswapd awake.

If the workingset is bigger than the local node, we end up thrashing
it while there is free remote memory readily available.  Obviously,
the IO cost is higher than the cost of remote references for most
secondary storage.

For anonymous memory this phenomenon is not as severe because people
try to match anon size to node size and avoid anon reclaim (swapping)
as much as possible.

But cache often exceeds the local node size and clean cache is quickly
reclaimable, which makes the scenario for cache very likely and
observable in practice.

How do we get this right?

One idea would be to have kswapd bail after it reclaimed high-low
watermark number of pages.  However, the above described behavior
might not be entirely undesirable, for example when kswapd reclaims
cache to allow anonymous memory to be placed locally, comparable to
zone_reclaim_mode=1 but without all the direct reclaim latency.  It
would also reduce kswapd's effectiveness at reducing latency when it
IS legitimate to keep running, i.e. when all nodes ARE in equal use.

Another idea would be to change the default allocation policy such
that cache allocations default to a round-robin policy.  This is a
drawback for workloads whose workingset including cache does not
exceed the local node, but those we could offer a mempolicy, while
providing a sensible default.

The question here would be how we approach this problem, whether the
solution involves user interface changes, and what the default
behavior should be.

File LRU balancing
------------------

The Linux VM has two LRU lists for file pages: the "inactive" list for
recently faulted pages, and the "active" list to which pages get
promoted when they are accessed multiple times.  Linux also reclaims
lazily, which means that there is usually no free memory left and the
inactive and active list share all available memory.  As the active
list grows, it reduces the available space for the inactive list.

A smaller inactive list means faster eviction for the pages on it, and
so a page that might have been activated with a small active list
might be evicted before its second access when the active list is
bigger.  This in turn means that, as a workingset establishes itself
on the active list, the current VM turns blind to workingset changes.

The result is a complete breakdown of the VM's caching abilities when
a workingset change exceeds the inactive list size (fixed minimum of
50% of memory at this time, which has other downsides as well).

I have sent patches that set out to fix this problem.  They accomplish
this by remembering eviction information as inactive pages get
reclaimed, and then use this information to reconstruct the access
distance when the page refaults.  If the distance is within the
theoretical maximum size of the inactive list (inactive + active), the
page gets activated directly.  This makes the multi-access detection
immune to the physical inactive/active size balance.

People seemed interested in this at last year's LSF/MM, but the actual
patch submissions have seen very little response from MM people on the
lists, so I'd like to bring this up again.

Zeroconf memcgs
---------------

Memory cgroups, outside of the pay-per-container usecase, are awkward
to configure because it needs precise knowledge of the workload.  Task
grouping is one thing, but finding a static upper memory limit for any
given application is tough: it's not trivial to estimate a workingset
size, and it varies during execution.  How much memory do I grant an
rsync backup?  A build job?

The idea with zeroconf memcgs would be a respin of "local" reclaim
policies on a per-memcg basis.  No upper memory limit is defined and a
memcg consumes whatever physical memory is readily available.  But as
soon as memory is exhausted and the task has to initiate reclaim, it
would not reclaim GLOBALLY from all memcgs in the system, as is the
case right now.  Instead, it would try to reclaim its own clean cache
first, and fall back if there is no clean cache or if that cache is
thrashing.  It's conceivable to use the refault information as
described in "File LRU balancing" to detect such thrashing.  It would
also fall back when the readahead window is being thrashed,
i.e. !PageReferenced pages are reclaimed.

On a populated system, an rsync backup workload would stay relatively
contained by recycling its own used-once cache before stealing memory
from other workloads, but WOULD use global reclaim in order to expand
to the size of its readahead window.

Such "local page replacement" policies on a per-task level have had
limited success in the past.  "Task" often does not correspond to
"workload" and so this could easily end up doing the wrong thing.
Memory cgroups on the other hand ARE tasks grouped by workload.  In
addition, we now have means to restrict a reclaim scan to file cache,
thanks to the split LRU lists.  We also have means to detect cache
thrashing thanks to the refault information.

With this new infrastructure in place, would it be a good idea to give
local reclaim another shot as a memcg feature?  Even consider the
memory equivalent of CONFIG_SCHED_AUTOGROUP?

Memcg upper & lower limit
-------------------------

Another idea to make memory cgroups more approachable by casual users
would be to rethink the default behavior of the upper limit, currently
"hardlimit".  This idea came from Tejun.

Currently, when the hardlimit is reached and reclaim can not make
progress, a per-memcg OOM killer is invoked.  For most usecases, again
outside of pay-per-container situations, this seems quite harsh.  It's
likely that most people would rather set the limit a little lower than
higher, have reclaim try to enforce it, but ultimately let the
allocation pass.  A best effort measure.

The OOM killer was written for situations of hopeless overcommit where
the kernel simply has no other choice.  Obviously this behavior should
still be available for cases where the applications are untrusted, but
maybe the default should be less extreme.

As to the lower limit, Michal already proposed this for discussion.
This is about guaranteeing groups a minimum amount of memory.  Here I
would think we want behavior that is symmetrical to the upper limit,
whatever we end up deciding on.  But it's also likely that the default
should be a soft failure mode of bypassing the limit instead of a hard
failure mode that invokes the OOM killer or even panics the system.

In the light of the cgroup interface being revamped entirely, it might
make sense to discuss a new interface for the memory limits as well
and treat the lower and the upper limit as two halves of the same
thing, unlike the current semantical nightmare of soft and hard limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
