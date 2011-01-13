Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2525D6B00E8
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:01:17 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 0/5] memcg: per cgroup background reclaim
Date: Thu, 13 Jan 2011 14:00:30 -0800
Message-Id: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The current implementation of memcg only supports direct reclaim and this
patchset adds the support for background reclaim. Per cgroup background
reclaim is needed which spreads out the memory pressure over longer period
of time and smoothes out the system performance.

I run through some simple tests which reads/writes a large file and makes sure
it triggers per cgroup kswapd on the low_wmark. I compared at pg_steal/pg_scan
ratio w/o background reclaim. Also the running time is measured in this
patchset.

Step1: Create a cgroup with 500M memory_limit.
$ mount -t cgroup -o cpuset,memory cpuset /dev/cgroup
$ mkdir /dev/cgroup/A
$ echo 0 >/dev/cgroup/A/cpuset.cpus
$ echo 0 >/dev/cgroup/A/cpuset.mems
$ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/A/tasks

Step2: Check the wmarks.
$ cat /dev/cgroup/A/memory.reclaim_wmarks
low_wmark 3663360
high_wmark 4396032

Step3: Dirty the pages by creating a 20g file on hard drive.
$ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1

Checked the memory.stat w/o background reclaim. It used to be all the pages are
reclaimed from direct reclaim, and now most of the pages  are reclaimed at
background. (note: writing '0' to min_free_kbytes disables per cgroup kswapd)

Only direct reclaim                       With background reclaim:
pgpgin 5184374                            pgpgin 5248437
pgpgout 5056385                           pgpgout 5121659
kswapd_steal 0                            kswapd_steal 5121516
pg_pgsteal 5056363                        pg_pgsteal 32
kswapd_pgscan 0                           kswapd_pgscan 5121569
pg_scan 5056416                           pg_scan 32
pgrefill 297632                           pgrefill 312512
pgoutrun 0                                pgoutrun 107525
allocstall 158009                         allocstall 1

real 21m6.864s                            real 24m56.735s
user 0m2.047s                             user 0m2.331s
sys 6m2.572s                              sys  7m29.048s

Step4: Cleanup
$ echo $$ >/dev/cgroup/tasks
$ echo 1 > /dev/cgroup/A/memory.force_empty

Step5: Read the 20g file into the pagecache.
$ cat /export/hdc3/dd/tf0 > /dev/zero;

Checked the memory.stat w/o background reclaim. Most of clean pages are
reclaimed at background instead of direct reclaim.

Only direct reclaim                       With background reclaim:
pgpgin 5184066                            pgpgin 5184081
pgpgout 5056093                           pgpgout 5057185
kswapd_steal 0                            kswapd_steal 4960805
pg_pgsteal 5056063                        pg_pgsteal 96348
kswapd_pgscan 0                           kswapd_pgscan 4960809
pg_scan 5056064                           pg_scan 96348
pgrefill 0                                pgrefill 0
pgoutrun 0                                pgoutrun 54904
allocstall 158001                         allocstall 3010

real 3m13.034s                            real 3m13.074s
user 0m0.221s                             user 0m0.158s
sys  0m22.793s                            sys  0m38.603s

TODO:
1. Keep debugging the crash isse on NUMA machine.
2. Generate more test cases and look into reducing the lock contention.

Ying Han (5):
  Add kswapd descriptor.
  Add per cgroup reclaim watermarks.
  New APIs to adjust per cgroup wmarks.
  Per cgroup background reclaim.
  Add more per memcg stats.

 Documentation/cgroups/memory.txt |   14 ++
 include/linux/memcontrol.h       |  102 +++++++++
 include/linux/mmzone.h           |    3 +-
 include/linux/res_counter.h      |   83 ++++++++
 include/linux/swap.h             |   12 +-
 kernel/res_counter.c             |    6 +
 mm/memcontrol.c                  |  390 +++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c                  |    1 -
 mm/vmscan.c                      |  418 ++++++++++++++++++++++++++++++++++----
 9 files changed, 979 insertions(+), 50 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
