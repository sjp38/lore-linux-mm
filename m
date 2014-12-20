Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 60AF56B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 07:22:29 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so2929860pad.29
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 04:22:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hz1si17774907pbb.121.2014.12.20.04.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 20 Dec 2014 04:22:27 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
	<201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
	<20141219124903.GB18397@dhcp22.suse.cz>
	<201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
In-Reply-To: <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
Message-Id: <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
Date: Sat, 20 Dec 2014 20:42:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Tetsuo Handa wrote:
> By the way, Michal, I think there is still an unlikely race window at
> set_tsk_thread_flag(p, TIF_MEMDIE) in oom_kill_process(). For example,
> task1 calls out_of_memory() and select_bad_process() is called from
> out_of_memory(). oom_scan_process_thread(task2) is called from
> select_bad_process(). oom_scan_process_thread() returns OOM_SCAN_OK
> because task2->mm != NULL and task_will_free_mem(task2) == false.
> select_bad_process() calls get_task_struct(task2) and returns task2.
> Task1 goes to sleep and task2 is woken up. Task2 enters into do_exit()
> and gets PF_EXITING at exit_signals() and releases mm at exit_mm().
> Task2 goes to sleep and task1 is woken up. Task1 calls
> oom_kill_process(task2). oom_kill_process() sets TIF_MEMDIE on task2
> because task_will_free_mem(task2) == true due to PF_EXITING already set...
> Should we do like
> 
>         if (task_will_free_mem(p)) {
> 		if (p->mm)
> 	                set_tsk_thread_flag(p, TIF_MEMDIE);
>                 put_task_struct(p);
>                 return;
>         }
> 
> at oom_kill_process() ? Or even if we do so, how to check if task1 went
> to sleep between task2->mm and set_tsk_thread_flag(task2, TIF_MEMDIE) ?
> This race window is very very unlikely because releasing task2->mm is
> expected to release some memory. But if somebody else consumed memory
> released by exit_mm(task2), I think there is nothing to protect.
Well, this could happen if task2 is one of threads in a multi-threaded
process like Java where exit_mm(task2) decrements refcount than releases
memory. Below is a patch. Michal, please check.
----------------------------------------
>From a2ebb5b873ec5af45e0bea9ea6da2a93c0f06c35 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 20 Dec 2014 20:05:14 +0900
Subject: [PATCH] oom: Close race of setting TIF_MEMDIE to mm-less process.

exit_mm() and oom_kill_process() could race with regard to handling of
TIF_MEMDIE flag if sequence described below occurred.

P1 calls out_of_memory(). out_of_memory() calls select_bad_process().
select_bad_process() calls oom_scan_process_thread(P2). If P2->mm != NULL
and task_will_free_mem(P2) == false, oom_scan_process_thread(P2) returns
OOM_SCAN_OK. And if P2 is chosen as a victim task, select_bad_process()
returns P2 after calling get_task_struct(P2). Then, P1 goes to sleep and
P2 is woken up. P2 enters into do_exit() and gets PF_EXITING at exit_signals()
and releases mm at exit_mm(). Then, P2 goes to sleep and P1 is woken up.
P1 calls oom_kill_process(P2). oom_kill_process() sets TIF_MEMDIE on P2
because task_will_free_mem(P2) == true due to PF_EXITING already set.
Afterward, oom_scan_process_thread(P2) will return OOM_SCAN_ABORT because
test_tsk_thread_flag(P2, TIF_MEMDIE) is checked before P2->mm is checked.

If TIF_MEMDIE was again set to P2, the OOM killer will be blocked by P2
sitting in the final schedule() waiting for P2's parent to reap P2.
It will trigger an OOM livelock if P2's parent is unable to reap P2 due to
doing an allocation and waiting for the OOM killer to kill P2.

To close this race window, clear TIF_MEMDIE if P2->mm == NULL after
set_tsk_thread_flag(P2, TIF_MEMDIE) is done.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 kernel/exit.c | 1 +
 mm/oom_kill.c | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/kernel/exit.c b/kernel/exit.c
index 1ea4369..46d72e6 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -435,6 +435,7 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
+	smp_wmb(); /* Avoid race with oom_kill_process(). */
 	clear_thread_flag(TIF_MEMDIE);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f82dd13..c8ae445 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -440,6 +440,9 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	if (task_will_free_mem(p)) {
 		set_tsk_thread_flag(p, TIF_MEMDIE);
+		smp_rmb(); /* Avoid race with exit_mm(). */
+		if (unlikely(!p->mm))
+			clear_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
 		return;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
