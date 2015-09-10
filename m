Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id AE01F6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:28:01 -0400 (EDT)
Received: by laeb10 with SMTP id b10so28295539lae.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:28:01 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id w4si10441692lad.89.2015.09.10.06.27.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 06:28:00 -0700 (PDT)
Received: by lbbmp1 with SMTP id mp1so23056497lbb.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:27:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150910083605.GB9526@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
	<55EC9221.4040603@oracle.com>
	<20150907114048.GA5016@node.dhcp.inet.fi>
	<55F0D5B2.2090205@oracle.com>
	<20150910083605.GB9526@node.dhcp.inet.fi>
Date: Thu, 10 Sep 2015 15:27:59 +0200
Message-ID: <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
Subject: Re: Multiple potential races on vma->vm_flags
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Can a vma be shared among a few mm's?
If yes, then taking current->mm->mmap_sem to protect vma is not enough.

In the first report below both T378 and T398 take
current->mm->mmap_sem at mm/mlock.c:650, but they turn out to be
different locks (the addresses are different).
In the second report T309 doesn't take any locks at all, since it
assumes that after checking atomic_dec_and_test(&mm->mm_users) the mm
has no other users, but then it does a write to vma.

==================================================================
ThreadSanitizer: data-race in munlock_vma_pages_range

