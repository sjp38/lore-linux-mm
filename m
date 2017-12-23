Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6506B0038
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 10:34:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so18633391pgq.3
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 07:34:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k26si18870888pfh.110.2017.12.23.07.34.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Dec 2017 07:34:45 -0800 (PST)
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second allocation
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201712132006.DDE78145.FMFJSOOHVFQtOL@I-love.SAKURA.ne.jp>
	<201712192336.GHG30208.MLFSVJQOHOFtOF@I-love.SAKURA.ne.jp>
	<20171219145508.GZ2787@dhcp22.suse.cz>
	<201712220034.HIC12926.OtQJOOFFVFMSLH@I-love.SAKURA.ne.jp>
	<20171221164244.GK4831@dhcp22.suse.cz>
In-Reply-To: <20171221164244.GK4831@dhcp22.suse.cz>
Message-Id: <201712232341.FGC64072.VFLOOJOtFSFMHQ@I-love.SAKURA.ne.jp>
Date: Sat, 23 Dec 2017 23:41:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 22-12-17 00:34:05, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > >                                   Let me repeat something I've said a
> > > long ago. We do not optimize for corner cases. We want to survive but if
> > > an alternative is to kill another task then we can live with that.
> > >  
> > 
> > Setting MMF_OOM_SKIP before all OOM-killed threads try memory reserves
> > leads to needlessly selecting more OOM victims.
> > 
> > Unless any OOM-killed thread fails to satisfy allocation even with ALLOC_OOM,
> > no OOM-killed thread needs to select more OOM victims. Commit 696453e66630ad45
> > ("mm, oom: task_will_free_mem should skip oom_reaped tasks") obviously broke
> > it, which is exactly a regression.
> 
> You are trying to fix a completely artificial case. Or do you have any
> example of an application which uses CLONE_VM without sharing signals?

Your response is an invalid and insane resistance.

You dare to silently made user visible changes. If you really believe that
there is no application which uses CLONE_VM without sharing signals, let's
revert below patch.

----------
commit 44a70adec910d6929689e42b6e5cee5b7d202d20
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Jul 28 15:44:43 2016 -0700

    mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj

    oom_score_adj is shared for the thread groups (via struct signal) but this
    is not sufficient to cover processes sharing mm (CLONE_VM without
    CLONE_SIGHAND) and so we can easily end up in a situation when some
    processes update their oom_score_adj and confuse the oom killer.  In the
    worst case some of those processes might hide from the oom killer
    altogether via OOM_SCORE_ADJ_MIN while others are eligible.  OOM killer
    would then pick up those eligible but won't be allowed to kill others
    sharing the same mm so the mm wouldn't release the mm and so the memory.

    It would be ideal to have the oom_score_adj per mm_struct because that is
    the natural entity OOM killer considers.  But this will not work because
    some programs are doing

        vfork()
        set_oom_adj()
        exec()

    We can achieve the same though.  oom_score_adj write handler can set the
    oom_score_adj for all processes sharing the same mm if the task is not in
    the middle of vfork.  As a result all the processes will share the same
    oom_score_adj.  The current implementation is rather pessimistic and
    checks all the existing processes by default if there is more than 1
    holder of the mm but we do not have any reliable way to check for external
    users yet.

    Link: http://lkml.kernel.org/r/1466426628-15074-5-git-send-email-mhocko@kernel.org
    Signed-off-by: Michal Hocko <mhocko@suse.com>
    Acked-by: Oleg Nesterov <oleg@redhat.com>
    Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
----------

We do prepare for the worst case. We have just experienced two mistakes
by not considering the worst case.

