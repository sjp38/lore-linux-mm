Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C4346B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 17:59:33 -0500 (EST)
Received: by fxm5 with SMTP id 5so1597054fxm.28
        for <linux-mm@kvack.org>; Fri, 11 Dec 2009 14:59:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v2 0/4] cgroup notifications API and memory thresholds
Date: Sat, 12 Dec 2009 00:59:15 +0200
Message-Id: <cover.1260571675.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

This patchset introduces eventfd-based API for notifications in cgroups and
implements memory notifications on top of it.

It uses statistics in memory controler to track memory usage.

Before changes:

Root cgroup
 Performance counter stats for './multi-fault 2' (5 runs):

  117596.249864  task-clock-msecs         #      1.960 CPUs    ( +-   0.043% )
          80114  context-switches         #      0.001 M/sec   ( +-   0.234% )
             80  CPU-migrations           #      0.000 M/sec   ( +-  24.934% )
       39120862  page-faults              #      0.333 M/sec   ( +-   0.138% )
   294682530295  cycles                   #   2505.884 M/sec   ( +-   0.076% )  (scaled from 70.00%)
   191303772329  instructions             #      0.649 IPC     ( +-   0.041% )  (scaled from 80.01%)
    39400843259  branches                 #    335.052 M/sec   ( +-   0.062% )  (scaled from 80.02%)
      497810459  branch-misses            #      1.263 %       ( +-   1.584% )  (scaled from 80.02%)
     3352408601  cache-references         #     28.508 M/sec   ( +-   0.251% )  (scaled from 19.98%)
         128744  cache-misses             #      0.001 M/sec   ( +-   4.542% )  (scaled from 19.98%)

   60.001025199  seconds time elapsed   ( +-   0.000% )

Non-root cgroup
 Performance counter stats for './multi-fault 2' (5 runs):

  116907.543887  task-clock-msecs         #      1.948 CPUs    ( +-   0.087% )
          70497  context-switches         #      0.001 M/sec   ( +-   0.204% )
             94  CPU-migrations           #      0.000 M/sec   ( +-  11.854% )
       33894593  page-faults              #      0.290 M/sec   ( +-   0.123% )
   291912994149  cycles                   #   2496.956 M/sec   ( +-   0.102% )  (scaled from 70.03%)
   194998499007  instructions             #      0.668 IPC     ( +-   0.109% )  (scaled from 80.01%)
    41752189092  branches                 #    357.139 M/sec   ( +-   0.118% )  (scaled from 79.96%)
      487437901  branch-misses            #      1.167 %       ( +-   0.378% )  (scaled from 79.95%)
     3076284269  cache-references         #     26.314 M/sec   ( +-   0.471% )  (scaled from 20.04%)
         170468  cache-misses             #      0.001 M/sec   ( +-   1.481% )  (scaled from 20.05%)

   60.001211398  seconds time elapsed   ( +-   0.000% )

After changes:

Root cgroup
 Performance counter stats for './multi-fault 2' (5 runs):

  117396.738764  task-clock-msecs         #      1.957 CPUs    ( +-   0.047% )
          78763  context-switches         #      0.001 M/sec   ( +-   0.132% )
            109  CPU-migrations           #      0.000 M/sec   ( +-  25.646% )
       38141062  page-faults              #      0.325 M/sec   ( +-   0.107% )
   294257674123  cycles                   #   2506.523 M/sec   ( +-   0.045% )  (scaled from 70.01%)
   194937378540  instructions             #      0.662 IPC     ( +-   0.120% )  (scaled from 79.98%)
    40694602714  branches                 #    346.642 M/sec   ( +-   0.127% )  (scaled from 79.95%)
      529968529  branch-misses            #      1.302 %       ( +-   1.668% )  (scaled from 79.94%)
     3196763471  cache-references         #     27.230 M/sec   ( +-   0.262% )  (scaled from 20.05%)
         201095  cache-misses             #      0.002 M/sec   ( +-   3.315% )  (scaled from 20.06%)

   60.001025546  seconds time elapsed   ( +-   0.000% )

Non-root cgroup:
 Performance counter stats for './multi-fault 2' (5 runs):

  116471.855099  task-clock-msecs         #      1.941 CPUs    ( +-   0.067% )
          69393  context-switches         #      0.001 M/sec   ( +-   0.099% )
            117  CPU-migrations           #      0.000 M/sec   ( +-  14.049% )
       33043048  page-faults              #      0.284 M/sec   ( +-   0.086% )
   290751403642  cycles                   #   2496.323 M/sec   ( +-   0.073% )  (scaled from 69.97%)
   196594115294  instructions             #      0.676 IPC     ( +-   0.065% )  (scaled from 79.97%)
    42507307304  branches                 #    364.958 M/sec   ( +-   0.054% )  (scaled from 79.96%)
      500670691  branch-misses            #      1.178 %       ( +-   0.729% )  (scaled from 79.98%)
     2935664654  cache-references         #     25.205 M/sec   ( +-   0.153% )  (scaled from 20.04%)
         224967  cache-misses             #      0.002 M/sec   ( +-   2.462% )  (scaled from 20.02%)

   60.001218531  seconds time elapsed   ( +-   0.000% )

Any comments?

TODO:
 - documentation.

v1 -> v2:
 - use statistics instead of res_counter to track resource usage;
 - fix bugs with locking;

v0 -> v1:
 - memsw support implemented.

Kirill A. Shutemov (4):
  cgroup: implement eventfd-based generic API for notifications
  memcg: extract mem_group_usage() from mem_cgroup_read()
  memcg: rework usage of stats by soft limit
  memcg: implement memory thresholds

 include/linux/cgroup.h |   20 +++
 kernel/cgroup.c        |  215 ++++++++++++++++++++++++++++++-
 mm/memcontrol.c        |  335 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 543 insertions(+), 27 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
