Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 332436B004D
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:02:38 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so9407156pab.27
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:02:37 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id r1si29657569pdl.121.2014.09.10.16.02.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 16:02:37 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so8577637pab.17
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:02:36 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:00:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG in unmap_page_range
In-Reply-To: <5410B641.1080504@oracle.com>
Message-ID: <alpine.LSU.2.11.1409101541430.3374@eggly.anvils>
References: <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com> <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com>
 <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <54104E24.5010402@oracle.com>
 <alpine.LSU.2.11.1409101148290.1262@eggly.anvils> <5410B641.1080504@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Wed, 10 Sep 2014, Sasha Levin wrote:
> On 09/10/2014 03:09 PM, Hugh Dickins wrote:
> > Thanks for supplying, but the change in inlining means that
> > change_protection_range() and change_protection() are no longer
> > relevant for these traces, we now need to see change_pte_range()
> > instead, to confirm that what I expect are ptes are indeed ptes.
> > 
> > If you can include line numbers (objdump -ld) in the disassembly, so
> > much the better, but should be decipherable without.  (Or objdump -Sd
> > for source, but I often find that harder to unscramble, can't say why.)
> 
> Here it is. Note that the source includes both of Mel's debug patches.
> For reference, here's one trace of the issue with those patches:
> 
> [ 3114.540976] kernel BUG at include/asm-generic/pgtable.h:724!
> [ 3114.541857] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 3114.543112] Dumping ftrace buffer:
> [ 3114.544056]    (ftrace buffer empty)
> [ 3114.545000] Modules linked in:
> [ 3114.545717] CPU: 18 PID: 30217 Comm: trinity-c617 Tainted: G        W      3.17.0-rc4-next-20140910-sasha-00032-g6825fb5-dirty #1137
> [ 3114.548058] task: ffff880415050000 ti: ffff88076f584000 task.ti: ffff88076f584000
> [ 3114.549284] RIP: 0010:[<ffffffff952e527a>]  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
> [ 3114.550028] RSP: 0000:ffff88076f587d68  EFLAGS: 00010246
> [ 3114.550028] RAX: 0000000314625900 RBX: 0000000041218000 RCX: 0000000000000100
> [ 3114.550028] RDX: 0000000314625900 RSI: 0000000041218000 RDI: 0000000314625900
> [ 3114.550028] RBP: ffff88076f587dc8 R08: ffff8802cf973600 R09: 0000000000b50000
> [ 3114.550028] R10: 0000000000032c01 R11: 0000000000000008 R12: ffff8802a81070c0
> [ 3114.550028] R13: 8000000000000025 R14: 0000000041343000 R15: ffffc00000000fff
> [ 3114.550028] FS:  00007fabb91c8700(0000) GS:ffff88025ec00000(0000) knlGS:0000000000000000
> [ 3114.550028] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 3114.550028] CR2: 00007fffdb7678e8 CR3: 0000000713935000 CR4: 00000000000006a0
> [ 3114.550028] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 3114.550028] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000050602
> [ 3114.550028] Stack:
> [ 3114.550028]  0000000000000001 0000000314625900 0000000000000018 ffff8802685f2260
> [ 3114.550028]  0000000016840000 ffff8802cf973600 ffff880616840000 0000000041343000
> [ 3114.550028]  ffff880108805048 0000000041005000 0000000041200000 0000000041343000
> [ 3114.550028] Call Trace:
> [ 3114.550028]  [<ffffffff952e5534>] change_protection+0x2b4/0x4e0
> [ 3114.550028]  [<ffffffff952ff24b>] change_prot_numa+0x1b/0x40
> [ 3114.550028]  [<ffffffff951adf16>] task_numa_work+0x1f6/0x330
> [ 3114.550028]  [<ffffffff95193de4>] task_work_run+0xc4/0xf0
> [ 3114.550028]  [<ffffffff95071477>] do_notify_resume+0x97/0xb0
> [ 3114.550028]  [<ffffffff9850f06a>] int_signal+0x12/0x17
> [ 3114.550028] Code: 66 90 48 8b 7d b8 e8 e6 88 22 03 48 8b 45 b0 e9 6f ff ff ff 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b <0f> 0b 0f 0b 0f 0b 66 66 66 66 90 55 48 89 e5 41 57 49 89 d7 41
> [ 3114.550028] RIP  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
> [ 3114.550028]  RSP <ffff88076f587d68>
> 
> And the disassembly:
...
> /home/sasha/linux-next/mm/mprotect.c:105
>  31d:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
>  321:	81 e1 01 03 00 00    	and    $0x301,%ecx
>  327:	48 81 f9 00 02 00 00 	cmp    $0x200,%rcx
>  32e:	0f 84 0b ff ff ff    	je     23f <change_pte_range+0x23f>
> pte_val():
> /home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
>  334:	48 83 3d 00 00 00 00 	cmpq   $0x0,0x0(%rip)        # 33c <change_pte_range+0x33c>
>  33b:	00
> 			337: R_X86_64_PC32	pv_mmu_ops+0xe3
> ptep_set_numa():
> /home/sasha/linux-next/include/asm-generic/pgtable.h:740
>  33c:	49 8b 3c 24          	mov    (%r12),%rdi
> pte_val():
> /home/sasha/linux-next/./arch/x86/include/asm/paravirt.h:450
>  340:	0f 84 12 01 00 00    	je     458 <change_pte_range+0x458>
>  346:	ff 14 25 00 00 00 00 	callq  *0x0
> 			349: R_X86_64_32S	pv_mmu_ops+0xe8
> pte_mknuma():
> /home/sasha/linux-next/include/asm-generic/pgtable.h:724
>  34d:	a8 01                	test   $0x1,%al
>  34f:	0f 84 95 01 00 00    	je     4ea <change_pte_range+0x4ea>
...
> ptep_set_numa():
> /home/sasha/linux-next/include/asm-generic/pgtable.h:724
>  4ea:	0f 0b                	ud2

Thanks, yes, there is enough in there to be sure that the ...900 is
indeed the oldpte.  I wasn't expecting that pv_mmu_ops function call,
but there's no evidence that it does anything worse than just return
in %rax what it's given in %rdi; and the second long on the stack is
the -0x58(%rbp) from which oldpte is retrieved for !pte_numa(oldpte)
at the beginning of the extract above.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
