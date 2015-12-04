Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id D6EF06B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 15:48:51 -0500 (EST)
Received: by obcse5 with SMTP id se5so78107348obc.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 12:48:51 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s3si14288237oet.58.2015.12.04.12.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 12:48:51 -0800 (PST)
Subject: Re: mm: BUG in __munlock_pagevec
References: <565C5C38.3040705@oracle.com>
 <20151201213801.GA138207@black.fi.intel.com> <5661FBB6.6050307@oracle.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5661FC30.5060707@oracle.com>
Date: Fri, 4 Dec 2015 15:48:48 -0500
MIME-Version: 1.0
In-Reply-To: <5661FBB6.6050307@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/04/2015 03:46 PM, Sasha Levin wrote:
> On 12/01/2015 04:38 PM, Kirill A. Shutemov wrote:
>> > On Mon, Nov 30, 2015 at 09:24:56AM -0500, Sasha Levin wrote:
>>>> >> > Hi all,
>>>> >> > 
>>>> >> > I've hit the following while fuzzing with trinity on the latest -next kernel:
>>>> >> > 
>>>> >> > 
>>>> >> > [  850.305385] page:ffffea001a5a0f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1ffffffffff
>>>> >> > [  850.306773] flags: 0x2fffff80000000()
>>>> >> > [  850.307175] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
>>>> >> > [  850.308027] page_owner info is not active (free page?)
>> > Could you check this completely untested patch:
>> > 
>> > diff --git a/mm/mlock.c b/mm/mlock.c
>> > index af421d8bd6da..9197b6721a1e 100644
>> > --- a/mm/mlock.c
>> > +++ b/mm/mlock.c
>> > @@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>> >  		if (!page || page_zone_id(page) != zoneid)
>> >  			break;
>> >  
>> > +		/*
>> > +		 * Do not use pagevec for PTE-mapped THP,
>> > +		 * munlock_vma_pages_range() will handle them.
>> > +		 */
>> > +		if (PageTransCompound(page))
>> > +			break;
>> > +
>> >  		get_page(page);
>> >  		/*
>> >  		 * Increase the address that will be returned *before* the
> I've started seeing:

And:

[  883.470914] kernel BUG at mm/mlock.c:460!
[  883.472612] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[  883.474950] Modules linked in:
[  883.476583] CPU: 11 PID: 15210 Comm: trinity-c191 Not tainted 4.4.0-rc3-next-20151203-sasha-00025-gf813aca-dirty #2691
[  883.481771] task: ffff8801026b4000 ti: ffff8808a25d0000 task.ti: ffff8808a25d0000
[  883.485068] RIP: 0010:[<ffffffff816b9d43>]  [<ffffffff816b9d43>] munlock_vma_pages_range+0x2b3/0xab0
[  883.493522] RSP: 0018:ffff8808a25d79e8  EFLAGS: 00010246
[  883.495623] RAX: 0000000000000000 RBX: ffffea0029af2740 RCX: 0000000000000000
[  883.498478] RDX: 1ffffd400535e4ef RSI: 0000000000000246 RDI: ffffea0029af2778
[  883.501609] RBP: ffff8808a25d7be0 R08: fffffbfff36d4114 R09: ffffffff9b6a08a4
[  883.504475] R10: 0000000000000001 R11: 1ffffffff36d410d R12: ffffea0029af2760
[  883.507422] R13: ffff8808a25d7bb8 R14: dffffc0000000000 R15: ffffea0029af0000
[  883.510004] FS:  0000000000000000(0000) GS:ffff880aa4600000(0000) knlGS:0000000000000000
[  883.511243] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  883.512303] CR2: 0000000000639378 CR3: 0000000880b7b000 CR4: 00000000000006a0
[  883.518040] DR0: 0000000000008ac6 DR1: 0000000000000000 DR2: 0000000000000000
[  883.519467] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  883.520662] Stack:
[  883.521038]  ffff8811eb99db60 0000000000000002 ffff880aa7fcf000 1ffff101144baf4b
[  883.522493]  ffffed023d733b6c 0000000002c97000 000077f75da28510 0000002e00000000
[  883.524015]  ffff8808a25d7a78 ffffea002a6a495c 00007f04ffe7b000 ffffea0029af0001
[  883.527296] Call Trace:
[  883.528482]  [<ffffffff816b9a90>] ? munlock_vma_page+0x400/0x400
[  883.531246]  [<ffffffff8144dbe0>] ? in_lock_functions+0x30/0x40
[  883.534027]  [<ffffffff813ddd1d>] ? get_parent_ip+0xd/0x40
[  883.536351]  [<ffffffff813dde39>] ? preempt_count_add+0xe9/0x140
[  883.539045]  [<ffffffff8173d597>] ? free_debug_processing+0x417/0x550
[  883.542045]  [<ffffffff818a0b45>] ? exit_aio+0x365/0x3c0
[  883.544352]  [<ffffffff816c9f11>] exit_mmap+0x1f1/0x420
[  883.546476]  [<ffffffff817616ee>] ? __khugepaged_exit+0x2ee/0x3a0
[  883.548906]  [<ffffffff816c9d20>] ? SyS_remap_file_pages+0x630/0x630
[  883.551544]  [<ffffffff8174185d>] ? kmem_cache_free+0x26d/0x2d0
[  883.553718]  [<ffffffff817616ff>] ? __khugepaged_exit+0x2ff/0x3a0
[  883.556319]  [<ffffffff81761400>] ? hugepage_madvise+0x160/0x160
[  883.558901]  [<ffffffff813cc436>] ? ___might_sleep+0xd6/0x3f0
[  883.561232]  [<ffffffff813cf532>] ? __might_sleep+0x1f2/0x220
[  883.566857]  [<ffffffff813509d5>] mmput+0xe5/0x320
[  883.568416]  [<ffffffff813508f0>] ? sighand_ctor+0x70/0x70
[  883.570136]  [<ffffffff81362a39>] ? mm_update_next_owner+0x5c9/0x600
[  883.572272]  [<ffffffff813dde39>] ? preempt_count_add+0xe9/0x140
[  883.574501]  [<ffffffff813638fd>] do_exit+0xe8d/0x1540
[  883.577297]  [<ffffffff811693a4>] ? sched_clock+0x44/0x50
[  883.579268]  [<ffffffff813f058c>] ? local_clock+0x1c/0x20
[  883.581118]  [<ffffffff81362a70>] ? mm_update_next_owner+0x600/0x600
[  883.585181]  [<ffffffff81607721>] ? __context_tracking_exit+0xb1/0xc0
[  883.587569]  [<ffffffff8160784b>] ? context_tracking_exit+0x11b/0x120
[  883.589850]  [<ffffffff81005e5a>] ? syscall_trace_enter_phase1+0x4aa/0x4f0
[  883.592297]  [<ffffffff810059b0>] ? enter_from_user_mode+0x80/0x80
[  883.594603]  [<ffffffff83024353>] ? check_preemption_disabled+0x233/0x250
[  883.596920]  [<ffffffff81364209>] do_group_exit+0x1e9/0x330
[  883.598682]  [<ffffffff8136436d>] SyS_exit_group+0x1d/0x20
[  883.602748]  [<ffffffff8b9178d5>] entry_SYSCALL_64_fastpath+0x35/0x99
[  883.604899] Code: 3c 30 00 74 08 4c 89 ff e8 0b be 08 00 49 8b 07 a9 00 00 10 00 74 22 e8 9c c3 08 00 48 c7 c6 c0 94 b0 8b 48 89 df e8 3d 0f fe ff <0f> 0b 48 c7 c7 e0 f3 ec 8f e8 ad 71 9f 01 e8 7a c3 08 00 4c 89
[  883.613771] RIP  [<ffffffff816b9d43>] munlock_vma_pages_range+0x2b3/0xab0
[  883.614902]  RSP <ffff8808a25d79e8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
