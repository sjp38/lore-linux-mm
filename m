Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 600066B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:38:56 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so33558473pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 15:38:56 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fw7si8150408pbd.82.2015.10.13.15.38.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 15:38:55 -0700 (PDT)
Received: by padcn9 with SMTP id cn9so2601352pad.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 15:38:55 -0700 (PDT)
Date: Tue, 13 Oct 2015 15:38:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Multiple potential races on vma->vm_flags
In-Reply-To: <560346F2.4050507@oracle.com>
Message-ID: <alpine.LSU.2.11.1510131534080.2288@eggly.anvils>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <alpine.LSU.2.11.1509111734480.7660@eggly.anvils> <55F8572D.8010409@oracle.com> <20150915190143.GA18670@node.dhcp.inet.fi>
 <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com> <alpine.LSU.2.11.1509221151370.11653@eggly.anvils> <CAAeHK+zkG4L7TJ3M8fus8F5KExHRMhcyjgEQop=wqOpBcrKzYQ@mail.gmail.com> <alpine.LSU.2.11.1509221831570.19790@eggly.anvils>
 <CAAeHK+wwFG2y3BUbirrSE8v67PR4iZH3adWqPKr2jk17KTpJ_Q@mail.gmail.com> <560346F2.4050507@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 23 Sep 2015, Sasha Levin wrote:
> On 09/23/2015 09:08 AM, Andrey Konovalov wrote:
> > On Wed, Sep 23, 2015 at 3:39 AM, Hugh Dickins <hughd@google.com> wrote:
> >> > This is totally untested, and one of you may quickly prove me wrong;
> >> > but I went in to fix your "Bad page state (mlocked)" by holding pte
> >> > lock across the down_read_trylock of mmap_sem in try_to_unmap_one(),
> >> > then couldn't see why it would need mmap_sem at all, given how mlock
> >> > and munlock first assert intention by setting or clearing VM_LOCKED
> >> > in vm_flags, then work their way up the vma, taking pte locks.
> >> >
> >> > Calling mlock_vma_page() under pte lock may look suspicious
> >> > at first: but what it does is similar to clear_page_mlock(),
> >> > which we regularly call under pte lock from page_remove_rmap().
> >> >
> >> > I'd rather wait to hear whether this appears to work in practice,
> >> > and whether you agree that it should work in theory, before writing
> >> > the proper description.  I'd love to lose that down_read_trylock.
> > No, unfortunately it doesn't work, I still see "Bad page state (mlocked)".
> > 
> > It seems that your patch doesn't fix the race from the report below, since pte
> > lock is not taken when 'vma->vm_flags &= ~VM_LOCKED;' (mlock.c:425)
> > is being executed. (Line numbers are from kernel with your patch applied.)
> 
> I've fired up my HZ_10000 patch, and this seems to be a real race that is
> somewhat easy to reproduce under those conditions.
> 
> Here's a fresh backtrace from my VMs:
> 
> [1935109.882343] BUG: Bad page state in process trinity-subchil  pfn:3ca200
> [1935109.884000] page:ffffea000f288000 count:0 mapcount:0 mapping:          (null) index:0x1e00 compound_mapcount: 0
> [1935109.885772] flags: 0x22fffff80144008(uptodate|head|swapbacked|mlocked)
> [1935109.887174] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> [1935109.888197] bad because of flags:
> [1935109.888759] flags: 0x100000(mlocked)
> [1935109.889525] Modules linked in:
> [1935109.890165] CPU: 8 PID: 2615 Comm: trinity-subchil Not tainted 4.3.0-rc2-next-20150923-sasha-00079-gec04207-dirty #2569
> [1935109.891876]  1ffffffff6445448 00000000e5dca494 ffff8803f7657708 ffffffffa70402da
> [1935109.893504]  ffffea000f288000 ffff8803f7657738 ffffffffa56e522b 022fffff80144008
> [1935109.894947]  ffffea000f288020 ffffea000f288000 00000000ffffffff ffff8803f76577a8
> [1935109.896413] Call Trace:
> [1935109.899102]  [<ffffffffa70402da>] dump_stack+0x4e/0x84
> [1935109.899821]  [<ffffffffa56e522b>] bad_page+0x17b/0x210
> [1935109.900469]  [<ffffffffa56e85a8>] free_pages_prepare+0xb48/0x1110
> [1935109.902127]  [<ffffffffa56ee0d1>] __free_pages_ok+0x21/0x260
> [1935109.904435]  [<ffffffffa56ee373>] free_compound_page+0x63/0x80
> [1935109.905614]  [<ffffffffa581b51e>] free_transhuge_page+0x6e/0x80

free_transhuge_page belongs to Kirill's THP refcounting patchset,
it's not in 4.3-rc or 4.3.0-rc2-next-20150923 or mmotm.
Well worth testing, thank you, but please make it clear what you
are testing: I'll not spend longer on this one, not at this time.

Hugh

> [1935109.906752]  [<ffffffffa5709f76>] __put_compound_page+0x76/0xa0
> [1935109.907884]  [<ffffffffa570a475>] release_pages+0x4d5/0x9f0
> [1935109.913027]  [<ffffffffa5769bea>] tlb_flush_mmu_free+0x8a/0x120
> [1935109.913957]  [<ffffffffa576f993>] unmap_page_range+0xe73/0x1460
> [1935109.915737]  [<ffffffffa57700a6>] unmap_single_vma+0x126/0x2f0
> [1935109.916646]  [<ffffffffa577270d>] unmap_vmas+0xdd/0x190
> [1935109.917454]  [<ffffffffa5790361>] exit_mmap+0x221/0x430
> [1935109.921176]  [<ffffffffa5366da1>] mmput+0xb1/0x240
> [1935109.921919]  [<ffffffffa537b3b2>] do_exit+0x732/0x27c0
> [1935109.928561]  [<ffffffffa537d599>] do_group_exit+0xf9/0x300
> [1935109.929786]  [<ffffffffa537d7bd>] SyS_exit_group+0x1d/0x20
> [1935109.930617]  [<ffffffffaf59fbf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> 
> 
> Thanks,
> Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
