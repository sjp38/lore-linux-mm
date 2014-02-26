Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id CFB9F6B0082
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 09:48:31 -0500 (EST)
Received: by mail-vc0-f179.google.com with SMTP id lh14so1040007vcb.10
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 06:48:31 -0800 (PST)
Received: from mail-ve0-x22b.google.com (mail-ve0-x22b.google.com [2607:f8b0:400c:c01::22b])
        by mx.google.com with ESMTPS id sm10si263405vec.81.2014.02.26.06.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 06:48:31 -0800 (PST)
Received: by mail-ve0-f171.google.com with SMTP id oz11so2221162veb.2
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 06:48:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140226140941.GA31230@node.dhcp.inet.fi>
References: <530CEFE2.9090909@oracle.com>
	<CAA_GA1dJA9PmZnoNy59__Ek+KPS3xX4WuR_8=onY8mZSRQrKiQ@mail.gmail.com>
	<20140226140941.GA31230@node.dhcp.inet.fi>
Date: Wed, 26 Feb 2014 22:48:30 +0800
Message-ID: <CAA_GA1dRS9WghaoG3bYwnEVxdOXQTjcTrZQkgZEU+vq3Lbmm6Q@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in balance_dirty_pages_ratelimited
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 26, 2014 at 10:09 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Feb 26, 2014 at 03:15:07PM +0800, Bob Liu wrote:
>> On Wed, Feb 26, 2014 at 3:32 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
>> > Hi all,
>> >
>> > While fuzzing with trinity inside a KVM tools running latest -next kernel
>> > I've stumbled on the following spew:
>> >
>> > [  232.869443] BUG: unable to handle kernel NULL pointer dereference at
>> > 0000000000000020
>> > [  232.870230] IP: [<mm/page-writeback.c:1612>]
>> > balance_dirty_pages_ratelimited+0x1e/0x150
>> > [  232.870230] PGD 586e1d067 PUD 586e1e067 PMD 0
>> > [  232.870230] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> > [  232.870230] Dumping ftrace buffer:
>> > [  232.870230]    (ftrace buffer empty)
>> > [  232.870230] Modules linked in:
>> > [  232.870230] CPU: 36 PID: 9707 Comm: trinity-c36 Tainted: G        W
>> > 3.14.0-rc4-next-20140225-sasha-00010-ga117461 #42
>> > [  232.870230] task: ffff880586dfb000 ti: ffff880586e34000 task.ti:
>> > ffff880586e34000
>> > [  232.870230] RIP: 0010:[<mm/page-writeback.c:1612>]
>> > [<mm/page-writeback.c:1612>] balance_dirty_pages_ratelimited+0x1e/0x150
>> > [  232.870230] RSP: 0000:ffff880586e35c58  EFLAGS: 00010282
>> > [  232.870230] RAX: 0000000000000000 RBX: ffff880582831361 RCX:
>> > 0000000000000007
>> > [  232.870230] RDX: 0000000000000007 RSI: ffff880586dfbcc0 RDI:
>> > ffff880582831361
>> > [  232.870230] RBP: ffff880586e35c78 R08: 0000000000000000 R09:
>> > 0000000000000000
>> > [  232.870230] R10: 0000000000000001 R11: 0000000000000001 R12:
>> > 00007f58007ee000
>> > [  232.870230] R13: ffff880c8d6d4f70 R14: 0000000000000200 R15:
>> > ffff880c8dcce710
>> > [  232.870230] FS:  00007f58018bb700(0000) GS:ffff880c8e800000(0000)
>> > knlGS:0000000000000000
>> > [  232.870230] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> > [  232.870230] CR2: 0000000000000020 CR3: 0000000586e1c000 CR4:
>> > 00000000000006e0
>> > [  232.870230] Stack:
>> > [  232.870230]  ffff880586e35c78 ffff880586e33400 00007f58007ee000
>> > ffff880c8d6d4f70
>> > [  232.870230]  ffff880586e35cd8 ffffffff8127d241 0000000000000001
>> > 0000000000000001
>> > [  232.870230]  0000000000000000 ffffea0032337080 0000000080000000
>> > ffff880586e33400
>> > [  232.870230] Call Trace:
>> > [  232.870230]  [<mm/memory.c:3467>] do_shared_fault+0x1a1/0x1f0
>> > [  232.870230]  [<mm/memory.c:3487>] handle_pte_fault+0xc8/0x230
>> > [  232.870230]  [<arch/x86/include/asm/preempt.h:98>] ? delay_tsc+0xea/0x110
>> > [  232.870230]  [<mm/memory.c:3770>] __handle_mm_fault+0x36e/0x3a0
>> > [  232.870230]  [<include/linux/rcupdate.h:829>] ? rcu_read_unlock+0x5d/0x60
>> > [  232.870230]  [<include/linux/memcontrol.h:148>]
>> > handle_mm_fault+0x10b/0x1b0
>> > [  232.870230]  [<arch/x86/mm/fault.c:1147>] ? __do_page_fault+0x2e2/0x590
>> > [  232.870230]  [<arch/x86/mm/fault.c:1214>] __do_page_fault+0x551/0x590
>> > [  232.870230]  [<kernel/sched/cputime.c:681>] ?
>> > vtime_account_user+0x91/0xa0
>> > [  232.870230]  [<arch/x86/include/asm/atomic.h:26>] ?
>> > context_tracking_user_exit+0xa8/0x1c0
>> > [  232.870230]  [<arch/x86/include/asm/preempt.h:98>] ?
>> > _raw_spin_unlock+0x30/0x50
>> > [  232.870230]  [<kernel/sched/cputime.c:681>] ?
>> > vtime_account_user+0x91/0xa0
>> > [  232.870230]  [<arch/x86/include/asm/atomic.h:26>] ?
>> > context_tracking_user_exit+0xa8/0x1c0
>> > [  232.870230]  [<arch/x86/include/asm/atomic.h:26>] do_page_fault+0x3d/0x70
>> > [  232.870230]  [<arch/x86/kernel/kvm.c:263>] do_async_page_fault+0x35/0x100
>> > [  232.870230]  [<arch/x86/kernel/entry_64.S:1496>]
>> > async_page_fault+0x28/0x30
>> > [  232.870230] Code: 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48
>> > 83 ec 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 48 89 fb 48 8b 87 50 01 00 00
>> > <f6> 40 20 01 0f 85 18 01 00 00 65 48 8b 14 25 40 da 00 00 44 8b
>> > [  232.870230] RIP  [<mm/page-writeback.c:1612>]
>> > balance_dirty_pages_ratelimited+0x1e/0x150
>> > [  232.870230]  RSP <ffff880586e35c58>
>> > [  232.870230] CR2: 0000000000000020
>> >
>> >
>>
>> Could you please test below patch? I think it may fix this issue.
>
> What stops compiler from transform this back to unpatched?

