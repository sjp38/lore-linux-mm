Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A49646B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 10:04:28 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so12051076pde.37
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 07:04:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id c8si31925603pat.177.2014.08.20.07.04.22
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 07:04:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <53F487EB.7070703@oracle.com>
References: <53F487EB.7070703@oracle.com>
Subject: RE: mm: kernel BUG at mm/rmap.c:530
Content-Transfer-Encoding: 7bit
Message-Id: <20140820140247.C729CE00A3@blue.fi.intel.com>
Date: Wed, 20 Aug 2014 17:02:47 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:
> 
> [ 2581.180086] kernel BUG at mm/rmap.c:530!

Page is mapped where it shouldn't be. Or vma/struct page/pgtable is corrupted.
Basically, I have no idea what happend :-P

We really should dump page and vma info there. It's strange we don't have
dump_vma() helper yet.

> [ 2581.180086] invalid opcode: 0000 [#1]
> [ 2581.180086] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2581.180086] Dumping ftrace buffer:
> [ 2581.180086]    (ftrace buffer empty)
> [ 2581.180086] Modules linked in:
> [ 2581.180086] CPU: 13 PID: 8515 Comm: trinity-main Not tainted 3.16.0-next-20140815-sasha-00034-g615561b #1071
> [ 2581.180086] task: ffff8804c1b30000 ti: ffff8804bd9e4000 task.ti: ffff8804bd9e4000
> [ 2581.180086] RIP: rmap_walk (mm/rmap.c:530 mm/rmap.c:1675 mm/rmap.c:1707)
> [ 2581.180086] RSP: 0018:ffff8804bd9e7bb8  EFLAGS: 00010206
> [ 2581.180086] RAX: 0000000000000000 RBX: ffffea000b39e3c0 RCX: ffff8803c501fb18
> [ 2581.180086] RDX: 00007fffffffd000 RSI: 00000007fffffffd RDI: ffffea000b39e3c0
> [ 2581.180086] RBP: ffff8804bd9e7bf0 R08: ffff880254972200 R09: 0000000000000000
> [ 2581.180086] R10: 0000000000000001 R11: 0000000000000008 R12: ffff8804bd9e7c00
> [ 2581.180086] R13: ffff8801e2d40ff0 R14: 00000007fffffffd R15: ffff880254972200
> [ 2581.180086] FS:  00007fb53e50d700(0000) GS:ffff8804ca200000(0000) knlGS:0000000000000000
> [ 2581.180086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2581.180086] CR2: 00000000025e5000 CR3: 00000004c19fa000 CR4: 00000000000006a0
> [ 2581.180086] Stack:
> [ 2581.180086]  ffff8804c125a400 ffff8804bd9e7bf8 ffffea000b39e3c0 ffffea0020b86cc0
> [ 2581.180086]  0000000000000001 0000000000000000 0000000000000000 ffff8804bd9e7c30
> [ 2581.180086]  ffffffffab30e7b1 ffffea0020b86cc0 ffffffffab30f050 0000000000000000
> [ 2581.180086] Call Trace:
> [ 2581.180086] remove_migration_ptes (mm/migrate.c:222)
> [ 2581.180086] ? __migration_entry_wait.isra.25 (mm/migrate.c:107)
> [ 2581.180086] ? remove_migration_pte (mm/migrate.c:193)
> [ 2581.180086] move_to_new_page (mm/migrate.c:785)
> [ 2581.180086] ? try_to_unmap (mm/rmap.c:1527)
> [ 2581.180086] ? try_to_unmap_nonlinear (mm/rmap.c:1124)
> [ 2581.180086] ? invalid_migration_vma (mm/rmap.c:1483)
> [ 2581.273353] ? page_remove_rmap (mm/rmap.c:1391)
> [ 2581.273353] migrate_pages (mm/migrate.c:916 mm/migrate.c:953 mm/migrate.c:1141)
> [ 2581.273353] ? buffer_migrate_lock_buffers (mm/migrate.c:1589)
> [ 2581.273353] migrate_misplaced_page (mm/migrate.c:1749)
> [ 2581.273353] handle_mm_fault (mm/memory.c:3175 mm/memory.c:3228 mm/memory.c:3341 mm/memory.c:3370)
> [ 2581.273353] ? __lock_is_held (kernel/locking/lockdep.c:3518)
> [ 2581.273353] __do_page_fault (arch/x86/mm/fault.c:1231)
> [ 2581.273353] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> [ 2581.273353] ? vtime_account_user (kernel/sched/cputime.c:687)
> [ 2581.273353] ? context_tracking_user_exit (kernel/context_tracking.c:184)
> [ 2581.273353] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 2581.273353] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2641 (discriminator 8))
> [ 2581.273353] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
> [ 2581.273353] do_async_page_fault (arch/x86/kernel/kvm.c:279)
> [ 2581.273353] async_page_fault (arch/x86/kernel/entry_64.S:1313)
> [ 2581.273353] Code: 17 02 00 00 49 8b 14 24 4c 89 ee 48 89 df ff d0 48 8b 7d c8 89 45 d0 e8 77 24 ee ff 8b 45 d0 e9 38 01 00 00 0f 1f 80 00 00 00 00 <0f> 0b 66 0f 1f 44 00 00 e8 3b ff 00 00 4c 8b 73 10 85 c0 0f 85
> All code
> ========
>    0:	17                   	(bad)
>    1:	02 00                	add    (%rax),%al
>    3:	00 49 8b             	add    %cl,-0x75(%rcx)
>    6:	14 24                	adc    $0x24,%al
>    8:	4c 89 ee             	mov    %r13,%rsi
>    b:	48 89 df             	mov    %rbx,%rdi
>    e:	ff d0                	callq  *%rax
>   10:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
>   14:	89 45 d0             	mov    %eax,-0x30(%rbp)
>   17:	e8 77 24 ee ff       	callq  0xffffffffffee2493
>   1c:	8b 45 d0             	mov    -0x30(%rbp),%eax
>   1f:	e9 38 01 00 00       	jmpq   0x15c
>   24:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
>   2b:*	0f 0b                	ud2    		<-- trapping instruction
>   2d:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
>   33:	e8 3b ff 00 00       	callq  0xff73
>   38:	4c 8b 73 10          	mov    0x10(%rbx),%r14
>   3c:	85 c0                	test   %eax,%eax
>   3e:	0f                   	.byte 0xf
>   3f:	85 00                	test   %eax,(%rax)
> 
> Code starting with the faulting instruction
> ===========================================
>    0:	0f 0b                	ud2
>    2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
>    8:	e8 3b ff 00 00       	callq  0xff48
>    d:	4c 8b 73 10          	mov    0x10(%rbx),%r14
>   11:	85 c0                	test   %eax,%eax
>   13:	0f                   	.byte 0xf
>   14:	85 00                	test   %eax,(%rax)
> [ 2581.273353] RIP rmap_walk (mm/rmap.c:530 mm/rmap.c:1675 mm/rmap.c:1707)
> [ 2581.273353]  RSP <ffff8804bd9e7bb8>
> 
> 
> Thanks,
> Sasha

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
