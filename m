Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 150296B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 05:27:04 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w63so1277972qkd.0
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 02:27:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n42sor737205qtf.80.2017.09.28.02.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 02:27:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170302173738.18994-2-aarcange@redhat.com>
References: <20170302173738.18994-1-aarcange@redhat.com> <20170302173738.18994-2-aarcange@redhat.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 28 Sep 2017 02:26:42 -0700
Message-ID: <CA+1xoqc0W4CXEJ-hXL5=KnzskazR1E2p+rQuEop_Y0tHoanyUA@mail.gmail.com>
Subject: Re: [PATCH 1/3] userfaultfd: non-cooperative: fix fork fctx->new memleak
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, alexander.levin@verizon.com

On Thu, Mar 2, 2017 at 9:37 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> From: Mike Rapoport <rppt@linux.vnet.ibm.com>
>
> We have a memleak in the ->new ctx if the uffd of the parent is closed
> before the fork event is read, nothing frees the new context.

Hey Mike,

This seems to result in the following:

==================================================================
BUG: KASAN: use-after-free in resolve_userfault_fork
fs/userfaultfd.c:967 [inline]
BUG: KASAN: use-after-free in userfaultfd_ctx_read+0xa2e/0x2110
fs/userfaultfd.c:1093
Read of size 4 at addr ffff880064944204 by task syz-executor5/6524

CPU: 1 PID: 6524 Comm: syz-executor5 Not tainted 4.13.0-next-20170908+ #246
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.10.1-1ubuntu1 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 print_address_description+0xcb/0x250 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351 [inline]
 kasan_report+0x275/0x360 mm/kasan/report.c:409
 __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:429
 resolve_userfault_fork fs/userfaultfd.c:967 [inline]
 userfaultfd_ctx_read+0xa2e/0x2110 fs/userfaultfd.c:1093
 userfaultfd_read+0x1a3/0x260 fs/userfaultfd.c:1126
 do_loop_readv_writev fs/read_write.c:693 [inline]
 do_iter_read+0x3db/0x5b0 fs/read_write.c:917
 vfs_readv+0x130/0x1d0 fs/read_write.c:979
 do_readv+0x108/0x2d0 fs/read_write.c:1012
 SYSC_readv fs/read_write.c:1099 [inline]
 SyS_readv+0x27/0x30 fs/read_write.c:1096
 do_syscall_64+0x26a/0x800 arch/x86/entry/common.c:287
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x452ea9
RSP: 002b:00007fa93a8bac08 EFLAGS: 00000216 ORIG_RAX: 0000000000000013
RAX: ffffffffffffffda RBX: 0000000000718210 RCX: 0000000000452ea9
RDX: 0000000000000001 RSI: 000000002000f000 RDI: 0000000000000015
RBP: 0000000000004000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000216 R12: 00000000004bc64f
R13: 00000000ffffffff R14: 0000000000000015 R15: 000000002000f000

Allocated by task 6495:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:489
 slab_post_alloc_hook mm/slab.h:444 [inline]
 slab_alloc_node mm/slub.c:2745 [inline]
 slab_alloc mm/slub.c:2753 [inline]
 kmem_cache_alloc+0x121/0x390 mm/slub.c:2758
 dup_userfaultfd+0x21e/0x890 fs/userfaultfd.c:653
 dup_mmap kernel/fork.c:658 [inline]
 dup_mm kernel/fork.c:1179 [inline]
 copy_mm+0xa49/0x130d kernel/fork.c:1233
 copy_process.part.30+0x21d5/0x4f00 kernel/fork.c:1735
 copy_process kernel/fork.c:1548 [inline]
 _do_fork+0x1f7/0x1050 kernel/fork.c:2027
 SYSC_clone kernel/fork.c:2137 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2131
 do_syscall_64+0x26a/0x800 arch/x86/entry/common.c:287
 return_from_SYSCALL_64+0x0/0x7a

Freed by task 6495:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:524
 slab_free_hook mm/slub.c:1390 [inline]
 slab_free_freelist_hook mm/slub.c:1412 [inline]
 slab_free mm/slub.c:2988 [inline]
 kmem_cache_free+0xb6/0x320 mm/slub.c:3010
 userfaultfd_ctx_put+0x50c/0x740 fs/userfaultfd.c:165
 userfaultfd_event_wait_completion+0x763/0x930 fs/userfaultfd.c:599
 dup_fctx fs/userfaultfd.c:687 [inline]
 dup_userfaultfd_complete+0x2e0/0x480 fs/userfaultfd.c:695
 dup_mmap kernel/fork.c:726 [inline]
 dup_mm kernel/fork.c:1179 [inline]
 copy_mm+0xe7c/0x130d kernel/fork.c:1233
 copy_process.part.30+0x21d5/0x4f00 kernel/fork.c:1735
 copy_process kernel/fork.c:1548 [inline]
 _do_fork+0x1f7/0x1050 kernel/fork.c:2027
 SYSC_clone kernel/fork.c:2137 [inline]
 SyS_clone+0x37/0x50 kernel/fork.c:2131
 do_syscall_64+0x26a/0x800 arch/x86/entry/common.c:287
 return_from_SYSCALL_64+0x0/0x7a

The buggy address belongs to the object at ffff880064944040
 which belongs to the cache userfaultfd_ctx_cache of size 480
The buggy address is located 452 bytes inside of
 480-byte region [ffff880064944040, ffff880064944220)
The buggy address belongs to the page:
page:ffffea0001925100 count:1 mapcount:0 mapping:          (null)
index:0xffff880064947bc0 compound_mapcount: 0
flags: 0x4fffe0000008100(slab|head)
raw: 04fffe0000008100 0000000000000000 ffff880064947bc0 0000000100120001
raw: ffff88006a556d98 ffff88006a556d98 ffff88003e7c31c0 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff880064944100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880064944180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880064944200: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc
                   ^
 ffff880064944280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880064944300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
