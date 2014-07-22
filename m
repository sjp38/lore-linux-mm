Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 988886B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 23:27:18 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so10928353pad.8
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:27:18 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xc3si16187647pab.114.2014.07.21.20.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 20:27:17 -0700 (PDT)
Message-ID: <53CDD961.1080006@oracle.com>
Date: Mon, 21 Jul 2014 23:24:17 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com> <alpine.LSU.2.11.1407191628450.24073@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407191628450.24073@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/19/2014 07:44 PM, Hugh Dickins wrote:
>> Otherwise, I've been unable to reproduce the shmem_fallocate hang.
> Great.  Andrew, I think we can say that it's now safe to send
> 1/2 shmem: fix faulting into a hole, not taking i_mutex
> 2/2 shmem: fix splicing from a hole while it's punched
> on to Linus whenever suits you.
> 
> (You have some other patches in the mainline-later section of the
> mmotm/series file: they're okay too, but not in doubt as these two were.)

I think we may need to hold off on sending them...

It seems that this code in shmem_fault():

	/*
	 * shmem_falloc_waitq points into the shmem_fallocate()
	 * stack of the hole-punching task: shmem_falloc_waitq
	 * is usually invalid by the time we reach here, but
	 * finish_wait() does not dereference it in that case;
	 * though i_lock needed lest racing with wake_up_all().
	 */
	spin_lock(&inode->i_lock);
	finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
	spin_unlock(&inode->i_lock);

Is problematic. I'm not sure what changed, but it seems to be causing everything
from NULL ptr derefs:

[  169.922536] BUG: unable to handle kernel NULL pointer dereference at 0000000000000631
[  169.925638] IP: __lock_acquire (./arch/x86/include/asm/atomic.h:92 kernel/locking/lockdep.c:3082)
[  169.927845] PGD 1d38af067 PUD 1d38b0067 PMD 0
[  169.929644] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  169.930082] Dumping ftrace buffer:
[  169.930082]    (ftrace buffer empty)
[  169.930082] Modules linked in:
[  169.930082] CPU: 14 PID: 8824 Comm: trinity-c53 Tainted: G        W      3.16.0-rc5-next-20140721-sasha-00051-g258dfea-dirty #925
[  169.930082] task: ffff8801d3893000 ti: ffff8801d38f8000 task.ti: ffff8801d38f8000
[  169.930082] RIP: __lock_acquire (./arch/x86/include/asm/atomic.h:92 kernel/locking/lockdep.c:3082)
[  169.930082] RSP: 0000:ffff8801d38fb6c0  EFLAGS: 00010006
[  169.930082] RAX: 0000000000000000 RBX: ffff8801d3893000 RCX: 0000000000000001
[  169.930082] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8801b2b13d98
[  169.930082] RBP: ffff8801d38fb728 R08: 0000000000000001 R09: 0000000000000001
[  169.930082] R10: 0000000000000499 R11: 0000000000000001 R12: 0000000000000000
[  169.930082] R13: 0000000000000000 R14: 0000000000000000 R15: ffff8801b2b13d98
[  169.930082] FS:  00007f9e6374a700(0000) GS:ffff880548e00000(0000) knlGS:0000000000000000
[  169.930082] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  169.930082] CR2: 0000000000000631 CR3: 00000001d38ae000 CR4: 00000000000006a0
[  169.930082] Stack:
[  169.930082]  ffff8801d3893000 ffff8801d3893000 ffffffffa6053bf0 0000000000000290
[  169.930082]  0000000000000000 ffff8801d38fb760 ffffffff9f1d0be2 ffffffff9f1cdbdb
[  169.930082]  ffff8801b2b13d80 0000000000000000 0000000000000000 0000000000000001
[  169.930082] Call Trace:
[  169.930082] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[  169.930082] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[  169.930082] lock_acquire (./arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  169.930082] ? finish_wait (include/linux/list.h:144 kernel/sched/wait.c:251)
[  169.930082] _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
[  169.930082] ? finish_wait (include/linux/list.h:144 kernel/sched/wait.c:251)
[  169.930082] finish_wait (include/linux/list.h:144 kernel/sched/wait.c:251)
[  169.930082] shmem_fault (include/linux/spinlock.h:343 mm/shmem.c:1327)
[  169.930082] ? __wait_on_bit_lock (kernel/sched/wait.c:291)
[  169.930082] __do_fault (mm/memory.c:2713)
[  169.930082] do_read_fault.isra.40 (mm/memory.c:2905)
[  169.930082] handle_mm_fault (mm/memory.c:3092 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
[  169.930082] ? __lock_is_held (kernel/locking/lockdep.c:3516)
[  170.003723] __do_page_fault (arch/x86/mm/fault.c:1231)
[  170.003723] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[  170.003723] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  170.003723] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2639 (discriminator 8))
[  170.003723] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[  170.003723] do_async_page_fault (arch/x86/kernel/kvm.c:279)
[  170.003723] async_page_fault (arch/x86/kernel/entry_64.S:1321)
[  170.003723] ? copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:137)
[  170.003723] ? copy_page_from_iter_iovec (mm/iov_iter.c:141)
[  170.003723] copy_page_from_iter (mm/iov_iter.c:668)
[  170.003723] process_vm_rw_core.isra.2 (mm/process_vm_access.c:50 mm/process_vm_access.c:114 mm/process_vm_access.c:213)
[  170.003723] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3769)
[  170.003723] ? might_fault (mm/memory.c:3770)
[  170.003723] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3769)
[  170.003723] ? rw_copy_check_uvector (fs/read_write.c:758)
[  170.003723] process_vm_rw (mm/process_vm_access.c:287)
[  170.003723] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  170.003723] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  170.003723] ? vtime_account_user (kernel/sched/cputime.c:687)
[  170.003723] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  170.003723] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  170.003723] ? syscall_trace_enter (include/trace/events/syscalls.h:16 arch/x86/kernel/ptrace.c:1488)
[  170.003723] SyS_process_vm_writev (mm/process_vm_access.c:302)
[  170.003723] tracesys (arch/x86/kernel/entry_64.S:541)
[ 170.003723] Code: 49 81 3f 00 3e 97 a5 b8 00 00 00 00 44 0f 44 c0 41 83 fe 01 0f 87 e5 fe ff ff 44 89 f0 4d 8b 54 c7 08 4d 85 d2 0f 84 d4 fe ff ff <f0> 41 ff 82 98 01 00 00 8b 8b f0 0c 00 00 83 f9 2f 76 0e 8b 05
All code
========
   0:   49 81 3f 00 3e 97 a5    cmpq   $0xffffffffa5973e00,(%r15)
   7:   b8 00 00 00 00          mov    $0x0,%eax
   c:   44 0f 44 c0             cmove  %eax,%r8d
  10:   41 83 fe 01             cmp    $0x1,%r14d
  14:   0f 87 e5 fe ff ff       ja     0xfffffffffffffeff
  1a:   44 89 f0                mov    %r14d,%eax
  1d:   4d 8b 54 c7 08          mov    0x8(%r15,%rax,8),%r10
  22:   4d 85 d2                test   %r10,%r10
  25:   0f 84 d4 fe ff ff       je     0xfffffffffffffeff
  2b:*  f0 41 ff 82 98 01 00    lock incl 0x198(%r10)           <-- trapping instruction
  32:   00
  33:   8b 8b f0 0c 00 00       mov    0xcf0(%rbx),%ecx
  39:   83 f9 2f                cmp    $0x2f,%ecx
  3c:   76 0e                   jbe    0x4c
  3e:   8b                      .byte 0x8b
  3f:   05                      .byte 0x5
        ...

