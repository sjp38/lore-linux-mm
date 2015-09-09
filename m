Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id D43426B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 12:01:36 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so8438639lbc.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 09:01:36 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id fq16si13267034wjc.124.2015.09.09.09.01.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 09:01:32 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so162986100wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 09:01:31 -0700 (PDT)
Date: Wed, 9 Sep 2015 19:01:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150909160129.GA9526@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
 <55EC9221.4040603@oracle.com>
 <20150907114048.GA5016@node.dhcp.inet.fi>
 <55F04FD4.6060308@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55F04FD4.6060308@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 09, 2015 at 05:27:16PM +0200, Vlastimil Babka wrote:
> On 09/07/2015 01:40 PM, Kirill A. Shutemov wrote:
> >On Sun, Sep 06, 2015 at 03:21:05PM -0400, Sasha Levin wrote:
> >>==================================================================
> >>ThreadSanitizer: data-race in munlock_vma_pages_range
> >>
> >>Write of size 8 by thread T378 (K2633, CPU3):
> >>  [<ffffffff81212579>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
> >>  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
> >>  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
> >>  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
> >>  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
> >>  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
> >>arch/x86/entry/entry_64.S:186
> >
> >...
> >
> >>Previous read of size 8 by thread T398 (K2623, CPU2):
> >>  [<ffffffff8121d198>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
> >>  [<     inlined    >] rmap_walk+0x147/0x450 rmap_walk_file mm/rmap.c:1540
> >>  [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
> >>  [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
> >>  [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
> >>  [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
> >>  [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
> >>  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
> >>  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
> >>  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
> >>  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
> >>  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
> >>arch/x86/entry/entry_64.S:186
> >
> >Okay, the detected race is mlock/munlock vs. rmap.
> >
> >On rmap side we check vma->vm_flags in few places without taking
> >vma->vm_mm->mmap_sem. The vma cannot be freed since we hold i_mmap_rwsem
> >or anon_vma_lock, but nothing prevent vma->vm_flags from changing under
> >us.
> >
> >In this particular case, speculative check in beginning of
> >try_to_unmap_one() is fine, since we re-check it under mmap_sem later in
> >the function.
> >
> >False-negative is fine too here, since we will mlock the page in
> >__mm_populate() on mlock side after mlock_fixup().
> >
> >BUT.
> >
> >We *must* have all speculative vm_flags accesses wrapped READ_ONCE() to
> >avoid all compiler trickery, like duplication vm_flags access with
> >inconsistent results.
> 
> Doesn't taking a semaphore, as in try_to_unmap_one(), already imply a
> compiler barrier forcing vm_flags to be re-read?

Yes, but it doesn't prevent compiler from generation multiple reads from
vma->vm_flags and it may blow up if two values doesn't match.

> >I looked only on VM_LOCKED checks, but there are few other flags checked
> >in rmap. All of them must be handled carefully. At least READ_ONCE() is
> >required.
> >
> >Other solution would be to introduce per-vma spinlock to protect
> >vma->vm_flags and probably other vma fields and offload this duty
> >from mmap_sem.
> >But that's much bigger project.
> 
> Sounds like an overkill, unless we find something more serious than this.

May be...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
