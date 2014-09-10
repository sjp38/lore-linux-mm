Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C089D6B009F
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:37:05 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id h18so1711751igc.9
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:37:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ip4si18680892icc.11.2014.09.10.13.37.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:37:04 -0700 (PDT)
Message-ID: <5410B641.1080504@oracle.com>
Date: Wed, 10 Sep 2014 16:36:17 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com> <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <54104E24.5010402@oracle.com> <alpine.LSU.2.11.1409101148290.1262@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409101148290.1262@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/10/2014 03:09 PM, Hugh Dickins wrote:
> Thanks for supplying, but the change in inlining means that
> change_protection_range() and change_protection() are no longer
> relevant for these traces, we now need to see change_pte_range()
> instead, to confirm that what I expect are ptes are indeed ptes.
> 
> If you can include line numbers (objdump -ld) in the disassembly, so
> much the better, but should be decipherable without.  (Or objdump -Sd
> for source, but I often find that harder to unscramble, can't say why.)

Here it is. Note that the source includes both of Mel's debug patches.
For reference, here's one trace of the issue with those patches:

[ 3114.540976] kernel BUG at include/asm-generic/pgtable.h:724!
[ 3114.541857] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3114.543112] Dumping ftrace buffer:
[ 3114.544056]    (ftrace buffer empty)
[ 3114.545000] Modules linked in:
[ 3114.545717] CPU: 18 PID: 30217 Comm: trinity-c617 Tainted: G        W      3.17.0-rc4-next-20140910-sasha-00032-g6825fb5-dirty #1137
[ 3114.548058] task: ffff880415050000 ti: ffff88076f584000 task.ti: ffff88076f584000
[ 3114.549284] RIP: 0010:[<ffffffff952e527a>]  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
[ 3114.550028] RSP: 0000:ffff88076f587d68  EFLAGS: 00010246
[ 3114.550028] RAX: 0000000314625900 RBX: 0000000041218000 RCX: 0000000000000100
[ 3114.550028] RDX: 0000000314625900 RSI: 0000000041218000 RDI: 0000000314625900
[ 3114.550028] RBP: ffff88076f587dc8 R08: ffff8802cf973600 R09: 0000000000b50000
[ 3114.550028] R10: 0000000000032c01 R11: 0000000000000008 R12: ffff8802a81070c0
[ 3114.550028] R13: 8000000000000025 R14: 0000000041343000 R15: ffffc00000000fff
[ 3114.550028] FS:  00007fabb91c8700(0000) GS:ffff88025ec00000(0000) knlGS:0000000000000000
[ 3114.550028] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3114.550028] CR2: 00007fffdb7678e8 CR3: 0000000713935000 CR4: 00000000000006a0
[ 3114.550028] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3114.550028] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000050602
[ 3114.550028] Stack:
[ 3114.550028]  0000000000000001 0000000314625900 0000000000000018 ffff8802685f2260
[ 3114.550028]  0000000016840000 ffff8802cf973600 ffff880616840000 0000000041343000
[ 3114.550028]  ffff880108805048 0000000041005000 0000000041200000 0000000041343000
[ 3114.550028] Call Trace:
[ 3114.550028]  [<ffffffff952e5534>] change_protection+0x2b4/0x4e0
[ 3114.550028]  [<ffffffff952ff24b>] change_prot_numa+0x1b/0x40
[ 3114.550028]  [<ffffffff951adf16>] task_numa_work+0x1f6/0x330
[ 3114.550028]  [<ffffffff95193de4>] task_work_run+0xc4/0xf0
[ 3114.550028]  [<ffffffff95071477>] do_notify_resume+0x97/0xb0
[ 3114.550028]  [<ffffffff9850f06a>] int_signal+0x12/0x17
[ 3114.550028] Code: 66 90 48 8b 7d b8 e8 e6 88 22 03 48 8b 45 b0 e9 6f ff ff ff 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b <0f> 0b 0f 0b 0f 0b 66 66 66 66 90 55 48 89 e5 41 57 49 89 d7 41
[ 3114.550028] RIP  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
[ 3114.550028]  RSP <ffff88076f587d68>

And the disassembly:

