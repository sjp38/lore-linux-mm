Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 218496B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:58:48 -0400 (EDT)
Received: by lbwr8 with SMTP id r8so76492624lbw.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:58:47 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id zv6si9733665lbb.62.2015.10.15.09.58.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:58:46 -0700 (PDT)
Received: by lbbpp2 with SMTP id pp2so47881628lbb.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:58:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510131448540.2288@eggly.anvils>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
	<55EC9221.4040603@oracle.com>
	<20150907114048.GA5016@node.dhcp.inet.fi>
	<55F0D5B2.2090205@oracle.com>
	<20150910083605.GB9526@node.dhcp.inet.fi>
	<CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
	<20150911103959.GA7976@node.dhcp.inet.fi>
	<alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
	<55F8572D.8010409@oracle.com>
	<20150915190143.GA18670@node.dhcp.inet.fi>
	<CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
	<alpine.LSU.2.11.1509221151370.11653@eggly.anvils>
	<CAAeHK+zkG4L7TJ3M8fus8F5KExHRMhcyjgEQop=wqOpBcrKzYQ@mail.gmail.com>
	<alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
	<CAAeHK+wwFG2y3BUbirrSE8v67PR4iZH3adWqPKr2jk17KTpJ_Q@mail.gmail.com>
	<alpine.LSU.2.11.1510131448540.2288@eggly.anvils>
Date: Thu, 15 Oct 2015 18:58:45 +0200
Message-ID: <CAAeHK+zPs45-H7YVx+ccfeq0W9YpQ0y7ixXg5rc36OhGk7dQzA@mail.gmail.com>
Subject: Re: Multiple potential races on vma->vm_flags
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Davidlohr Bueso <dave@stgolabs.net>, Sasha Levin <sasha.levin@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, Oct 14, 2015 at 12:33 AM, Hugh Dickins <hughd@google.com> wrote:
> I think I've found the answer to that at last: we were indeed
> all looking in the wrong direction.  Your ktsan tree shows
>
> static __always_inline int atomic_add_negative(int i, atomic_t *v)
> {
> #ifndef CONFIG_KTSAN
>         GEN_BINARY_RMWcc(LOCK_PREFIX "addl", v->counter, "er", i, "%0", "s");
> #else
>         return (ktsan_atomic32_fetch_add((void *)v, i,
>                         ktsan_memory_order_acq_rel) + i) < 0;
> #endif
> }
>
> but ktsan_atomic32_fetch_add() returns u32: so it looks like
> your implementation of atomic_add_negative() always returns 0,
> and page_remove_file_rmap() never calls clear_page_mlock(), as
> it ought when an Mlocked page has been truncated or punched out.
>
> /proc/meminfo gives you crazy AnonPages and Mapped too, yes?

Yes, you're correct, there was a bug in KTSAN annotations.
Thank you for finding this.

Fixing that bug fixes the bad page reports.
Sorry for troubling you with this.

The race reports are still there though.

>
>>
>> It seems that your patch doesn't fix the race from the report below, since pte
>> lock is not taken when 'vma->vm_flags &= ~VM_LOCKED;' (mlock.c:425)
>> is being executed. (Line numbers are from kernel with your patch applied.)
>
> I was not trying to "fix" that with my patch, because I couldn't find
> any problem with the way it reads vm_flags there; I can't even see any
> need for READ_ONCE or more barriers, we have sufficient locking already.
>
> Sure, try_to_unmap_one() may read vm_flags an instant before or after
> a racing mlock() or munlock() or exit_mmap() sets or clears VM_LOCKED;
> but the syscalls (or exit) then work their way up the address space to
> establish the final state, no problem.
>
> But I am glad you drew attention to the inadequacy of the
> down_read_trylock(mmap_sem) in try_to_unmap_one(), and since posting
> that patch (doing the mlock_vma_page under pt lock instead), I have
> identifed one case that it would fix - though it clearly wasn't
> involved in your stacktrace (it's a race with truncating COWed pages,
> but your trace was holepunching, which leaves the COWs alone).
>
> I'll go forward with that patch, but it rather falls into a series
> I was preparing, must finish up all their comments before posting.
>
> Hugh
>
>>
>> ===
>> ThreadSanitizer: data-race in munlock_vma_pages_range
>>
>> Write at 0xffff880282a93290 of size 8 by thread 2546 on CPU 2:
>>  [<ffffffff81211009>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
>>  [<     inline     >] munlock_vma_pages_all mm/internal.h:252
>>  [<ffffffff81215d03>] exit_mmap+0x163/0x190 mm/mmap.c:2824
>>  [<ffffffff81085635>] mmput+0x65/0x190 kernel/fork.c:708
>>  [<     inline     >] exit_mm kernel/exit.c:437
>>  [<ffffffff8108c2a7>] do_exit+0x457/0x1400 kernel/exit.c:733
>>  [<ffffffff8108ef3f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
>>  [<ffffffff810a03a5>] get_signal+0x375/0xa70 kernel/signal.c:2353
>>  [<ffffffff8100619c>] do_signal+0x2c/0xad0 arch/x86/kernel/signal.c:704
>>  [<ffffffff81006cbd>] do_notify_resume+0x7d/0x80 arch/x86/kernel/signal.c:749
>>  [<ffffffff81ea87a4>] int_signal+0x12/0x17 arch/x86/entry/entry_64.S:329
>>
>> Previous read at 0xffff880282a93290 of size 8 by thread 2545 on CPU 1:
>>  [<ffffffff8121bc1a>] try_to_unmap_one+0x6a/0x450 mm/rmap.c:1208
>>  [<     inline     >] rmap_walk_file mm/rmap.c:1522
>>  [<ffffffff8121d1a7>] rmap_walk+0x147/0x450 mm/rmap.c:1541
>>  [<ffffffff8121d962>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1405
>>  [<ffffffff81210640>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
>>  [<ffffffff81210af6>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
>>  [<ffffffff81211330>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
>>  [<     inline     >] munlock_vma_pages_all mm/internal.h:252
>>  [<ffffffff81215d03>] exit_mmap+0x163/0x190 mm/mmap.c:2824
>>  [<ffffffff81085635>] mmput+0x65/0x190 kernel/fork.c:708
>>  [<     inline     >] exit_mm kernel/exit.c:437
>>  [<ffffffff8108c2a7>] do_exit+0x457/0x1400 kernel/exit.c:733
>>  [<ffffffff8108ef3f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
>>  [<ffffffff810a03a5>] get_signal+0x375/0xa70 kernel/signal.c:2353
>>  [<ffffffff8100619c>] do_signal+0x2c/0xad0 arch/x86/kernel/signal.c:704
>>  [<ffffffff81006cbd>] do_notify_resume+0x7d/0x80 arch/x86/kernel/signal.c:749
>>  [<ffffffff81ea87a4>] int_signal+0x12/0x17 arch/x86/entry/entry_64.S:329
>> ===
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
