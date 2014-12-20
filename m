Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDAB6B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 04:52:29 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2728522pab.26
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 01:52:28 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hv5si17551778pad.40.2014.12.20.01.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 20 Dec 2014 01:52:27 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
	<201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
	<20141219124903.GB18397@dhcp22.suse.cz>
In-Reply-To: <20141219124903.GB18397@dhcp22.suse.cz>
Message-Id: <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
Date: Sat, 20 Dec 2014 18:13:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> On Fri 19-12-14 21:07:53, Tetsuo Handa wrote:
> [...]
> > >From 3c68c66a72f0dbfc66f9799a00fbaa1f0217befb Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Fri, 19 Dec 2014 20:49:06 +0900
> > Subject: [PATCH v2] oom: Don't count on mm-less current process.
> > 
> > out_of_memory() doesn't trigger the OOM killer if the current task is already
> > exiting or it has fatal signals pending, and gives the task access to memory
> > reserves instead. However, doing so is wrong if out_of_memory() is called by
> > an allocation (e.g. from exit_task_work()) after the current task has already
> > released its memory and cleared TIF_MEMDIE at exit_mm(). If we again set
> > TIF_MEMDIE to post-exit_mm() current task, the OOM killer will be blocked by
> > the task sitting in the final schedule() waiting for its parent to reap it.
> > It will trigger an OOM livelock if its parent is unable to reap it due to
> > doing an allocation and waiting for the OOM killer to kill it.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Just a nit, You could start the condition with current->mm because it
> is the simplest check. We do not have to check for signals pending or
> PF_EXITING at all if it is NULL. But this is not a hot path so it
> doesn't matter much. It is just a good practice to start with the
> simplest tests first.
> 
> Please also make sure to add Andrew to CC when sending the patch again
> so that he knows about it and picks it up.
> 
> Thanks!
> 
I see. Here is v3 patch. Andrew, would you please pick this up?

By the way, Michal, I think there is still an unlikely race window at
set_tsk_thread_flag(p, TIF_MEMDIE) in oom_kill_process(). For example,
task1 calls out_of_memory() and select_bad_process() is called from
out_of_memory(). oom_scan_process_thread(task2) is called from
select_bad_process(). oom_scan_process_thread() returns OOM_SCAN_OK
because task2->mm != NULL and task_will_free_mem(task2) == false.
select_bad_process() calls get_task_struct(task2) and returns task2.
Task1 goes to sleep and task2 is woken up. Task2 enters into do_exit()
and gets PF_EXITING at exit_signals() and releases mm at exit_mm().
Task2 goes to sleep and task1 is woken up. Task1 calls
oom_kill_process(task2). oom_kill_process() sets TIF_MEMDIE on task2
because task_will_free_mem(task2) == true due to PF_EXITING already set...
Should we do like

        if (task_will_free_mem(p)) {
		if (p->mm)
	                set_tsk_thread_flag(p, TIF_MEMDIE);
                put_task_struct(p);
                return;
        }

at oom_kill_process() ? Or even if we do so, how to check if task1 went
to sleep between task2->mm and set_tsk_thread_flag(task2, TIF_MEMDIE) ?
This race window is very very unlikely because releasing task2->mm is
expected to release some memory. But if somebody else consumed memory
released by exit_mm(task2), I think there is nothing to protect.
----------------------------------------
>From 3a75c92a03cf17d9505bbb7fc9c81603daac9da0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 20 Dec 2014 17:18:37 +0900
Subject: [PATCH v3] oom: Don't count on mm-less current process.

out_of_memory() doesn't trigger the OOM killer if the current task is already
exiting or it has fatal signals pending, and gives the task access to memory
reserves instead. However, doing so is wrong if out_of_memory() is called by
an allocation (e.g. from exit_task_work()) after the current task has already
released its memory and cleared TIF_MEMDIE at exit_mm(). If we again set
TIF_MEMDIE to post-exit_mm() current task, the OOM killer will be blocked by
the task sitting in the final schedule() waiting for its parent to reap it.
It will trigger an OOM livelock if its parent is unable to reap it due to
doing an allocation and waiting for the OOM killer to kill it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.cz>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..f82dd13 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -643,8 +643,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * But don't select if current has already released its mm and cleared
+	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (current->mm &&
+	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
