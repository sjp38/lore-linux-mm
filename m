Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1EB6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:56:31 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so9156700pdb.11
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:56:31 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id af10si16895052pbd.228.2014.06.30.17.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 17:56:30 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so9573829pab.32
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:56:30 -0700 (PDT)
Date: Mon, 30 Jun 2014 17:55:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: derefing NULL vma->vm_mm when unmapping
In-Reply-To: <20140630150728.c5f268a0092862f2a7d2b29c@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1406301729500.5074@eggly.anvils>
References: <53B16B05.20108@gmail.com> <20140630150728.c5f268a0092862f2a7d2b29c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 30 Jun 2014, Andrew Morton wrote:
> On Mon, 30 Jun 2014 09:49:57 -0400 Sasha Levin <levinsasha928@gmail.com> wrote:
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> > kernel I've stumbled on the following spew:
> > 
> > [  761.704089] BUG: unable to handle kernel NULL pointer dereference at           (null)
> > [  761.704089] IP: mm_find_pmd (mm/rmap.c:570)
> 
> Does this mean it oopsed in mm_find_pmd()'s call to pgd_offset()?
> 
> > [  761.704089] PGD 51223067 PUD 50a09067 PMD 0
> > [  761.704089] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [  761.704089] Dumping ftrace buffer:
> > [  761.704089]    (ftrace buffer empty)
> > [  761.704089] Modules linked in:
> > [  761.704089] CPU: 4 PID: 20723 Comm: trinity-c131 Tainted: G        W      3.16.0-rc3-next-20140630-sasha-00023-g44434d4-dirty #756
> > [  761.704089] task: ffff88004e3c0000 ti: ffff88004e0b8000 task.ti: ffff88004e0b8000
> > [  761.704089] RIP: mm_find_pmd (mm/rmap.c:570)
> > [  761.704089] RSP: 0000:ffff88004e0bbaa8  EFLAGS: 00010246
> > [  761.704089] RAX: 0000000000000000 RBX: 0000000000a65000 RCX: ffff88004e0bbb30
> > [  761.704089] RDX: 0000000000000000 RSI: 0000000000a65000 RDI: ffff880000146000
> > [  761.704089] RBP: ffff88004e0bbaa8 R08: 0000000000000000 R09: 0000000000000000
> > [  761.704089] R10: ffff88004e3c0000 R11: 0000000000000000 R12: ffffea000d766e00
> > [  761.704089] R13: ffff88004e0bbb30 R14: ffff880000146000 R15: 0000000000000000
> > [  761.704089] FS:  00007f0293c61700(0000) GS:ffff880144e00000(0000) knlGS:0000000000000000
> > [  761.704089] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  761.704089] CR2: 0000000000000000 CR3: 000000004e3be000 CR4: 00000000000006a0
> > [  761.704089] Stack:
> > [  761.704089]  ffff88004e0bbae8 ffffffff9c2d0815 800000035d9b8805 ffff880000146000
> > [  761.704089]  ffffea000d766e00 ffff88000b4c4e58 ffff880034d7d200 0000000000000302
> > [  761.704089]  ffff88004e0bbb68 ffffffff9c2d1491 ffff88004e0bbb28 ffffffff9f57c58a
> > [  761.704089] Call Trace:
> > [  761.704089] __page_check_address (mm/rmap.c:618)
> > [  761.704089] try_to_unmap_one (mm/rmap.c:1133)
> > [  761.704089] ? down_read (kernel/locking/rwsem.c:45 (discriminator 2))
> > [  761.704089] ? page_lock_anon_vma_read (./arch/x86/include/asm/atomic.h:118 mm/rmap.c:491)
> > [  761.704089] ? page_lock_anon_vma_read (mm/rmap.c:448)
> > [  761.704089] rmap_walk (mm/rmap.c:1634 mm/rmap.c:1705)
> > [  761.704089] try_to_unmap (mm/rmap.c:1527)
> > [  761.704089] ? page_remove_rmap (mm/rmap.c:1124)
> > [  761.704089] ? invalid_migration_vma (mm/rmap.c:1483)
> > [  761.704089] ? try_to_unmap_one (mm/rmap.c:1391)
> > [  761.704089] ? anon_vma_prepare (mm/rmap.c:448)
> > [  761.704089] ? invalid_mkclean_vma (mm/rmap.c:1478)
> > [  761.704089] ? page_get_anon_vma (mm/rmap.c:405)
> > [  761.704089] migrate_pages (mm/migrate.c:912 mm/migrate.c:955 mm/migrate.c:1142)
> > [  761.704089] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1590)
> > [  761.704089] migrate_misplaced_page (mm/migrate.c:1750)
> > [  761.704089] __handle_mm_fault (mm/memory.c:3162 mm/memory.c:3212 mm/memory.c:3322)
> > [  761.704089] handle_mm_fault (include/linux/memcontrol.h:124 mm/memory.c:3348)
> > [  761.704089] ? __do_page_fault (arch/x86/mm/fault.c:1163)
> > [  761.704089] __do_page_fault (arch/x86/mm/fault.c:1230)
> > [  761.704089] ? vtime_account_user (kernel/sched/cputime.c:687)
> > [  761.704089] ? get_parent_ip (kernel/sched/core.c:2550)
> > [  761.704089] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:115 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:180)
> > [  761.704089] ? preempt_count_sub (kernel/sched/core.c:2606)
> > [  761.704089] ? context_tracking_user_exit (kernel/context_tracking.c:184)
> > [  761.704089] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> > [  761.704089] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
> > [  761.704089] trace_do_page_fault (arch/x86/mm/fault.c:1313 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1314)
> > [  761.704089] do_async_page_fault (arch/x86/kernel/kvm.c:264)
> > [  761.704089] async_page_fault (arch/x86/kernel/entry_64.S:1322)
> > [ 761.704089] Code: 00 48 8b 5d f0 4c 8b 65 f8 c9 c3 66 0f 1f 44 00 00 66 66 66 66 90 55 48 89 f2 48 8b 47 40 48 c1 ea 27 48 89 e5 81 e2 ff 01 00 00 <48> 8b 3c d0 40 f6 c7 01 75 0c 31 f6 e9 af 00 00 00 0f 1f 44 00
> > All code
> > ========
> >    0:	00 48 8b             	add    %cl,-0x75(%rax)
> >    3:	5d                   	pop    %rbp
> >    4:	f0 4c 8b 65 f8       	lock mov -0x8(%rbp),%r12
> >    9:	c9                   	leaveq
> >    a:	c3                   	retq
> >    b:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
> >   11:	66 66 66 66 90       	data32 data32 data32 xchg %ax,%ax
> >   16:	55                   	push   %rbp
> >   17:	48 89 f2             	mov    %rsi,%rdx
> >   1a:	48 8b 47 40          	mov    0x40(%rdi),%rax
> 
> 0x40 is mm_struct.pgd
> 
> >   1e:	48 c1 ea 27          	shr    $0x27,%rdx
> >   22:	48 89 e5             	mov    %rsp,%rbp
> >   25:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
> >   2b:*	48 8b 3c d0          	mov    (%rax,%rdx,8),%rdi		<-- trapping instruction
> 
> So we seem to have mm->pgd == NULL?

