Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7D79830D6
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 06:42:43 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id m60so245626056uam.3
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 03:42:43 -0700 (PDT)
Received: from mail-qt0-x22a.google.com (mail-qt0-x22a.google.com. [2607:f8b0:400d:c0d::22a])
        by mx.google.com with ESMTPS id c27si20230695qta.84.2016.08.28.03.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 03:42:42 -0700 (PDT)
Received: by mail-qt0-x22a.google.com with SMTP id w38so56808238qtb.0
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 03:42:42 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 28 Aug 2016 12:42:21 +0200
Message-ID: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
Subject: mm: use-after-free in collapse_huge_page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hello,

I've git the following use-after-free in collapse_huge_page while
running syzkaller fuzzer. It is in khugepaged, so not reproducible. On
commit 61c04572de404e52a655a36752e696bbcb483cf5 (Aug 25).

==================================================================
BUG: KASAN: use-after-free in collapse_huge_page+0x28b1/0x3500 at addr
ffff88006c731388
Read of size 8 by task khugepaged/1327
CPU: 0 PID: 1327 Comm: khugepaged Not tainted 4.8.0-rc3+ #33
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff884b8280 ffff88003c207920 ffffffff82d1b239 ffffffff89ec1520
 fffffbfff1097050 ffff88003e94c700 ffff88006c731300 ffff88006c7313c0
 0000000000000000 ffff88003c207b88 ffff88003c207948 ffffffff817da1fc
