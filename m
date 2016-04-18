Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30ED36B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 10:45:00 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g185so411096268ioa.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 07:45:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 197si21904984ion.193.2016.04.18.07.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 07:44:58 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: NULL ptr deref in free_pages_and_swap_cache
Message-ID: <5714F2C4.9010104@oracle.com>
Date: Mon, 18 Apr 2016 10:44:20 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[  326.963405] general protection fault: 0000 [#1] PREEMPT SMP KASAN
[  326.963416] Modules linked in:
[  326.963430] CPU: 0 PID: 10488 Comm: syz-executor Not tainted 4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998
[  326.963437] task: ffff8800b6f91000 ti: ffff8801b5de0000 task.ti: ffff8801b5de0000
[  326.963501] RIP: free_pages_and_swap_cache (./arch/x86/include/asm/bitops.h:311 (discriminator 3) include/linux/page-flags.h:320 (discriminator 3) mm/swap_state.c:242 (discriminator 3) mm/swap_state.c:269 (discriminator 3))
[  326.963505] RSP: 0018:ffff8801b5de7878  EFLAGS: 00010202
[  326.963510] RAX: 00000000000015b0 RBX: 0000000000000003 RCX: 0000000000000000
[  326.963514] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffffffb989fa00
[  326.963519] RBP: ffff8801b5de78b0 R08: 0000000000000000 R09: fffffffffffffff4
[  326.963524] R10: 000000000014000a R11: ffffffffaa24a300 R12: dffffc0000000000
[  326.963532] R13: 000000000000ad80 R14: ffff8800b5eef010 R15: 000000000000ad80
[  326.963539] FS:  00007f01f5466700(0000) GS:ffff8801d4200000(0000) knlGS:0000000000000000
[  326.963544] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  326.963549] CR2: 0000000000811000 CR3: 00000001b3c49000 CR4: 00000000000406f0
[  326.963556] Stack:
[  326.963566]  ffff8801b5de7958 000001fe3911bddd ffff8800b5eef000 dffffc0000000000
[  326.963574]  ffff8800b5eef008 ffff8801b5de7958 00000000000001fe ffff8801b5de78f0
[  326.963582]  ffffffffa06d6ce7 ffff8801b5de7980 ffff8801b5bcc828 dffffc0000000000
[  326.963583] Call Trace:
[  326.963596] tlb_flush_mmu_free (mm/memory.c:259 (discriminator 4))
[  326.963604] tlb_finish_mmu (mm/memory.c:283)
[  326.963613] exit_mmap (mm/mmap.c:2730)
[  326.963649] mmput (include/linux/compiler.h:222 kernel/fork.c:748 kernel/fork.c:715)
[  326.963687] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:437 kernel/exit.c:735)
[  326.963712] do_group_exit (kernel/exit.c:862)
[  326.963720] get_signal (kernel/signal.c:2307)
[  326.963735] do_signal (arch/x86/kernel/signal.c:784)
[  326.963859] exit_to_usermode_loop (arch/x86/entry/common.c:231)
[  326.963868] syscall_return_slowpath (arch/x86/entry/common.c:274 arch/x86/entry/common.c:329)
[  326.963877] ret_from_fork (arch/x86/entry/entry_64.S:404)
[ 326.963953] Code: 00 74 08 4c 89 ff e8 c5 88 05 00 4d 8b 2f 4d 85 ed 4d 89 ef 75 0e 31 f6 48 c7 c7 c0 58 56 ae e8 58 c6 99 01 4c 89 e8 48 c1 e8 03 <42> 80 3c 20 00 74 08 4c 89 ef e8 96 88 05 00 49 8b 45 00 f6 c4
All code
========
   0:   00 74 08 4c             add    %dh,0x4c(%rax,%rcx,1)
   4:   89 ff                   mov    %edi,%edi
   6:   e8 c5 88 05 00          callq  0x588d0
   b:   4d 8b 2f                mov    (%r15),%r13
   e:   4d 85 ed                test   %r13,%r13
  11:   4d 89 ef                mov    %r13,%r15
  14:   75 0e                   jne    0x24
  16:   31 f6                   xor    %esi,%esi
  18:   48 c7 c7 c0 58 56 ae    mov    $0xffffffffae5658c0,%rdi
  1f:   e8 58 c6 99 01          callq  0x199c67c
  24:   4c 89 e8                mov    %r13,%rax
  27:   48 c1 e8 03             shr    $0x3,%rax
  2b:*  42 80 3c 20 00          cmpb   $0x0,(%rax,%r12,1)               <-- trapping instruction
  30:   74 08                   je     0x3a
  32:   4c 89 ef                mov    %r13,%rdi
  35:   e8 96 88 05 00          callq  0x588d0
  3a:   49 8b 45 00             mov    0x0(%r13),%rax
  3e:   f6 c4 00                test   $0x0,%ah

Code starting with the faulting instruction
===========================================
   0:   42 80 3c 20 00          cmpb   $0x0,(%rax,%r12,1)
   5:   74 08                   je     0xf
   7:   4c 89 ef                mov    %r13,%rdi
   a:   e8 96 88 05 00          callq  0x588a5
   f:   49 8b 45 00             mov    0x0(%r13),%rax
  13:   f6 c4 00                test   $0x0,%ah
[  326.963963] RIP free_pages_and_swap_cache (./arch/x86/include/asm/bitops.h:311 (discriminator 3) include/linux/page-flags.h:320 (discriminator 3) mm/swap_state.c:242 (discriminator 3) mm/swap_state.c:269 (discriminator 3))
[  326.963965]  RSP <ffff8801b5de7878>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
