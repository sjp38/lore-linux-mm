Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id ACA02828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 11:58:54 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so143393924wmf.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 08:58:54 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id ln5si24118017wjb.38.2016.01.08.08.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 08:58:53 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id f206so142382845wmf.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 08:58:53 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 8 Jan 2016 17:58:33 +0100
Message-ID: <CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com>
Subject: mm: possible deadlock in mm_take_all_locks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>, Sasha Levin <sasha.levin@oracle.com>

Hello,

I've hit the following deadlock warning while running syzkaller fuzzer
on commit b06f3a168cdcd80026276898fd1fee443ef25743. As far as I
understand this is a false positive, because both call stacks are
protected by mm_all_locks_mutex. What would be a way to annotate such
locking discipline?


======================================================
[ INFO: possible circular locking dependency detected ]
4.4.0-rc8+ #211 Not tainted
-------------------------------------------------------
syz-executor/11520 is trying to acquire lock:
 (&mapping->i_mmap_rwsem){++++..}, at: [<     inline     >]
vm_lock_mapping mm/mmap.c:3159
 (&mapping->i_mmap_rwsem){++++..}, at: [<ffffffff816e2e6d>]
mm_take_all_locks+0x1bd/0x5f0 mm/mmap.c:3207

but task is already holding lock:
 (&hugetlbfs_i_mmap_rwsem_key){+.+...}, at: [<     inline     >]
vm_lock_mapping mm/mmap.c:3159
 (&hugetlbfs_i_mmap_rwsem_key){+.+...}, at: [<ffffffff816e2e6d>]
