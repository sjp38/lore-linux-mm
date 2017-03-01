Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id D52786B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 13:48:22 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id v33so34576575uaf.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 10:48:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h21sor445808vkf.8.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Mar 2017 10:48:21 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Mar 2017 19:48:00 +0100
Message-ID: <CACT4Y+Z188Wehaes7iTo5m3PLiPgusj86f39kuN-O2HeDvQEWg@mail.gmail.com>
Subject: fs: use-after-free in userfaultfd_exit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

I've got the following use-after-free report while running syzkaller
fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760:

==================================================================
BUG: KASAN: use-after-free in userfaultfd_exit+0x251/0x270
fs/userfaultfd.c:803 at addr ffff88004cb91910
Read of size 8 by task syz-executor4/6218
CPU: 0 PID: 6218 Comm: syz-executor4 Not tainted 4.10.0+ #234
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:331 [inline]
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
 userfaultfd_exit+0x251/0x270 fs/userfaultfd.c:803
 exit_mm kernel/exit.c:551 [inline]
 do_exit+0xa41/0x2900 kernel/exit.c:860
 do_group_exit+0x149/0x420 kernel/exit.c:977
 SYSC_exit_group kernel/exit.c:988 [inline]
 SyS_exit_group+0x1d/0x20 kernel/exit.c:986
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:0000000000a5fe20 EFLAGS: 00000216 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000002dbb RCX: 00000000004458d9
RDX: 00000000004458d9 RSI: 00000000007541a0 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000001ddbc26dec R09: 0000000000000000
R10: 0000000000754198 R11: 0000000000000216 R12: 00000000000f70cd
R13: 00000000007080cc R14: 0000000020311000 R15: 00000000000f6fee
Object at ffff88004cb91900, in cache vm_area_struct size: 192
Allocated:
PID = 6219
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
9pnet_virtio: no channels available for device ./bus
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 __split_vma+0x1b7/0x880 mm/mmap.c:2515
 split_vma+0x8f/0xc0 mm/mmap.c:2578
 userfaultfd_register fs/userfaultfd.c:1360 [inline]
 userfaultfd_ioctl+0x3413/0x42f0 fs/userfaultfd.c:1739
 vfs_ioctl fs/ioctl.c:43 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
 SYSC_ioctl fs/ioctl.c:698 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 6222
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 __vma_adjust+0x954/0x1d40 mm/mmap.c:890
 vma_merge+0xcc2/0x10c0 mm/mmap.c:1135
 userfaultfd_release+0x3cf/0x6d0 fs/userfaultfd.c:840
 __fput+0x332/0x7f0 fs/file_table.c:208
 ____fput+0x15/0x20 fs/file_table.c:244
 task_work_run+0x18a/0x260 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0xafa/0x2900 kernel/exit.c:873
 do_group_exit+0x149/0x420 kernel/exit.c:977
 get_signal+0x7e0/0x1820 kernel/signal.c:2313
 do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807
 exit_to_usermode_loop+0x200/0x2a0 arch/x86/entry/common.c:156
 prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
 syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
 entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff88004cb91800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88004cb91880: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>ffff88004cb91900: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                         ^
 ffff88004cb91980: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88004cb91a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
