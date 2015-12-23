Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E14F782F99
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 18:00:11 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id o67so228536044iof.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:00:11 -0800 (PST)
Received: from mail-ig0-x242.google.com (mail-ig0-x242.google.com. [2607:f8b0:4001:c05::242])
        by mx.google.com with ESMTPS id j6si2676889igu.98.2015.12.23.15.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 15:00:09 -0800 (PST)
Received: by mail-ig0-x242.google.com with SMTP id rx7so11523717igc.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:00:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
Date: Wed, 23 Dec 2015 16:00:09 -0700
Message-ID: <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Ross Zwisler <zwisler@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Dec 15, 2015 at 11:36 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
>
> The OOM killer currently allows to kill only a single task in a good
> hope that the task will terminate in a reasonable time and frees up its
> memory.  Such a task (oom victim) will get an access to memory reserves
> via mark_oom_victim to allow a forward progress should there be a need
> for additional memory during exit path.
>
> It has been shown (e.g. by Tetsuo Handa) that it is not that hard to
> construct workloads which break the core assumption mentioned above and
> the OOM victim might take unbounded amount of time to exit because it
> might be blocked in the uninterruptible state waiting for on an event
> (e.g. lock) which is blocked by another task looping in the page
> allocator.
>
> This patch reduces the probability of such a lockup by introducing a
> specialized kernel thread (oom_reaper) which tries to reclaim additional
> memory by preemptively reaping the anonymous or swapped out memory
> owned by the oom victim under an assumption that such a memory won't
> be needed when its owner is killed and kicked from the userspace anyway.
> There is one notable exception to this, though, if the OOM victim was
> in the process of coredumping the result would be incomplete. This is
> considered a reasonable constrain because the overall system health is
> more important than debugability of a particular application.
>
> A kernel thread has been chosen because we need a reliable way of
> invocation so workqueue context is not appropriate because all the
> workers might be busy (e.g. allocating memory). Kswapd which sounds
> like another good fit is not appropriate as well because it might get
> blocked on locks during reclaim as well.
>
> oom_reaper has to take mmap_sem on the target task for reading so the
> solution is not 100% because the semaphore might be held or blocked for
> write but the probability is reduced considerably wrt. basically any
> lock blocking forward progress as described above. In order to prevent
> from blocking on the lock without any forward progress we are using only
> a trylock and retry 10 times with a short sleep in between.
> Users of mmap_sem which need it for write should be carefully reviewed
> to use _killable waiting as much as possible and reduce allocations
> requests done with the lock held to absolute minimum to reduce the risk
> even further.
>
> The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
> updates mm_to_reap with cmpxchg to guarantee only NULL->mm transition
> and oom_reaper clear this atomically once it is done with the work. This
> means that only a single mm_struct can be reaped at the time. As the
> operation is potentially disruptive we are trying to limit it to the
> ncessary minimum and the reaper blocks any updates while it operates on
> an mm. mm_struct is pinned by mm_count to allow parallel exit_mmap and a
> race is detected by atomic_inc_not_zero(mm_users).
>
> Changes since v2
> - fix mm_count refernce leak reported by Tetsuo
> - make sure oom_reaper_th is NULL after kthread_run fails - Tetsuo
> - use wait_event_freezable rather than open coded wait loop - suggested
>   by Tetsuo
> Changes since v1
> - fix the screwed up detail->check_swap_entries - Johannes
> - do not use kthread_should_stop because that would need a cleanup
>   and we do not have anybody to stop us - Tetsuo
> - move wake_oom_reaper to oom_kill_process because we have to wait
>   for all tasks sharing the same mm to get killed - Tetsuo
> - do not reap mm structs which are shared with unkillable tasks - Tetsuo
>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

While running xfstests on next-20151223 I hit a pair of kernel BUGs
that bisected to this commit:

1eb3a80d8239 ("mm, oom: introduce oom reaper")