Sorry for my fault. I'll format a patch later.

> Do you relay on unlock_page() to have a compiler barrier?
>

Before your commit mapping is a local variable and be assigned before
unlock_page():
struct address_space *mapping = page->mapping;
unlock_page(dirty_page);
put_page(dirty_page);
if ((dirtied || page_mkwrite) && mapping) {


I'm afraid now "fault_page->mapping" might be changed to NULL after
"if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {"
and then passed down to balance_dirty_pages_ratelimited(NULL).

>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 548d97e..90cea22 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3419,6 +3419,7 @@ static int do_shared_fault(struct mm_struct *mm,
>> struct vm_area_struct *vma,
>>   pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
>>  {
>>   struct page *fault_page;
>> + struct address_space *mapping;
>>   spinlock_t *ptl;
>>   pte_t *pte;
>>   int dirtied = 0;
>> @@ -3454,13 +3455,14 @@ static int do_shared_fault(struct mm_struct
>> *mm, struct vm_area_struct *vma,
>>
>>   if (set_page_dirty(fault_page))
>>   dirtied = 1;
>> + mapping = fault_page->mapping;
>>   unlock_page(fault_page);
>> - if ((dirtied || vma->vm_ops->page_mkwrite) && fault_page->mapping) {
>> + if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
>>   /*
>>   * Some device drivers do not set page.mapping but still
>>   * dirty their pages
>>   */
>> - balance_dirty_pages_ratelimited(fault_page->mapping);
>> + balance_dirty_pages_ratelimited(mapping);
>>   }
>>
>>   /* file_update_time outside page_lock */
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
> --
>  Kirill A. Shutemov

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
