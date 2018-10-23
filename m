Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF98C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 03:57:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26-v6so522085eda.7
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 00:57:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x45-v6si627991edx.250.2018.10.23.00.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 00:57:49 -0700 (PDT)
Date: Tue, 23 Oct 2018 08:57:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181023075745.GA28684@suse.de>
References: <20181009094825.GC6931@suse.de>
 <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de>
 <20181009142510.GU8528@dhcp22.suse.cz>
 <20181009230352.GE9307@redhat.com>
 <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015154459.e870c30df5c41966ffb4aed8@linux-foundation.org>
 <20181016074606.GH6931@suse.de>
 <alpine.DEB.2.21.1810221355050.120157@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810221355050.120157@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, Oct 22, 2018 at 02:04:32PM -0700, David Rientjes wrote:
> On Tue, 16 Oct 2018, Mel Gorman wrote:
> 
> > I consider this to be an unfortunate outcome. On the one hand, we have a
> > problem that three people can trivially reproduce with known test cases
> > and a patch shown to resolve the problem. Two of those three people work
> > on distributions that are exposed to a large number of users. On the
> > other, we have a problem that requires the system to be in a specific
> > state and an unknown workload that suffers badly from the remote access
> > penalties with a patch that has review concerns and has not been proven
> > to resolve the trivial cases.
> 
> The specific state is that remote memory is fragmented as well, this is 
> not atypical. 

While not necessarily atypical, *how* it gets fragmented is important.
The final state of fragmentation depends on both the input allocation
stream *and* the liveness of the mobility of unmovable pages. This is
why a target workload is crucial. While it's trivial to fragment memory,
it can be in a state that may or may not be trivially compacted.

For example, a fragmenting workload that interleaves slab allocations
with page cache may fragment memory but if the files are not being used
at the time of a THP allocation then they are trivially
reclaimed/compacted. However, if the files are in active use, the system
remains active.

You make the following claim in another response

	The test case is rather trivial: fragment all memory with order-4
	memory to replicate a fragmented local zone, use sched_setaffinity()
	to bind to that node, and fault a reasonable number of hugepages
	(128MB, 256, whatever).

You do not describe why it's order-4 allocations that are fragmenting or why
they remain live. order-4 might imply large jumbo frame allocations but they
typically do not remain live for very long unless you are using a driver
that recycles large numbers of order-4 pages. It's a critical detail. If
your test case is trivial then post it so there is a common base to work
from. A test case has been requested from you multiple times already.

Note that I accept it's trivial to fragment memory in a harmful way.
I've prototyped a test case yesterday that uses fio in the following way
to fragment memory

o fio of many small files (64K)
o create initial pages using writes that disable fallocate and create
  inodes on first open. This is massively inefficient from an IO
  perspective but it mixes slab and page cache allocations so all
  NUMA nodes get fragmented.
o Size the page cache so that it's 150% the size of memory so it forces
  reclaim activity and new fio activity to further mix slab and page
  cache allocations
o After initial write, run parallel readers to keep slab active and run
  this for the same length of time the initial writes took so fio has
  called stat() on the existing files and begun the read phase. This
  forces the slab and page cache pages to remain "live" and difficult
  to reclaim/compact.
o Finally, start a workload that allocates THP after the warmup phase
  but while fio is still runnning to measure allocation success rate
  and latencies

There are three configurations that use default advice, MADV_HUGEPAGE and
"always" fragment that is still running to cover the differet configurations
of interest. However, this is completly useless to you as even if this test
cases are fixed, there is no guarantee at all that it helps yours. They
are still being evaluated as they were recently prototyped but the mmtests
configurations in case someone wishes to independently evaluate are;

config-global-dhp__workload_thpfioscale
config-global-dhp__workload_thpfioscale-defrag
config-global-dhp__workload_thpfioscale-madvhugepage

It's best to run them on a dedicated test partition if possible. Locally
I've configured them to use a freshly created XFS filesystem.

If you're going to block fixes for problems that multiple people
experience then at least do the courtesy of providing a test case or
prototype patches for the complex alternatives you are proposing so they
can be independently evaluated. 

> Removing __GFP_THISNODE to avoid thrashing a zone will only 
> be beneficial when you can allocate remotely instead.  When you cannot 
> allocate remotely instead, you've made the problem much worse for 
> something that should be __GFP_NORETRY in the first place (and was for 
> years) and should never thrash.
> 
> I'm not interested in patches that require remote nodes to have an 
> abundance of free or unfragmented memory to avoid regressing.
> 