0000000000000000 <change_pte_range>:
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:70
   0:	e8 00 00 00 00       	callq  5 <change_pte_range+0x5>
			1: R_X86_64_PC32	__fentry__-0x4
   5:	55                   	push   %rbp
   6:	48 89 e5             	mov    %rsp,%rbp
   9:	41 57                	push   %r15
   b:	41 56                	push   %r14
   d:	49 89 ce             	mov    %rcx,%r14
  10:	41 55                	push   %r13
  12:	4d 89 c5             	mov    %r8,%r13
  15:	41 54                	push   %r12
  17:	49 89 f4             	mov    %rsi,%r12
  1a:	53                   	push   %rbx
  1b:	48 89 d3             	mov    %rdx,%rbx
  1e:	48 83 ec 38          	sub    $0x38,%rsp
/home/sasha/linux-next/mm/mprotect.c:71
  22:	48 8b 47 40          	mov    0x40(%rdi),%rax
/home/sasha/linux-next/mm/mprotect.c:70
  26:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
lock_pte_protection():
/home/sasha/linux-next/mm/mprotect.c:53
  2a:	8b 4d 10             	mov    0x10(%rbp),%ecx
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:70
  2d:	44 89 4d c4          	mov    %r9d,-0x3c(%rbp)
/home/sasha/linux-next/mm/mprotect.c:71
  31:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
lock_pte_protection():
/home/sasha/linux-next/mm/mprotect.c:53
  35:	85 c9                	test   %ecx,%ecx
  37:	0f 84 6b 03 00 00    	je     3a8 <change_pte_range+0x3a8>
pmd_to_page():
/home/sasha/linux-next/include/linux/mm.h:1538
  3d:	48 89 f7             	mov    %rsi,%rdi
  40:	48 81 e7 00 f0 ff ff 	and    $0xfffffffffffff000,%rdi
  47:	e8 00 00 00 00       	callq  4c <change_pte_range+0x4c>
			48: R_X86_64_PC32	__phys_addr-0x4
  4c:	48 ba 00 00 00 00 00 	movabs $0xffffea0000000000,%rdx
  53:	ea ff ff
  56:	48 c1 e8 0c          	shr    $0xc,%rax
spin_lock():
/home/sasha/linux-next/include/linux/spinlock.h:309
  5a:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  5e:	48 c1 e0 06          	shl    $0x6,%rax
  62:	4c 8b 7c 10 30       	mov    0x30(%rax,%rdx,1),%r15
  67:	4c 89 ff             	mov    %r15,%rdi
  6a:	e8 00 00 00 00       	callq  6f <change_pte_range+0x6f>
			6b: R_X86_64_PC32	_raw_spin_lock-0x4
  6f:	49 8b 3c 24          	mov    (%r12),%rdi
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
  73:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 7b <change_pte_range+0x7b>
  7a:	00
			76: R_X86_64_PC32	pv_mmu_ops+0x10b
  7b:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  7f:	0f 84 ab 03 00 00    	je     430 <change_pte_range+0x430>
  85:	ff 14 25 00 00 00 00 	callq  *0x0
			88: R_X86_64_32S	pv_mmu_ops+0x110
lock_pte_protection():
/home/sasha/linux-next/mm/mprotect.c:57
  8c:	a8 80                	test   $0x80,%al
  8e:	0f 85 a4 03 00 00    	jne    438 <change_pte_range+0x438>
  94:	49 8b 3c 24          	mov    (%r12),%rdi
  98:	48 85 ff             	test   %rdi,%rdi
  9b:	0f 84 97 03 00 00    	je     438 <change_pte_range+0x438>
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
  a1:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # a9 <change_pte_range+0xa9>
  a8:	00
			a4: R_X86_64_PC32	pv_mmu_ops+0x10b
  a9:	0f 84 81 03 00 00    	je     430 <change_pte_range+0x430>
  af:	ff 14 25 00 00 00 00 	callq  *0x0
			b2: R_X86_64_32S	pv_mmu_ops+0x110
  b6:	48 b9 00 f0 ff ff ff 	movabs $0x3ffffffff000,%rcx
  bd:	3f 00 00
  c0:	48 21 c8             	and    %rcx,%rax
  c3:	48 89 c7             	mov    %rax,%rdi
  c6:	48 c1 ef 06          	shr    $0x6,%rdi
  ca:	48 8b 44 3a 30       	mov    0x30(%rdx,%rdi,1),%rax
  cf:	49 8b 3c 24          	mov    (%r12),%rdi
  d3:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
  d7:	48 89 d8             	mov    %rbx,%rax
  da:	48 c1 e8 09          	shr    $0x9,%rax
  de:	25 f8 0f 00 00       	and    $0xff8,%eax
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
  e3:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # eb <change_pte_range+0xeb>
  ea:	00
			e6: R_X86_64_PC32	pv_mmu_ops+0x10b
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
  eb:	48 89 c2             	mov    %rax,%rdx
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
  ee:	0f 84 3c 03 00 00    	je     430 <change_pte_range+0x430>
  f4:	ff 14 25 00 00 00 00 	callq  *0x0
			f7: R_X86_64_32S	pv_mmu_ops+0x110
