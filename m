Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id A5EBF6B0267
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 05:16:20 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id p187so73093456oia.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 02:16:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p4si781139oib.73.2016.01.13.02.16.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 02:16:19 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160107145841.GN27868@dhcp22.suse.cz>
	<201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
	<20160111151835.GH27317@dhcp22.suse.cz>
	<201601122032.FHH13586.MOQVFFOJStFHOL@I-love.SAKURA.ne.jp>
	<20160112195200.GB4515@dhcp22.suse.cz>
In-Reply-To: <20160112195200.GB4515@dhcp22.suse.cz>
Message-Id: <201601131915.BCI35488.FHSFQtVMJOOOLF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Jan 2016 19:15:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > > Do we want to require SysRq-f for each thread in a process?
> > > > If g has 1024 p, dump_tasks() will do
> > > >
> > > >   pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
> > > >
> > > > for 1024 times? I think one SysRq-f per one process is sufficient.
> > >
> > > I am not following you here. If we kill the process the whole process
> > > group (aka all threads) will get killed which ever thread we happen to
> > > send the sigkill to.
> >
> > Please distinguish "sending SIGKILL to a process" and "all threads in that
> > process terminate".
>
> I didn't say anything about termination if your read my response again.

I think "the whole thread group will go down anyway" assumes termination.
The whole thread group (process group ?) will not go down if some of threads
got stuck and select_bad_process() and find_lock_task_mm() choose the same
thread forever. Even if we are lucky enough to terminate one thread per one
SysRq-f request, dump_tasks() will report the same thread group for many times
if we skip individual TIF_MEMDIE thread. In that regard, "[RFC 1/3] oom,sysrq:
Skip over oom victims and killed tasks" is nice that fatal_signal_pending(p)
prevents dump_tasks() from reporting the same thread group for many times if
that check is done in dump_tasks() as well.

By the way, why "[RFC 1/3] oom,sysrq: Skip over oom victims and killed tasks"
does not check task_will_free_mem(p) while "[RFC 2/3] oom: Do not sacrifice
already OOM killed children" checks task_will_free_mem(children)?
I think we can add a helper like

static bool task_should_terminate(struct task_struct *p)
{
	return fatal_signal_pending(p) || (p->flags & PF_EXITING) ||
	       test_tsk_thread_flag(p, TIF_MEMDIE);
}

and call it from both [RFC 1/3] and [RFC 2/3].

>
> [...]
>
> > > > How can we guarantee that find_lock_task_mm() from oom_kill_process()
> > > > chooses !TIF_MEMDIE thread when try_to_sacrifice_child() somehow chose
> > > > !TIF_MEMDIE thread? I think choosing !TIF_MEMDIE thread at
> > > > find_lock_task_mm() is the simplest way.
> > >
> > > find_lock_task_mm chosing TIF_MEMDIE thread shouldn't change anything
> > > because the whole thread group will go down anyway. If you want to
> > > guarantee that the sysrq+f never choses a task which has a TIF_MEMDIE
> > > thread then we would have to check for fatal_signal_pending as well
> > > AFAIU. Fiddling with find find_lock_task_mm will not help you though
> > > unless I am missing something.
> >
> > I do want to guarantee that the SysRq-f (and timeout based next victim
> > selection) never chooses a process which has a TIF_MEMDIE thread.
>
> Sigh... see what I have written in the paragraph you are replying to...
>

???



> > I don't like current "oom: clear TIF_MEMDIE after oom_reaper managed to unmap
> > the address space" patch unless both "mm,oom: exclude TIF_MEMDIE processes from
> > candidates." patch and "mm,oom: Re-enable OOM killer using timers."
>
> Those patches are definitely not a prerequisite from the functional
> point of view and putting them together as a prerequisite sounds like
> blocking a useful feature without technical grounds to me.

I like the OOM reaper approach. I said I don't like current patch because
current patch ignores unlikely cases described below. If all changes that
cover unlikely cases are implemented, my patches will become unneeded.

(1) Make the OOM reaper available on CONFIG_MMU=n kernels.

    I don't know about MMU, but I assume we can handle these errors.

    slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
    slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
    slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'

