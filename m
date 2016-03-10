Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id DFECF6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:17:38 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id fz5so77190914obc.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 03:17:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ct2si2251878oec.4.2016.03.10.03.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Mar 2016 03:17:37 -0800 (PST)
Subject: Re: [PATCH 2/2]oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
	<201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
	<20160309224829.GA5716@cmpxchg.org>
	<20160309150853.2658e3bc75907e404cf3ca33@linux-foundation.org>
	<20160310004500.GA7374@cmpxchg.org>
In-Reply-To: <20160310004500.GA7374@cmpxchg.org>
Message-Id: <201603102017.ECB12953.HLFJQFVOtMFSOO@I-love.SAKURA.ne.jp>
Date: Thu, 10 Mar 2016 20:17:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: mhocko@kernel.org, linux-mm@kvack.org, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.com

Johannes Weiner wrote:
> On Wed, Mar 09, 2016 at 03:08:53PM -0800, Andrew Morton wrote:
> > On Wed, 9 Mar 2016 17:48:29 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > However, I disagree with your changelog.
> > 
> > What text would you prefer?
> 
> I'd just keep the one you had initially. Or better, this modified
> version:
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that task regardless of the score. The problem is that
> if that task got stuck waiting for some state the allocation site is
> holding, the OOM reaper can not move on to the next best victim.
> 

There is no guarantee that the OOM reaper is waken up.
There are shortcuts which I don't like.

> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer. We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill.
> This is testing pure noise. Remove it.
> 

My concern is what an optimistic idea it is to wait for task_will_free_mem() or
TIF_MEMDIE task forever blindly
( http://lkml.kernel.org/r/201602232224.FEJ69269.LMVJOFFOQSHtFO@I-love.SAKURA.ne.jp ).
We have

  do_exit() {
    exit_signals(); /* sets PF_EXITING */
    /* (1) start */
    exit_mm() {
      mm_release() {
        exit_robust_list() {
          get_user() {
            __do_page_fault() {
              /* (1) end */
              down_read(&current->mm->mmap_sem);
              handle_mm_fault() {
                kmalloc(GFP_KERNEL) {
                  out_of_memory() {
                    if (current->mm &&
                        (fatal_signal_pending(current) || task_will_free_mem(current))) {
                      mark_oom_victim(current); /* sets TIF_MEMDIE */
                      return true;
                    }
                  }
                }
              }
              up_read(&current->mm->mmap_sem);
              /* (2) start */
            }
          }
        }
      }
      /* (2) end */
      down_read(&current->mm->mmap_sem);
      up_read(&current->mm->mmap_sem);
      current->mm = NULL;
      exit_oom_victim();
    }
  }

sequence. We will hit silent OOM livelock if somebody sharing the mm does
down_write_killable(&current->mm->mmap_sem) and kmalloc(GFP_KERNEL) for mmap() etc. at (1) or (2)
due to failing to send SIGKILL to somebody doing/done down_write_killable(&current->mm->mmap_sem)
and returning OOM_SCAN_ABORT without testing whether down_read(&victim->mm->mmap_sem) will succeed.
Since the OOM reaper is not invoked when shortcut is used, nobody can unlock.

Doing

-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
+	if (task_will_free_mem(task) && !is_sysrq_oom(oc) && can_lock_mm_for_read(task))
		return OOM_SCAN_ABORT;

and

	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
+		if (!is_sysrq_oom(oc) && can_lock_mm_for_read(task))
			return OOM_SCAN_ABORT;
	}

is a too fast decision because can_lock_mm_for_read(task) might become true
if if we waited for a moment. Doing

-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
+	if (task_will_free_mem(task) && !is_sysrq_oom(oc) && we_havent_waited_enough_period(task))
		return OOM_SCAN_ABORT;

and

	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
+		if (!is_sysrq_oom(oc) && we_havent_waited_enough_period(task))
			return OOM_SCAN_ABORT;
	}

is a timeout based unlocking which Michal does not like. Doing

-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
+	if (task_will_free_mem(task) && !is_sysrq_oom(oc) && should_oom_scan_abort(task))
		return OOM_SCAN_ABORT;

and

	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
+		if (!is_sysrq_oom(oc) && should_oom_scan_abort(task))
			return OOM_SCAN_ABORT;
	}

is a counter based unlocking which I don't know what Michal thinks.

This situation is similar to when to declare OOM in OOM detection rework.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
