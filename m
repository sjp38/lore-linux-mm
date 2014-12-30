Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EF6926B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:22:02 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so20552074wgh.36
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 03:22:02 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id gf8si64350449wib.61.2014.12.30.03.22.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 03:22:01 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so23787636wiv.0
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 03:22:01 -0800 (PST)
Date: Tue, 30 Dec 2014 12:21:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141230112158.GA15546@dhcp22.suse.cz>
References: <20141220020331.GM1942@devil.localdomain>
 <201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
 <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

On Tue 30-12-14 15:42:56, Tetsuo Handa wrote:
[...]
> We might want to discuss below case as a separate topic, but is a TIF_MEMDIE
> stall anyway. I retested using 3.19-rc2 with diff shown below. If I start
> a.out and b.out (where b.out is a copy of a.out) with slight delay (a few
> deciseconds), I can observe that the a.out is unable to die due to b.out
> asking for memory or holding lock.
> http://I-love.SAKURA.ne.jp/tmp/serial-20141230-ab-1.txt.xz is a case
> where I think a.out keeps the OOM killer disabled and

[   53.748454] b.out invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[...]
[   53.807397] active_anon:448903 inactive_anon:2082 isolated_anon:0
[   53.807397]  active_file:0 inactive_file:9 isolated_file:0
[   53.807397]  unevictable:0 dirty:3 writeback:0 unstable:0
[   53.807397]  free:13079 slab_reclaimable:1227 slab_unreclaimable:4520
[   53.807397]  mapped:380 shmem:2151 pagetables:2059 bounce:0
[   53.807397]  free_cma:0
[...]
[   53.856598] Free swap  = 0kB
[   53.857908] Total swap = 0kB
[   53.859218] 524157 pages RAM

This situation looks quite hopeless. We cannot swap yet we have over 80%
of memory occupied by anon memory. There is still around ~50M free and
few pages in the reclaimable slab which should be sufficient to help
TIF_MEMDIE to make some progress on the other hand.

[   54.380517] Out of memory: Kill process 3596 (a.out) score 719 or sacrifice child
[   54.382091] Killed process 3596 (a.out) total-vm:2166864kB, anon-rss:1383880kB, file-rss:4kB
[...]
[  348.134718] a.out           D ffff880036fefcb8     0  3596      1 0x00100084
[  348.136616]  ffff880036fefcb8 ffff880036fefc88 ffff88007c204550 00000000000130c0
[  348.138645]  ffff880036feffd8 00000000000130c0 ffff88007c204550 ffff880036fefcb8
[  348.140657]  ffff88007ca45248 ffff88007ca4524c ffff88007c204550 00000000ffffffff
[  348.142672] Call Trace:
[  348.143662]  [<ffffffff815bddb4>] schedule_preempt_disabled+0x24/0x70
[  348.145379]  [<ffffffff815bfb65>] __mutex_lock_slowpath+0xb5/0x120
[  348.147153]  [<ffffffff815bfbee>] mutex_lock+0x1e/0x32
[  348.148644]  [<ffffffffa02463ca>] xfs_file_buffered_aio_write.isra.15+0x6a/0x200 [xfs]
[  348.150637]  [<ffffffff8100d62f>] ? __switch_to+0x15f/0x580
[  348.152209]  [<ffffffffa02465dd>] xfs_file_write_iter+0x7d/0x120 [xfs]
[  348.153961]  [<ffffffff81178009>] new_sync_write+0x89/0xd0
[  348.155506]  [<ffffffff811787f2>] vfs_write+0xb2/0x1f0
[  348.157004]  [<ffffffff8101b994>] ? do_audit_syscall_entry+0x64/0x70
[  348.158715]  [<ffffffff81179440>] SyS_write+0x50/0xc0
[  348.160188]  [<ffffffff810f9ffe>] ? __audit_syscall_exit+0x22e/0x2d0

and this is the case for most a.out and b.out threads basically because
all of them contend on a single file. The holder of the lock right now
seems to be:

