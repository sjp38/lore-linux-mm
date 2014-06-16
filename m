Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 480506B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 11:24:27 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id z6so4473292yhz.28
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 08:24:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t6si17938276yhk.136.2014.06.16.08.24.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 08:24:26 -0700 (PDT)
Message-ID: <539F0C20.10101@oracle.com>
Date: Mon, 16 Jun 2014 11:24:16 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mincore: apply page table walker on do_mincore()
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>

On 06/06/2014 06:58 PM, Naoya Horiguchi wrote:
> This patch makes do_mincore() use walk_page_vma(), which reduces many lines
> of code by using common page table walk code.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi Naoya,

This patch is causing a few issues on -next:

[  367.679282] BUG: sleeping function called from invalid context at mm/mincore.c:37
[  367.683618] in_atomic(): 1, irqs_disabled(): 0, pid: 10386, name: trinity-c13
[  367.686236] 2 locks held by trinity-c13/10386:
[  367.688006] #0: (&mm->mmap_sem){++++++}, at: SyS_mincore (mm/mincore.c:161 mm/mincore.c:245 mm/mincore.c:213)
[  367.693232] #1: (&(ptlock_ptr(page))->rlock){+.+.-.}, at: __walk_page_range (mm/pagewalk.c:209 mm/pagewalk.c:262)
[  367.698436] Preemption disabled __walk_page_range (mm/pagewalk.c:209 mm/pagewalk.c:262)
[  367.700421]
[  367.700803] CPU: 13 PID: 10386 Comm: trinity-c13 Not tainted 3.15.0-next-20140616-sasha-00025-g0fd1f7d #655
[  367.703605]  ffff88010bd08000 ffff88010bddbdd8 ffffffffb7514111 0000000000000002
[  367.706819]  0000000000000000 ffff88010bddbe08 ffffffffb419ca64 ffff8801b209dc38
[  367.710416]  00007fcc85400000 0000000000000000 ffff88010bddbef0 ffff88010bddbe38
[  367.713101] Call Trace:
[  367.714248] dump_stack (lib/dump_stack.c:52)
[  367.716428] __might_sleep (kernel/sched/core.c:7080)
[  367.723608] mincore_hugetlb (mm/mincore.c:37)
[  367.725609] ? __walk_page_range (mm/pagewalk.c:209 mm/pagewalk.c:262)
[  367.727712] __walk_page_range (include/linux/spinlock.h:343 mm/pagewalk.c:211 mm/pagewalk.c:262)
[  367.729098] walk_page_vma (mm/pagewalk.c:376)
[  367.731343] SyS_mincore (mm/mincore.c:178 mm/mincore.c:245 mm/mincore.c:213)
[  367.733621] ? mincore_hugetlb (mm/mincore.c:144)
[  367.735712] ? mincore_hole (mm/mincore.c:110)
[  367.737022] ? mincore_page (mm/mincore.c:88)
[  367.739416] ? copy_page_range (mm/mincore.c:24)
[  367.741634] tracesys (arch/x86/kernel/entry_64.S:542)

And:

[  391.118663] BUG: unable to handle kernel paging request at ffff880142aca000
[  391.118663] IP: mincore_hole (mm/mincore.c:99 (discriminator 2))
[  391.118663] PGD 3bbcd067 PUD 70574e067 PMD 705738067 PTE 8000000142aca060
[  391.118663] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  391.118663] Dumping ftrace buffer:
[  391.118663]    (ftrace buffer empty)
[  391.118663] Modules linked in:
[  391.118663] CPU: 4 PID: 9695 Comm: trinity-c566 Not tainted 3.15.0-next-20140616-sasha-00025-g0fd1f7d #655
[  391.118663] task: ffff880044a5b000 ti: ffff880044adc000 task.ti: ffff880044adc000
[  391.118663] RIP: mincore_hole (mm/mincore.c:99 (discriminator 2))
[  391.118663] RSP: 0000:ffff880044adfd48  EFLAGS: 00010246
[  391.118663] RAX: 0000000000000000 RBX: 0000000000007137 RCX: 0000005b107d3134
[  391.118663] RDX: 0000000000000001 RSI: ffffffffb4b2dbe8 RDI: 0000000000000000
[  391.118663] RBP: ffff880044adfd88 R08: 00000000000163fc R09: 0000000000000000
[  391.118663] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000200
[  391.118663] R13: ffff880142aca000 R14: ffff8800cadc0000 R15: 0000000000000001
[  391.118663] FS:  00007fcc8afe0700(0000) GS:ffff880144e00000(0000) knlGS:0000000000000000
[  391.118663] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  391.118663] CR2: ffff880142aca000 CR3: 0000000044a76000 CR4: 00000000000006a0
[  391.118663] Stack:
[  391.118663]  ffff880044adfef0 ffff880142aca000 0000000000000000 00007fcc46a00000
[  391.118663]  00007fcc4baee000 ffff880044adfef0 00007fcc46800000 ffff8800cad251a0
[  391.118663]  ffff880044adfe38 ffffffffb42d1c8d ffff880000000000 ffffffffb41a0038
[  391.118663] Call Trace:
[  391.118663] walk_pgd_range (mm/pagewalk.c:73 mm/pagewalk.c:141 mm/pagewalk.c:170)
[  391.118663] ? preempt_count_sub (kernel/sched/core.c:2602)
[  391.118663] __walk_page_range (mm/pagewalk.c:264)
[  391.118663] ? SyS_mincore (mm/mincore.c:161 mm/mincore.c:245 mm/mincore.c:213)
[  391.118663] walk_page_vma (mm/pagewalk.c:376)
[  391.118663] SyS_mincore (mm/mincore.c:178 mm/mincore.c:245 mm/mincore.c:213)
[  391.118663] ? mincore_hugetlb (mm/mincore.c:144)
[  391.118663] ? mincore_hole (mm/mincore.c:110)
[  391.118663] ? mincore_page (mm/mincore.c:88)
[  391.118663] ? copy_page_range (mm/mincore.c:24)
[  391.118663] tracesys (arch/x86/kernel/entry_64.S:542)
[ 391.118663] Code: 4d 85 e4 74 57 0f 1f 40 00 49 8b 86 a0 00 00 00 48 89 de 41 83 c7 01 4c 03 6d c8 48 83 c3 01 48 8b b8 f8 01 00 00 e8 ae fe ff ff <41> 88 45 00 4d 63 ef 4d 39 ec 77 d2 48 8b 4d c0 48 8b 49 50 48
All code
========
   0:	4d 85 e4             	test   %r12,%r12
   3:	74 57                	je     0x5c
   5:	0f 1f 40 00          	nopl   0x0(%rax)
   9:	49 8b 86 a0 00 00 00 	mov    0xa0(%r14),%rax
  10:	48 89 de             	mov    %rbx,%rsi
  13:	41 83 c7 01          	add    $0x1,%r15d
  17:	4c 03 6d c8          	add    -0x38(%rbp),%r13
  1b:	48 83 c3 01          	add    $0x1,%rbx
  1f:	48 8b b8 f8 01 00 00 	mov    0x1f8(%rax),%rdi
  26:	e8 ae fe ff ff       	callq  0xfffffffffffffed9
  2b:*	41 88 45 00          	mov    %al,0x0(%r13)		<-- trapping instruction
  2f:	4d 63 ef             	movslq %r15d,%r13
  32:	4d 39 ec             	cmp    %r13,%r12
  35:	77 d2                	ja     0x9
  37:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  3b:	48 8b 49 50          	mov    0x50(%rcx),%rcx
  3f:	48                   	rex.W
	...

Code starting with the faulting instruction
===========================================
   0:	41 88 45 00          	mov    %al,0x0(%r13)
   4:	4d 63 ef             	movslq %r15d,%r13
   7:	4d 39 ec             	cmp    %r13,%r12
   a:	77 d2                	ja     0xffffffffffffffde
   c:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  10:	48 8b 49 50          	mov    0x50(%rcx),%rcx
  14:	48                   	rex.W
	...
[  391.118663] RIP mincore_hole (mm/mincore.c:99 (discriminator 2))
[  391.118663]  RSP <ffff880044adfd48>
[  391.118663] CR2: ffff880142aca000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