Code starting with the faulting instruction
===========================================
   0:   f0 41 ff 82 98 01 00    lock incl 0x198(%r10)
   7:   00
   8:   8b 8b f0 0c 00 00       mov    0xcf0(%rbx),%ecx
   e:   83 f9 2f                cmp    $0x2f,%ecx
  11:   76 0e                   jbe    0x21
  13:   8b                      .byte 0x8b
  14:   05                      .byte 0x5
        ...
[  170.003723] RIP __lock_acquire (./arch/x86/include/asm/atomic.h:92 kernel/locking/lockdep.c:3082)
[  170.003723]  RSP <ffff8801d38fb6c0>
[  170.003723] CR2: 0000000000000631

To memory corruptions:

[ 1031.264226] BUG: spinlock bad magic on CPU#1, trinity-c99/25740
[ 1031.265632]  lock: 0xffff88038023fd80, .magic: ffff8802, .owner: %<C0><DA>/1711276032, .owner_cpu: 0
[ 1031.267000] CPU: 1 PID: 25740 Comm: trinity-c99 Tainted: G        W      3.16.0-rc5-next-20140721-sasha-00051-g258dfea-dirty #925
[ 1031.270013]  ffff88038023fd80 ffff88010d2a38c0 ffffffffa24c0712 ffffffff9f1a703d
[ 1031.270081]  ffff88010d2a38e0 ffffffff9f1d6d76 ffff88038023fd80 ffffffffa396a896
[ 1031.270081]  ffff88010d2a3900 ffffffff9f1d6df6 ffff88038023fd80 ffff88038023fd80
[ 1031.270081] Call Trace:
[ 1031.270081] dump_stack (lib/dump_stack.c:52)
[ 1031.270081] ? sched_clock_local (kernel/sched/clock.c:214)
[ 1031.270081] spin_dump (kernel/locking/spinlock_debug.c:68 (discriminator 8))
[ 1031.270081] spin_bug (kernel/locking/spinlock_debug.c:76)
[ 1031.270081] do_raw_spin_unlock (./arch/x86/include/asm/spinlock.h:165 kernel/locking/spinlock_debug.c:98 kernel/locking/spinlock_debug.c:158)
[ 1031.270081] _raw_spin_unlock_irqrestore (include/linux/spinlock_api_smp.h:160 kernel/locking/spinlock.c:191)
[ 1031.270081] finish_wait (kernel/sched/wait.c:254)
[ 1031.270081] shmem_fault (include/linux/spinlock.h:343 mm/shmem.c:1327)
[ 1031.270081] ? __wait_on_bit_lock (kernel/sched/wait.c:291)
[ 1031.270081] __do_fault (mm/memory.c:2713)
[ 1031.270081] do_shared_fault (mm/memory.c:2985 (discriminator 8))
[ 1031.270081] handle_mm_fault (mm/memory.c:3097 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
[ 1031.270081] __do_page_fault (arch/x86/mm/fault.c:1231)
[ 1031.270081] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 1031.270081] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[ 1031.270081] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1031.270081] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2639 (discriminator 8))
[ 1031.270081] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[ 1031.270081] do_async_page_fault (arch/x86/kernel/kvm.c:279)
[ 1031.270081] async_page_fault (arch/x86/kernel/entry_64.S:1321)
[ 1031.270081] ? copy_page_to_iter_iovec (include/linux/pagemap.h:562 mm/iov_iter.c:27)
[ 1031.270081] ? vmsplice_to_user (fs/splice.c:1533)
[ 1031.270081] copy_page_to_iter (mm/iov_iter.c:658)
[ 1031.270081] ? pipe_lock (fs/pipe.c:69)
[ 1031.270081] ? preempt_count_sub (kernel/sched/core.c:2617)
[ 1031.270081] ? vmsplice_to_user (fs/splice.c:1533)
[ 1031.270081] pipe_to_user (fs/splice.c:1535)
[ 1031.270081] __splice_from_pipe (fs/splice.c:770 fs/splice.c:886)
[ 1031.270081] vmsplice_to_user (fs/splice.c:1573)
[ 1031.270081] ? rcu_read_lock_held (kernel/rcu/update.c:168)
[ 1031.270081] SyS_vmsplice (include/linux/file.h:38 fs/splice.c:1657 fs/splice.c:1638)
[ 1031.270081] tracesys (arch/x86/kernel/entry_64.S:541)

