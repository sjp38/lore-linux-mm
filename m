Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC6D96B0069
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 14:38:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so88693890wma.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:13 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id ec14si12676562wjb.87.2016.11.08.11.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 11:38:12 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id f82so201597861wmf.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:38:12 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/2] kasan,stacktrace: improve error reports
Date: Tue,  8 Nov 2016 20:37:48 +0100
Message-Id: <cover.1478632698.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

This patchset improves KASAN reports by making the following changes:

1. Changes header format from:
[   24.247214] BUG: KASAN: use-after-free in kmalloc_uaf+0xad/0xb9 [test_kasan] at addr ffff88006bbb38a8
[   24.247301] Write of size 1 by task insmod/3852
to
[   19.338308] BUG: KASAN: use-after-free in kmalloc_uaf+0xad/0xb9 [test_kasan]
[   19.338387] Write of size 1 at addr ffff88006af77968 by task insmod/3840

2. Unifies header format between different kinds of bad accesses.

3. Adds empty lines between parts of the report to improve readability.

4. Improves slab object description, before:
[   24.247301] Object at ffff88006bbb38a0, in cache kmalloc-16 size: 16
now:
[   19.338387] The buggy address belongs to the object at ffff88006af77960
[   19.338387]  which belongs to the cache kmalloc-16 of size 16
[   19.338387] The buggy address ffff88006af77968 is located 8 bytes inside
[   19.338387]  of 16-byte region [ffff88006af77960, ffff88006af77970)

5. Fixes printing timeframes twice in alloc and free stack traces.

6. Improves mm/kasan/report.c readability.


This is what a test use-after-free report looks like now:

[   19.337402] ==================================================================
[   19.338308] BUG: KASAN: use-after-free in kmalloc_uaf+0xad/0xb9 [test_kasan]
[   19.338387] Write of size 1 at addr ffff88006af77968 by task insmod/3840
[   19.338387] 
[   19.338387] page:ffffea0001abddc0 count:1 mapcount:0 mapping:          (null) index:0x0
[   19.338387] flags: 0x100000000000080(slab)
[   19.338387] page dumped because: kasan: bad access detected
[   19.338387] 
[   19.338387] CPU: 0 PID: 3840 Comm: insmod Tainted: G    B           4.9.0-rc4+ #394
[   19.338387] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[   19.338387]  ffff880063d6f9a8 ffffffff81b46b74 ffff880063d6fa38 ffff88006af77968
[   19.338387]  00000000000000fa 00000000000000fb ffff880063d6fa28 ffffffff8150aa92
[   19.338387]  ffffffff8120812d ffff880063d6fa00 0000000000000282 0000000000000296
[   19.338387] Call Trace:
[   19.338387]  [<ffffffff81b46b74>] dump_stack+0xb3/0x10f
[   19.338387]  [<ffffffff8150aa92>] kasan_report_error+0x122/0x560
[   19.338387]  [<ffffffff8120812d>] ? trace_hardirqs_on+0xd/0x10
[   19.338387]  [<ffffffffa001928c>] ? copy_user_test+0x24f/0x24f [test_kasan]
[   19.338387]  [<ffffffff8150b04e>] __asan_report_store1_noabort+0x3e/0x40
[   19.338387]  [<ffffffffa0018609>] ? kmalloc_uaf+0xad/0xb9 [test_kasan]
[   19.338387]  [<ffffffffa0018609>] kmalloc_uaf+0xad/0xb9 [test_kasan]
[   19.338387]  [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   19.338387]  [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   19.338387]  [<ffffffff810004c0>] ? initcall_blacklisted+0x170/0x170
[   19.338387]  [<ffffffff81509e1b>] ? kasan_kmalloc+0xab/0xe0
[   19.338387]  [<ffffffff81509cb5>] ? kasan_unpoison_shadow+0x35/0x50
[   19.338387]  [<ffffffff81509d4c>] ? __asan_register_globals+0x7c/0xa0
[   19.338387]  [<ffffffff8140d696>] do_init_module+0x1c1/0x516
[   19.338387]  [<ffffffff812bbe1d>] load_module+0x65ed/0x8f90
[   19.338387]  [<ffffffff812b2f70>] ? __symbol_put+0xb0/0xb0
[   19.338387]  [<ffffffffa001002d>] ? __UNIQUE_ID_vermagic8+0x36ff9f20d843/0x36ff9f20d846 [test_kasan]
[   19.338387]  [<ffffffff812b5830>] ? module_frob_arch_sections+0x20/0x20
[   19.338387]  [<ffffffff83fc1f5f>] ? retint_kernel+0x10/0x10
[   19.338387]  [<ffffffff81207f90>] ? trace_hardirqs_on_caller+0x420/0x5b0
[   19.338387]  [<ffffffff8100301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   19.338387]  [<ffffffff83fc1f5f>] ? retint_kernel+0x10/0x10
[   19.338387]  [<ffffffff812be97c>] SYSC_init_module+0x1bc/0x1d0
[   19.338387]  [<ffffffff812be7c0>] ? load_module+0x8f90/0x8f90
[   19.338387]  [<ffffffff81207f90>] ? trace_hardirqs_on_caller+0x420/0x5b0
[   19.338387]  [<ffffffff8100301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   19.338387]  [<ffffffff812beaf9>] SyS_init_module+0x9/0x10
[   19.338387]  [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   19.338387] 
[   19.338387] The buggy address belongs to the object at ffff88006af77960
[   19.338387]  which belongs to the cache kmalloc-16 of size 16
[   19.338387] The buggy address ffff88006af77968 is located 8 bytes inside
[   19.338387]  of 16-byte region [ffff88006af77960, ffff88006af77970)
[   19.338387] 
[   19.338387] Freed by task 3840:
[   19.338387]  [<ffffffff8107e236>] save_stack_trace+0x16/0x20
[   19.338387]  [<ffffffff81509ba6>] save_stack+0x46/0xd0
[   19.338387]  [<ffffffff8150a403>] kasan_slab_free+0x73/0xc0
[   19.338387]  [<ffffffff815068e8>] kfree+0xe8/0x2b0
[   19.338387]  [<ffffffffa00185e1>] kmalloc_uaf+0x85/0xb9 [test_kasan]
[   19.338387]  [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   19.338387]  [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   19.338387]  [<ffffffff8140d696>] do_init_module+0x1c1/0x516
[   19.338387]  [<ffffffff812bbe1d>] load_module+0x65ed/0x8f90
[   19.338387]  [<ffffffff812be97c>] SYSC_init_module+0x1bc/0x1d0
[   19.338387]  [<ffffffff812beaf9>] SyS_init_module+0x9/0x10
[   19.338387]  [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   19.338387] 
[   19.338387] Allocated by task 3840:
[   19.338387]  [<ffffffff8107e236>] save_stack_trace+0x16/0x20
[   19.338387]  [<ffffffff81509ba6>] save_stack+0x46/0xd0
[   19.338387]  [<ffffffff81509e1b>] kasan_kmalloc+0xab/0xe0
[   19.338387]  [<ffffffff8150554c>] kmem_cache_alloc_trace+0xec/0x270
[   19.338387]  [<ffffffffa00185b2>] kmalloc_uaf+0x56/0xb9 [test_kasan]
[   19.338387]  [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   19.338387]  [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   19.338387]  [<ffffffff8140d696>] do_init_module+0x1c1/0x516
[   19.338387]  [<ffffffff812bbe1d>] load_module+0x65ed/0x8f90
[   19.338387]  [<ffffffff812be97c>] SYSC_init_module+0x1bc/0x1d0
[   19.338387]  [<ffffffff812beaf9>] SyS_init_module+0x9/0x10
[   19.338387]  [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   19.338387] 
[   19.338387] Memory state around the buggy address:
[   19.338387]  ffff88006af77800: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[   19.338387]  ffff88006af77880: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[   19.338387] >ffff88006af77900: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[   19.338387]                                                           ^
[   19.338387]  ffff88006af77980: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
[   19.338387]  ffff88006af77a00: 00 00 fc fc 00 00 fc fc 00 00 fc fc fb fb fc fc
[   19.338387] ==================================================================

