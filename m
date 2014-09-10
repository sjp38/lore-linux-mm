Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 279CB6B003A
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:12:48 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id z6so4320673yhz.29
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 06:12:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e3si317900yhq.147.2014.09.10.06.12.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 06:12:47 -0700 (PDT)
Message-ID: <54104E24.5010402@oracle.com>
Date: Wed, 10 Sep 2014 09:12:04 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com> <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/09/2014 10:45 PM, Hugh Dickins wrote:
> Sasha, you say you're getting plenty of these now, but I've only seen
> the dump for one of them, on Aug26: please post a few more dumps, so
> that we can look for commonality.

I wasn't saving older logs for this issue so I only have 2 traces from
tonight. If that's not enough please let me know and I'll try to add
a few more.

[ 1125.600123] kernel BUG at include/asm-generic/pgtable.h:724!
[ 1125.600123] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1125.600123] Dumping ftrace buffer:
[ 1125.600123]    (ftrace buffer empty)
[ 1125.600123] Modules linked in:
[ 1125.600123] CPU: 16 PID: 11903 Comm: trinity-c517 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1135
[ 1125.600123] task: ffff880661730000 ti: ffff880582c20000 task.ti: ffff880582c20000
[ 1125.600123] RIP: 0010:[<ffffffffa32e500a>]  [<ffffffffa32e500a>] change_pte_range+0x4ea/0x4f0
[ 1125.600123] RSP: 0018:ffff880582c23d68  EFLAGS: 00010246
[ 1125.600123] RAX: 0000000936d9a900 RBX: 00007ffdb17c8000 RCX: 0000000000000100
[ 1125.600123] RDX: 0000000936d9a900 RSI: 00007ffdb17c8000 RDI: 0000000936d9a900
[ 1125.600123] RBP: ffff880582c23dc8 R08: ffff8802a8f2d400 R09: 0000000000b56000
[ 1125.600123] R10: 0000000000020201 R11: 0000000000000008 R12: ffff88004dd6ee40
[ 1125.600123] R13: 8000000000000025 R14: 00007ffdb1800000 R15: ffffc00000000fff
[ 1125.600123] FS:  00007ffdb6382700(0000) GS:ffff880278200000(0000) knlGS:0000000000000000
[ 1125.600123] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1125.600123] CR2: 00007ffdb617e60c CR3: 000000050ff12000 CR4: 00000000000006a0
[ 1125.600123] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1125.600123] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1125.600123] Stack:
[ 1125.600123]  0000000000000001 0000000936d9a900 0000000000000046 ffff8804bd549f40
[ 1125.600123]  000000001f989000 ffff8802a8f2d400 ffff88051f989000 00007f9f40604cfdb1ac8000
[ 1125.600123]  ffff88032fcc3c58 00007ffdb16df000 00007ffdb16df000 00007ffdb1800000
[ 1125.600123] Call Trace:
[ 1125.600123]  [<ffffffffa32e52c4>] change_protection+0x2b4/0x4e0
[ 1125.600123]  [<ffffffffa32fefdb>] change_prot_numa+0x1b/0x40
[ 1125.600123]  [<ffffffffa31add86>] task_numa_work+0x1f6/0x330
[ 1125.600123]  [<ffffffffa3193d84>] task_work_run+0xc4/0xf0
[ 1125.600123]  [<ffffffffa3071477>] do_notify_resume+0x97/0xb0
[ 1125.600123]  [<ffffffffa650daea>] int_signal+0x12/0x17
[ 1125.600123] Code: 66 90 48 8b 7d b8 e8 f6 75 22 03 48 8b 45 b0 e9 6f ff ff ff 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b <0f> 0b 0f 0b 0f 0b 66 66 66 66 90 55 48 89 e5 41 57 49 89 d7 41
[ 1125.600123] RIP  [<ffffffffa32e500a>] change_pte_range+0x4ea/0x4f0
[ 1125.600123]  RSP <ffff880582c23d68>