[  355.559722] b.out           R  running task        0  3843   3724 0x00000080
[  355.561700] MemAlloc: 21916 jiffies on 0x10
[  355.563056]  ffff88007c3f3808 ffff88007c3f37d8 ffff88007c3e4d60 00000000000130c0
[  355.565346]  ffff88007c3f3fd8 00000000000130c0 ffff88007c3e4d60 ffff880036f02b48
[  355.567440]  ffffffff81848588 0000000000000400 0000000000000000 ffff88007c3f39c8
[  355.569517] Call Trace:
[  355.570557]  [<ffffffff815bdc72>] _cond_resched+0x22/0x40
[  355.572167]  [<ffffffff811249f2>] shrink_node_slabs+0x242/0x310
[  355.573846]  [<ffffffff81127155>] shrink_zone+0x175/0x1c0
[  355.575410]  [<ffffffff81127590>] do_try_to_free_pages+0x1d0/0x3e0
[  355.577339]  [<ffffffff81127834>] try_to_free_pages+0x94/0xc0
[  355.579015]  [<ffffffff8111d4c5>] __alloc_pages_nodemask+0x535/0xaa0
[  355.580759]  [<ffffffff8115cf9c>] alloc_pages_current+0x8c/0x100
[  355.582446]  [<ffffffff811148f7>] __page_cache_alloc+0xa7/0xc0
[  355.584092]  [<ffffffff81115364>] pagecache_get_page+0x54/0x1b0
[  355.585773]  [<ffffffffa025d11e>] ? xfs_trans_commit+0x13e/0x230 [xfs]
[  355.587553]  [<ffffffff811154e8>] grab_cache_page_write_begin+0x28/0x50
[  355.589349]  [<ffffffffa023b04f>] xfs_vm_write_begin+0x2f/0xe0 [xfs]
[  355.591096]  [<ffffffff8111465c>] generic_perform_write+0xbc/0x1c0
[  355.592816]  [<ffffffffa024634f>] ? xfs_file_aio_write_checks+0xdf/0xf0 [xfs]
[  355.594718]  [<ffffffffa024642f>] xfs_file_buffered_aio_write.isra.15+0xcf/0x200 [xfs]

So it is trying to reclaim at least something but it will take some time
for it to realize this will not fly. The allocation will fail eventually,
though, because this is !__GFP_FS allocation and the same will apply to
a.out waiting for the lock as well.

$ grep "waited for.*select_bad_process" serial-20141230-ab-1.txt | sed 's@.*\((pid=.*waited for.*\) for.*@\1@' | sort | uniq -c
      1 (pid=2,flags=0x2000d0) waited for a.out(pid=3596,flags=0x0)
    809 (pid=3724,flags=0x280da) waited for a.out(pid=3596,flags=0x0)

[  351.915586] b.out           R  running task        0  3724   3572 0x00000080
[  351.917619] MemAlloc: 29906 jiffies on 0x10
[  351.919012]  ffff88007b8d7948 ffff88007fffc6c0 ffff88007c5751b0 00000000000130c0
[  351.921096]  ffff88007b8d7fd8 00000000000130c0 ffff88007c5751b0 0000000000000000
[  351.923228]  0000000000000000 00000000000280da 0000000000000002 0000000000000000
[  351.925374] Call Trace:
[  351.926466]  [<ffffffff815bdc72>] _cond_resched+0x22/0x40
[  351.928073]  [<ffffffff8111d477>] __alloc_pages_nodemask+0x4e7/0xaa0
[  351.929828]  [<ffffffff8115f302>] alloc_pages_vma+0x92/0x160
[  351.931502]  [<ffffffff8113fa11>] handle_mm_fault+0xbe1/0xed0
[  351.933171]  [<ffffffff815c2847>] ? native_iret+0x7/0x7
[  351.934719]  [<ffffffff8105502c>] __do_page_fault+0x1dc/0x5b0
[  351.936412]  [<ffffffff8111d125>] ? __alloc_pages_nodemask+0x195/0xaa0
[  351.938191]  [<ffffffff81055431>] do_page_fault+0x31/0x70
[  351.939769]  [<ffffffff815c3638>] page_fault+0x28/0x30
[  351.941322]  [<ffffffff812b1940>] ? __clear_user+0x20/0x50
[  351.942921]  [<ffffffff81139538>] iov_iter_zero+0x68/0x2f0
[  351.944503]  [<ffffffff8138a4e7>] read_iter_zero+0x47/0xb0
[  351.946135]  [<ffffffff81177f46>] new_sync_read+0x86/0xc0
[  351.947703]  [<ffffffff811791b3>] __vfs_read+0x13/0x50
[  351.949216]  [<ffffffff81179271>] vfs_read+0x81/0x140
[  351.950757]  [<ffffffff81179380>] SyS_read+0x50/0xc0
[  351.952277]  [<ffffffff810f9ffe>] ? __audit_syscall_exit+0x22e/0x2d0
[  351.953995]  [<ffffffff815c1c29>] system_call_fastpath+0x12/0x17

