Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 163F46B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 20:32:55 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id 9so8958659ykp.1
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 17:32:54 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t27si13499746yhn.126.2014.03.06.17.32.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 17:32:54 -0800 (PST)
Message-ID: <531921C0.3030904@oracle.com>
Date: Thu, 06 Mar 2014 20:32:48 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
References: <530F3F0A.5040304@oracle.com>	<20140227150313.3BA27E0098@blue.fi.intel.com> <CAA_GA1c02iSmkmCLHFkrK4b4W+JppZ4CSMUJ-Wn1rCs-c=dV6g@mail.gmail.com> <53169FC5.4080006@oracle.com>
In-Reply-To: <53169FC5.4080006@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/04/2014 10:53 PM, Sasha Levin wrote:
> On 03/04/2014 10:16 PM, Bob Liu wrote:
>> On Thu, Feb 27, 2014 at 11:03 PM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>>> Sasha Levin wrote:
>>>> Hi all,
>>>>
>>>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
>>>> following spew:
>>>>
>>>> [ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
>>>
>>> Hm, interesting.
>>>
>>> It seems we either failed to split huge page on vma split or it
>>> materialized from under us. I don't see how it can happen:
>>>
>>>    - it seems we do the right thing with vma_adjust_trans_huge() in
>>>      __split_vma();
>>>    - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
>>>      a place where we could drop it;
>>>
>>
>> Enable CONFIG_DEBUG_VM may show some useful information, at least we
>> can confirm weather rwsem_is_locked(&tlb->mm->mmap_sem) before
>> split_huge_page_pmd().
>
> I have CONFIG_DEBUG_VM enabled and that code you're talking is not triggering, so mmap_sem
> is locked.

Guess what. I've just hit it.

It's worth keeping in mind that this is the first time I see it.

[  695.173659] kernel BUG at mm/memory.c:1228!
[  695.174233] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  695.175322] Dumping ftrace buffer:
[  695.176180]    (ftrace buffer empty)
[  695.176813] Modules linked in:
[  695.177223] CPU: 6 PID: 21524 Comm: trinity-c362 Tainted: G        W    3.14.0-rc5-next-20140305-sasha-00012-g00c5c8f-dirty #110
[  695.179249] task: ffff880d27a70000 ti: ffff880c28042000 task.ti: ffff880c28042000
[  695.180341] RIP: 0010:[<ffffffff8129f82c>]  [<ffffffff8129f82c>] unmap_page_range+0x25c/0x410
[  695.180341] RSP: 0000:ffff880c28043b18  EFLAGS: 00010292
[  695.180341] RAX: 0000000000000083 RBX: ffff880528fca698 RCX: 0000000000000000
[  695.180341] RDX: ffff880d27a70000 RSI: 0000000000000001 RDI: 0000000000000282
[  695.180341] RBP: ffff880c28043b98 R08: 0000000000000001 R09: 0000000000000001
[  695.180341] R10: 0000000000000001 R11: 0000000000000001 R12: 00007f735a600000
[  695.180341] R13: 00007f735a633000 R14: ffff880c28043c38 R15: 00007f735a632fff
[  695.180341] FS:  0000000000000000(0000) GS:ffff88072b800000(0000) knlGS:0000000000000000
[  695.180341] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  695.180341] CR2: 0000000000000008 CR3: 0000000005e27000 CR4: 00000000000006a0
[  695.180341] DR0: 000000000089e000 DR1: 0000000000000000 DR2: 0000000000000000
[  695.180341] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  695.180341] Stack:
[  695.180341]  ffffffff8447a29d 00007f735a600000 00007f735a632fff 00007f735a633000
[  695.180341]  ffff880c285087f0 0000000000000000 00007f735a632fff ffff88081804bc00
[  695.180341]  ffff880505918e68 00007f735a633000 ffff880c27f745c0 ffff88081804bc00
[  695.180341] Call Trace:
[  695.180341]  [<ffffffff8447a29d>] ? _raw_spin_unlock_irqrestore+0x6d/0xc0
[  695.180341]  [<ffffffff8129fae1>] unmap_single_vma+0x101/0x120
[  695.180341]  [<ffffffff8129fb61>] unmap_vmas+0x61/0xa0
[  695.180341]  [<ffffffff812a6f20>] exit_mmap+0xd0/0x170
[  695.180341]  [<ffffffff812ddbc0>] ? __khugepaged_exit+0xe0/0x150
[  695.180341]  [<ffffffff8114030c>] mmput+0x7c/0xf0
[  695.180341]  [<ffffffff8114451d>] exit_mm+0x18d/0x1a0
[  695.180341]  [<ffffffff811f7fe5>] ? acct_collect+0x175/0x1b0
[  695.180341]  [<ffffffff8114696f>] do_exit+0x26f/0x520
[  695.180341]  [<ffffffff81146cc9>] do_group_exit+0xa9/0xe0
[  695.180341]  [<ffffffff8115c562>] get_signal_to_deliver+0x4e2/0x570
[  695.180341]  [<ffffffff8106fc3b>] do_signal+0x4b/0x120
[  695.180341]  [<ffffffff8118ab06>] ? vtime_account_user+0x96/0xb0
[  695.180341]  [<ffffffff811a0000>] ? print_cfs_group_stats+0x570/0x900
[  695.180341]  [<ffffffff810c25b5>] ? __bad_area_nosemaphore+0x45/0x250
[  695.180341]  [<ffffffff81269545>] ? context_tracking_user_exit+0x195/0x1d0
[  695.180341]  [<ffffffff81269545>] ? context_tracking_user_exit+0x195/0x1d0
[  695.180341]  [<ffffffff811ab7dd>] ? trace_hardirqs_on+0xd/0x10
[  695.180341]  [<ffffffff8106ff8a>] do_notify_resume+0x5a/0xe0
[  695.180341]  [<ffffffff8447a93b>] retint_signal+0x4d/0x92
[  695.180341] Code: 00 00 00 75 32 48 8b 45 b8 4c 89 e9 4c 8b 48 08 4c 8b 00 4c 89 e2 48 c7 c6 38 0c 66 84 48 c7 c7 10 d5 6c 85 31 c0 e8 70 2f 1d 03 <0f> 0b 66 90 eb fe 66 0f 1f 44 00 00 48 8b 3b 48 83 3d cd e1 ba
[  695.180341] RIP  [<ffffffff8129f82c>] unmap_page_range+0x25c/0x410
[  695.180341]  RSP <ffff880c28043b18>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
