Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1161D8D004C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:26:40 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH V7 0/9] memcg: per cgroup background reclaim
Date: Thu, 21 Apr 2011 21:24:11 -0700
Message-Id: <1303446260-21333-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The current implementation of memcg supports targeting reclaim when the
cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
Per cgroup background reclaim is needed which helps to spread out memory
pressure over longer period of time and smoothes out the cgroup performance.

Two watermarks ("high_wmark", "low_wmark") are added to trigger the background
reclaim and stop it. The watermarks are calculated based on the cgroup's
limit_in_bytes. By default, the per-memcg kswapd threads are running under root
cgroup. There is a per-memcg API which exports the pid of each kswapd thread,
and userspace can configure cpu cgroup seperately.

Prior to this version, there are one kswapd thread per cgroup. the thread is
created when the cgroup changes its limit_in_bytes and is deleted when the
cgroup is being removed. In some enviroment when thousand of cgroups are being
configured on a single host, we will have thousand of kswapd threads. The memory
consumption would be 8k*100 = 8M. We don't see a big issue for now if the host
can host that many of cgroups.

In this patchset, i applied the thread pool patch from KAMAZAWA. The patch is
built on top of V6 but changing the threading model. All memcg which needs
background recalim are linked to a list and memcg-kswapd picks up a memcg
from the list and run reclaim.

The per-memcg-per-kswapd model
Pros:
1. memory overhead per thread, and The memory consumption would be 8k*1000 = 8M
with 1k cgroup.
2. we see lots of threads at 'ps -elf'

Cons:
1. the implementation is simply and straigh-forward.
2. we can easily isolate the background reclaim overhead between cgroups.
3. better latency from memory pressure to actual start reclaiming

The thread-pool model
Pros:
1. there is no isolation between memcg background reclaim, since the memcg threads
are shared.
2. it is hard for visibility and debugability. I have been experienced a lot when
some kswapds running creazy and we need a stright-forward way to identify which
cgroup causing the reclaim.
3. potential starvation for some memcgs, if one workitem stucks and the rest of work
won't proceed.

Cons:
1. save some memory resource.

In general, the per-memcg-per-kswapd implmentation looks sane to me at this point,
esepcially the sharing memcg thread model will make debugging issue very hard later.

changlog v7..v6:
1. applied the [PATCH 1/3] memcg kswapd thread pool from KAMAZAWA, and fix the
merge conflicts.
2. applied the [PATCH 3/3] fix mem_cgroup_watemark_ok
3. fix the compile error from the patch with building w/o memcg.
4. removed two patches from V6. (export kswapd_id and the memory.stat)
5. I haven't applied [PATCH 2/3]. Will include that in next post after we deciding
the threading model.

I run through dd test on large file and then cat the file. Then I compared
the reclaim related stats in memory.stat.

Step1: Create a cgroup with 500M memory_limit.
$ mkdir /dev/cgroup/memory/A
$ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/A/tasks

Step2: Test and set the wmarks.
$ cat /dev/cgroup/memory/A/memory.low_wmark_distance
0
$ cat /dev/cgroup/memory/A/memory.high_wmark_distance
0

$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
low_wmark 524288000
high_wmark 524288000

$ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
$ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance

$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
low_wmark 482344960
high_wmark 471859200

$ ps -ef | grep memcg
root       607     2  0 18:25 ?        00:00:01 [memcg_1]
root       608     2  0 18:25 ?        00:00:03 [memcg_2]
root       609     2  0 18:25 ?        00:00:03 [memcg_3]
root     32711 32696  0 21:07 ttyS0    00:00:00 grep memcg

Step3: Dirty the pages by creating a 20g file on hard drive.
$ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1

Here are the memory.stat with vs without the per-memcg reclaim. It used to be
all the pages are reclaimed from direct reclaim, and now some of the pages are
also being reclaimed at background.

Only direct reclaim                      With background reclaim:

pgpgin 5243093                           pgpgin 5242926
pgpgout 5115140                          pgpgout 5127779
kswapd_steal 0                           kswapd_steal 1427513
pg_pgsteal 5115117                       pg_pgsteal 3700243
kswapd_pgscan 0                          kswapd_pgscan 2636508
pg_scan 5941889                          pg_scan 21933629
pgrefill 264792                          pgrefill 283584
pgoutrun 0                               pgoutrun 43875
allocstall 158383                        allocstall 114128

