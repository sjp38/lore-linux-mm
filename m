Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C21436B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 11:54:21 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u201so137063104oie.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:54:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 194si7199443iou.63.2016.06.24.08.54.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 08:54:20 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear TIF_MEMDIE
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160624123953.GC20203@dhcp22.suse.cz>
In-Reply-To: <20160624123953.GC20203@dhcp22.suse.cz>
Message-Id: <201606250054.AIF67056.OOSLVtMOJFFFQH@I-love.SAKURA.ne.jp>
Date: Sat, 25 Jun 2016 00:54:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> On Fri 24-06-16 20:02:01, Tetsuo Handa wrote:
> > Currently, the OOM reaper calls exit_oom_victim() on remote TIF_MEMDIE
> > thread after an OOM reap attempt was made. This behavior is intended
> > for allowing oom_scan_process_thread() to select next OOM victim by
> > making atomic_read(&task->signal->oom_victims) == 0.
> > 
> > But since threads can be blocked for unbounded period at __mmput() from
> > mmput() from exit_mm() from do_exit(), we can't risk the OOM reaper
> > being blocked for unbounded period waiting for TIF_MEMDIE threads.
> > Therefore, when we hit a situation that a TIF_MEMDIE thread which is
> > the only thread of that thread group reached tsk->mm = NULL line in
> > exit_mm() from do_exit() before __oom_reap_task() finds a mm via
> > find_lock_task_mm(), oom_reap_task() does not wait for the TIF_MEMDIE
> > thread to return from __mmput() and instead calls exit_oom_victim().
> > 
> > Patch "mm, oom: hide mm which is shared with kthread or global init"
> > tried to avoid OOM livelock by setting MMF_OOM_REAPED, but it is racy
> > because setting MMF_OOM_REAPED will not help when find_lock_task_mm()
> > in oom_scan_process_thread() failed.
> 
> I haven't thought that through yet (I will wait for the monday fresh
> brain) but wouldn't the following be sufficient?
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4c21f744daa6..72360d7284a6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -295,7 +295,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
>  				ret = OOM_SCAN_CONTINUE;
>  			task_unlock(p);
> -		}
> +		} else if (task->state == EXIT_ZOMBIE)
> +			ret = OOM_SCAN_CONTINUE;

I think EXIT_ZOMBIE is too late, for it is exit_notify() stage from do_exit()
which sets EXIT_ZOMBIE state.

The stage my patch is trying to rescue is __mmput() from mmput() from
exit_mm() from do_exit(). It is something like doing

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..f1f892e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -289,11 +289,11 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
 		struct task_struct *p = find_lock_task_mm(task);
-		enum oom_scan_t ret = OOM_SCAN_ABORT;
+		enum oom_scan_t ret = OOM_SCAN_CONTINUE;
 
 		if (p) {
-			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
-				ret = OOM_SCAN_CONTINUE;
+			if (!test_bit(MMF_OOM_REAPED, &p->mm->flags))
+				ret = OOM_SCAN_ABORT;
 			task_unlock(p);
 		}
 
----------

which is effectively nearly equivalent with doing

----------
diff --git a/kernel/exit.c b/kernel/exit.c
index 84ae830..ea188a7 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -509,9 +509,9 @@ static void exit_mm(struct task_struct *tsk)
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
-	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim(tsk);
+	mmput(mm);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
----------

because we don't want to risk the OOM killer wait forever when __mmput() from
mmput() from exit_mm() from do_exit() is blocked at memory allocation.

If we had some timer or timeout, we can call

 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim(tsk);

when __mmput() from mmput() from exit_mm() from do_exit() is blocked for
too long. But since we don't put !can_oom_reap TIF_MEMDIE thread under the
OOM reaper's supervision, we need to do something equivalent to calling
exit_oom_victim(tsk) early, at the cost of increasing possibility of
needlessly selecting next OOM victim.

>  
>  		return ret;
>  	}
> @@ -592,14 +593,7 @@ static void oom_reap_task(struct task_struct *tsk)
>  		debug_show_all_locks();
>  	}
>  
> -	/*
> -	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> -	 * reasonably reclaimable memory anymore or it is not a good candidate
> -	 * for the oom victim right now because it cannot release its memory
> -	 * itself nor by the oom reaper.
> -	 */
>  	tsk->oom_reaper_list = NULL;
> -	exit_oom_victim(tsk);
>  
>  	/* Drop a reference taken by wake_oom_reaper */
>  	put_task_struct(tsk);
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
