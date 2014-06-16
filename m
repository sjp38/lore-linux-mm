Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 815926B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 17:15:07 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id q200so4661483ykb.0
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 14:15:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o3si19323888yhm.150.2014.06.16.14.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 14:15:06 -0700 (PDT)
Message-ID: <539F5E4B.3090302@oracle.com>
Date: Mon, 16 Jun 2014 17:14:51 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mincore: apply page table walker on do_mincore()
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-8-git-send-email-n-horiguchi@ah.jp.nec.com> <539F0C20.10101@oracle.com> <20140616164449.GB13264@nhori.bos.redhat.com>
In-Reply-To: <20140616164449.GB13264@nhori.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>

On 06/16/2014 12:44 PM, Naoya Horiguchi wrote:
> Hi Sasha,
> 
> Thanks for bug reporting.
> 
> On Mon, Jun 16, 2014 at 11:24:16AM -0400, Sasha Levin wrote:
>> On 06/06/2014 06:58 PM, Naoya Horiguchi wrote:
>>> This patch makes do_mincore() use walk_page_vma(), which reduces many lines
>>> of code by using common page table walk code.
>>>
>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> Hi Naoya,
>>
>> This patch is causing a few issues on -next:
>>
>> [  367.679282] BUG: sleeping function called from invalid context at mm/mincore.c:37
> 
> cond_resched() in mincore_hugetlb() triggered this. This is done in common
> pagewalk code, so I should have removed it.
> 
> ...
>> And:
>>
>> [  391.118663] BUG: unable to handle kernel paging request at ffff880142aca000
>> [  391.118663] IP: mincore_hole (mm/mincore.c:99 (discriminator 2))
> 
> walk->pte_hole cannot assume walk->vma != NULL, so I should've checked it
> in mincore_hole() before using walk->vma.
> 
> Could you try the following fixes?

That solved those two, but I'm seeing new ones:

[  650.352956] BUG: unable to handle kernel paging request at ffff8802fdf03000
[  650.352956] IP: mincore_hole (mm/mincore.c:101 (discriminator 2))
[  650.352956] PGD 23bcd067 PUD 704b48067 PMD 704958067 PTE 80000002fdf03060
[  650.352956] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  650.352956] Dumping ftrace buffer:
[  650.352956]    (ftrace buffer empty)
[  650.352956] Modules linked in:
[  650.352956] CPU: 12 PID: 15403 Comm: trinity-c363 Tainted: G        W     3.15.0-next-20140616-sasha-00025-g0fd1f7d-dirty #657
[  650.352956] task: ffff88027caf3000 ti: ffff880279d5c000 task.ti: ffff880279d5c000
[  650.352956] RIP: mincore_hole (mm/mincore.c:101 (discriminator 2))
[  650.352956] RSP: 0018:ffff880279d5fd48  EFLAGS: 00010202
[  650.352956] RAX: 0000000000000001 RBX: 00007f2445400000 RCX: 0000000000000000
[  650.352956] RDX: 0000000000000000 RSI: 00007f2445400000 RDI: 00007f2445200000
[  650.352956] RBP: ffff880279d5fd88 R08: 0000000000000001 R09: ffff880000000100
[  650.352956] R10: 0000000000000001 R11: 00007f2444126000 R12: 00007f2480000000
[  650.352956] R13: ffff8802fdf03000 R14: 0000000000000200 R15: ffff8804e32f2000
[  650.352956] FS:  00007f24899ec700(0000) GS:ffff8802ff000000(0000) knlGS:0000000000000000
[  650.352956] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  650.352956] CR2: ffff8802fdf03000 CR3: 000000027c39b000 CR4: 00000000000006a0
[  650.352956] DR0: 00000000006df000 DR1: 0000000000000000 DR2: 0000000000000000
[  650.352956] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  650.352956] Stack:
[  650.352956]  ffff880279d5fef0 0000000000000000 0000000000000000 00007f2445400000
[  650.352956]  00007f2480000000 ffff880279d5fef0 00007f2445200000 ffff8804e30fd148
[  650.352956]  ffff880279d5fe38 ffffffff9c2d1c4d ffff880200000000 ffffffff9c1a0038
[  650.352956] Call Trace:
[  650.352956] walk_pgd_range (mm/pagewalk.c:73 mm/pagewalk.c:141 mm/pagewalk.c:170)
[  650.352956] ? preempt_count_sub (kernel/sched/core.c:2602)
[  650.352956] __walk_page_range (mm/pagewalk.c:264)
[  650.352956] ? SyS_mincore (mm/mincore.c:160 mm/mincore.c:244 mm/mincore.c:212)
[  650.352956] walk_page_vma (mm/pagewalk.c:376)
[  650.352956] SyS_mincore (mm/mincore.c:177 mm/mincore.c:244 mm/mincore.c:212)
[  650.352956] ? mincore_hugetlb (mm/mincore.c:143)
[  650.352956] ? mincore_hole (mm/mincore.c:109)
[  650.352956] ? mincore_page (mm/mincore.c:87)
[  650.352956] ? copy_page_range (mm/mincore.c:24)
[  650.352956] tracesys (arch/x86/kernel/entry_64.S:542)
[ 650.352956] Code: 87 a0 00 00 00 48 83 c3 01 48 8b b8 f8 01 00 00 e8 ab fe ff ff 48 8b 55 c8 88 02 49 63 c4 49 39 c6 77 cd eb 14 0f 1f 00 83 c0 01 <41> c6 44 15 00 00 48 63 d0 49 39 d6 77 ef 48 8b 55 c0 4c 8b 6a
All code
========
   0:	87 a0 00 00 00 48    	xchg   %esp,0x48000000(%rax)
   6:	83 c3 01             	add    $0x1,%ebx
   9:	48 8b b8 f8 01 00 00 	mov    0x1f8(%rax),%rdi
  10:	e8 ab fe ff ff       	callq  0xfffffffffffffec0
  15:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  19:	88 02                	mov    %al,(%rdx)
  1b:	49 63 c4             	movslq %r12d,%rax
  1e:	49 39 c6             	cmp    %rax,%r14
  21:	77 cd                	ja     0xfffffffffffffff0
  23:	eb 14                	jmp    0x39
  25:	0f 1f 00             	nopl   (%rax)
  28:	83 c0 01             	add    $0x1,%eax
  2b:*	41 c6 44 15 00 00    	movb   $0x0,0x0(%r13,%rdx,1)		<-- trapping instruction
  31:	48 63 d0             	movslq %eax,%rdx
  34:	49 39 d6             	cmp    %rdx,%r14
  37:	77 ef                	ja     0x28
  39:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  3d:	4c 8b 6a 00          	mov    0x0(%rdx),%r13

Code starting with the faulting instruction
===========================================
   0:	41 c6 44 15 00 00    	movb   $0x0,0x0(%r13,%rdx,1)
   6:	48 63 d0             	movslq %eax,%rdx
   9:	49 39 d6             	cmp    %rdx,%r14
   c:	77 ef                	ja     0xfffffffffffffffd
   e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  12:	4c 8b 6a 00          	mov    0x0(%rdx),%r13
[  650.352956] RIP mincore_hole (mm/mincore.c:101 (discriminator 2))
[  650.352956]  RSP <ffff880279d5fd48>
[  650.352956] CR2: ffff8802fdf03000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
