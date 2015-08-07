Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id A2A7C6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 12:14:27 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so36231652lbb.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 09:14:27 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id bn6si7828085lbc.95.2015.08.07.09.14.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 09:14:26 -0700 (PDT)
Received: by lagz9 with SMTP id z9so24815291lag.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 09:14:25 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 7 Aug 2015 18:14:24 +0200
Message-ID: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com>
Subject: Potential data race in SyS_swapon
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, Miklos Szeredi <mszeredi@suse.cz>, Jason Low <jason.low2@hp.com>, Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hi!

We are working on a dynamic data race detector for the Linux kernel
called KernelThreadSanitizer (ktsan)
(https://github.com/google/ktsan/wiki).

While running ktsan on the upstream revision 21bdb584af8c with trinity
we got a few reports from SyS_swapon, here is one of them:

==================================================================
ThreadSanitizer: data-race in SyS_swapon

Read of size 8 by thread T307 (K7621):
 [<     inlined    >] SyS_swapon+0x3c0/0x1850 SYSC_swapon mm/swapfile.c:2395
 [<ffffffff812242c0>] SyS_swapon+0x3c0/0x1850 mm/swapfile.c:2345
 [<ffffffff81e97c8a>] ia32_do_call+0x1b/0x25
arch/x86/entry/entry_64_compat.S:500
DBG: cpu = ffff88063fc9fe68
DBG: cpu id = 1

Previous write of size 8 by thread T322 (K7625):
 [<     inlined    >] SyS_swapon+0x809/0x1850 SYSC_swapon mm/swapfile.c:2540
 [<ffffffff81224709>] SyS_swapon+0x809/0x1850 mm/swapfile.c:2345
 [<ffffffff81e957ae>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
DBG: cpu = 0

DBG: addr: ffff8800bba262d8
DBG: first offset: 0, second offset: 0
DBG: T307 clock: {T307: 1942841, T322: 3661262}
DBG: T322 clock: {T322: 3661679}
==================================================================

The race is happening when accessing the swap_file field of a
swap_info_struct struct.

2392         for (i = 0; i < nr_swapfiles; i++) {
2393                 struct swap_info_struct *q = swap_info[i];
2394
2395                 if (q == p || !q->swap_file)
2396                         continue;
2397                 if (mapping == q->swap_file->f_mapping) {
2398                         error = -EBUSY;
2399                         goto bad_swap;
2400                 }
2401         }

2539         spin_lock(&swap_lock);
2540         p->swap_file = NULL;
2541         p->flags = 0;
2542         spin_unlock(&swap_lock);

Since the swap_lock lock is not taken in the first snippet, it's
possible for q->swap_file to be assigned to NULL and reloaded between
executing lines 2395 and 2397, which might lead to a null pointer
dereference.

To confirm this I added a sleep in there:

2393         for (i = 0; i < nr_swapfiles; i++) {
2394                 struct swap_info_struct *q = swap_info[i];
2395
2396                 if (q == p || !q->swap_file)
2397                         continue;
2398                 msleep(10);
2399                 if (mapping == q->swap_file->f_mapping) {
2400                         error = -EBUSY;
2401                         goto bad_swap;
2402                 }
2403         }

And that leads to:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000f8
IP: [<     inlined    >] SyS_swapon+0x3eb/0x1880 SYSC_swapon mm/swapfile.c:2399
IP: [<ffffffff8122431b>] SyS_swapon+0x3eb/0x1880 mm/swapfile.c:2346
PGD 1d08db067 PUD 1d0e63067 PMD 0
Oops: 0000 [#5] SMP
Modules linked in:
CPU: 0 PID: 7516 Comm: trinity-c7 Tainted: G      D         4.2.0-rc2-tsan #229
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8801d37d0040 ti: ffff8801cc1f4000 task.ti: ffff8801cc1f4000
RIP: 0010:[<ffffffff8122431b>]  [<ffffffff8122431b>] SyS_swapon+0x3eb/0x1880
RSP: 0000:ffff8801cc1f7e28  EFLAGS: 00010292
RAX: 0000000000000001 RBX: ffff8800bb0e9400 RCX: 0000000000000003
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000292
RBP: ffff8801cc1f7f48 R08: 0000000000000001 R09: 0000000000000006
R10: ffff880249752820 R11: 0000000000000005 R12: 0000000000000000
R13: 0000000000000000 R14: ffff8800bb4ca2d8 R15: ffff8800bb0394d8
FS:  00007f080f521700(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000002360fe8 CR3: 00000001cf2f0000 CR4: 00000000000006f0
DR0: 0000000001f6f000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Stack:
 00000505d2000000 000000dc1eb617ff ffff8801cc1f7e58 ffffffff812454c8
 ffff8801cc1f7f30 0000000000000246 ffff8801cc1f7e78 ffff880249752820
 ffff880249752820 0000000000000007 0000000000000268 ffff880249752820
Call Trace:
 [<ffffffff812454c8>] ? kt_func_exit+0x18/0x60 mm/ktsan/func.c:14
 [<ffffffff812454c8>] ? kt_func_exit+0x18/0x60 mm/ktsan/func.c:14
 [<ffffffff81e9582e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
Code: 00 49 83 bd d8 00 00 00 00 74 2d e8 80 b8 c6 00 4c 89 ff e8 38
1b 02 00 4d 8b ad d8 00 00 00 49 8d bd f8 00 00 00 e8 25 1b 02 00 <4d>
3b b5 f8 00 00 00 0f 84 c7 03 00 00 48 c7 c7 50 10 72 82 41
RIP  [<     inlined    >] SyS_swapon+0x3eb/0x1880 SYSC_swapon mm/swapfile.c:2399
RIP  [<ffffffff8122431b>] SyS_swapon+0x3eb/0x1880 mm/swapfile.c:2346
 RSP <ffff8801cc1f7e28>
CR2: 00000000000000f8
---[ end trace e38cbebf888067b7 ]---

Looks like the swap_lock should be taken when iterating through the
swap_info array on lines 2392 - 2401.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
