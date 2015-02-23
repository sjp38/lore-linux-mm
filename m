Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D1EC96B0070
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:27 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id l15so16445653wiw.3
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gd5si61497543wjb.116.2015.02.23.04.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:20 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/6] the big khugepaged redesign
Date: Mon, 23 Feb 2015 13:58:36 +0100
Message-Id: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
THP allocation attempts on page faults are a good performance trade-off.

- THP allocations add to page fault latency, as high-order allocations are
  notoriously expensive. Page allocation slowpath now does extra checks for
  GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
  compaction for user page faults. But even async compaction can be expensive.
- During the first page fault in a 2MB range we cannot predict how much of the
  range will be actually accessed - we can theoretically waste as much as 511
  worth of pages [2]. Or, the pages in the range might be accessed from CPUs
  from different NUMA nodes and while base pages could be all local, THP could
  be remote to all but one CPU. The cost of remote accesses due to this false
  sharing would be higher than any savings on the TLB.
- The interaction with memcg are also problematic [1].

Now I don't have any hard data to show how big these problems are, and I
expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
for performance reasons.

One might think that instead of fully disabling THP's it should be possible to
only disable (or make less aggressive, or limit to MADV_HUGEPAGE regions) THP's
for page faults and leave the collapsing up to khugepaged, which would hide the
latencies and allow better decisions based on how many base pages were faulted
in and from which nodes. However, looking more closely gives the impression
that khugepaged was meant rather as a rarely needed fallback for cases where
the THP page fault fails due to e.g. low memory. There are some tunables under
/sys/kernel/mm/transparent_hugepage/ but it doesn't seem sufficient for moving
the bulk of the THP work to khugepaged as it is.

- setting "defrag" to "madvise" or "never", while leaving khugepaged/defrag=1
  will result in very lightweight THP allocation attempts during page faults.
  This is nice and solves the latency problem, but not the other problems
  described above. It doesn't seem possible to disable page fault THP's
  completely without also disabling khugepaged.
- even if it was possible, the default settings for khugepaged are to scan up
  to 8 PMD's and collapse up to 1 THP per 10 seconds. That's probably too slow
  for some workloads and machines, but if one was to set this to be more
  aggressive, it would become quite inefficient. Khugepaged has a single global
  list of mm's to scan, which may include lot of tasks where scanning won't yield
  anything. It should rather focus on tasks that are actually running (and thus
  could benefit) and where collapses were recently successful. The activity
  should also be ideally accounted to the task that benefits from it.
- scanning on NUMA systems will proceed even when actual THP allocations fail,
  e.g. during memory pressure. In such case it should be better to save the
  scanning time until memory is available.
- there were some limitations on which PMD's khugepaged can collapse. Thanks to
  Ebru's recent patches, this should be fixed soon. With the
  khugepaged/max_ptes_none tunable, one can limit the potential memory wasted.
  But limiting NUMA false sharing is performed just in zone reclaim mode and
  could be made stricter.

This RFC patchset doesn't try to solve everything mentioned above - the full
motivation is included for the bigger picture discussion, including LSF/MM.
The main part of this patchset is the move of collapse scanning from
khugepaged to the task_work context. This has been already discussed as a good
idea and a RFC has been posted by Alex Thorlton last October [5]. In that
prototype, scanning has been driven from __khugepaged_enter(), which is called
on events such as vma_merge, fork, and THP page fault attempts, e.g. events
that are not exactly periodical. The main difference in my patchset is it being
modeled after the automatic NUMA balancing scanning, i.e. using scheduler's
task_tick_fair(). The second difference is that khugepaged is not disabled
entirely, but repurposed for the costly hugepage allocations. There is a
nodemask for indicating which nodes should have hugepages easily available.
The idea is that hugepage allocation attempts from the process context
(either page fault or the task_work collapsing) would not attempt
reclaim/compaction, and on failure will clear the nodemask bit and wake up
khugepaged to do the hard work and flip the bit back on. If if appears that
ther are no hugepages available, attempts to page fault THP or scan are
suspended.

I have done only light testing so far to see that it works as intended, but
not to prove it's "better" than current state. I wanted to post the RFC before
LSF/MM.

There are known limitations and TODO/FIXME's in the code, for example:
- the scanning period doesn't yet adjust itself based on recent collapse
  success/failure. The idea is that it will double itself if the last full
  mm scan yielded no collapse.
- some user-visible counters for the task scanning activity should be added
- the change of THP allocation attempts pressure can have hard to predict
  outcomes on fragmentation and the periods of deferred compaction.
- Documentation should be updated

More stuff is not decided yet:
- moving to task context from khugepaged results in the hugepage allocations
  for collapsing not use sync compaction anymore. But should we also change
  the "defrag" default from "always" to e.g. "madvise", which results in
  ~__GFP_WAIT allocations to further reduce latencies perceived from process
  context?
- Would make sense to have one khugepaged instance per memory node, bound to
  the corresponding CPU's? It would then touch local memory e.g. during
  compaction migrations, and the khugepaged sleeps and wakeups would be more
  fine-grained.
- should we keep using the tunables under /sys/.../khugepaged for the activity
  that is mostly no longer performed by khugepaged, and when e.g. NUMA
  balancing uses sysctl?

The stuff not touched by this patchset (nor decided):
- should we allow the user to disable THP page faults completely (or restrict
  them to MADV_HUGEPAGE vma's?), or just assume that max_ptes_none < 511 means
  it should be disabled, because we cannot know how much of the 2MB the process
  would fault in?
- do we want to further limit collapses when base pages come from different
  NUMA nodes? Another tunable (saying that minimum X pte's should be from
  single node), or just hard-require that all are from the same node?

Patchset was lightly tested on v3.19 + 2 cherry-picked patches 077fcf116c8c and
be97a41b291, and rebased to 4.0-rc1 before sending.

[1] http://marc.info/?l=linux-mm&m=142056088232484&w=2
[2] http://www.spinics.net/lists/kernel/msg1928252.html
[3] http://www.spinics.net/lists/linux-mm/msg84023.html
[4] http://scn.sap.com/people/markmumy/blog/2014/05/22/sap-iq-and-linux-hugepagestransparent-hugepages
[5] https://lkml.org/lkml/2014/10/22/931

Vlastimil Babka (6):
  mm, thp: stop preallocating hugepages in khugepaged
  mm, thp: make khugepaged check for THP allocability before scanning
  mm, thp: try fault allocations only if we expect them to succeed
  mm, thp: move collapsing from khugepaged to task_work context
  mm, thp: wakeup khugepaged when THP allocation fails
  mm, thp: remove no longer needed khugepaged code

 include/linux/khugepaged.h |  19 +-
 include/linux/mm_types.h   |   4 +
 include/linux/sched.h      |   5 +
 kernel/fork.c              |   1 -
 kernel/sched/core.c        |  12 +
 kernel/sched/fair.c        | 124 ++++++++-
 mm/huge_memory.c           | 628 ++++++++++++++-------------------------------
 7 files changed, 339 insertions(+), 454 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
