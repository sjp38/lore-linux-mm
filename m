Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33C7A6B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:49:47 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 7so37390138otu.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 04:49:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p187si702469oig.60.2017.03.15.04.49.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 04:49:44 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v8] mm: Add memory allocation watchdog kernel thread.
Date: Wed, 15 Mar 2017 20:49:01 +0900
Message-Id: <1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>, Alexander Polakov <apolyakov@beget.ru>

This patch adds a watchdog which periodically reports number of memory
allocating tasks, dying tasks and OOM victim tasks when some task is
spending too long time inside __alloc_pages_slowpath(). This patch also
serves as a hook for obtaining additional information using SystemTap
(e.g. examine other variables using printk(), capture a crash dump by
calling panic()) by triggering a callback only when a stall is detected.
Ability to take administrator-controlled actions based on some threshold
is a big advantage gained by introducing a state tracking.

Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
too long") was a great step for reducing possibility of silent hang up
problem caused by memory allocation stalls [1]. However, there are
reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
[3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
lockup problem) where this patch is more useful than that commit, for
this patch can report possibly related tasks even if allocating tasks
are unexpectedly blocked for so long. Regarding premature OOM killer
invocation, tracepoints which can accumulate samples in short interval
would be useful. But regarding too late to report allocation stalls,
this patch which can capture all tasks (for reporting overall situation)
in longer interval and act as a trigger (for accumulating short interval
samples) would be useful.

Thanks to the OOM reaper which can guarantee forward progress (by selecting
next OOM victim) as long as the OOM killer can be invoked, we can start
testing low memory situations which are previously too difficult to test.
And we are now aware that there are still corner cases remaining where
the system hangs without invoking the OOM killer.

This patch is aimed for help bisecting whether unexpected hung cases are
related to memory allocation. By merging this patch (and enabling this
watchdog in enterprise systems via kernels supported by distributors),
we can identify patterns/cases of problems (if related to memory
allocation) and improve quality of Linux kernels by fixing problems
related to memory allocation.

As a nature of hang up problems caused by memory allocation, it is very
hard for administrators to collect information for analysis. As a result,
such problems are left unrecognized/unsolved at the support center, and
are seldom reported to distributors/developers in order to ask for fixes.
Therefore, nobody can prove that this patch will not find any problems
which occur in production systems. By merging this patch, we can start
focusing on real problems which occurred in production systems.

This patch remained out-of-tree for a year and a half due to a question
whether amount of changes, runtime cost and maintenance burden caused
by this patch can be justified. But after all there is no real objection.

  Regarding amount of changes, I consider it is needed for making the
  watchdog safe/robust (e.g. no duplicated/skipped reports and no lockup
  warnings even if hundreds of threads entered into direct reclaim for
  memory allocation) and useful (e.g. trigger additional actions only when
  needed).

  Regarding runtime cost of allocating threads, this watchdog involves
  only slowpath where __GFP_DIRECT_RECLAIM is evaluated (in other words,
  direct reclaim for memory allocation is needed). Therefore, systems
  with adequate memory pressure will not notice.
  Regarding runtime cost of the watchdog kernel thread side, I tried to
  minimize it by checking per CPU in-flight counters before traversing
  the tasklist.

  Regarding maintenance burden, I consider this patch is least invasive
  because it does not make __GFP_NOWARN flag's semantic confusing while
  providing administrators some hints [4]. Also, this patch will remain
  useful because we might overlook something that can cause infinite
  loop (or significant delay) in future changes, and we can remove this
  patch when we achieve safe and robust memory management subsystem.

Changes from v1 [5]:

  (1) Use per a "struct task_struct" variables. This allows vmcore to
      remember information about last memory allocation request, which
      is useful for understanding last-minute behavior of the kernel.

  (2) Report using accurate timeout. This increases possibility of
      successfully reporting before watchdog timers reset the machine.

  (3) Show memory information (SysRq-m). This makes it easier to know
      the reason of stalling.

  (4) Show both $state_of_allocation and $state_of_task in the same
      line. This makes it easier to grep the output.

  (5) Minimize duration of spinlock held by the kernel thread.

Changes from v2 [6]:

  (1) Print sequence number. This makes it easier to know whether
      memory allocation is succeeding (looks like a livelock but making
      forward progress) or not.

  (2) Replace spinlock with cheaper seqlock_t like sequence number based
      method. The caller no longer contend on lock, and major overhead
      for caller side will be two smp_wmb() instead for
      read_lock()/read_unlock().

  (3) Print "exiting" instead for "dying" if an OOM victim is stalling
      at do_exit(), for SIGKILL is removed before arriving at do_exit().

  (4) Moved explanation to Documentation/malloc-watchdog.txt .

Changes from v3 [7]:

  (1) Avoid stalls even if there are so many tasks to report.

Changes from v4 [8]:

  (1) Use per CPU in-flight counter by reverting "Report using accurate
      timeout." in v2, in order to avoid walking the process list which
      is costly when there are extremely so many tasks in the system.

  (2) Updated Documentation/malloc-watchdog.txt to add explanation for
      serving as a hook for dynamic probes.

