Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAEE76B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 14:06:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so44113790wmz.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:06:18 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id 1si9379882lfi.195.2016.07.29.11.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 11:06:17 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id l69so76552438lfg.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:06:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <579B991C.9050809@oracle.com>
References: <579B991C.9050809@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 29 Jul 2016 20:05:57 +0200
Message-ID: <CACT4Y+a9=LJjaXgkp=0Dm+ftDbYQchqrzm7P9cM6ksRdHCnw-w@mail.gmail.com>
Subject: Re: kernel BUG at mm/mempolicy.c:1699!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Jul 29, 2016 at 7:57 PM, Vegard Nossum <vegard.nossum@oracle.com> wrote:
> Hi guys,
>
> I ran into this one on commit c624c86615fb8aa61fa76ed8c935446d06c80e77:
>
> ------------[ cut here ]------------
> kernel BUG at mm/mempolicy.c:1699!
> invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> CPU: 1 PID: 27676 Comm: trinity-c0 Not tainted 4.7.0+ #64
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff88010b055a00 task.stack: ffff880101fb0000
> RIP: 0010:[<ffffffff8146246b>]  [<ffffffff8146246b>]
> policy_zonelist+0xab/0x1a0
> RSP: 0018:ffff880101fb7838  EFLAGS: 00010293
> RAX: 0000000000000000 RBX: 0000000002000200 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffff880103ef0690 RDI: ffff880103ef0694
> RBP: ffff880101fb7858 R08: 000000000000000b R09: 0000000000000001
> R10: 000000007d18a1c3 R11: 00000000b63bb1ad R12: 0000000002000200
> R13: ffff88010b055a00 R14: 0000000000000000 R15: ffff880103ef0694
> FS:  00007f405819e700(0000) GS:ffff88011ac80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000001746770 CR3: 0000000004218000 CR4: 00000000000006e4
> Stack:
>  ffff880103ef0690 0000000002000200 ffff880103ef0690 0000000002000200
>  ffff880101fb78c0 ffffffff8146893a ffff880101fb78d0 0000000000015320
>  ffff88010b055a00 0000000000000000 ffff88010b056968 00000002030594a7
> Call Trace:
>  [<ffffffff8146893a>] alloc_pages_current+0xba/0x370
>  [<ffffffff81e136d4>] depot_save_stack+0x3f4/0x490
>  [<ffffffff81476a65>] save_stack+0xb5/0xd0
>  [<ffffffff814770dc>] kasan_slab_free+0x9c/0xd0
>  [<ffffffff814734ef>] kmem_cache_free+0xaf/0x2b0
>  [<ffffffff81465429>] __mpol_put+0x19/0x20
>  [<ffffffff81109c95>] do_exit+0x1515/0x2c90
>  [<ffffffff812bf16e>] seccomp_phase1+0x68e/0x830
>  [<ffffffff8100476c>] syscall_trace_enter_phase1+0x24c/0x500
>  [<ffffffff81004fe4>] syscall_trace_enter+0x64/0xb0
>  [<ffffffff81005586>] do_syscall_64+0x336/0x460
>  [<ffffffff8389f42a>] entry_SYSCALL64_slow_path+0x25/0x25
> Code: db 0f 95 c0 48 89 c1 48 c1 e0 0b 48 c1 e1 04 48 89 ca 4a 03 14 e5 c0
> 58 84 84 48 83 c4 10 5b 41 5c 5d 48 8d 84 02 00 15 00 00 c3 <0f> 0b 48 8d 7e
> 06 48 b8 00 00 00 00 00 fc ff df 48 89 f9 48 c1
> RIP  [<ffffffff8146246b>] policy_zonelist+0xab/0x1a0
>  RSP <ffff880101fb7838>
> ---[ end trace a30466557ef07873 ]---
>
> That's:
>
> $ addr2line -e runs/1469799091/vmlinux -i ffffffff8146246b ffffffff8146893a
> ffffffff81e136d4 ffffffff81476a65 ffffffff814770dc ffffffff814734ef
> ffffffff81465429 ffffffff81109c95 ffffffff812bf16e
> /home/vegard/linux/mm/mempolicy.c:1699
> /home/vegard/linux/mm/mempolicy.c:2072
> /home/vegard/linux/lib/stackdepot.c:247
> /home/vegard/linux/mm/kasan/kasan.c:491
> /home/vegard/linux/mm/kasan/kasan.c:496
> /home/vegard/linux/mm/kasan/kasan.c:547
> /home/vegard/linux/mm/slub.c:2940
> /home/vegard/linux/mm/slub.c:2957
> /home/vegard/linux/mm/mempolicy.c:300
> /home/vegard/linux/kernel/exit.c:854
> /home/vegard/linux/include/linux/audit.h:325
> /home/vegard/linux/kernel/seccomp.c:536
> /home/vegard/linux/kernel/seccomp.c:656
>
> In particular, it's interesting that the kernel/exit.c line is
>
>     mpol_put(tsk->mempolicy);
>
> and alloc_pages_current() does (potentially):
>
>     pol = get_task_policy(current);.
>
> The bug seems very new or very rare or both.


This is https://github.com/google/kasan/issues/35
It is introduced with stackdepot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
