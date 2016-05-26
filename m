Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 067AA6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 07:48:06 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id g6so122119236obn.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 04:48:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k71si3550795oih.144.2016.05.26.04.48.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 04:48:04 -0700 (PDT)
Subject: [PATCH] mm,oom: Hold oom_victims counter while OOM reaping.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201605262047.JAB39598.OFOtQJVSFFOLMH@I-love.SAKURA.ne.jp>
Date: Thu, 26 May 2016 20:47:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

Continued from http://lkml.kernel.org/r/201605252330.IAC82384.OOSQHVtFFFLOMJ@I-love.SAKURA.ne.jp :
> > I do not think we want to wait inside the oom_lock as it is a global
> > lock shared by all OOM killer contexts. Another option would be to use
> > the oom_lock inside __oom_reap_task. It is not super cool either because
> > now we have a dependency on the lock but looks like reasonably easy
> > solution.
> 
> It would be nice if we can wait until memory reclaimed from the OOM victim's
> mm is queued to freelist for allocation. But I don't have idea other than
> oomkiller_holdoff_timer.
> 
> I think this problem should be discussed another day in a new thread.
> 

Can we use per "struct signal_struct" oom_victims instead of global oom_lock?

Or, don't we want to allow the OOM killer wait for a while (with expectation
that memory becomes available shortly) before calling panic() ?

I booted with init=/bin/sh and tested like "while :; do ./oleg's-test; done".

---------- oleg's-test.c ----------
#include <stdlib.h>
#include <string.h>

int main(void)
{
	for (;;) {
		void *p = malloc(1024 * 1024);
		memset(p, 0, 1024 * 1024);
	}
}
---------- oleg's-test.c ----------

