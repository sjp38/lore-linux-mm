Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 298356B0388
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:24:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c143so1372706wmd.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:21 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id p80si1019492wmf.22.2017.03.14.12.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:24:19 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id n11so71876993wma.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:19 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 0/3] x86, kasan: add KASAN checks to atomic operations
Date: Tue, 14 Mar 2017 20:24:11 +0100
Message-Id: <cover.1489519233.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com
Cc: will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

KASAN uses compiler instrumentation to intercept all memory accesses.
But it does not see memory accesses done in assembly code.
One notable user of assembly code is atomic operations. Frequently,
for example, an atomic reference decrement is the last access to an
object and a good candidate for a racy use-after-free.

Atomic operations are defined in arch files, but KASAN instrumentation
is required for several archs that support KASAN. Later we will need
similar hooks for KMSAN (uninit use detector) and KTSAN (data race
detector).

This change introduces wrappers around atomic operations that can be
used to add KASAN/KMSAN/KTSAN instrumentation across several archs,
and adds KASAN checks to them.

This patch uses the wrappers only for x86 arch. Arm64 will be switched
later. And we also plan to instrument bitops in a similar way.

Within a day it has found its first bug:

BUG: KASAN: use-after-free in atomic_dec_and_test
arch/x86/include/asm/atomic.h:123 [inline] at addr ffff880079c30158
Write of size 4 by task syz-executor6/25698
CPU: 2 PID: 25698 Comm: syz-executor6 Not tainted 4.10.0+ #302
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 kasan_check_write+0x14/0x20 mm/kasan/kasan.c:344
 atomic_dec_and_test arch/x86/include/asm/atomic.h:123 [inline]
 put_task_struct include/linux/sched/task.h:93 [inline]
 put_ctx+0xcf/0x110 kernel/events/core.c:1131
 perf_event_release_kernel+0x3ad/0xc90 kernel/events/core.c:4322
 perf_release+0x37/0x50 kernel/events/core.c:4338
 __fput+0x332/0x800 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x197/0x260 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0xb38/0x29c0 kernel/exit.c:880
 do_group_exit+0x149/0x420 kernel/exit.c:984
 get_signal+0x7e0/0x1820 kernel/signal.c:2318
 do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x200/0x2a0 arch/x86/entry/common.c:157
 syscall_return_slowpath arch/x86/entry/common.c:191 [inline]
 do_syscall_64+0x6fc/0x930 arch/x86/entry/common.c:286
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x4458d9
RSP: 002b:00007f3f07187cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000007080c8 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000007080c8
RBP: 00000000007080a8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 00007f3f071889c0 R15: 00007f3f07188700
Object at ffff880079c30140, in cache task_struct size: 5376
Allocated:
PID = 25681
 kmem_cache_alloc_node+0x122/0x6f0 mm/slab.c:3662
 alloc_task_struct_node kernel/fork.c:153 [inline]
 dup_task_struct kernel/fork.c:495 [inline]
 copy_process.part.38+0x19c8/0x4aa0 kernel/fork.c:1560
 copy_process kernel/fork.c:1531 [inline]
 _do_fork+0x200/0x1010 kernel/fork.c:1994
 SYSC_clone kernel/fork.c:2104 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2098
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
 return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 25681
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 free_task_struct kernel/fork.c:158 [inline]
 free_task+0x151/0x1d0 kernel/fork.c:370
 copy_process.part.38+0x18e5/0x4aa0 kernel/fork.c:1931
 copy_process kernel/fork.c:1531 [inline]
 _do_fork+0x200/0x1010 kernel/fork.c:1994
 SYSC_clone kernel/fork.c:2104 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2098
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
 return_from_SYSCALL_64+0x0/0x7a

Dmitry Vyukov (3):
  kasan: allow kasan_check_read/write() to accept pointers to volatiles
  asm-generic, x86: wrap atomic operations
  asm-generic: add KASAN instrumentation to atomic operations

 arch/x86/include/asm/atomic.h             | 100 ++++++------
 arch/x86/include/asm/atomic64_32.h        |  86 ++++++-----
 arch/x86/include/asm/atomic64_64.h        |  90 +++++------
 arch/x86/include/asm/cmpxchg.h            |  12 +-
 arch/x86/include/asm/cmpxchg_32.h         |   8 +-
 arch/x86/include/asm/cmpxchg_64.h         |   4 +-
 include/asm-generic/atomic-instrumented.h | 246 ++++++++++++++++++++++++++++++
 include/linux/kasan-checks.h              |  10 +-
 mm/kasan/kasan.c                          |   4 +-
 9 files changed, 411 insertions(+), 149 deletions(-)
 create mode 100644 include/asm-generic/atomic-instrumented.h

-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
