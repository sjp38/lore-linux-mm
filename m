Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC636B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 07:30:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v132so3083170oie.19
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 04:30:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 88si1548116otf.43.2017.10.26.04.30.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 04:30:35 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: don't warn about allocations which stall for too long
Date: Thu, 26 Oct 2017 20:28:59 +0900
Message-Id: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for too
long") was a great step for reducing possibility of silent hang up problem
caused by memory allocation stalls. But this commit reverts it, for it is
possible to trigger OOM lockup and/or soft lockups when many threads
concurrently called warn_alloc() (in order to warn about memory allocation
stalls) due to current implementation of printk(), and it is difficult to
obtain useful information due to limitation of synchronous warning
approach.

Current printk() implementation flushes all pending logs using the context
of a thread which called console_unlock(). printk() should be able to flush
all pending logs eventually unless somebody continues appending to printk()
buffer.

Since warn_alloc() started appending to printk() buffer while waiting for
oom_kill_process() to make forward progress when oom_kill_process() is
processing pending logs, it became possible for warn_alloc() to force
oom_kill_process() loop inside printk(). As a result, warn_alloc()
significantly increased possibility of preventing oom_kill_process() from
making forward progress.

---------- Pseudo code start ----------
Before warn_alloc() was introduced:

  retry:
    if (mutex_trylock(&oom_lock)) {
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_lock)
    }
    goto retry;

After warn_alloc() was introduced:

  retry:
    if (mutex_trylock(&oom_lock)) {
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_lock)
    } else if (waited_for_10seconds()) {
      atomic_inc(&printk_pending_logs);
    }
    goto retry;
---------- Pseudo code end ----------

Although waited_for_10seconds() becomes true once per 10 seconds, unbounded
number of threads can call waited_for_10seconds() at the same time. Also,
since threads doing waited_for_10seconds() keep doing almost busy loop, the
thread doing print_one_log() can use little CPU resource. Therefore, this
situation can be simplified like

---------- Pseudo code start ----------
  retry:
    if (mutex_trylock(&oom_lock)) {
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_lock)
    } else {
      atomic_inc(&printk_pending_logs);
    }
    goto retry;
---------- Pseudo code end ----------

when printk() is called faster than print_one_log() can process a log.

One of possible mitigation would be to introduce a new lock in order to
make sure that no other series of printk() (either oom_kill_process() or
warn_alloc()) can append to printk() buffer when one series of printk()
(either oom_kill_process() or warn_alloc()) is already in progress. Such
serialization will also help obtaining kernel messages in readable form.

---------- Pseudo code start ----------
  retry:
    if (mutex_trylock(&oom_lock)) {
      mutex_lock(&oom_printk_lock);
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_printk_lock);
      mutex_unlock(&oom_lock)
    } else {
      if (mutex_trylock(&oom_printk_lock)) {
        atomic_inc(&printk_pending_logs);
        mutex_unlock(&oom_printk_lock);
      }
    }
    goto retry;
---------- Pseudo code end ----------

But this commit does not go that direction, for we don't want to introduce
a new lock dependency, and we unlikely be able to obtain useful information
even if we serialized oom_kill_process() and warn_alloc().

Synchronous approach is prone to unexpected results (e.g. too late [1], too
frequent [2], overlooked [3]). As far as I know, warn_alloc() never helped
with providing information other than "something is going wrong".
I want to consider asynchronous approach which can obtain information
during stalls with possibly relevant threads (e.g. the owner of oom_lock
and kswapd-like threads) and serve as a trigger for actions (e.g. turn
on/off tracepoints, ask libvirt daemon to take a memory dump of stalling
KVM guest for diagnostic purpose).

This commit temporarily looses ability to report e.g. OOM lockup due to
unable to invoke the OOM killer due to !__GFP_FS allocation request.
But asynchronous approach will be able to detect such situation and emit
warning. Thus, let's remove warn_alloc().

[1] https://bugzilla.kernel.org/show_bug.cgi?id=192981
[2] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com
[3] commit db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolated for ever"))

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
Reported-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>
---
 mm/page_alloc.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97687b3..a4edfba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3856,8 +3856,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries;
 	int no_progress_loops;
-	unsigned long alloc_start = jiffies;
-	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
 	int reserve_flags;
 
@@ -3989,14 +3987,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (!can_direct_reclaim)
 		goto nopage;
 
-	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
-	}
-
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