Changes from v5 [9]:

  (1) Disable commit 63f53dea0c9866e9 ("mm: warn about allocations which
      stall for too long") when CONFIG_DETECT_MEMALLOC_STALL_TASK is
      enabled.

  (2) Updated Documentation/malloc-watchdog.txt to reflect OOM related
      improvements up to Linux 4.9.

Changes from v6 [10]:

  (1) Check __GFP_DIRECT_RECLAIM allocation requests rather than
      __GFP_RECLAIM == (__GFP_KSWAPD_RECLAIM|__GFP_DIRECT_RECLAIM)
      allocation requests.

  (2) Rename /proc/sys/kernel/memalloc_task_timeout_secs to
      /proc/sys/kernel/memalloc_task_warning_secs , for the name of
      "timeout" is associated with "give up retrying, and OOM kill or fail".
      This variable is for emitting warning messages rather than giving up.

Changes from v7 [11]:

  (1) Reflect review comments from Andrew Morton. (Convert "u8 type" to
      "bool report", use CPUHP_PAGE_ALLOC_DEAD event and replace
      for_each_possible_cpu() with for_each_online_cpu(), reuse existing
      rcu_lock_break() and hung_timeout_jiffies() for now, update comments).

[1] http://lkml.kernel.org/r/201610182004.AEF87559.FOOHVLJOQFFtSM@I-love.SAKURA.ne.jp
[2] https://bugzilla.kernel.org/show_bug.cgi?id=192981
[3] http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp
[4] http://lkml.kernel.org/r/1484132120-35288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[5] http://lkml.kernel.org/r/201510182105.AGA00839.FHVFFStLQOMOOJ@I-love.SAKURA.ne.jp
[6] http://lkml.kernel.org/r/201511222346.JBH48464.VFFtOLOOQJMFHS@I-love.SAKURA.ne.jp
[7] http://lkml.kernel.org/r/201511250024.AAE78692.QVOtFFOSFOMLJH@I-love.SAKURA.ne.jp
[8] http://lkml.kernel.org/r/201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp
[9] http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[10] http://lkml.kernel.org/r/1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[11] http://lkml.kernel.org/r/1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Polakov <apolyakov@beget.ru>
---
 Documentation/malloc-watchdog.txt | 515 ++++++++++++++++++++++++++++++++++++++
 include/linux/oom.h               |   4 +
 include/linux/sched.h             |  19 ++
 kernel/fork.c                     |   4 +
 kernel/hung_task.c                | 213 +++++++++++++++-
 kernel/sysctl.c                   |  10 +
 lib/Kconfig.debug                 |  24 ++
 mm/oom_kill.c                     |   3 +
 mm/page_alloc.c                   |  84 +++++++
 9 files changed, 875 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/malloc-watchdog.txt

diff --git a/Documentation/malloc-watchdog.txt b/Documentation/malloc-watchdog.txt
new file mode 100644
index 0000000..218c094
--- /dev/null
+++ b/Documentation/malloc-watchdog.txt
@@ -0,0 +1,515 @@
+=================================
+Memory allocation stall watchdog.
+=================================
+
+
+- What is it?
+
+This is an extension to khungtaskd kernel thread, which is for warning
+that memory allocation requests are stalling, in order to catch unexplained
+hangups/reboots caused by memory allocation stalls.
+
+
+- Why need to use it?
+
+Currently, when something went wrong inside memory allocation request,
+the system might stall without any kernel messages.
+
+Although there is khungtaskd kernel thread as an asynchronous monitoring
+approach, khungtaskd kernel thread is not always helpful because memory
+allocating tasks unlikely sleep in uninterruptible state for
+/proc/sys/kernel/hung_task_timeout_secs seconds.
+
+Although there is warn_alloc() as a synchronous monitoring approach
+which emits
+
+  "%s: page allocation stalls for %ums, order:%u, mode:%#x(%pGg), nodemask=%*pbl\n"
+
+line, warn_alloc() is not bullet proof because allocating tasks can take
+too long to wait (e.g. 30+ minutes, or possibly forever) before calling
+warn_alloc() and/or such lines are suppressed by ratelimiting and/or
+such lines are corrupted due to collisions.
+
+Unless we use asynchronous monitoring approach, we can fail to figure out
+that something went wrong inside memory allocation requests.
+
+People are reporting hang up problems and/or slowdown problem inside memory
+allocation request. But we are forcing people to use kernels without means
+to find out what was happening. The means are expected to work without
+knowledge to use trace points functionality, are expected to run without
+memory allocation, are expected to dump output without administrator's
+operation, are expected to work before watchdog timers reset the machine.
+
+This extension adds a state tracking mechanism for memory allocation requests
+to khungtaskd kernel thread, allowing administrators to figure out that the
+system hung up due to memory allocation stalls and/or to take administrator-
+controlled actions when memory allocation requests are stalling.
+
+
+- How to configure it?
+
+Build kernels with CONFIG_DETECT_HUNG_TASK=y and
+CONFIG_DETECT_MEMALLOC_STALL_TASK=y.
+
+Default scan interval is configured by CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT.
+Scan interval can be changed at run time by writing timeout in seconds to
+/proc/sys/kernel/memalloc_task_warning_secs. Writing 0 disables this scan.
+
+Even if you disable this scan, information about last memory allocation
+request is kept. That is, you will get some hint for understanding
+last-minute behavior of the kernel when you analyze vmcore (or memory
+snapshot of a virtualized machine).
+
+
+- How memory allocation stalls are reported?
+
+This extension will report allocation stalls by printing
+
+  MemAlloc-Info: stalling=$X dying=$Y1 exiting=$Y2 victim=$Z oom_count=$O
+
+line where $X > 0, followed by
+
+  MemAlloc: $name($pid) flags=$flags switches=$switches $state_of_allocation $state_of_task
+
+lines and corresponding stack traces.
+
+$O is number of times the OOM killer is invoked. If $O does not increase
+over time, allocation requests got stuck before calling the OOM killer.
+
+$name is that task's comm name string ("struct task_struct"->comm).
+
+$pid is that task's pid value ("struct task_struct"->pid).
+
+$flags is that task's flags value ("struct task_struct"->flags).
+
+$switches is that task's context switch counter ("struct task_struct"->nvcsw +
+"struct task_struct"->nivcsw) which is also checked by
+/proc/sys/kernel/hung_task_warnings for finding hung tasks.
+
+$state_of_allocation is reported only when that task is stalling inside
+__alloc_pages_slowpath(), in seq=$seq gfp=$gfp order=$order delay=$delay
+format where $seq is the sequence number for allocation request, $gfp is
+the gfp flags used for that allocation request, $order is the order,
+delay is jiffies elapsed since entering into __alloc_pages_slowpath().
+
+You can check for seq=$seq field for each reported process. If $seq is
+increasing over time, it will be simply overloaded (not a livelock but
+progress is too slow to wait) unless the caller is doing open-coded
+__GFP_NOFAIL allocation requests (effectively a livelock).
+
+$state_of_task is reported only when that task is dying, in combination
+of "uninterruptible" (where that task is in uninterruptible sleep,
+likely due to uninterruptible lock), "exiting" (where that task arrived
+at do_exit() function), "dying" (where that task has pending SIGKILL)
+and "victim" (where that task received TIF_MEMDIE, likely be only 1 task).
+
+
+- How the messages look like?
+
+An example of MemAlloc lines (grep of dmesg output) is shown below.
+You can use serial console and/or netconsole to save these messages
+when the system is stalling.
+
+  [  100.503284] MemAlloc-Info: stalling=8 dying=1 exiting=0 victim=1 oom_count=101421
+  [  100.505674] MemAlloc: kswapd0(54) flags=0xa40840 switches=84685
+  [  100.546645] MemAlloc: kworker/3:1(70) flags=0x4208060 switches=9462 seq=5 gfp=0x2400000(GFP_NOIO) order=0 delay=8207 uninterruptible
+  [  100.606034] MemAlloc: systemd-journal(469) flags=0x400100 switches=8380 seq=212 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.651766] MemAlloc: irqbalance(998) flags=0x400100 switches=4366 seq=5 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=5819
+  [  100.697590] MemAlloc: vmtoolsd(1928) flags=0x400100 switches=8542 seq=82 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.743312] MemAlloc: tuned(3737) flags=0x400040 switches=8220 seq=44 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.792038] MemAlloc: nmbd(3759) flags=0x400140 switches=8079 seq=198 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10620 uninterruptible
+  [  100.839428] MemAlloc: oom-write(3814) flags=0x400000 switches=8126 seq=223446 gfp=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=10620 uninterruptible
+  [  100.878846] MemAlloc: write(3816) flags=0x400000 switches=7440 uninterruptible dying victim
+  [  100.917971] MemAlloc: write(3820) flags=0x400000 switches=16130 seq=8714 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=10620 uninterruptible
+  [  101.190979] MemAlloc-Info: stalling=8 dying=1 exiting=0 victim=1 oom_count=107514
+  [  111.194055] MemAlloc-Info: stalling=9 dying=1 exiting=0 victim=1 oom_count=199825
+  [  111.196624] MemAlloc: kswapd0(54) flags=0xa40840 switches=168410
+  [  111.238096] MemAlloc: kworker/3:1(70) flags=0x4208060 switches=18592 seq=5 gfp=0x2400000(GFP_NOIO) order=0 delay=18898
+  [  111.296920] MemAlloc: systemd-journal(469) flags=0x400100 switches=15918 seq=212 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311
+  [  111.343129] MemAlloc: systemd-logind(973) flags=0x400100 switches=7786 seq=3 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=10476
+  [  111.390142] MemAlloc: irqbalance(998) flags=0x400100 switches=11965 seq=5 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=16510
+  [  111.435170] MemAlloc: vmtoolsd(1928) flags=0x400100 switches=16230 seq=82 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311 uninterruptible
+  [  111.479089] MemAlloc: tuned(3737) flags=0x400040 switches=15850 seq=44 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311 uninterruptible
+  [  111.528294] MemAlloc: nmbd(3759) flags=0x400140 switches=15682 seq=198 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=21311
+  [  111.576371] MemAlloc: oom-write(3814) flags=0x400000 switches=15378 seq=223446 gfp=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) order=0 delay=21311 uninterruptible
+  [  111.617562] MemAlloc: write(3816) flags=0x400000 switches=7440 uninterruptible dying victim
+  [  111.661662] MemAlloc: write(3820) flags=0x400000 switches=24334 seq=8714 gfp=0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) order=0 delay=21311 uninterruptible
+  [  111.956964] MemAlloc-Info: stalling=9 dying=1 exiting=0 victim=1 oom_count=206663
+
+You can check whether memory allocations are making forward progress.
+You can check where memory allocations are stalling using stack trace
+of reported task which follows each MemAlloc: line. You can check memory
+information (SysRq-m) and stuck workqueues information which follow the
+end of MemAlloc: lines. You can also check locks held (SysRq-d) if built
+with CONFIG_PROVE_LOCKING=y and lockdep is still active.
+
+Two more examples from stress tests are shown below.
+
+This extension found a lockup situation where all __GFP_DIRECT_RECLAIM allocation
+requests fall into an infinite loop (and therefore cannot call warn_alloc()) inside
+shrink_inactive_list() from output shown below.
+
+  (1) kswapd cannot make progress waiting for lock.
+
+----------
+[ 1209.790966] MemAlloc: kswapd0(67) flags=0xa60840 switches=51139 uninterruptible
+[ 1209.799726] kswapd0         D10936    67      2 0x00000000
+[ 1209.807326] Call Trace:
+[ 1209.812581]  __schedule+0x336/0xe00
+[ 1209.818599]  schedule+0x3d/0x90
+[ 1209.823907]  schedule_timeout+0x26a/0x510
+[ 1209.827218]  ? trace_hardirqs_on+0xd/0x10
+[ 1209.830535]  __down_common+0xfb/0x131
+[ 1209.833801]  ? _xfs_buf_find+0x2cb/0xc10 [xfs]
+[ 1209.837372]  __down+0x1d/0x1f
+[ 1209.840331]  down+0x41/0x50
+[ 1209.843243]  xfs_buf_lock+0x64/0x370 [xfs]
+[ 1209.846597]  _xfs_buf_find+0x2cb/0xc10 [xfs]
+[ 1209.850031]  ? _xfs_buf_find+0xa4/0xc10 [xfs]
+[ 1209.853514]  xfs_buf_get_map+0x2a/0x480 [xfs]
+[ 1209.855831]  xfs_buf_read_map+0x2c/0x400 [xfs]
+[ 1209.857388]  ? free_debug_processing+0x27d/0x2af
+[ 1209.859037]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
+[ 1209.860707]  xfs_read_agf+0xc8/0x2b0 [xfs]
+[ 1209.862184]  xfs_alloc_read_agf+0x7a/0x300 [xfs]
+[ 1209.863728]  ? xfs_alloc_space_available+0x7b/0x120 [xfs]
+[ 1209.865385]  xfs_alloc_fix_freelist+0x3bc/0x490 [xfs]
+[ 1209.866974]  ? __radix_tree_lookup+0x84/0xf0
+[ 1209.868374]  ? xfs_perag_get+0x1a0/0x310 [xfs]
+[ 1209.869798]  ? xfs_perag_get+0x5/0x310 [xfs]
+[ 1209.871288]  xfs_alloc_vextent+0x161/0xda0 [xfs]
+[ 1209.872757]  xfs_bmap_btalloc+0x46c/0x8b0 [xfs]
+[ 1209.874182]  ? save_stack_trace+0x1b/0x20
+[ 1209.875542]  xfs_bmap_alloc+0x17/0x30 [xfs]
+[ 1209.876847]  xfs_bmapi_write+0x74e/0x11d0 [xfs]
+[ 1209.878190]  xfs_iomap_write_allocate+0x199/0x3a0 [xfs]
+[ 1209.879632]  xfs_map_blocks+0x2cc/0x5a0 [xfs]
+[ 1209.880909]  xfs_do_writepage+0x215/0x920 [xfs]
+[ 1209.882255]  ? clear_page_dirty_for_io+0xb4/0x310
+[ 1209.883598]  xfs_vm_writepage+0x3b/0x70 [xfs]
+[ 1209.884841]  pageout.isra.54+0x1a4/0x460
+[ 1209.886210]  shrink_page_list+0xa86/0xcf0
+[ 1209.887441]  shrink_inactive_list+0x1c5/0x660
+[ 1209.888682]  shrink_node_memcg+0x535/0x7f0
+[ 1209.889975]  ? mem_cgroup_iter+0x14d/0x720
+[ 1209.891197]  shrink_node+0xe1/0x310
+[ 1209.892288]  kswapd+0x362/0x9b0
+[ 1209.893308]  kthread+0x10f/0x150
+[ 1209.894383]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
+[ 1209.895703]  ? kthread_create_on_node+0x70/0x70
+[ 1209.896956]  ret_from_fork+0x31/0x40
+----------
+
+  (2) Both GFP_IO and GFP_KERNEL allocations are stuck at
+      too_many_isolated() loop.
+
+----------
+[ 1209.898117] MemAlloc: systemd-journal(526) flags=0x400900 switches=33248 seq=121659 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=52772 uninterruptible
+[ 1209.902154] systemd-journal D11240   526      1 0x00000000
+[ 1209.903642] Call Trace:
+[ 1209.904574]  __schedule+0x336/0xe00
+[ 1209.905734]  schedule+0x3d/0x90
+[ 1209.906817]  schedule_timeout+0x20d/0x510
+[ 1209.908025]  ? prepare_to_wait+0x2b/0xc0
+[ 1209.909268]  ? lock_timer_base+0xa0/0xa0
+[ 1209.910460]  io_schedule_timeout+0x1e/0x50
+[ 1209.911681]  congestion_wait+0x86/0x260
+[ 1209.912853]  ? remove_wait_queue+0x60/0x60
+[ 1209.914115]  shrink_inactive_list+0x5b4/0x660
+[ 1209.915385]  ? __list_lru_count_one.isra.2+0x22/0x80
+[ 1209.916768]  shrink_node_memcg+0x535/0x7f0
+[ 1209.918173]  shrink_node+0xe1/0x310
+[ 1209.919288]  do_try_to_free_pages+0xe1/0x300
+[ 1209.920548]  try_to_free_pages+0x131/0x3f0
+[ 1209.921827]  __alloc_pages_slowpath+0x3ec/0xd95
+[ 1209.923137]  __alloc_pages_nodemask+0x3e4/0x460
+[ 1209.924454]  ? __radix_tree_lookup+0x84/0xf0
+[ 1209.925790]  alloc_pages_current+0x97/0x1b0
+[ 1209.927021]  ? find_get_entry+0x5/0x300
+[ 1209.928189]  __page_cache_alloc+0x15d/0x1a0
+[ 1209.929471]  ? pagecache_get_page+0x2c/0x2b0
+[ 1209.930716]  filemap_fault+0x4df/0x8b0
+[ 1209.931867]  ? filemap_fault+0x373/0x8b0
+[ 1209.933111]  ? xfs_ilock+0x22c/0x360 [xfs]
+[ 1209.934510]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
+[ 1209.935857]  ? down_read_nested+0x7b/0xc0
+[ 1209.937123]  ? xfs_ilock+0x22c/0x360 [xfs]
+[ 1209.938373]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
+[ 1209.939691]  __do_fault+0x1e/0xa0
+[ 1209.940807]  ? _raw_spin_unlock+0x27/0x40
+[ 1209.942002]  __handle_mm_fault+0xbb1/0xf40
+[ 1209.943228]  ? mutex_unlock+0x12/0x20
+[ 1209.944410]  ? devkmsg_read+0x15c/0x330
+[ 1209.945912]  handle_mm_fault+0x16b/0x390
+[ 1209.947297]  ? handle_mm_fault+0x49/0x390
+[ 1209.948868]  __do_page_fault+0x24a/0x530
+[ 1209.950351]  do_page_fault+0x30/0x80
+[ 1209.951615]  page_fault+0x28/0x30
+
+[ 1210.538496] MemAlloc: kworker/3:0(6345) flags=0x4208860 switches=10134 seq=22 gfp=0x1400000(GFP_NOIO) order=0 delay=45953 uninterruptible
+[ 1210.541487] kworker/3:0     D12560  6345      2 0x00000080
+[ 1210.542991] Workqueue: events_freezable_power_ disk_events_workfn
+[ 1210.544577] Call Trace:
+[ 1210.545468]  __schedule+0x336/0xe00
+[ 1210.546606]  schedule+0x3d/0x90
+[ 1210.547616]  schedule_timeout+0x20d/0x510
+[ 1210.548778]  ? prepare_to_wait+0x2b/0xc0
+[ 1210.550013]  ? lock_timer_base+0xa0/0xa0
+[ 1210.551208]  io_schedule_timeout+0x1e/0x50
+[ 1210.552519]  congestion_wait+0x86/0x260
+[ 1210.553650]  ? remove_wait_queue+0x60/0x60
+[ 1210.554900]  shrink_inactive_list+0x5b4/0x660
+[ 1210.556119]  ? __list_lru_count_one.isra.2+0x22/0x80
+[ 1210.557447]  shrink_node_memcg+0x535/0x7f0
+[ 1210.558714]  shrink_node+0xe1/0x310
+[ 1210.559803]  do_try_to_free_pages+0xe1/0x300
+[ 1210.561009]  try_to_free_pages+0x131/0x3f0
+[ 1210.562250]  __alloc_pages_slowpath+0x3ec/0xd95
+[ 1210.563506]  __alloc_pages_nodemask+0x3e4/0x460
+[ 1210.564777]  alloc_pages_current+0x97/0x1b0
+[ 1210.566017]  bio_copy_kern+0xc9/0x180
+[ 1210.567116]  blk_rq_map_kern+0x70/0x140
+[ 1210.568356]  __scsi_execute.isra.22+0x13a/0x1e0
+[ 1210.569839]  scsi_execute_req_flags+0x94/0x100
+[ 1210.571218]  sr_check_events+0xbf/0x2b0 [sr_mod]
+[ 1210.572500]  cdrom_check_events+0x18/0x30 [cdrom]
+[ 1210.573934]  sr_block_check_events+0x2a/0x30 [sr_mod]
+[ 1210.575335]  disk_check_events+0x60/0x170
+[ 1210.576509]  disk_events_workfn+0x1c/0x20
+[ 1210.577744]  process_one_work+0x22b/0x760
+[ 1210.578934]  ? process_one_work+0x194/0x760
+[ 1210.580147]  worker_thread+0x137/0x4b0
+[ 1210.581336]  kthread+0x10f/0x150
+[ 1210.582365]  ? process_one_work+0x760/0x760
+[ 1210.583603]  ? kthread_create_on_node+0x70/0x70
+[ 1210.584961]  ? do_syscall_64+0x6c/0x200
+[ 1210.586343]  ret_from_fork+0x31/0x40
+----------
+
+  (3) Number of stalling threads does not decrease over time and
+      number of out_of_memory() calls does not increase over time.
+
+----------
+[ 1209.781787] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
+[ 1212.195351] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
+[ 1242.551629] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
+[ 1245.149165] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
+[ 1275.319189] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
+[ 1278.241813] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
+----------
+
+This extension also found a lockup situation where memory reclaim activity got stuck
+waiting for memory allocation (and therefore the system hung without invoking the
+OOM killer) from output shown below.
+
+  (1) kswapd cannot make progress waiting for lock.
+
+----------
+[  518.900038] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
+[  518.902095] kswapd0         D10776    69      2 0x00000000
+[  518.903784] Call Trace:
+[  518.904849]  __schedule+0x336/0xe00
+[  518.906118]  schedule+0x3d/0x90
+[  518.907314]  io_schedule+0x16/0x40
+[  518.908622]  __xfs_iflock+0x129/0x140 [xfs]
+[  518.910027]  ? autoremove_wake_function+0x60/0x60
+[  518.911559]  xfs_reclaim_inode+0x162/0x440 [xfs]
+[  518.913068]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
+[  518.914611]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
+[  518.916148]  ? trace_hardirqs_on+0xd/0x10
+[  518.917465]  ? try_to_wake_up+0x59/0x7a0
+[  518.918758]  ? wake_up_process+0x15/0x20
+[  518.920067]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
+[  518.921560]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
+[  518.923114]  super_cache_scan+0x181/0x190
+[  518.924435]  shrink_slab+0x29f/0x6d0
+[  518.925683]  shrink_node+0x2fa/0x310
+[  518.926909]  kswapd+0x362/0x9b0
+[  518.928061]  kthread+0x10f/0x150
+[  518.929218]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
+[  518.930953]  ? kthread_create_on_node+0x70/0x70
+[  518.932380]  ret_from_fork+0x31/0x40
+
+[ 1095.632984] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
+[ 1095.632985] kswapd0         D10776    69      2 0x00000000
+[ 1095.632988] Call Trace:
+[ 1095.632991]  __schedule+0x336/0xe00
+[ 1095.632994]  schedule+0x3d/0x90
+[ 1095.632996]  io_schedule+0x16/0x40
+[ 1095.633017]  __xfs_iflock+0x129/0x140 [xfs]
+[ 1095.633021]  ? autoremove_wake_function+0x60/0x60
+[ 1095.633051]  xfs_reclaim_inode+0x162/0x440 [xfs]
+[ 1095.633072]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
+[ 1095.633106]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
+[ 1095.633114]  ? trace_hardirqs_on+0xd/0x10
+[ 1095.633116]  ? try_to_wake_up+0x59/0x7a0
+[ 1095.633120]  ? wake_up_process+0x15/0x20
+[ 1095.633156]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
+[ 1095.633178]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
+[ 1095.633180]  super_cache_scan+0x181/0x190
+[ 1095.633183]  shrink_slab+0x29f/0x6d0
+[ 1095.633189]  shrink_node+0x2fa/0x310
+[ 1095.633193]  kswapd+0x362/0x9b0
+[ 1095.633200]  kthread+0x10f/0x150
+[ 1095.633201]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
+[ 1095.633202]  ? kthread_create_on_node+0x70/0x70
+[ 1095.633205]  ret_from_fork+0x31/0x40
+----------
+
+  (2) All WQ_MEM_RECLAIM threads shown by show_workqueue_state()
+      cannot make progress waiting for memory allocation.
+
+----------
+[ 1095.633625] MemAlloc: xfs-data/sda1(451) flags=0x4228060 switches=45509 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652073
+[ 1095.633626] xfs-data/sda1   R  running task    12696   451      2 0x00000000
+[ 1095.633663] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
+[ 1095.633665] Call Trace:
+[ 1095.633668]  __schedule+0x336/0xe00
+[ 1095.633671]  schedule+0x3d/0x90
+[ 1095.633672]  schedule_timeout+0x20d/0x510
+[ 1095.633675]  ? lock_timer_base+0xa0/0xa0
+[ 1095.633678]  schedule_timeout_uninterruptible+0x2a/0x30
+[ 1095.633680]  __alloc_pages_slowpath+0x2b5/0xd95
+[ 1095.633687]  __alloc_pages_nodemask+0x3e4/0x460
+[ 1095.633699]  alloc_pages_current+0x97/0x1b0
+[ 1095.633702]  new_slab+0x4cb/0x6b0
+[ 1095.633706]  ___slab_alloc+0x3a3/0x620
+[ 1095.633728]  ? kmem_alloc+0x96/0x120 [xfs]
+[ 1095.633730]  ? ___slab_alloc+0x5c6/0x620
+[ 1095.633732]  ? cpuacct_charge+0x38/0x1e0
+[ 1095.633767]  ? kmem_alloc+0x96/0x120 [xfs]
+[ 1095.633770]  __slab_alloc+0x46/0x7d
+[ 1095.633773]  __kmalloc+0x301/0x3b0
+[ 1095.633802]  kmem_alloc+0x96/0x120 [xfs]
+[ 1095.633804]  ? kfree+0x1fa/0x330
+[ 1095.633842]  xfs_log_commit_cil+0x489/0x710 [xfs]
+[ 1095.633864]  __xfs_trans_commit+0x83/0x260 [xfs]
+[ 1095.633883]  xfs_trans_commit+0x10/0x20 [xfs]
+[ 1095.633901]  __xfs_setfilesize+0xdb/0x240 [xfs]
+[ 1095.633936]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
+[ 1095.633954]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
+[ 1095.633971]  xfs_end_io+0x81/0x110 [xfs]
+[ 1095.633973]  process_one_work+0x22b/0x760
+[ 1095.633975]  ? process_one_work+0x194/0x760
+[ 1095.633997]  rescuer_thread+0x1f2/0x3d0
+[ 1095.634002]  kthread+0x10f/0x150
+[ 1095.634003]  ? worker_thread+0x4b0/0x4b0
+[ 1095.634004]  ? kthread_create_on_node+0x70/0x70
+[ 1095.634007]  ret_from_fork+0x31/0x40
+[ 1095.634013] MemAlloc: xfs-eofblocks/s(456) flags=0x4228860 switches=15435 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=293074
+[ 1095.634014] xfs-eofblocks/s R  running task    12032   456      2 0x00000000
+[ 1095.634037] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
+[ 1095.634038] Call Trace:
+[ 1095.634040]  ? _raw_spin_lock+0x3d/0x80
+[ 1095.634042]  ? vmpressure+0xd0/0x120
+[ 1095.634044]  ? vmpressure+0xd0/0x120
+[ 1095.634047]  ? vmpressure_prio+0x21/0x30
+[ 1095.634049]  ? do_try_to_free_pages+0x70/0x300
+[ 1095.634052]  ? try_to_free_pages+0x131/0x3f0
+[ 1095.634058]  ? __alloc_pages_slowpath+0x3ec/0xd95
+[ 1095.634065]  ? __alloc_pages_nodemask+0x3e4/0x460
+[ 1095.634069]  ? alloc_pages_current+0x97/0x1b0
+[ 1095.634111]  ? xfs_buf_allocate_memory+0x160/0x2a3 [xfs]
+[ 1095.634133]  ? xfs_buf_get_map+0x2be/0x480 [xfs]
+[ 1095.634169]  ? xfs_buf_read_map+0x2c/0x400 [xfs]
+[ 1095.634204]  ? xfs_trans_read_buf_map+0x186/0x830 [xfs]
+[ 1095.634222]  ? xfs_btree_read_buf_block.constprop.34+0x78/0xc0 [xfs]
+[ 1095.634239]  ? xfs_btree_lookup_get_block+0x8a/0x180 [xfs]
+[ 1095.634257]  ? xfs_btree_lookup+0xd0/0x3f0 [xfs]
+[ 1095.634296]  ? kmem_zone_alloc+0x96/0x120 [xfs]
+[ 1095.634299]  ? _raw_spin_unlock+0x27/0x40
+[ 1095.634315]  ? xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]
+[ 1095.634348]  ? xfs_bmap_del_extent+0x1b2/0x1610 [xfs]
+[ 1095.634380]  ? kmem_zone_alloc+0x96/0x120 [xfs]
+[ 1095.634400]  ? __xfs_bunmapi+0x4db/0xda0 [xfs]
+[ 1095.634421]  ? xfs_bunmapi+0x2b/0x40 [xfs]
+[ 1095.634459]  ? xfs_itruncate_extents+0x1df/0x780 [xfs]
+[ 1095.634502]  ? xfs_rename+0xc70/0x1080 [xfs]
+[ 1095.634525]  ? xfs_free_eofblocks+0x1c4/0x230 [xfs]
+[ 1095.634546]  ? xfs_inode_free_eofblocks+0x18d/0x280 [xfs]
+[ 1095.634565]  ? xfs_inode_ag_walk.isra.13+0x2b5/0x620 [xfs]
+[ 1095.634582]  ? xfs_inode_ag_walk.isra.13+0x91/0x620 [xfs]
+[ 1095.634618]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
+[ 1095.634630]  ? radix_tree_next_chunk+0x10b/0x2d0
+[ 1095.634635]  ? radix_tree_gang_lookup_tag+0xd7/0x150
+[ 1095.634672]  ? xfs_perag_get_tag+0x11d/0x370 [xfs]
+[ 1095.634690]  ? xfs_perag_get_tag+0x5/0x370 [xfs]
+[ 1095.634709]  ? xfs_inode_ag_iterator_tag+0x71/0xa0 [xfs]
+[ 1095.634726]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
+[ 1095.634744]  ? __xfs_icache_free_eofblocks+0x3b/0x40 [xfs]
+[ 1095.634759]  ? xfs_eofblocks_worker+0x27/0x40 [xfs]
+[ 1095.634762]  ? process_one_work+0x22b/0x760
+[ 1095.634763]  ? process_one_work+0x194/0x760
+[ 1095.634784]  ? rescuer_thread+0x1f2/0x3d0
+[ 1095.634788]  ? kthread+0x10f/0x150
+[ 1095.634789]  ? worker_thread+0x4b0/0x4b0
+[ 1095.634790]  ? kthread_create_on_node+0x70/0x70
+[ 1095.634793]  ? ret_from_fork+0x31/0x40
+----------
+
+  (3) order-0 GFP_NOIO allocation request cannot make progress
+      waiting for memory allocation.
+
+----------
+[ 1095.631687] MemAlloc: kworker/2:0(27) flags=0x4208860 switches=38727 seq=21 gfp=0x1400000(GFP_NOIO) order=0 delay=652160
+[ 1095.631688] kworker/2:0     R  running task    12680    27      2 0x00000000
+[ 1095.631739] Workqueue: events_freezable_power_ disk_events_workfn
+[ 1095.631740] Call Trace:
+[ 1095.631743]  __schedule+0x336/0xe00
+[ 1095.631746]  preempt_schedule_common+0x1f/0x31
+[ 1095.631747]  _cond_resched+0x1c/0x30
+[ 1095.631749]  shrink_slab+0x339/0x6d0
+[ 1095.631754]  shrink_node+0x2fa/0x310
+[ 1095.631758]  do_try_to_free_pages+0xe1/0x300
+[ 1095.631761]  try_to_free_pages+0x131/0x3f0
+[ 1095.631765]  __alloc_pages_slowpath+0x3ec/0xd95
+[ 1095.631771]  __alloc_pages_nodemask+0x3e4/0x460
+[ 1095.631775]  alloc_pages_current+0x97/0x1b0
+[ 1095.631779]  bio_copy_kern+0xc9/0x180
+[ 1095.631830]  blk_rq_map_kern+0x70/0x140
+[ 1095.631835]  __scsi_execute.isra.22+0x13a/0x1e0
+[ 1095.631838]  scsi_execute_req_flags+0x94/0x100
+[ 1095.631844]  sr_check_events+0xbf/0x2b0 [sr_mod]
+[ 1095.631852]  cdrom_check_events+0x18/0x30 [cdrom]
+[ 1095.631854]  sr_block_check_events+0x2a/0x30 [sr_mod]
+[ 1095.631856]  disk_check_events+0x60/0x170
+[ 1095.631859]  disk_events_workfn+0x1c/0x20
+[ 1095.631862]  process_one_work+0x22b/0x760
+[ 1095.631863]  ? process_one_work+0x194/0x760
+[ 1095.631867]  worker_thread+0x137/0x4b0
+[ 1095.631887]  kthread+0x10f/0x150
+[ 1095.631889]  ? process_one_work+0x760/0x760
+[ 1095.631890]  ? kthread_create_on_node+0x70/0x70
+[ 1095.631893]  ret_from_fork+0x31/0x40
+----------
+
+  (4) Number of stalling threads does not decrease over time while
+      number of out_of_memory() calls increases over time.
+
+----------
+[  518.090012] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=8441307
+[  553.070829] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=10318507
+[  616.394649] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=13908219
+[  642.266252] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=15180673
+[  702.412189] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=18732529
+[  736.787879] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=20565244
+[  800.715759] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=24411576
+[  837.571405] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=26463562
+[  899.021495] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=30144879
+[  936.282709] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=32129234
+[  997.328119] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=35657983
+[ 1033.977265] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=37659912
+[ 1095.630961] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40639677
+[ 1095.821248] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40646791
+----------
+
+This extension also serves as a hook for triggering actions when timeout
+expired. If you want to obtain more information, you can utilize dynamic
+probes using e.g. SystemTap. For example,
+
+  # stap -F -g -e 'probe kernel.function("check_memalloc_stalling_tasks").return { if ($return > 0) panic("MemAlloc stall detected."); }'
+
+will allow you to obtain vmcore by triggering the kernel panic. Since
+variables used by this extension is associated with "struct task_struct",
+you can obtain accurate snapshot using "foreach task" command from crash
+utility.
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 8a266e2..fd31dee 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -79,8 +79,12 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern unsigned int out_of_memory_count;
+extern bool memalloc_maybe_stalling(void);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern unsigned long sysctl_memalloc_task_warning_secs;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6850e47..d26d563 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -480,6 +480,22 @@ struct wake_q_node {
 	struct wake_q_node *next;
 };
 