If only there was a test case that could reliably demonstrate this
independenly so it can be analysed and fixed *hint hint*. Better yet,
kindly prototype a fix.

> > In the case of distributions, the first
> > patch addresses concerns with a common workload where on the other hand
> > we have an internal workload of a single company that is affected --
> > which indirectly affects many users admittedly but only one entity directly.
> > 
> 
> The alternative, which is my patch, hasn't been tested or shown why it 
> cannot work.  We continue to talk about order >= pageblock_order vs
> __GFP_COMPACTONLY.
> 

You already received negative feedback on it. I worried that it would
conflate the requirements of THP and hugetlbfs with the latter usually
being more willing to tolerate initial latency to get the huge pages.
It's also being pointed out numerous times that the bug being addressed
is for a trivial workload on a clean system and not a case that depends
heavily on the system state. Normally the priority is to fix the trivial
case and work on the complex case.

Furthermore, Andrea has already stated that the complex alternatives will
take too long as they are non-trivial changes and that upstrewam cannot
be shipped (for RHEL presumably) with the existing bug. The bug being
addressed, and has a confirmed patch for, is addressing a severe regression
that "made important workloads unusuable". We are now in a situation where
distributions are likely to carry an out-of-tree patch to cover the trivial
case with a limited path forward as the blocking test case is unuavailable.

All that said, your patches results when tested were inconclusive at
best. For the trivial case, system CPU usage is indeed reduced to similar
levels to Michal's patch. However, the actual time to complete is 15.7%
longer than the vanilla kernel. Michal's patch completed 10.5% faster.

> I'd like to know, specifically:
> 
>  - what measurable affect my patch has that is better solved with removing
>    __GFP_THISNODE on systems where remote memory is also fragmented?
> 

In my case, it failed to fix the trivial case. That may be specific to
my machine or bad luck but nevertheless, it failed. The patch is also at
the RFC level with no test case that can be independently verified.

>  - what platforms benefit from remote access to hugepages vs accessing
>    local small pages (I've asked this maybe 4 or 5 times now)?
> 

That's a loaded question. In the case of a workload that has long
active phases that fit in L3 cache, the remote access penalty is masked.
Furthermore, virtualisation can benefit from THP even if remote due to
the reduced depth of page table walks combined with the fact that vcpus
may migrate to nodes accessing local memory due to either normal scheduler
waker/wakee migrations or automatic NUMA balancing.

>  - how is reclaiming (and possibly thrashing) memory helpful if compaction
>    fails to free an entire pageblock due to slab fragmentation due to low
>    on memory conditions and the page allocator preference to return node-
>    local memory?
> 

It is not, but it requires knowledge of the future to know if
reclaim/compaction will be truely beneficial. While it could be addressed
with tracking state and heuristics, no such state or heuristic has been
proposed. Furthermore, it's ortotogonal to the patch under discussion
and this is somewhat the crux of the matter. You are naking a fix for a
known trivial problem and proposing that people work on an unspecified,
unbounded, long-lived project as the basis for the nak without providing
even a prototype of what you propose.

>  - how is reclaiming (and possibly thrashing) memory helpful if compaction
>    cannot access the memory reclaimed because the freeing scanner has 
>    already passed by it, or the migration scanner has passed by it, since
>    this reclaim is not targeted to pages it can find?
> 

Again, knowledge of the future or a lot of memory scanning combined with
heuristics may be required to achieve what you propose.

>  - what metrics can be introduced to the page allocator so that we can
>    determine that reclaiming (and possibly thrashing) memory will result 
>    in a hugepage being allocated?
> 

Knowledge of the future to know as we cannot know in advance if reclaimn
will succeed without knowing if a workload is keeping contents of slab
and the LRU active.

> Until we have answers, especially for the last, there is no reason why thp 
> allocations should not be __GFP_NORETRY including for MADV_HUGEPAGE 
> regions.  The implementation of memory compaction simply cannot guarantee 
> that the cost is worthwhile.

Other than the fact that the __GFP_NORETRY patch failed at least one test
that is without a clear indication and changelog showing that it
addresses the problems with an unreleased workload.

-- 
Mel Gorman
SUSE Labs