Here is a BUG produced by generic/029 when run against XFS:

[  235.751723] ------------[ cut here ]------------
[  235.752194] kernel BUG at mm/filemap.c:208!
[  235.752595] invalid opcode: 0000 [#1] SMP
[  235.753036] Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
[  235.753681] CPU: 3 PID: 17586 Comm: xfs_io Not tainted
4.4.0-rc6-next-20151223_new_fsync_v6+ #8
[  235.754535] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140709_153950- 04/01/2014
[  235.755451] task: ffff88040bde19c0 ti: ffff8800bab80000 task.ti:
ffff8800bab80000
[  235.756202] RIP: 0010:[<ffffffff811c81f6>]  [<ffffffff811c81f6>]
__delete_from_page_cache+0x206/0x440
[  235.757151] RSP: 0018:ffff8800bab83b60  EFLAGS: 00010082
[  235.757679] RAX: 0000000000000021 RBX: ffffea0007d37e00 RCX: 0000000000000006
[  235.758360] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8804117ce380
[  235.759043] RBP: ffff8800bab83bb8 R08: 0000000000000001 R09: 0000000000000001
[  235.759749] R10: 00000000ffffffff R11: 0000000000028dc0 R12: ffff8800b1e7db00
[  235.760444] R13: ffff8800b1e7daf8 R14: 0000000000000000 R15: 0000000000000003
[  235.761122] FS:  00007f65dd009700(0000) GS:ffff880411600000(0000)
knlGS:0000000000000000
[  235.761888] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  235.762432] CR2: 00007f65dd01f000 CR3: 00000000ba9d7000 CR4: 00000000000406e0
[  235.763150] Stack:
[  235.763347]  ffff88040cf1a800 0000000000000001 0000000000000001
ffff8800ae2a3b50
[  235.764123]  ffff8800ae2a3b80 00000000b4ca5e1a ffffea0007d37e00
ffff8800b1e7db10
[  235.764900]  ffff88040cf1a800 0000000000000000 0000000000000292
ffff8800bab83bf0
[  235.765638] Call Trace:
[  235.765903]  [<ffffffff811c8493>] delete_from_page_cache+0x63/0xd0
[  235.766513]  [<ffffffff811dc3e5>] truncate_inode_page+0xa5/0x120
[  235.767088]  [<ffffffff811dc648>] truncate_inode_pages_range+0x1a8/0x7f0
[  235.767725]  [<ffffffff81021459>] ? sched_clock+0x9/0x10
[  235.768239]  [<ffffffff810db37c>] ? local_clock+0x1c/0x20
[  235.768779]  [<ffffffff811feba4>] ? unmap_mapping_range+0x64/0x130
[  235.769385]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130
[  235.770010]  [<ffffffff810f5c3f>] ? up_write+0x1f/0x40
[  235.770501]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130
[  235.771092]  [<ffffffff811dcd58>] truncate_pagecache+0x48/0x70
[  235.771646]  [<ffffffff811dcdb2>] truncate_setsize+0x32/0x40
[  235.772276]  [<ffffffff8148e972>] xfs_setattr_size+0x232/0x470
[  235.772839]  [<ffffffff8148ec64>] xfs_vn_setattr+0xb4/0xc0
[  235.773369]  [<ffffffff8127af87>] notify_change+0x237/0x350
[  235.773945]  [<ffffffff81257c87>] do_truncate+0x77/0xc0
[  235.774446]  [<ffffffff8125800f>] do_sys_ftruncate.constprop.15+0xef/0x150
[  235.775156]  [<ffffffff812580ae>] SyS_ftruncate+0xe/0x10
[  235.775650]  [<ffffffff81a527b2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  235.776257] Code: 5f 5d c3 48 8b 43 20 48 8d 78 ff a8 01 48 0f 44
fb 8b 47 48 85 c0 0f 88 2b 01 00 00 48 c7 c6 a8 57 f0 81 48 89 df e8
fa 1a 03 00 <0f> 0b 4c 89 ce 44 89 fa 4c 89 e7 4c 89 45 b0 4c 89 4d b8
e8 32
[  235.778695] RIP  [<ffffffff811c81f6>] __delete_from_page_cache+0x206/0x440
[  235.779350]  RSP <ffff8800bab83b60>
[  235.779694] ---[ end trace fac9dd65c4cdd828 ]---

