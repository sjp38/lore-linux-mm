Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4216B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 06:24:52 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id zv6so3406770obb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 03:24:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r4si7179909obx.46.2016.01.28.03.24.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 03:24:51 -0800 (PST)
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452516120-5535-1-git-send-email-mhocko@kernel.org>
	<201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
	<20160126163823.GG27563@dhcp22.suse.cz>
In-Reply-To: <20160126163823.GG27563@dhcp22.suse.cz>
Message-Id: <201601282024.JBG90615.JLFQOSFFVOMHtO@I-love.SAKURA.ne.jp>
Date: Thu, 28 Jan 2016 20:24:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 18-01-16 13:35:44, Tetsuo Handa wrote:
> [...]
> > (1) Make the OOM reaper available on CONFIG_MMU=n kernels.
> > 
> >     I don't know about MMU, but I assume we can handle these errors.
> 
> What is the usecase for this on !MMU configurations? Why does it make
> sense to add more code to such a restricted environments? I haven't
> heard of a single OOM report from that land.
> 

For making a guarantee that the OOM reaper always takes care of OOM
victims. What I'm asking for is a guarantee, not a best-effort. I'm
fed up with responding to unexpected corner cases.

If you agree to delegate duty for handling such corner cases to a
guaranteed last resort
( http://lkml.kernel.org/r/201601222259.GJB90663.MLOJtFFOQFVHSO@I-love.SAKURA.ne.jp ),
I will stop pointing out such corner cases in the OOM reaper.

> >     slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
> >     slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
> >     slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'
> > 
> > (2) Do not boot the system if failed to create the OOM reaper thread.
> > 
> >     We are already heavily depending on the OOM reaper.
> 
> Hohmm, does this really bother you that much? This all happens really
> early during the boot. If a single kernel thread creation fails that
> early then we are screwed anyway and OOM killer will not help a tiny
> bit. The only place where the current benevolence matters is a test for
> oom_reaper_th != NULL in wake_oom_reaper and I doubt it adds an
> overhead. BUG_ON is suited for unrecoverable errors and we can clearly
> live without oom_reaper.
>  

The OOM reaper is the only chain you are trying to add, but we can't make a
guarantee without reliable chain for reclaiming memory (unless we delegate
duty for handling such corner cases to a guaranteed last resort).

By the way, it saves size of mm/oom_kill.o a bit. ;-)

  pr_err(): 18624 bytes
  BUG_ON(): 18432 bytes

> >     pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> >                     PTR_ERR(oom_reaper_th));
> > 
> > (3) Eliminate locations that call mark_oom_victim() without
> >     making the OOM victim task under monitor of the OOM reaper.
> > 
> >     The OOM reaper needs to take actions when the OOM victim task got stuck
> >     because we (except me) do not want to use my sysctl-controlled timeout-
> >     based OOM victim selection.
> 
> I do not think this is a correct way to approach the problem. I think we
> should involve oom_reaper for those cases. I just want to do that in an
> incremental steps. Originally I had the oom_reaper invocation in
> mark_oom_victim but that didn't work out (for reasons I do not remember
> right now and would have to find them in the archive).
> [...]

The archive is http://lkml.kernel.org/r/201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp .
These threads might be sharing memory with OOM-unkillable threads or not-yet-SIGKILL-pending
threads. In that case, the OOM reaper must not reap memory (which means we disconnect
the chain for reclaiming memory). I showed you a polling version ("[PATCH 4/2] oom: change
OOM reaper to walk the process list") for handling those cases.

> 
> > (4) Don't select an OOM victim until mm_to_reap (or task_to_reap) becomes NULL.
> 
> If we ever see a realistic case where the OOM killer hits in such a pace
> that the oom reaper cannot cope with it then I would rather introduce a
> queuing mechanism than add a complex code to synchronize the two
> contexts. They are currently synchronized via TIF_MEMDIE and that should
> be sufficient until the TIF_MEMDIE stops being the oom synchronization
> point.
> 

I think that the TIF_MEMDIE is not the OOM synchronization point for the OOM
reaper because the OOM killer sets TIF_MEMDIE on only one thread.

Say, there is a process with three threads (T1, T2, T3). We assume that, when
the OOM killer sends SIGKILL on this process and sets TIF_MEMDIE on T1, T1 is
about to call do_exit() and T2 is waiting at mutex_lock() and T3 is looping
inside the allocator with mmap_sem held for write.

When T1 got TIF_MEMDIE, wake_oom_reaper() is called and task_to_reap becomes T1.
But it is possible that T3 is sleeping at schedule_timeout_uninterruptible(1) in
__alloc_pages_may_oom().

The OOM reaper tries to reap T1's memory, but first down_read_trylock(&mm->mmap_sem)
attempt fails due to T3 sleeping for a jiffie. Then, the OOM reaper sleeps for 0.1
second at schedule_timeout_idle(HZ/10) in oom_reap_task().

While the OOM reaper is sleeping, T1 exits and clears TIF_MEMDIE, which can result
in choosing T2 as next OOM victim and calling wake_oom_reaper() before task_to_reap
becomes NULL. Now, the chain for reclaiming memory got disconnected.

T3 will get TIF_MEMDIE because T3 will eventually succeed mutex_trylock(&oom_lock),
and get TIF_MEMDIE by calling out_of_memory() and complete current memory allocation
request and call up_write(&mm->mmap_sem). But where is the guarantee that T3 can do it
before the OOM reaper gives up waiting for T3? If the OOM reaper failed to reap that
process's memory, task_to_reap becomes NULL when T2 already got TIF_MEMDIE which is not
under control of the OOM reaper, and the OOM killer will not choose next OOM victim.

Where is the guarantee that T2 can make forward progress after T3 successfully exited
and cleared TIF_MEMDIE? Since the OOM reaper is not monitoring T2 which has TIF_MEMDIE,
we can hit OOM livelock.

Polling or queuing is needed for handling such corner cases.

> >     This is needed for making sure that any OOM victim is made under
> >     monitor of the OOM reaper in order to let the OOM reaper take action
> >     before leaving oom_reap_vmas() (or oom_reap_task()).
> > 
> >     Since the OOM reaper can do mm_to_reap (or task_to_reap) = NULL shortly
> >     (e.g. within a second if it retries for 10 times with 0.1 second interval),
> >     waiting should not become a problem.
> > 
> > (5) Decrease oom_score_adj value after the OOM reaper reclaimed memory.
> > 
> >     If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) succeeded, set oom_score_adj
> >     value of all tasks sharing the same mm to -1000 (by walking the process list)
> >     and clear TIF_MEMDIE.
> > 

