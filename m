Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 182CE6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 09:12:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so88056071wme.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 06:12:18 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id 99si2274215lja.72.2016.07.05.06.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 06:12:16 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id h129so134532905lfh.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 06:12:16 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 5 Jul 2016 15:11:56 +0200
Message-ID: <CACT4Y+Z27=Jsu9_Gdfj4aap6EKQ5kN7+kHxTdNMbMQx6nSmfWw@mail.gmail.com>
Subject: mm: page fault in __do_huge_pmd_anonymous_page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>

Hello,

While running syzkaller fuzzer I've got the following crash report.
Unfortunately it's not reproducible.
On commit 1a0a02d1efa066001fd315c1b4df583d939fa2c4 (Jun 30).

BUG: unable to handle kernel paging request at ffff88005f269000
IP: [<ffffffff82ced4ac>] clear_page+0xc/0x10 arch/x86/lib/clear_page_64.S:22
PGD a973067 PUD a976067 PMD 7fc09067 PTE 800000005f269060
Oops: 0002 [#1] SMP DEBUG_PAGEALLOC KASAN
Modules linked in:
CPU: 3 PID: 10563 Comm: syz-executor Not tainted 4.7.0-rc5+ #28
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880069230300 ti: ffff88006c288000 task.ti: ffff88006c288000
RIP: 0010:[<ffffffff82ced4ac>]
 [<ffffffff82ced4ac>] clear_page+0xc/0x10 arch/x86/lib/clear_page_64.S:22
RSP: 0018:ffff88006c28fce8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 00000000017c9a40 RCX: 0000000000000200
RDX: 0000000080000000 RSI: 0000000000000f42 RDI: ffff88005f269000
RBP: ffff88006c28fd40 R08: 0000000000029900 R09: 0000000000000000
R10: fffffffffffffffd R11: ffffffffffffffe8 R12: dffffc0000000000
R13: ffff880069230300 R14: 00000000017d0000 R15: ffffed000d2462b7
FS:  0000000002c4c880(0000) GS:ffff88006d500000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff88005f269000 CR3: 000000006b2b3000 CR4: 00000000000006e0
Stack:
 ffffffff81747f60 0000000000000000 ffff88006c28fd20 ffffffff81483dcd
 ffffea00019ebf40 ffff8800692315b8 ffff8800672c9700 0000000020000000
 1ffff1000d851fb2 ffffea00017c8000 0000000000000000 ffff88006c28fe18
Call Trace:
 [<     inline     >] ? clear_user_page ./arch/x86/include/asm/page.h:27
 [<     inline     >] ? clear_user_highpage include/linux/highmem.h:136
 [<ffffffff81747f60>] ? clear_huge_page+0x110/0x470 mm/memory.c:3907
 [<ffffffff81483dcd>] ? __raw_spin_lock_init+0x2d/0x100
kernel/locking/spinlock_debug.c:24
 [<     inline     >] __do_huge_pmd_anonymous_page mm/huge_memory.c:819
 [<ffffffff817d727b>] do_huge_pmd_anonymous_page+0x53b/0xfe0
mm/huge_memory.c:970
 [<ffffffff814b4be7>] ? debug_lockdep_rcu_enabled+0x77/0x90
kernel/rcu/update.c:261
 [<ffffffff817d6d40>] ? __khugepaged_enter+0x2a0/0x2a0 mm/huge_memory.c:1903
 [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:907
 [<     inline     >] ? mem_cgroup_count_vm_event include/linux/memcontrol.h:513
 [<ffffffff81741b94>] ? handle_mm_fault+0x194/0x11a0 mm/memory.c:3506
 [<     inline     >] create_huge_pmd mm/memory.c:3309
 [<     inline     >] __handle_mm_fault mm/memory.c:3433
 [<ffffffff81742994>] handle_mm_fault+0xf94/0x11a0 mm/memory.c:3518
 [<     inline     >] ? arch_static_branch include/linux/vmstat.h:41
 [<     inline     >] ? mem_cgroup_disabled include/linux/memcontrol.h:278
 [<     inline     >] ? mem_cgroup_count_vm_event include/linux/memcontrol.h:494
 [<ffffffff81741a94>] ? handle_mm_fault+0x94/0x11a0 mm/memory.c:3506
 [<ffffffff81290e67>] __do_page_fault+0x457/0xbb0 arch/x86/mm/fault.c:1356
 [<ffffffff8129170f>] trace_do_page_fault+0xdf/0x5b0 arch/x86/mm/fault.c:1449
 [<ffffffff81281c24>] do_async_page_fault+0x14/0xd0 arch/x86/kernel/kvm.c:265
 [<ffffffff86a96fb8>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923
Code: ff ff e9 fd fe ff ff 4c 89 ff e8 e0 c6 ac fe e9 1a ff ff ff 90
90 90 90 90 90 90 90 90 90 90 0f 1f 44 00 00 b9 00 02 00 00 31 c0 <f3>
48 ab c3 31 c0 b9 40 00 00 00 66 0f 1f 84 00 00 00 00 00 ff
RIP  [<ffffffff82ced4ac>] clear_page+0xc/0x10 arch/x86/lib/clear_page_64.S:22
 RSP <ffff88006c28fce8>
CR2: ffff88005f269000
---[ end trace 69bd3018b876c97d ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
