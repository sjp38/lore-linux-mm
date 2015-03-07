Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3546B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 13:38:18 -0500 (EST)
Received: by yhoa41 with SMTP id a41so32409052yho.9
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 10:38:18 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l145si8078466yke.132.2015.03.07.10.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Mar 2015 10:38:17 -0800 (PST)
Message-ID: <54FB4590.20102@oracle.com>
Date: Sat, 07 Mar 2015 13:38:08 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: hangs in free_pages_prepare
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm >> Andrew Morton" <akpm@linux-foundation.org>

Hi all,

I've disabled preemption on my fuzzing setup, and am hitting lots of the following, which
go back all the way to <3.18:

[ 1573.730097] NMI watchdog: BUG: soft lockup - CPU#12 stuck for 22s! [trinity-c42:27057]
[ 1573.730097] Modules linked in:
[ 1573.730097] irq event stamp: 13148952
[ 1573.730097] hardirqs last enabled at (13148951): free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
[ 1573.730097] hardirqs last disabled at (13148952): apic_timer_interrupt (arch/x86/kernel/entry_64.S:961)
[ 1573.730097] softirqs last enabled at (13142584): __do_softirq (./arch/x86/include/asm/preempt.h:22 kernel/softirq.c:300)
[ 1573.730097] softirqs last disabled at (13142579): irq_exit (kernel/softirq.c:350 kernel/softirq.c:391)
[ 1573.730097] CPU: 12 PID: 27057 Comm: trinity-c42 Not tainted 4.0.0-rc2-next-20150306-sasha-00035-g8286417 #2008
[ 1573.730097] task: ffff8803cff28000 ti: ffff8803cf378000 task.ti: ffff8803cf378000
[ 1573.730097] RIP: __memset (arch/x86/lib/memset_64.S:84)
[ 1573.730097] RSP: 0018:ffff8803cf37fcc0  EFLAGS: 00000202
[ 1573.730097] RAX: ffffffffffffffff RBX: ffff880583325000 RCX: 0000000000000001
[ 1573.730097] RDX: 0000000000000200 RSI: 00000000000000ff RDI: ffffed00b0664dc0
[ 1573.730097] RBP: ffff8803cf37fcc8 R08: 1ffff100b0664c00 R09: 0000000000000000
[ 1573.730097] R10: ffffed00b0664c00 R11: 0000000000000000 R12: ffffffffa6504c34
[ 1573.730097] R13: 0000000041b58ab3 R14: ffffffffaa31a488 R15: ffffffffaa31a480
[ 1573.730097] FS:  00007f071dd34700(0000) GS:ffff88024f200000(0000) knlGS:0000000000000000
[ 1573.730097] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1573.730097] CR2: 0000000000000000 CR3: 00000003e4736000 CR4: 00000000000007a0
[ 1573.730097] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1573.730097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1573.730097] Stack:
[ 1573.730097]  ffffffff997679b9 ffff8803cf37fd48 ffffffff9966b3ea 000000000000026a
[ 1573.730097]  0000000000000000 ffffea00160c9a30 ffffffff99672eb8 ffff8803cff28000
[ 1573.730097]  ffff88024f22ddb8 ffffea00160cc960 ffffffffa8c3ba90 ffff8803cf37fd38
[ 1573.730097] Call Trace:
[ 1573.730097] ? kasan_free_pages (mm/kasan/kasan.c:301)
[ 1573.788680] free_pages_prepare (mm/page_alloc.c:791)
[ 1573.788680] ? free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
[ 1573.788680] free_hot_cold_page (mm/page_alloc.c:1543)
[ 1573.788680] __free_pages (mm/page_alloc.c:2957)
[ 1573.788680] ? __vunmap (mm/vmalloc.c:1460 (discriminator 2))
[ 1573.788680] __vunmap (mm/vmalloc.c:1460 (discriminator 2))
[ 1573.788680] vfree (mm/vmalloc.c:1505)
[ 1573.788680] SyS_init_module (kernel/module.c:2503 kernel/module.c:3385)
[ 1573.788680] ? load_module (kernel/module.c:3385)
[ 1573.788680] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1604)
[ 1573.788680] ia32_do_call (arch/x86/ia32/ia32entry.S:446)
[ 1573.788680] Code: b6 ce 48 b8 01 01 01 01 01 01 01 01 48 0f af c1 41 89 f9 41 83 e1 07 75 70 48 89 d1 48 c1 e9 06 74 39 66 0f 1f 84 00 00 00 00 00 <48> ff c9 48 89 07 48 89 47 08 48 89 47 10 48 89 47 18 48 89 47
All code
========
   0:	b6 ce                	mov    $0xce,%dh
   2:	48 b8 01 01 01 01 01 	movabs $0x101010101010101,%rax
   9:	01 01 01
   c:	48 0f af c1          	imul   %rcx,%rax
  10:	41 89 f9             	mov    %edi,%r9d
  13:	41 83 e1 07          	and    $0x7,%r9d
  17:	75 70                	jne    0x89
  19:	48 89 d1             	mov    %rdx,%rcx
  1c:	48 c1 e9 06          	shr    $0x6,%rcx
  20:	74 39                	je     0x5b
  22:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  29:	00 00
  2b:*	48 ff c9             	dec    %rcx		<-- trapping instruction
  2e:	48 89 07             	mov    %rax,(%rdi)
  31:	48 89 47 08          	mov    %rax,0x8(%rdi)
  35:	48 89 47 10          	mov    %rax,0x10(%rdi)
  39:	48 89 47 18          	mov    %rax,0x18(%rdi)
  3d:	48 89 47 00          	mov    %rax,0x0(%rdi)