I guess I need to scratch "and clear TIF_MEMDIE" part, for clearing TIF_MEMDIE needs
a switch for avoid re-setting TIF_MEMDIE forever and such switch is complicated.

> >     Changing only the OOM victim's oom_score_adj is not sufficient
> >     when there are other thread groups sharing the OOM victim's memory
> >     (i.e. clone(!CLONE_THREAD && CLONE_VM) case).
> >
> > (6) Decrease oom_score_adj value even if the OOM reaper failed to reclaim memory.
> > 
> >     If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) failed for 10 times, decrease
> >     oom_score_adj value of all tasks sharing the same mm and clear TIF_MEMDIE.
> >     This is needed for preventing the OOM killer from selecting the same thread
> >     group forever.
> 
> I understand what you mean but I would consider this outside of the
> scope of the patchset as I want to pursue it right now. I really want to
> introduce a simple async OOM handling. Further steps can be built on top
> but please let's not make it a huge monster right away. The same applies
> to the point 5. mm shared between processes is a border line to focus on
> it in the first submission.
> 

I really do not want you to pursue the OOM reaper without providing a guarantee
that the chain for reclaiming memory never gets disconnected.

> >     An example is, set oom_score_adj to -999 if oom_score_adj is greater than
> >     -999, set -1000 if oom_score_adj is already -999. This will allow the OOM
> >     killer try to choose different OOM victims before retrying __oom_reap_vmas(mm)
> >     (or __oom_reap_task(tsk)) of this OOM victim, then trigger kernel panic if
> >     all OOM victims got -1000.
> > 
> >     Changing mmap_sem lock killable increases possibility of __oom_reap_vmas(mm)
> >     (or __oom_reap_task(tsk)) to succeed. But due to the changes in (3) and (4),
> >     there is no guarantee that TIF_MEMDIE is set to the thread which is looping at
> >     __alloc_pages_slowpath() with the mmap_sem held for writing. If the OOM killer
> >     were able to know which thread is looping at __alloc_pages_slowpath() with the
> >     mmap_sem held for writing (via per task_struct variable), the OOM killer would
> >     set TIF_MEMDIE on that thread before randomly choosing one thread using
> >     find_lock_task_mm().
> 
> If mmap_sem (for write) holder is looping in the allocator and the
> process gets killed it will get access to memory reserves automatically,
> so I am not sure what do you mean here.
> 

Please stop assuming that "dying tasks get access to memory reserves
automatically (by getting TIF_MEMDIE)". It is broken.

Dying tasks might be doing !__GFP_FS allocation requests. Even if we set
TIF_MEMDIE to all threads which should terminate (in case they are doing
!__GFP_FS allocation requests), there is no guarantee that they will not
wait for locks in unkillable state after their current memory allocation
request completes (e.g. getname() followed by mutex_lock() shown at
http://lkml.kernel.org/r/201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp ).

Dying tasks cannot access memory reserves unless they are doing memory
allocation. Therefore, we cannot wait for dying tasks forever, even if
the OOM reaper can reclaim some memory.

Please do not disconnect the chain for reclaiming memory.

> Thank you for your feedback. There are some improvements and additional
> heuristics proposed and they might be really valuable in some cases but
> I believe that none of the points you are rising are blockers for the
> current code. My intention here is to push the initial version which
> would handle the most probable cases and build more on top. I would
> really prefer this doesn't grow into a hard to evaluate bloat from the
> early beginning.

I like the OOM reaper approach but I can't agree on merging the OOM reaper
without providing a guaranteed last resort at the same time. If you do want
to start the OOM reaper as simple as possible (without being bothered by
a lot of possible corner cases), please pursue a guaranteed last resort
at the same time.

We can remove the guaranteed last resort after we made the OOM reaper (and
other preferable approaches) enough reliable by doing incremental development.

Even if all OOM-killable tasks are OOM-killed, it is better than unable to
login from ssh due to OOM livelock as well as torturing with unhandled
corner cases.

If you don't like the guaranteed last resort, I can tolerate with kmallocwd.
Without a mean to understand what is happening, we will simply pretend as if
there is no bug because we are not receiving reports from users. Most users
are not as skillful as you about reporting problems related to memory allocation.
Would you please right now stop torturing administrators and technical staffs
at support center with unexplained hangups?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
