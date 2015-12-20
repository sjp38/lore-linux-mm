Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id A235C4402ED
	for <linux-mm@kvack.org>; Sun, 20 Dec 2015 02:14:32 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id 186so130008770iow.0
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 23:14:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t12si20659405igd.27.2015.12.19.23.14.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 19 Dec 2015 23:14:31 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
	<20151217130223.GE18625@dhcp22.suse.cz>
	<201512182110.FBH73485.LFOFtOOVSHFQMJ@I-love.SAKURA.ne.jp>
In-Reply-To: <201512182110.FBH73485.LFOFtOOVSHFQMJ@I-love.SAKURA.ne.jp>
Message-Id: <201512201614.IFE86919.HFtFMOLFQVOJOS@I-love.SAKURA.ne.jp>
Date: Sun, 20 Dec 2015 16:14:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151218.txt.xz .
> ----------
> [  438.304082] Killed process 12680 (oom_reaper-test) total-vm:4324kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
> [  439.318951] oom_reaper: attempts=11
> [  445.581171] MemAlloc-Info: 796 stalling task, 0 dying task, 0 victim task.
> [  618.955215] MemAlloc-Info: 979 stalling task, 0 dying task, 0 victim task.
> ----------
> 
> Yes, this is an insane program. But what is important will be we prepare for
> cases when oom_reap_vmas() gave up waiting. Silent hang up is annoying.

s/gave up waiting/did not help/



I noticed yet another problem with this program.

The OOM victim (a child of memory hog process) received SIGKILL at
uptime = 438 and it terminated before uptime = 445 even though
oom_reap_vmas() gave up waiting at uptime = 439. However, the OOM killer
was not invoked again in order to kill the memory hog process before I
gave up waiting at uptime = 679. The OOM killer was needlessly kept
disabled for more than 234 seconds after the OOM victim terminated.

----------
[  438.180596] oom_reaper-test invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x26040c0(GFP_KERNEL|GFP_COMP|GFP_NOTRACK)
[  438.183524] oom_reaper-test cpuset=/ mems_allowed=0
[  438.185440] CPU: 0 PID: 13451 Comm: oom_reaper-test Not tainted 4.4.0-rc5-next-20151217+ #248
(...snipped...)
[  438.301687] Out of memory: Kill process 12679 (oom_reaper-test) score 876 or sacrifice child
[  438.304082] Killed process 12680 (oom_reaper-test) total-vm:4324kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  568.185582] MemAlloc: oom_reaper-test(13451) seq=2 gfp=0x26040c0 order=0 delay=7403
[  568.187593] oom_reaper-test R  running task        0 13451   8130 0x00000080
[  568.189546]  ffff88007a4cb918 ffff88007a5c4140 ffff88007a4c0000 ffff88007a4cc000
[  568.191637]  ffff88007a4cb950 ffff88007fc10240 0000000100021bb8 ffffffff81c11730
[  568.193713]  ffff88007a4cb930 ffffffff816f5b77 ffff88007fc10240 ffff88007a4cb9d0
[  568.195798] Call Trace:
[  568.196878]  [<ffffffff816f5b77>] schedule+0x37/0x90
[  568.198402]  [<ffffffff816f9f37>] schedule_timeout+0x117/0x1c0
[  568.200078]  [<ffffffff810dfd00>] ? init_timer_key+0x40/0x40
[  568.201725]  [<ffffffff816fa034>] schedule_timeout_killable+0x24/0x30
[  568.203512]  [<ffffffff81142d49>] out_of_memory+0x1f9/0x5a0
[  568.205144]  [<ffffffff81142dfd>] ? out_of_memory+0x2ad/0x5a0
[  568.206800]  [<ffffffff811486f3>] __alloc_pages_nodemask+0xc43/0xc80
[  568.208564]  [<ffffffff8118f786>] alloc_pages_current+0x96/0x1b0
[  568.210259]  [<ffffffff81198177>] ? new_slab+0x357/0x470
[  568.211811]  [<ffffffff811981ee>] new_slab+0x3ce/0x470
[  568.213329]  [<ffffffff8119a41a>] ___slab_alloc+0x42a/0x5c0
[  568.214917]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  568.216486]  [<ffffffff811aa75d>] ? mem_cgroup_end_page_stat+0x2d/0xb0
[  568.218240]  [<ffffffff810ba2a9>] ? __lock_is_held+0x49/0x70
[  568.219815]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  568.221388]  [<ffffffff811bc45b>] __slab_alloc+0x4a/0x81
[  568.222980]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  568.224565]  [<ffffffff8119aab3>] __kmalloc+0x163/0x1b0
[  568.226075]  [<ffffffff811e5ff5>] seq_buf_alloc+0x35/0x40
[  568.227710]  [<ffffffff811e660b>] seq_read+0x31b/0x3c0
[  568.229184]  [<ffffffff811beaf2>] __vfs_read+0x32/0xf0
[  568.230673]  [<ffffffff81302339>] ? security_file_permission+0xa9/0xc0
[  568.232408]  [<ffffffff811bf49d>] ? rw_verify_area+0x4d/0xd0
[  568.234068]  [<ffffffff811bf59a>] vfs_read+0x7a/0x120
[  568.235561]  [<ffffffff811c0700>] SyS_pread64+0x90/0xb0
[  568.237062]  [<ffffffff816fb0f2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  568.238766] 2 locks held by oom_reaper-test/13451:
[  568.240188]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff811e6337>] seq_read+0x47/0x3c0
[  568.242303]  #1:  (oom_lock){+.+...}, at: [<ffffffff81148358>] __alloc_pages_nodemask+0x8a8/0xc80
(...snipped...)
[  658.711079] MemAlloc: oom_reaper-test(13451) seq=2 gfp=0x26040c0 order=0 delay=180777
[  658.713110] oom_reaper-test R  running task        0 13451   8130 0x00000080
[  658.715073]  ffff88007a4cb918 ffff88007a5c4140 ffff88007a4c0000 ffff88007a4cc000
[  658.717166]  ffff88007a4cb950 ffff88007fc10240 0000000100021bb8 ffffffff81c11730
[  658.719248]  ffff88007a4cb930 ffffffff816f5b77 ffff88007fc10240 ffff88007a4cb9d0
[  658.721345] Call Trace:
[  658.722426]  [<ffffffff816f5b77>] schedule+0x37/0x90
[  658.723950]  [<ffffffff816f9f37>] schedule_timeout+0x117/0x1c0
[  658.725636]  [<ffffffff810dfd00>] ? init_timer_key+0x40/0x40
[  658.727304]  [<ffffffff816fa034>] schedule_timeout_killable+0x24/0x30
[  658.729113]  [<ffffffff81142d49>] out_of_memory+0x1f9/0x5a0
[  658.730757]  [<ffffffff81142dfd>] ? out_of_memory+0x2ad/0x5a0
[  658.732444]  [<ffffffff811486f3>] __alloc_pages_nodemask+0xc43/0xc80
[  658.734314]  [<ffffffff8118f786>] alloc_pages_current+0x96/0x1b0
[  658.736041]  [<ffffffff81198177>] ? new_slab+0x357/0x470
[  658.737643]  [<ffffffff811981ee>] new_slab+0x3ce/0x470
[  658.739239]  [<ffffffff8119a41a>] ___slab_alloc+0x42a/0x5c0
[  658.740899]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  658.742617]  [<ffffffff811aa75d>] ? mem_cgroup_end_page_stat+0x2d/0xb0
[  658.744489]  [<ffffffff810ba2a9>] ? __lock_is_held+0x49/0x70
[  658.746157]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  658.747801]  [<ffffffff811bc45b>] __slab_alloc+0x4a/0x81
[  658.749392]  [<ffffffff811e5ff5>] ? seq_buf_alloc+0x35/0x40
[  658.751021]  [<ffffffff8119aab3>] __kmalloc+0x163/0x1b0
[  658.752562]  [<ffffffff811e5ff5>] seq_buf_alloc+0x35/0x40
[  658.754145]  [<ffffffff811e660b>] seq_read+0x31b/0x3c0
[  658.755678]  [<ffffffff811beaf2>] __vfs_read+0x32/0xf0
[  658.757194]  [<ffffffff81302339>] ? security_file_permission+0xa9/0xc0
[  658.758959]  [<ffffffff811bf49d>] ? rw_verify_area+0x4d/0xd0
[  658.760571]  [<ffffffff811bf59a>] vfs_read+0x7a/0x120
[  658.762746]  [<ffffffff811c0700>] SyS_pread64+0x90/0xb0
[  658.770489]  [<ffffffff816fb0f2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  658.772641] 2 locks held by oom_reaper-test/13451:
[  658.774321]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff811e6337>] seq_read+0x47/0x3c0
[  658.776456]  #1:  (oom_lock){+.+...}, at: [<ffffffff81148358>] __alloc_pages_nodemask+0x8a8/0xc80
(...snipped...)
[  679.648918] sysrq: SysRq : Kill All Tasks
----------