----------
commit 400e22499dd92613821374c8c6c88c7225359980
Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date:   Wed Nov 15 17:38:37 2017 -0800

    mm: don't warn about allocations which stall for too long

    Commit 63f53dea0c98 ("mm: warn about allocations which stall for too
    long") was a great step for reducing possibility of silent hang up
    problem caused by memory allocation stalls.  But this commit reverts it,
    for it is possible to trigger OOM lockup and/or soft lockups when many
    threads concurrently called warn_alloc() (in order to warn about memory
    allocation stalls) due to current implementation of printk(), and it is
    difficult to obtain useful information due to limitation of synchronous
    warning approach.

    Current printk() implementation flushes all pending logs using the
    context of a thread which called console_unlock().  printk() should be
    able to flush all pending logs eventually unless somebody continues
    appending to printk() buffer.

    Since warn_alloc() started appending to printk() buffer while waiting
    for oom_kill_process() to make forward progress when oom_kill_process()
    is processing pending logs, it became possible for warn_alloc() to force
    oom_kill_process() loop inside printk().  As a result, warn_alloc()
    significantly increased possibility of preventing oom_kill_process()
    from making forward progress.

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

    Although waited_for_10seconds() becomes true once per 10 seconds,
    unbounded number of threads can call waited_for_10seconds() at the same
    time.  Also, since threads doing waited_for_10seconds() keep doing
    almost busy loop, the thread doing print_one_log() can use little CPU
    resource.  Therefore, this situation can be simplified like

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
    (either oom_kill_process() or warn_alloc()) is already in progress.

    Such serialization will also help obtaining kernel messages in readable
    form.

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

    But this commit does not go that direction, for we don't want to
    introduce a new lock dependency, and we unlikely be able to obtain
    useful information even if we serialized oom_kill_process() and
    warn_alloc().

    Synchronous approach is prone to unexpected results (e.g.  too late [1],
    too frequent [2], overlooked [3]).  As far as I know, warn_alloc() never
    helped with providing information other than "something is going wrong".
    I want to consider asynchronous approach which can obtain information
    during stalls with possibly relevant threads (e.g.  the owner of
    oom_lock and kswapd-like threads) and serve as a trigger for actions
    (e.g.  turn on/off tracepoints, ask libvirt daemon to take a memory dump
    of stalling KVM guest for diagnostic purpose).

    This commit temporarily loses ability to report e.g.  OOM lockup due to
    unable to invoke the OOM killer due to !__GFP_FS allocation request.
    But asynchronous approach will be able to detect such situation and emit
    warning.  Thus, let's remove warn_alloc().

    [1] https://bugzilla.kernel.org/show_bug.cgi?id=192981
    [2] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com
    [3] commit db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolated for ever"))

    Link: http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
    Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
    Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
    Reported-by: Johannes Weiner <hannes@cmpxchg.org>
    Acked-by: Michal Hocko <mhocko@suse.com>
    Acked-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Vlastimil Babka <vbabka@suse.cz>
    Cc: Mel Gorman <mgorman@suse.de>
    Cc: Dave Hansen <dave.hansen@intel.com>
    Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
    Cc: Petr Mladek <pmladek@suse.com>
    Cc: Steven Rostedt <rostedt@goodmis.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
----------

----------
commit 4837fe37adff1d159904f0c013471b1ecbcb455e
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Dec 14 15:33:15 2017 -0800

    mm, oom_reaper: fix memory corruption

    David Rientjes has reported the following memory corruption while the
    oom reaper tries to unmap the victims address space

      BUG: Bad page map in process oom_reaper  pte:6353826300000000 pmd:00000000
      addr:00007f50cab1d000 vm_flags:08100073 anon_vma:ffff9eea335603f0 mapping:          (null) index:7f50cab1d
      file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
      CPU: 2 PID: 1001 Comm: oom_reaper
      Call Trace:
         unmap_page_range+0x1068/0x1130
         __oom_reap_task_mm+0xd5/0x16b
         oom_reaper+0xff/0x14c
         kthread+0xc1/0xe0

    Tetsuo Handa has noticed that the synchronization inside exit_mmap is
    insufficient.  We only synchronize with the oom reaper if
    tsk_is_oom_victim which is not true if the final __mmput is called from
    a different context than the oom victim exit path.  This can trivially
    happen from context of any task which has grabbed mm reference (e.g.  to
    read /proc/<pid>/ file which requires mm etc.).

    The race would look like this

      oom_reaper                oom_victim              task
                                                mmget_not_zero
                        do_exit
                          mmput
      __oom_reap_task_mm                                mmput
                                                  __mmput
                                                    exit_mmap
                                                      remove_vma
        unmap_page_range

    Fix this issue by providing a new mm_is_oom_victim() helper which
    operates on the mm struct rather than a task.  Any context which
    operates on a remote mm struct should use this helper in place of
    tsk_is_oom_victim.  The flag is set in mark_oom_victim and never cleared
    so it is stable in the exit_mmap path.

    Debugged by Tetsuo Handa.

    Link: http://lkml.kernel.org/r/20171210095130.17110-1-mhocko@kernel.org
    Fixes: 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run concurrently")
    Signed-off-by: Michal Hocko <mhocko@suse.com>
    Reported-by: David Rientjes <rientjes@google.com>
    Acked-by: David Rientjes <rientjes@google.com>
    Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Cc: Andrea Argangeli <andrea@kernel.org>
    Cc: <stable@vger.kernel.org>        [4.14]
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
----------

There is no reason not to make sure processes sharing victim's mm have
same treatment regarding use of memory reserves.

You want to get rid of TIF_MEMDIE flag, but you rejected my patch which is
one of steps for getting rid of TIF_MEMDIE flag.

Whether a problem is seen in real life is a catch-22 discussion, for you
keep refusing/ignoring to provide a method for allowing normal users to
tell whether they hit that problem.

Please stop rejecting my patches without thinking deeply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