spin_lock():
/home/sasha/linux-next/include/linux/spinlock.h:309
  fb:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
pmd_page_vaddr():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
  ff:	49 89 c4             	mov    %rax,%r12
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
 102:	48 b8 00 00 00 00 00 	movabs $0xffff880000000000,%rax
 109:	88 ff ff
 10c:	48 01 d0             	add    %rdx,%rax
 10f:	4c 21 e1             	and    %r12,%rcx
 112:	4c 8d 24 08          	lea    (%rax,%rcx,1),%r12
spin_lock():
/home/sasha/linux-next/include/linux/spinlock.h:309
 116:	e8 00 00 00 00       	callq  11b <change_pte_range+0x11b>
			117: R_X86_64_PC32	_raw_spin_lock-0x4
spin_unlock():
/home/sasha/linux-next/include/linux/spinlock.h:349
 11b:	4c 89 ff             	mov    %r15,%rdi
 11e:	e8 00 00 00 00       	callq  123 <change_pte_range+0x123>
			11f: R_X86_64_PC32	_raw_spin_unlock-0x4
arch_enter_lazy_mmu_mode():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:694
 123:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 12b <change_pte_range+0x12b>
 12a:	00
			126: R_X86_64_PC32	pv_mmu_ops+0x133
 12b:	0f 84 a7 03 00 00    	je     4d8 <change_pte_range+0x4d8>
 131:	ff 14 25 00 00 00 00 	callq  *0x0
			134: R_X86_64_32S	pv_mmu_ops+0x138
massage_pgprot():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:351
 138:	4c 89 e8             	mov    %r13,%rax
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:74
 13b:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
 142:	00
pte_present():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:460
 143:	49 bf ff 0f 00 00 00 	movabs $0xffffc00000000fff,%r15
 14a:	c0 ff ff
massage_pgprot():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:351
 14d:	83 e0 01             	and    $0x1,%eax
 150:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
 154:	e9 fa 00 00 00       	jmpq   253 <change_pte_range+0x253>
 159:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:87
 160:	8b 55 10             	mov    0x10(%rbp),%edx
 163:	85 d2                	test   %edx,%edx
 165:	0f 85 85 01 00 00    	jne    2f0 <change_pte_range+0x2f0>
ptep_modify_prot_start():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:490
 16b:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 173 <change_pte_range+0x173>
 172:	00
			16e: R_X86_64_PC32	pv_mmu_ops+0xd3
 173:	0f 84 2f 03 00 00    	je     4a8 <change_pte_range+0x4a8>
 179:	48 8b 7d d0          	mov    -0x30(%rbp),%rdi
 17d:	48 89 de             	mov    %rbx,%rsi
 180:	4c 89 e2             	mov    %r12,%rdx
 183:	ff 14 25 00 00 00 00 	callq  *0x0
			186: R_X86_64_32S	pv_mmu_ops+0xd8
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:89
 18a:	48 89 c2             	mov    %rax,%rdx
ptep_modify_prot_start():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:490
 18d:	48 89 c7             	mov    %rax,%rdi
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:89
 190:	81 e2 01 03 00 00    	and    $0x301,%edx
 196:	48 81 fa 00 02 00 00 	cmp    $0x200,%rdx
 19d:	0f 84 bd 02 00 00    	je     460 <change_pte_range+0x460>
pte_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
 1a3:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 1ab <change_pte_range+0x1ab>
 1aa:	00
			1a6: R_X86_64_PC32	pv_mmu_ops+0xe3
 1ab:	0f 84 a7 02 00 00    	je     458 <change_pte_range+0x458>
 1b1:	ff 14 25 00 00 00 00 	callq  *0x0
			1b4: R_X86_64_32S	pv_mmu_ops+0xe8
pte_modify():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:377
 1b8:	48 be 78 fa ff ff ff 	movabs $0x3ffffffffa78,%rsi
 1bf:	3f 00 00
