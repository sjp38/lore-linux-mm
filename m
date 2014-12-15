Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 063E46B0073
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:27:27 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so5139496yha.40
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 06:27:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n66si4151965yhd.23.2014.12.15.06.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 06:27:25 -0800 (PST)
Message-ID: <548EEFC5.2090002@oracle.com>
Date: Mon, 15 Dec 2014 09:27:17 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: BUG in release_pages
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[  263.650215] page:ffffea0002fde3c0 count:0 mapcount:0 mapping:ffff880057633a31 index:0x803
[  263.651812] flags: 0x5fffff80080028(uptodate|lru|swapbacked)
[  263.653045] page dumped because: VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0)
[  263.654398] ------------[ cut here ]------------
[  263.655241] kernel BUG at include/linux/mm.h:340!
[  263.656067] invalid opcode: 0000 [#1] SMP KASAN
[  263.656969] Dumping ftrace buffer:
[  263.657562]    (ftrace buffer empty)
[  263.658154] Modules linked in:
[  263.658693] CPU: 23 PID: 8919 Comm: trinity-c23 Not tainted 3.18.0-next-20141211-sasha-00050-g421f72c-dirty #1604
[  263.660068] task: ffff880473cb6000 ti: ffff880473d50000 task.ti: ffff880473d50000
[  263.660068] RIP: release_pages (include/linux/mm.h:340 mm/swap.c:930)
[  263.660068] RSP: 0000:ffff880473d53ad8  EFLAGS: 00010282
[  263.660068] RAX: dfffe90000000000 RBX: ffffea0002fde3c0 RCX: 0000000000000044
[  263.660068] RDX: 1ffffd40005fbc7f RSI: 0000000000000282 RDI: ffffea0002fde3f8
[  263.660068] RBP: ffff880473d53b58 R08: 0000000000000000 R09: 0000000000000000
[  263.660068] R10: 3a65737561636562 R11: 206465706d756420 R12: dfffe90000000000
[  263.660068] R13: 0000000002fde080 R14: ffffea0002fde3dc R15: 0000000000000000
[  263.660068] FS:  00007fab435de700(0000) GS:ffff880910c00000(0000) knlGS:0000000000000000
[  263.660068] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  263.660068] CR2: 00000000011d4ff8 CR3: 0000000473cd6000 CR4: 00000000000006a0
[  263.660068] Stack:
[  263.660068]  ffffea0002fde080 0000000000000000 0000000000000000 0000000000000001
[  263.660068]  ffff880473d53b58 ffffffffa18a511d 0000000e00000000 ffff880910c104d0
[  263.660068]  ffff880473d53b18 ffff880473d53b18 1ffff1008e7aa002 000000000000000e
[  263.660068] Call Trace:
[  263.660068] ? __pagevec_lru_add_fn (mm/swap.c:489 mm/swap.c:1034)
[  263.660068] pagevec_lru_move_fn (include/linux/pagevec.h:44 mm/swap.c:436)
[  263.660068] ? __put_single_page (mm/swap.c:1025)
[  263.660068] __lru_cache_add (include/linux/pagevec.h:62 mm/swap.c:628)
[  263.660068] lru_cache_add (mm/swap.c:665)
[  263.660068] lru_cache_add_active_or_unevictable (mm/swap.c:723)
[  263.660068] do_wp_page (include/linux/mmu_notifier.h:190 include/linux/mmu_notifier.h:245 mm/memory.c:2233)
[  263.660068] ? group_sched_in (kernel/events/core.c:1832)
[  263.660068] handle_mm_fault (mm/memory.c:3236 mm/memory.c:3341 mm/memory.c:3370)
[  263.660068] ? find_vma (mm/mmap.c:2042)
[  263.660068] __do_page_fault (arch/x86/mm/fault.c:1246)
[  263.660068] ? account_user_time (kernel/sched/cputime.c:152)
[  263.660068] ? get_vtime_delta (kernel/sched/cputime.c:652 kernel/sched/cputime.c:660)
[  263.660068] ? vtime_account_user (kernel/sched/cputime.c:701)
[  263.660068] trace_do_page_fault (arch/x86/mm/fault.c:1329 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1330)
[  263.660068] ? trace_hardirqs_off_thunk (arch/x86/lib/thunk_64.S:34)
[  263.660068] do_async_page_fault (arch/x86/kernel/kvm.c:280)
[  263.660068] async_page_fault (arch/x86/kernel/entry_64.S:1320)
[  263.660068] Code: 00 20 00 00 e8 cb 6e ac 0f 48 89 df e8 73 d9 ff ff 31 c0 e9 7a fc ff ff 0f 1f 40 00 48 c7 c6 e8 44 4a b2 48 89 df e8 b9 76 07 00 <0f> 0b 0f 1f 80 00 00 00 00 0f ba 33 14 41 b9 04 00 00 00 e9 96
All code
========
   0:	00 20                	add    %ah,(%rax)
   2:	00 00                	add    %al,(%rax)
   4:	e8 cb 6e ac 0f       	callq  0xfac6ed4
   9:	48 89 df             	mov    %rbx,%rdi
   c:	e8 73 d9 ff ff       	callq  0xffffffffffffd984
  11:	31 c0                	xor    %eax,%eax
  13:	e9 7a fc ff ff       	jmpq   0xfffffffffffffc92
  18:	0f 1f 40 00          	nopl   0x0(%rax)
  1c:	48 c7 c6 e8 44 4a b2 	mov    $0xffffffffb24a44e8,%rsi
  23:	48 89 df             	mov    %rbx,%rdi
  26:	e8 b9 76 07 00       	callq  0x776e4
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  34:	0f ba 33 14          	btrl   $0x14,(%rbx)
  38:	41 b9 04 00 00 00    	mov    $0x4,%r9d
  3e:	e9                   	.byte 0xe9
  3f:	96                   	xchg   %eax,%esi
	...

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   9:	0f ba 33 14          	btrl   $0x14,(%rbx)
   d:	41 b9 04 00 00 00    	mov    $0x4,%r9d
  13:	e9                   	.byte 0xe9
  14:	96                   	xchg   %eax,%esi
	...
[  263.660068] RIP release_pages (include/linux/mm.h:340 mm/swap.c:930)
[  263.660068]  RSP <ffff880473d53ad8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
