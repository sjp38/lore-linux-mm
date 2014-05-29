Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0266B0055
	for <linux-mm@kvack.org>; Thu, 29 May 2014 04:59:48 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so44718pab.22
        for <linux-mm@kvack.org>; Thu, 29 May 2014 01:59:47 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id iw9si33803pac.85.2014.05.29.01.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 01:59:46 -0700 (PDT)
Message-ID: <1401353983.4930.15.camel@concordia>
Subject: Re: BUG at mm/memory.c:1489!
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 29 May 2014 18:59:43 +1000
In-Reply-To: <alpine.LSU.2.11.1405281712310.7156@eggly.anvils>
References: <1401265922.3355.4.camel@concordia>
	 <alpine.LSU.2.11.1405281712310.7156@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Wed, 2014-05-28 at 17:33 -0700, Hugh Dickins wrote:
> On Wed, 28 May 2014, Michael Ellerman wrote:
> > Linux Blade312-5 3.15.0-rc7 #306 SMP Wed May 28 17:51:18 EST 2014 ppc64
> > 
> > [watchdog] 27853 iterations. [F:22642 S:5174 HI:1276]
> > ------------[ cut here ]------------
> > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > cpu 0xc: Vector: 700 (Program Check) at [c000000384eaf960]
> >     pc: c0000000001ad6f0: .follow_page_mask+0x90/0x650
> >     lr: c0000000001ad6d8: .follow_page_mask+0x78/0x650
> >     sp: c000000384eafbe0
> >    msr: 8000000000029032
> >   current = 0xc0000003c27e1bc0
> >   paca    = 0xc000000001dc3000   softe: 0        irq_happened: 0x01
> >     pid   = 20800, comm = trinity-c12
> > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > enter ? for help
> > [c000000384eafcc0] c0000000001e5514 .SyS_move_pages+0x524/0x7d0
> > [c000000384eafe30] c00000000000a1d8 syscall_exit+0x0/0x98
> > --- Exception: c01 (System Call) at 00003fff795f30a8
> > SP (3ffff958f290) is in userspace
> > 
> > I've left it in the debugger, can dig into it a bit more tomorrow
> > if anyone has any clues.
> 
> Thanks for leaving it overnight, but this one is quite obvious,
> so go ahead and reboot whenever suits you.
> 
> Trinity didn't even need to do anything bizarre to get this: that
> ordinary path simply didn't get tried on powerpc or ia64 before.
> 
> Here's a patch which should fix it for you, but I believe leaves
> a race in common with other architectures.  I must turn away to
> other things, and hope Naoya-san can fix up the locking separately
> (or point out why it's already safe).
> 
> [PATCH] mm: fix move_pages follow_page huge_addr BUG
> 
> v3.12's e632a938d914 ("mm: migrate: add hugepage migration code to
> move_pages()") is okay on most arches, but on follow_huge_addr-style
> arches ia64 and powerpc, it hits my old BUG_ON(flags & FOLL_GET)
> from v2.6.15 deceb6cd17e6 ("mm: follow_page with inner ptlock").
> 
> The point of the BUG_ON was that nothing needed FOLL_GET there at
> the time, and it was not clear that we have sufficient locking to
> use get_page() safely here on the outside - maybe the page found has
> already been freed and even reused when follow_huge_addr() returns.
> 
> I suspect that e632a938d914's use of get_page() after return from
> follow_huge_pmd() has the same problem: what prevents a racing
> instance of move_pages() from already migrating away and freeing
> that page by then?  A reference to the page should be taken while
> holding suitable lock (huge_pte_lockptr?), to serialize against
> concurrent migration.
> 
> But I'm not prepared to rework the hugetlb locking here myself;
> so for now just supply a patch to copy e632a938d914's get_page()
> after follow_huge_pmd() to after follow_huge_addr(): removing
> the BUG_ON(flags & FOLL_GET), but probably leaving a race.

Thanks for the detailed explanation Hugh.

Unfortunately I don't know our mm/hugetlb code well enough to give you a good
answer. Ben had a quick look at our follow_huge_addr() and thought it looked
"fishy". He suggested something like what we do in gup_pte_range() with
page_cache_get_speculative() might be in order.

Applying your patch and running trinity pretty immediately results in the
following, which looks related (sys_move_pages() again) ?

Unable to handle kernel paging request for data at address 0xf2000f80000000
Faulting instruction address: 0xc0000000001e29bc
cpu 0x1b: Vector: 300 (Data Access) at [c0000003c70f76f0]
    pc: c0000000001e29bc: .remove_migration_pte+0x9c/0x320
    lr: c0000000001e29b8: .remove_migration_pte+0x98/0x320
    sp: c0000003c70f7970
   msr: 8000000000009032
   dar: f2000f80000000
 dsisr: 40000000
  current = 0xc0000003f9045800
  paca    = 0xc000000001dc6c00   softe: 0        irq_happened: 0x01
    pid   = 3585, comm = trinity-c27
enter ? for help
[c0000003c70f7a20] c0000000001bce88 .rmap_walk+0x328/0x470
[c0000003c70f7ae0] c0000000001e2904 .remove_migration_ptes+0x44/0x60
[c0000003c70f7b80] c0000000001e4ce8 .migrate_pages+0x6d8/0xa00
[c0000003c70f7cc0] c0000000001e55ec .SyS_move_pages+0x5dc/0x7d0
[c0000003c70f7e30] c00000000000a1d8 syscall_exit+0x0/0x98
--- Exception: c01 (System Call) at 00003fff7b2b30a8
SP (3fffe09728a0) is in userspace
1b:mon> 

I've hit it twice in two runs:

Unable to handle kernel paging request for data at address 0xf2400f00000000
Faulting instruction address: 0xc0000000001e2a3c
cpu 0xd: Vector: 300 (Data Access) at [c00000038a4bf6f0]
    pc: c0000000001e2a3c: .remove_migration_pte+0x9c/0x320
    lr: c0000000001e2a38: .remove_migration_pte+0x98/0x320
    sp: c00000038a4bf970
   msr: 8000000000009032
   dar: f2400f00000000
 dsisr: 40000000
  current = 0xc0000003acd9e680
  paca    = 0xc000000001dc3400   softe: 0        irq_happened: 0x01
    pid   = 13334, comm = trinity-c13
enter ? for help
[c00000038a4bfa20] c0000000001bcf08 .rmap_walk+0x328/0x470
[c00000038a4bfae0] c0000000001e2984 .remove_migration_ptes+0x44/0x60
[c00000038a4bfb80] c0000000001e4d68 .migrate_pages+0x6d8/0xa00
[c00000038a4bfcc0] c0000000001e566c .SyS_move_pages+0x5dc/0x7d0
[c00000038a4bfe30] c00000000000a1d8 syscall_exit+0x0/0x98
--- Exception: c01 (System Call) at 00003fff79df30a8
SP (3fffda95d500) is in userspace
d:mon> 


If I tell trinity to skip sys_move_pages() it runs for hours.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
