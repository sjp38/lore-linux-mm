Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 9D5FB6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 08:10:06 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v5] Soft limit rework
Date: Tue, 18 Jun 2013 14:09:39 +0200
Message-Id: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

Hi,

This is the fifth version of the patchset.

Summary of versions:
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

Please let me know if this has any chance to get merged into 3.11. I do
not want to push it too hard but I think this work is basically ready
and waiting more doesn't help. I can live with 3.12 merge window as well
if 3.11 sounds too early though.

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
baserebase is mmotm-2013-06-05-17-24-63 + patches from the current mmots
without slab shrinkers patchset.
reworkrebase all patches 8 applied on top of baserebase

* No-limit
User
base: min: 1164.94 max: 1169.75 avg: 1168.31 std: 1.57 runs: 6
baserebase: min: 1169.46 [100.4%] max: 1176.07 [100.5%] avg: 1172.49 [100.4%] std: 2.38 runs: 6
reworkrebase: min: 1172.58 [100.7%] max: 1177.43 [100.7%] avg: 1175.53 [100.6%] std: 1.91 runs: 6
System
base: min: 242.55 max: 245.36 avg: 243.92 std: 1.17 runs: 6
baserebase: min: 235.36 [97.0%] max: 238.52 [97.2%] avg: 236.70 [97.0%] std: 1.04 runs: 6
reworkrebase: min: 236.21 [97.4%] max: 239.46 [97.6%] avg: 237.55 [97.4%] std: 1.05 runs: 6
Elapsed
base: min: 596.81 max: 620.04 avg: 605.52 std: 7.56 runs: 6
baserebase: min: 666.45 [111.7%] max: 710.89 [114.7%] avg: 690.62 [114.1%] std: 13.85 runs: 6
reworkrebase: min: 664.05 [111.3%] max: 701.06 [113.1%] avg: 689.29 [113.8%] std: 12.36 runs: 6

Elapsed time regressed by 13% wrt. base but it seems that this came from
baserebase which regressed by the same amount.

* 0-limit
User
base: min: 1188.28 max: 1198.54 avg: 1194.10 std: 3.31 runs: 6
baserebase: min: 1186.17 [99.8%] max: 1196.46 [99.8%] avg: 1189.75 [99.6%] std: 3.41 runs: 6
reworkrebase: min: 1169.88 [98.5%] max: 1177.84 [98.3%] avg: 1173.50 [98.3%] std: 2.79 runs: 6
System
base: min: 248.40 max: 252.00 avg: 250.19 std: 1.38 runs: 6
baserebase: min: 240.77 [96.9%] max: 246.74 [97.9%] avg: 243.63 [97.4%] std: 2.23 runs: 6
reworkrebase: min: 235.19 [94.7%] max: 237.43 [94.2%] avg: 236.35 [94.5%] std: 0.86 runs: 6
Elapsed
base: min: 759.28 max: 805.30 avg: 784.87 std: 15.45 runs: 6
baserebase: min: 881.69 [116.1%] max: 938.14 [116.5%] avg: 911.68 [116.2%] std: 19.58 runs: 6
reworkrebase: min: 667.54 [87.9%] max: 718.54 [89.2%] avg: 695.61 [88.6%] std: 17.16 runs: 6

System time is slightly better but I wouldn't consider it relevant.

Elapsed time is more interesting though. baserebase regresses by 16%
again which is in par with no-limit configuration.

With the patchset applied we are 11% better in average wrt. to the
old base but it is important to realize that this is still 76.3% wrt.
baserebase so the effect of the series is comparable to the previous
version. Albeit the whole result is worse.

Page fault statistics tell us at least part of the story:
Minor
base: min: 35941845.00 max: 36029788.00 avg: 35986860.17 std: 28288.66 runs: 6
baserebase: min: 35852414.00 [99.8%] max: 35899605.00 [99.6%] avg: 35874906.83 [99.7%] std: 18722.59 runs: 6
reworkrebase: min: 35538346.00 [98.9%] max: 35584907.00 [98.8%] avg: 35562362.17 [98.8%] std: 18921.74 runs: 6
Major
base: min: 25390.00 max: 33132.00 avg: 29961.83 std: 2476.58 runs: 6
baserebase: min: 34224.00 [134.8%] max: 45674.00 [137.9%] avg: 41556.83 [138.7%] std: 3595.39 runs: 6
reworkrebase: min: 277.00 [1.1%] max: 480.00 [1.4%] avg: 384.67 [1.3%] std: 74.67 runs: 6

While the minor faults are within the noise the major faults are reduced
considerably. This looks like an aggressive pageout during the reclaim
and that pageout affects the working set presumably. Please note that
baserebase has even hight number of major page faults than the older
mmotm trree.

While this looks as a nice win it is fair to say that there are some
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
baserebase: min: 102.51 [82.1%] max: 108.84 [79.5%] avg: 104.81 [80.1%] std: 2.86 runs: 3
reworkrebase: min: 108.29 [86.7%] max: 121.70 [88.9%] avg: 114.60 [87.6%] std: 5.50 runs: 3
Elapsed
base: min: 398.86 max: 412.81 avg: 407.62 std: 6.23 runs: 3
baserebase: min: 480.92 [120.6%] max: 497.56 [120.5%] avg: 491.46 [120.6%] std: 7.48 runs: 3
reworkrebase: min: 397.19 [99.6%] max: 462.57 [112.1%] avg: 436.13 [107.0%] std: 28.12 runs: 3

baserebase regresses again by 20% and the series is worse by 7% but it
is still at 89% wrt baserebase so it looks good to me.

So to wrap this up. The series is still doing good and improves the soft
limit.

The testing results for bunch of cgroups with both stream IO and kbuild
loads can be found in "memcg: track children in soft limit excess to
improve soft limit".

The series has seen quite some testing and I guess it is in the state to
be merged into mmotm and hopefully get into 3.11. I would like to hear
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

And the disffstat shows us that we still got rid of a lot of code
 include/linux/memcontrol.h |  54 ++++-
 mm/memcontrol.c            | 565 +++++++++++++--------------------------------
 mm/vmscan.c                |  83 ++++---
 3 files changed, 254 insertions(+), 448 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
