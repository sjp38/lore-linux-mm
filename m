Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6F8576B0074
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:19:08 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [patch v4] Soft limit rework
Date: Mon,  3 Jun 2013 12:18:47 +0200
Message-Id: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

Hi,

This is the fourth version of the patchset.

Summary of versions:
The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
(lkml wasn't CCed at the time so I cannot find it in lwn.net
archives). There were no major objections. The second version
has been posted here http://lwn.net/Articles/548191/ as a part
of a longer and spicier thread which started after LSF here:
https://lwn.net/Articles/548192/
Version number 3 has been posted here http://lwn.net/Articles/550409/
Johannes was worried about setups with thousands of memcgs and the
tree walk overhead for the soft reclaim pass without anybody in excess.

Changes between RFC (aka V1) -> V2
As there were no major objections there were only some minor cleanups
since the last version and I have moved "memcg: Ignore soft limit until
it is explicitly specified" to the end of the series.

Changes between V2 -> V3
No changes in the code since the last version. I have just rebased the
series on top of the current mmotm tree. The most controversial part
has been dropped (the last patch "memcg: Ignore soft limit until it is
explicitly specified") so there are no semantical changes to the soft
limit behavior. This makes this work mostly a code clean up and code
reorganization. Nevertheless, this is enough to make the soft limit work
more efficiently according to my testing and groups above the soft limit
are reclaimed much less as a result.

Changes between V3->V4
Added some Reviewed-bys but the biggest change comes from Johannes
concern about the tree traversal overhead with a huge number of memcgs
(http://thread.gmane.org/gmane.linux.kernel.cgroups/7307/focus=100326)
and this version addresses this problem by augmenting the memcg tree
with the number of over soft limit children at each level of the
hierarchy. See more bellow.

The basic idea is quite simple. Pull soft reclaim into shrink_zone in
the first step and get rid of the previous soft reclaim infrastructure.
shrink_zone is done in two passes now. First it tries to do the soft
limit reclaim and it falls back to reclaim-all mode if no group is over
the limit or no pages have been scanned. The second pass happens at the
same priority so the only time we waste is the memcg tree walk which
has been updated in the third step to have only negligible overhead.

As a bonus we will get rid of a _lot_ of code by this and soft reclaim
will not stand out like before when it wasn't integrated into the zone
shrinking code and it reclaimed at priority 0 (the testing results show
that some workloads suffers from such an aggressive reclaim). The clean
up is in a separate patch because I felt it would be easier to review
that way.

The second step is soft limit reclaim integration into targeted
reclaim. It should be rather straight forward. Soft limit has been used
only for the global reclaim so far but it makes sense for any kind of
pressure coming from up-the-hierarchy, including targeted reclaim.

The third step (patches 4-8) addresses the tree walk overhead by
enhancing memcg iterators to enable skipping whole subtrees and tracking
number of over soft limit children at each level of the hierarchy. This
information is updated same way the old soft limit tree was updated
(from memcg_check_events) so we shouldn't see an additional overhead. In
fact mem_cgroup_update_soft_limit is much simpler than tree manipulation
done previously.
__shrink_zone uses mem_cgroup_soft_reclaim_eligible as a predicate for
mem_cgroup_iter so the decision whether a particular group should be
visited is done at the iterator level which allows us to decide to skip
the whole subtree as well (if there is no child in excess). This reduces
the tree walk overhead considerably.

My primary test case was a parallel kernel build with 2 groups (make
is running with -j4 with a distribution .config in a separate cgroup
without any hard limit) on a 8 CPU machine booted with 1GB memory.  I
was mostly interested in 2 setups. Default - no soft limit set and - and
0 soft limit set to both groups.
The first one should tell us whether the rework regresses the default
behavior while the second one should show us improvements in an extreme
case where both workloads are always over the soft limit.

/usr/bin/time -v has been used to collect the statistics and each
configuration had 3 runs after fresh boot without any other load on the
system.

base is mmotm-2013-05-09-15-57
rework means patches 1-3
reworkoptim means patches 4-8

* No-limit
System
base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
rework: min: 240.74 [99.3%] max: 244.90 [99.8%] avg: 242.82 [99.5%] std: 1.45 runs: 6
reworkoptim: min: 242.07 [99.8%] max: 244.73 [99.7%] avg: 243.78 [99.9%] std: 0.91 runs: 6
Elapsed
base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
rework: min: 590.06 [98.9%] max: 602.11 [97.1%] avg: 596.09 [98.4%] std: 4.39 runs: 6
reworkoptim: min: 591.54 [99.1%] max: 613.47 [98.9%] avg: 599.60 [99.0%] std: 7.20 runs: 6

The numbers are within stdev so it doesn't look like an regression

* 0-limit
System
base: min: 248.40 max: 252.00 avg: 250.19 std: 1.38 runs: 6
rework: min: 240.31 [96.7%] max: 243.61 [96.7%] avg: 242.01 [96.7%] std: 1.18 runs: 6
reworkoptim: min: 242.67 [97.7%] max: 245.73 [97.5%] avg: 244.52 [97.7%] std: 1.00 runs: 6
Elapsed
base: min: 759.28 max: 805.30 avg: 784.87 std: 15.45 runs: 6
rework: min: 588.75 [77.5%] max: 606.30 [75.3%] avg: 597.07 [76.1%] std: 5.12 runs: 6
reworkoptim: min: 591.31 [77.9%] max: 612.52 [76.1%] avg: 601.08 [76.6%] std: 6.93 runs: 6

We can see 2-3% time decrease for System time which is not rocket high
but sounds like a good outcome from a cleanup (rework) and the tracking
overhead is barely visible (within the noise).

It is even more interesting to check the Elapsed time numbers which show
that the parallel load is much more effective. I haven't looked into
the specific reasons for this boost up deeply but I would guess that
priority-0 reclaim done in the original implementation should be a big
contributor.

Page fault statistics tell us at least part of the story:
Minor
base: min: 35941845.00 max: 36029788.00 avg: 35986860.17 std: 28288.66 runs: 6
rework: min: 35595937.00 [99.0%] max: 35690024.00 [99.1%] avg: 35654958.17 [99.1%] std: 31270.07 runs: 6
reworkoptim: min: 35596909.00 [99.0%] max: 35684640.00 [99.0%] avg: 35660804.67 [99.1%] std: 29918.93 runs: 6
Major
base: min: 25390.00 max: 33132.00 avg: 29961.83 std: 2476.58 runs: 6
rework: min: 451.00 [1.8%] max: 1600.00 [4.8%] avg: 814.17 [2.7%] std: 380.01 runs: 6
reworkoptim: min: 318.00 [1.3%] max: 2023.00 [6.1%] avg: 911.50 [3.0%] std: 632.83 runs: 6

While the minor faults are within the noise the major faults are reduced
considerably. This looks like an aggressive pageout during the reclaim
and that pageout affects the working set presumably.

 While this looks as a huge win it is fair to say that there are some
workloads that actually benefit from reclaim at 0 priority (from
background reclaim). E.g. an aggressive streaming IO would like to get
rid of as many pages as possible and do not block on the pages under
writeback. This can lead to a higher System time but I generally got
Elapsed which was comparable.

The following results are from 2 groups configuration on a 8GB machine
(A running stream IO with 4*TotalMem with 0 soft limit, B runnning a
mem_eater which consumes TotalMem-1G without any limit).
System
base: min: 124.88 max: 136.97 avg: 130.77 std: 4.94 runs: 3
rework: min: 161.67 [129.5%] max: 196.80 [143.7%] avg: 174.18 [133.2%] std: 16.02 runs: 3
reworkoptim: min: 267.48 [214.2%] max: 319.64 [233.4%] avg: 300.43 [229.7%] std: 23.40 runs: 3
Elapsed
base: min: 398.86 max: 412.81 avg: 407.62 std: 6.23 runs: 3
rework: min: 423.41 [106.2%] max: 450.30 [109.1%] avg: 440.92 [108.2%] std: 12.39 runs: 3
reworkoptim: min: 379.91 [95.2%] max: 416.46 [100.9%] avg: 399.26 [97.9%] std: 15.00 runs: 3

The testing results for bunch of cgroups with both stream IO and kbuild
loads can be found in "memcg: track children in soft limit excess to
improve soft limit".

The series has seen quite some testing and I guess it is in the state to
be merged into mmotm and hopefully get into 3.11. I would like to hear
back from Johannes and Kamezawa about this timing though.

Shortlog says:
Michal Hocko (8):
      memcg: integrate soft reclaim tighter with zone shrinking code
      memcg: Get rid of soft-limit tree infrastructure
      vmscan, memcg: Do softlimit reclaim also for targeted reclaim
      memcg: enhance memcg iterator to support predicates
      memcg: track children in soft limit excess to improve soft limit
      memcg, vmscan: Do not attempt soft limit reclaim if it would not scan anything
      memcg: Track all children over limit in the root
      memcg, vmscan: do not fall into reclaim-all pass too quickly

And the diffstat is still promissing I would say:
 include/linux/memcontrol.h |   46 +++-
 mm/memcontrol.c            |  537 +++++++++++---------------------------------
 mm/vmscan.c                |   83 ++++---
 3 files changed, 218 insertions(+), 448 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