[ 3131.084176] kernel BUG at include/asm-generic/pgtable.h:724!
[ 3131.087358] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3131.090143] Dumping ftrace buffer:
[ 3131.090143]    (ftrace buffer empty)
[ 3131.090143] Modules linked in:
[ 3131.090143] CPU: 8 PID: 20595 Comm: trinity-c34 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1135
[ 3131.090143] task: ffff8801ded60000 ti: ffff8803204ec000 task.ti: ffff8803204ec000
[ 3131.090143] RIP: 0010:[<ffffffffa72e500a>]  [<ffffffffa72e500a>] change_pte_range+0x4ea/0x4f0
[ 3131.090143] RSP: 0000:ffff8803204efd68  EFLAGS: 00010246
[ 3131.090143] RAX: 0000000971bba900 RBX: 00007ffda1d4d000 RCX: 0000000000000100
[ 3131.090143] RDX: 0000000971bba900 RSI: 00007ffda1d4d000 RDI: 0000000971bba900
[ 3131.120281] RBP: ffff8803204efdc8 R08: ffff88026bed8800 R09: 0000000000b48000
[ 3131.120281] R10: 0000000000076501 R11: 0000000000000008 R12: ffff8801ca071a68
[ 3131.120281] R13: 8000000000000025 R14: 00007ffda1dbf000 R15: ffffc00000000fff
[ 3131.120281] FS:  00007ffda5cd4700(0000) GS:ffff880277e00000(0000) knlGS:0000000000000000
[ 3131.120281] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3131.120281] CR2: 00000000025d6000 CR3: 00000004bcde2000 CR4: 00000000000006a0
[ 3131.120281] Stack:
[ 3131.120281]  0000000000000001 0000000971bba900 000000000000005c ffff8800661a7b60
[ 3131.120281]  00000000f4953000 ffff88026bed8800 ffff8801f4953000 00007ffda1dbf000
[ 3131.120281]  ffff8802b3319870 00007ffda1c1b000 00007ffda1c1b000 00007ffda1dbf000
[ 3131.120281] Call Trace:
[ 3131.120281]  [<ffffffffa72e52c4>] change_protection+0x2b4/0x4e0
[ 3131.120281]  [<ffffffffa72fefdb>] change_prot_numa+0x1b/0x40
[ 3131.120281]  [<ffffffffa71add86>] task_numa_work+0x1f6/0x330
[ 3131.120281]  [<ffffffffa7193d84>] task_work_run+0xc4/0xf0
[ 3131.120281]  [<ffffffffa7071477>] do_notify_resume+0x97/0xb0
[ 3131.120281]  [<ffffffffaa50e6ae>] retint_signal+0x4d/0x9f
[ 3131.120281] Code: 66 90 48 8b 7d b8 e8 f6 75 22 03 48 8b 45 b0 e9 6f ff ff ff 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b <0f> 0b 0f 0b 0f 0b 66 66 66 66 90 55 48 89 e5 41 57 49 89 d7 41
[ 3131.120281] RIP  [<ffffffffa72e500a>] change_pte_range+0x4ea/0x4f0
[ 3131.120281]  RSP <ffff8803204efd68>

> And please attach a disassembly of change_protection_range() (noting
> which of the dumps it corresponds to, in case it has changed around):
> "Code" just shows a cluster of ud2s for the unlikely bugs at end of the
> function, we cannot tell at all what should be in the registers by then.

change_protection_range() got inlined into change_protection(), it applies to
both traces above:

00000000000004f0 <change_protection>:
 4f0:	e8 00 00 00 00       	callq  4f5 <change_protection+0x5>
			4f1: R_X86_64_PC32	__fentry__-0x4
 4f5:	55                   	push   %rbp
 4f6:	48 89 e5             	mov    %rsp,%rbp
 4f9:	41 57                	push   %r15
 4fb:	49 89 d7             	mov    %rdx,%r15
 4fe:	41 56                	push   %r14
 500:	41 55                	push   %r13
 502:	41 54                	push   %r12
 504:	53                   	push   %rbx
 505:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
 50c:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
 510:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
 514:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
 518:	44 89 45 98          	mov    %r8d,-0x68(%rbp)
 51c:	44 89 4d 9c          	mov    %r9d,-0x64(%rbp)
 520:	f6 47 52 40          	testb  $0x40,0x52(%rdi)
 524:	0f 85 96 03 00 00    	jne    8c0 <change_protection+0x3d0>
 52a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
 52e:	48 8b 40 40          	mov    0x40(%rax),%rax
 532:	48 89 45 80          	mov    %rax,-0x80(%rbp)
 536:	48 39 55 c0          	cmp    %rdx,-0x40(%rbp)
 53a:	0f 83 40 04 00 00    	jae    980 <change_protection+0x490>
 540:	4c 8b 5d c0          	mov    -0x40(%rbp),%r11
 544:	48 8b 4d 80          	mov    -0x80(%rbp),%rcx
 548:	4c 89 d8             	mov    %r11,%rax
 54b:	48 c1 e8 24          	shr    $0x24,%rax
 54f:	c6 81 dc 08 00 00 01 	movb   $0x1,0x8dc(%rcx)
 556:	25 f8 0f 00 00       	and    $0xff8,%eax
 55b:	48 03 41 40          	add    0x40(%rcx),%rax
 55f:	48 8d 52 ff          	lea    -0x1(%rdx),%rdx
 563:	4c 89 7d d0          	mov    %r15,-0x30(%rbp)
 567:	49 89 c7             	mov    %rax,%r15
 56a:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
 56e:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
 575:	00
 576:	48 b8 00 00 00 00 80 	movabs $0x8000000000,%rax
 57d:	00 00 00
 580:	49 8b 3f             	mov    (%r15),%rdi
 583:	49 bd 00 00 00 00 80 	movabs $0xffffff8000000000,%r13
 58a:	ff ff ff
 58d:	4c 01 d8             	add    %r11,%rax
 590:	49 21 c5             	and    %rax,%r13
 593:	49 8d 45 ff          	lea    -0x1(%r13),%rax
 597:	48 3b 45 b0          	cmp    -0x50(%rbp),%rax
 59b:	4c 0f 43 6d d0       	cmovae -0x30(%rbp),%r13
 5a0:	48 85 ff             	test   %rdi,%rdi
 5a3:	0f 84 2f 02 00 00    	je     7d8 <change_protection+0x2e8>
 5a9:	48 b8 fb 0f 00 00 00 	movabs $0xffffc00000000ffb,%rax
 5b0:	c0 ff ff
 5b3:	48 21 f8             	and    %rdi,%rax
 5b6:	48 83 f8 63          	cmp    $0x63,%rax
 5ba:	0f 85 98 03 00 00    	jne    958 <change_protection+0x468>
 5c0:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 5c8 <change_protection+0xd8>
 5c7:	00
			5c3: R_X86_64_PC32	pv_mmu_ops+0xf3
 5c8:	0f 84 d2 03 00 00    	je     9a0 <change_protection+0x4b0>
 5ce:	ff 14 25 00 00 00 00 	callq  *0x0
			5d1: R_X86_64_32S	pv_mmu_ops+0xf8
 5d5:	4c 89 df             	mov    %r11,%rdi
 5d8:	4d 89 ea             	mov    %r13,%r10
 5db:	4c 89 bd 60 ff ff ff 	mov    %r15,-0xa0(%rbp)
 5e2:	48 ba 00 f0 ff ff ff 	movabs $0x3ffffffff000,%rdx
 5e9:	3f 00 00
 5ec:	48 c1 ef 1b          	shr    $0x1b,%rdi
 5f0:	48 21 d0             	and    %rdx,%rax
 5f3:	48 be 00 00 00 00 00 	movabs $0xffff880000000000,%rsi
 5fa:	88 ff ff
 5fd:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
 604:	00 00 00 00
 608:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
 60e:	48 89 95 70 ff ff ff 	mov    %rdx,-0x90(%rbp)
 615:	48 01 f7             	add    %rsi,%rdi
 618:	4c 8d 34 07          	lea    (%rdi,%rax,1),%r14
 61c:	49 8d 45 ff          	lea    -0x1(%r13),%rax
 620:	4d 89 f5             	mov    %r14,%r13
 623:	4d 89 de             	mov    %r11,%r14
 626:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
 62a:	49 8d 9e 00 00 00 40 	lea    0x40000000(%r14),%rbx
 631:	49 8b 7d 00          	mov    0x0(%r13),%rdi
 635:	48 81 e3 00 00 00 c0 	and    $0xffffffffc0000000,%rbx
 63c:	48 8d 43 ff          	lea    -0x1(%rbx),%rax
 640:	48 3b 45 a0          	cmp    -0x60(%rbp),%rax
 644:	49 0f 43 da          	cmovae %r10,%rbx
 648:	48 85 ff             	test   %rdi,%rdi
 64b:	0f 84 ff 01 00 00    	je     850 <change_protection+0x360>
 651:	48 b8 98 0f 00 00 00 	movabs $0xffffc00000000f98,%rax
 658:	c0 ff ff
 65b:	48 85 c7             	test   %rax,%rdi
 65e:	0f 85 04 03 00 00    	jne    968 <change_protection+0x478>
 664:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 66c <change_protection+0x17c>
 66b:	00
			667: R_X86_64_PC32	pv_mmu_ops+0x11b
 66c:	0f 84 4e 03 00 00    	je     9c0 <change_protection+0x4d0>
 672:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
 676:	48 8b 40 40          	mov    0x40(%rax),%rax
 67a:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
 681:	ff 14 25 00 00 00 00 	callq  *0x0
			684: R_X86_64_32S	pv_mmu_ops+0x120
 688:	48 23 85 70 ff ff ff 	and    -0x90(%rbp),%rax
 68f:	4d 89 f4             	mov    %r14,%r12
 692:	45 31 db             	xor    %r11d,%r11d
 695:	4c 89 ad 48 ff ff ff 	mov    %r13,-0xb8(%rbp)
 69c:	49 c1 ec 12          	shr    $0x12,%r12
 6a0:	48 c7 45 88 00 00 00 	movq   $0x0,-0x78(%rbp)
 6a7:	00
 6a8:	4d 89 dd             	mov    %r11,%r13
 6ab:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
 6b2:	4c 89 95 50 ff ff ff 	mov    %r10,-0xb0(%rbp)
 6b9:	48 ba 00 00 00 00 00 	movabs $0xffff880000000000,%rdx
 6c0:	88 ff ff
 6c3:	48 c7 85 58 ff ff ff 	movq   $0x0,-0xa8(%rbp)
 6ca:	00 00 00 00
 6ce:	49 01 d4             	add    %rdx,%r12
 6d1:	49 01 c4             	add    %rax,%r12
 6d4:	48 8d 43 ff          	lea    -0x1(%rbx),%rax
 6d8:	48 89 45 90          	mov    %rax,-0x70(%rbp)
 6dc:	4d 8d be 00 00 20 00 	lea    0x200000(%r14),%r15
 6e3:	49 8b 3c 24          	mov    (%r12),%rdi
 6e7:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15
 6ee:	49 8d 47 ff          	lea    -0x1(%r15),%rax
 6f2:	48 3b 45 90          	cmp    -0x70(%rbp),%rax
 6f6:	4c 0f 43 fb          	cmovae %rbx,%r15
 6fa:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 702 <change_protection+0x212>
 701:	00
			6fd: R_X86_64_PC32	pv_mmu_ops+0x10b
 702:	0f 84 60 01 00 00    	je     868 <change_protection+0x378>
 708:	ff 14 25 00 00 00 00 	callq  *0x0
			70b: R_X86_64_32S	pv_mmu_ops+0x110
 70f:	a8 80                	test   $0x80,%al
 711:	0f 84 59 01 00 00    	je     870 <change_protection+0x380>
 717:	4d 85 ed             	test   %r13,%r13
 71a:	75 18                	jne    734 <change_protection+0x244>
 71c:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
 723:	4d 89 f5             	mov    %r14,%r13
 726:	48 83 b8 c0 04 00 00 	cmpq   $0x0,0x4c0(%rax)
 72d:	00
 72e:	0f 85 54 02 00 00    	jne    988 <change_protection+0x498>
 734:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 73c <change_protection+0x24c>
 73b:	00
			737: R_X86_64_PC32	pv_mmu_ops+0x10b
 73c:	49 8b 3c 24          	mov    (%r12),%rdi
 740:	0f 84 22 01 00 00    	je     868 <change_protection+0x378>
 746:	ff 14 25 00 00 00 00 	callq  *0x0
			749: R_X86_64_32S	pv_mmu_ops+0x110
 74d:	a8 80                	test   $0x80,%al
 74f:	74 33                	je     784 <change_protection+0x294>
 751:	4c 89 f8             	mov    %r15,%rax
 754:	4c 29 f0             	sub    %r14,%rax
 757:	48 3d 00 00 20 00    	cmp    $0x200000,%rax
 75d:	0f 84 7d 01 00 00    	je     8e0 <change_protection+0x3f0>
 763:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 76b <change_protection+0x27b>
 76a:	00
			766: R_X86_64_PC32	pv_mmu_ops+0x10b
 76b:	49 8b 3c 24          	mov    (%r12),%rdi
 76f:	0f 84 f3 00 00 00    	je     868 <change_protection+0x378>
 775:	ff 14 25 00 00 00 00 	callq  *0x0
			778: R_X86_64_32S	pv_mmu_ops+0x110
 77c:	a8 80                	test   $0x80,%al
 77e:	0f 85 24 02 00 00    	jne    9a8 <change_protection+0x4b8>
 784:	8b 45 9c             	mov    -0x64(%rbp),%eax
 787:	4c 89 f9             	mov    %r15,%rcx
 78a:	4c 89 f2             	mov    %r14,%rdx
 78d:	4c 89 e6             	mov    %r12,%rsi
 790:	44 8b 4d 98          	mov    -0x68(%rbp),%r9d
 794:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
 798:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
 79c:	89 04 24             	mov    %eax,(%rsp)
 79f:	e8 5c f8 ff ff       	callq  0 <change_pte_range>
 7a4:	48 01 45 88          	add    %rax,-0x78(%rbp)
 7a8:	49 83 c4 08          	add    $0x8,%r12
 7ac:	4c 39 fb             	cmp    %r15,%rbx
 7af:	74 3f                	je     7f0 <change_protection+0x300>
 7b1:	4d 89 fe             	mov    %r15,%r14
 7b4:	e9 23 ff ff ff       	jmpq   6dc <change_protection+0x1ec>
 7b9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
 7c0:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
 7c7:	4d 89 d5             	mov    %r10,%r13
 7ca:	4c 8b bd 60 ff ff ff 	mov    -0xa0(%rbp),%r15
 7d1:	48 01 75 a8          	add    %rsi,-0x58(%rbp)
 7d5:	0f 1f 00             	nopl   (%rax)
 7d8:	49 83 c7 08          	add    $0x8,%r15
 7dc:	4c 39 6d d0          	cmp    %r13,-0x30(%rbp)
 7e0:	0f 84 3a 01 00 00    	je     920 <change_protection+0x430>
 7e6:	4d 89 eb             	mov    %r13,%r11
 7e9:	e9 88 fd ff ff       	jmpq   576 <change_protection+0x86>
 7ee:	66 90                	xchg   %ax,%ax
 7f0:	4d 89 eb             	mov    %r13,%r11
 7f3:	4c 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%r10
 7fa:	4c 8b ad 48 ff ff ff 	mov    -0xb8(%rbp),%r13
 801:	4d 85 db             	test   %r11,%r11
 804:	74 2a                	je     830 <change_protection+0x340>
 806:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
 80d:	48 83 b8 c0 04 00 00 	cmpq   $0x0,0x4c0(%rax)
 814:	00
 815:	74 19                	je     830 <change_protection+0x340>
 817:	48 89 da             	mov    %rbx,%rdx
 81a:	4c 89 de             	mov    %r11,%rsi
 81d:	48 89 c7             	mov    %rax,%rdi
 820:	4c 89 55 90          	mov    %r10,-0x70(%rbp)
 824:	e8 00 00 00 00       	callq  829 <change_protection+0x339>
			825: R_X86_64_PC32	__mmu_notifier_invalidate_range_end-0x4
 829:	4c 8b 55 90          	mov    -0x70(%rbp),%r10
 82d:	0f 1f 00             	nopl   (%rax)
 830:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
 837:	48 85 c0             	test   %rax,%rax
 83a:	74 09                	je     845 <change_protection+0x355>
 83c:	65 48 01 04 25 00 00 	add    %rax,%gs:0x0
 843:	00 00
			841: R_X86_64_32S	vm_event_states+0x170
 845:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
 849:	48 01 b5 68 ff ff ff 	add    %rsi,-0x98(%rbp)
 850:	49 83 c5 08          	add    $0x8,%r13
 854:	49 39 da             	cmp    %rbx,%r10
 857:	0f 84 63 ff ff ff    	je     7c0 <change_protection+0x2d0>
 85d:	49 89 de             	mov    %rbx,%r14
 860:	e9 c5 fd ff ff       	jmpq   62a <change_protection+0x13a>
 865:	0f 1f 00             	nopl   (%rax)
 868:	0f 0b                	ud2
 86a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 870:	49 8b 04 24          	mov    (%r12),%rax
 874:	48 85 c0             	test   %rax,%rax
 877:	0f 84 2b ff ff ff    	je     7a8 <change_protection+0x2b8>
 87d:	48 89 c2             	mov    %rax,%rdx
 880:	81 e2 01 02 00 00    	and    $0x201,%edx
 886:	48 81 fa 00 02 00 00 	cmp    $0x200,%rdx
 88d:	0f 84 84 fe ff ff    	je     717 <change_protection+0x227>
 893:	48 be fb 0f 00 00 00 	movabs $0xffffc00000000ffb,%rsi
 89a:	c0 ff ff
 89d:	48 21 f0             	and    %rsi,%rax
 8a0:	48 83 f8 63          	cmp    $0x63,%rax
 8a4:	0f 84 6d fe ff ff    	je     717 <change_protection+0x227>
 8aa:	4c 89 e7             	mov    %r12,%rdi
 8ad:	e8 00 00 00 00       	callq  8b2 <change_protection+0x3c2>
			8ae: R_X86_64_PC32	pmd_clear_bad-0x4
 8b2:	e9 f1 fe ff ff       	jmpq   7a8 <change_protection+0x2b8>
 8b7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 8be:	00 00
 8c0:	e8 00 00 00 00       	callq  8c5 <change_protection+0x3d5>
			8c1: R_X86_64_PC32	hugetlb_change_protection-0x4
 8c5:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
 8c9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
 8cd:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
 8d4:	5b                   	pop    %rbx
 8d5:	41 5c                	pop    %r12
 8d7:	41 5d                	pop    %r13
 8d9:	41 5e                	pop    %r14
 8db:	41 5f                	pop    %r15
 8dd:	5d                   	pop    %rbp
 8de:	c3                   	retq
 8df:	90                   	nop
 8e0:	44 8b 45 9c          	mov    -0x64(%rbp),%r8d
 8e4:	4c 89 f2             	mov    %r14,%rdx
 8e7:	4c 89 e6             	mov    %r12,%rsi
 8ea:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
 8ee:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
 8f2:	e8 00 00 00 00       	callq  8f7 <change_protection+0x407>
			8f3: R_X86_64_PC32	change_huge_pmd-0x4
 8f7:	85 c0                	test   %eax,%eax
 8f9:	0f 84 85 fe ff ff    	je     784 <change_protection+0x294>
 8ff:	3d 00 02 00 00       	cmp    $0x200,%eax
 904:	0f 85 9e fe ff ff    	jne    7a8 <change_protection+0x2b8>
 90a:	48 81 45 88 00 02 00 	addq   $0x200,-0x78(%rbp)
 911:	00
 912:	48 83 85 58 ff ff ff 	addq   $0x1,-0xa8(%rbp)
 919:	01
 91a:	e9 89 fe ff ff       	jmpq   7a8 <change_protection+0x2b8>
 91f:	90                   	nop
 920:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
 925:	4c 8b 7d d0          	mov    -0x30(%rbp),%r15
 929:	74 18                	je     943 <change_protection+0x453>
 92b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
 92f:	4c 89 fa             	mov    %r15,%rdx
 932:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
 936:	48 8b 48 50          	mov    0x50(%rax),%rcx
 93a:	48 8b 78 40          	mov    0x40(%rax),%rdi
 93e:	e8 00 00 00 00       	callq  943 <change_protection+0x453>
			93f: R_X86_64_PC32	flush_tlb_mm_range-0x4
 943:	48 8b 45 80          	mov    -0x80(%rbp),%rax
 947:	c6 80 dc 08 00 00 00 	movb   $0x0,0x8dc(%rax)
 94e:	e9 76 ff ff ff       	jmpq   8c9 <change_protection+0x3d9>
 953:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 958:	4c 89 ff             	mov    %r15,%rdi
 95b:	e8 00 00 00 00       	callq  960 <change_protection+0x470>
			95c: R_X86_64_PC32	pgd_clear_bad-0x4
 960:	e9 73 fe ff ff       	jmpq   7d8 <change_protection+0x2e8>
 965:	0f 1f 00             	nopl   (%rax)
 968:	4c 89 ef             	mov    %r13,%rdi
 96b:	4c 89 55 90          	mov    %r10,-0x70(%rbp)
 96f:	e8 00 00 00 00       	callq  974 <change_protection+0x484>
			970: R_X86_64_PC32	pud_clear_bad-0x4
 974:	4c 8b 55 90          	mov    -0x70(%rbp),%r10
 978:	e9 d3 fe ff ff       	jmpq   850 <change_protection+0x360>
 97d:	0f 1f 00             	nopl   (%rax)
 980:	0f 0b                	ud2
 982:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 988:	48 89 da             	mov    %rbx,%rdx
 98b:	4c 89 f6             	mov    %r14,%rsi
 98e:	48 89 c7             	mov    %rax,%rdi
 991:	e8 00 00 00 00       	callq  996 <change_protection+0x4a6>
			992: R_X86_64_PC32	__mmu_notifier_invalidate_range_start-0x4
 996:	e9 99 fd ff ff       	jmpq   734 <change_protection+0x244>
 99b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 9a0:	0f 0b                	ud2
 9a2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 9a8:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
 9ac:	4c 89 e2             	mov    %r12,%rdx
 9af:	4c 89 f6             	mov    %r14,%rsi
 9b2:	e8 00 00 00 00       	callq  9b7 <change_protection+0x4c7>
			9b3: R_X86_64_PC32	__split_huge_page_pmd-0x4
 9b7:	e9 c8 fd ff ff       	jmpq   784 <change_protection+0x294>
 9bc:	0f 1f 40 00          	nopl   0x0(%rax)
 9c0:	0f 0b                	ud2
 9c2:	66 66 66 66 66 2e 0f 	data32 data32 data32 data32 nopw %cs:0x0(%rax,%rax,1)
 9c9:	1f 84 00 00 00 00 00