+struct memalloc_info {
+	/* Is current thread doing (nested) memory allocation? */
+	u8 in_flight;
+	/* Watchdog kernel thread is about to report this task? */
+	bool report;
+	/* Index used for memalloc_in_flight[] counter. */
+	u8 idx;
+	/* For progress monitoring. */
+	unsigned int sequence;
+	/* Started time in jiffies as of in_flight == 1. */
+	unsigned long start;
+	/* Requested order and gfp flags as of in_flight == 1. */
+	unsigned int order;
+	gfp_t gfp;
+};
+
 struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/*
@@ -1041,6 +1057,9 @@ struct task_struct {
 #ifdef CONFIG_LIVEPATCH
 	int patch_state;
 #endif
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	struct memalloc_info		memalloc;
+#endif
 	/* CPU-specific state of this task: */
 	struct thread_struct		thread;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 3be4be7..9d54470 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1667,6 +1667,10 @@ static __latent_entropy struct task_struct *copy_process(
 	p->sequential_io_avg	= 0;
 #endif
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	p->memalloc.sequence = 0;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
 	if (retval)
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 751593e..8f237c0 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -16,6 +16,7 @@
 #include <linux/export.h>
 #include <linux/sysctl.h>
 #include <linux/utsname.h>
+#include <linux/oom.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/debug.h>
 
@@ -203,6 +204,200 @@ static long hung_timeout_jiffies(unsigned long last_checked,
 		MAX_SCHEDULE_TIMEOUT;
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+/*
+ * Zero means infinite timeout - no checking done:
+ */
+unsigned long __read_mostly sysctl_memalloc_task_warning_secs =
+	CONFIG_DEFAULT_MEMALLOC_TASK_TIMEOUT;
+
+/* Filled by is_stalling_task(), used by only khungtaskd kernel thread. */
+static struct memalloc_info memalloc;
+
+/**
+ * is_stalling_task - Check and copy a task's memalloc variable.
+ *
+ * @task:   A task to check.
+ * @expire: Timeout in jiffies.
+ *
+ * Returns true if a task is stalling, false otherwise.
+ */
+static bool is_stalling_task(const struct task_struct *task,
+			     const unsigned long expire)
+{
+	const struct memalloc_info *m = &task->memalloc;
+
+	if (likely(!m->in_flight || !time_after_eq(expire, m->start)))
+		return false;
+	/*
+	 * start_memalloc_timer() guarantees that ->in_flight is updated after
+	 * ->start is stored.
+	 */
+	smp_rmb();
+	memalloc.sequence = m->sequence;
+	memalloc.start = m->start;
+	memalloc.order = m->order;
+	memalloc.gfp = m->gfp;
+	return time_after_eq(expire, memalloc.start);
+}
+
+/*
+ * check_memalloc_stalling_tasks - Check for memory allocation stalls.
+ *
+ * @timeout: Timeout in jiffies.
+ *
+ * Returns number of stalling tasks.
+ *
+ * This function is marked as "noinline" in order to allow inserting dynamic
+ * probes (e.g. printing more information as needed using SystemTap, calling
+ * panic() if this function returned non 0 value).
+ */
+static noinline int check_memalloc_stalling_tasks(unsigned long timeout)
+{
+	enum {
+		MEMALLOC_TYPE_STALLING,       /* Report as stalling task. */
+		MEMALLOC_TYPE_DYING,          /* Report as dying task. */
+		MEMALLOC_TYPE_EXITING,        /* Report as exiting task.*/
+		MEMALLOC_TYPE_OOM_VICTIM,     /* Report as OOM victim. */
+		MEMALLOC_TYPE_UNCONDITIONAL,  /* Report unconditionally. */
+	};
+	char buf[256];
+	struct task_struct *g, *p;
+	unsigned long now;
+	unsigned long expire;
+	unsigned int sigkill_pending = 0;
+	unsigned int exiting_tasks = 0;
+	unsigned int memdie_pending = 0;
+	unsigned int stalling_tasks = 0;
+
+	cond_resched();
+	now = jiffies;
+	/*
+	 * Report tasks that stalled for more than half of timeout duration
+	 * because such tasks might be correlated with tasks that already
+	 * stalled for full timeout duration.
+	 */
+	expire = now - timeout * (HZ / 2);
+	/* Count stalling tasks, dying and victim tasks. */
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		bool report = false;
+
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			report = true;
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			report = true;
+			sigkill_pending++;
+		}
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			report = true;
+			exiting_tasks++;
+		}
+		if (is_stalling_task(p, expire)) {
+			report = true;
+			stalling_tasks++;
+		}
+		if (p->flags & PF_KSWAPD)
+			report = true;
+		p->memalloc.report = report;
+	}
+	rcu_read_unlock();
+	if (!stalling_tasks)
+		return 0;
+	cond_resched();
+	/* Report stalling tasks, dying and victim tasks. */
+	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
+		out_of_memory_count);
+	cond_resched();
+	sigkill_pending = 0;
+	exiting_tasks = 0;
+	memdie_pending = 0;
+	stalling_tasks = 0;
+	rcu_read_lock();
+ restart_report:
+	for_each_process_thread(g, p) {
+		u8 type;
+
+		if (likely(!p->memalloc.report))
+			continue;
+		p->memalloc.report = false;
+		/* Recheck in case state changed meanwhile. */
+		type = 0;
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			type |= (1 << MEMALLOC_TYPE_OOM_VICTIM);
+			memdie_pending++;
+		}
+		if (fatal_signal_pending(p)) {
+			type |= (1 << MEMALLOC_TYPE_DYING);
+			sigkill_pending++;
+		}
+		if ((p->flags & PF_EXITING) && p->state != TASK_DEAD) {
+			type |= (1 << MEMALLOC_TYPE_EXITING);
+			exiting_tasks++;
+		}
+		if (is_stalling_task(p, expire)) {
+			type |= (1 << MEMALLOC_TYPE_STALLING);
+			stalling_tasks++;
+			snprintf(buf, sizeof(buf),
+				 " seq=%u gfp=0x%x(%pGg) order=%u delay=%lu",
+				 memalloc.sequence, memalloc.gfp,
+				 &memalloc.gfp,
+				 memalloc.order, now - memalloc.start);
+		} else {
+			buf[0] = '\0';
+		}
+		if (p->flags & PF_KSWAPD)
+			type |= (1 << MEMALLOC_TYPE_UNCONDITIONAL);
+		if (unlikely(!type))
+			continue;
+		/*
+		 * Victim tasks get pending SIGKILL removed before arriving at
+		 * do_exit(). Therefore, print " exiting" instead for " dying".
+		 */
+		pr_warn("MemAlloc: %s(%u) flags=0x%x switches=%lu%s%s%s%s%s\n",
+			p->comm, p->pid, p->flags, p->nvcsw + p->nivcsw, buf,
+			(p->state & TASK_UNINTERRUPTIBLE) ?
+			" uninterruptible" : "",
+			(type & (1 << MEMALLOC_TYPE_EXITING)) ?
+			" exiting" : "",
+			(type & (1 << MEMALLOC_TYPE_DYING)) ? " dying" : "",
+			(type & (1 << MEMALLOC_TYPE_OOM_VICTIM)) ?
+			" victim" : "");
+		sched_show_task(p);
+		/*
+		 * Since there could be thousands of tasks to report, we always
+		 * call cond_resched() after each report, in order to avoid RCU
+		 * stalls.
+		 *
+		 * Since not yet reported tasks are marked as
+		 * p->memalloc.report == T, this loop can restart even if
+		 * "g" or "p" went away.
+		 *
+		 * TODO: Try to wait for a while (e.g. sleep until usage of
+		 * printk() buffer becomes less than 75%) in order to avoid
+		 * dropping messages.
+		 */
+		if (!rcu_lock_break(g, p))
+			goto restart_report;
+	}
+	rcu_read_unlock();
+	cond_resched();
+	/* Show memory information. (SysRq-m) */
+	show_mem(0, NULL);
+	/* Show workqueue state. */
+	show_workqueue_state();
+	/* Show lock information. (SysRq-d) */
+	debug_show_all_locks();
+	pr_warn("MemAlloc-Info: stalling=%u dying=%u exiting=%u victim=%u oom_count=%u\n",
+		stalling_tasks, sigkill_pending, exiting_tasks, memdie_pending,
+		out_of_memory_count);
+	return stalling_tasks;
+}
+#endif /* CONFIG_DETECT_MEMALLOC_STALL_TASK */
+
 /*
  * Process updating of timeout sysctl
  */
