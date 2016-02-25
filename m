Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABE76B025B
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:28:51 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id z135so85571516iof.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:28:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e14si9783090iod.133.2016.02.25.03.28.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 03:28:50 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-4-git-send-email-mhocko@kernel.org>
Message-Id: <201602252028.BAE39532.MFOHFLOQSOVFJt@I-love.SAKURA.ne.jp>
Date: Thu, 25 Feb 2016 20:28:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> When oom_reaper manages to unmap all the eligible vmas there shouldn't
> be much of the freable memory held by the oom victim left anymore so it
> makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> OOM killer to select another task.
> 
> The lack of TIF_MEMDIE also means that the victim cannot access memory
> reserves anymore but that shouldn't be a problem because it would get
> the access again if it needs to allocate and hits the OOM killer again
> due to the fatal_signal_pending resp. PF_EXITING check. We can safely
> hide the task from the OOM killer because it is clearly not a good
> candidate anymore as everyhing reclaimable has been torn down already.
> 
> This patch will allow to cap the time an OOM victim can keep TIF_MEMDIE
> and thus hold off further global OOM killer actions granted the oom
> reaper is able to take mmap_sem for the associated mm struct. This is
> not guaranteed now but further steps should make sure that mmap_sem
> for write should be blocked killable which will help to reduce such a
> lock contention. This is not done by this patch.

Did you decide what to do if the OOM reaper is unable to take mmap_sem
for the associated mm struct? I can not only disable the OOM reaper but
also disable further global OOM killer actions at the same time because
the OOM reaper does not clear TIF_MEMDIE. I think we need to take action
regardless of whether the OOM reaper was able to reap the associated mm
struct.