Write of size 8 by thread T378 (K2633, CPU3):
 [<ffffffff81212579>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
 [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
 [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
 [<     inlined    >] SYSC_munlock mm/mlock.c:651
 [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

Locks held by T378:
#0 Lock 25710428 taken here:
 [<     inlined    >] SYSC_munlock mm/mlock.c:650
 [<ffffffff8121308c>] SyS_munlock+0x4c/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

Previous read of size 8 by thread T398 (K2623, CPU2):
 [<ffffffff8121d198>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
 [<     inlined    >] rmap_walk_file mm/rmap.c:1540
 [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
 [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
 [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
 [<     inlined    >] SYSC_munlock mm/mlock.c:651
 [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

Locks held by T398:
#0 Lock 21b00c68 taken here:
 [<     inlined    >] SYSC_munlock mm/mlock.c:650
 [<ffffffff8121308c>] SyS_munlock+0x4c/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
#1 Lock bac2d750 taken here:
 [<     inlined    >] i_mmap_lock_read include/linux/fs.h:509
 [<     inlined    >] rmap_walk_file mm/rmap.c:1533
 [<ffffffff8121e6e8>] rmap_walk+0x78/0x450 mm/rmap.c:1559
 [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
 [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
 [<     inlined    >] SYSC_munlock mm/mlock.c:651
 [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
#2 Lock 0895f570 taken here:
 [<     inlined    >] spin_lock include/linux/spinlock.h:312
 [<ffffffff8121c959>] __page_check_address+0xd9/0x210 mm/rmap.c:681
 [<     inlined    >] page_check_address include/linux/rmap.h:204
 [<ffffffff8121d173>] try_to_unmap_one+0x53/0x4f0 mm/rmap.c:1198
 [<     inlined    >] rmap_walk_file mm/rmap.c:1540
 [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
 [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
 [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
 [<     inlined    >] SYSC_munlock mm/mlock.c:651
 [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
 [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

DBG: addr: ffff880222610e10
DBG: first offset: 0, second offset: 0
DBG: T378 clock: {T378: 4486533, T398: 2405850}
DBG: T398 clock: {T398: 2406009}
==================================================================

==================================================================
ThreadSanitizer: data-race in munlock_vma_pages_range

Write of size 8 by thread T309 (K2577, CPU0):
 [<ffffffff81211fc9>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
 [<     inlined    >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81216cc3>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085685>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inlined    >] exit_mm kernel/exit.c:437
 [<ffffffff8108c3a7>] do_exit+0x457/0x1420 kernel/exit.c:733
 [<ffffffff8108f08f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<     inlined    >] SYSC_exit_group kernel/exit.c:885
 [<ffffffff8108f170>] __wake_up_parent+0x0/0x50 kernel/exit.c:883
 [<ffffffff81eadb2e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

Locks held by T309:

Previous read of size 8 by thread T293 (K2573, CPU3):
 [<ffffffff8121cbe8>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
 [<     inlined    >] rmap_walk_file mm/rmap.c:1540
 [<ffffffff8121e207>] rmap_walk+0x147/0x450 mm/rmap.c:1559
 [<ffffffff8121e9c2>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211600>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81211ab6>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812122f0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<     inlined    >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81216cc3>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085685>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inlined    >] exit_mm kernel/exit.c:437
 [<ffffffff8108c3a7>] do_exit+0x457/0x1420 kernel/exit.c:733
 [<ffffffff8108f08f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<     inlined    >] SYSC_exit_group kernel/exit.c:885
 [<ffffffff8108f170>] __wake_up_parent+0x0/0x50 kernel/exit.c:883
 [<ffffffff81eadb2e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

Locks held by T293:
#0 Lock bb0dc710 taken here:
 [<     inlined    >] i_mmap_lock_read include/linux/fs.h:509
 [<     inlined    >] rmap_walk_file mm/rmap.c:1533
 [<ffffffff8121e138>] rmap_walk+0x78/0x450 mm/rmap.c:1559
 [<ffffffff8121e9c2>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211600>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81211ab6>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812122f0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<     inlined    >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81216cc3>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085685>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inlined    >] exit_mm kernel/exit.c:437
 [<ffffffff8108c3a7>] do_exit+0x457/0x1420 kernel/exit.c:733
 [<ffffffff8108f08f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<     inlined    >] SYSC_exit_group kernel/exit.c:885
 [<ffffffff8108f170>] __wake_up_parent+0x0/0x50 kernel/exit.c:883
 [<ffffffff81eadb2e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186
#1 Lock 02e0f1b0 taken here:
 [<     inlined    >] spin_lock include/linux/spinlock.h:312
 [<ffffffff8121c3a9>] __page_check_address+0xd9/0x210 mm/rmap.c:681
 [<     inlined    >] page_check_address include/linux/rmap.h:204
 [<ffffffff8121cbc3>] try_to_unmap_one+0x53/0x4f0 mm/rmap.c:1198
 [<     inlined    >] rmap_walk_file mm/rmap.c:1540
 [<ffffffff8121e207>] rmap_walk+0x147/0x450 mm/rmap.c:1559
 [<ffffffff8121e9c2>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
 [<ffffffff81211600>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81211ab6>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff812122f0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<     inlined    >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81216cc3>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085685>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inlined    >] exit_mm kernel/exit.c:437
 [<ffffffff8108c3a7>] do_exit+0x457/0x1420 kernel/exit.c:733
 [<ffffffff8108f08f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<     inlined    >] SYSC_exit_group kernel/exit.c:885
 [<ffffffff8108f170>] __wake_up_parent+0x0/0x50 kernel/exit.c:883
 [<ffffffff81eadb2e>] entry_SYSCALL_64_fastpath+0x12/0x71
arch/x86/entry/entry_64.S:186

DBG: addr: ffff8800bb153a78
DBG: first offset: 0, second offset: 0
DBG: T309 clock: {T309: 1297809, T293: 747168}
DBG: T293 clock: {T293: 747528}
==================================================================

On Thu, Sep 10, 2015 at 10:36 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Sep 09, 2015 at 08:58:26PM -0400, Sasha Levin wrote:
>> On 09/07/2015 07:40 AM, Kirill A. Shutemov wrote:
>> > On Sun, Sep 06, 2015 at 03:21:05PM -0400, Sasha Levin wrote:
>> >> > ==================================================================
>> >> > ThreadSanitizer: data-race in munlock_vma_pages_range
>> >> >
>> >> > Write of size 8 by thread T378 (K2633, CPU3):
>> >> >  [<ffffffff81212579>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
>> >> >  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>> >> >  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>> >> >  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>> >> >  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>> >> >  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
>> >> > arch/x86/entry/entry_64.S:186
>> > ...
>> >
>> >> > Previous read of size 8 by thread T398 (K2623, CPU2):
>> >> >  [<ffffffff8121d198>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
>> >> >  [<     inlined    >] rmap_walk+0x147/0x450 rmap_walk_file mm/rmap.c:1540
>> >> >  [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
>> >> >  [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
>> >> >  [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
>> >> >  [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
>> >> >  [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
>> >> >  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>> >> >  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>> >> >  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>> >> >  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>> >> >  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
>> >> > arch/x86/entry/entry_64.S:186
>> > Okay, the detected race is mlock/munlock vs. rmap.
>> >
>> > On rmap side we check vma->vm_flags in few places without taking
>> > vma->vm_mm->mmap_sem. The vma cannot be freed since we hold i_mmap_rwsem
>> > or anon_vma_lock, but nothing prevent vma->vm_flags from changing under
>> > us.
>> >
>> > In this particular case, speculative check in beginning of
>> > try_to_unmap_one() is fine, since we re-check it under mmap_sem later in
>> > the function.
>>
>> So you're suggesting that this isn't the cause of the bad page flags
>> error observed by Andrey and myself?
>
> I don't see it, but who knows.
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