By applying this patch (shown below), number of OOM kill events until
panic() caused by hitting this race window seems to be increased (i.e.
possibility of needlessly selecting next OOM victim seems to be reduced).

  Number of OOM kill events until panic():

                next-20160526    next-20160526 + patch
     1st trial:             1                        6
     2nd trial:             4                       25

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160526.txt.xz .
----------
[    0.000000] Linux version 4.6.0-next-20160526 (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC) ) #430 SMP PREEMPT Thu May 26 19:52:56 JST 2016
[   24.555609] Killed process 463 (oleg's-test) total-vm:896220kB, anon-rss:840192kB, file-rss:4kB, shmem-rss:0kB
[    0.000000] Linux version 4.6.0-next-20160526+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC) ) #429 SMP PREEMPT Thu May 26 19:43:06 JST 2016
[   24.475525] Killed process 464 (oleg's-test) total-vm:895192kB, anon-rss:830840kB, file-rss:8kB, shmem-rss:0kB
[   25.720562] Killed process 466 (oleg's-test) total-vm:897248kB, anon-rss:838872kB, file-rss:0kB, shmem-rss:0kB
[   26.816009] Killed process 467 (oleg's-test) total-vm:896220kB, anon-rss:838948kB, file-rss:52kB, shmem-rss:0kB
[   27.894932] Killed process 468 (oleg's-test) total-vm:896220kB, anon-rss:840528kB, file-rss:8kB, shmem-rss:0kB
[   29.006985] Killed process 469 (oleg's-test) total-vm:896220kB, anon-rss:840516kB, file-rss:28kB, shmem-rss:0kB
[   30.428075] Killed process 470 (oleg's-test) total-vm:897248kB, anon-rss:840200kB, file-rss:24kB, shmem-rss:0kB
[    0.000000] Linux version 4.6.0-next-20160526 (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC) ) #430 SMP PREEMPT Thu May 26 19:52:56 JST 2016
[   23.470481] Killed process 463 (oleg's-test) total-vm:895192kB, anon-rss:839884kB, file-rss:0kB, shmem-rss:0kB
[   24.942030] Killed process 464 (oleg's-test) total-vm:896220kB, anon-rss:840440kB, file-rss:4kB, shmem-rss:0kB
[   26.346044] Killed process 465 (oleg's-test) total-vm:896220kB, anon-rss:840604kB, file-rss:8kB, shmem-rss:0kB
[   27.751910] Killed process 466 (oleg's-test) total-vm:897248kB, anon-rss:840452kB, file-rss:8kB, shmem-rss:0kB
[    0.000000] Linux version 4.6.0-next-20160526+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC) ) #429 SMP PREEMPT Thu May 26 19:43:06 JST 2016
[   22.355416] Killed process 462 (oleg's-test) total-vm:895192kB, anon-rss:840452kB, file-rss:0kB, shmem-rss:0kB
[   25.309877] Killed process 463 (oleg's-test) total-vm:896220kB, anon-rss:840184kB, file-rss:12kB, shmem-rss:0kB
[   26.405032] Killed process 464 (oleg's-test) total-vm:896220kB, anon-rss:839824kB, file-rss:0kB, shmem-rss:0kB
[   27.797315] Killed process 465 (oleg's-test) total-vm:896220kB, anon-rss:840508kB, file-rss:28kB, shmem-rss:0kB
[   28.867265] Killed process 466 (oleg's-test) total-vm:896220kB, anon-rss:839748kB, file-rss:20kB, shmem-rss:0kB
[   30.277844] Killed process 467 (oleg's-test) total-vm:897248kB, anon-rss:840280kB, file-rss:20kB, shmem-rss:0kB
[   31.685334] Killed process 468 (oleg's-test) total-vm:897248kB, anon-rss:839488kB, file-rss:52kB, shmem-rss:0kB
[   33.098171] Killed process 469 (oleg's-test) total-vm:897248kB, anon-rss:838792kB, file-rss:20kB, shmem-rss:0kB
[   34.188245] Killed process 470 (oleg's-test) total-vm:896220kB, anon-rss:839904kB, file-rss:0kB, shmem-rss:0kB
[   35.245294] Killed process 471 (oleg's-test) total-vm:896220kB, anon-rss:838212kB, file-rss:28kB, shmem-rss:0kB
[   36.296437] Killed process 472 (oleg's-test) total-vm:896220kB, anon-rss:838252kB, file-rss:16kB, shmem-rss:0kB
[   37.668111] Killed process 473 (oleg's-test) total-vm:896220kB, anon-rss:838536kB, file-rss:60kB, shmem-rss:0kB
[   39.038473] Killed process 474 (oleg's-test) total-vm:896220kB, anon-rss:838544kB, file-rss:8kB, shmem-rss:0kB
[   40.435541] Killed process 475 (oleg's-test) total-vm:896220kB, anon-rss:839756kB, file-rss:0kB, shmem-rss:0kB
[   41.500513] Killed process 476 (oleg's-test) total-vm:896220kB, anon-rss:839908kB, file-rss:0kB, shmem-rss:0kB
[   42.915002] Killed process 477 (oleg's-test) total-vm:896220kB, anon-rss:839768kB, file-rss:0kB, shmem-rss:0kB
[   43.974876] Killed process 478 (oleg's-test) total-vm:896220kB, anon-rss:838912kB, file-rss:24kB, shmem-rss:0kB
[   45.373478] Killed process 479 (oleg's-test) total-vm:896220kB, anon-rss:839732kB, file-rss:0kB, shmem-rss:0kB
[   46.504031] Killed process 480 (oleg's-test) total-vm:897248kB, anon-rss:840064kB, file-rss:20kB, shmem-rss:0kB
[   47.601467] Killed process 481 (oleg's-test) total-vm:896220kB, anon-rss:840076kB, file-rss:60kB, shmem-rss:0kB
[   48.674246] Killed process 482 (oleg's-test) total-vm:897248kB, anon-rss:838908kB, file-rss:24kB, shmem-rss:0kB
[   49.894287] Killed process 483 (oleg's-test) total-vm:897248kB, anon-rss:839868kB, file-rss:8kB, shmem-rss:0kB
[   50.953256] Killed process 484 (oleg's-test) total-vm:896220kB, anon-rss:838280kB, file-rss:4kB, shmem-rss:0kB
[   52.014750] Killed process 485 (oleg's-test) total-vm:896220kB, anon-rss:838544kB, file-rss:72kB, shmem-rss:0kB
[   53.094042] Killed process 486 (oleg's-test) total-vm:896220kB, anon-rss:840576kB, file-rss:8kB, shmem-rss:0kB
----------

----------------------------------------
>From dd2f4b63f68c02e2c896ee17b5797e6e1559a25d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 26 May 2016 19:33:08 +0900
Subject: [PATCH] mm,oom: Hold oom_victims counter while OOM reaping.

There has been a race window which allows the OOM killer needlessly select
next OOM victim because oom_scan_process_thread() was checking TIF_MEMDIE
set on "struct task_struct" which can be cleared before all users release
the OOM victim's mm.

And, since __oom_reap_task() holds a reference of a TIF_MEMDIE thread's mm,
the OOM reaper widened this race window due to sequence shown below.

   The OOM reaper         A TIF_MEMDIE thread   Somebody waiting for memory
   in __oom_reap_task()   in exit_mm()          in oom_scan_process_thread()

                                                  tsk->signal->oom_victims > 0.
     atomic_inc_not_zero() succeeds.
                            tsk->mm = NULL;
                            mmput()
                              atomic_dec_and_test() returns false.
                            exit_oom_victim()
                              Clears TIF_MEMDIE.
                              Decrement tsk->signal->oom_victims.
                                                  tsk->signal->oom_victims == 0.
                                                  Select next OOM victim.
                                                  Kill the next OOM victim.
     unmap_page_range() releases memory.
     mmput_async()
       atomic_dec_and_test() returns true.

But commit f44666b04605d1c7 ("mm,oom: speed up select_bad_process() loop")
unexpectedly changed the situation to allow the OOM killer wait for a while
because oom_scan_process_thread() is now checking oom_victim_count of an
OOM-killed thread's "struct signal_struct" which remains available until
TASK_DEAD state.

Therefore, by incrementing oom_victim_count before incrementing mm_users
and decrementing oom_victim_count after decrementing mm_users, we can
narrow this race window to some degree.

The OOM killer will not be blocked indefinitely because the OOM reaper
does not do operations that block indefinitely.

Temporarily having an elevated oom_victim_count does not matter.
out_of_memory() will not be called if the OOM situation was solved before
the OOM reaper calls unmap_page_range(). Otherwise, out_of_memory() will
select next OOM victim after the OOM reaper finished (or gave up) reaping.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5bb2f76..de410ce 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -527,8 +527,10 @@ static void oom_reap_task(struct task_struct *tsk)
 	int attempts = 0;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
+	atomic_inc(&tsk->signal->oom_victims);
 	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
 		schedule_timeout_idle(HZ/10);
+	atomic_dec(&tsk->signal->oom_victims);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
