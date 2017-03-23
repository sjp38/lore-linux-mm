Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D30696B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:20:00 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 62so46510978uas.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 03:20:00 -0700 (PDT)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id o184si1520005vka.140.2017.03.23.03.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 03:19:59 -0700 (PDT)
Received: by mail-ua0-x229.google.com with SMTP id x52so5998297uax.3
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 03:19:59 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 23 Mar 2017 11:19:38 +0100
Message-ID: <CACT4Y+Z-trVe0Oqzs8c+mTG6_iL7hPBBFgOm0p0iQsCz9Q2qiw@mail.gmail.com>
Subject: mm: BUG in resv_map_release
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

Hello,

I've got the following BUG while running syzkaller fuzzer.
Note the injected kmalloc failure, most likely it's the root cause.


FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 2 PID: 12823 Comm: syz-executor1 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 fail_dump lib/fault-inject.c:45 [inline]
 should_fail+0x78a/0x870 lib/fault-inject.c:154
 should_failslab+0xec/0x120 mm/failslab.c:31
 slab_pre_alloc_hook mm/slab.h:434 [inline]
 slab_alloc mm/slab.c:3394 [inline]
 kmem_cache_alloc_trace+0x206/0x720 mm/slab.c:3636
 kmalloc include/linux/slab.h:490 [inline]
 region_chg+0x429/0xa80 mm/hugetlb.c:402
 hugetlb_reserve_pages+0x16d/0x540 mm/hugetlb.c:4334
 hugetlb_file_setup+0x40c/0x9f0 fs/hugetlbfs/inode.c:1289
 newseg+0x422/0xd30 ipc/shm.c:575
 ipcget_new ipc/util.c:285 [inline]
 ipcget+0x21e/0x580 ipc/util.c:639
 SYSC_shmget ipc/shm.c:673 [inline]
 SyS_shmget+0x158/0x230 ipc/shm.c:657
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f273aba1858 EFLAGS: 00000282 ORIG_RAX: 000000000000001d
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000000000900 RSI: 0000000000003000 RDI: 0000000000000000
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000020000000 R11: 0000000000000282 R12: 00000000004a7e31
R13: 0000000000000000 R14: 00007f273aba1618 R15: 00007f273aba1788
------------[ cut here ]------------
kernel BUG at mm/hugetlb.c:742!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 2 PID: 12823 Comm: syz-executor1 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006be3c0c0 task.stack: ffff88003daa0000
RIP: 0010:resv_map_release+0x265/0x330 mm/hugetlb.c:742
RSP: 0018:ffff88003daa7830 EFLAGS: 00010246
RAX: 0000000000010000 RBX: dffffc0000000000 RCX: ffffc90002253000
RDX: 0000000000010000 RSI: ffffffff81976485 RDI: ffff88006b5bf950
RBP: ffff88003daa78e0 R08: 1ffff1000d7c7a5b R09: 0000000000000000
R10: 0000000000000006 R11: 0000000000000000 R12: ffff88006b5bf958
R13: ffffed0007b54f0f R14: ffff88006b5bf958 R15: ffff88006b5bf958
FS:  00007f273aba2700(0000) GS:ffff88006e200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f68fabe8000 CR3: 0000000014a09000 CR4: 00000000000026e0
DR0: 0000000020000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 hugetlbfs_evict_inode+0x7b/0xa0 fs/hugetlbfs/inode.c:493
 evict+0x481/0x920 fs/inode.c:553
 iput_final fs/inode.c:1515 [inline]
 iput+0x62b/0xa20 fs/inode.c:1542
 hugetlb_file_setup+0x593/0x9f0 fs/hugetlbfs/inode.c:1306
 newseg+0x422/0xd30 ipc/shm.c:575
 ipcget_new ipc/util.c:285 [inline]
 ipcget+0x21e/0x580 ipc/util.c:639
 SYSC_shmget ipc/shm.c:673 [inline]
 SyS_shmget+0x158/0x230 ipc/shm.c:657
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f273aba1858 EFLAGS: 00000282 ORIG_RAX: 000000000000001d
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000000000900 RSI: 0000000000003000 RDI: 0000000000000000
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000020000000 R11: 0000000000000282 R12: 00000000004a7e31
R13: 0000000000000000 R14: 00007f273aba1618 R15: 00007f273aba1788
Code: 00 fc ff df 48 c7 04 01 00 00 00 00 c7 44 08 08 00 00 00 00 48
81 c4 88 00 00 00 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 ab a5 d5 ff <0f>
0b 48 8b bd 70 ff ff ff e8 ad c0 03 00 e9 2c fe ff ff e8 a3
RIP: resv_map_release+0x265/0x330 mm/hugetlb.c:742 RSP: ffff88003daa7830
---[ end trace 575ce95655b30bd0 ]---

On commit 093b995e3b55a0ae0670226ddfcb05bfbf0099ae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
