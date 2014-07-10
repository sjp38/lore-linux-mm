Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CF9886B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 13:27:16 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11319475pab.6
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 10:27:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tk10si49004120pab.212.2014.07.10.10.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 10:27:15 -0700 (PDT)
Message-ID: <53BECBA4.3010508@oracle.com>
Date: Thu, 10 Jul 2014 13:21:40 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com> <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com>
In-Reply-To: <53BE8B1B.3000808@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/10/2014 08:46 AM, Sasha Levin wrote:
> On 07/10/2014 03:37 AM, Hugh Dickins wrote:
>> > I do think that the most useful thing you could do at the moment,
>> > is to switch away from running trinity on -next temporarily, and
>> > run it instead on Linus's current git or on 3.16-rc4, but with
>> > f00cdc6df7d7 reverted and my "take 2" inserted in its place.
>> > 
>> > That tree would also include Heiko's seq_buf_alloc() patch, which
>> > trinity on -next has cast similar doubt upon: at present, we do
>> > not know if Heiko's patch and my patch are bad in themselves,
>> > or exposing other bugs in 3.16-rc, or exposing bugs in -next.
> Funny enough, Linus's tree doesn't even boot properly here. It's
> going to take longer than I expected...

While I'm failing to reproduce the mountinfo issue on Linus's tree,
the shmem_fallocate one reproduces rather easily.

I've reverted your original fix and applied the "take 2" one as you
suggested, there are no other significant changes on top on Linus's
tree in this case (just Heiko's test patch and some improvements to
what gets printed on hung tasks plus an assortment on unrelated fixes
that are present in next).

The same structure of locks that was analysed in -next exists here
as well:

Triggered here:

[  364.601210] INFO: task trinity-c214:9083 blocked for more than 120 seconds.
[  364.605498]       Not tainted 3.16.0-rc4-sasha-00069-g615ded7-dirty #793
[  364.609705] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  364.614939] trinity-c214    D 0000000000000002 13528  9083   8490 0x00000000
[  364.619414]  ffff880018757ce8 0000000000000002 ffffffff91a01d70 0000000000000001
[  364.624540]  ffff880018757fd8 00000000001d7740 00000000001d7740 00000000001d7740
[  364.629378]  ffff880006428000 ffff880018758000 ffff880018757cd8 ffff880031fdc210
[  364.650601] Call Trace:
[  364.652252] schedule (kernel/sched/core.c:2832)
[  364.655337] schedule_preempt_disabled (kernel/sched/core.c:2859)
[  364.659287] mutex_lock_nested (kernel/locking/mutex.c:535 kernel/locking/mutex.c:587)
[  364.663131] ? shmem_fallocate (mm/shmem.c:1738)
[  364.666616] ? get_parent_ip (kernel/sched/core.c:2546)
[  364.670454] ? shmem_fallocate (mm/shmem.c:1738)
[  364.674159] shmem_fallocate (mm/shmem.c:1738)
[  364.676589] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  364.678415] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  364.680806] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  364.684206] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
[  364.687313] SyS_madvise (mm/madvise.c:335 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  364.690343] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  364.692913] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  364.694450] tracesys (arch/x86/kernel/entry_64.S:543)
[  364.696034] 2 locks held by trinity-c214/9083:
[  364.697222] #0: (sb_writers#9){.+.+.+}, at: do_fallocate (fs/open.c:298)
[  364.700686] #1: (&sb->s_type->i_mutex_key#16){+.+.+.}, at: shmem_fallocate (mm/shmem.c:1738)

Holding i_mutex and blocking on i_mmap_mutex:

