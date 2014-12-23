Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 160F36B006C
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 07:52:32 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so7908660pad.1
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:52:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id vy7si29117122pbc.187.2014.12.23.04.52.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 04:52:30 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141222202511.GA9485@dhcp22.suse.cz>
	<201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
	<20141223095159.GA28549@dhcp22.suse.cz>
	<201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
	<201412232057.CID73463.FJFOtFLSOOVHQM@I-love.SAKURA.ne.jp>
In-Reply-To: <201412232057.CID73463.FJFOtFLSOOVHQM@I-love.SAKURA.ne.jp>
Message-Id: <201412232112.ABE82336.JOFLtFVHQMOFOS@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 21:12:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > If such a delay is theoretically impossible, I'm OK with your patch.
> > 
> 
> Oops, I forgot to mention that task_unlock(p) should be called before
> put_task_struct(p), in case p->usage == 1 at put_task_struct(p).
> 
After all, something like below?
----------------------------------------
>From 63e9317553688944e27b6054ccc059b82064605e Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 23 Dec 2014 21:04:43 +0900
Subject: [PATCH] oom: Make sure that TIF_MEMDIE is set under task_lock

OOM killer tries to exclude tasks which do not have mm_struct associated
because killing such a task wouldn't help much. The OOM victim gets
TIF_MEMDIE set to disable OOM killer while the current victim releases
the memory and then enables the OOM killer again by dropping the flag.

oom_kill_process is currently prone to a race condition when the OOM
victim is already exiting and TIF_MEMDIE is set after it the task
releases its address space. This might theoretically lead to OOM
livelock if the OOM victim blocks on an allocation later during exiting
because it wouldn't kill any other process and the exiting one won't be
able to exit. The situation is highly unlikely because the OOM victim is
expected to release some memory which should help to sort out OOM
situation.

Fix this by checking task->mm and setting TIF_MEMDIE flag under task_lock
which will serialize the OOM killer with exit_mm which sets task->mm to
NULL. Also, reverse the order of sending SIGKILL and setting TIF_MEMDIE
so that preemption will not allow the victim task to abuse TIF_MEMDIE.

Setting the flag for current is not necessary because check and set is
not racy.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..91079ec 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -438,11 +438,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (task_will_free_mem(p)) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
-		put_task_struct(p);
-		return;
-	}
+	if (task_will_free_mem(victim))
+		goto set_memdie_flag;
 
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
@@ -522,8 +519,12 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+ set_memdie_flag:
+	task_lock(victim);
+	if (victim->mm)
+		set_tsk_thread_flag(victim, TIF_MEMDIE);
+	task_unlock(victim);
 	put_task_struct(victim);
 }
 #undef K
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