So the OOM blocked task is sitting in the page fault caused by clearing
the user buffer. According to your debugging patch this should be
GFP_HIGHUSER_MOVABLE | __GFP_ZERO allocation which is the case where we
retry without failing most of the time.
I am not familiar with the VFS code much but it seems we are not sitting
on any locks that would block the OOM victim later on (I am not entirely
sure about FDPUT_POS_UNLOCK from fdget_pos but all tasks are past this
calling it without blocking so it shouldn't matter). So even if the page
fault failed with ENOMEM it wouldn't help us much here.

That being said this doesn't look like a live lock or a lockup. System
should recover from this state but it might take a lot of time (there
are hundreds of tasks waiting on the i_mutex lock, each will try to
allocate and fail and OOM victims will have to get out of the kernel and
die). I am not sure we can do much about that from the allocator POV. A
possible way would be refraining from the reclaim efforts when it is
clear that nothing is really reclaimable. But I suspect this would be
tricky to get right.

> http://I-love.SAKURA.ne.jp/tmp/serial-20141230-ab-2.txt.xz is a case

[   44.588785] Out of memory: Kill process 3599 (a.out) score 773 or sacrifice child
[   44.590418] Killed process 3599 (a.out) total-vm:2166864kB, anon-rss:1488688kB, file-rss:4kB
[...]
[   44.640689] a.out: page allocation failure: order:0, mode:0x280da
[   44.640690] CPU: 2 PID: 3599 Comm: a.out Not tainted 3.19.0-rc2+ #20
[...]
[   44.641125] a.out: page allocation failure: order:0, mode:0x2015a
[   44.641126] CPU: 2 PID: 3599 Comm: a.out Not tainted 3.19.0-rc2+ #20

So the OOM victim is failing the allocation because we prevent endless
loops in the allocator for TIF_MEMDIE tasks and then it dies (it is not
among Sysrq+t output AFAICS). We still have to wait for all the tasks
sharing mm with it.

many of them are in:
[  402.300859] a.out           x ffff88007be53ce8     0  3601      1 0x00000086
[  402.303407]  ffff88007be53ce8 ffff88007c962450 ffff880078d10e60 00000000000130c0
[  402.305478]  ffff88007be53fd8 00000000000130c0 ffff880078d10e60 ffff880078d114a8
[  402.307519]  ffff880078d114a8 ffff880078d11170 ffff88007c0a9220 ffff880078d10e60
[  402.309547] Call Trace:
[  402.310551]  [<ffffffff815bd8c4>] schedule+0x24/0x70
[  402.312040]  [<ffffffff8106a4ea>] do_exit+0x6ba/0xb10
[  402.313531]  [<ffffffff8106b7da>] do_group_exit+0x3a/0xa0
[  402.315082]  [<ffffffff81075de8>] get_signal+0x188/0x690
[  402.316629]  [<ffffffff815bd43a>] ? __schedule+0x27a/0x6e0
[  402.318196]  [<ffffffff8100e4f2>] do_signal+0x32/0x750
[  402.319744]  [<ffffffffa02611c4>] ? _xfs_log_force_lsn+0xc4/0x2f0 [xfs]
[  402.321729]  [<ffffffffa0245489>] ? xfs_file_fsync+0x159/0x1b0 [xfs]
[  402.323461]  [<ffffffff8100ec5c>] do_notify_resume+0x4c/0x90
[  402.325135]  [<ffffffff815c1ec7>] int_signal+0x12/0x17

so they have already dropped reference to mm_struct but some of them are
still waiting in the write path to fail and exit:
[  402.271983] a.out           D ffff88007c047cb8     0  3600      1 0x00000084
[  402.273866]  ffff88007c047cb8 ffff88007c047c88 ffff8800793d8ba0 00000000000130c0
[  402.275872]  ffff88007c047fd8 00000000000130c0 ffff8800793d8ba0 ffff88007c047cb8
[  402.277878]  ffff88007ae56a48 ffff88007ae56a4c ffff8800793d8ba0 00000000ffffffff
[  402.279888] Call Trace:
[  402.280874]  [<ffffffff815bddb4>] schedule_preempt_disabled+0x24/0x70
[  402.282597]  [<ffffffff815bfb65>] __mutex_lock_slowpath+0xb5/0x120
[  402.284266]  [<ffffffff815bfbee>] mutex_lock+0x1e/0x32
[  402.285756]  [<ffffffffa02463ca>] xfs_file_buffered_aio_write.isra.15+0x6a/0x200 [xfs]
[  402.287741]  [<ffffffff8100d62f>] ? __switch_to+0x15f/0x580
[  402.289311]  [<ffffffffa02465dd>] xfs_file_write_iter+0x7d/0x120 [xfs]
[  402.291050]  [<ffffffff81178009>] new_sync_write+0x89/0xd0
[  402.292596]  [<ffffffff811787f2>] vfs_write+0xb2/0x1f0
[  402.294075]  [<ffffffff8101b994>] ? do_audit_syscall_entry+0x64/0x70
[  402.295774]  [<ffffffff81179440>] SyS_write+0x50/0xc0
[  402.297239]  [<ffffffff810f9ffe>] ? __audit_syscall_exit+0x22e/0x2d0
[  402.298947]  [<ffffffff815c1c29>] system_call_fastpath+0x12/0x17

while one of them is holding the lock:
[  402.736525] a.out           R  running task        0  3617      1 0x00000084
[  402.738452] MemAlloc: 358299 jiffies on 0x10
[  402.739812]  ffff88007ba63808 ffff88007ba637d8 ffff8800792f2510 00000000000130c0
[  402.741972]  ffff88007ba63fd8 00000000000130c0 ffff8800792f2510 ffff880078d1bb48
[  402.744029]  ffffffff81848588 0000000000000400 0000000000000000 ffff88007ba639c8
[  402.746135] Call Trace:
[  402.747153]  [<ffffffff815bdc72>] _cond_resched+0x22/0x40
[  402.748718]  [<ffffffff811249f2>] shrink_node_slabs+0x242/0x310
[  402.750432]  [<ffffffff81127155>] shrink_zone+0x175/0x1c0
[  402.751996]  [<ffffffff81127590>] do_try_to_free_pages+0x1d0/0x3e0
[  402.753686]  [<ffffffff81127834>] try_to_free_pages+0x94/0xc0
[  402.755325]  [<ffffffff8111d4c5>] __alloc_pages_nodemask+0x535/0xaa0
[  402.757057]  [<ffffffff8115cf9c>] alloc_pages_current+0x8c/0x100
[  402.758725]  [<ffffffff811148f7>] __page_cache_alloc+0xa7/0xc0
[  402.760362]  [<ffffffff81115364>] pagecache_get_page+0x54/0x1b0
[  402.762004]  [<ffffffff811154e8>] grab_cache_page_write_begin+0x28/0x50
[  402.763787]  [<ffffffffa023b04f>] xfs_vm_write_begin+0x2f/0xe0 [xfs]
[  402.765516]  [<ffffffff8111465c>] generic_perform_write+0xbc/0x1c0
[  402.767203]  [<ffffffffa024634f>] ? xfs_file_aio_write_checks+0xdf/0xf0 [xfs]
[  402.769078]  [<ffffffffa024642f>] xfs_file_buffered_aio_write.isra.15+0xcf/0x200 [xfs]

So this is basically the same as the previous one we just see it in a
slightly better shape because many threads managed to exit already.

> where I think a.out cannot die within reasonable duration due to b.out .

I am not sure you can have any reasonable time expectation with such a
huge contention on a single file. Even killing the task manually would
take quite some time I suspect. Sure, memory pressure makes it all much
worse.

> I don't know whether cgroups can help or not,

Memory cgroups would help you to limit the amount of anon memory but you
would have to be really careful about the potential overcomit due to
other allocations from outside of the restricted group. Not having any
swap doesn't help here either. It just moves all the reclaim pressure to
the file pages and slabs which struggle already.

> but I think we need to be prepared for cases where sending SIGKILL to
> all threads sharing the same memory does not help.

Sure, unkillable tasks are a problem which we have to handle. Having
GFP_KERNEL allocations looping without way out contributes to this which
is sad but your current data just show that sometimes it might take ages
to finish even without that going on.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