Code starting with the faulting instruction
===========================================
   0:	48 ff c9             	dec    %rcx
   3:	48 89 07             	mov    %rax,(%rdi)
   6:	48 89 47 08          	mov    %rax,0x8(%rdi)
   a:	48 89 47 10          	mov    %rax,0x10(%rdi)
   e:	48 89 47 18          	mov    %rax,0x18(%rdi)
  12:	48 89 47 00          	mov    %rax,0x0(%rdi)

And from a different run:

[ 1369.560070] NMI watchdog: BUG: soft lockup - CPU#16 stuck for 22s! [trinity-c16:27469]
[ 1369.560070] Modules linked in:
[ 1369.560070] irq event stamp: 8701850
[ 1369.560070] hardirqs last enabled at (8701849): _raw_spin_unlock_irqrestore (./arch/x86/include/asm/paravirt.h:809 include/linux/spinlock_api_smp.h:162 kernel/locking/spinlock.c:191)
[ 1369.560070] hardirqs last disabled at (8701850): apic_timer_interrupt (arch/x86/kernel/entry_64.S:961)
[ 1369.560070] softirqs last enabled at (8693324): __do_softirq (./arch/x86/include/asm/preempt.h:22 kernel/softirq.c:300)
[ 1369.560070] softirqs last disabled at (8693321): irq_exit (kernel/softirq.c:350 kernel/softirq.c:391)
[ 1369.560070] CPU: 16 PID: 27469 Comm: trinity-c16 Not tainted 4.0.0-rc2-next-20150306-sasha-00035-g8286417 #2008
[ 1369.560070] task: ffff8804a3293000 ti: ffff8804b9538000 task.ti: ffff8804b9538000
[ 1369.560070] RIP: _raw_spin_unlock_irqrestore (./arch/x86/include/asm/paravirt.h:809 include/linux/spinlock_api_smp.h:162 kernel/locking/spinlock.c:191)
[ 1369.560070] RSP: 0000:ffff8804b953fba8  EFLAGS: 00000286
[ 1369.560070] RAX: dffffc0000000000 RBX: ffffffff9c0b5c39 RCX: ffff8804a3293000
[ 1369.560070] RDX: 1ffffffff4f155c9 RSI: 0000000000000001 RDI: 0000000000000286
[ 1369.560070] RBP: ffff8804b953fbb8 R08: 0000000000000000 R09: 0000000000000000
[ 1369.560070] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000086
[ 1369.560070] R13: ffff8804b953fb88 R14: 0000000000000000 R15: 0000000000000001
[ 1369.560070] FS:  00007f1d92980700(0000) GS:ffff8802f7200000(0000) knlGS:0000000000000000
[ 1369.560070] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1369.560070] CR2: 0000000000000000 CR3: 00000004b3430000 CR4: 00000000000007a0
[ 1369.560070] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1369.560070] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1369.560070] Stack:
[ 1369.560070]  dffffc0000000000 ffff880631538000 ffff8804b953fcb8 ffffffff9c0b5d94
[ 1369.560070]  ffffffffa7935440 ffffffffa8533040 ffff8804b953fc38 1ffff100972a7f85
[ 1369.560070]  0000000000000000 ffff8804a3293cd8 0000000000000001 ffff880631539000
[ 1369.560070] Call Trace:
[ 1369.560070] __debug_check_no_obj_freed (lib/debugobjects.c:713)
[ 1369.560070] ? __debug_object_init (lib/debugobjects.c:667)
[ 1369.560070] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2554 kernel/locking/lockdep.c:2601)
[ 1369.560070] debug_check_no_obj_freed (lib/debugobjects.c:727)
[ 1369.560070] free_pages_prepare (mm/page_alloc.c:816)
[ 1369.560070] ? free_hot_cold_page (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) mm/page_alloc.c:1579 (discriminator 2))
[ 1369.560070] free_hot_cold_page (mm/page_alloc.c:1543)
[ 1369.560070] __free_pages (mm/page_alloc.c:2957)
[ 1369.560070] ? __vunmap (mm/vmalloc.c:1460 (discriminator 2))
[ 1369.560070] __vunmap (mm/vmalloc.c:1460 (discriminator 2))
[ 1369.560070] vfree (mm/vmalloc.c:1505)
[ 1369.560070] SyS_init_module (kernel/module.c:2503 kernel/module.c:3385)
[ 1369.560070] ? load_module (kernel/module.c:3385)
[ 1369.560070] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1604)
[ 1369.560070] ia32_do_call (arch/x86/ia32/ia32entry.S:446)
[ 1369.560070] Code: c7 48 ae 8a a7 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 80 3c 02 00 75 6d 48 83 3d dc 5e c9 02 00 74 5a 48 89 df 57 9d <66> 66 90 66 90 65 ff 0d 59 fb 3f 5b 5b 41 5c 5d c3 0f 1f 40 00
All code
========
   0:	c7                   	(bad)
   1:	48 ae                	rex.W scas %es:(%rdi),%al
   3:	8a a7 48 b8 00 00    	mov    0xb848(%rdi),%ah
   9:	00 00                	add    %al,(%rax)
   b:	00 fc                	add    %bh,%ah
   d:	ff df                	lcallq *<internal disassembler error>
   f:	48 89 fa             	mov    %rdi,%rdx
  12:	48 c1 ea 03          	shr    $0x3,%rdx
  16:	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)
  1a:	75 6d                	jne    0x89
  1c:	48 83 3d dc 5e c9 02 	cmpq   $0x0,0x2c95edc(%rip)        # 0x2c95f00
  23:	00
  24:	74 5a                	je     0x80
  26:	48 89 df             	mov    %rbx,%rdi
  29:	57                   	push   %rdi
  2a:	9d                   	popfq
  2b:*	66 66 90             	data32 xchg %ax,%ax		<-- trapping instruction
  2e:	66 90                	xchg   %ax,%ax
  30:	65 ff 0d 59 fb 3f 5b 	decl   %gs:0x5b3ffb59(%rip)        # 0x5b3ffb90
  37:	5b                   	pop    %rbx
  38:	41 5c                	pop    %r12
  3a:	5d                   	pop    %rbp
  3b:	c3                   	retq
  3c:	0f 1f 40 00          	nopl   0x0(%rax)
	...

Code starting with the faulting instruction
===========================================
   0:	66 66 90             	data32 xchg %ax,%ax
   3:	66 90                	xchg   %ax,%ax
   5:	65 ff 0d 59 fb 3f 5b 	decl   %gs:0x5b3ffb59(%rip)        # 0x5b3ffb65
   c:	5b                   	pop    %rbx
   d:	41 5c                	pop    %r12
   f:	5d                   	pop    %rbp
  10:	c3                   	retq
  11:	0f 1f 40 00          	nopl   0x0(%rax)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