massage_pgprot():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:352
 1c2:	4c 89 ef             	mov    %r13,%rdi
 1c5:	48 23 3d 00 00 00 00 	and    0x0(%rip),%rdi        # 1cc <change_pte_range+0x1cc>
			1c8: R_X86_64_PC32	__supported_pte_mask-0x4
pte_modify():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:378
 1cc:	48 ba 87 05 00 00 00 	movabs $0xffffc00000000587,%rdx
 1d3:	c0 ff ff
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:377
 1d6:	48 21 f0             	and    %rsi,%rax
massage_pgprot():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:352
 1d9:	48 83 7d a0 00       	cmpq   $0x0,-0x60(%rbp)
 1de:	49 0f 44 fd          	cmove  %r13,%rdi
pte_modify():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:378
 1e2:	48 89 f9             	mov    %rdi,%rcx
 1e5:	48 21 d1             	and    %rdx,%rcx
 1e8:	48 09 c1             	or     %rax,%rcx
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 1eb:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 1f3 <change_pte_range+0x1f3>
 1f2:	00
			1ee: R_X86_64_PC32	pv_mmu_ops+0xeb
pte_modify():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:378
 1f3:	48 89 cf             	mov    %rcx,%rdi
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 1f6:	0f 84 a4 02 00 00    	je     4a0 <change_pte_range+0x4a0>
 1fc:	ff 14 25 00 00 00 00 	callq  *0x0
			1ff: R_X86_64_32S	pv_mmu_ops+0xf0
 203:	48 89 c1             	mov    %rax,%rcx
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:96
 206:	8b 45 c4             	mov    -0x3c(%rbp),%eax
 209:	85 c0                	test   %eax,%eax
 20b:	74 0e                	je     21b <change_pte_range+0x21b>
pte_set_flags():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:186 (discriminator 1)
 20d:	48 89 c8             	mov    %rcx,%rax
 210:	48 83 c8 02          	or     $0x2,%rax
 214:	f6 c1 40             	test   $0x40,%cl
 217:	48 0f 45 c8          	cmovne %rax,%rcx
ptep_modify_prot_commit():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:503
 21b:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 223 <change_pte_range+0x223>
 222:	00
			21e: R_X86_64_PC32	pv_mmu_ops+0xdb
 223:	0f 84 b7 02 00 00    	je     4e0 <change_pte_range+0x4e0>
 229:	48 8b 7d d0          	mov    -0x30(%rbp),%rdi
 22d:	48 89 de             	mov    %rbx,%rsi
 230:	4c 89 e2             	mov    %r12,%rdx
 233:	ff 14 25 00 00 00 00 	callq  *0x0
			236: R_X86_64_32S	pv_mmu_ops+0xe0
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:128
 23a:	48 83 45 b0 01       	addq   $0x1,-0x50(%rbp)
/home/sasha/linux-next/mm/mprotect.c:131
 23f:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
 246:	49 83 c4 08          	add    $0x8,%r12
 24a:	4c 39 f3             	cmp    %r14,%rbx
 24d:	0f 84 5d 02 00 00    	je     4b0 <change_pte_range+0x4b0>
/home/sasha/linux-next/mm/mprotect.c:82
 253:	49 8b 0c 24          	mov    (%r12),%rcx
pte_present():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:460
 257:	48 89 c8             	mov    %rcx,%rax
 25a:	4c 21 f8             	and    %r15,%rax
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:83
 25d:	a9 01 03 00 00       	test   $0x301,%eax
 262:	0f 85 f8 fe ff ff    	jne    160 <change_pte_range+0x160>
/home/sasha/linux-next/mm/mprotect.c:113
 268:	a8 40                	test   $0x40,%al
 26a:	75 d3                	jne    23f <change_pte_range+0x23f>
pte_swp_soft_dirty():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:885
 26c:	a9 01 01 00 00       	test   $0x101,%eax
 271:	0f 85 71 02 00 00    	jne    4e8 <change_pte_range+0x4e8>
pte_clear_flags():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:193
 277:	48 89 ca             	mov    %rcx,%rdx
 27a:	41 89 c0             	mov    %eax,%r8d
 27d:	80 e2 7f             	and    $0x7f,%dl
 280:	41 81 e0 80 00 00 00 	and    $0x80,%r8d
 287:	48 0f 45 ca          	cmovne %rdx,%rcx
