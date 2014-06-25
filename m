Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0036B0036
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 12:51:15 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id v10so1730074qac.41
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 09:51:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y19si5477607qae.27.2014.06.25.09.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 09:51:14 -0700 (PDT)
Message-ID: <53AAFDF7.2010607@oracle.com>
Date: Wed, 25 Jun 2014 12:51:03 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: slub: invalid memory access in setup_object
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[  791.659908] BUG: unable to handle kernel paging request at ffff880302e12000
[  791.661580] IP: memset (arch/x86/lib/memset_64.S:83)
[  791.661580] PGD 17b7d067 PUD 704947067 PMD 70492f067 PTE 8000000302e12060
[  791.661580] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  791.661580] Dumping ftrace buffer:
[  791.661580]    (ftrace buffer empty)
[  791.667964] Modules linked in:
[  791.667964] CPU: 13 PID: 10630 Comm: trinity-c20 Not tainted 3.16.0-rc2-next-20140624-sasha-00024-g332b58d #726
[  791.669480] task: ffff8803d5123000 ti: ffff8803ba460000 task.ti: ffff8803ba460000
[  791.669480] RIP: memset (arch/x86/lib/memset_64.S:83)
[  791.669480] RSP: 0018:ffff8803ba463b18  EFLAGS: 00010003
[  791.669480] RAX: 6b6b6b6b6b6b6b6b RBX: ffff880036851540 RCX: 0000000000000068
[  791.669480] RDX: 0000000000002a77 RSI: 000000000000006b RDI: ffff880302e12000
[  791.669480] RBP: ffff8803ba463b40 R08: 0000000000000001 R09: 0000000000000000
[  791.669480] R10: ffff880302e11000 R11: ffffffffffffffd8 R12: ffff880302e11000
[  791.669480] R13: 00000000000000bb R14: ffff880302e11000 R15: ffffffffffffffff
[  791.669480] FS:  00007f37693b3700(0000) GS:ffff880334e00000(0000) knlGS:0000000000000000
[  791.669480] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  791.669480] CR2: ffff880302e12000 CR3: 00000003b744f000 CR4: 00000000000006a0
[  791.669480] Stack:
[  791.669480]  ffffffff902f4273 ffff8803ba463b30 ffff880036851540 ffff880302e11000
[  791.669480]  ffffea000c0b8440 ffff8803ba463b60 ffffffff902f48b0 ffff880036851540
[  791.669480]  ffff880302e11000 ffff8803ba463bc0 ffffffff902f6886 00000000000000d0
[  791.669480] Call Trace:
[  791.669480] ? init_object (mm/slub.c:665)
[  791.669480] setup_object.isra.34 (mm/slub.c:1008 mm/slub.c:1373)
[  791.669480] new_slab (mm/slub.c:278 mm/slub.c:1412)
[  791.669480] __slab_alloc (mm/slub.c:2186 mm/slub.c:2344)
[  791.690803] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  791.690803] ? copy_process (kernel/fork.c:306 kernel/fork.c:1193)
[  791.690803] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  791.690803] ? get_parent_ip (kernel/sched/core.c:2550)
[  791.690803] kmem_cache_alloc_node (mm/slub.c:2417 mm/slub.c:2486)
[  791.690803] ? sched_clock_cpu (kernel/sched/clock.c:311)
[  791.690803] ? copy_process (kernel/fork.c:306 kernel/fork.c:1193)
[  791.690803] copy_process (kernel/fork.c:306 kernel/fork.c:1193)
[  791.690803] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  791.690803] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  791.690803] ? sched_clock_local (kernel/sched/clock.c:214)
[  791.690803] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  791.690803] do_fork (kernel/fork.c:1609)
[  791.690803] ? get_parent_ip (kernel/sched/core.c:2550)
[  791.690803] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  791.690803] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  791.690803] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[  791.690803] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  791.690803] SyS_clone (kernel/fork.c:1695)
[  791.690803] stub_clone (arch/x86/kernel/entry_64.S:637)
[  791.690803] ? tracesys (arch/x86/kernel/entry_64.S:542)
[ 791.690803] Code: b8 01 01 01 01 01 01 01 01 48 0f af c1 41 89 f9 41 83 e1 07 75 70 48 89 d1 48 c1 e9 06 74 39 66 0f 1f 84 00 00 00 00 00 48 ff c9 <48> 89 07 48 89 47 08 48 89 47 10 48 89 47 18 48 89 47 20 48 89
All code
========
   0:	b8 01 01 01 01       	mov    $0x1010101,%eax
   5:	01 01                	add    %eax,(%rcx)
   7:	01 01                	add    %eax,(%rcx)
   9:	48 0f af c1          	imul   %rcx,%rax
   d:	41 89 f9             	mov    %edi,%r9d
  10:	41 83 e1 07          	and    $0x7,%r9d
  14:	75 70                	jne    0x86
  16:	48 89 d1             	mov    %rdx,%rcx
  19:	48 c1 e9 06          	shr    $0x6,%rcx
  1d:	74 39                	je     0x58
  1f:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  26:	00 00
  28:	48 ff c9             	dec    %rcx
  2b:*	48 89 07             	mov    %rax,(%rdi)		<-- trapping instruction
  2e:	48 89 47 08          	mov    %rax,0x8(%rdi)
  32:	48 89 47 10          	mov    %rax,0x10(%rdi)
  36:	48 89 47 18          	mov    %rax,0x18(%rdi)
  3a:	48 89 47 20          	mov    %rax,0x20(%rdi)
  3e:	48 89 00             	mov    %rax,(%rax)

Code starting with the faulting instruction
===========================================
   0:	48 89 07             	mov    %rax,(%rdi)
   3:	48 89 47 08          	mov    %rax,0x8(%rdi)
   7:	48 89 47 10          	mov    %rax,0x10(%rdi)
   b:	48 89 47 18          	mov    %rax,0x18(%rdi)
   f:	48 89 47 20          	mov    %rax,0x20(%rdi)
  13:	48 89 00             	mov    %rax,(%rax)
[  791.690803] RIP memset (arch/x86/lib/memset_64.S:83)
[  791.690803]  RSP <ffff8803ba463b18>
[  791.690803] CR2: ffff880302e12000

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
