Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id F2D646B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 10:41:07 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so1206917igb.8
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 07:41:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ge5si4755680pbc.3.2014.09.05.07.41.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 07:41:06 -0700 (PDT)
Message-ID: <5409CAFD.90206@oracle.com>
Date: Fri, 05 Sep 2014 10:38:53 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: invalid memory deref in page_get_anon_vma
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[12191.987737] BUG: unable to handle kernel paging request at ffff88035615eca8
[12191.988865] IP: page_get_anon_vma (./arch/x86/include/asm/atomic.h:27 ./arch/x86/include/asm/atomic.h:197 include/linux/atomic.h:17 mm/rmap.c:417)
[12191.990071] PGD 2ed4b067 PUD 9753bd067 PMD 97530c067 PTE 800000035615e060
[12191.991578] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[12191.991578] Dumping ftrace buffer:
[12191.991578]    (ftrace buffer empty)
[12191.991578] Modules linked in:
[12191.991578] CPU: 5 PID: 3079 Comm: khugepaged Not tainted 3.17.0-rc3-next-20140903-sasha-00034-g33e7ae9 #1108
[12191.991578] task: ffff8802729f3000 ti: ffff880272b0c000 task.ti: ffff880272b0c000
[12191.991578] RIP: page_get_anon_vma (./arch/x86/include/asm/atomic.h:27 ./arch/x86/include/asm/atomic.h:197 include/linux/atomic.h:17 mm/rmap.c:417)
[12191.991578] RSP: 0018:ffff880272b0f7b8  EFLAGS: 00010246
[12191.991578] RAX: 0000000000000000 RBX: ffff88035615ec00 RCX: 0000000000000001
[12191.991578] RDX: ffff88035615ec01 RSI: ffffffffa72e2182 RDI: ffffffffa71ebfd4
[12191.991578] RBP: ffff880272b0f7d8 R08: 0000000000000001 R09: 0000000000000000
[12191.991578] R10: 0000000000000000 R11: 0000000000000000 R12: ffffea000a72aa40
[12191.991578] R13: ffff880272b0f8f8 R14: ffffea000a72aa40 R15: 000000000029cc00
[12191.991578] FS:  0000000000000000(0000) GS:ffff8804c9e00000(0000) knlGS:0000000000000000
[12192.020146] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[12192.020146] CR2: ffff88035615eca8 CR3: 000000002c032000 CR4: 00000000000006a0
[12192.020146] Stack:
[12192.020146]  ffffffffa72e2135 ffff880272b0f8f8 ffffea000a72aa60 ffffea000d2b7780
[12192.020146]  ffff880272b0f888 ffffffffa730d27a ffff880272b0f7f8 000000008b880a00
[12192.020146]  ffff8804c5e00340 ffff8802729f3000 0000000100000000 0000000000000000
[12192.020146] Call Trace:
[12192.020146] ? page_get_anon_vma (mm/rmap.c:405)
[12192.020146] migrate_pages (mm/migrate.c:853 mm/migrate.c:941 mm/migrate.c:1122)
[12192.020146] ? __reset_isolation_suitable (mm/compaction.c:947)
[12192.020146] ? isolate_freepages_block (mm/compaction.c:918)
[12192.020146] compact_zone (mm/compaction.c:1209)
[12192.020146] compact_zone_order (mm/compaction.c:1258)
[12192.020146] try_to_compact_pages (mm/compaction.c:1323)
[12192.020146] __alloc_pages_direct_compact (mm/page_alloc.c:2313)
[12192.020146] __alloc_pages_slowpath (mm/page_alloc.c:2760)
[12192.020146] __alloc_pages_nodemask (mm/page_alloc.c:2838)
[12192.020146] ? collapse_huge_page.isra.31 (mm/huge_memory.c:766 mm/huge_memory.c:2336 mm/huge_memory.c:2435)
[12192.020146] collapse_huge_page.isra.31 (mm/huge_memory.c:2336 mm/huge_memory.c:2435)
[12192.020146] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[12192.020146] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[12192.020146] ? khugepaged_scan_mm_slot (include/linux/spinlock.h:349 mm/huge_memory.c:2604 mm/huge_memory.c:2700)
[12192.020146] ? preempt_count_sub (kernel/sched/core.c:2626)
[12192.020146] khugepaged_scan_mm_slot (mm/huge_memory.c:2704)
[12192.020146] khugepaged (include/linux/spinlock.h:349 mm/huge_memory.c:2784 mm/huge_memory.c:2817)
[12192.020146] ? bit_waitqueue (kernel/sched/wait.c:291)
[12192.020146] ? khugepaged_scan_mm_slot (mm/huge_memory.c:2810)
[12192.020146] kthread (kernel/kthread.c:210)
[12192.020146] ? kthread_create_on_node (kernel/kthread.c:176)
[12192.020146] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[12192.020146] ? kthread_create_on_node (kernel/kthread.c:176)
[12192.020146] Code: ee ff 0f 1f 00 49 8b 54 24 08 48 89 d0 83 e0 03 48 83 f8 01 0f 85 cb 00 00 00 41 8b 44 24 18 85 c0 0f 88 be 00 00 00 48 8d 5a ff <8b> 8b a8 00 00 00 85 c9 0f 84 ac 00 00 00 8d 71 01 89 c8 48 8d
All code
========
   0:	ee                   	out    %al,(%dx)
   1:	ff 0f                	decl   (%rdi)
   3:	1f                   	(bad)
   4:	00 49 8b             	add    %cl,-0x75(%rcx)
   7:	54                   	push   %rsp
   8:	24 08                	and    $0x8,%al
   a:	48 89 d0             	mov    %rdx,%rax
   d:	83 e0 03             	and    $0x3,%eax
  10:	48 83 f8 01          	cmp    $0x1,%rax
  14:	0f 85 cb 00 00 00    	jne    0xe5
  1a:	41 8b 44 24 18       	mov    0x18(%r12),%eax
  1f:	85 c0                	test   %eax,%eax
  21:	0f 88 be 00 00 00    	js     0xe5
  27:	48 8d 5a ff          	lea    -0x1(%rdx),%rbx
  2b:*	8b 8b a8 00 00 00    	mov    0xa8(%rbx),%ecx		<-- trapping instruction
  31:	85 c9                	test   %ecx,%ecx
  33:	0f 84 ac 00 00 00    	je     0xe5
  39:	8d 71 01             	lea    0x1(%rcx),%esi
  3c:	89 c8                	mov    %ecx,%eax
  3e:	48 8d 00             	lea    (%rax),%rax

Code starting with the faulting instruction
===========================================
   0:	8b 8b a8 00 00 00    	mov    0xa8(%rbx),%ecx
   6:	85 c9                	test   %ecx,%ecx
   8:	0f 84 ac 00 00 00    	je     0xba
   e:	8d 71 01             	lea    0x1(%rcx),%esi
  11:	89 c8                	mov    %ecx,%eax
  13:	48 8d 00             	lea    (%rax),%rax
[12192.070370] RIP page_get_anon_vma (./arch/x86/include/asm/atomic.h:27 ./arch/x86/include/asm/atomic.h:197 include/linux/atomic.h:17 mm/rmap.c:417)
[12192.070370]  RSP <ffff880272b0f7b8>
[12192.070370] CR2: ffff88035615eca8


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