Looking at the traces, the process which invoked the OOM killer kept
the oom_lock mutex held because it had been sleeping at
schedule_timeout_killable(1) at out_of_memory(), which meant to wait for
only one jiffie but actually waited for more than 234 seconds.

        if (p && p != (void *)-1UL) {
                oom_kill_process(oc, p, points, totalpages, NULL,
                                 "Out of memory");
                /*
                 * Give the killed process a good chance to exit before trying
                 * to allocate memory again.
                 */
                schedule_timeout_killable(1);
        }
        return true;

During that period, nobody was able to call out_of_memory() because
everybody assumed that the process which invoked the OOM killer is
making progress for us.

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
        if (!mutex_trylock(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

The side effect is not limited to not choosing the next OOM victim.
SIGKILL but !TIF_MEMDIE tasks (possibly tasks sharing OOM victim's mm)
cannot use ALLOC_NO_WATERMARKS until they can arrive at out_of_memory().
Assumptions like

        /*
         * If current has a pending SIGKILL or is exiting, then automatically
         * select it.  The goal is to allow it to allocate so that it may
         * quickly exit and free its memory.
         *
         * But don't select if current has already released its mm and cleared
         * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
         */
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

in out_of_memory() and

        /*
         * Kill all user processes sharing victim->mm in other thread groups, if
         * any.  They don't get access to memory reserves, though, to avoid
         * depletion of all memory.  This prevents mm->mmap_sem livelock when an
         * oom killed thread cannot exit because it requires the semaphore and
         * its contended by another thread trying to allocate memory itself.
         * That thread will now get access to memory reserves since it has a
         * pending fatal signal.
         */

in oom_kill_process() can not work. (Yes, we know
fatal_signal_pending(current) check in out_of_memory() is wrong.
http://lkml.kernel.org/r/20151002135201.GA28533@redhat.com )

I think we might want to make sure that the oom_lock mutex is released within
reasonable period after the OOM killer kills a victim. Maybe changing not to
depend on TIF_MEMDIE for using memory reserves. Maybe replacing the whole
operation between mutex_trylock(&oom_lock) and mutex_unlock(&oom_lock) with
request_oom_killer() (like request_module() does) and let a kernel thread do
the OOM kill operation (oom_reaper() can do it?), for it will make easy to
wait for short period after killing the victim, without worrying about huge
unexpected delay caused by low scheduling priority / limited available CPUs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
