Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F10D26B0038
	for <linux-mm@kvack.org>; Sat,  3 Sep 2016 06:11:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so29963087wmu.3
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 03:11:43 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id d124si7453291lfe.378.2016.09.03.03.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Sep 2016 03:11:42 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id b199so99079211lfe.0
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 03:11:42 -0700 (PDT)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 3 Sep 2016 12:11:21 +0200
Message-ID: <CACT4Y+bnSJoKrYpLmHejjxMq1e43zXomAboUxjZ87_2XvrQmGw@mail.gmail.com>
Subject: mm: kernel BUG in page_add_new_anon_rmap (khugepaged)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?RWJydSBBa2Fnw7xuZMO8eg==?= <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

Hello,

I've got another BUG in khugepaged while running syzkaller fuzzer:

kernel BUG at mm/rmap.c:1248!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 2 PID: 1340 Comm: khugepaged Not tainted 4.8.0-rc3-next-20160825+ #8
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006a40c580 task.stack: ffff88006a438000
RIP: 0010:[<ffffffff817b6a30>]  [<ffffffff817b6a30>]
page_add_new_anon_rmap+0x2e0/0x450 mm/rmap.c:1248
RSP: 0018:ffff88006a43f9c8  EFLAGS: 00010296
RAX: 0000000000000154 RBX: ffffea0000548000 RCX: 0000000000000000
RDX: 0000000000000154 RSI: 0000000000000001 RDI: ffffed000d487f15
RBP: ffff88006a43fa00 R08: 0000000000000001 R09: 0000000000000000
R10: ffff88003cc505c0 R11: 0000000000000001 R12: ffff880038cecd00
R13: 000000c440200000 R14: 0000000000000001 R15: ffff88006a43fb88
FS:  0000000000000000(0000) GS:ffff88006d200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000c43d56a000 CR3: 000000000861c000 CR4: 00000000000006e0
DR0: 000000000000001e DR1: 000000000000001e DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Stack:
 ffffea0000f29c40 ffff880000000200 80000000152000e7 ffff880038cecd00
 ffffea0000f29c40 ffffea0000548000 ffff88006a43fb88 ffff88006a43fbb0
 ffffffff81830466 ffffed000719d9a8 ffff880038cecd40 ffffffff00000001
Call Trace:
 [<ffffffff81830466>] collapse_huge_page+0x2d36/0x3500 mm/khugepaged.c:1066
 [<     inline     >] khugepaged_scan_pmd mm/khugepaged.c:1205
 [<     inline     >] khugepaged_scan_mm_slot mm/khugepaged.c:1718
 [<     inline     >] khugepaged_do_scan mm/khugepaged.c:1799
 [<ffffffff818329fb>] khugepaged+0x1dcb/0x2b30 mm/khugepaged.c:1844
 [<ffffffff813f120f>] kthread+0x23f/0x2d0 kernel/kthread.c:209
 [<ffffffff86e1098a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
Code: df e8 a5 35 fc ff 0f 0b e8 fe 52 e1 ff 48 c7 c6 20 42 11 87 48
89 df e8 8f 35 fc ff 0f 0b e8 e8 52 e1 ff 4c 89 e7 e8 20 2d fc ff <0f>
0b e8 d9 52 e1 ff 4c 89 fa 48 b8 00 00 00 00 00 fc ff df 48
RIP  [<ffffffff817b6a30>] page_add_new_anon_rmap+0x2e0/0x450 mm/rmap.c:1248
 RSP <ffff88006a43f9c8>
---[ end trace 27dc22f88d620ad9 ]---


On 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