real   5m1.462s                          real    5m0.988s
user   0m1.235s                          user    0m1.209s
sys    1m8.929s                          sys     1m11.348s

throughput is 67.81 MB/sec               throughput is 68.04 MB/sec

Step 4: Cleanup
$ echo $$ >/dev/cgroup/memory/tasks
$ echo 1 > /dev/cgroup/memory/A/memory.force_empty
$ rmdir /dev/cgroup/memory/A
$ echo 3 >/proc/sys/vm/drop_caches

Step 5: Create the same cgroup and read the 20g file into pagecache.
$ cat /export/hdc3/dd/tf0 > /dev/zero

All the pages are reclaimed from background instead of direct reclaim with
the per cgroup reclaim.

Only direct reclaim                       With background reclaim:

pgpgin 5243093                            pgpgin 5243032
pgpgout 5115140                           pgpgout 5127889
kswapd_steal 0                            kswapd_steal 5127830
pg_pgsteal 5115117                        pg_pgsteal 0
kswapd_pgscan 0                           kswapd_pgscan 5127840
pg_scan 5941889                           pg_scan 0
pgrefill 264792                           pgrefill 0
pgoutrun 0                                pgoutrun 160242
allocstall 158383                         allocstall 0

real    4m24.373s                         real    4m20.842s
user    0m0.265s                          user    0m0.289s
sys     0m23.205s                         sys     0m24.393s

Note:
This is the first effort of enhancing the target reclaim into memcg. Here are
the existing known issues and our plan:

The 1 and 2 here are from previous versions and keep here for record.
1. there are one kswapd thread per cgroup. the thread is created when the
cgroup changes its limit_in_bytes and is deleted when the cgroup is being
removed. In some enviroment when thousand of cgroups are being configured on
a single host, we will have thousand of kswapd threads. The memory consumption
would be 8k*100 = 8M. We don't see a big issue for now if the host can host
that many of cgroups.

2. regarding to the alternative workqueue, which is more complicated and we
need to be very careful of work items in the workqueue. We've experienced in
one workitem stucks and the rest of the work item won't proceed. For example
in dirty page writeback, one heavily writer cgroup could starve the other
cgroups from flushing dirty pages to the same disk. In the kswapd case, I can
imagine we might have similar senario. How to prioritize the workitems is
another problem. The order of adding the workitems in the queue reflects the
order of cgroups being reclaimed. We don't have that restriction currently but
relying on the cpu scheduler to put kswapd on the right cpu-core to run. We
"might" introduce priority later for reclaim and how are we gonna deal with
that.

3. there is a potential lock contention between per cgroup kswapds, and the
worst case depends on the number of cpu cores on the system. Basically we
now are sharing the zone->lru_lock between per-memcg LRU and global LRU. I have
a plan to get rid of the global LRU eventually, which requires to enhance the
existing targeting reclaim (this patch is included). I would like to get to that
where the locking contention problem will be solved naturely.

4. no hierarchical reclaim support in this patchset. I would like to get to
after the basic stuff are being accepted.

5. By default, it is running under root. If there is a need to put the kswapd
thread into a cpu cgroup, userspace can make that change by reading the pid from
the new API and echo-ing. In non preemption kernel, we need to be careful of
priority inversion when restricting kswapd cpu time while it is holding a mutex.


Ying Han (9):
  Add kswapd descriptor
  Add per memcg reclaim watermarks
  New APIs to adjust per-memcg wmarks
  Add memcg kswapd thread pool
  Infrastructure to support per-memcg reclaim.
  Implement the select_victim_node within memcg.
  Per-memcg background reclaim.
  Add per-memcg zone "unreclaimable"
  Enable per-memcg background reclaim.

 include/linux/memcontrol.h  |  122 +++++++++++
 include/linux/mmzone.h      |    2 +-
 include/linux/res_counter.h |   78 +++++++
 include/linux/sched.h       |    1 +
 include/linux/swap.h        |   11 +-
 kernel/res_counter.c        |    6 +
 mm/memcontrol.c             |  467 ++++++++++++++++++++++++++++++++++++++++++-
 mm/memory_hotplug.c         |    2 +-
 mm/vmscan.c                 |  337 +++++++++++++++++++++++++------
 9 files changed, 959 insertions(+), 67 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