> I've been rather assuming that the 9d340902 seen in many of the
> registers in that Aug26 dump is the pte val in question: that's
> SOFT_DIRTY|PROTNONE|RW.
> 
> I think RW on PROTNONE is unusual but not impossible (migration entry
> replacement racing with mprotect setting PROT_NONE, after it's updated
> vm_page_prot, before it's reached the page table).  But exciting though
> that line of thought is, I cannot actually bring it to a pte_mknuma bug,
> or any bug at all.
> 
> Mel, no way can it be the cause of this bug - unless Sasha's later
> traces actually show a different stack - but I don't see the call
> to change_prot_numa() from queue_pages_range() sharing the same
> avoidance of PROT_NONE that task_numa_work() has (though it does
> have an outdated comment about PROT_NONE which should be removed).
> So I think that site probably does need PROT_NONE checking added.

I've spotted a new trace in overnight fuzzing, it could be related to this issue:

[ 3494.324839] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3494.332153] Dumping ftrace buffer:
[ 3494.332153]    (ftrace buffer empty)
[ 3494.332153] Modules linked in:
[ 3494.332153] CPU: 8 PID: 2727 Comm: trinity-c929 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1135
[ 3494.332153] task: ffff88047e52b000 ti: ffff8804d491c000 task.ti: ffff8804d491c000
[ 3494.332153] RIP: task_numa_work (include/linux/mempolicy.h:177 kernel/sched/fair.c:1956)
[ 3494.332153] RSP: 0000:ffff8804d491feb8  EFLAGS: 00010206
[ 3494.332153] RAX: 0000000000000000 RBX: ffff8804bf4e8000 RCX: 000000000000e8e8
[ 3494.343974] RDX: 000000000000000a RSI: 0000000000000000 RDI: ffff8804bd6d4da8
[ 3494.343974] RBP: ffff8804d491fef8 R08: ffff8804bf4e84c8 R09: 0000000000000000
[ 3494.343974] R10: 00007f53e443c000 R11: 0000000000000001 R12: 00007f53e443c000
[ 3494.343974] R13: 000000000000dc51 R14: 006f732e61727478 R15: ffff88047e52b000
[ 3494.343974] FS:  00007f53e463f700(0000) GS:ffff880277e00000(0000) knlGS:0000000000000000
[ 3494.343974] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3494.369895] CR2: 0000000001670fa8 CR3: 0000000283562000 CR4: 00000000000006a0
[ 3494.369895] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3494.369895] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 3494.380081] Stack:
[ 3494.380081]  ffff8804bf4e80a8 0000000000000014 00007f53e4437000 0000000000000000
[ 3494.380081]  ffffffff9b976e70 ffff88047e52bbd8 ffff88047e52b000 0000000000000000
[ 3494.380081]  ffff8804d491ff28 ffffffff95193d84 0000000000000002 ffff8804d491ff58
[ 3494.380081] Call Trace:
[ 3494.380081] task_work_run (kernel/task_work.c:125 (discriminator 1))
[ 3494.380081] do_notify_resume (include/linux/tracehook.h:190 arch/x86/kernel/signal.c:758)
[ 3494.380081] retint_signal (arch/x86/kernel/entry_64.S:918)
[ 3494.380081] Code: e8 1e e5 01 00 48 89 df 4c 89 e6 e8 a3 2d 13 00 49 89 c6 48 85 c0 0f 84 07 02 00 00 48 c7 45 c8 00 00 00 00 0f 1f 80 00 00 00 00 <49> f7 46 50 00 44 00 00 0f 85 42 01 00 00 49 8b 86 a0 00 00 00
All code
========
   0:	e8 1e e5 01 00       	callq  0x1e523
   5:	48 89 df             	mov    %rbx,%rdi
   8:	4c 89 e6             	mov    %r12,%rsi
   b:	e8 a3 2d 13 00       	callq  0x132db3
  10:	49 89 c6             	mov    %rax,%r14
  13:	48 85 c0             	test   %rax,%rax
  16:	0f 84 07 02 00 00    	je     0x223
  1c:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  23:	00
  24:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  2b:*	49 f7 46 50 00 44 00 	testq  $0x4400,0x50(%r14)		<-- trapping instruction
  32:	00
  33:	0f 85 42 01 00 00    	jne    0x17b
  39:	49 8b 86 a0 00 00 00 	mov    0xa0(%r14),%rax
	...

Code starting with the faulting instruction
===========================================
   0:	49 f7 46 50 00 44 00 	testq  $0x4400,0x50(%r14)
   7:	00
   8:	0f 85 42 01 00 00    	jne    0x150
   e:	49 8b 86 a0 00 00 00 	mov    0xa0(%r14),%rax
	...
[ 3494.380081] RIP task_numa_work (include/linux/mempolicy.h:177 kernel/sched/fair.c:1956)
[ 3494.380081]  RSP <ffff8804d491feb8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
