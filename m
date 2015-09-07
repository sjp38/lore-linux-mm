Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 828856B0258
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 07:40:51 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so80895412wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:40:51 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id z17si20422963wij.0.2015.09.07.04.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 04:40:50 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so80995472wic.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 04:40:50 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:40:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Multiple potential races on vma->vm_flags
Message-ID: <20150907114048.GA5016@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
 <55EC9221.4040603@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55EC9221.4040603@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Sep 06, 2015 at 03:21:05PM -0400, Sasha Levin wrote:
> ==================================================================
> ThreadSanitizer: data-race in munlock_vma_pages_range
> 
> Write of size 8 by thread T378 (K2633, CPU3):
>  [<ffffffff81212579>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
>  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
> arch/x86/entry/entry_64.S:186

...

> Previous read of size 8 by thread T398 (K2623, CPU2):
>  [<ffffffff8121d198>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
>  [<     inlined    >] rmap_walk+0x147/0x450 rmap_walk_file mm/rmap.c:1540
>  [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
>  [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
>  [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
>  [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
>  [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
>  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
> arch/x86/entry/entry_64.S:186

Okay, the detected race is mlock/munlock vs. rmap.

On rmap side we check vma->vm_flags in few places without taking
vma->vm_mm->mmap_sem. The vma cannot be freed since we hold i_mmap_rwsem
or anon_vma_lock, but nothing prevent vma->vm_flags from changing under
us.

In this particular case, speculative check in beginning of
try_to_unmap_one() is fine, since we re-check it under mmap_sem later in
the function.

False-negative is fine too here, since we will mlock the page in
__mm_populate() on mlock side after mlock_fixup().

BUT.

We *must* have all speculative vm_flags accesses wrapped READ_ONCE() to
avoid all compiler trickery, like duplication vm_flags access with
inconsistent results.

I looked only on VM_LOCKED checks, but there are few other flags checked
in rmap. All of them must be handled carefully. At least READ_ONCE() is
required.

Other solution would be to introduce per-vma spinlock to protect
vma->vm_flags and probably other vma fields and offload this duty
from mmap_sem.
But that's much bigger project.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
