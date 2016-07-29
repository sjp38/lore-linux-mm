Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD8DB6B0262
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 04:23:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so141338626ith.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 01:23:47 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id r95si17935022ioi.214.2016.07.29.01.23.45
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 01:23:47 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <01fa01d1e94c$4be09210$e3a1b630$@alibaba-inc.com> <021901d1e96f$4b271830$e1754890$@alibaba-inc.com> <20160729081011.GA28534@black.fi.intel.com>
In-Reply-To: <20160729081011.GA28534@black.fi.intel.com>
Subject: Re: [PATCH] mm: fail prefaulting if page table allocation fails
Date: Fri, 29 Jul 2016 16:23:33 +0800
Message-ID: <022c01d1e972$7ee5ada0$7cb108e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: 'Vegard Nossum' <vegard.nossum@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org

> 
> On Fri, Jul 29, 2016 at 04:00:37PM +0800, Hillf Danton wrote:
> > >
> > > I ran into this:
> > >
> > >     BUG: sleeping function called from invalid context at mm/page_alloc.c:3784
> > >     in_atomic(): 0, irqs_disabled(): 0, pid: 1434, name: trinity-c1
> > >     2 locks held by trinity-c1/1434:
> > >      #0:  (&mm->mmap_sem){......}, at: [<ffffffff810ce31e>] __do_page_fault+0x1ce/0x8f0
> > >      #1:  (rcu_read_lock){......}, at: [<ffffffff81378f86>] filemap_map_pages+0xd6/0xdd0
> > >
> > >     CPU: 0 PID: 1434 Comm: trinity-c1 Not tainted 4.7.0+ #58
> > >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > >      ffff8800b662f698 ffff8800b662f548 ffffffff81d6d001 ffffffff83a61100
> > >      ffff8800b662f620 ffff8800b662f610 ffffffff81373fd1 0000000041b58ab3
> > >      ffffffff8406ca21 ffffffff81373e4c 0000000041b58ab3 ffffffff00000008
> > >     Call Trace:
> > >      [<ffffffff81d6d001>] dump_stack+0x65/0x84
> > >      [<ffffffff81373fd1>] panic+0x185/0x2dd
> > >      [<ffffffff8118e38c>] ___might_sleep+0x51c/0x600
> > >      [<ffffffff8118e500>] __might_sleep+0x90/0x1a0
> > >      [<ffffffff81392761>] __alloc_pages_nodemask+0x5b1/0x2160
> > >      [<ffffffff814665ac>] alloc_pages_current+0xcc/0x370
> > >      [<ffffffff810d95b2>] pte_alloc_one+0x12/0x90
> > >      [<ffffffff814053cd>] __pte_alloc+0x1d/0x200
> > >      [<ffffffff8140be4e>] alloc_set_pte+0xe3e/0x14a0
> > >      [<ffffffff813792db>] filemap_map_pages+0x42b/0xdd0
> > >      [<ffffffff8140e0d5>] handle_mm_fault+0x17d5/0x28b0
> > >      [<ffffffff810ce460>] __do_page_fault+0x310/0x8f0
> > >      [<ffffffff810cec7d>] trace_do_page_fault+0x18d/0x310
> > >      [<ffffffff810c2177>] do_async_page_fault+0x27/0xa0
> > >      [<ffffffff8389e258>] async_page_fault+0x28/0x30
> > >
> > > The important bits from the above is that filemap_map_pages() is calling
> > > into the page allocator while holding rcu_read_lock (sleeping is not
> > > allowed inside RCU read-side critical sections).
> > >
> > > According to Kirill Shutemov, the prefaulting code in do_fault_around()
> > > is supposed to take care of this, but missing error handling means that
> > > the allocation failure can go unnoticed.
> > >
> > Well it is fixed at this particular call site, thanks.
> >
> > On the other hand IIUC in alloc_set_pte() there is no acquiring of ptl if
> > fe->pte is valid, so race still sits there.
> 
> Could you elaborate on where you see the race? I didn't get it.
> 
In filemap_map_pages()
	CPU0					CPU1
	trylock_page at offset_A		trylock_page at offset_A
						goto offset_A+1
	if (!fe->pte) {
		alloc pte
		map pte
		lock pte
	}
	handle offset_A with ptl held		handle offset_A+1 without acquiring ptl

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
