Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBC326B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 07:25:06 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id dh6so168202698obb.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:25:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t47si3270068otd.16.2016.05.27.04.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 04:25:05 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race with exiting task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464271493-20008-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464271493-20008-1-git-send-email-mhocko@kernel.org>
Message-Id: <201605271924.JHJ51087.JFOLSVOFtHFQMO@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 19:24:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, linux-mm@kvack.org, mhocko@suse.com

Continued from http://lkml.kernel.org/r/20160526115759.GB23675@dhcp22.suse.cz :
> The problem with signal_struct is that we will not help if the task gets
> unhashed from the task list which usually happens quite early after
> exit_mm. The oom_lock will keep other OOM killer activity away until we
> reap the address space and free up the memory so it would cover that
> case. So I think the oom_lock is a more robust solution. I plan to post
> the patch with the full changelog soon I just wanted to finish the other
> pile before.

Excuse me, I didn't understand it.
A task is unhashed at __unhash_process() from __exit_signal() from
release_task() from exit_notify() which is called from do_exit() after
exit_task_work(), isn't it? It seems to me that it happens quite late
after exit_mm(), and signal_struct will help.

Michal Hocko wrote:
> Hi,
> I haven't marked this for stable because the race is quite unlikely I
> believe. I have noted the original commit, though, for those who might
> want to backport it and consider this follow up fix as well.
> 
> I guess this would be good to go in the current merge window, unless I
> have missed something subtle. It would be great if Tetsuo could try to
> reproduce and confirm this really solves his issue.

I haven't tried this patch. But you need below fix if you use oom_lock.

  mm/oom_kill.c: In function ‘__oom_reap_task’:
  mm/oom_kill.c:537:13: warning: ‘mm’ may be used uninitialized in this function [-Wmaybe-uninitialized]
    mmput_async(mm);

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890..c2d3b05 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -527,14 +527,14 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * to release its memory.
 	 */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
-unlock_oom:
-	mutex_unlock(&oom_lock);
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
 	 * different context because we shouldn't risk we get stuck there and
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
+unlock_oom:
+	mutex_unlock(&oom_lock);
 	return ret;
 }
----------

While it is true that commit ec8d7c14ea14922f ("mm, oom_reaper: do not mmput
synchronously from the oom reaper context") avoids locking up the OOM reaper,
the OOM reaper can prematurely clear TIF_MEMDIE due to deferring synchronous
exit_aio() etc. in __mmput() by TIF_MEMDIE thread's mmput() till asynchronous
exit_aio() etc. in __mmput() by some workqueue (which is not guaranteed to
run shortly) via the OOM reaper's mmput_async(). This is nearly changing
exit_mm() from

        /* more a memory barrier than a real lock */
        task_lock(tsk);
        tsk->mm = NULL;
        up_read(&mm->mmap_sem);
        enter_lazy_tlb(mm, current);
        task_unlock(tsk);
        mm_update_next_owner(mm);
        mmput(mm);
        if (test_thread_flag(TIF_MEMDIE))
                exit_oom_victim(tsk);

to

        /* more a memory barrier than a real lock */
        task_lock(tsk);
        tsk->mm = NULL;
        up_read(&mm->mmap_sem);
        enter_lazy_tlb(mm, current);
        task_unlock(tsk);
        mm_update_next_owner(mm);
        if (test_thread_flag(TIF_MEMDIE))
                exit_oom_victim(tsk);
        mmput(mm);

which is undesirable from the point of view of avoid selecting next
OOM victim needlessly because mmput_async() can insert unpredictable
delay between

        if (test_thread_flag(TIF_MEMDIE))
                exit_oom_victim(tsk);

and

        mmput(mm);

which waits for workqueue to be processed. The problem is that
we do this because there is no trigger for giving up (e.g. timeout)
even if synchronous mmput() might be able to release a lot of memory.

Do we really want to let the OOM reaper try __oom_reap_task() as soon
as calling mark_oom_victim()? Since majority of OOM-killer events can
solve the OOM situation without waking up the OOM reaper, from the point
of view of avoid selecting next OOM victim needlessly, it might be
desirable to defer calling __oom_reap_task() for a while to wait for
synchronous mmput().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
