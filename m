Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 588B06B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 17:46:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z11-v6so7626081pfn.1
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 14:46:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21-v6sor3925553pfj.32.2018.06.17.14.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Jun 2018 14:46:09 -0700 (PDT)
Date: Mon, 18 Jun 2018 06:46:05 +0900
From: Stafford Horne <shorne@gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Mark pages in use for page tables
Message-ID: <20180617214605.GC24595@lianli.shorne-pla.net>
References: <20180307134443.32646-1-willy@infradead.org>
 <20180307134443.32646-5-willy@infradead.org>
 <20180617150931.GB24595@lianli.shorne-pla.net>
 <20180617185222.GA21805@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180617185222.GA21805@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Sun, Jun 17, 2018 at 11:52:22AM -0700, Matthew Wilcox wrote:
> On Mon, Jun 18, 2018 at 12:09:31AM +0900, Stafford Horne wrote:
> > On Wed, Mar 07, 2018 at 05:44:43AM -0800, Matthew Wilcox wrote:
> > > Define a new PageTable bit in the page_type and use it to mark pages in
> > > use as page tables.  This can be helpful when debugging crashdumps or
> > > analysing memory fragmentation.  Add a KPF flag to report these pages
> > > to userspace and update page-types.c to interpret that flag.
> > 
> > I have bisected a regression on OpenRISC in v4.18-rc1 to this commit.  Using
> > our defconfig after boot I am getting:
> 
> Hi Stafford.  Thanks for the report!
> 
> >     BUG: Bad page state in process hostname  pfn:00b5c
> >     page:c1ff0b80 count:0 mapcount:-1024 mapping:00000000 index:0x0
> >     flags: 0x0()
> >     raw: 00000000 00000000 00000000 fffffbff 00000000 00000100 00000200 00000000
> >     page dumped because: nonzero mapcount
> >     Modules linked in:
> >     CPU: 1 PID: 38 Comm: hostname Tainted: G    B
> >     4.17.0-simple-smp-07461-g1d40a5ea01d5-dirty #993
> >     Call trace:
> >     [<(ptrval)>] show_stack+0x44/0x54
> >     [<(ptrval)>] dump_stack+0xb0/0xe8
> >     [<(ptrval)>] bad_page+0x138/0x174
> >     [<(ptrval)>] ? ipi_icache_page_inv+0x0/0x24
> >     [<(ptrval)>] ? cpumask_next+0x24/0x34
> >     [<(ptrval)>] free_pages_check_bad+0x6c/0xd0
> >     [<(ptrval)>] free_pcppages_bulk+0x174/0x42c
> >     [<(ptrval)>] free_unref_page_commit.isra.17+0xb8/0xc8
> >     [<(ptrval)>] free_unref_page_list+0x10c/0x190
> >     [<(ptrval)>] ? set_reset_devices+0x0/0x2c
> >     [<(ptrval)>] release_pages+0x3a0/0x414
> >     [<(ptrval)>] tlb_flush_mmu_free+0x5c/0x90
> >     [<(ptrval)>] tlb_flush_mmu+0x90/0xa4
> >     [<(ptrval)>] arch_tlb_finish_mmu+0x50/0x94
> >     [<(ptrval)>] tlb_finish_mmu+0x30/0x64
> >     [<(ptrval)>] exit_mmap+0x110/0x1e0
> >     [<(ptrval)>] mmput+0x50/0xf0
> >     [<(ptrval)>] do_exit+0x274/0xa94
> >     [<(ptrval)>] ? _raw_spin_unlock_irqrestore+0x1c/0x2c
> >     [<(ptrval)>] ? __up_read+0x70/0x88
> >     [<(ptrval)>] do_group_exit+0x50/0x110
> >     [<(ptrval)>] __wake_up_parent+0x0/0x38
> >     [<(ptrval)>] _syscall_return+0x0/0x4
> > 
> > 
> > In this series we are overloading mapcount with page_type, the above is caused
> > due to this check in mm/page_alloc.c (free_pages_check_bad):
> > 
> >         if (unlikely(atomic_read(&page->_mapcount) != -1))
> >                 bad_reason = "nonzero mapcount";
> > 
> > We can see in the dump above that _mapcount is fffffbff, this corresponds to the
> > 'PG_table' flag.  Which was added here.  But it seems for some case in openrisc
> > its not getting cleared during page free.
> > 
> > This is as far as I got tracing it.  It might be an issue with OpenRISC, but our
> > implementation is mostly generic.  I will look into it more in the next few days
> > but I figured you might be able to spot something more quickly.
> 
> More than happy to help.  You've done a great job of debugging this.
> I think the problem is in your __pte_free_tlb definition.  Most other
> architectures are doing:
> 
> #define __pte_free_tlb(tlb, pte, address) pte_free((tlb)->mm, pte)
> 
> while you're doing:
> 
> #define __pte_free_tlb(tlb, pte, addr) tlb_remove_page((tlb), (pte))
> 
> and that doesn't call pgtable_page_dtor().
> 
> Up to you how you want to fix this ;-)  x86 defines a ___pte_free_tlb which
> calls pgtable_page_dtor() before calling tlb_remove_table() as an example.

I will do it the x86 way unless anyone has a concern, I notice a few other do it
this way too.  I have tested it out and it works fine.

Thanks a lot for your help.

-Stafford
