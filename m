Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 93F7C6B0036
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 02:01:12 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so4134389pbc.12
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 23:01:12 -0700 (PDT)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id cc2si12717252pbb.208.2014.06.26.23.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 23:01:11 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so4142576pbc.20
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 23:01:11 -0700 (PDT)
Date: Thu, 26 Jun 2014 22:59:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shm: hang in shmem_fallocate
In-Reply-To: <53AC383F.3010007@oracle.com>
Message-ID: <alpine.LSU.2.11.1406262236370.27670@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz>
 <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53AC383F.3010007@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 26 Jun 2014, Sasha Levin wrote:
> On 06/25/2014 06:36 PM, Hugh Dickins wrote:
> > Sasha, may I trespass on your time, and ask you to revert the previous
> > patch from your tree, and give this patch below a try?  I am very
> > interested to learn if in fact it fixes it for you (as it did for me).
> 
> Hi Hugh,
> 
> Happy to help,

Thank you!  Though Vlastimil has made it clear that we cannot go
forward with that one-liner patch, so I've just proposed another.

> and as I often do I will answer with a question.
> 
> I've observed two different issues after reverting the original fix and
> applying this new patch. Both of them seem semi-related, but I'm not sure.

I've rather concentrated on putting the new patch together, and just
haven't had time to give these two much thought - nor shall tomorrow,
I'm afraid.

> 
> First, this:
> 
> [  681.267487] BUG: unable to handle kernel paging request at ffffea0003480048
> [  681.268621] IP: zap_pte_range (mm/memory.c:1132)

Weird, I don't think we've seen anything like that before, have we?
I'm pretty sure it's not a consequence of my "index = min(index, end)",
but what it portends I don't know.  Please confirm mm/memory.c:1132 -
that's the "if (PageAnon(page))" line, isn't it?  Which indeed matches
the code below.  So accessing page->mapping is causing an oops...

> [  681.269335] PGD 37fcc067 PUD 37fcb067 PMD 0
> [  681.269972] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  681.270952] Dumping ftrace buffer:
> [  681.270952]    (ftrace buffer empty)
> [  681.270952] Modules linked in:
> [  681.270952] CPU: 7 PID: 1952 Comm: trinity-c29 Not tainted 3.16.0-rc2-next-20140625-s
> asha-00025-g2e02e05-dirty #730
> [  681.270952] task: ffff8803e6f58000 ti: ffff8803df050000 task.ti: ffff8803df050000
> [  681.270952] RIP: zap_pte_range (mm/memory.c:1132)
> [  681.270952] RSP: 0018:ffff8803df053c58  EFLAGS: 00010246
> [  681.270952] RAX: ffffea0003480040 RBX: ffff8803edae7a70 RCX: 0000000003480040
> [  681.270952] RDX: 00000000d2001730 RSI: 0000000000000000 RDI: 00000000d2001730
> [  681.270952] RBP: ffff8803df053cf8 R08: ffff88000015cc00 R09: 0000000000000000
> [  681.270952] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0003480040
> [  681.270952] R13: ffff8803df053de8 R14: 00007fc15014f000 R15: 00007fc15014e000
> [  681.270952] FS:  00007fc15031b700(0000) GS:ffff8801ece00000(0000) knlGS:0000000000000
> 000
> [  681.270952] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  681.270952] CR2: ffffea0003480048 CR3: 000000001a02e000 CR4: 00000000000006a0
> [  681.270952] Stack:
> [  681.270952]  ffff8803df053de8 00000000d2001000 00000000d2001fff ffff8803e6f58000
> [  681.270952]  0000000000000000 0000000000000001 ffff880404dd8400 ffff8803e6e31900
> [  681.270952]  00000000d2001730 ffff88000015cc00 0000000000000000 ffff8804078f8000
> [  681.270952] Call Trace:
> [  681.270952] unmap_single_vma (mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301 mm/m
> emory.c:1346)
> [  681.270952] unmap_vmas (mm/memory.c:1375 (discriminator 1))
> [  681.270952] exit_mmap (mm/mmap.c:2797)
> [  681.270952] ? preempt_count_sub (kernel/sched/core.c:2606)
> [  681.270952] mmput (kernel/fork.c:638)
> [  681.270952] do_exit (kernel/exit.c:744)
> [  681.270952] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  681.270952] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/
> lockdep.c:2599)
> [  681.270952] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
> [  681.270952] do_group_exit (kernel/exit.c:884)
> [  681.270952] SyS_exit_group (kernel/exit.c:895)
> [  681.270952] tracesys (arch/x86/kernel/entry_64.S:542)
> [ 681.270952] Code: e8 cf 39 25 03 49 8b 4c 24 10 48 39 c8 74 1c 48 8b 7d b8 48 c1 e1 0c
>  48 89 da 48 83 c9 40 4c 89 fe e8 e5 db ff ff 0f 1f 44 00 00 <41> f6 44 24 08 01 74 08 83 6d c8 01 eb 33 66 90 f6 45 a0 40 74
> All code
> ========
>    0:   e8 cf 39 25 03          callq  0x32539d4
>    5:   49 8b 4c 24 10          mov    0x10(%r12),%rcx
>    a:   48 39 c8                cmp    %rcx,%rax
>    d:   74 1c                   je     0x2b
>    f:   48 8b 7d b8             mov    -0x48(%rbp),%rdi
>   13:   48 c1 e1 0c             shl    $0xc,%rcx
>   17:   48 89 da                mov    %rbx,%rdx
>   1a:   48 83 c9 40             or     $0x40,%rcx
>   1e:   4c 89 fe                mov    %r15,%rsi
>   21:   e8 e5 db ff ff          callq  0xffffffffffffdc0b
>   26:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
>   2b:*  41 f6 44 24 08 01       testb  $0x1,0x8(%r12)           <-- trapping instruction
>   31:   74 08                   je     0x3b
>   33:   83 6d c8 01             subl   $0x1,-0x38(%rbp)
>   37:   eb 33                   jmp    0x6c
>   39:   66 90                   xchg   %ax,%ax
>   3b:   f6 45 a0 40             testb  $0x40,-0x60(%rbp)
>   3f:   74 00                   je     0x41
> 
> Code starting with the faulting instruction
> ===========================================
>    0:   41 f6 44 24 08 01       testb  $0x1,0x8(%r12)
>    6:   74 08                   je     0x10
>    8:   83 6d c8 01             subl   $0x1,-0x38(%rbp)
>    c:   eb 33                   jmp    0x41
>    e:   66 90                   xchg   %ax,%ax
>   10:   f6 45 a0 40             testb  $0x40,-0x60(%rbp)
>   14:   74 00                   je     0x16
> [  681.270952] RIP zap_pte_range (mm/memory.c:1132)
> [  681.270952]  RSP <ffff8803df053c58>
> [  681.270952] CR2: ffffea0003480048
> 
> And a longer lockup that shows a few shmem_fallocate hanging, but they don't seem to be
> the main reason for the hang (log it pretty long, attached).

I wandered through the log you attached, but didn't have much idea of
what I should look for, and set it aside to get on with other things.

I think it was just confirming what Vlastimil indicated, that the
one-liner patch is not good enough: lots of hole-punches waiting
their turn for i_mutex, though I didn't see as many corresponding
faults into those holes as perhaps I expected.

Your mm/memory.c:1132 is more intriguing, but right now I can't
afford to get very intrigued by it!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