The reproducer program and kernel patch is shown at
http://lkml.kernel.org/r/201602252025.ICH57371.FMOtOOFJFQHVSL@I-love.SAKURA.ne.jp .

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160225.txt.xz .
---------- console log ----------
[   59.707294] Killed process 2020 (a.out) total-vm:8272kB, anon-rss:4160kB, file-rss:0kB, shmem-rss:0kB
[   59.714851] oom_reaper: reaped process 2020 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0lB
[   59.739672] Out of memory: Kill process 1562 (a.out) score 1003 or sacrifice child
[   59.746018] Killed process 1562 (a.out) total-vm:8268kB, anon-rss:4024kB, file-rss:0kB, shmem-rss:0kB
[   60.003576] MemAlloc-Info: stalling=880 dying=42 exiting=0 victim=1 oom_count=113/49
(...snipped...)
[   60.757062] oom_reaper: unable to reap pid:1562 (a.out)
(...snipped...)
[   60.758417] 1 lock held by a.out/2269:
[   60.758417]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.759217] 1 lock held by a.out/2371:
[   60.759217]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.759732] 1 lock held by a.out/2600:
[   60.759732]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.760394] 1 lock held by a.out/2673:
[   60.760394]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.760528] 1 lock held by a.out/2689:
[   60.760528]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.760803] 1 lock held by a.out/2723:
[   60.760803]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.760884] 1 lock held by a.out/2731:
[   60.760884]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.761381] 1 lock held by a.out/2781:
[   60.761382]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.761466] 1 lock held by a.out/2791:
[   60.761466]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
[   60.761615] 1 lock held by a.out/2803:
[   60.761615]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8117e6aa>] SyS_mremap+0xaa/0x500
(...snipped...)
[  222.428230] MemAlloc-Info: stalling=876 dying=36 exiting=0 victim=1 oom_count=72229/1744
[  232.434607] MemAlloc-Info: stalling=1082 dying=36 exiting=0 victim=1 oom_count=75777/1855
(...snipped...)
[  232.711169] MemAlloc: kswapd0(49) flags=0xa60840 switches=59 uninterruptible
[  232.716820] kswapd0         D ffff880039f935d0     0    49      2 0x00000000
[  232.722494]  ffff880039f935d0 ffff8800366500c0 ffff880039f8c040 ffff880039f94000
[  232.728190]  ffff8800367eac80 ffff8800367eac98 0000000000000000 ffff880039f93820
[  232.733785]  ffff880039f935e8 ffffffff81672d1a ffff880039f8c040 ffff880039f93650
[  232.739694] Call Trace:
[  232.741797]  [<ffffffff81672d1a>] schedule+0x3a/0x90
[  232.745674]  [<ffffffff81676b16>] rwsem_down_read_failed+0xd6/0x140
[  232.750368]  [<ffffffff8132c324>] call_rwsem_down_read_failed+0x14/0x30
[  232.755333]  [<ffffffff8167645d>] ? down_read+0x3d/0x50
[  232.759397]  [<ffffffffa026286b>] ? xfs_log_commit_cil+0x5b/0x490 [xfs]
[  232.764628]  [<ffffffffa026286b>] xfs_log_commit_cil+0x5b/0x490 [xfs]
[  232.769470]  [<ffffffffa025d1e3>] __xfs_trans_commit+0x123/0x230 [xfs]
[  232.774341]  [<ffffffffa025d57b>] xfs_trans_commit+0xb/0x10 [xfs]
[  232.778929]  [<ffffffffa024e394>] xfs_iomap_write_allocate+0x194/0x380 [xfs]
[  232.784237]  [<ffffffffa023b3ed>] xfs_map_blocks+0x13d/0x150 [xfs]
[  232.788860]  [<ffffffffa023c2ab>] xfs_do_writepage+0x15b/0x520 [xfs]
[  232.793646]  [<ffffffffa023c6a6>] xfs_vm_writepage+0x36/0x70 [xfs]
[  232.798328]  [<ffffffff8115773f>] pageout.isra.43+0x18f/0x240
[  232.802677]  [<ffffffff811590a3>] shrink_page_list+0x803/0xae0
[  232.807247]  [<ffffffff81159ae7>] shrink_inactive_list+0x207/0x550
[  232.811912]  [<ffffffff8115a7d6>] shrink_zone_memcg+0x5b6/0x780
[  232.816585]  [<ffffffff811b38ed>] ? mem_cgroup_iter+0x15d/0x7c0
[  232.820923]  [<ffffffff8115aa74>] shrink_zone+0xd4/0x2f0
[  232.824963]  [<ffffffff8115b8fe>] kswapd+0x41e/0x800
[  232.828916]  [<ffffffff8115b4e0>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[  232.833835]  [<ffffffff810923ee>] kthread+0xee/0x110
[  232.837628]  [<ffffffff81678572>] ret_from_fork+0x22/0x50
[  232.841640]  [<ffffffff81092300>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[  247.278695] MemAlloc: a.out(2269) flags=0x400040 switches=2115 seq=2 gfp=0x26084c0(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO|__GFP_NOTRACK) order=0 delay=181584 uninterruptible
[  247.289757] a.out           D ffff880027aafa48     0  2269   1229 0x00000080
[  247.295134]  ffff880027aafa48 ffff880027a38040 ffff880027aa8100 ffff880027ab0000
[  247.301091]  ffff880027aafa80 ffff88003d610240 00000000ffff2f67 000000000000004c
[  247.306879]  ffff880027aafa60 ffffffff81672d1a ffff88003d610240 ffff880027aafb08
[  247.312590] Call Trace:
[  247.314749]  [<ffffffff81672d1a>] schedule+0x3a/0x90
[  247.319758]  [<ffffffff8167717e>] schedule_timeout+0x11e/0x1c0
[  247.324427]  [<ffffffff810bd056>] ? mark_held_locks+0x66/0x90
[  247.329085]  [<ffffffff810e1270>] ? init_timer_key+0x40/0x40
[  247.333385]  [<ffffffff810e8197>] ? ktime_get+0xa7/0x130
[  247.337469]  [<ffffffff816720c1>] io_schedule_timeout+0xa1/0x110
[  247.342046]  [<ffffffff811650ed>] congestion_wait+0x7d/0xd0
[  247.346570]  [<ffffffff810b73e0>] ? wait_woken+0x80/0x80
[  247.350714]  [<ffffffff8114e584>] __alloc_pages_nodemask+0xd74/0xed0
[  247.355918]  [<ffffffff81198026>] alloc_pages_current+0x96/0x1b0
[  247.361015]  [<ffffffff81062162>] pte_alloc_one+0x12/0x60
[  247.365132]  [<ffffffff811740e9>] __pte_alloc+0x19/0x110
[  247.369162]  [<ffffffff8117e20a>] move_page_tables+0x5da/0x700
[  247.373560]  [<ffffffff8117b00d>] ? copy_vma+0x20d/0x260
[  247.377647]  [<ffffffff8117e41b>] move_vma+0xeb/0x2d0
[  247.381577]  [<ffffffff8117eac8>] SyS_mremap+0x4c8/0x500
[  247.385727]  [<ffffffff8100365d>] do_syscall_64+0x5d/0x180
[  247.389869]  [<ffffffff816783ff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  275.592260] MemAlloc: a.out(1562) flags=0x400040 switches=17 uninterruptible dying victim
[  275.598299] a.out           D ffff88002e3c7d68     0  1562   1229 0x00100084
[  275.603752]  ffff88002e3c7d68 ffffffff818f9500 ffff88002e3c00c0 ffff88002e3c8000
[  275.609544]  ffff88003d1f74c8 0000000000000246 ffff88002e3c00c0 00000000ffffffff
[  275.615527]  ffff88002e3c7d80 ffffffff81672d1a ffff88003d1f74c0 ffff88002e3c7d90
[  275.621526] Call Trace:
[  275.623707]  [<ffffffff81672d1a>] schedule+0x3a/0x90
[  275.627629]  [<ffffffff81672fa3>] schedule_preempt_disabled+0x13/0x20
[  275.632511]  [<ffffffff81674d3e>] mutex_lock_nested+0x16e/0x430
[  275.636989]  [<ffffffff811d37c3>] ? lock_rename+0xd3/0x100
[  275.641192]  [<ffffffff811d37c3>] lock_rename+0xd3/0x100
[  275.645337]  [<ffffffff811d774d>] SyS_renameat2+0x1ed/0x530
[  275.649788]  [<ffffffff811d7ab9>] SyS_rename+0x19/0x20
[  275.653731]  [<ffffffff8100365d>] do_syscall_64+0x5d/0x180
[  275.657938]  [<ffffffff816783ff>] entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  385.466224] MemAlloc-Info: stalling=1081 dying=36 exiting=0 victim=1 oom_count=143237/3490
[  385.472491] INFO: task kworker/0:0:4 blocked for more than 120 seconds.
[  385.477667]       Not tainted 4.5.0-rc5-next-20160224+ #75
---------- console log ----------

While number of out_of_memory() calls is increasing over time ( 75777 -> 143237 ),
kswapd being stuck ( http://lkml.kernel.org/r/20160211225929.GU14668@dastard )
might be involved to this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