(2) Do not boot the system if failed to create the OOM reaper thread.

    We are already heavily depending on the OOM reaper.

    pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
                    PTR_ERR(oom_reaper_th));

(3) Eliminate locations that call mark_oom_victim() without
    making the OOM victim task under monitor of the OOM reaper.

    The OOM reaper needs to take actions when the OOM victim task got stuck
    because we (except me) do not want to use my sysctl-controlled timeout-
    based OOM victim selection.

    out_of_memory():
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

    oom_kill_process():
        task_lock(p);
        if (p->mm && task_will_free_mem(p)) {
                mark_oom_victim(p);
                task_unlock(p);
                put_task_struct(p);
                return;
        }
        task_unlock(p);

    mem_cgroup_out_of_memory():
        if (fatal_signal_pending(current) || task_will_free_mem(current)) {
                mark_oom_victim(current);
                goto unlock;
        }

    lowmem_scan():
        if (selected->mm)
                mark_oom_victim(selected);

(4) Don't select an OOM victim until mm_to_reap (or task_to_reap) becomes NULL.

    This is needed for making sure that any OOM victim is made under
    monitor of the OOM reaper in order to let the OOM reaper take action
    before leaving oom_reap_vmas() (or oom_reap_task()).

    Since the OOM reaper can do mm_to_reap (or task_to_reap) = NULL shortly
    (e.g. within a second if it retries for 10 times with 0.1 second interval),
    waiting should not become a problem.

(5) Decrease oom_score_adj value after the OOM reaper reclaimed memory.

    If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) succeeded, set oom_score_adj
    value of all tasks sharing the same mm to -1000 (by walking the process list)
    and clear TIF_MEMDIE.

    Changing only the OOM victim's oom_score_adj is not sufficient
    when there are other thread groups sharing the OOM victim's memory
    (i.e. clone(!CLONE_THREAD && CLONE_VM) case).

(6) Decrease oom_score_adj value even if the OOM reaper failed to reclaim memory.

    If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) failed for 10 times, decrease
    oom_score_adj value of all tasks sharing the same mm and clear TIF_MEMDIE.
    This is needed for preventing the OOM killer from selecting the same thread
    group forever.

    An example is, set oom_score_adj to -999 if oom_score_adj is greater than
    -999, set -1000 if oom_score_adj is already -999. This will allow the OOM
    killer try to choose different OOM victims before retrying __oom_reap_vmas(mm)
    (or __oom_reap_task(tsk)) of this OOM victim, then trigger kernel panic if
    all OOM victims got -1000.

    Changing mmap_sem lock killable increases possibility of __oom_reap_vmas(mm)
    (or __oom_reap_task(tsk)) to succeed. But due to the changes in (3) and (4),
    there is no guarantee that TIF_MEMDIE is set to the thread which is looping at
    __alloc_pages_slowpath() with the mmap_sem held for writing. If the OOM killer
    were able to know which thread is looping at __alloc_pages_slowpath() with the
    mmap_sem held for writing (via per task_struct variable), the OOM killer would
    set TIF_MEMDIE on that thread before randomly choosing one thread using
    find_lock_task_mm().

(7) Decrease oom_score_adj value even if the OOM reaper is not allowed to reclaim
    memory.

    This is same with (6) except for cases where the OOM victim's memory is
    used by some OOM-unkillable threads (i.e. can_oom_reap = false case).

    Calling wake_oom_reaper() with can_oom_reap added is the simplest way for
    waiting for short period (e.g. a second) and change oom_score_adj value
    and clear TIF_MEMDIE.

Maybe I'm missing something else. But assuming that [RFC 1/3] and [RFC 2/3] does
what "mm,oom: exclude TIF_MEMDIE processes from candidates." patch will cover,
adding changes listed above to current "oom: clear TIF_MEMDIE after oom_reaper
managed to unmap the address space" patch will do what "mm,oom: Re-enable OOM
killer using timers." patch will cover.

Also, kmallocwd-like approach (i.e. walk the process list) will eliminate the
need for doing (3) and (4). By using memalloc_info, that kernel thread can do
better decision based on e.g. "Are you currently waiting at memory allocation?"
"Is the order a __GFP_NOFAIL-order-5-allocation?" when choosing an OOM victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
