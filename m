Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 591DE6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:37:06 -0400 (EDT)
Received: by qgev79 with SMTP id v79so90295653qge.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:37:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w95si21679360qge.15.2015.09.21.07.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 07:37:05 -0700 (PDT)
Message-ID: <5600160B.3000400@oracle.com>
Date: Mon, 21 Sep 2015 10:36:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: NULL ptr deref in handle_mm_fault
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running -next kernel I've
stumbled on:

[1717058.906453] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[1717058.910606] Modules linked in:
[1717058.911423] CPU: 6 PID: 16918 Comm: trinity-c136 Not tainted 4.3.0-rc1-next-20150918-sasha-00081-g4b7392a-dirty #2567
[1717058.913616] task: ffff8803b767c000 ti: ffff8803c1190000 task.ti: ffff8803c1190000
[1717058.915215] RIP: handle_mm_fault (./arch/x86/include/asm/pgtable.h:547 mm/memory.c:3401 mm/memory.c:3432)
[1717058.917170] RSP: 0000:ffff8803c1197cd0  EFLAGS: 00010202
[1717058.918303] RAX: dffffc0000000000 RBX: ffff88042c6cfd40 RCX: 1ffffffff5858826
[1717058.919794] RDX: 0000000000000000 RSI: ffff8803b767ccb8 RDI: 0000000310392067
[1717058.921275] RBP: ffff8803c1197e78 R08: 0000000000000108 R09: 00000000000003f2
[1717058.922744] R10: 0000000000000002 R11: fffff91f843c5644 R12: 0000000000000000
[1717058.924242] R13: ffff88042c6cfd90 R14: 00007fbfca421230 R15: ffff880174174000
[1717058.925858] FS:  00007fbfca8d3700(0000) GS:ffff88032e200000(0000) knlGS:0000000000000000
[1717058.927711] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1717058.928931] CR2: 0000000000000000 CR3: 00000003d2b3f000 CR4: 00000000000006a0
[1717058.930435] Stack:
[1717058.930917]  ffffffff9f778b6f ffff8803c1197bc0 0000000000000000 ffffffff9f75d250
[1717058.932712]  0000000000000000 ffff8803b767c000 ffffffff9f778a30 0000000000000000
[1717058.934426]  ffffffff9f27ee03 ffff88070a4b1c90 ffffffff9f778a30 0000000000000000
[1717058.936158] Call Trace:
[1717058.949349] __do_page_fault (arch/x86/mm/fault.c:1239)
[1717058.952904] trace_do_page_fault (arch/x86/mm/fault.c:1331 include/linux/jump_label.h:133 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:46 arch/x86/mm/fault.c:1332)
[1717058.954825] do_async_page_fault (arch/x86/kernel/kvm.c:280)
[1717058.956371] async_page_fault (arch/x86/entry/entry_64.S:989)
[1717058.957819] Code: 81 e4 80 00 00 00 0f 85 87 09 00 00 48 b8 00 00 00 00 00 fc ff df 4d 89 f0 4c 89 d2 49 c1 e8 09 48 c1 ea 03 41 81 e0 f8 0f 00 00 <80> 3c 02 00 0f 85 28 38 00 00 48 ba 00 00 00 00 00 fc ff df 4c
All code
========
   0:   81 e4 80 00 00 00       and    $0x80,%esp
   6:   0f 85 87 09 00 00       jne    0x993
   c:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  13:   fc ff df
  16:   4d 89 f0                mov    %r14,%r8
  19:   4c 89 d2                mov    %r10,%rdx
  1c:   49 c1 e8 09             shr    $0x9,%r8
  20:   48 c1 ea 03             shr    $0x3,%rdx
  24:   41 81 e0 f8 0f 00 00    and    $0xff8,%r8d
  2b:*  80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)               <-- trapping instruction
  2f:   0f 85 28 38 00 00       jne    0x385d
  35:   48 ba 00 00 00 00 00    movabs $0xdffffc0000000000,%rdx
  3c:   fc ff df
  3f:   4c                      rex.WR
        ...

Code starting with the faulting instruction
===========================================
   0:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
   4:   0f 85 28 38 00 00       jne    0x3832
   a:   48 ba 00 00 00 00 00    movabs $0xdffffc0000000000,%rdx
  11:   fc ff df
  14:   4c                      rex.WR
        ...
[1717058.967918] RIP handle_mm_fault (./arch/x86/include/asm/pgtable.h:547 mm/memory.c:3401 mm/memory.c:3432)
[1717058.970464]  RSP <ffff8803c1197cd0>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
