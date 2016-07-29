Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E69566B0260
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 04:10:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so104164304pfg.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 01:10:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id l29si17205700pfk.67.2016.07.29.01.10.14
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 01:10:14 -0700 (PDT)
Date: Fri, 29 Jul 2016 11:10:11 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: fail prefaulting if page table allocation fails
Message-ID: <20160729081011.GA28534@black.fi.intel.com>
References: <01fa01d1e94c$4be09210$e3a1b630$@alibaba-inc.com>
 <021901d1e96f$4b271830$e1754890$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <021901d1e96f$4b271830$e1754890$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Vegard Nossum' <vegard.nossum@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Jul 29, 2016 at 04:00:37PM +0800, Hillf Danton wrote:
> > 
> > I ran into this:
> > 
> >     BUG: sleeping function called from invalid context at mm/page_alloc.c:3784
> >     in_atomic(): 0, irqs_disabled(): 0, pid: 1434, name: trinity-c1
> >     2 locks held by trinity-c1/1434:
> >      #0:  (&mm->mmap_sem){......}, at: [<ffffffff810ce31e>] __do_page_fault+0x1ce/0x8f0
> >      #1:  (rcu_read_lock){......}, at: [<ffffffff81378f86>] filemap_map_pages+0xd6/0xdd0
> > 
> >     CPU: 0 PID: 1434 Comm: trinity-c1 Not tainted 4.7.0+ #58
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> >      ffff8800b662f698 ffff8800b662f548 ffffffff81d6d001 ffffffff83a61100
> >      ffff8800b662f620 ffff8800b662f610 ffffffff81373fd1 0000000041b58ab3
> >      ffffffff8406ca21 ffffffff81373e4c 0000000041b58ab3 ffffffff00000008
> >     Call Trace:
> >      [<ffffffff81d6d001>] dump_stack+0x65/0x84
> >      [<ffffffff81373fd1>] panic+0x185/0x2dd
> >      [<ffffffff8118e38c>] ___might_sleep+0x51c/0x600
> >      [<ffffffff8118e500>] __might_sleep+0x90/0x1a0
> >      [<ffffffff81392761>] __alloc_pages_nodemask+0x5b1/0x2160
> >      [<ffffffff814665ac>] alloc_pages_current+0xcc/0x370
> >      [<ffffffff810d95b2>] pte_alloc_one+0x12/0x90
> >      [<ffffffff814053cd>] __pte_alloc+0x1d/0x200
> >      [<ffffffff8140be4e>] alloc_set_pte+0xe3e/0x14a0
> >      [<ffffffff813792db>] filemap_map_pages+0x42b/0xdd0
> >      [<ffffffff8140e0d5>] handle_mm_fault+0x17d5/0x28b0
> >      [<ffffffff810ce460>] __do_page_fault+0x310/0x8f0
> >      [<ffffffff810cec7d>] trace_do_page_fault+0x18d/0x310
> >      [<ffffffff810c2177>] do_async_page_fault+0x27/0xa0
> >      [<ffffffff8389e258>] async_page_fault+0x28/0x30
> > 
> > The important bits from the above is that filemap_map_pages() is calling
> > into the page allocator while holding rcu_read_lock (sleeping is not
> > allowed inside RCU read-side critical sections).
> > 
> > According to Kirill Shutemov, the prefaulting code in do_fault_around()
> > is supposed to take care of this, but missing error handling means that
> > the allocation failure can go unnoticed.
> > 
> Well it is fixed at this particular call site, thanks. 
> 
> On the other hand IIUC in alloc_set_pte() there is no acquiring of ptl if 
> fe->pte is valid, so race still sits there. 

Could you elaborate on where you see the race? I didn't get it.

> Would you please address both?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
