Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F34936B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so67166075wrc.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:19 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l138sor33039wmd.10.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:18 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 0/9] kasan: improve error reports
Date: Mon,  6 Mar 2017 17:00:00 +0100
Message-Id: <cover.1488815789.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

This patchset improves KASAN reports by making them easier to read
and a little more detailed.
Also improves mm/kasan/report.c readability.

Effectively changes a use-after-free report to:

==================================================================
BUG: KASAN: use-after-free in kmalloc_uaf+0xaa/0xb6 [test_kasan]
Write of size 1 at addr ffff88006aa59da8 by task insmod/3951

CPU: 1 PID: 3951 Comm: insmod Tainted: G    B           4.10.0+ #84
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 dump_stack+0x292/0x398
 print_address_description+0x73/0x280
 kasan_report.part.2+0x207/0x2f0
 __asan_report_store1_noabort+0x2c/0x30
 kmalloc_uaf+0xaa/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x7f22cfd0b9da
RSP: 002b:00007ffe69118a78 EFLAGS: 00000206 ORIG_RAX: 00000000000000af
RAX: ffffffffffffffda RBX: 0000555671242090 RCX: 00007f22cfd0b9da
RDX: 00007f22cffcaf88 RSI: 000000000004df7e RDI: 00007f22d0399000
RBP: 00007f22cffcaf88 R08: 0000000000000003 R09: 0000000000000000
R10: 00007f22cfd07d0a R11: 0000000000000206 R12: 0000555671243190
R13: 000000000001fe81 R14: 0000000000000000 R15: 0000000000000004

Allocated by task 3951:
 save_stack_trace+0x16/0x20
 save_stack+0x43/0xd0
 kasan_kmalloc+0xad/0xe0
 kmem_cache_alloc_trace+0x82/0x270
 kmalloc_uaf+0x56/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc2

Freed by task 3951:
 save_stack_trace+0x16/0x20
 save_stack+0x43/0xd0
 kasan_slab_free+0x72/0xc0
 kfree+0xe8/0x2b0
 kmalloc_uaf+0x85/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc

Object at ffff880068388540 belongs to cache kmalloc-128 of size 128
Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)
The buggy address belongs to the page:
page:ffffea0001aa9640 count:1 mapcount:0 mapping:          (null) index:0x0
flags: 0x100000000000100(slab)
raw: 0100000000000100 0000000000000000 0000000000000000 0000000180800080
raw: ffffea0001abe380 0000000700000007 ffff88006c401b40 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff88006aa59c80: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
 ffff88006aa59d00: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
>ffff88006aa59d80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
                                  ^
 ffff88006aa59e00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
 ffff88006aa59e80: fb fb fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
==================================================================

from:

==================================================================
BUG: KASAN: use-after-free in kmalloc_uaf+0xaa/0xb6 [test_kasan] at addr ffff88006c4dcb28
Write of size 1 by task insmod/3984
CPU: 1 PID: 3984 Comm: insmod Tainted: G    B           4.10.0+ #83
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 dump_stack+0x292/0x398
 kasan_object_err+0x1c/0x70
 kasan_report.part.1+0x20e/0x4e0
 __asan_report_store1_noabort+0x2c/0x30
 kmalloc_uaf+0xaa/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x7feca0f779da
RSP: 002b:00007ffdfeae5218 EFLAGS: 00000206 ORIG_RAX: 00000000000000af
RAX: ffffffffffffffda RBX: 000055a064c13090 RCX: 00007feca0f779da
RDX: 00007feca1236f88 RSI: 000000000004df7e RDI: 00007feca1605000
RBP: 00007feca1236f88 R08: 0000000000000003 R09: 0000000000000000
R10: 00007feca0f73d0a R11: 0000000000000206 R12: 000055a064c14190
R13: 000000000001fe81 R14: 0000000000000000 R15: 0000000000000004
Object at ffff88006c4dcb20, in cache kmalloc-16 size: 16
Allocated:
PID = 3984
 save_stack_trace+0x16/0x20
 save_stack+0x43/0xd0
 kasan_kmalloc+0xad/0xe0
 kmem_cache_alloc_trace+0x82/0x270
 kmalloc_uaf+0x56/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 3984
 save_stack_trace+0x16/0x20
 save_stack+0x43/0xd0
 kasan_slab_free+0x73/0xc0
 kfree+0xe8/0x2b0
 kmalloc_uaf+0x85/0xb6 [test_kasan]
 kmalloc_tests_init+0x4f/0xa48 [test_kasan]
 do_one_initcall+0xf3/0x390
 do_init_module+0x215/0x5d0
 load_module+0x54de/0x82b0
 SYSC_init_module+0x3be/0x430
 SyS_init_module+0x9/0x10
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff88006c4dca00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
 ffff88006c4dca80: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
>ffff88006c4dcb00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
                                  ^
 ffff88006c4dcb80: fb fb fc fc 00 00 fc fc fb fb fc fc fb fb fc fc
 ffff88006c4dcc00: fb fb fc fc fb fb fc fc fb fb fc fc fb fb fc fc
==================================================================

Changes in v3:
- make slab objects description shorter
- pass caller addr from SLUB/SLAB instead of usign __builtin_return_address
- make get_wild_bug_type() static
- combine consequent lines into one when possible

Changes in v2:
- split patch in multiple smaller ones
- improve double-free reports

Andrey Konovalov (9):
  kasan: introduce helper functions for determining bug type
  kasan: unify report headers
  kasan: change allocation and freeing stack traces headers
  kasan: simplify address description logic
  kasan: change report header
  kasan: improve slab object description
  kasan: print page description after stacks
  kasan: improve double-free report format
  kasan: separate report parts by empty lines

 include/linux/kasan.h |   2 +-
 mm/kasan/kasan.c      |   5 +-
 mm/kasan/kasan.h      |   2 +-
 mm/kasan/report.c     | 185 +++++++++++++++++++++++++++++++++-----------------
 mm/slab.c             |   2 +-
 mm/slub.c             |  12 ++--
 6 files changed, 134 insertions(+), 74 deletions(-)

-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
