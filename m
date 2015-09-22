Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8D646B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:45:24 -0400 (EDT)
Received: by lagj9 with SMTP id j9so26157310lag.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:45:24 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id y15si1122456lfd.55.2015.09.22.12.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 12:45:23 -0700 (PDT)
Received: by lagj9 with SMTP id j9so26156741lag.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:45:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1509221151370.11653@eggly.anvils>
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
Date: Tue, 22 Sep 2015 21:45:22 +0200
Message-ID: <CAAeHK+zkG4L7TJ3M8fus8F5KExHRMhcyjgEQop=wqOpBcrKzYQ@mail.gmail.com>
Subject: Re: Multiple potential races on vma->vm_flags
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, Sep 22, 2015 at 8:54 PM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 22 Sep 2015, Andrey Konovalov wrote:
>> If anybody comes up with a patch to fix the original issue I easily
>> can test it, since I'm hitting "BUG: Bad page state" in a second when
>> fuzzing with KTSAN and Trinity.
>
> This "BUG: Bad page state" sounds more serious, but I cannot track down
> your report of it: please repost - thanks - though on seeing it, I may
> well end up with no ideas.

The report is below.

I get it after a few seconds of running Trinity on a kernel with KTSAN
and targeting mlock, munlock and madvise syscalls.
Sasha also observed a very similar crash a while ago
(https://lkml.org/lkml/2014/11/6/1055).
I didn't manage to reproduce this in a kernel build without KTSAN though.
The idea was that data races KTSAN reports might be the explanation of
these crashes.

BUG: Bad page state in process trinity-c15  pfn:281999
page:ffffea000a066640 count:0 mapcount:0 mapping:          (null) index:0xd
flags: 0x20000000028000c(referenced|uptodate|swapbacked|mlocked)
page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
bad because of flags:
flags: 0x200000(mlocked)
Modules linked in:
CPU: 3 PID: 11190 Comm: trinity-c15 Not tainted 4.2.0-tsan #1295
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff821c3b70 0000000000000000 0000000100004741 ffff8800b857f948
 ffffffff81e9926c 0000000000000003 ffffea000a066640 ffff8800b857f978
 ffffffff811ce045 ffffffff821c3b70 ffffea000a066640 0000000000000001
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81e9926c>] dump_stack+0x63/0x81 lib/dump_stack.c:50
 [<ffffffff811ce045>] bad_page+0x115/0x1a0 mm/page_alloc.c:409
 [<     inline     >] free_pages_check mm/page_alloc.c:731
 [<ffffffff811cf3b8>] free_pages_prepare+0x2f8/0x330 mm/page_alloc.c:922
 [<ffffffff811d2911>] free_hot_cold_page+0x51/0x2b0 mm/page_alloc.c:1908
 [<ffffffff811d2bcf>] free_hot_cold_page_list+0x5f/0x100
mm/page_alloc.c:1956 (discriminator 3)
 [<ffffffff811dd9c1>] release_pages+0x151/0x300 mm/swap.c:967
 [<ffffffff811de723>] __pagevec_release+0x43/0x60 mm/swap.c:984
 [<     inline     >] pagevec_release include/linux/pagevec.h:69
 [<ffffffff811ef36a>] shmem_undo_range+0x4fa/0x9d0 mm/shmem.c:446
 [<ffffffff811ef86f>] shmem_truncate_range+0x2f/0x60 mm/shmem.c:540
 [<ffffffff811f15d5>] shmem_fallocate+0x555/0x6e0 mm/shmem.c:2086
 [<ffffffff812568d0>] vfs_fallocate+0x1e0/0x310 fs/open.c:303
 [<     inline     >] madvise_remove mm/madvise.c:326
 [<     inline     >] madvise_vma mm/madvise.c:378
 [<     inline     >] SYSC_madvise mm/madvise.c:528
 [<ffffffff81225548>] SyS_madvise+0x378/0x760 mm/madvise.c:459
 [<ffffffff8124ef36>] ? kt_atomic64_store+0x76/0x130 mm/ktsan/sync_atomic.c:161
 [<ffffffff81ea8691>] entry_SYSCALL_64_fastpath+0x31/0x95
arch/x86/entry/entry_64.S:188
Disabling lock debugging due to kernel taint

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
