Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE0406B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:49:08 -0400 (EDT)
Received: by mail-io0-f179.google.com with SMTP id m184so94019369iof.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 03:49:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w136si9822729iod.131.2016.03.17.03.49.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 03:49:07 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160222094105.GD17938@dhcp22.suse.cz>
	<201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
	<20160315114300.GC6108@dhcp22.suse.cz>
	<20160315115001.GE6108@dhcp22.suse.cz>
	<201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
In-Reply-To: <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
Message-Id: <201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
Date: Thu, 17 Mar 2016 19:49:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Tetsuo Handa wrote:
> If we can tolerate lack of process name and its pid when reporting
> success/failure (or we pass them via mm_struct or walk the process list or
> whatever else), I think we can do something like below patch (most revert of
> "oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space").
>
>  	if (attempts > MAX_OOM_REAP_RETRIES) {
> -		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> -				task_pid_nr(tsk), tsk->comm);
> +		pr_info("oom_reaper: unable to reap memory\n");
>  		debug_show_all_locks();
>  	}
>

Since possible cause of unable to reap memory for oom_reap_vmas() is limited to

  Somebody was waiting at down_write(&mm->mmap_sem)
  (where converting to down_write_killable(&mm->mmap_sem) helps).

or

  Somebody was waiting on unkillable lock between
  down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
  (where we will need to convert such locks killable).

or

  Somebody was doing !__GFP_FS && !__GFP_NOFAIL allocation between
  down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem), and unable
  to call out_of_memory() in order to acquire TIF_MEMDIE (where setting
  TIF_MEMDIE to all threads using that mm by oom_kill_process() helps).

or

  Somebody was doing __GFP_FS || __GFP_NOFAIL allocation between
  down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem), but unable
  to call out_of_memory() for more than one second due to oom_lock
  contention and/or scheduling priority (where setting TIF_MEMDIE
  to all threads using that mm by oom_kill_process() helps).

, we want to check traces of threads using that mm rather than locks
held by all threads. In addition to that, CONFIG_PROVE_LOCKING is not
enabled in most production systems.

I think below patch is more helpful than debug_show_all_locks().
(Though kmallocwd patch will report "unable to reap mm" case and
"unable to leave too_many_isolated() loop" case and any other
not-yet-identified cases which stall memory allocation.)

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2199c71..affbb79 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -502,8 +502,26 @@ static void oom_reap_vmas(struct mm_struct *mm)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
+		struct task_struct *p;
+		struct task_struct *t;
+
 		pr_info("oom_reaper: unable to reap memory\n");
-		debug_show_all_locks();
+		rcu_read_lock();
+		for_each_process_thread(p, t) {
+			if (likely(t->mm != mm))
+				continue;
+			pr_info("oom_reaper: %s(%u) flags=0x%x%s%s%s%s\n",
+				t->comm, t->pid, t->flags,
+				(t->state & TASK_UNINTERRUPTIBLE) ?
+				" uninterruptible" : "",
+				(t->flags & PF_EXITING) ? " exiting" : "",
+				fatal_signal_pending(t) ? " dying" : "",
+				test_tsk_thread_flag(t, TIF_MEMDIE) ?
+				" victim" : "");
+			sched_show_task(t);
+			debug_show_held_locks(t);
+		}
+		rcu_read_unlock();
 	}
 
 	/* Drop a reference taken by wake_oom_reaper */
----------

Well, I think we can define CONFIG_OOM_REAPER which defaults to y
and depends on CONFIG_MMU, rather than scatter around CONFIG_MMU.
That will help catching build failure on CONFIG_MMU=n case...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