pte_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
 28b:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 293 <change_pte_range+0x293>
 292:	00
			28e: R_X86_64_PC32	pv_mmu_ops+0xe3
 293:	0f 84 bf 01 00 00    	je     458 <change_pte_range+0x458>
 299:	48 89 cf             	mov    %rcx,%rdi
 29c:	ff 14 25 00 00 00 00 	callq  *0x0
			29f: R_X86_64_32S	pv_mmu_ops+0xe8
swp_entry():
/home/sasha/linux-next/include/linux/swapops.h:30
 2a3:	48 89 c1             	mov    %rax,%rcx
 2a6:	48 c1 e8 0a          	shr    $0xa,%rax
 2aa:	48 d1 e9             	shr    %rcx
 2ad:	83 e1 1f             	and    $0x1f,%ecx
 2b0:	48 c1 e1 39          	shl    $0x39,%rcx
 2b4:	48 09 c8             	or     %rcx,%rax
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:116
 2b7:	48 89 c2             	mov    %rax,%rdx
 2ba:	48 c1 ea 39          	shr    $0x39,%rdx
 2be:	48 83 fa 1f          	cmp    $0x1f,%rdx
 2c2:	0f 85 77 ff ff ff    	jne    23f <change_pte_range+0x23f>
swp_entry_to_pte():
/home/sasha/linux-next/include/linux/swapops.h:84
 2c8:	48 c1 e0 0a          	shl    $0xa,%rax
 2cc:	48 89 c1             	mov    %rax,%rcx
 2cf:	0c bc                	or     $0xbc,%al
 2d1:	48 83 c9 3c          	or     $0x3c,%rcx
 2d5:	45 85 c0             	test   %r8d,%r8d
 2d8:	48 0f 45 c8          	cmovne %rax,%rcx
set_pte_at():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:524
 2dc:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 2e4 <change_pte_range+0x2e4>
 2e3:	00
			2df: R_X86_64_PC32	pv_mmu_ops+0x9b
 2e4:	0f 85 a4 00 00 00    	jne    38e <change_pte_range+0x38e>
 2ea:	0f 0b                	ud2
 2ec:	0f 1f 40 00          	nopl   0x0(%rax)
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:103
 2f0:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
 2f4:	48 89 ca             	mov    %rcx,%rdx
 2f7:	48 89 de             	mov    %rbx,%rsi
 2fa:	48 89 4d a8          	mov    %rcx,-0x58(%rbp)
 2fe:	e8 00 00 00 00       	callq  303 <change_pte_range+0x303>
			2ff: R_X86_64_PC32	vm_normal_page-0x4
/home/sasha/linux-next/mm/mprotect.c:104
 303:	48 85 c0             	test   %rax,%rax
 306:	0f 84 33 ff ff ff    	je     23f <change_pte_range+0x23f>
/home/sasha/linux-next/mm/mprotect.c:104 (discriminator 1)
 30c:	48 8b 40 08          	mov    0x8(%rax),%rax
 310:	83 e0 03             	and    $0x3,%eax
 313:	48 83 f8 03          	cmp    $0x3,%rax
 317:	0f 84 22 ff ff ff    	je     23f <change_pte_range+0x23f>
/home/sasha/linux-next/mm/mprotect.c:105
 31d:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
 321:	81 e1 01 03 00 00    	and    $0x301,%ecx
 327:	48 81 f9 00 02 00 00 	cmp    $0x200,%rcx
 32e:	0f 84 0b ff ff ff    	je     23f <change_pte_range+0x23f>
pte_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
 334:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 33c <change_pte_range+0x33c>
 33b:	00
			337: R_X86_64_PC32	pv_mmu_ops+0xe3
ptep_set_numa():
/home/sasha/linux-next/include/asm-generic/pgtable.h:740
 33c:	49 8b 3c 24          	mov    (%r12),%rdi
pte_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
 340:	0f 84 12 01 00 00    	je     458 <change_pte_range+0x458>
 346:	ff 14 25 00 00 00 00 	callq  *0x0
			349: R_X86_64_32S	pv_mmu_ops+0xe8
pte_mknuma():
/home/sasha/linux-next/include/asm-generic/pgtable.h:724
 34d:	a8 01                	test   $0x1,%al
 34f:	0f 84 95 01 00 00    	je     4ea <change_pte_range+0x4ea>
/home/sasha/linux-next/include/asm-generic/pgtable.h:727
 355:	f6 c4 01             	test   $0x1,%ah
 358:	0f 85 8e 01 00 00    	jne    4ec <change_pte_range+0x4ec>
