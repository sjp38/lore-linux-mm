Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AF5FB6B0256
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 05:59:11 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fy10so44964875pac.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 02:59:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id sm4si42762228pac.245.2016.02.15.02.59.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 02:59:10 -0800 (PST)
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452516120-5535-1-git-send-email-mhocko@kernel.org>
	<20160111165214.GA32132@cmpxchg.org>
In-Reply-To: <20160111165214.GA32132@cmpxchg.org>
Message-Id: <201602151958.HCJ48972.FFOFOLMHSQVJtO@I-love.SAKURA.ne.jp>
Date: Mon, 15 Feb 2016 19:58:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Andrew Morton wrote:
> 
> The patch titled
>      Subject: mm/oom_kill.c: don't ignore oom score on exiting tasks
> has been removed from the -mm tree.  Its filename was
>      mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim.patch
> 
> This patch was dropped because an updated version will be merged
> 
> ------------------------------------------------------
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm/oom_kill.c: don't ignore oom score on exiting tasks
> 
> When the OOM killer scans tasks and encounters a PF_EXITING one, it
> force-selects that one regardless of the score.  Is there a possibility
> that the task might hang after it has set PF_EXITING?  In that case the
> OOM killer should be able to move on to the next task.
> 
> Frankly, I don't even know why we check for exiting tasks in the OOM
> killer.  We've tried direct reclaim at least 15 times by the time we
> decide the system is OOM, there was plenty of time to exit and free
> memory; and a task might exit voluntarily right after we issue a kill. 
> This is testing pure noise.
> 

I can't find updated version of this patch in linux-next. Why don't you submit?
I think the patch description should be updated because this patch solves yet
another silent OOM livelock bug.

Say, there is a process with two threads named Thread1 and Thread2.
Since the OOM killer sets TIF_MEMDIE only on the first non-NULL mm task,
it is possible that Thread2 invokes the OOM killer and Thread1 gets
TIF_MEMDIE (without sending SIGKILL to processes using Thread1's mm).

----------
Thread1                       Thread2
                              Calls mmap()
Calls _exit(0)
                              Arrives at vm_mmap_pgoff()
Arrives at do_exit()
Gets PF_EXITING via exit_signals()
                              Calls down_write(&mm->mmap_sem)
                              Calls do_mmap_pgoff()
Calls down_read(&mm->mmap_sem) from exit_mm()
                              Does a GFP_KERNEL allocation
                              Calls out_of_memory()
                              oom_scan_process_thread(Thread1) returns OOM_SCAN_ABORT

down_read(&mm->mmap_sem) is waiting for Thread2 to call up_write(&mm->mmap_sem)
                              but Thread2 is waiting for Thread1 to set Thread1->mm = NULL ... silent OOM livelock!
----------

The OOM reaper tries to avoid this livelock by using down_read_trylock()
instead of down_read(), but core_state check in exit_mm() cannot avoid this
livelock unless we use non-blocking allocation (i.e. GFP_ATOMIC or GFP_NOWAIT)
for allocations between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem).

I think that the same problem exists for any task_will_free_mem()-based
optimizations such as

        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

in out_of_memory() and

        task_lock(p);
        if (p->mm && task_will_free_mem(p)) {
                mark_oom_victim(p);
                task_unlock(p);
                put_task_struct(p);
                return;
        }
        task_unlock(p);

in oom_kill_process() and

        if (fatal_signal_pending(current) || task_will_free_mem(current)) {
                mark_oom_victim(current);
                goto unlock;
        }

in mem_cgroup_out_of_memory().

Well, what are possible callers of task_will_free_mem(current) between getting
PF_EXITING and doing current->mm = NULL ? tty_audit_exit() seems to be an example
which does a GFP_KERNEL allocation from tty_audit_log() and can be later blocked
at down_read() in exit_mm() after TIF_MEMDIE is set at tty_audit_log() called from
tty_audit_exit() ?

Is task_will_free_mem(current) possible for mem_cgroup_out_of_memory() case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
