Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0906B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 21:05:34 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so22677398obb.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 18:05:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ar6si6044359obc.104.2015.09.09.18.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 18:05:33 -0700 (PDT)
Message-ID: <55F0D5B2.2090205@oracle.com>
Date: Wed, 09 Sep 2015 20:58:26 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: Multiple potential races on vma->vm_flags
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi>
In-Reply-To: <20150907114048.GA5016@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/07/2015 07:40 AM, Kirill A. Shutemov wrote:
> On Sun, Sep 06, 2015 at 03:21:05PM -0400, Sasha Levin wrote:
>> > ==================================================================
>> > ThreadSanitizer: data-race in munlock_vma_pages_range
>> > 
>> > Write of size 8 by thread T378 (K2633, CPU3):
>> >  [<ffffffff81212579>] munlock_vma_pages_range+0x59/0x3e0 mm/mlock.c:425
>> >  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>> >  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>> >  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>> >  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>> >  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
>> > arch/x86/entry/entry_64.S:186
> ...
> 
>> > Previous read of size 8 by thread T398 (K2623, CPU2):
>> >  [<ffffffff8121d198>] try_to_unmap_one+0x78/0x4f0 mm/rmap.c:1208
>> >  [<     inlined    >] rmap_walk+0x147/0x450 rmap_walk_file mm/rmap.c:1540
>> >  [<ffffffff8121e7b7>] rmap_walk+0x147/0x450 mm/rmap.c:1559
>> >  [<ffffffff8121ef72>] try_to_munlock+0xa2/0xc0 mm/rmap.c:1423
>> >  [<ffffffff81211bb0>] __munlock_isolated_page+0x30/0x60 mm/mlock.c:129
>> >  [<ffffffff81212066>] __munlock_pagevec+0x236/0x3f0 mm/mlock.c:331
>> >  [<ffffffff812128a0>] munlock_vma_pages_range+0x380/0x3e0 mm/mlock.c:476
>> >  [<ffffffff81212ac9>] mlock_fixup+0x1c9/0x280 mm/mlock.c:549
>> >  [<ffffffff81212ccc>] do_mlock+0x14c/0x180 mm/mlock.c:589
>> >  [<     inlined    >] SyS_munlock+0x74/0xb0 SYSC_munlock mm/mlock.c:651
>> >  [<ffffffff812130b4>] SyS_munlock+0x74/0xb0 mm/mlock.c:643
>> >  [<ffffffff81eb352e>] entry_SYSCALL_64_fastpath+0x12/0x71
>> > arch/x86/entry/entry_64.S:186
> Okay, the detected race is mlock/munlock vs. rmap.
> 
> On rmap side we check vma->vm_flags in few places without taking
> vma->vm_mm->mmap_sem. The vma cannot be freed since we hold i_mmap_rwsem
> or anon_vma_lock, but nothing prevent vma->vm_flags from changing under
> us.
> 
> In this particular case, speculative check in beginning of
> try_to_unmap_one() is fine, since we re-check it under mmap_sem later in
> the function.

So you're suggesting that this isn't the cause of the bad page flags
error observed by Andrey and myself?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