Call Trace:
 [<ffffffff817da82e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff817ff651>] collapse_huge_page+0x28b1/0x3500 mm/khugepaged.c:1004
 [<     inline     >] khugepaged_scan_pmd mm/khugepaged.c:1205
 [<     inline     >] khugepaged_scan_mm_slot mm/khugepaged.c:1718
 [<     inline     >] khugepaged_do_scan mm/khugepaged.c:1799
 [<ffffffff8180206b>] khugepaged+0x1dcb/0x2b30 mm/khugepaged.c:1844
 [<ffffffff813e8ddf>] kthread+0x23f/0x2d0 drivers/block/aoe/aoecmd.c:1303
 [<ffffffff86c256cf>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:393
Object at ffff88006c731300, in cache vm_area_struct size: 192
Allocated:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d985d>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:582
 [<ffffffff817d9d92>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:521
 [<ffffffff817d4fcb>] kmem_cache_alloc+0x12b/0x710 mm/slab.c:3573
 [<     inline     >] kmem_cache_zalloc ./include/linux/slab.h:626
 [<ffffffff8177d1ed>] mmap_region+0x63d/0xfe0 mm/mmap.c:1486
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Freed:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d9e12>] kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:555
 [<     inline     >] __cache_free mm/slab.c:3515
 [<ffffffff817d6f96>] kmem_cache_free+0x76/0x300 mm/slab.c:3775
 [<ffffffff817727a2>] remove_vma+0x162/0x1b0 mm/mmap.c:168
 [<     inline     >] remove_vma_list mm/mmap.c:2286
 [<ffffffff81779017>] do_munmap+0x7c7/0xf00 mm/mmap.c:2509
 [<ffffffff8177cd02>] mmap_region+0x152/0xfe0 mm/mmap.c:1459
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
 ffff88006c731280: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
 ffff88006c731300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88006c731380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
                      ^
 ffff88006c731400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006c731480: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
==================================================================
Disabling lock debugging due to kernel taint
==================================================================
BUG: KASAN: use-after-free in pmdp_collapse_flush+0x146/0x160 at addr
ffff88006c731350
Read of size 8 by task khugepaged/1327
CPU: 0 PID: 1327 Comm: khugepaged Tainted: G    B           4.8.0-rc3+ #33
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff884b8280 ffff88003c2078e0 ffffffff82d1b239 ffffffff00000000
 fffffbfff1097050 ffff88003e94c700 ffff88006c731300 ffff88006c7313c0
 0000000020000000 ffff88003c207b88 ffff88003c207908 ffffffff817da1fc
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82d1b239>] dump_stack+0x12e/0x185 lib/dump_stack.c:51
 [<ffffffff817da1fc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:154
 [<     inline     >] print_address_description mm/kasan/report.c:192
 [<ffffffff817da44e>] kasan_report_error+0x1ae/0x490 mm/kasan/report.c:281
 [<     inline     >] kasan_report mm/kasan/report.c:301
 [<ffffffff817da82e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff81799f86>] pmdp_collapse_flush+0x146/0x160 mm/pgtable-generic.c:186
 [<ffffffff817fde79>] collapse_huge_page+0x10d9/0x3500 mm/khugepaged.c:1019
 [<     inline     >] khugepaged_scan_pmd mm/khugepaged.c:1205
 [<     inline     >] khugepaged_scan_mm_slot mm/khugepaged.c:1718
 [<     inline     >] khugepaged_do_scan mm/khugepaged.c:1799
 [<ffffffff8180206b>] khugepaged+0x1dcb/0x2b30 mm/khugepaged.c:1844
 [<ffffffff813e8ddf>] kthread+0x23f/0x2d0 drivers/block/aoe/aoecmd.c:1303
 [<ffffffff86c256cf>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:393
Object at ffff88006c731300, in cache vm_area_struct size: 192
Allocated:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d985d>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:582
 [<ffffffff817d9d92>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:521
 [<ffffffff817d4fcb>] kmem_cache_alloc+0x12b/0x710 mm/slab.c:3573
 [<     inline     >] kmem_cache_zalloc ./include/linux/slab.h:626
 [<ffffffff8177d1ed>] mmap_region+0x63d/0xfe0 mm/mmap.c:1486
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Freed:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d9e12>] kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:555
 [<     inline     >] __cache_free mm/slab.c:3515
 [<ffffffff817d6f96>] kmem_cache_free+0x76/0x300 mm/slab.c:3775
 [<ffffffff817727a2>] remove_vma+0x162/0x1b0 mm/mmap.c:168
 [<     inline     >] remove_vma_list mm/mmap.c:2286
 [<ffffffff81779017>] do_munmap+0x7c7/0xf00 mm/mmap.c:2509
 [<ffffffff8177cd02>] mmap_region+0x152/0xfe0 mm/mmap.c:1459
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
 ffff88006c731200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88006c731280: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
>ffff88006c731300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                 ^
 ffff88006c731380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88006c731400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
==================================================================
BUG: KASAN: use-after-free in pmdp_collapse_flush+0x137/0x160 at addr
ffff88006c731340
Read of size 8 by task khugepaged/1327
CPU: 0 PID: 1327 Comm: khugepaged Tainted: G    B           4.8.0-rc3+ #33
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff884b8280 ffff88003c2078e0 ffffffff82d1b239 ffffffff00000000
 fffffbfff1097050 ffff88003e94c700 ffff88006c731300 ffff88006c7313c0
 0000000020000000 ffff88003c207b88 ffff88003c207908 ffffffff817da1fc
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82d1b239>] dump_stack+0x12e/0x185 lib/dump_stack.c:51
 [<ffffffff817da1fc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:154
 [<     inline     >] print_address_description mm/kasan/report.c:192
 [<ffffffff817da44e>] kasan_report_error+0x1ae/0x490 mm/kasan/report.c:281
 [<     inline     >] kasan_report mm/kasan/report.c:301
 [<ffffffff817da82e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff81799f77>] pmdp_collapse_flush+0x137/0x160 mm/pgtable-generic.c:186
 [<ffffffff817fde79>] collapse_huge_page+0x10d9/0x3500 mm/khugepaged.c:1019
 [<     inline     >] khugepaged_scan_pmd mm/khugepaged.c:1205
 [<     inline     >] khugepaged_scan_mm_slot mm/khugepaged.c:1718
 [<     inline     >] khugepaged_do_scan mm/khugepaged.c:1799
 [<ffffffff8180206b>] khugepaged+0x1dcb/0x2b30 mm/khugepaged.c:1844
 [<ffffffff813e8ddf>] kthread+0x23f/0x2d0 drivers/block/aoe/aoecmd.c:1303
 [<ffffffff86c256cf>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:393
Object at ffff88006c731300, in cache vm_area_struct size: 192
Allocated:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d985d>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:582
 [<ffffffff817d9d92>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:521
 [<ffffffff817d4fcb>] kmem_cache_alloc+0x12b/0x710 mm/slab.c:3573
 [<     inline     >] kmem_cache_zalloc ./include/linux/slab.h:626
 [<ffffffff8177d1ed>] mmap_region+0x63d/0xfe0 mm/mmap.c:1486
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Freed:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d9e12>] kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:555
 [<     inline     >] __cache_free mm/slab.c:3515
 [<ffffffff817d6f96>] kmem_cache_free+0x76/0x300 mm/slab.c:3775
 [<ffffffff817727a2>] remove_vma+0x162/0x1b0 mm/mmap.c:168
 [<     inline     >] remove_vma_list mm/mmap.c:2286
 [<ffffffff81779017>] do_munmap+0x7c7/0xf00 mm/mmap.c:2509
 [<ffffffff8177cd02>] mmap_region+0x152/0xfe0 mm/mmap.c:1459
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
 ffff88006c731200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88006c731280: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
>ffff88006c731300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                           ^
 ffff88006c731380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88006c731400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
==================================================================
BUG: KASAN: use-after-free in collapse_huge_page+0x231c/0x3500 at addr
ffff88006c731388
Read of size 8 by task khugepaged/1327
CPU: 0 PID: 1327 Comm: khugepaged Tainted: G    B           4.8.0-rc3+ #33
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff884b8280 ffff88003c207920 ffffffff82d1b239 ffffffff00000000
 fffffbfff1097050 ffff88003e94c700 ffff88006c731300 ffff88006c7313c0
 0000000000000000 ffff88003c207b88 ffff88003c207948 ffffffff817da1fc
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82d1b239>] dump_stack+0x12e/0x185 lib/dump_stack.c:51
 [<ffffffff817da1fc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:154
 [<     inline     >] print_address_description mm/kasan/report.c:192
 [<ffffffff817da44e>] kasan_report_error+0x1ae/0x490 mm/kasan/report.c:281
 [<     inline     >] kasan_report mm/kasan/report.c:301
 [<ffffffff817da82e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff817ff0bc>] collapse_huge_page+0x231c/0x3500 mm/khugepaged.c:1038
 [<     inline     >] khugepaged_scan_pmd mm/khugepaged.c:1205
 [<     inline     >] khugepaged_scan_mm_slot mm/khugepaged.c:1718
 [<     inline     >] khugepaged_do_scan mm/khugepaged.c:1799
 [<ffffffff8180206b>] khugepaged+0x1dcb/0x2b30 mm/khugepaged.c:1844
 [<ffffffff813e8ddf>] kthread+0x23f/0x2d0 drivers/block/aoe/aoecmd.c:1303
 [<ffffffff86c256cf>] ret_from_fork+0x1f/0x40 arch/x86/entry/entry_64.S:393
Object at ffff88006c731300, in cache vm_area_struct size: 192
Allocated:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d985d>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:582
 [<ffffffff817d9d92>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:521
 [<ffffffff817d4fcb>] kmem_cache_alloc+0x12b/0x710 mm/slab.c:3573
 [<     inline     >] kmem_cache_zalloc ./include/linux/slab.h:626
 [<ffffffff8177d1ed>] mmap_region+0x63d/0xfe0 mm/mmap.c:1486
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Freed:
PID = 23069
 [<ffffffff8122b7d6>] save_stack_trace+0x26/0x50 arch/x86/kernel/stacktrace.c:67
 [<ffffffff817d95e6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:479
 [<     inline     >] set_track mm/kasan/kasan.c:491
 [<ffffffff817d9e12>] kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:555
 [<     inline     >] __cache_free mm/slab.c:3515
 [<ffffffff817d6f96>] kmem_cache_free+0x76/0x300 mm/slab.c:3775
 [<ffffffff817727a2>] remove_vma+0x162/0x1b0 mm/mmap.c:168
 [<     inline     >] remove_vma_list mm/mmap.c:2286
 [<ffffffff81779017>] do_munmap+0x7c7/0xf00 mm/mmap.c:2509
 [<ffffffff8177cd02>] mmap_region+0x152/0xfe0 mm/mmap.c:1459
 [<ffffffff8177e52d>] do_mmap+0x99d/0xbf0 mm/mmap.c:1297
 [<     inline     >] do_mmap_pgoff ./include/linux/mm.h:2044
 [<ffffffff81722a26>] vm_mmap_pgoff+0x156/0x1a0 mm/util.c:302
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1347
 [<ffffffff81777288>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1305
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8120cc36>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff86c25480>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
 ffff88006c731280: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
 ffff88006c731300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88006c731380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
                      ^
 ffff88006c731400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006c731480: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
==================================================================


For the record here is full crash log:
https://gist.githubusercontent.com/dvyukov/9366a1585f95df0251b9310e4fe33bb1/raw/ad635fb9594a733a95cd6f6c82dffa847f62c2ea/gistfile1.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
