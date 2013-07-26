Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 946FB6B0033
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 12:04:29 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5.1] Soft limit rework
Date: Fri, 26 Jul 2013 18:04:10 +0200
Message-Id: <1374854658-26990-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

Hi,

This is basically the v5 of the patchset again. There are no changes
except for rebase on top of the current mmotm tree (2013-07-18-16-40) +
new testing results.

Summary of previous versions:
The first version has been posted here: http://permalink.gmane.org/gmane.linux.kernel.mm/97973
(lkml wasn't CCed at the time so I cannot find it in lwn.net
archives). There were no major objections. 

The second version has been posted here http://lwn.net/Articles/548191/
as a part of a longer and spicier thread which started after LSF here:
https://lwn.net/Articles/548192/

Version number 3 has been posted here http://lwn.net/Articles/550409/
Johannes was worried about setups with thousands of memcgs and the
tree walk overhead for the soft reclaim pass without anybody in excess.

Version number 4 has been posted here http://lwn.net/Articles/552703/
appart from heated discussion about memcg iterator predicate which ended
with a conclusion that the predicate based iteration is "the shortest path to
implementing subtree skip given how the iterator is put together
currently and the series as a whole reduces significant amount of
complexity, so it is an acceptable tradeoff to proceed with this
implementation with later restructuring of the iterator." 
(http://thread.gmane.org/gmane.linux.kernel.mm/101162/focus=101560)

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

Changes between V4->V5
Rebased on top of mmotm tree (without slab shrinkers patchset because
there are issues with that patchset) + restested as there were many 
kswapd changes (Results are more or less consistent more on that bellow).
There were only doc updates, no code changes.

Changes between V5->V5.1
Rebased and retested

This patchset is sitting out of tree for quite some time without any
objections. I would be really happy if it made it into 3.12. I do not
want to push it too hard but I think this work is basically ready and
waiting more doesn't help.

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

* TEST 1
========
My primary test case was a parallel kernel build with 2 groups (make
is running with -j8 with a distribution .config in a separate cgroup
without any hard limit) on a 32 CPU machine booted with 1GB memory and
both builds run taskset to Node 0 cpus.

I was mostly interested in 2 setups. Default - no soft limit set and -
and 0 soft limit set to both groups.
The first one should tell us whether the rework regresses the default
behavior while the second one should show us improvements in an extreme
case where both workloads are always over the soft limit.

/usr/bin/time -v has been used to collect the statistics and each
configuration had 3 runs after fresh boot without any other load on the
system.

base is mmotm-2013-07-18-16-40
rework all 8 patches applied on top of base

* No-limit
User
no-limit/base: min: 651.92 max: 672.65 avg: 664.33 std: 8.01 runs: 6
no-limit/rework: min: 657.34 [100.8%] max: 668.39 [99.4%] avg: 663.13 [99.8%] std: 3.61 runs: 6
System
no-limit/base: min: 69.33 max: 71.39 avg: 70.32 std: 0.79 runs: 6
no-limit/rework: min: 69.12 [99.7%] max: 71.05 [99.5%] avg: 70.04 [99.6%] std: 0.59 runs: 6
Elapsed
no-limit/base: min: 398.27 max: 422.36 avg: 408.85 std: 7.74 runs: 6
no-limit/rework: min: 386.36 [97.0%] max: 438.40 [103.8%] avg: 416.34 [101.8%] std: 18.85 runs: 6

The results are within noise. Elapsed time has a bigger variance but the
average looks good.

* 0-limit
User
0-limit/base: min: 573.76 max: 605.63 avg: 585.73 std: 12.21 runs: 6
0-limit/rework: min: 645.77 [112.6%] max: 666.25 [110.0%] avg: 656.97 [112.2%] std: 7.77 runs: 6
System
0-limit/base: min: 69.57 max: 71.13 avg: 70.29 std: 0.54 runs: 6
0-limit/rework: min: 68.68 [98.7%] max: 71.40 [100.4%] avg: 69.91 [99.5%] std: 0.87 runs: 6
Elapsed
0-limit/base: min: 1306.14 max: 1550.17 avg: 1430.35 std: 90.86 runs: 6
0-limit/rework: min: 404.06 [30.9%] max: 465.94 [30.1%] avg: 434.81 [30.4%] std: 22.68 runs: 6

The improvement is really huge here (even bigger than with my previous
testing and I suspect that this highly depends on the storage).  Page
fault statistics tell us at least part of the story:

Minor
0-limit/base: min: 37180461.00 max: 37319986.00 avg: 37247470.00 std: 54772.71 runs: 6
0-limit/rework: min: 36751685.00 [98.8%] max: 36805379.00 [98.6%] avg: 36774506.33 [98.7%] std: 17109.03 runs: 6
Major
0-limit/base: min: 170604.00 max: 221141.00 avg: 196081.83 std: 18217.01 runs: 6
0-limit/rework: min: 2864.00 [1.7%] max: 10029.00 [4.5%] avg: 5627.33 [2.9%] std: 2252.71 runs: 6

Same as with my previous testing Minor faults are more or less within
noise but Major fault count is way bellow the base kernel.

While this looks as a nice win it is fair to say that 0-limit
configuration is quite artificial. So I was playing with 0-no-limit
loads as well.

* TEST 2
========
The following results are from 2 groups configuration on a 16GB machine
(single NUMA node).
- A running stream IO (dd if=/dev/zero of=local.file bs=1024) with
  2*TotalMem with 0 soft limit.
- B running a mem_eater which consumes TotalMem-1G without any limit. The
  mem_eater consumes the memory in 100 chunks with 1s nap after each
  mmap+poppulate so that both loads have chance to fight for the memory.

The expected result is that B shouldn't be reclaimed and A shouldn't see
a big dropdown in elapsed time.

User
base: min: 2.68 max: 2.89 avg: 2.76 std: 0.09 runs: 3
rework: min: 3.27 [122.0%] max: 3.74 [129.4%] avg: 3.44 [124.6%] std: 0.21 runs: 3
System
base: min: 86.26 max: 88.29 avg: 87.28 std: 0.83 runs: 3
rework: min: 81.05 [94.0%] max: 84.96 [96.2%] avg: 83.14 [95.3%] std: 1.61 runs: 3
Elapsed
base: min: 317.28 max: 332.39 avg: 325.84 std: 6.33 runs: 3
rework: min: 281.53 [88.7%] max: 298.16 [89.7%] avg: 290.99 [89.3%] std: 6.98 runs: 3

System time improved slightly as well as Elapsed. My previous testing
has shown worse numbers but this again seem to depend on the storage
speed.

My theory is that the writeback doesn't catch up and prio-0 soft reclaim
falls into wait on writeback page too often in the base kernel. The
patched kernel doesn't do that because the soft reclaim is done from the
kswapd/direct reclaim context. This can be seen on the following graph
nicely. The A's group usage_in_bytes regurarly drops really low very often.

All 3 runs
http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/stream.png
resp. a detail of the single run
http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/stream-one-run.png

mem_eater seems to be doing better as well. It gets to the full
allocation size faster as can be seen on the following graph:
http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/mem_eater-one-run.png

/proc/meminfo collected during the test also shows that rework kernel
hasn't swapped that much (well almost not at all):
base: max: 123900 K avg: 56388.29 K
rework: max: 300 K avg: 128.68 K

kswapd and direct reclaim statistics are of no use unfortunatelly
because soft reclaim is not accounted properly as the counters are
hidden by global_reclaim() checks in the base kernel.

* TEST 3
========
Another test was the same configuration as TEST2 except the stream IO
was replaced by a single kbuild (16 parallel jobs bound to Node0 cpus
same as in TEST1) and mem_eater allocated TotalMem-200M so kbuild had
only 200MB left.
Kbuild did better with the rework kernel here as well:
User
base: min: 860.28 max: 872.86 avg: 868.03 std: 5.54 runs: 3
rework: min: 880.81 [102.4%] max: 887.45 [101.7%] avg: 883.56 [101.8%] std: 2.83 runs: 3
System
base: min: 84.35 max: 85.06 avg: 84.79 std: 0.31 runs: 3
rework: min: 85.62 [101.5%] max: 86.09 [101.2%] avg: 85.79 [101.2%] std: 0.21 runs: 3
Elapsed
base: min: 135.36 max: 243.30 avg: 182.47 std: 45.12 runs: 3
rework: min: 110.46 [81.6%] max: 116.20 [47.8%] avg: 114.15 [62.6%] std: 2.61 runs: 3
Minor
base: min: 36635476.00 max: 36673365.00 avg: 36654812.00 std: 15478.03 runs: 3
rework: min: 36639301.00 [100.0%] max: 36695541.00 [100.1%] avg: 36665511.00 [100.0%] std: 23118.23 runs: 3
Major
base: min: 14708.00 max: 53328.00 avg: 31379.00 std: 16202.24 runs: 3
rework: min: 302.00 [2.1%] max: 414.00 [0.8%] avg: 366.33 [1.2%] std: 47.22 runs: 3

Again we can see a significant improvement in Elapsed (it also seems to
be more stable), there is a huge dropdown for the Major page faults and
much more swapping:
base: max: 583736 K avg: 112547.43 K
rework: max: 4012 K avg: 124.36 K

Graphs from all three runs show the variability of the kbuild quite
nicely. It even seems that it took longer after every run with the base
kernel which would be quite surprising as the source tree for the build
is removed and caches are dropped after each run so the build operates
on a freshly extracted sources everytime.
http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/kbuild-mem_eater.png

My other testing shows that this is just a matter of timing and other
runs behave differently the std for Elapsed time is similar ~50.
Example of other three runs:
http://labs.suse.cz/mhocko/soft_limit_rework/stream_io-vs-mem_eater/kbuild-mem_eater2.png

So to wrap this up. The series is still doing good and improves the soft
limit.

The testing results for bunch of cgroups with both stream IO and kbuild
loads can be found in "memcg: track children in soft limit excess to
improve soft limit".

The series has seen quite some testing and I guess it is in the state to
be merged into mmotm and hopefully get into 3.12. I would like to hear
back from Johannes and Kamezawa about this timing though.

Shortlog says:
Michal Hocko (8):
      memcg, vmscan: integrate soft reclaim tighter with zone shrinking code
      memcg: Get rid of soft-limit tree infrastructure
      vmscan, memcg: Do softlimit reclaim also for targeted reclaim
      memcg: enhance memcg iterator to support predicates
      memcg: track children in soft limit excess to improve soft limit
      memcg, vmscan: Do not attempt soft limit reclaim if it would not scan anything
      memcg: Track all children over limit in the root
      memcg, vmscan: do not fall into reclaim-all pass too quickly

Diffstat says:
 include/linux/memcontrol.h |  54 ++++-
 mm/memcontrol.c            | 567 +++++++++++++--------------------------------
 mm/vmscan.c                |  83 ++++---
 3 files changed, 255 insertions(+), 449 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