/home/sasha/linux-next/include/asm-generic/pgtable.h:729
 35e:	48 83 e0 fe          	and    $0xfffffffffffffffe,%rax
/home/sasha/linux-next/include/asm-generic/pgtable.h:730
 362:	80 cc 02             	or     $0x2,%ah
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 365:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 36d <change_pte_range+0x36d>
 36c:	00
			368: R_X86_64_PC32	pv_mmu_ops+0xeb
pte_mknuma():
/home/sasha/linux-next/include/asm-generic/pgtable.h:730
 36d:	48 89 c7             	mov    %rax,%rdi
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 370:	0f 84 2a 01 00 00    	je     4a0 <change_pte_range+0x4a0>
 376:	ff 14 25 00 00 00 00 	callq  *0x0
			379: R_X86_64_32S	pv_mmu_ops+0xf0
set_pte_at():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:524
 37d:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 385 <change_pte_range+0x385>
 384:	00
			380: R_X86_64_PC32	pv_mmu_ops+0x9b
pte_mknuma():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 385:	48 89 c1             	mov    %rax,%rcx
set_pte_at():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:524
 388:	0f 84 5c ff ff ff    	je     2ea <change_pte_range+0x2ea>
 38e:	48 8b 7d d0          	mov    -0x30(%rbp),%rdi
 392:	48 89 de             	mov    %rbx,%rsi
 395:	4c 89 e2             	mov    %r12,%rdx
 398:	ff 14 25 00 00 00 00 	callq  *0x0
			39b: R_X86_64_32S	pv_mmu_ops+0xa0
 39f:	e9 96 fe ff ff       	jmpq   23a <change_pte_range+0x23a>
 3a4:	0f 1f 40 00          	nopl   0x0(%rax)
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
 3a8:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 3b0 <change_pte_range+0x3b0>
 3af:	00
			3ab: R_X86_64_PC32	pv_mmu_ops+0x10b
 3b0:	48 8b 3e             	mov    (%rsi),%rdi
 3b3:	74 7b                	je     430 <change_pte_range+0x430>
 3b5:	ff 14 25 00 00 00 00 	callq  *0x0
			3b8: R_X86_64_32S	pv_mmu_ops+0x110
 3bc:	48 ba 00 f0 ff ff ff 	movabs $0x3ffffffff000,%rdx
 3c3:	3f 00 00
 3c6:	48 21 d0             	and    %rdx,%rax
 3c9:	48 89 c7             	mov    %rax,%rdi
 3cc:	48 b8 00 00 00 00 00 	movabs $0xffffea0000000000,%rax
 3d3:	ea ff ff
 3d6:	48 c1 ef 06          	shr    $0x6,%rdi
 3da:	48 8b 44 07 30       	mov    0x30(%rdi,%rax,1),%rax
 3df:	48 8b 3e             	mov    (%rsi),%rdi
 3e2:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
 3e6:	48 89 d8             	mov    %rbx,%rax
 3e9:	48 c1 e8 09          	shr    $0x9,%rax
 3ed:	25 f8 0f 00 00       	and    $0xff8,%eax
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
 3f2:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 3fa <change_pte_range+0x3fa>
 3f9:	00
			3f5: R_X86_64_PC32	pv_mmu_ops+0x10b
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
 3fa:	48 89 c1             	mov    %rax,%rcx
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
 3fd:	74 31                	je     430 <change_pte_range+0x430>
 3ff:	ff 14 25 00 00 00 00 	callq  *0x0
			402: R_X86_64_32S	pv_mmu_ops+0x110
spin_lock():
/home/sasha/linux-next/include/linux/spinlock.h:309
 406:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
pmd_page_vaddr():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
 40a:	49 89 c4             	mov    %rax,%r12
pte_offset_kernel():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:551
 40d:	48 b8 00 00 00 00 00 	movabs $0xffff880000000000,%rax
 414:	88 ff ff
 417:	48 01 c8             	add    %rcx,%rax
 41a:	4c 21 e2             	and    %r12,%rdx
 41d:	4c 8d 24 10          	lea    (%rax,%rdx,1),%r12
spin_lock():
/home/sasha/linux-next/include/linux/spinlock.h:309
 421:	e8 00 00 00 00       	callq  426 <change_pte_range+0x426>
			422: R_X86_64_PC32	_raw_spin_lock-0x4
 426:	e9 f8 fc ff ff       	jmpq   123 <change_pte_range+0x123>
 42b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
