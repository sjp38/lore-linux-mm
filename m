Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id ECAD36B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:44:40 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so1611382igi.0
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:44:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s14si18022736ick.72.2014.09.10.09.44.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 09:44:39 -0700 (PDT)
Message-ID: <54107FD3.90300@oracle.com>
Date: Wed, 10 Sep 2014 12:44:03 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <54104E24.5010402@oracle.com> <20140910134014.GU17501@suse.de>
In-Reply-To: <20140910134014.GU17501@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/10/2014 09:40 AM, Mel Gorman wrote:
> On Wed, Sep 10, 2014 at 09:12:04AM -0400, Sasha Levin wrote:
>> <SNIP, haven't digested the rest>
>>
>> I've spotted a new trace in overnight fuzzing, it could be related to this issue:
>>
>> [ 3494.324839] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [ 3494.332153] Dumping ftrace buffer:
>> [ 3494.332153]    (ftrace buffer empty)
>> [ 3494.332153] Modules linked in:
>> [ 3494.332153] CPU: 8 PID: 2727 Comm: trinity-c929 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1135
>> [ 3494.332153] task: ffff88047e52b000 ti: ffff8804d491c000 task.ti: ffff8804d491c000
>> [ 3494.332153] RIP: task_numa_work (include/linux/mempolicy.h:177 kernel/sched/fair.c:1956)
>> [ 3494.332153] RSP: 0000:ffff8804d491feb8  EFLAGS: 00010206
>> [ 3494.332153] RAX: 0000000000000000 RBX: ffff8804bf4e8000 RCX: 000000000000e8e8
>> [ 3494.343974] RDX: 000000000000000a RSI: 0000000000000000 RDI: ffff8804bd6d4da8
>> [ 3494.343974] RBP: ffff8804d491fef8 R08: ffff8804bf4e84c8 R09: 0000000000000000
>> [ 3494.343974] R10: 00007f53e443c000 R11: 0000000000000001 R12: 00007f53e443c000
>> [ 3494.343974] R13: 000000000000dc51 R14: 006f732e61727478 R15: ffff88047e52b000
>> [ 3494.343974] FS:  00007f53e463f700(0000) GS:ffff880277e00000(0000) knlGS:0000000000000000
>> [ 3494.343974] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ 3494.369895] CR2: 0000000001670fa8 CR3: 0000000283562000 CR4: 00000000000006a0
>> [ 3494.369895] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
>> [ 3494.369895] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>> [ 3494.380081] Stack:
>> [ 3494.380081]  ffff8804bf4e80a8 0000000000000014 00007f53e4437000 0000000000000000
>> [ 3494.380081]  ffffffff9b976e70 ffff88047e52bbd8 ffff88047e52b000 0000000000000000
>> [ 3494.380081]  ffff8804d491ff28 ffffffff95193d84 0000000000000002 ffff8804d491ff58
>> [ 3494.380081] Call Trace:
>> [ 3494.380081] task_work_run (kernel/task_work.c:125 (discriminator 1))
>> [ 3494.380081] do_notify_resume (include/linux/tracehook.h:190 arch/x86/kernel/signal.c:758)
>> [ 3494.380081] retint_signal (arch/x86/kernel/entry_64.S:918)
>> [ 3494.380081] Code: e8 1e e5 01 00 48 89 df 4c 89 e6 e8 a3 2d 13 00 49 89 c6 48 85 c0 0f 84 07 02 00 00 48 c7 45 c8 00 00 00 00 0f 1f 80 00 00 00 00 <49> f7 46 50 00 44 00 00 0f 85 42 01 00 00 49 8b 86 a0 00 00 00
> 
> Shot in dark, can you test this please? Pagetable teardown can schedule
> and I'm wondering if we are trying to add hinting faults to an address
> space that is in the process of going away. The TASK_DEAD check is bogus
> so replacing it.

Mel, I ran today's -next with both of your patches, but the issue still remains:

[ 3114.540976] kernel BUG at include/asm-generic/pgtable.h:724!
[ 3114.541857] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3114.543112] Dumping ftrace buffer:
[ 3114.544056]    (ftrace buffer empty)
[ 3114.545000] Modules linked in:
[ 3114.545717] CPU: 18 PID: 30217 Comm: trinity-c617 Tainted: G        W      3.17.0-rc4-next-20140910-sasha-00032-g6825fb5-dirty #1137
[ 3114.548058] task: ffff880415050000 ti: ffff88076f584000 task.ti: ffff88076f584000
[ 3114.549284] RIP: 0010:[<ffffffff952e527a>]  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
[ 3114.550028] RSP: 0000:ffff88076f587d68  EFLAGS: 00010246
[ 3114.550028] RAX: 0000000314625900 RBX: 0000000041218000 RCX: 0000000000000100
[ 3114.550028] RDX: 0000000314625900 RSI: 0000000041218000 RDI: 0000000314625900
[ 3114.550028] RBP: ffff88076f587dc8 R08: ffff8802cf973600 R09: 0000000000b50000
[ 3114.550028] R10: 0000000000032c01 R11: 0000000000000008 R12: ffff8802a81070c0
[ 3114.550028] R13: 8000000000000025 R14: 0000000041343000 R15: ffffc00000000fff
[ 3114.550028] FS:  00007fabb91c8700(0000) GS:ffff88025ec00000(0000) knlGS:0000000000000000
[ 3114.550028] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3114.550028] CR2: 00007fffdb7678e8 CR3: 0000000713935000 CR4: 00000000000006a0
[ 3114.550028] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3114.550028] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000050602
[ 3114.550028] Stack:
[ 3114.550028]  0000000000000001 0000000314625900 0000000000000018 ffff8802685f2260
[ 3114.550028]  0000000016840000 ffff8802cf973600 ffff880616840000 0000000041343000
[ 3114.550028]  ffff880108805048 0000000041005000 0000000041200000 0000000041343000
[ 3114.550028] Call Trace:
[ 3114.550028]  [<ffffffff952e5534>] change_protection+0x2b4/0x4e0
[ 3114.550028]  [<ffffffff952ff24b>] change_prot_numa+0x1b/0x40
[ 3114.550028]  [<ffffffff951adf16>] task_numa_work+0x1f6/0x330
[ 3114.550028]  [<ffffffff95193de4>] task_work_run+0xc4/0xf0
[ 3114.550028]  [<ffffffff95071477>] do_notify_resume+0x97/0xb0
[ 3114.550028]  [<ffffffff9850f06a>] int_signal+0x12/0x17
[ 3114.550028] Code: 66 90 48 8b 7d b8 e8 e6 88 22 03 48 8b 45 b0 e9 6f ff ff ff 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b <0f> 0b 0f 0b 0f 0b 66 66 66 66 90 55 48 89 e5 41 57 49 89 d7 41
[ 3114.550028] RIP  [<ffffffff952e527a>] change_pte_range+0x4ea/0x4f0
[ 3114.550028]  RSP <ffff88076f587d68>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
