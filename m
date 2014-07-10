Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C04B6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 03:39:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so10253189pde.26
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:39:07 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id ev3si47879632pbb.114.2014.07.10.00.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 00:39:05 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so10274490pdj.5
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:39:05 -0700 (PDT)
Date: Thu, 10 Jul 2014 00:37:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
In-Reply-To: <53BD67DC.9040700@oracle.com>
Message-ID: <alpine.LSU.2.11.1407092358090.18131@eggly.anvils>
References: <53b45c9b.2rlA0uGYBLzlXEeS%akpm@linux-foundation.org> <53BCBF1F.1000506@oracle.com> <alpine.LSU.2.11.1407082309040.7374@eggly.anvils> <53BD1053.5020401@suse.cz> <53BD39FC.7040205@oracle.com> <53BD67DC.9040700@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 9 Jul 2014, Sasha Levin wrote:
> On 07/09/2014 08:47 AM, Sasha Levin wrote:
> >> > So it would again help to see stacks of other tasks, to see who holds the i_mutex and where it's stuck...
> > The stacks print got garbled due to having large amount of tasks and too low of a
> > console buffer. I've fixed that and will update when (if) the problem reproduces.
> 
> Okay, so the issue reproduces on today's -next as well, and here's my analysis.
> 
> Hung task timer was triggered for trinity-c37:
> 
> [  483.991095] INFO: task trinity-c37:8968 blocked for more than 120 seconds.
> [  483.995898]       Not tainted 3.16.0-rc4-next-20140709-sasha-00024-gd22103d-dirty #775
> [  484.000405] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  484.004961] trinity-c37     D 00000000ffffffff 13160  8968   8558 0x10000000
> [  484.009035]  ffff8800c0457ce8 0000000000000006 ffffffff9ac1d920 0000000000000001
> [  484.012654]  ffff8800c0457fd8 00000000001e2740 00000000001e2740 00000000001e2740
> [  484.015716]  ffff880201610000 ffff8800c0bc3000 ffff8800c0457cd8 ffff880223115bb0
> [  484.050723] Call Trace:
> [  484.051831] schedule (kernel/sched/core.c:2841)
> [  484.053683] schedule_preempt_disabled (kernel/sched/core.c:2868)
> [  484.055979] mutex_lock_nested (kernel/locking/mutex.c:532 kernel/locking/mutex.c:584)
> [  484.058175] ? shmem_fallocate (mm/shmem.c:1760)
> [  484.060441] ? get_parent_ip (kernel/sched/core.c:2555)
> [  484.063899] ? shmem_fallocate (mm/shmem.c:1760)
> [  484.067485] shmem_fallocate (mm/shmem.c:1760)
> [  484.071113] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [  484.075128] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
> [  484.078566] SyS_madvise (mm/madvise.c:332 mm/madvise.c:381 mm/madvise.c:531 mm/madvise.c:462)
> [  484.082074] tracesys (arch/x86/kernel/entry_64.S:542)
> [  484.150284] 2 locks held by trinity-c37/8968:
> [  484.152995] #0: (sb_writers#16){.+.+.+}, at: do_fallocate (fs/open.c:298)
> [  484.158692] #1: (&sb->s_type->i_mutex_key#18){+.+.+.}, at: shmem_fallocate (mm/shmem.c:1760)
> 
> It has acquired sb_writers lock ("sb_start_write(inode->i_sb);") in do_fallocate and
> is blocking on an attempt to acquire i_mutex in shmem_fallocate():
> 
>         if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
>                 return -EOPNOTSUPP;
> 
>         mutex_lock(&inode->i_mutex); <=== HERE
> 
>         if (mode & FALLOC_FL_PUNCH_HOLE) {
> 
> Now, looking into what actually holds i_mutex rather than waiting on it we see trinity-c507:
> 
> [  488.014804] trinity-c507    D 0000000000000002 13112  9445   8558 0x10000002
> [  488.014860]  ffff88010391fab8 0000000000000002 ffffffff9abff6b0 0000000000000002
> [  488.014894]  ffff88010391ffd8 00000000001e2740 00000000001e2740 00000000001e2740
> [  488.014912]  ffff8800be3f8000 ffff88010389b000 ffff88010391faa8 ffff880223115d58
> [  488.014942] Call Trace:
> [  488.014948] schedule (kernel/sched/core.c:2841)
> [  488.014960] schedule_preempt_disabled (kernel/sched/core.c:2868)
> [  488.014970] mutex_lock_nested (kernel/locking/mutex.c:532 kernel/locking/mutex.c:584)
> [  488.014983] ? unmap_mapping_range (mm/memory.c:2392)
> [  488.014992] ? unmap_mapping_range (mm/memory.c:2392)
> [  488.015005] unmap_mapping_range (mm/memory.c:2392)
> [  488.015021] truncate_inode_page (mm/truncate.c:136 mm/truncate.c:180)
> [  488.015041] shmem_undo_range (mm/shmem.c:441)
> [  488.015059] shmem_truncate_range (mm/shmem.c:537)
> [  488.015069] shmem_fallocate (mm/shmem.c:1771)
> [  488.015079] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [  488.015098] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
> [  488.015110] SyS_madvise (mm/madvise.c:332 mm/madvise.c:381 mm/madvise.c:531 mm/madvise.c:462)
> [  488.015131] tracesys (arch/x86/kernel/entry_64.S:542)
> 
> It has acquired i_mutex lock in shmem_fallocate() and is now blocking on i_mmap_mutex
> in unmap_mapping_range():
> 
>         details.check_mapping = even_cows? NULL: mapping;
>         details.nonlinear_vma = NULL;
>         details.first_index = hba;
>         details.last_index = hba + hlen - 1;
>         if (details.last_index < details.first_index)
>                 details.last_index = ULONG_MAX;
> 
> 
>         mutex_lock(&mapping->i_mmap_mutex); <==== HERE
>         if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>                 unmap_mapping_range_tree(&mapping->i_mmap, &details);

I agree with your analysis up to here.

> 
> The only process that actually holds a i_mmap_mutex (instead of just spinning on it)
> is trinity-c402:

But not here.  trinity-c402 would not be holding i_mmap_mutex when it
does the zap_pte_range for exit_mmap below.  Callers of zap_pte_range
coming from unmap_mapping_range would hold i_mmap_mutex, but that's
not the case for exit_mmap.

I realize that the later part of the log shows
    1 lock held by trinity-c402/9339:
    #0: (&mapping->i_mmap_mutex){+.+...}, at: unlink_file_vma (mm/mmap.c:245)
but that's because trinity-c402 completed its unmap_vmas, and had
advanced to free_pgtables by the time that part of the log got written -
given the horrid misfeature that locks being tried are reported as held.

(There are a few other cases where the task has advanced in between
the stack dump and the locks held dump e.g. -c29, -c83, -c87.)

So I think our focus on zap_pte_range was mistaken.

I did not find who was holding the i_mmap_mutex so many are waiting for.
I could easily have missed it, but my suspicion is that nobody holds it,
that it merely got corrupted so that nobody can take it.

I do think that the most useful thing you could do at the moment,
is to switch away from running trinity on -next temporarily, and
run it instead on Linus's current git or on 3.16-rc4, but with
f00cdc6df7d7 reverted and my "take 2" inserted in its place.

That tree would also include Heiko's seq_buf_alloc() patch, which
trinity on -next has cast similar doubt upon: at present, we do
not know if Heiko's patch and my patch are bad in themselves,
or exposing other bugs in 3.16-rc, or exposing bugs in -next.

Hugh

> 
> [  487.925991] trinity-c402    R  running task    13160  9339   8558 0x10000000
> [  487.926007]  ffff8800b7eb7b88 0000000000000002 ffff88006efe3290 0000000000000282
> [  487.926013]  ffff8800b7eb7fd8 00000000001e2740 00000000001e2740 00000000001e2740
> [  487.926022]  ffff8800362b3000 ffff8800b7eb8000 ffff8800b7eb7b88 ffff8800b7eb7fd8
> [  487.926028] Call Trace:
> [  487.926030] preempt_schedule (./arch/x86/include/asm/preempt.h:80 kernel/sched/core.c:2889)
> [  487.926034] ___preempt_schedule (arch/x86/kernel/preempt.S:11)
> [  487.926039] ? zap_pte_range (mm/memory.c:1218)
> [  487.926042] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> [  487.926045] ? _raw_spin_unlock (include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> [  487.926049] zap_pte_range (mm/memory.c:1218)
> [  487.926056] unmap_single_vma (mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301 mm/memory.c:1346)
> [  487.926060] unmap_vmas (mm/memory.c:1375 (discriminator 1))
> [  487.926066] exit_mmap (mm/mmap.c:2802)
> [  487.926069] ? preempt_count_sub (kernel/sched/core.c:2611)
> [  487.926075] mmput (kernel/fork.c:638)
> [  487.926079] do_exit (kernel/exit.c:744)
> [  487.926086] do_group_exit (kernel/exit.c:884)
> [  487.926091] SyS_exit_group (kernel/exit.c:895)
> [  487.926095] tracesys (arch/x86/kernel/entry_64.S:542)
> 
> We can see that it's not blocked since it's in the middle of a spinlock unlock
> call, and we can guess it's been in that function for a while because of the hung
> task timer, and other processes waiting on that i_mmap_mutex:
> 
> 
> [  487.857145] trinity-c338    D 0000000000000008 12904  9274   8558 0x10000004
> [  487.857179]  ffff8800b9bcbaa8 0000000000000002 ffffffff9abff6b0 0000000000000000
> [  487.857193]  ffff8800b9bcbfd8 00000000001e2740 00000000001e2740 00000000001e2740
> [  487.857202]  ffff880107198000 ffff8800b9bc0000 ffff8800b9bcba98 ffff8801ec17f090
> [  487.857209] Call Trace:
> [  487.857210] schedule (kernel/sched/core.c:2841)
> [  487.857222] schedule_preempt_disabled (kernel/sched/core.c:2868)
> [  487.857228] mutex_lock_nested (kernel/locking/mutex.c:532 kernel/locking/mutex.c:584)
> [  487.857237] ? unlink_file_vma (mm/mmap.c:245)
> [  487.857241] ? unlink_file_vma (mm/mmap.c:245)
> [  487.857251] unlink_file_vma (mm/mmap.c:245)
> [  487.857261] free_pgtables (mm/memory.c:540)
> [  487.857275] exit_mmap (mm/mmap.c:2803)
> [  487.857284] ? preempt_count_sub (kernel/sched/core.c:2611)
> [  487.857291] mmput (kernel/fork.c:638)
> [  487.857305] do_exit (kernel/exit.c:744)
> [  487.857317] ? get_signal_to_deliver (kernel/signal.c:2333)
> [  487.857327] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
> [  487.857339] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [  487.857351] ? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
> [  487.857362] do_group_exit (kernel/exit.c:884)
> [  487.857376] get_signal_to_deliver (kernel/signal.c:2351)
> [  487.857392] do_signal (arch/x86/kernel/signal.c:698)
> [  487.857399] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [  487.857411] ? vtime_account_user (kernel/sched/cputime.c:687)
> [  487.857418] ? preempt_count_sub (kernel/sched/core.c:2611)
> [  487.857431] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
> [  487.857441] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  487.857451] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
> [  487.857464] do_notify_resume (arch/x86/kernel/signal.c:751)
> [  487.857479] int_signal (arch/x86/kernel/entry_64.S:600)
> 
> Hope that helps. Full log attached for reference.
> 
> 
> Thanks,
> Sasha
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
