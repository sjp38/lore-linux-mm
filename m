Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA0046B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:54:52 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so624393pad.30
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 08:54:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id tj6si11668640pbc.124.2014.03.25.08.54.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 08:54:51 -0700 (PDT)
Message-ID: <5331A6C3.2000303@oracle.com>
Date: Tue, 25 Mar 2014 11:54:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: gpf in deactivate_slab
References: <53208A87.2040907@oracle.com>
In-Reply-To: <53208A87.2040907@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@gentwo.org>, Matt Mackall <mpm@selenic.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/12/2014 12:25 PM, Sasha Levin wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled
> on the following spew:
>
> [  241.916559] BUG: unable to handle kernel paging request at ffff880029aa5e58
> [  241.917961] IP: [<ffffffff812c5fa3>] deactivate_slab+0x103/0x560
> [  241.919439] PGD 88f9067 PUD 88fa067 PMD 102fd35067 PTE 8000000029aa5060
> [  241.920339] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  241.920339] Dumping ftrace buffer:
> [  241.920339]    (ftrace buffer empty)
> [  241.920339] Modules linked in:
> [  241.920339] CPU: 17 PID: 9910 Comm: trinity-c183 Tainted: G        W    3.14.0-rc6-next-20140311-sasha-00009-g6c028cd-dirty #146
> [  241.920339] task: ffff88090eb68000 ti: ffff88090eb70000 task.ti: ffff88090eb70000
> [  241.920339] RIP: 0010:[<ffffffff812c5fa3>]  [<ffffffff812c5fa3>] deactivate_slab+0x103/0x560
> [  241.920339] RSP: 0018:ffff88090eb71c18  EFLAGS: 00010082
> [  241.920339] RAX: 0000000000000418 RBX: ffff880229ae2010 RCX: 0000000180170017
> [  241.920339] RDX: 0000000000000000 RSI: ffffffff812c5f52 RDI: ffffffff812c5e29
> [  241.920339] RBP: ffff88090eb71d28 R08: ffff880229ae2010 R09: 0000000000000080
> [  241.920339] R10: ffff880229ae2ed0 R11: 0000000000000000 R12: ffffea0008a6b800
> [  241.920339] R13: ffff88012b4da580 R14: ffff880029aa5a40 R15: ffff880229ae2010
> [  241.920339] FS:  00007fb615415700(0000) GS:ffff88022ba00000(0000) knlGS:0000000000000000
> [  241.920339] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  241.920339] CR2: ffff880029aa5e58 CR3: 000000090eb4a000 CR4: 00000000000006a0
> [  241.920339] DR0: 0000000000005bf2 DR1: 0000000000000000 DR2: 0000000000000000
> [  241.920339] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000070602
> [  241.920339] Stack:
> [  241.920339]  ffffffff856e37ab ffffffff84486272 0000000000000000 000000002b405600
> [  241.920339]  ffff88090eb71c58 ffff88090eb70000 0000000000000011 ffff88022ba03fc0
> [  241.920339]  ffff88090eb71cb8 000000000000000f ffff88022b405600 ffff880029aa5a40
> [  241.920339] Call Trace:
> [  241.920339]  [<ffffffff84486272>] ? preempt_count_sub+0xe2/0x120
> [  241.920339]  [<ffffffff8130f151>] ? alloc_inode+0x41/0xa0
> [  241.954886]  [<ffffffff8130f151>] ? alloc_inode+0x41/0xa0
> [  241.954886]  [<ffffffff8130f151>] ? alloc_inode+0x41/0xa0
> [  241.954886]  [<ffffffff812c36eb>] ? set_track+0xab/0x100
> [  241.954886]  [<ffffffff812c731f>] __slab_alloc+0x42f/0x4d0
> [  241.954886]  [<ffffffff81073e6d>] ? sched_clock+0x1d/0x30
> [  241.954886]  [<ffffffff8130f151>] ? alloc_inode+0x41/0xa0
> [  241.961624]  [<ffffffff812c870f>] kmem_cache_alloc+0x12f/0x2e0
> [  241.961624]  [<ffffffff8130f151>] ? alloc_inode+0x41/0xa0
> [  241.961624]  [<ffffffff8130f151>] alloc_inode+0x41/0xa0
> [  241.961624]  [<ffffffff8130f1cb>] new_inode_pseudo+0x1b/0x70
> [  241.961624]  [<ffffffff812f985c>] get_pipe_inode+0x1c/0xf0
> [  241.961624]  [<ffffffff812f995c>] create_pipe_files+0x2c/0x170
> [  241.961624]  [<ffffffff812f9ae1>] __do_pipe_flags+0x41/0xf0
> [  241.961624]  [<ffffffff812f9bbb>] SyS_pipe2+0x2b/0xb0
> [  241.961624]  [<ffffffff8448b3b1>] ? tracesys+0x7e/0xe2
> [  241.961624]  [<ffffffff8448b410>] tracesys+0xdd/0xe2
> [  241.972975] Code: 4d 85 f6 75 8b eb 45 90 4d 85 f6 75 13 49 8b 5c 24 10 45 31 ff 0f 1f 00 eb 32 66 0f 1f 44 00 00 4c 89 b5 48 ff ff ff 49 63 45 20 <49> 8b 0c 06 48 85 c9 74 10 4d 89 f7 49 8b 54 24 10 49 89 ce e9
> [  241.972975] RIP  [<ffffffff812c5fa3>] deactivate_slab+0x103/0x560
> [  241.972975]  RSP <ffff88090eb71c18>
> [  241.972975] CR2: ffff880029aa5e58

I have a lead on this. Consider the following:

   kmem_cache_alloc
	__slab_alloc
		local_irq_save()
		deactivate_slab
			__cmpxchg_double_slab
				slab_unlock
					__bit_spin_unlock
						preempt_enable
		[ Page Fault ]

With this trace, it manifests as a "BUG: sleeping function called from invalid
context at arch/x86/mm/fault.c" on a might_sleep() in the page fault handler
(which is an issue on it's own), but I suspect it's also the cause of the trace
above - preemption enabled and a race that removed the page.

Could someone confirm please?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