Yes.

> 
> dump_pagetable() was able to locate the pgd OK when it printed "PGD
> 51223067 PUD 50a09067 PMD 0", but it plucks the pgd out of the physical
> pagetables, not out of the mm_struct.

Two different mms, I think.  dump_pagetable() is reporting on the
current mm which experienced the oops on NULL pointer.  Whereas the
mm->pgd which is NULL is for one of those mms which rmap_walk is visiting.

> 
> Dunno.  You're under KVM and tracing is enabled, yes?  I don't
> immediately see how that would affect it.

I am beginning to wonder whether some of Sasha's reports are
actually problems with KVM, which I cannot help with at all.
It does add another dimension of doubt.  Or with DEBUG_PAGEALLOC.

I took a quick look, but had no more ideas on this crash than many
other of his recent ones.  Or is there something very (but very
rarely) wrong with the rmap walk and its trees these days?

> 
> >   2f:	40 f6 c7 01          	test   $0x1,%dil
> >   33:	75 0c                	jne    0x41
> >   35:	31 f6                	xor    %esi,%esi
> >   37:	e9 af 00 00 00       	jmpq   0xeb
> >   3c:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
> > 
> > Code starting with the faulting instruction
> > ===========================================
> >    0:	48 8b 3c d0          	mov    (%rax,%rdx,8),%rdi
> >    4:	40 f6 c7 01          	test   $0x1,%dil
> >    8:	75 0c                	jne    0x16
> >    a:	31 f6                	xor    %esi,%esi
> >    c:	e9 af 00 00 00       	jmpq   0xc0
> >   11:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

Entirely off-topic: I love scripts/decodecode (thank you Andi!),
but has anyone ever seen any point at all to the "Code starting with
the faulting instruction" section, repeat of what's already shown?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
