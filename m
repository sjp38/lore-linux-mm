Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id BF88E6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:19:21 -0500 (EST)
Received: by obbww6 with SMTP id ww6so69956047obb.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 12:19:21 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t73si7156453oif.8.2015.11.19.12.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 12:19:21 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: bad page flags in free_pages_prepare
Message-ID: <564E2EC5.3060006@oracle.com>
Date: Thu, 19 Nov 2015 15:19:17 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[ 9037.524924] BUG: Bad page state in process trinity-c2179  pfn:197750f
[ 9037.529243] page:ffffea0065dd43c0 count:0 mapcount:1 mapping:          (null) index:0x2f0f
[ 9037.530154] flags: 0x4afffff80040018(uptodate|dirty|swapbacked)
[ 9037.530834] page dumped because: nonzero mapcount
[ 9037.531404] Modules linked in:
[ 9037.531778] CPU: 18 PID: 15342 Comm: trinity-c2179 Not tainted 4.4.0-rc1-next-20151118-sasha-00042-g1ccc6e8 #2642
[ 9037.532856]  0000000000000012 00000000ac7ad40b ffff880fcc7e7ab0 ffffffff96e4ca9b
[ 9037.533928]  ffffea0065dd43c0 1ffffffff4305048 ffffffff9ed37240 ffff880fcc7e7ae0
[ 9037.534803]  ffffffff9569db5b 04afffff80040018 ffffea0065dd43e0 ffffea0065dd43c0
[ 9037.535760] Call Trace:
[ 9037.537046] dump_stack (lib/dump_stack.c:52)
[ 9037.538995] bad_page (include/linux/compiler.h:246 ./arch/x86/include/asm/atomic.h:39 include/linux/mm.h:418 mm/page_alloc.c:443)
[ 9037.539580] free_pages_prepare (mm/page_alloc.c:994)
[ 9037.540370] free_hot_cold_page (mm/page_alloc.c:2058)
[ 9037.541742] __put_page (mm/swap.c:73 mm/swap.c:97)
[ 9037.542408] do_wp_page (include/linux/mm.h:479 mm/memory.c:2323)
[ 9037.545165] handle_mm_fault (mm/memory.c:3312 mm/memory.c:3406 mm/memory.c:3435)
[ 9037.549248] __do_page_fault (arch/x86/mm/fault.c:1239)
[ 9037.550326] trace_do_page_fault (arch/x86/mm/fault.c:1331 include/linux/jump_label.h:133 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:50 arch/x86/mm/fault.c:1332)
[ 9037.550954] do_async_page_fault (arch/x86/kernel/kvm.c:265)
[ 9037.552334] async_page_fault (arch/x86/entry/entry_64.S:980)
[ 9037.553252] Disabling lock debugging due to kernel taint
[ 9037.553830] page:ffffea0065dd43c0 count:0 mapcount:0 mapping:          (null) index:0x2f0f
[ 9037.554780] flags: 0x4afffff80040018(uptodate|dirty|swapbacked)
[ 9037.555669] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
[ 9037.556545] ------------[ cut here ]------------
[ 9037.557058] kernel BUG at mm/swapfile.c:929!
[ 9037.557319] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[ 9037.557319] Modules linked in:
[ 9037.557319] CPU: 18 PID: 15342 Comm: trinity-c2179 Tainted: G    B           4.4.0-rc1-next-20151118-sasha-00042-g1ccc6e8 #2642
[ 9037.557319] task: ffff880fcc7d8000 ti: ffff880fcc7e0000 task.ti: ffff880fcc7e0000
[ 9037.557319] RIP: reuse_swap_page (mm/swapfile.c:929 (discriminator 1))
[ 9037.557319] RSP: 0000:ffff880fcc7e7bb0  EFLAGS: 00010282
[ 9037.557319] RAX: ffff880fcc7d8000 RBX: ffffea0065dd43c0 RCX: 0000000000000000
[ 9037.557319] RDX: 0000000000000000 RSI: ffffffff9e99f229 RDI: ffffea0065dd43f8
[ 9037.557319] RBP: ffff880fcc7e7bd0 R08: 0000000000000001 R09: 0000000000000000
[ 9037.557319] R10: fffffbfff4857d8a R11: 702864656b636f4c R12: ffffea0065dd43e0
[ 9037.557319] R13: ffffea0065dd43c0 R14: ffffea0065dd43e0 R15: ffff880fd0e93000
[ 9037.557319] FS:  00007fa70dec1700(0000) GS:ffff8819b2600000(0000) knlGS:0000000000000000
[ 9037.557319] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 9037.557319] CR2: 00007fa7021ef000 CR3: 0000000fcec93000 CR4: 00000000000006a0
[ 9037.557319] Stack:
[ 9037.557319]  ffffea0065dd43c0 ffff88198247f830 ffffea0065dd43e0 ffffea0065dd43c0
[ 9037.557319]  ffff880fcc7e7cc8 ffffffff95720287 ffff880f00000002 0000000000000000
[ 9037.557319]  0000001956263067 ffff881956263f78 1ffff101f98fcf84 ffff880fcc400080
[ 9037.557319] Call Trace:
[ 9037.557319] do_wp_page (mm/memory.c:2325)
[ 9037.557319] handle_mm_fault (mm/memory.c:3312 mm/memory.c:3406 mm/memory.c:3435)
[ 9037.557319] __do_page_fault (arch/x86/mm/fault.c:1239)
[ 9037.557319] trace_do_page_fault (arch/x86/mm/fault.c:1331 include/linux/jump_label.h:133 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:50 arch/x86/mm/fault.c:1332)
[ 9037.557319] do_async_page_fault (arch/x86/kernel/kvm.c:265)
[ 9037.557319] async_page_fault (arch/x86/entry/entry_64.S:980)
[ 9037.557319] Code: 03 80 3c 02 00 74 08 4c 89 ef e8 eb 30 04 00 49 8b 45 00 a8 01 75 16 e8 2e 35 04 00 48 c7 c6 a0 ed d4 9e 48 89 df e8 ef 12 fb ff <0f> 0b e8 18 35 04 00 4c 89 e2 48 b8 00 00 00 00 00 fc ff df 48
All code
========
   0:	03 80 3c 02 00 74    	add    0x7400023c(%rax),%eax
   6:	08 4c 89 ef          	or     %cl,-0x11(%rcx,%rcx,4)
   a:	e8 eb 30 04 00       	callq  0x430fa
   f:	49 8b 45 00          	mov    0x0(%r13),%rax
  13:	a8 01                	test   $0x1,%al
  15:	75 16                	jne    0x2d
  17:	e8 2e 35 04 00       	callq  0x4354a
  1c:	48 c7 c6 a0 ed d4 9e 	mov    $0xffffffff9ed4eda0,%rsi
  23:	48 89 df             	mov    %rbx,%rdi
  26:	e8 ef 12 fb ff       	callq  0xfffffffffffb131a
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	e8 18 35 04 00       	callq  0x4354a
  32:	4c 89 e2             	mov    %r12,%rdx
  35:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
  3c:	fc ff df
  3f:	48                   	rex.W
	...

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	e8 18 35 04 00       	callq  0x4351f
   7:	4c 89 e2             	mov    %r12,%rdx
   a:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
  11:	fc ff df
  14:	48                   	rex.W
	...
[ 9037.557319] RIP reuse_swap_page (mm/swapfile.c:929 (discriminator 1))
[ 9037.557319]  RSP <ffff880fcc7e7bb0>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
