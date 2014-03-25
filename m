Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 499946B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:16:01 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so712079pdi.30
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 10:16:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w4si11980873paa.34.2014.03.25.10.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 10:15:59 -0700 (PDT)
Message-ID: <5331B9C8.7080106@oracle.com>
Date: Tue, 25 Mar 2014 13:15:52 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: gpf in deactivate_slab
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc>
In-Reply-To: <alpine.DEB.2.10.1403251205140.24534@nuc>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2014 01:06 PM, Christoph Lameter wrote:
> On Tue, 25 Mar 2014, Michal Hocko wrote:
>
>> You are right. The function even does VM_BUG_ON(!irqs_disabled())...
>> Unfortunatelly we do not seem to have an _irq alternative of the bit
>> spinlock.
>> Not sure what to do about it. Christoph?
>>
>> Btw. it seems to go way back to 3.1 (1d07171c5e58e).
>
> Well there is a preempt_enable() (bit_spin_lock) and a preempt_disable()
> bit_spin_unlock() within a piece of code where irqs are disabled.
>
> Is that a problem? Has been there for a long time.

So here's the full trace. There's obviously something wrong here since we
pagefault inside the section that was supposed to be running with irqs disabled
and I don't see another cause besides this.

The unreliable entries in the stack trace also somewhat suggest that the
fault is with the code I've pointed out.


[  584.145271] BUG: sleeping function called from invalid context at arch/x86/mm/fault.c:1167
[  584.148787] in_atomic(): 0, irqs_disabled(): 1, pid: 10089, name: trinity-c42
[  584.150413] 1 lock held by trinity-c42/10089:
[  584.151834]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8450aec3>] __do_page_fault+0x2e3/0x630
[  584.151834] irq event stamp: 33318
[  584.151834] hardirqs last  enabled at (33317): [<ffffffff81282f15>] context_tracking_user_exit+0x1b5/0x260
[  584.151834] hardirqs last disabled at (33318): [<ffffffff844b10d6>] __slab_alloc+0x41/0x637
[  584.151834] softirqs last  enabled at (33070): [<ffffffff81161a3e>] __do_softirq+0x3fe/0x560
[  584.151834] softirqs last disabled at (33065): [<ffffffff81161f7c>] irq_exit+0x6c/0x170
[  584.151834] CPU: 42 PID: 10089 Comm: trinity-c42 Tainted: G        W     3.14.0-rc7-next-20140324-sasha-00015-g2fee858-dirty #271
[  584.151834]  ffff8800bc043000 ffff8800bc06f9c8 ffffffff844baf42 0000000000000001
[  584.151834]  0000000000000000 ffff8800bc06f9f8 ffffffff81197ee1 ffffffff8450aec3
[  584.151834]  0000000000000028 ffff8800bc06fb68 0000000000000a94 ffff8800bc06fb08
[  584.151834] Call Trace:
[  584.151834]  [<ffffffff844baf42>] dump_stack+0x4f/0x7c
[  584.151834]  [<ffffffff81197ee1>] __might_sleep+0x221/0x240
[  584.151834]  [<ffffffff8450aec3>] ? __do_page_fault+0x2e3/0x630
[  584.151834]  [<ffffffff8450af0b>] __do_page_fault+0x32b/0x630
[  584.151834]  [<ffffffff8107aab5>] ? sched_clock+0x15/0x20
[  584.151834]  [<ffffffff811a2295>] ? sched_clock_local+0x25/0xa0
[  584.151834]  [<ffffffff811a2578>] ? sched_clock_cpu+0xa8/0xf0
[  584.151834]  [<ffffffff81282f07>] ? context_tracking_user_exit+0x1a7/0x260
[  584.151834]  [<ffffffff81b37063>] ? __this_cpu_preempt_check+0x13/0x20
[  584.151834]  [<ffffffff811c0664>] ? trace_hardirqs_off_caller+0x174/0x1a0
[  584.151834]  [<ffffffff8450b25e>] do_page_fault+0x4e/0xa0
[  584.151834]  [<ffffffff8450a775>] do_async_page_fault+0x35/0x100
[  584.151834]  [<ffffffff845073d8>] async_page_fault+0x28/0x30
[  584.151834]  [<ffffffff812e60e8>] ? deactivate_slab+0xc8/0x620
[  584.151834]  [<ffffffff812e5f70>] ? __cmpxchg_double_slab.isra.26+0x120/0x1d0
[  584.151834]  [<ffffffff812e611b>] ? deactivate_slab+0xfb/0x620
[  584.151834]  [<ffffffff812e60e8>] ? deactivate_slab+0xc8/0x620
[  584.151834]  [<ffffffff84506345>] ? _raw_spin_unlock+0x35/0x60
[  584.151834]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.151834]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.151834]  [<ffffffff81b37087>] ? debug_smp_processor_id+0x17/0x20
[  584.151834]  [<ffffffff812e3676>] ? set_track+0x96/0x180
[  584.151834]  [<ffffffff812e35ce>] ? init_object+0x6e/0x80
[  584.151834]  [<ffffffff844b15f9>] __slab_alloc+0x564/0x637
[  584.151834]  [<ffffffff810b9b24>] ? kvm_clock_read+0x24/0x40
[  584.151834]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.151834]  [<ffffffff8119b041>] ? get_parent_ip+0x11/0x50
[  584.151834]  [<ffffffff812e7ddc>] kmem_cache_alloc+0x12c/0x3b0
[  584.151834]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.151834]  [<ffffffff811a3288>] ? vtime_account_user+0x98/0xb0
[  584.151834]  [<ffffffff8132c5e1>] alloc_inode+0x41/0xa0
[  584.151834]  [<ffffffff8132e4fa>] new_inode_pseudo+0x1a/0x70
[  584.151834]  [<ffffffff8131837a>] create_pipe_files+0x2a/0x220
[  584.151834]  [<ffffffff811c28f4>] ? trace_hardirqs_on_caller+0x1f4/0x290
[  584.151834]  [<ffffffff813185b5>] __do_pipe_flags+0x45/0xe0
[  584.151834]  [<ffffffff81318770>] SyS_pipe+0x20/0xb0
[  584.151834]  [<ffffffff84510975>] ? tracesys+0x7e/0xe6
[  584.151834]  [<ffffffff845109d8>] tracesys+0xe1/0xe6