[  367.615992] trinity-c100    R  running task    13048  8967   8490 0x00000006
[  367.616039]  ffff88001b903978 0000000000000002 0000000000000006 ffff880404666fd8
[  367.616075]  ffff88001b903fd8 00000000001d7740 00000000001d7740 00000000001d7740
[  367.616113]  ffff880007a40000 ffff88001b8f8000 ffff88001b903968 ffff88001b903fd8
[  367.616152] Call Trace:
[  367.616165] preempt_schedule_irq (./arch/x86/include/asm/paravirt.h:814 kernel/sched/core.c:2912)
[  367.616182] retint_kernel (arch/x86/kernel/entry_64.S:937)
[  367.616198] ? unmap_single_vma (mm/memory.c:1230 mm/memory.c:1277 mm/memory.c:1302 mm/memory.c:1348)
[  367.616213] ? unmap_single_vma (mm/memory.c:1297 mm/memory.c:1348)
[  367.616226] zap_page_range_single (include/linux/mmu_notifier.h:234 mm/memory.c:1429)
[  367.616240] ? get_parent_ip (kernel/sched/core.c:2546)
[  367.616260] ? unmap_mapping_range (mm/memory.c:2391)
[  367.616267] unmap_mapping_range (mm/memory.c:2316 mm/memory.c:2392)
[  367.616271] truncate_inode_page (mm/truncate.c:136 mm/truncate.c:180)
[  367.616281] shmem_undo_range (mm/shmem.c:429)
[  367.616289] shmem_truncate_range (mm/shmem.c:528)
[  367.616296] shmem_fallocate (mm/shmem.c:1749)
[  367.616301] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.616307] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  367.616314] ? SyS_madvise (mm/madvise.c:334 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.616320] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
[  367.616326] SyS_madvise (mm/madvise.c:335 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[  367.616333] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  367.616340] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  367.616345] tracesys (arch/x86/kernel/entry_64.S:543)

And finally, (not) holding the i_mmap_mutex:

[  367.638911] trinity-c190    R  running task    12680  9059   8490 0x00000004
[  367.638928]  ffff8800193db828 0000000000000002 0000000000000030 0000000000000000
[  367.638937]  ffff8800193dbfd8 00000000001d7740 00000000001d7740 00000000001d7740
[  367.638943]  ffff8800048eb000 ffff8800193d0000 ffff8800193db818 ffff8800193dbfd8
[  367.638950] Call Trace:
[  367.638952]  [<ffffffff8e5170f4>] preempt_schedule_irq+0x84/0x100
[  367.638956]  [<ffffffff8e51ec50>] retint_kernel+0x20/0x30
[  367.638960]  [<ffffffff8b290c36>] ? free_hot_cold_page+0x1c6/0x1f0
[  367.638962]  [<ffffffff8b291566>] free_hot_cold_page_list+0x126/0x1a0
[  367.638974]  [<ffffffff8b29702e>] release_pages+0x21e/0x250
[  367.638989]  [<ffffffff8b2cf0c5>] free_pages_and_swap_cache+0x55/0xc0
[  367.638999]  [<ffffffff8b2b68ac>] tlb_flush_mmu_free+0x4c/0x60
[  367.639012]  [<ffffffff8b2b8dd1>] zap_pte_range+0x491/0x4f0
[  367.639019]  [<ffffffff8b2b92ce>] unmap_single_vma+0x49e/0x4c0
[  367.639025]  [<ffffffff8b2b9675>] unmap_vmas+0x65/0x90
[  367.639029]  [<ffffffff8b2c3344>] exit_mmap+0xd4/0x180
[  367.639032]  [<ffffffff8b15c4ab>] mmput+0x5b/0xf0
[  367.639038]  [<ffffffff8b163043>] do_exit+0x3a3/0xc80
[  367.639041]  [<ffffffff8bb46d37>] ? debug_smp_processor_id+0x17/0x20
[  367.639044]  [<ffffffff8b1c2fae>] ? put_lock_stats.isra.12+0xe/0x30
[  367.639047]  [<ffffffff8e51d100>] ? _raw_spin_unlock_irq+0x30/0x70
[  367.639051]  [<ffffffff8b1639f4>] do_group_exit+0x84/0xd0
[  367.639055]  [<ffffffff8b177657>] get_signal_to_deliver+0x807/0x910
[  367.639059]  [<ffffffff8b1a6eb8>] ? vtime_account_user+0x98/0xb0
[  367.639063]  [<ffffffff8b0706c7>] do_signal+0x57/0x9a0
[  367.639066]  [<ffffffff8b1a6eb8>] ? vtime_account_user+0x98/0xb0
[  367.639070]  [<ffffffff8b19f228>] ? preempt_count_sub+0xd8/0x130
[  367.639072]  [<ffffffff8b2848d5>] ? context_tracking_user_exit+0x1b5/0x260
[  367.639078]  [<ffffffff8bb46d13>] ? __this_cpu_preempt_check+0x13/0x20
[  367.639081]  [<ffffffff8b1c5df4>] ? trace_hardirqs_on_caller+0x1f4/0x290
[  367.639087]  [<ffffffff8b07104a>] do_notify_resume+0x3a/0xb0
[  367.639089]  [<ffffffff8e51e02a>] int_signal+0x12/0x17


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
