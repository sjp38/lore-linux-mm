Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id D1F096B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:35:04 -0400 (EDT)
Received: by obbeb7 with SMTP id eb7so94975545obb.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:35:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z9si14730100oey.5.2015.04.27.15.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:35:03 -0700 (PDT)
Message-ID: <553EB993.7030401@oracle.com>
Date: Mon, 27 Apr 2015 18:34:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: compaction: BUG in isolate_migratepages_block()
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[ 4249.344788] kernel BUG at include/linux/page-flags.h:575!
[ 4249.344788] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[ 4249.344788] Dumping ftrace buffer:
[ 4249.344788]    (ftrace buffer empty)
[ 4249.344788] Modules linked in:
[ 4249.344788] CPU: 1 PID: 5364 Comm: trinity-c10 Not tainted 4.0.0-next-20150427-sasha-00037-ga12998c-dirty #2183
[ 4249.344788] task: ffff8801a28db000 ti: ffff88006af40000 task.ti: ffff88006af40000
[ 4249.344788] RIP: isolate_migratepages_block (include/linux/page-flags.h:575 include/linux/huge_mm.h:156 include/linux/mm_inline.h:37 mm/compaction.c:784)
[ 4249.383007] RSP: 0000:ffff88006af47398  EFLAGS: 00010282
[ 4249.383007] RAX: dffffc0000000000 RBX: 00000000000305e5 RCX: 0000000000000000
[ 4249.383007] RDX: 1ffffd4000182f2f RSI: 0000000000000000 RDI: ffffea0000c17978
[ 4249.383007] RBP: ffff88006af474f8 R08: 0000000000000001 R09: 0000000000000000
[ 4249.383007] R10: ffffffffab4b2d21 R11: 0000000000000001 R12: dffffc0000000000
[ 4249.401928] R13: 0000000000000001 R14: ffffea0000c17940 R15: 0000000000030600
[ 4249.401928] FS:  00007f816da75700(0000) GS:ffff880053200000(0000) knlGS:0000000000000000
[ 4249.401928] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4249.401928] CR2: 0000000000c73fd8 CR3: 000000006aed7000 CR4: 00000000000007e0
[ 4249.401928] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4249.401928] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000005f060a
[ 4249.401928] Stack:
[ 4249.401928]  ffff88006af473e8 ffffffff9b26f1dc ffffffff9b26f1b0 ffff88006af476e0
[ 4249.401928]  ffff8800533e2b80 ffff8800533e2b80 0000000c59a2c000 ffffed000d5e8edc
[ 4249.401928]  1ffff1000d5e8e85 ffff88006af476c8 0000000000000000 00000000000305e5
[ 4249.401928] Call Trace:
[ 4249.401928] compact_zone (mm/compaction.c:1113 mm/compaction.c:1347)
[ 4249.401928] compact_zone_order (mm/compaction.c:1466)
[ 4249.401928] try_to_compact_pages (mm/compaction.c:1526)
[ 4249.401928] __alloc_pages_direct_compact (mm/page_alloc.c:2452)
[ 4249.401928] __alloc_pages_nodemask (mm/page_alloc.c:2756 mm/page_alloc.c:2908)
[ 4249.401928] alloc_pages_vma (mm/mempolicy.c:1991)
[ 4249.401928] do_huge_pmd_anonymous_page (mm/huge_memory.c:831)
[ 4249.401928] handle_mm_fault (mm/memory.c:3332 mm/memory.c:3415)
[ 4249.401928] __do_page_fault (arch/x86/mm/fault.c:1235)
[ 4249.401928] trace_do_page_fault (arch/x86/mm/fault.c:1327 include/linux/jump_label.h:125 include/linux/context_tracking_state.h:28 include/linux/context_tracking.h:48 arch/x86/mm/fault.c:1328)
[ 4249.401928] do_async_page_fault (arch/x86/kernel/kvm.c:280)
[ 4249.401928] async_page_fault (arch/x86/kernel/entry_64.S:1257)
[ 4249.401928] Code: fe ff 4c 8b 9d c0 fe ff ff 4c 8b 85 c8 fe ff ff e9 bb fb ff ff 0f 1f 80 00 00 00 00 48 c7 c6 c0 31 10 a5 4c 89 c7 e8 b9 eb 00 00 <0f> 0b 0f 1f 80 00 00 00 00 e8 56 4f 90 01 48 8b b5 f0 fe ff ff
All code
========
   0:	fe                   	(bad)
   1:	ff 4c 8b 9d          	decl   -0x63(%rbx,%rcx,4)
   5:	c0 fe ff             	sar    $0xff,%dh
   8:	ff 4c 8b 85          	decl   -0x7b(%rbx,%rcx,4)
   c:	c8 fe ff ff          	enterq $0xfffe,$0xff
  10:	e9 bb fb ff ff       	jmpq   0xfffffffffffffbd0
  15:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  1c:	48 c7 c6 c0 31 10 a5 	mov    $0xffffffffa51031c0,%rsi
  23:	4c 89 c7             	mov    %r8,%rdi
  26:	e8 b9 eb 00 00       	callq  0xebe4
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  34:	e8 56 4f 90 01       	callq  0x1904f8f
  39:	48 8b b5 f0 fe ff ff 	mov    -0x110(%rbp),%rsi
	...

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   9:	e8 56 4f 90 01       	callq  0x1904f64
   e:	48 8b b5 f0 fe ff ff 	mov    -0x110(%rbp),%rsi
	...
[ 4249.401928] RIP isolate_migratepages_block (include/linux/page-flags.h:575 include/linux/huge_mm.h:156 include/linux/mm_inline.h:37 mm/compaction.c:784)
[ 4249.401928]  RSP <ffff88006af47398>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
