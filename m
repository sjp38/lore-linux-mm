Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27B316B03A6
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:54:48 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 62so6142033uas.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:54:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x85sor1345789vkd.2.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 05:54:47 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 3 Mar 2017 14:54:26 +0100
Message-ID: <CACT4Y+YQscOM_H-gZqyzd7n79nUA3QM8=UsX55QEyoapn4QqdA@mail.gmail.com>
Subject: mm: use-after-free in zap_page_range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

Yesterday Andrea helped me to extend syzkaller descriptions to
accommodate the new userfaultfd features:
https://github.com/google/syzkaller/commit/e7fc37e3cc9909ac38afc13e4f00c299d05cabf5
And here we go. UFFDIO_API seems to be necessary to trigger this. If
you add new APIs don't neglect to add syzkaller descriptions as well.


The following program triggers use-after-free in zap_page_range:
https://gist.githubusercontent.com/dvyukov/b59dfbaa0cb1e5231094d228fa57c9bd/raw/95c4da18cb96f8aaa47c10012d8c4484fd5917ad/gistfile1.txt

BUG: KASAN: use-after-free in zap_page_range+0x552/0x5c0
mm/memory.c:1399 at addr ffff880064daa540
Read of size 8 by task a.out/11690
CPU: 0 PID: 11690 Comm: a.out Not tainted 4.10.0+ #269
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
 zap_page_range+0x552/0x5c0 mm/memory.c:1399
 madvise_dontneed mm/madvise.c:517 [inline]
 madvise_vma mm/madvise.c:624 [inline]
 SYSC_madvise mm/madvise.c:787 [inline]
 SyS_madvise+0x6a0/0x1300 mm/madvise.c:716
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x43fdb9
RSP: 002b:00007f563994cd98 EFLAGS: 00000246 ORIG_RAX: 000000000000001c
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 000000000043fdb9
RDX: 0000000000000004 RSI: 0000000000003000 RDI: 0000000020011000
RBP: 0000000000000000 R08: 00007f563994d700 R09: 0000000000000000
R10: 00007f563994d700 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 00007f563994d9c0 R15: 00007f563994d700
Object at ffff880064daa500, in cache vm_area_struct size: 192
Allocated:
PID = 11686
 kmem_cache_alloc+0x102/0x6e0 mm/slab.c:3571
 kmem_cache_zalloc include/linux/slab.h:653 [inline]
 mmap_region+0xa36/0x18f0 mm/mmap.c:1643
 do_mmap+0x6a6/0xd40 mm/mmap.c:1453
 do_mmap_pgoff include/linux/mm.h:2100 [inline]
 vm_mmap_pgoff+0x206/0x280 mm/util.c:307
 SYSC_mmap_pgoff mm/mmap.c:1503 [inline]
 SyS_mmap_pgoff+0x22c/0x5d0 mm/mmap.c:1461
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:95 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 11691
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 remove_vma+0x162/0x1b0 mm/mmap.c:175
 remove_vma_list mm/mmap.c:2443 [inline]
 do_munmap+0x945/0xff0 mm/mmap.c:2674
 mmap_region+0x69d/0x18f0 mm/mmap.c:1616
 do_mmap+0x6a6/0xd40 mm/mmap.c:1453
 do_mmap_pgoff include/linux/mm.h:2100 [inline]
 vm_mmap_pgoff+0x206/0x280 mm/util.c:307
 SYSC_mmap_pgoff mm/mmap.c:1503 [inline]
 SyS_mmap_pgoff+0x22c/0x5d0 mm/mmap.c:1461
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:95 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff880064daa400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880064daa480: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>ffff880064daa500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                           ^
 ffff880064daa580: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff880064daa600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

On commit 4977ab6e92e267afe9d8f78438c3db330ca8434c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
