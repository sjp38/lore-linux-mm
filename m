Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id B75BD6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 09:08:45 -0400 (EDT)
Received: by lagj9 with SMTP id j9so49735303lag.2
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:08:45 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com. [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id g3si3773987lag.57.2015.09.23.06.08.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 06:08:44 -0700 (PDT)
Received: by lahh2 with SMTP id h2so25434211lah.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:08:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
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
Date: Wed, 23 Sep 2015 15:08:43 +0200
Message-ID: <CAAeHK+wwFG2y3BUbirrSE8v67PR4iZH3adWqPKr2jk17KTpJ_Q@mail.gmail.com>
Subject: Re: Multiple potential races on vma->vm_flags
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Davidlohr Bueso <dave@stgolabs.net>, Sasha Levin <sasha.levin@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, Sep 23, 2015 at 3:39 AM, Hugh Dickins <hughd@google.com> wrote:
> This is totally untested, and one of you may quickly prove me wrong;
> but I went in to fix your "Bad page state (mlocked)" by holding pte
> lock across the down_read_trylock of mmap_sem in try_to_unmap_one(),
> then couldn't see why it would need mmap_sem at all, given how mlock
> and munlock first assert intention by setting or clearing VM_LOCKED
> in vm_flags, then work their way up the vma, taking pte locks.
>
> Calling mlock_vma_page() under pte lock may look suspicious
> at first: but what it does is similar to clear_page_mlock(),
> which we regularly call under pte lock from page_remove_rmap().
>
> I'd rather wait to hear whether this appears to work in practice,
> and whether you agree that it should work in theory, before writing
> the proper description.  I'd love to lose that down_read_trylock.

No, unfortunately it doesn't work, I still see "Bad page state (mlocked)".

It seems that your patch doesn't fix the race from the report below, since pte
lock is not taken when 'vma->vm_flags &= ~VM_LOCKED;' (mlock.c:425)
is being executed. (Line numbers are from kernel with your patch applied.)

===
ThreadSanitizer: data-race in munlock_vma_pages_range

Write at 0xffff880282a93290 of size 8 by thread 2546 on CPU 2:
 [<ffffffff81211009>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
 [<     inline     >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81215d03>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085635>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inline     >] exit_mm kernel/exit.c:437
 [<ffffffff8108c2a7>] do_exit+0x457/0x1400 kernel/exit.c:733
 [<ffffffff8108ef3f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<ffffffff810a03a5>] get_signal+0x375/0xa70 kernel/signal.c:2353
 [<ffffffff8100619c>] do_signal+0x2c/0xad0 arch/x86/kernel/signal.c:704
 [<ffffffff81006cbd>] do_notify_resume+0x7d/0x80 arch/x86/kernel/signal.c:749
 [<ffffffff81ea87a4>] int_signal+0x12/0x17 arch/x86/entry/entry_64.S:329

Previous read at 0xffff880282a93290 of size 8 by thread 2545 on CPU 1:
 [<ffffffff8121bc1a>] try_to_unmap_one+0x6a/0x450 mm/rmap.c:1208
 [<     inline     >] rmap_walk_file mm/rmap.c:1522
 [<ffffffff8121d1a7>] rmap_walk+0x147/0x450 mm/rmap.c:1541
 [<ffffffff8121d962>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1405
 [<ffffffff81210640>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
 [<ffffffff81210af6>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
 [<ffffffff81211330>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
 [<     inline     >] munlock_vma_pages_all mm/internal.h:252
 [<ffffffff81215d03>] exit_mmap+0x163/0x190 mm/mmap.c:2824
 [<ffffffff81085635>] mmput+0x65/0x190 kernel/fork.c:708
 [<     inline     >] exit_mm kernel/exit.c:437
 [<ffffffff8108c2a7>] do_exit+0x457/0x1400 kernel/exit.c:733
 [<ffffffff8108ef3f>] do_group_exit+0x7f/0x140 kernel/exit.c:874
 [<ffffffff810a03a5>] get_signal+0x375/0xa70 kernel/signal.c:2353
 [<ffffffff8100619c>] do_signal+0x2c/0xad0 arch/x86/kernel/signal.c:704
 [<ffffffff81006cbd>] do_notify_resume+0x7d/0x80 arch/x86/kernel/signal.c:749
 [<ffffffff81ea87a4>] int_signal+0x12/0x17 arch/x86/entry/entry_64.S:329
===

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