@@ -237,12 +432,28 @@ void reset_hung_task_detector(void)
 static int watchdog(void *dummy)
 {
 	unsigned long hung_last_checked = jiffies;
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	unsigned long stall_last_checked = hung_last_checked;
+#endif
 
 	set_user_nice(current, 0);
 
 	for ( ; ; ) {
 		unsigned long timeout = sysctl_hung_task_timeout_secs;
 		long t = hung_timeout_jiffies(hung_last_checked, timeout);
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+		unsigned long timeout2 = sysctl_memalloc_task_warning_secs;
+		long t2 = hung_timeout_jiffies(stall_last_checked, timeout2);
+
+		if (t2 <= 0) {
+			if (memalloc_maybe_stalling())
+				check_memalloc_stalling_tasks(timeout2);
+			stall_last_checked = jiffies;
+			continue;
+		}
+#else
+		long t2 = t;
+#endif
 
 		if (t <= 0) {
 			if (!atomic_xchg(&reset_hung_task, 0))
@@ -250,7 +461,7 @@ static int watchdog(void *dummy)
 			hung_last_checked = jiffies;
 			continue;
 		}
-		schedule_timeout_interruptible(t);
+		schedule_timeout_interruptible(min(t, t2));
 	}
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index acf0a5a..a8bb0d6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1070,6 +1070,16 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &neg_one,
 	},
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+	{
+		.procname	= "memalloc_task_warning_secs",
+		.data		= &sysctl_memalloc_task_warning_secs,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= proc_dohung_task_timeout_secs,
+		.extra2		= &hung_task_timeout_max,
+	},
+#endif
 #endif
 #ifdef CONFIG_RT_MUTEXES
 	{
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 924f210..f7d2c2a 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -912,6 +912,30 @@ config WQ_WATCHDOG
 	  state.  This can be configured through kernel parameter
 	  "workqueue.watchdog_thresh" and its sysfs counterpart.
 
+config DETECT_MEMALLOC_STALL_TASK
+	bool "Detect tasks stalling inside memory allocator"
+	default n
+	depends on DETECT_HUNG_TASK
+	help
+	  This option emits warning messages and traces when memory
+	  allocation requests are stalling, in order to catch unexplained
+	  hangups/reboots caused by memory allocation stalls.
+
+config DEFAULT_MEMALLOC_TASK_TIMEOUT
+	int "Default timeout for stalling task detection (in seconds)"
+	depends on DETECT_MEMALLOC_STALL_TASK
+	default 60
+	help
+	  This option controls the default timeout (in seconds) used
+	  to determine when a task has become non-responsive and should
+	  be considered stalling inside memory allocator.
+
+	  It can be adjusted at runtime via the kernel.memalloc_task_warning_secs
+	  sysctl or by writing a value to
+	  /proc/sys/kernel/memalloc_task_warning_secs.
+
+	  A timeout of 0 disables the check. The default is 60 seconds.
+
 endmenu # "Debug lockups and hangs"
 
 config PANIC_ON_OOPS
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d083714..3f06926 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -47,6 +47,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+unsigned int out_of_memory_count;
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -982,6 +984,7 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	out_of_memory_count++;
 	if (oom_killer_disabled)
 		return false;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f749b7f..dc248bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3681,8 +3681,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries;
 	int no_progress_loops;
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
+#endif
 	unsigned int cpuset_mems_cookie;
 
 	/*
@@ -3812,6 +3814,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (!can_direct_reclaim)
 		goto nopage;
 
+#ifndef CONFIG_DETECT_MEMALLOC_STALL_TASK
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
@@ -3819,6 +3822,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 			jiffies_to_msecs(jiffies-alloc_start), order);
 		stall_timeout += 10 * HZ;
 	}
+#endif
 
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
@@ -3990,6 +3994,78 @@ static inline void finalise_ac(gfp_t gfp_mask,
 					ac->high_zoneidx, ac->nodemask);
 }
 
+#ifdef CONFIG_DETECT_MEMALLOC_STALL_TASK
+
+static DEFINE_PER_CPU_ALIGNED(int, memalloc_in_flight[2]);
+static u8 memalloc_active_index; /* Either 0 or 1. */
+
+/* Called periodically with sysctl_memalloc_task_warning_secs interval. */
+bool memalloc_maybe_stalling(void)
+{
+	int cpu;
+	int sum = 0;
+	const u8 idx = memalloc_active_index ^ 1;
+
+	for_each_online_cpu(cpu)
+		sum += per_cpu(memalloc_in_flight[idx], cpu);
+	if (sum)
+		return true;
+	memalloc_active_index ^= 1;
+	return false;
+}
+
+static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	/* We don't check for stalls for !__GFP_DIRECT_RECLAIM allocations. */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return;
+	/* Record the beginning of memory allocation request. */
+	if (!m->in_flight) {
+		m->sequence++;
+		m->start = jiffies;
+		m->order = order;
+		m->gfp = gfp_mask;
+		m->idx = memalloc_active_index;
+		/*
+		 * is_stalling_task() depends on ->in_flight being updated
+		 * after ->start is stored.
+		 */
+		smp_wmb();
+		this_cpu_inc(memalloc_in_flight[m->idx]);
+	}
+	m->in_flight++;
+}
+
+static void stop_memalloc_timer(const gfp_t gfp_mask)
+{
+	struct memalloc_info *m = &current->memalloc;
+
+	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !--m->in_flight)
+		this_cpu_dec(memalloc_in_flight[m->idx]);
+}
+
+static void memalloc_counter_fold(int cpu)
+{
+	int counter;
+	u8 idx;
+
+	for (idx = 0; idx < 2; idx++) {
+		counter = per_cpu(memalloc_in_flight[idx], cpu);
+		if (!counter)
+			continue;
+		this_cpu_add(memalloc_in_flight[idx], counter);
+		per_cpu(memalloc_in_flight[idx], cpu) = 0;
+	}
+}
+
+#else
+#define start_memalloc_timer(gfp_mask, order) do { } while (0)
+#define stop_memalloc_timer(gfp_mask) do { } while (0)
+#define memalloc_counter_fold(cpu) do { } while (0)
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -4029,7 +4105,9 @@ struct page *
 	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
 
+	start_memalloc_timer(alloc_mask, order);
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	stop_memalloc_timer(alloc_mask);
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
@@ -6781,6 +6859,12 @@ static int page_alloc_cpu_dead(unsigned int cpu)
 	 * race with what we are doing.
 	 */
 	cpu_vm_stats_fold(cpu);
+
+	/*
+	 * Zero the in-flight counters of the dead processor so that
+	 * memalloc_maybe_stalling() needs to check only online processors.
+	 */
+	memalloc_counter_fold(cpu);
 	return 0;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
