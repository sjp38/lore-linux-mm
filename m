Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD276B0255
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 09:37:40 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so192340184pab.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 06:37:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f7si10157574pat.97.2015.11.30.06.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 06:37:39 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: kernel BUG at mm/huge_memory.c:3272!
Message-ID: <565C5F2D.5060003@oracle.com>
Date: Mon, 30 Nov 2015 09:37:33 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Kirill,

I've hit the following while fuzzing with trinity on the latest -next kernel:

[  321.348184] page:ffffea0011a20080 count:1 mapcount:1 mapping:ffff8802d745f601 index:0x1802
[  321.350607] flags: 0x320035c00040078(uptodate|dirty|lru|active|swapbacked)
[  321.453706] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
[  321.455353] page->mem_cgroup:ffff880286620000
[  321.456482] ------------[ cut here ]------------
[  321.457158] kernel BUG at mm/huge_memory.c:3272!
[  321.457811] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  321.458598] Modules linked in:
[  321.459057] CPU: 18 PID: 24106 Comm: trinity-c129 Not tainted 4.4.0-rc2-next-20151127-sasha-00012-gf0498ca-dirty #2661
[  321.460516] task: ffff880042fd2000 ti: ffff8800428c0000 task.ti: ffff8800428c0000
[  321.461732] RIP: split_huge_page_to_list (mm/huge_memory.c:3272 (discriminator 1))
[  321.464004] RSP: 0000:ffff8800428c71d0  EFLAGS: 00010246
[  321.464733] RAX: ffff880042fd2000 RBX: ffffea0011a20080 RCX: 0000000000000000
[  321.465735] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffffed0008518e1f
[  321.466719] RBP: ffff8800428c72b0 R08: fffffbfff4f9eaf1 R09: ffffffffa7cf578f
[  321.467704] R10: ffffed0105fe6293 R11: 1ffffffff4f9eaed R12: ffffea0011a20060
[  321.468702] R13: ffffea0011a200a0 R14: ffffea0011a20080 R15: ffff8800428c7300
[  321.469718] FS:  00007f9d611bb700(0000) GS:ffff880686800000(0000) knlGS:0000000000000000
[  321.470807] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  321.471608] CR2: 0000000001b54fe8 CR3: 0000000042869000 CR4: 00000000000006a0
[  321.472633] DR0: 00007f9d5cb76000 DR1: 0000000000000000 DR2: 0000000000000000
[  321.473612] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  321.474619] Stack:
[  321.474935]  ffff8800428c7300 ffff8800428c72b0 ffffffff9950f2c8 dffffc0000000000
[  321.476071]  0000000041b58ab3 ffffffffa4871335 ffffffff9950f0c0 dffffc0000000000
[  321.477184]  ffffea0011a20000 0000000000000000 0000000000000000 0000000000000001
[  321.478297] Call Trace:
[  321.481234] deferred_split_scan (mm/huge_memory.c:3392)
[  321.484688] shrink_slab (mm/vmscan.c:354 mm/vmscan.c:446)
[  321.488008] shrink_zone (mm/vmscan.c:2449)
[  321.493105] do_try_to_free_pages (mm/vmscan.c:2600 mm/vmscan.c:2650)
[  321.496657] try_to_free_pages (mm/vmscan.c:2858)
[  321.498346] __alloc_pages_nodemask (mm/page_alloc.c:2878 mm/page_alloc.c:2896 mm/page_alloc.c:3149 mm/page_alloc.c:3260)
[  321.508819] alloc_pages_vma (mm/mempolicy.c:2042)
[  321.509629] wp_page_copy.isra.41 (mm/memory.c:2064)
[  321.512347] do_wp_page (mm/memory.c:2339)
[  321.518569] handle_mm_fault (mm/memory.c:3302 mm/memory.c:3396 mm/memory.c:3425)
[  321.527500] __do_page_fault (arch/x86/mm/fault.c:1239)
[  321.528411] do_page_fault (arch/x86/mm/fault.c:1301 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:50 arch/x86/mm/fault.c:1302)
[  321.530053] do_async_page_fault (./arch/x86/include/asm/traps.h:82 arch/x86/kernel/kvm.c:264)
[  321.532125] async_page_fault (arch/x86/entry/entry_64.S:989)
[ 321.533057] Code: ea 03 80 3c 02 00 74 08 48 89 df e8 58 4d fe ff 48 8b 03 a8 01 75 16 e8 7c 51 fe ff 48 c7 c6 80 3c 4f a2 4c 89 f7 e8 2d 84 f5 ff <0f> 0b e8 66 51 fe ff 48 8b 55 c8 48 b8 00 00 00 00 00 fc ff df
All code
========
   0:   ea                      (bad)
   1:   03 80 3c 02 00 74       add    0x7400023c(%rax),%eax
   7:   08 48 89                or     %cl,-0x77(%rax)
   a:   df e8                   fucomip %st(0),%st
   c:   58                      pop    %rax
   d:   4d fe                   rex.WRB (bad)
   f:   ff 48 8b                decl   -0x75(%rax)
  12:   03 a8 01 75 16 e8       add    -0x17e98aff(%rax),%ebp
  18:   7c 51                   jl     0x6b
  1a:   fe                      (bad)
  1b:   ff 48 c7                decl   -0x39(%rax)
  1e:   c6 80 3c 4f a2 4c 89    movb   $0x89,0x4ca24f3c(%rax)
  25:   f7 e8                   imul   %eax
  27:   2d 84 f5 ff 0f          sub    $0xffff584,%eax
  2c:   0b e8                   or     %eax,%ebp
  2e:   66 51                   push   %cx
  30:   fe                      (bad)
  31:   ff 48 8b                decl   -0x75(%rax)
  34:   55                      push   %rbp
  35:*  c8 48 b8 00             enterq $0xb848,$0x0             <-- trapping instruction
  39:   00 00                   add    %al,(%rax)
  3b:   00 00                   add    %al,(%rax)
  3d:   fc                      cld
  3e:   ff df                   lcallq *<internal disassembler error>
        ...

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   e8 66 51 fe ff          callq  0xfffffffffffe516d
   7:   48 8b 55 c8             mov    -0x38(%rbp),%rdx
   b:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  12:   fc ff df
        ...
[  321.537072] RIP split_huge_page_to_list (mm/huge_memory.c:3272 (discriminator 1))
[  321.537942]  RSP <ffff8800428c71d0>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
