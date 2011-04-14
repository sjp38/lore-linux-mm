Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 65CC4900088
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:55:47 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V4 00/10] memcg: per cgroup background reclaim
Date: Thu, 14 Apr 2011 15:54:19 -0700
Message-Id: <1302821669-29862-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The current implementation of memcg supports targeting reclaim when the
cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
Per cgroup background reclaim is needed which helps to spread out memory
pressure over longer period of time and smoothes out the cgroup performance.

If the cgroup is configured to use per cgroup background reclaim, a kswapd
thread is created which only scans the per-memcg LRU list. Two watermarks
("high_wmark", "low_wmark") are added to trigger the background reclaim and
stop it. The watermarks are calculated based on the cgroup's limit_in_bytes.
By default, the per-memcg kswapd threads are running under root cgroup. There
is a per-memcg API which exports the pid of each kswapd thread, and userspace
can configure cpu cgroup seperately.

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
root     18126     2  0 22:43 ?        00:00:00 [memcg_3]
root     18129  7999  0 22:44 pts/1    00:00:00 grep memcg

$ cat /dev/cgroup/memory/A/memory.kswapd_pid
memcg_3 18126

Step3: Dirty the pages by creating a 20g file on hard drive.
$ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1

Here are the memory.stat with vs without the per-memcg reclaim. It used to be
all the pages are reclaimed from direct reclaim, and now some of the pages are
also being reclaimed at background.

Only direct reclaim                       With background reclaim:

pgpgin 5243228                           pgpgin 5243233
pgpgout 5115242                          pgpgout 5131962
kswapd_steal 0                           kswapd_steal 3836249
pg_pgsteal 5115218                       pg_pgsteal 1295690
kswapd_pgscan 0                          kswapd_pgscan 21233387
pg_scan 5929918                          pg_scan 4359408
pgrefill 264763                          pgrefill 307044
pgoutrun 0                               pgoutrun 54431
allocstall 158364                        allocstall 40858

real   5m4.183s                          real    4m57.100s
user   0m1.197s                          user    0m1.261s
sys    1m8.176s                          sys     1m5.866s

throughput is 67.37 MB/sec               throughput is 68.96 MB/sec

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

pgpgin 5242937                            pgpgin 5242988
pgpgout 5114971                           pgpgout 5126756
kswapd_steal 0                            kswapd_steal 5126676
pg_pgsteal 5114941                        pg_pgsteal 0
kswapd_pgscan 0                           kswapd_pgscan 5126682
pg_scan 5114944                           pg_scan 0
pgrefill 0                                pgrefill 0
pgoutrun 0                                pgoutrun 60765
allocstall 159840                         allocstall 0

real    4m20.649s                         real    4m20.685s
user    0m0.193s                          user    0m0.268s
sys     0m32.266s                         sys     0m24.506s

Note:
This is the first effort of enhancing the target reclaim into memcg. Here are
the existing known issues and our plan:

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

Ying Han (10):
  Add kswapd descriptor
  Add per memcg reclaim watermarks
  New APIs to adjust per-memcg wmarks
  Infrastructure to support per-memcg reclaim.
  Implement the select_victim_node within memcg.
  Per-memcg background reclaim.
  Add per-memcg zone "unreclaimable"
  Enable per-memcg background reclaim.
  Add API to export per-memcg kswapd pid.
  Add some per-memcg stats

 Documentation/cgroups/memory.txt |   14 ++
 include/linux/memcontrol.h       |   91 ++++++++
 include/linux/mmzone.h           |    3 +-
 include/linux/res_counter.h      |   78 +++++++
 include/linux/swap.h             |   16 ++-
 kernel/res_counter.c             |    6 +
 mm/memcontrol.c                  |  450 ++++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c              |    4 +-
 mm/page_alloc.c                  |    1 -
 mm/vmscan.c                      |  438 +++++++++++++++++++++++++++++++------
 10 files changed, 1029 insertions(+), 72 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
