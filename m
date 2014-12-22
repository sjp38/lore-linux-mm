Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id B289B6B0071
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 13:01:14 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id f15so4714082lbj.27
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 10:01:13 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id y9si19141222lal.110.2014.12.22.10.01.12
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 10:01:12 -0800 (PST)
Date: Mon, 22 Dec 2014 20:01:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
Message-ID: <20141222180102.GA8072@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <549832E2.8060609@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Davidlohr Bueso <davidlohr@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:
> 
> [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)

Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
under us?

I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
path which could lead to the crash.

I've noticed one strange code path, which probably is not related to the
issue:

unmap_mapping_range()
  i_mmap_lock_read(mapping);
  unmap_mapping_range_tree()
    unmap_mapping_range_vma()
      zap_page_range_single()
        unmap_single_vma()
	  if (unlikely(is_vm_hugetlb_page(vma))) {
	    i_mmap_lock_write(vma->vm_file->f_mapping);

Is it legal to down_write() semaphore while we have it taken on read?
It must be the same mapping, right?

> [  432.380085] PGD 57e5e0067 PUD 57e5e1067 PMD 0
> [  432.380085] Oops: 0002 [#1] PREEMPT SMP KASAN
> [  432.380085] Dumping ftrace buffer:
> [  432.380085]    (ftrace buffer empty)
> [  432.380085] Modules linked in:
> [  432.380085] CPU: 4 PID: 9249 Comm: trinity-subchil Not tainted 3.18.0-next-20141219-sasha-00047-gaab33f6-dirty #1627
> [  432.380085] task: ffff8806a88c8000 ti: ffff880664f3c000 task.ti: ffff880664f3c000
> [  432.380085] RIP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> [  432.380085] RSP: 0018:ffff880664f3fc98  EFLAGS: 00010292
> [  432.380085] RAX: 0000000000000038 RBX: ffff880101aa7c00 RCX: 1ffff10020354f8f
> [  432.380085] RDX: ffffffff00000001 RSI: 1ffff100fe326200 RDI: 0000000000000038
> [  432.380085] RBP: ffff880664f3fcb8 R08: 0000000000000000 R09: ffff880101aa6258
> [  432.380085] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880000025900
> [  432.380085] R13: 0000000000000038 R14: 0000000000000000 R15: ffff880101aa7c00
> [  432.380085] FS:  00007f21149c4700(0000) GS:ffff880216400000(0000) knlGS:0000000000000000
> [  432.380085] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  432.380085] CR2: 0000000000000038 CR3: 000000057a4f3000 CR4: 00000000000006a0
> [  432.380085] Stack:
> [  432.380085]  ffff880101aa7c00 ffff880101aa7c78 ffff880101aa6200 ffff880101aa7c00
> [  432.380085]  ffff880664f3fce8 ffffffffa1953e9d[  432.400920] CONFIG_KASAN_INLINE enabled
> [  432.400923] GPF could be caused by NULL-ptr deref or user memory access
> 
> [  432.402566]  ffff880101aa7c00 00007f210f9f3000
> [  432.402566]  dfffe90000000000 ffff880101aa4600 ffff880664f3fd48 ffffffffa1937821
> [  432.402566] Call Trace:
> [  432.402566] unlink_file_vma (mm/mmap.c:264)
> [  432.402566] free_pgtables (mm/memory.c:548)
> [  432.402566] exit_mmap (mm/mmap.c:2846)
> [  432.402566] ? kmem_cache_free (mm/slub.c:2712 mm/slub.c:2721)
> [  432.402566] mmput (kernel/fork.c:659)
> [  432.402566] do_exit (./arch/x86/include/asm/thread_info.h:164 kernel/exit.c:438 kernel/exit.c:732)
> [  432.402566] ? preempt_count_sub (kernel/sched/core.c:2620)
> [  432.402566] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  432.402566] do_group_exit (include/linux/sched.h:775 kernel/exit.c:858)
> [  432.402566] SyS_exit_group (kernel/exit.c:886)
> [  432.402566] system_call_fastpath (arch/x86/kernel/entry_64.S:423)
> [ 432.402566] Code: 79 05 e8 f9 e9 a6 f2 5d c3 0f 1f 80 00 00 00 00 66 66 66 66 90 48 ba 01 00 00 00 ff ff ff ff 55 48 89 f8 48 89 e5 53 48 83 ec 18 <f0> 48 0f c1 10 85 d2 74 05 e8 f7 e9 a6 f2 65 48 8b 1c 25 80 b9
> All code
> ========
>    0:	79 05                	jns    0x7
>    2:	e8 f9 e9 a6 f2       	callq  0xfffffffff2a6ea00
>    7:	5d                   	pop    %rbp
>    8:	c3                   	retq
>    9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
>   10:	66 66 66 66 90       	data32 data32 data32 xchg %ax,%ax
>   15:	48 ba 01 00 00 00 ff 	movabs $0xffffffff00000001,%rdx
>   1c:	ff ff ff
>   1f:	55                   	push   %rbp
>   20:	48 89 f8             	mov    %rdi,%rax
>   23:	48 89 e5             	mov    %rsp,%rbp
>   26:	53                   	push   %rbx
>   27:	48 83 ec 18          	sub    $0x18,%rsp
>   2b:*	f0 48 0f c1 10       	lock xadd %rdx,(%rax)		<-- trapping instruction
>   30:	85 d2                	test   %edx,%edx
>   32:	74 05                	je     0x39
>   34:	e8 f7 e9 a6 f2       	callq  0xfffffffff2a6ea30
>   39:	65                   	gs
>   3a:	48                   	rex.W
>   3b:	8b                   	.byte 0x8b
>   3c:	1c 25                	sbb    $0x25,%al
>   3e:	80                   	.byte 0x80
>   3f:	b9                   	.byte 0xb9
> 	...
> 
> Code starting with the faulting instruction
> ===========================================
>    0:	f0 48 0f c1 10       	lock xadd %rdx,(%rax)
>    5:	85 d2                	test   %edx,%edx
>    7:	74 05                	je     0xe
>    9:	e8 f7 e9 a6 f2       	callq  0xfffffffff2a6ea05
>    e:	65                   	gs
>    f:	48                   	rex.W
>   10:	8b                   	.byte 0x8b
>   11:	1c 25                	sbb    $0x25,%al
>   13:	80                   	.byte 0x80
>   14:	b9                   	.byte 0xb9
> 	...
> [  432.402566] RIP down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> [  432.402566]  RSP <ffff880664f3fc98>
> [  432.402566] CR2: 0000000000000038
> 
> 
> Thanks,
> Sasha
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
