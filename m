Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AA3616B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 13:24:41 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so1220435igc.6
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 10:24:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x9si2811913igl.11.2014.09.03.10.24.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 10:24:41 -0700 (PDT)
Message-ID: <54074EB9.4000301@oracle.com>
Date: Wed, 03 Sep 2014 13:24:09 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: kernel BUG at mm/mmap.c:446!
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Jerome Marchand <jmarchan@redhat.com>, Davidlohr Bueso <davidlohr@hp.com>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 8419.384997] kernel BUG at mm/mmap.c:446!
[ 8419.385478] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 8419.388478] Dumping ftrace buffer:
[ 8419.390338]    (ftrace buffer empty)
[ 8419.393890] Modules linked in:
[ 8419.393890] CPU: 19 PID: 32634 Comm: trinity-c190 Not tainted 3.17.0-rc3-next-20140902-sasha-00031-g407ff1a #1099
[ 8419.393890] task: ffff880349293000 ti: ffff880458304000 task.ti: ffff880458304000
[ 8419.393890] RIP: validate_mm (mm/mmap.c:446 (discriminator 1))
[ 8419.393890] RSP: 0000:ffff880458307da8  EFLAGS: 00010296
[ 8419.393890] RAX: 000000000000001a RBX: 00000000000002c2 RCX: 0000000000000000
[ 8419.393890] RDX: 000000000000001a RSI: ffffffffb14e5e17 RDI: ffffffffae1e4007
[ 8419.393890] RBP: ffff880458307de8 R08: 0000000000000001 R09: 0000000000000001
[ 8419.393890] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000001
[ 8419.393890] R13: 0000000000000000 R14: ffff8802aac8d000 R15: 0000000000000000
[ 8419.393890] FS:  00007fd40a4d0700(0000) GS:ffff880958400000(0000) knlGS:0000000000000000
[ 8419.393890] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 8419.393890] CR2: 000000000063c378 CR3: 00000002891ee000 CR4: 00000000000006a0
[ 8419.393890] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 8419.393890] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 8419.393890] Stack:
[ 8419.393890]  ffff8802c4f87e00 000000000229be00 ffff880200000001 ffff880354275600
[ 8419.393890]  ffff88030229be00 ffff88030229be78 ffff88035c215800 ffff88030229be68
[ 8419.393890]  ffff880458307e78 ffffffffae2e42f8 fffffffffffff9fa 00000000000025d2
[ 8419.393890] Call Trace:
[ 8419.393890] vma_adjust (mm/mmap.c:895)
[ 8419.393890] vma_merge (mm/mmap.c:1056)
[ 8419.393890] do_brk (mm/mmap.c:2743)
[ 8419.393890] SyS_brk (mm/mmap.c:322 mm/mmap.c:269)
[ 8419.393890] tracesys (arch/x86/kernel/entry_64.S:542)
[ 8419.393890] Code: 8b 76 58 39 d6 75 16 8b 45 cc 85 c0 75 1d 48 83 c4 18 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 c7 c7 88 c0 75 b2 31 c0 e8 06 2c 20 03 <0f> 0b 31 db 45 31 ff e9 f5 fe ff ff 48 89 c2 48 c7 c7 28 09 76
All code
========
   0:	8b 76 58             	mov    0x58(%rsi),%esi
   3:	39 d6                	cmp    %edx,%esi
   5:	75 16                	jne    0x1d
   7:	8b 45 cc             	mov    -0x34(%rbp),%eax
   a:	85 c0                	test   %eax,%eax
   c:	75 1d                	jne    0x2b
   e:	48 83 c4 18          	add    $0x18,%rsp
  12:	5b                   	pop    %rbx
  13:	41 5c                	pop    %r12
  15:	41 5d                	pop    %r13
  17:	41 5e                	pop    %r14
  19:	41 5f                	pop    %r15
  1b:	5d                   	pop    %rbp
  1c:	c3                   	retq
  1d:	48 c7 c7 88 c0 75 b2 	mov    $0xffffffffb275c088,%rdi
  24:	31 c0                	xor    %eax,%eax
  26:	e8 06 2c 20 03       	callq  0x3202c31
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	31 db                	xor    %ebx,%ebx
  2f:	45 31 ff             	xor    %r15d,%r15d
  32:	e9 f5 fe ff ff       	jmpq   0xffffffffffffff2c
  37:	48 89 c2             	mov    %rax,%rdx
  3a:	48 c7 c7 28 09 76 00 	mov    $0x760928,%rdi

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	31 db                	xor    %ebx,%ebx
   4:	45 31 ff             	xor    %r15d,%r15d
   7:	e9 f5 fe ff ff       	jmpq   0xffffffffffffff01
   c:	48 89 c2             	mov    %rax,%rdx
   f:	48 c7 c7 28 09 76 00 	mov    $0x760928,%rdi
[ 8419.393890] RIP validate_mm (mm/mmap.c:446 (discriminator 1))
[ 8419.393890]  RSP <ffff880458307da8>

I'm not sure which one of the possible reasons for BUG() it was since the
pr_info didn't end up getting printed (I'm sending a patch to make that code
nicer).


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
