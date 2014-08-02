Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 835CB6B0035
	for <linux-mm@kvack.org>; Sat,  2 Aug 2014 17:59:38 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so7424076pde.37
        for <linux-mm@kvack.org>; Sat, 02 Aug 2014 14:59:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id bz2si13812925pab.151.2014.08.02.14.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 02 Aug 2014 14:59:37 -0700 (PDT)
Message-ID: <53DD5F20.8010507@oracle.com>
Date: Sat, 02 Aug 2014 17:58:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: BUG in unmap_page_range
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 2957.087977] BUG: unable to handle kernel paging request at ffffea0003480008
[ 2957.088008] IP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
[ 2957.088024] PGD 7fffc6067 PUD 7fffc5067 PMD 0
[ 2957.088041] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2957.088087] Dumping ftrace buffer:
[ 2957.088266]    (ftrace buffer empty)
[ 2957.088279] Modules linked in:
[ 2957.088293] CPU: 2 PID: 15417 Comm: trinity-c200 Not tainted 3.16.0-rc7-next-20140801-sasha-00047-gd6ce559 #990
[ 2957.088301] task: ffff8807a8c50000 ti: ffff880739fb4000 task.ti: ffff880739fb4000
[ 2957.088320] RIP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
[ 2957.088328] RSP: 0018:ffff880739fb7c58  EFLAGS: 00010246
[ 2957.088336] RAX: 0000000000000000 RBX: ffff880eb2bdbed8 RCX: dfff971b42800000
[ 2957.088343] RDX: 1ffff100e73f6fc4 RSI: 00007f00e85db000 RDI: ffffea0003480008
[ 2957.088350] RBP: ffff880739fb7d58 R08: 0000000000000001 R09: 0000000000b6e000
[ 2957.088357] R10: 0000000000000000 R11: 0000000000000001 R12: ffffea0003480000
[ 2957.088365] R13: 00000000d2000700 R14: 00007f00e85dc000 R15: 00007f00e85db000
[ 2957.088374] FS:  00007f00e85d8700(0000) GS:ffff88177fa00000(0000) knlGS:0000000000000000
[ 2957.088381] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2957.088387] CR2: ffffea0003480008 CR3: 00000007a802a000 CR4: 00000000000006a0
[ 2957.088406] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2957.088413] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 2957.088416] Stack:
[ 2957.088432]  ffff88171726d570 0000000000000010 0000000000000008 00000000d2000730
[ 2957.088450]  0000000019d00250 00007f00e85dc000 ffff880f9d311900 ffff880739fb7e20
[ 2957.088466]  ffff8807a8c507a0 ffff8807a8c50000 ffff8807a75fe000 ffff8807ceaa7a10
[ 2957.088469] Call Trace:
[ 2957.088490] unmap_single_vma (mm/memory.c:1348)
[ 2957.088505] unmap_vmas (mm/memory.c:1375 (discriminator 3))
[ 2957.088520] unmap_region (mm/mmap.c:2386 (discriminator 4))
[ 2957.088542] ? vma_rb_erase (mm/mmap.c:454 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:493)
[ 2957.088559] ? vmacache_update (mm/vmacache.c:61)
[ 2957.088572] do_munmap (mm/mmap.c:2581)
[ 2957.088583] vm_munmap (mm/mmap.c:2596)
[ 2957.088595] SyS_munmap (mm/mmap.c:2601)
[ 2957.088616] tracesys (arch/x86/kernel/entry_64.S:541)
[ 2957.088770] Code: ff ff e8 f9 5f 07 00 48 8b 45 90 80 48 18 01 4d 85 e4 0f 84 8b fe ff ff 45 84 ed 0f 85 fc 03 00 00 49 8d 7c 24 08 e8 b5 67 07 00 <41> f6 44 24 08 01 0f 84 29 02 00 00 83 6d c8 01 4c 89 e7 e8 bd
All code
========
   0:	ff                   	(bad)
   1:	ff e8                	ljmpq  *<internal disassembler error>
   3:	f9                   	stc
   4:	5f                   	pop    %rdi
   5:	07                   	(bad)
   6:	00 48 8b             	add    %cl,-0x75(%rax)
   9:	45 90                	rex.RB xchg %eax,%r8d
   b:	80 48 18 01          	orb    $0x1,0x18(%rax)
   f:	4d 85 e4             	test   %r12,%r12
  12:	0f 84 8b fe ff ff    	je     0xfffffffffffffea3
  18:	45 84 ed             	test   %r13b,%r13b
  1b:	0f 85 fc 03 00 00    	jne    0x41d
  21:	49 8d 7c 24 08       	lea    0x8(%r12),%rdi
  26:	e8 b5 67 07 00       	callq  0x767e0
  2b:*	41 f6 44 24 08 01    	testb  $0x1,0x8(%r12)		<-- trapping instruction
  31:	0f 84 29 02 00 00    	je     0x260
  37:	83 6d c8 01          	subl   $0x1,-0x38(%rbp)
  3b:	4c 89 e7             	mov    %r12,%rdi
  3e:	e8                   	.byte 0xe8
  3f:	bd                   	.byte 0xbd
	...

Code starting with the faulting instruction
===========================================
   0:	41 f6 44 24 08 01    	testb  $0x1,0x8(%r12)
   6:	0f 84 29 02 00 00    	je     0x235
   c:	83 6d c8 01          	subl   $0x1,-0x38(%rbp)
  10:	4c 89 e7             	mov    %r12,%rdi
  13:	e8                   	.byte 0xe8
  14:	bd                   	.byte 0xbd
	...
[ 2957.088784] RIP unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
[ 2957.088789]  RSP <ffff880739fb7c58>
[ 2957.088794] CR2: ffffea0003480008


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