And hangs:

[  212.010020] INFO: rcu_preempt detected stalls on CPUs/tasks:
[  212.010020]  Tasks blocked on level-1 rcu_node (CPUs 0-15):
[  212.010020]  8: (136 GPs behind) idle=2b9/140000000000000/0 softirq=4/4 last_accelerate: 0000/dda2, nonlazy_posted: 0, .D
[  212.010020]  9: (136 GPs behind) idle=92e/0/0 softirq=3/3 last_accelerate: 0000/dda2, nonlazy_posted: 0, .D
[  212.010020]  (detected by 1, t=6502 jiffies, g=4645, c=4644, q=0)
[  212.010020] Task dump for CPU 8:
[  212.010020] trinity-c350    R  running task    13000  9101   8424 0x00080006
[  212.010020]  ffff880520f47d98 0000000000000296 ffff8805230cfb38 ffffffffb750ba04
[  212.010020]  ffffffffb41bc165 ffff8805230cfb88 ffff8805230cfba0 ffff880520f47d80
[  212.010020]  ffff8805230cfb68 ffffffffb41bc165 ffff880520f47d80 ffff8805230c8800
[  212.010020] Call Trace:
[  212.010020] ? _raw_spin_lock_irqsave (include/linux/spinlock_api_smp.h:117 kernel/locking/spinlock.c:159)
[  212.010020] ? finish_wait (include/linux/list.h:144 kernel/sched/wait.c:251)
[  212.010020] ? finish_wait (include/linux/list.h:144 kernel/sched/wait.c:251)
[  212.010020] ? shmem_fault (include/linux/spinlock.h:343 mm/shmem.c:1327)
[  212.010020] ? __wait_on_bit_lock (kernel/sched/wait.c:291)
[  212.010020] ? __do_fault (mm/memory.c:2713)
[  212.010020] ? do_shared_fault (mm/memory.c:2985 (discriminator 8))
[  212.010020] ? handle_mm_fault (mm/memory.c:3097 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
[  212.010020] ? __do_page_fault (arch/x86/mm/fault.c:1231)
[  212.010020] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  212.010020] ? __tick_nohz_task_switch (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/time/tick-sched.c:278 (discriminator 2))
[  212.010020] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  212.010020] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[  212.010020] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  212.010020] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2639 (discriminator 8))
[  212.010020] ? trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[  212.010020] ? do_async_page_fault (arch/x86/kernel/kvm.c:279)
[  212.010020] ? async_page_fault (arch/x86/kernel/entry_64.S:1321)
[  212.010020] ? copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:167)
[  212.010020] ? SyS_getcwd (./arch/x86/include/asm/uaccess.h:731 fs/dcache.c:3200 fs/dcache.c:3164)
[  212.010020] ? tracesys (arch/x86/kernel/entry_64.S:541)
[  212.010020] ? tracesys (arch/x86/kernel/entry_64.S:541)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
