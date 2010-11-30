Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB9C6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:50:22 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
Date: Mon, 29 Nov 2010 22:49:41 -0800
Message-Id: <1291099785-5433-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The current implementation of memcg only supports direct reclaim and this
patchset adds the support for background reclaim. Per cgroup background
reclaim is needed which spreads out the memory pressure over longer period
of time and smoothes out the system performance.

The current implementation is not a stable version, and it crashes sometimes
on my NUMA machine. Before going further for debugging, I would like to start
the discussion and hear the feedbacks of the initial design.

Current status:
I run through some simple tests which reads/writes a large file and makes sure
it triggers per cgroup kswapd on the low_wmark. Also, I compared at
pg_steal/pg_scan ratio w/o background reclaim.

Step1: Create a cgroup with 500M memory_limit and set the min_free_kbytes to 1024.
$ mount -t cgroup -o cpuset,memory cpuset /dev/cgroup
$ mkdir /dev/cgroup/A
$ echo 0 >/dev/cgroup/A/cpuset.cpus
$ echo 0 >/dev/cgroup/A/cpuset.mems
$ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
$ echo 1024 >/dev/cgroup/A/memory.min_free_kbytes
$ echo $$ >/dev/cgroup/A/tasks

Step2: Check the wmarks.
$ cat /dev/cgroup/A/memory.reclaim_wmarks
memcg_low_wmark 98304000
memcg_high_wmark 81920000

Step3: Dirty the pages by creating a 20g file on hard drive.
$ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1

Checked the memory.stat w/o background reclaim. It used to be all the pages are
reclaimed from direct reclaim, and now about half of them are reclaimed at
background. (note: writing '0' to min_free_kbytes disables per cgroup kswapd)

Only direct reclaim                                                With background reclaim:
kswapd_steal 0                                                     kswapd_steal 2751822
pg_pgsteal 5100401                                               pg_pgsteal 2476676
kswapd_pgscan 0                                                  kswapd_pgscan 6019373
pg_scan 5542464                                                   pg_scan 3851281
pgrefill 304505                                                       pgrefill 348077
pgoutrun 0                                                             pgoutrun 44568
allocstall 159278                                                    allocstall 75669

Step4: Cleanup
$ echo $$ >/dev/cgroup/tasks
$ echo 0 > /dev/cgroup/A/memory.force_empty

Step5: Read the 20g file into the pagecache.
$ cat /export/hdc3/dd/tf0 > /dev/zero;

Checked the memory.stat w/o background reclaim. All the clean pages are reclaimed at
background instead of direct reclaim.

Only direct reclaim                                                With background reclaim
kswapd_steal 0                                                      kswapd_steal 3512424
pg_pgsteal 3461280                                               pg_pgsteal 0
kswapd_pgscan 0                                                  kswapd_pgscan 3512440
pg_scan 3461280                                                   pg_scan 0
pgrefill 0                                                                pgrefill 0
pgoutrun 0                                                             pgoutrun 74973
allocstall 108165                                                    allocstall 0


Ying Han (4):
  Add kswapd descriptor.
  Add per cgroup reclaim watermarks.
  Per cgroup background reclaim.
  Add more per memcg stats.

 include/linux/memcontrol.h  |  112 +++++++++++
 include/linux/mmzone.h      |    3 +-
 include/linux/res_counter.h |   88 +++++++++-
 include/linux/swap.h        |   10 +
 kernel/res_counter.c        |   26 ++-
 mm/memcontrol.c             |  447 ++++++++++++++++++++++++++++++++++++++++++-
 mm/mmzone.c                 |    2 +-
 mm/page_alloc.c             |   11 +-
 mm/vmscan.c                 |  346 ++++++++++++++++++++++++++++++----
 9 files changed, 994 insertions(+), 51 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