And a different BUG produced by generic/095, also with XFS:

[  609.398897] ------------[ cut here ]------------
[  609.399843] kernel BUG at mm/truncate.c:629!
[  609.400666] invalid opcode: 0000 [#1] SMP
[  609.401512] Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
[  609.402719] CPU: 4 PID: 26782 Comm: fio Tainted: G        W
4.4.0-rc6-next-20151223+ #1
[  609.404267] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140709_153950- 04/01/2014
[  609.405851] task: ffff8801e52119c0 ti: ffff8801f6540000 task.ti:
ffff8801f6540000
[  609.407272] RIP: 0010:[<ffffffff811dc0ab>]  [<ffffffff811dc0ab>]
invalidate_inode_pages2_range+0x30b/0x550
[  609.409111] RSP: 0018:ffff8801f6543c88  EFLAGS: 00010202
[  609.410105] RAX: 0000000000000001 RBX: 0000000000000061 RCX: ffff88041180e440
[  609.411417] RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
[  609.412737] RBP: ffff8801f6543dd0 R08: 0000000000000008 R09: 0000000000000001
[  609.414069] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8801f6dfb438
[  609.415388] R13: ffffffffffffffff R14: 000000000000000b R15: ffffea0002877c80
[  609.416681] FS:  00007f48e13ed740(0000) GS:ffff880411800000(0000)
knlGS:0000000000000000
[  609.418190] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  609.419261] CR2: 00000000012e0000 CR3: 000000040f24c000 CR4: 00000000000406e0
[  609.420577] Stack:
[  609.420968]  0000000000000292 ffff8800ba6f7800 ffff8801f6dfb450
0000000000000000
[  609.422423]  0000000000000001 0000000000000056 0000000000000057
0000000000000058
[  609.423878]  0000000000000059 000000000000005a 000000000000005b
000000000000005c
[  609.425325] Call Trace:
[  609.425797]  [<ffffffff811dc307>] invalidate_inode_pages2+0x17/0x20
[  609.426971]  [<ffffffff81482167>] xfs_file_read_iter+0x297/0x300
[  609.428097]  [<ffffffff81259ac9>] __vfs_read+0xc9/0x100
[  609.429073]  [<ffffffff8125a319>] vfs_read+0x89/0x130
[  609.430010]  [<ffffffff8125b418>] SyS_read+0x58/0xd0
[  609.430943]  [<ffffffff81a527b2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  609.432139] Code: 85 d8 fe ff ff 01 00 00 00 f6 c4 40 0f 84 59 ff
ff ff 49 8b 47 20 48 8d 78 ff a8 01 49 0f 44 ff 8b 47 48 85 c0 0f 88
bd 01 00 00 <0f> 0b 4d 3b 67 08 0f 85 70 ff ff ff 49 f7 07 00 18 00 00
74 15
[  609.436956] RIP  [<ffffffff811dc0ab>]
invalidate_inode_pages2_range+0x30b/0x550
[  609.438373]  RSP <ffff8801f6543c88>
[  609.439080] ---[ end trace 10616a16523ccb2c ]---

They both fail 100% of the time with the above signatures with the
"oom reaper" commit, and succeed 100% of the time with the parent
commit.

My test setup is a qemu guest machine with a pair of 4 GiB PMEM
ramdisk test devices, one for the xfstest test disk and one for the
scratch disk.

Please let me know if you have trouble reproducing this.  I'm also
happy to test fixes.

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
