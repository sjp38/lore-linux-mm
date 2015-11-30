Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE6E6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:25:02 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so129165905obd.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 06:25:02 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y199si33822127oia.146.2015.11.30.06.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 06:25:01 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: BUG in __munlock_pagevec
Message-ID: <565C5C38.3040705@oracle.com>
Date: Mon, 30 Nov 2015 09:24:56 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

I've hit the following while fuzzing with trinity on the latest -next kernel:


[  850.305385] page:ffffea001a5a0f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1ffffffffff
[  850.306773] flags: 0x2fffff80000000()
[  850.307175] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
[  850.308027] page_owner info is not active (free page?)
[  850.308925] ------------[ cut here ]------------
[  850.309614] kernel BUG at include/linux/page-flags.h:326!
[  850.310333] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  850.311176] Modules linked in:
[  850.311650] CPU: 5 PID: 7051 Comm: trinity-c129 Not tainted 4.4.0-rc2-next-20151127-sasha-00012-gf0498ca-dirty #2661
[  850.313115] task: ffff8806eaf08000 ti: ffff8806b1170000 task.ti: ffff8806b1170000
[  850.314085] RIP: __munlock_pagevec (include/linux/page-flags.h:326 mm/mlock.c:296)
[  850.315341] RSP: 0018:ffff8806b11778d0  EFLAGS: 00010046
[  850.316086] RAX: ffff8806eaf08000 RBX: ffff8806b1177b58 RCX: 0000000000000000
[  850.316938] RDX: 0000000000000000 RSI: 0000000000000046 RDI: ffffed00d622eef6
[  850.317777] RBP: ffff8806b1177a20 R08: fffffbfff439eaf3 R09: ffffffffa1cf5798
[  850.318453] R10: ffff8806f2aef9c0 R11: 1ffffffff439eaed R12: ffffea001a5a0f00
[  850.319131] R13: dffffc0000000000 R14: ffffea001a5a0f20 R15: ffff8806b11779f8
[  850.319807] FS:  0000000000000000(0000) GS:ffff8806fd340000(0000) knlGS:0000000000000000
[  850.320595] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  850.321155] CR2: 00000000006e0000 CR3: 00000006e2fd2000 CR4: 00000000000406e0
[  850.321839] Stack:
[  850.322045]  1ffff100d622ef23 ffff88082ffd8000 ffff8806b1177b48 0000000300000000
[  850.322811]  0000000000000003 ffff88082ffd6000 ffff8806b1177938 ffff8806b1177b58
[  850.323570]  ffffea001aadf700 0000000041b58ab3 ffffffff9e8778fa ffffffff93597a40
[  850.324396] Call Trace:
[  850.330731] munlock_vma_pages_range (mm/mlock.c:485)
[  850.335325] exit_mmap (mm/mmap.c:2844)
[  850.338123] mmput (include/linux/compiler.h:218 kernel/fork.c:750 kernel/fork.c:717)
[  850.338591] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:438 kernel/exit.c:735)
[  850.341432] do_group_exit (kernel/exit.c:862)
[  850.341950] SyS_exit_group (kernel/exit.c:889)
[  850.342582] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)
[ 850.343177] Code: 34 07 00 48 8b 85 f0 fe ff ff 49 8b 54 24 20 48 89 c3 83 e2 01 74 50 e8 ea 38 07 00 48 c7 c6 20 a3 4e 9c 4c 89 e7 e8 9b 6b fe ff <0f> 0b e8 d4 38 07 00 48 8b 85 d0 fe ff ff 48 8b 9d c0 fe ff ff
All code
========
   0:   34 07                   xor    $0x7,%al
   2:   00 48 8b                add    %cl,-0x75(%rax)
   5:   85 f0                   test   %esi,%eax
   7:   fe                      (bad)
   8:   ff                      (bad)
   9:   ff 49 8b                decl   -0x75(%rcx)
   c:   54                      push   %rsp
   d:   24 20                   and    $0x20,%al
   f:   48 89 c3                mov    %rax,%rbx
  12:   83 e2 01                and    $0x1,%edx
  15:   74 50                   je     0x67
  17:   e8 ea 38 07 00          callq  0x73906
  1c:   48 c7 c6 20 a3 4e 9c    mov    $0xffffffff9c4ea320,%rsi
  23:   4c 89 e7                mov    %r12,%rdi
  26:   e8 9b 6b fe ff          callq  0xfffffffffffe6bc6
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   e8 d4 38 07 00          callq  0x73906
  32:   48 8b 85 d0 fe ff ff    mov    -0x130(%rbp),%rax
  39:   48 8b 9d c0 fe ff ff    mov    -0x140(%rbp),%rbx
        ...

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   e8 d4 38 07 00          callq  0x738db
   7:   48 8b 85 d0 fe ff ff    mov    -0x130(%rbp),%rax
   e:   48 8b 9d c0 fe ff ff    mov    -0x140(%rbp),%rbx
        ...
[  850.345913] RIP __munlock_pagevec (include/linux/page-flags.h:326 mm/mlock.c:296)
[  850.346536]  RSP <ffff8806b11778d0>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