mm_take_all_locks+0x1bd/0x5f0 mm/mmap.c:3207

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #1 (&hugetlbfs_i_mmap_rwsem_key){+.+...}:
       [<ffffffff814472ec>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
       [<ffffffff81434989>] _down_write_nest_lock+0x49/0xa0
kernel/locking/rwsem.c:129
       [<     inline     >] vm_lock_mapping mm/mmap.c:3159
       [<ffffffff816e2e6d>] mm_take_all_locks+0x1bd/0x5f0 mm/mmap.c:3207
       [<ffffffff817295a8>] do_mmu_notifier_register+0x328/0x420
mm/mmu_notifier.c:267
       [<ffffffff817296c2>] mmu_notifier_register+0x22/0x30
mm/mmu_notifier.c:317
       [<     inline     >] kvm_init_mmu_notifier
arch/x86/kvm/../../../virt/kvm/kvm_main.c:474
       [<     inline     >] kvm_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:592
       [<     inline     >] kvm_dev_ioctl_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2966
       [<ffffffff8101acea>] kvm_dev_ioctl+0x72a/0x920
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2995
       [<     inline     >] vfs_ioctl fs/ioctl.c:43
       [<ffffffff817b66f1>] do_vfs_ioctl+0x681/0xe40 fs/ioctl.c:607
       [<     inline     >] SYSC_ioctl fs/ioctl.c:622
       [<ffffffff817b6f3f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:613
       [<ffffffff85e77af6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

-> #0 (&mapping->i_mmap_rwsem){++++..}:
       [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
       [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
       [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
       [<ffffffff8144398d>] __lock_acquire+0x320d/0x4720
kernel/locking/lockdep.c:3206
       [<     inline     >] __lock_release kernel/locking/lockdep.c:3432
       [<ffffffff81447e17>] lock_release+0x697/0xce0
kernel/locking/lockdep.c:3604
       [<ffffffff81434ada>] up_write+0x1a/0x60 kernel/locking/rwsem.c:91
       [<     inline     >] i_mmap_unlock_write include/linux/fs.h:504
       [<     inline     >] vm_unlock_mapping mm/mmap.c:3254
       [<ffffffff816e2bf6>] mm_drop_all_locks+0x266/0x320 mm/mmap.c:3278
       [<ffffffff81729506>] do_mmu_notifier_register+0x286/0x420
mm/mmu_notifier.c:292
       [<ffffffff817296c2>] mmu_notifier_register+0x22/0x30
mm/mmu_notifier.c:317
       [<     inline     >] kvm_init_mmu_notifier
arch/x86/kvm/../../../virt/kvm/kvm_main.c:474
       [<     inline     >] kvm_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:592
       [<     inline     >] kvm_dev_ioctl_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2966
       [<ffffffff8101acea>] kvm_dev_ioctl+0x72a/0x920
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2995
       [<     inline     >] vfs_ioctl fs/ioctl.c:43
       [<ffffffff817b66f1>] do_vfs_ioctl+0x681/0xe40 fs/ioctl.c:607
       [<     inline     >] SYSC_ioctl fs/ioctl.c:622
       [<ffffffff817b6f3f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:613
       [<ffffffff85e77af6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&hugetlbfs_i_mmap_rwsem_key);
                               lock(&mapping->i_mmap_rwsem);
                               lock(&hugetlbfs_i_mmap_rwsem_key);
  lock(&mapping->i_mmap_rwsem);

 *** DEADLOCK ***

3 locks held by syz-executor/11520:
 #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff817295a0>]
do_mmu_notifier_register+0x320/0x420 mm/mmu_notifier.c:266
 #1:  (mm_all_locks_mutex){+.+...}, at: [<ffffffff816e2cf7>]
mm_take_all_locks+0x47/0x5f0 mm/mmap.c:3201
 #2:  (&hugetlbfs_i_mmap_rwsem_key){+.+...}, at: [<     inline     >]
vm_lock_mapping mm/mmap.c:3159
 #2:  (&hugetlbfs_i_mmap_rwsem_key){+.+...}, at: [<ffffffff816e2e6d>]
mm_take_all_locks+0x1bd/0x5f0 mm/mmap.c:3207

stack backtrace:
CPU: 2 PID: 11520 Comm: syz-executor Not tainted 4.4.0-rc8+ #211
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88003613fa10 ffffffff82907ccd ffffffff88911190
 ffffffff88911190 ffffffff889321c0 ffff88003613fa60 ffffffff8143cb68
 ffff880034bbaf00 ffff880034bbb73a 0000000000000000 ffff880034bbb718
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82907ccd>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<ffffffff8143cb68>] print_circular_bug+0x288/0x340
kernel/locking/lockdep.c:1226
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
 [<ffffffff8144398d>] __lock_acquire+0x320d/0x4720 kernel/locking/lockdep.c:3206
 [<     inline     >] __lock_release kernel/locking/lockdep.c:3432
 [<ffffffff81447e17>] lock_release+0x697/0xce0 kernel/locking/lockdep.c:3604
 [<ffffffff81434ada>] up_write+0x1a/0x60 kernel/locking/rwsem.c:91
 [<     inline     >] i_mmap_unlock_write include/linux/fs.h:504
 [<     inline     >] vm_unlock_mapping mm/mmap.c:3254
 [<ffffffff816e2bf6>] mm_drop_all_locks+0x266/0x320 mm/mmap.c:3278
 [<ffffffff81729506>] do_mmu_notifier_register+0x286/0x420 mm/mmu_notifier.c:292
 [<ffffffff817296c2>] mmu_notifier_register+0x22/0x30 mm/mmu_notifier.c:317
 [<     inline     >] kvm_init_mmu_notifier
arch/x86/kvm/../../../virt/kvm/kvm_main.c:474
 [<     inline     >] kvm_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:592
 [<     inline     >] kvm_dev_ioctl_create_vm
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2966
 [<ffffffff8101acea>] kvm_dev_ioctl+0x72a/0x920
arch/x86/kvm/../../../virt/kvm/kvm_main.c:2995
 [<     inline     >] vfs_ioctl fs/ioctl.c:43
 [<ffffffff817b66f1>] do_vfs_ioctl+0x681/0xe40 fs/ioctl.c:607
 [<     inline     >] SYSC_ioctl fs/ioctl.c:622
 [<ffffffff817b6f3f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:613
 [<ffffffff85e77af6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