pmd_val():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:571
 430:	0f 0b                	ud2
 432:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
spin_unlock():
/home/sasha/linux-next/include/linux/spinlock.h:349
 438:	4c 89 ff             	mov    %r15,%rdi
 43b:	e8 00 00 00 00       	callq  440 <change_pte_range+0x440>
			43c: R_X86_64_PC32	_raw_spin_unlock-0x4
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:78
 440:	31 c0                	xor    %eax,%eax
/home/sasha/linux-next/mm/mprotect.c:136
 442:	48 83 c4 38          	add    $0x38,%rsp
 446:	5b                   	pop    %rbx
 447:	41 5c                	pop    %r12
 449:	41 5d                	pop    %r13
 44b:	41 5e                	pop    %r14
 44d:	41 5f                	pop    %r15
 44f:	5d                   	pop    %rbp
 450:	c3                   	retq
 451:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
pte_to_swp_entry():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
 458:	0f 0b                	ud2
 45a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
pte_val():
 460:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 468 <change_pte_range+0x468>
 467:	00
			463: R_X86_64_PC32	pv_mmu_ops+0xe3
 468:	74 ee                	je     458 <change_pte_range+0x458>
 46a:	48 89 c7             	mov    %rax,%rdi
 46d:	ff 14 25 00 00 00 00 	callq  *0x0
			470: R_X86_64_32S	pv_mmu_ops+0xe8
pte_mknonnuma():
/home/sasha/linux-next/include/asm-generic/pgtable.h:701
 474:	80 e4 fd             	and    $0xfd,%ah
/home/sasha/linux-next/include/asm-generic/pgtable.h:702
 477:	48 83 c8 21          	or     $0x21,%rax
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 47b:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 483 <change_pte_range+0x483>
 482:	00
			47e: R_X86_64_PC32	pv_mmu_ops+0xeb
pte_mknonnuma():
/home/sasha/linux-next/include/asm-generic/pgtable.h:702
 483:	48 89 c7             	mov    %rax,%rdi
__pte():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:435
 486:	74 18                	je     4a0 <change_pte_range+0x4a0>
 488:	ff 14 25 00 00 00 00 	callq  *0x0
			48b: R_X86_64_32S	pv_mmu_ops+0xf0
 48f:	48 89 c7             	mov    %rax,%rdi
 492:	e9 0c fd ff ff       	jmpq   1a3 <change_pte_range+0x1a3>
 497:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 49e:	00 00
 4a0:	0f 0b                	ud2
 4a2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
ptep_modify_prot_start():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:490
 4a8:	0f 0b                	ud2
 4aa:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
arch_leave_lazy_mmu_mode():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:699
 4b0:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 4b8 <change_pte_range+0x4b8>
 4b7:	00
			4b3: R_X86_64_PC32	pv_mmu_ops+0x13b
 4b8:	74 34                	je     4ee <change_pte_range+0x4ee>
 4ba:	ff 14 25 00 00 00 00 	callq  *0x0
			4bd: R_X86_64_32S	pv_mmu_ops+0x140
spin_unlock():
/home/sasha/linux-next/include/linux/spinlock.h:349
 4c1:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
 4c5:	e8 00 00 00 00       	callq  4ca <change_pte_range+0x4ca>
			4c6: R_X86_64_PC32	_raw_spin_unlock-0x4
change_pte_range():
/home/sasha/linux-next/mm/mprotect.c:135
 4ca:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
 4ce:	e9 6f ff ff ff       	jmpq   442 <change_pte_range+0x442>
 4d3:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
arch_enter_lazy_mmu_mode():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:694
 4d8:	0f 0b                	ud2
 4da:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
ptep_modify_prot_commit():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:503
 4e0:	0f 0b                	ud2
 4e2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
pte_to_swp_entry():
/home/sasha/linux-next/./arch/x86/include/asm/pgtable.h:885
 4e8:	0f 0b                	ud2
ptep_set_numa():
/home/sasha/linux-next/include/asm-generic/pgtable.h:724
 4ea:	0f 0b                	ud2
/home/sasha/linux-next/include/asm-generic/pgtable.h:727
 4ec:	0f 0b                	ud2
arch_leave_lazy_mmu_mode():
/home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:699
 4ee:	0f 0b                	ud2


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
