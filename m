Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F70E82958
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 12:02:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g127so43886088ith.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 09:02:49 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0093.outbound.protection.outlook.com. [104.47.0.93])
        by mx.google.com with ESMTPS id 32si2001572otp.99.2016.07.01.09.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 09:02:47 -0700 (PDT)
Subject: Re: mm: BUG in page_move_anon_rmap
References: <CACT4Y+Y9rhgTCuFbg5f4KHzR-_p4-mf4sVn4zoa-3hnY6iEmMQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5776945F.5080303@virtuozzo.com>
Date: Fri, 1 Jul 2016 19:03:43 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y9rhgTCuFbg5f4KHzR-_p4-mf4sVn4zoa-3hnY6iEmMQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>



On 07/01/2016 06:31 PM, Dmitry Vyukov wrote:
> Hello,
> 
> I am getting the following crashes while running syzkaller fuzzer on
> 00bf377d19ad3d80cbc7a036521279a86e397bfb (Jun 29). So far I did not
> manage to reproduce it outside of fuzzer, but fuzzer hits it once per
> hour or so.
> 
> flags: 0xfffe0000044079(locked|uptodate|dirty|lru|active|head|swapbacked)

This report is incomplete. It lacks one line ahead with page address, mapcount, index, etc.

> page dumped because: VM_BUG_ON_PAGE(page->index !=
> linear_page_index(vma, address))
> page->mem_cgroup:ffff88003e829be0
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:1103!
> invalid opcode: 0000 [#2] SMP DEBUG_PAGEALLOC KASAN
> Modules linked in:
> CPU: 0 PID: 7043 Comm: syz-fuzzer Tainted: G      D         4.7.0-rc5+ #22

So the kernel is already tainted. Can you show us the first oops message?

> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff8800342f46c0 ti: ffff880034008000 task.ti: ffff880034008000
> RIP: 0010:[<ffffffff817693d8>] [<ffffffff817693d8>]
> page_move_anon_rmap+0x278/0x310 mm/rmap.c:1103
> RSP: 0000:ffff88003400fad0  EFLAGS: 00010286
> RAX: ffff8800342f46c0 RBX: ffffea0000928000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff88003ec16de8 RDI: ffffed0006801f41
> RBP: ffff88003400fb00 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: ffffed000fffea01 R12: ffff88006776b8e8
> R13: 001000000c829e00 R14: ffff88006247c3e8 R15: 000000000c829e00
> FS:  00007f7627bc5700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000c829fd8000 CR3: 0000000034b23000 CR4: 00000000000006f0
> Stack:
>  ffffea0000928000 ffffea000092f600 ffff88006776b8e8 ffffea0000928000
>  ffffea0000928001 000000c829fd8000 ffff88003400fc38 ffffffff8173a25f
>  0000000000000086 ffff88003400fbd0 ffffea0000928001 ffff880036cd3ec0
> Call Trace:
>  [<ffffffff8173a25f>] do_wp_page+0x7df/0x1c90 mm/memory.c:2402
>  [<ffffffff817404f5>] handle_pte_fault+0x1e85/0x4960 mm/memory.c:3381
>  [<     inline     >] __handle_mm_fault mm/memory.c:3489
>  [<ffffffff8174443b>] handle_mm_fault+0xeab/0x11a0 mm/memory.c:3518
>  [<ffffffff81290f77>] __do_page_fault+0x457/0xbb0 arch/x86/mm/fault.c:1356
>  [<ffffffff8129181f>] trace_do_page_fault+0xdf/0x5b0 arch/x86/mm/fault.c:1449
>  [<ffffffff81281c24>] do_async_page_fault+0x14/0xd0 arch/x86/kernel/kvm.c:265
>  [<ffffffff86a9d538>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923
> Code: 0b e8 dd d5 e2 ff 48 c7 c6 40 f7 d0 86 48 89 df e8 2e 4a fc ff
> 0f 0b e8 c7 d5 e2 ff 48 c7 c6 c0 f7 d0 86 48 89 df e8 18 4a fc ff <0f>
> 0b e8 b1 d5 e2 ff 4c 89 ee 4c 89 e7 e8 96 80 02 00 49 89 c5
> RIP  [<ffffffff817693d8>] page_move_anon_rmap+0x278/0x310 mm/rmap.c:1103
>  RSP <ffff88003400fad0>
> ---[ end trace b6c02a1136e2a9ec ]---
> BUG: sleeping function called from invalid context at include/linux/sched.h:2955
> in_atomic(): 1, irqs_disabled(): 0, pid: 7043, name: syz-fuzzer
> lockdep is turned off.
> CPU: 0 PID: 7043 Comm: syz-fuzzer Tainted: G      D         4.7.0-rc5+ #22
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffffffff880b58e0 ffff88003400f5c0 ffffffff82cc924f ffffffff342f46c0
>  fffffbfff1016b1c ffff8800342f46c0 0000000000001b83 0000000000000000
>  0000000000000000 dffffc0000000000 ffff88003400f5e8 ffffffff813efbfb
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff82cc924f>] dump_stack+0x12e/0x18f lib/dump_stack.c:51
>  [<ffffffff813efbfb>] ___might_sleep+0x27b/0x3a0 kernel/sched/core.c:7573
>  [<ffffffff813efdb0>] __might_sleep+0x90/0x1a0 kernel/sched/core.c:7535
>  [<     inline     >] threadgroup_change_begin include/linux/sched.h:2955
>  [<ffffffff813a175f>] exit_signals+0x7f/0x430 kernel/signal.c:2392
>  [<ffffffff8137a6a4>] do_exit+0x234/0x2c80 kernel/exit.c:701
>  [<ffffffff81204331>] oops_end+0xa1/0xd0 arch/x86/kernel/dumpstack.c:250
>  [<ffffffff812045c6>] die+0x46/0x60 arch/x86/kernel/dumpstack.c:308
>  [<     inline     >] do_trap_no_signal arch/x86/kernel/traps.c:192
>  [<ffffffff811fd9f2>] do_trap+0x192/0x380 arch/x86/kernel/traps.c:238
>  [<ffffffff811fde4e>] do_error_trap+0x11e/0x280 arch/x86/kernel/traps.c:275
>  [<ffffffff811ff18b>] do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:288
>  [<ffffffff86a9cf0e>] invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:761
>  [<ffffffff8173a25f>] do_wp_page+0x7df/0x1c90 mm/memory.c:2402
>  [<ffffffff817404f5>] handle_pte_fault+0x1e85/0x4960 mm/memory.c:3381
>  [<     inline     >] __handle_mm_fault mm/memory.c:3489
>  [<ffffffff8174443b>] handle_mm_fault+0xeab/0x11a0 mm/memory.c:3518
>  [<ffffffff81290f77>] __do_page_fault+0x457/0xbb0 arch/x86/mm/fault.c:1356
>  [<ffffffff8129181f>] trace_do_page_fault+0xdf/0x5b0 arch/x86/mm/fault.c:1449
>  [<ffffffff81281c24>] do_async_page_fault+0x14/0xd0 arch/x86/kernel/kvm.c:265
>  [<ffffffff86a9d538>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:923
> note: syz-fuzzer[7043] exited with preempt_count 1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
