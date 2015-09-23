Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id AB4566B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 07:46:40 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so234148019wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 04:46:40 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id du1si10715197wib.20.2015.09.23.04.46.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 04:46:39 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so234147423wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 04:46:39 -0700 (PDT)
Date: Wed, 23 Sep 2015 14:46:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150923114636.GB25020@node.dhcp.inet.fi>
References: <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
 <20150911103959.GA7976@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
 <55F8572D.8010409@oracle.com>
 <20150915190143.GA18670@node.dhcp.inet.fi>
 <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
 <alpine.LSU.2.11.1509221151370.11653@eggly.anvils>
 <CAAeHK+zkG4L7TJ3M8fus8F5KExHRMhcyjgEQop=wqOpBcrKzYQ@mail.gmail.com>
 <alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrey Konovalov <andreyknvl@google.com>, Sasha Levin <sasha.levin@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, Sep 22, 2015 at 06:39:52PM -0700, Hugh Dickins wrote:
> On Tue, 22 Sep 2015, Andrey Konovalov wrote:
> > On Tue, Sep 22, 2015 at 8:54 PM, Hugh Dickins <hughd@google.com> wrote:
> > > On Tue, 22 Sep 2015, Andrey Konovalov wrote:
> > >> If anybody comes up with a patch to fix the original issue I easily
> > >> can test it, since I'm hitting "BUG: Bad page state" in a second when
> > >> fuzzing with KTSAN and Trinity.
> > >
> > > This "BUG: Bad page state" sounds more serious, but I cannot track down
> > > your report of it: please repost - thanks - though on seeing it, I may
> > > well end up with no ideas.
> > 
> > The report is below.
> 
> Thanks.
> 
> > 
> > I get it after a few seconds of running Trinity on a kernel with KTSAN
> > and targeting mlock, munlock and madvise syscalls.
> > Sasha also observed a very similar crash a while ago
> > (https://lkml.org/lkml/2014/11/6/1055).
> > I didn't manage to reproduce this in a kernel build without KTSAN though.
> > The idea was that data races KTSAN reports might be the explanation of
> > these crashes.
> > 
> > BUG: Bad page state in process trinity-c15  pfn:281999
> > page:ffffea000a066640 count:0 mapcount:0 mapping:          (null) index:0xd
> > flags: 0x20000000028000c(referenced|uptodate|swapbacked|mlocked)
> > page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> > bad because of flags:
> > flags: 0x200000(mlocked)
> > Modules linked in:
> > CPU: 3 PID: 11190 Comm: trinity-c15 Not tainted 4.2.0-tsan #1295
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >  ffffffff821c3b70 0000000000000000 0000000100004741 ffff8800b857f948
> >  ffffffff81e9926c 0000000000000003 ffffea000a066640 ffff8800b857f978
> >  ffffffff811ce045 ffffffff821c3b70 ffffea000a066640 0000000000000001
> > Call Trace:
> >  [<     inline     >] __dump_stack lib/dump_stack.c:15
> >  [<ffffffff81e9926c>] dump_stack+0x63/0x81 lib/dump_stack.c:50
> >  [<ffffffff811ce045>] bad_page+0x115/0x1a0 mm/page_alloc.c:409
> >  [<     inline     >] free_pages_check mm/page_alloc.c:731
> >  [<ffffffff811cf3b8>] free_pages_prepare+0x2f8/0x330 mm/page_alloc.c:922
> >  [<ffffffff811d2911>] free_hot_cold_page+0x51/0x2b0 mm/page_alloc.c:1908
> >  [<ffffffff811d2bcf>] free_hot_cold_page_list+0x5f/0x100
> > mm/page_alloc.c:1956 (discriminator 3)
> >  [<ffffffff811dd9c1>] release_pages+0x151/0x300 mm/swap.c:967
> >  [<ffffffff811de723>] __pagevec_release+0x43/0x60 mm/swap.c:984
> >  [<     inline     >] pagevec_release include/linux/pagevec.h:69
> >  [<ffffffff811ef36a>] shmem_undo_range+0x4fa/0x9d0 mm/shmem.c:446
> >  [<ffffffff811ef86f>] shmem_truncate_range+0x2f/0x60 mm/shmem.c:540
> >  [<ffffffff811f15d5>] shmem_fallocate+0x555/0x6e0 mm/shmem.c:2086
> >  [<ffffffff812568d0>] vfs_fallocate+0x1e0/0x310 fs/open.c:303
> >  [<     inline     >] madvise_remove mm/madvise.c:326
> >  [<     inline     >] madvise_vma mm/madvise.c:378
> >  [<     inline     >] SYSC_madvise mm/madvise.c:528
> >  [<ffffffff81225548>] SyS_madvise+0x378/0x760 mm/madvise.c:459
> >  [<ffffffff8124ef36>] ? kt_atomic64_store+0x76/0x130 mm/ktsan/sync_atomic.c:161
> >  [<ffffffff81ea8691>] entry_SYSCALL_64_fastpath+0x31/0x95
> > arch/x86/entry/entry_64.S:188
> > Disabling lock debugging due to kernel taint
> 
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

Indeed. Looks fishy. But probably will work.

That was not obvious for me what makes clearing VM_LOCKED visible in
try_to_unmap_one() without mmap_sem.

After looking some more it seems we would rely on page_check_address()
in try_to_unmap_one() having acquire semantics and follow_page_mask() in
munlock_vma_pages_range() having release semantics.

But I would prefer to have something more explicit.

That's mess.

> 
> I'd rather wait to hear whether this appears to work in practice,
> and whether you agree that it should work in theory, before writing
> the proper description.  I'd love to lose that down_read_trylock.
> 
> You mention how Sasha hit the "Bad page state (mlocked)" back in
> November: that was one of the reasons we reverted Davidlohr's
> i_mmap_lock_read to i_mmap_lock_write in unmap_mapping_range(),
> without understanding why it was needed.  Yes, it would lock out
> a concurrent try_to_unmap(), whose setting of PageMlocked was not
> sufficiently serialized by the down_read_trylock of mmap_sem.
> 
> But I don't remember the other reasons for that revert (and
> haven't looked very hard as yet): anyone else remember?

I hoped Davidlohr will come back with something after the revert, but it
never happend. I think the reverted patch was responsible for most of
scalability boost from rwsem for i_mmap_lock...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