It was also followed by a straightforward NULL ptr deref in deactivate_slab():

[  584.151834] BUG: unable to handle kernel NULL pointer dereference at 0000000000000a94
[  584.151834] IP: [<ffffffff812e611b>] deactivate_slab+0xfb/0x620
[  584.223982] PGD bc06c067 PUD bc06d067 PMD 0
[  584.223982] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  584.223982] Dumping ftrace buffer:
[  584.223982]    (ftrace buffer empty)
[  584.223982] Modules linked in:
[  584.223982] CPU: 42 PID: 10089 Comm: trinity-c42 Tainted: G        W     3.14.0-rc7-next-20140324-sasha-00015-g2fee858-dirty #271
[  584.223982] task: ffff8800bc043000 ti: ffff8800bc06e000 task.ti: ffff8800bc06e000
[  584.223982] RIP: 0010:[<ffffffff812e611b>]  [<ffffffff812e611b>] deactivate_slab+0xfb/0x620
[  584.223982] RSP: 0018:ffff8800bc06fc18  EFLAGS: 00010006
[  584.223982] RAX: 0000000000000410 RBX: ffffea002bb04200 RCX: 0000000180180016
[  584.223982] RDX: 0000000000000001 RSI: ffffffff812e60e8 RDI: ffffffff812e5f70
[  584.223982] RBP: ffff8800bc06fd08 R08: ffffea0023ac6000 R09: 0000000000000080
[  584.223982] R10: ffff880aec108408 R11: 0000000000000001 R12: ffffea0023ac6000
[  584.223982] R13: ffff880a6c520000 R14: 0000000000000684 R15: 0000000000000684
[  584.223982] FS:  00007feaa0845700(0000) GS:ffff880aecc00000(0000) knlGS:0000000000000000
[  584.223982] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  584.223982] CR2: 0000000000000a94 CR3: 00000000bc06b000 CR4: 00000000000006a0
[  584.223982] DR0: 0000000000698000 DR1: 0000000000698000 DR2: 0000000000000000
[  584.223982] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000d9060a
[  584.223982] Stack:
[  584.223982]  ffff8800bc043000 0000002a8450b958 ffff8800bc06e000 ffff8800bc06fc78
[  584.223982]  00000000bc06fc58 ffffffff84506345 ffff88000000000f ffff880aec805600
[  584.223982]  ffffffff8132c5e1 0000000000000082 ffff880aec108418 0000000180180015
[  584.223982] Call Trace:
[  584.223982]  [<ffffffff84506345>] ? _raw_spin_unlock+0x35/0x60
[  584.223982]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.223982]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.223982]  [<ffffffff81b37087>] ? debug_smp_processor_id+0x17/0x20
[  584.223982]  [<ffffffff812e3676>] ? set_track+0x96/0x180
[  584.223982]  [<ffffffff812e35ce>] ? init_object+0x6e/0x80
[  584.223982]  [<ffffffff844b15f9>] __slab_alloc+0x564/0x637
[  584.223982]  [<ffffffff810b9b24>] ? kvm_clock_read+0x24/0x40
[  584.223982]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.223982]  [<ffffffff8119b041>] ? get_parent_ip+0x11/0x50
[  584.223982]  [<ffffffff812e7ddc>] kmem_cache_alloc+0x12c/0x3b0
[  584.223982]  [<ffffffff8132c5e1>] ? alloc_inode+0x41/0xa0
[  584.223982]  [<ffffffff811a3288>] ? vtime_account_user+0x98/0xb0
[  584.223982]  [<ffffffff8132c5e1>] alloc_inode+0x41/0xa0
[  584.223982]  [<ffffffff8132e4fa>] new_inode_pseudo+0x1a/0x70
[  584.223982]  [<ffffffff8131837a>] create_pipe_files+0x2a/0x220
[  584.223982]  [<ffffffff811c28f4>] ? trace_hardirqs_on_caller+0x1f4/0x290
[  584.223982]  [<ffffffff813185b5>] __do_pipe_flags+0x45/0xe0
[  584.223982]  [<ffffffff81318770>] SyS_pipe+0x20/0xb0
[  584.223982]  [<ffffffff84510975>] ? tracesys+0x7e/0xe6
[  584.223982]  [<ffffffff845109d8>] tracesys+0xe1/0xe6
[  584.223982] Code: 49 63 45 20 eb b2 66 2e 0f 1f 84 00 00 00 00 00 4d 85 f6 75 0b 4c 8b 63 10 45 31 ff eb 22 66 90 49 63 45 20 4d 89 f7 4c 8b 63 10 <49> 8b 14 06 48 85 d2 74 0c 49 89 d6 e9 7c ff ff ff 0f 1f 40 00
[  584.223982] RIP  [<ffffffff812e611b>] deactivate_slab+0xfb/0x620
[  584.223982]  RSP <ffff8800bc06fc18>
[  584.223982] CR2: 0000000000000a94


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