This is what a test use-after-free report looked like before:

[   24.246351] ==================================================================
[   24.247214] BUG: KASAN: use-after-free in kmalloc_uaf+0xad/0xb9 [test_kasan] at addr ffff88006bbb38a8
[   24.247301] Write of size 1 by task insmod/3852
[   24.247301] CPU: 1 PID: 3852 Comm: insmod Tainted: G    B           4.9.0-rc4+ #393
[   24.247301] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[   24.247301]  ffff88006a647980 ffffffff81b46a64 ffff88006c801b40 ffff88006bbb38a0
[   24.247301]  ffff88006bbb38b0 ffff88006bbb38a0 ffff88006a6479a8 ffffffff8150a86c
[   24.247301]  ffff88006a647a38 ffff88006c801b40 ffff8800ebbb38a8 ffff88006a647a28
[   24.247301] Call Trace:
[   24.247301]  [<ffffffff81b46a64>] dump_stack+0xb3/0x10f
[   24.247301]  [<ffffffff8150a86c>] kasan_object_err+0x1c/0x70
[   24.247301]  [<ffffffff8150ab07>] kasan_report_error+0x1f7/0x4d0
[   24.247301]  [<ffffffff8120812d>] ? trace_hardirqs_on+0xd/0x10
[   24.247301]  [<ffffffffa001928c>] ? copy_user_test+0x24f/0x24f [test_kasan]
[   24.247301]  [<ffffffff8150af5e>] __asan_report_store1_noabort+0x3e/0x40
[   24.247301]  [<ffffffffa0018609>] ? kmalloc_uaf+0xad/0xb9 [test_kasan]
[   24.247301]  [<ffffffffa0018609>] kmalloc_uaf+0xad/0xb9 [test_kasan]
[   24.247301]  [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   24.247301]  [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   24.247301]  [<ffffffff810004c0>] ? initcall_blacklisted+0x170/0x170
[   24.247301]  [<ffffffff81509e4b>] ? kasan_kmalloc+0xab/0xe0
[   24.247301]  [<ffffffff81509ce5>] ? kasan_unpoison_shadow+0x35/0x50
[   24.247301]  [<ffffffff81509d7c>] ? __asan_register_globals+0x7c/0xa0
[   24.247301]  [<ffffffff8140d6c6>] do_init_module+0x1c1/0x516
[   24.247301]  [<ffffffff812bbe4d>] load_module+0x65ed/0x8f90
[   24.247301]  [<ffffffff812b2fa0>] ? __symbol_put+0xb0/0xb0
[   24.247301]  [<ffffffffa001002d>] ? __UNIQUE_ID_vermagic8+0x36ff9f26d843/0x36ff9f26d846 [test_kasan]
[   24.247301]  [<ffffffff812b5860>] ? module_frob_arch_sections+0x20/0x20
[   24.247301]  [<ffffffff83fc1f5f>] ? retint_kernel+0x10/0x10
[   24.247301]  [<ffffffff81207f90>] ? trace_hardirqs_on_caller+0x420/0x5b0
[   24.247301]  [<ffffffff8100301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   24.247301]  [<ffffffff83fc1f5f>] ? retint_kernel+0x10/0x10
[   24.247301]  [<ffffffff812be9ac>] SYSC_init_module+0x1bc/0x1d0
[   24.247301]  [<ffffffff812be7f0>] ? load_module+0x8f90/0x8f90
[   24.247301]  [<ffffffff81207f90>] ? trace_hardirqs_on_caller+0x420/0x5b0
[   24.247301]  [<ffffffff8100301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   24.247301]  [<ffffffff812beb29>] SyS_init_module+0x9/0x10
[   24.247301]  [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   24.247301] Object at ffff88006bbb38a0, in cache kmalloc-16 size: 16
[   24.247301] Allocated:
[   24.247301] PID = 3852
[   24.247301]  [   24.247301] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
[   24.247301]  [   24.247301] [<ffffffff81509bd6>] save_stack+0x46/0xd0
[   24.247301]  [   24.247301] [<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0
[   24.247301]  [   24.247301] [<ffffffff8150557c>] kmem_cache_alloc_trace+0xec/0x270
[   24.247301]  [   24.247301] [<ffffffffa00185b2>] kmalloc_uaf+0x56/0xb9 [test_kasan]
[   24.247301]  [   24.247301] [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   24.247301]  [   24.247301] [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   24.247301]  [   24.247301] [<ffffffff8140d6c6>] do_init_module+0x1c1/0x516
[   24.247301]  [   24.247301] [<ffffffff812bbe4d>] load_module+0x65ed/0x8f90
[   24.247301]  [   24.247301] [<ffffffff812be9ac>] SYSC_init_module+0x1bc/0x1d0
[   24.247301]  [   24.247301] [<ffffffff812beb29>] SyS_init_module+0x9/0x10
[   24.247301]  [   24.247301] [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   24.247301] Freed:
[   24.247301] PID = 3852
[   24.247301]  [   24.247301] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
[   24.247301]  [   24.247301] [<ffffffff81509bd6>] save_stack+0x46/0xd0
[   24.247301]  [   24.247301] [<ffffffff8150a433>] kasan_slab_free+0x73/0xc0
[   24.247301]  [   24.247301] [<ffffffff81506918>] kfree+0xe8/0x2b0
[   24.247301]  [   24.247301] [<ffffffffa00185e1>] kmalloc_uaf+0x85/0xb9 [test_kasan]
[   24.247301]  [   24.247301] [<ffffffffa00192db>] kmalloc_tests_init+0x4f/0x79 [test_kasan]
[   24.247301]  [   24.247301] [<ffffffff81000560>] do_one_initcall+0xa0/0x230
[   24.247301]  [   24.247301] [<ffffffff8140d6c6>] do_init_module+0x1c1/0x516
[   24.247301]  [   24.247301] [<ffffffff812bbe4d>] load_module+0x65ed/0x8f90
[   24.247301]  [   24.247301] [<ffffffff812be9ac>] SYSC_init_module+0x1bc/0x1d0
[   24.247301]  [   24.247301] [<ffffffff812beb29>] SyS_init_module+0x9/0x10
[   24.247301]  [   24.247301] [<ffffffff83fc1581>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[   24.247301] Memory state around the buggy address:
[   24.247301]  ffff88006bbb3780: fb fb fc fc fb fb fc fc 00 00 fc fc 00 00 fc fc
[   24.247301]  ffff88006bbb3800: 00 00 fc fc fb fb fc fc fb fb fc fc fb fb fc fc
[   24.247301] >ffff88006bbb3880: fb fb fc fc fb fb fc fc 00 00 fc fc fb fb fc fc
[   24.247301]                                   ^
[   24.247301]  ffff88006bbb3900: 00 00 fc fc 00 00 fc fc 00 00 fc fc 00 00 fc fc
[   24.247301]  ffff88006bbb3980: 00 00 fc fc 00 00 fc fc fb fb fc fc 00 00 fc fc
[   24.247301] ==================================================================

Andrey Konovalov (2):
  stacktrace: fix print_stack_trace printing timestamp twice
  kasan: improve error reports

 kernel/stacktrace.c |   6 +-
 mm/kasan/report.c   | 246 +++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 169 insertions(+), 83 deletions(-)

-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
