Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEA6B90008D
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:04:26 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 0/7] memcg: per cgroup background reclaim
Date: Wed, 13 Apr 2011 00:03:00 -0700
Message-Id: <1302678187-24154-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

The current implementation of memcg supports targeting reclaim when the
cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
Per cgroup background reclaim is needed which helps to spread out memory
pressure over longer period of time and smoothes out the cgroup performance.

If the cgroup is configured to use per cgroup background reclaim, a kswapd
thread is created which only scans the per-memcg LRU list. Two watermarks
("high_wmark", "low_wmark") are added to trigger the background reclaim and
stop it. The watermarks are calculated based on the cgroup's limit_in_bytes.

I run through dd test on large file and then cat the file. Then I compared
the reclaim related stats in memory.stat.

Step1: Create a cgroup with 500M memory_limit.
$ mkdir /dev/cgroup/memory/A
$ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/A/tasks

Step2: Test and set the wmarks.
$ cat /dev/cgroup/memory/A/memory.wmark_ratio
0

$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
low_wmark 524288000
high_wmark 524288000

$ echo 90 >/dev/cgroup/memory/A/memory.wmark_ratio

$ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
low_wmark 471859200
high_wmark 470016000

$ ps -ef | grep memcg
root     18126     2  0 22:43 ?        00:00:00 [memcg_3]
root     18129  7999  0 22:44 pts/1    00:00:00 grep memcg

Step3: Dirty the pages by creating a 20g file on hard drive.
$ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1

Here are the memory.stat with vs without the per-memcg reclaim. It used to be
all the pages are reclaimed from direct reclaim, and now some of the pages are
also being reclaimed at background.

Only direct reclaim                       With background reclaim:

pgpgin 5248668                            pgpgin 5248347
pgpgout 5120678                           pgpgout 5133505
kswapd_steal 0                            kswapd_steal 1476614
pg_pgsteal 5120578                        pg_pgsteal 3656868
kswapd_pgscan 0                           kswapd_pgscan 3137098
pg_scan 10861956                          pg_scan 6848006
pgrefill 271174                           pgrefill 290441
pgoutrun 0                                pgoutrun 18047
allocstall 131689                         allocstall 100179

real    7m42.702s                         real 7m42.323s
user    0m0.763s                          user 0m0.748s
sys     0m58.785s                         sys  0m52.123s

throughput is 44.33 MB/sec                throughput is 44.23 MB/sec

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
pgpgin 5248668                            pgpgin 5248114
pgpgout 5120678                           pgpgout 5133480
kswapd_steal 0                            kswapd_steal 5133397
pg_pgsteal 5120578                        pg_pgsteal 0
kswapd_pgscan 0                           kswapd_pgscan 5133400
pg_scan 10861956                          pg_scan 0
pgrefill 271174                           pgrefill 0
pgoutrun 0                                pgoutrun 40535
allocstall 131689                         allocstall 0

real    7m42.702s                         real 6m20.439s
user    0m0.763s                          user 0m0.169s
sys     0m58.785s                         sys  0m26.574s

Note:
This is the first effort of enhancing the target reclaim into memcg. Here are
the existing known issues and our plan:

1. there are one kswapd thread per cgroup. the thread is created when the
cgroup changes its limit_in_bytes and is deleted when the cgroup is being
removed. In some enviroment when thousand of cgroups are being configured on
a single host, we will have thousand of kswapd threads. The memory consumption
would be 8k*100 = 8M. We don't see a big issue for now if the host can host
that many of cgroups.

2. there is a potential lock contention between per cgroup kswapds, and the
worst case depends on the number of cpu cores on the system. Basically we
now are sharing the zone->lru_lock between per-memcg LRU and global LRU. I have
a plan to get rid of the global LRU eventually, which requires to enhance the
existing targeting reclaim (this patch is included). I would like to get to that
where the locking contention problem will be solved naturely.

3. no hierarchical reclaim support in this patchset. I would like to get to
after the basic stuff are being accepted.

Ying Han (7):
  Add kswapd descriptor
  Add per memcg reclaim watermarks
  New APIs to adjust per-memcg wmarks
  Infrastructure to support per-memcg reclaim.
  Per-memcg background reclaim.
  Enable per-memcg background reclaim.
  Add some per-memcg stats

 Documentation/cgroups/memory.txt |   14 ++
 include/linux/memcontrol.h       |   91 ++++++++
 include/linux/mmzone.h           |    3 +-
 include/linux/res_counter.h      |   80 +++++++
 include/linux/swap.h             |   14 +-
 kernel/res_counter.c             |    6 +
 mm/memcontrol.c                  |  375 +++++++++++++++++++++++++++++++
 mm/page_alloc.c                  |    1 -
 mm/vmscan.c                      |  461 ++++++++++++++++++++++++++++++++------
 9 files changed, 976 insertions(+), 69 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
