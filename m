Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47C466B0005
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 11:09:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p16-v6so7281993pfn.7
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 08:09:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k70-v6sor2696279pgd.203.2018.06.17.08.09.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Jun 2018 08:09:34 -0700 (PDT)
Date: Mon, 18 Jun 2018 00:09:31 +0900
From: Stafford Horne <shorne@gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Mark pages in use for page tables
Message-ID: <20180617150931.GB24595@lianli.shorne-pla.net>
References: <20180307134443.32646-1-willy@infradead.org>
 <20180307134443.32646-5-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180307134443.32646-5-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Wed, Mar 07, 2018 at 05:44:43AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Define a new PageTable bit in the page_type and use it to mark pages in
> use as page tables.  This can be helpful when debugging crashdumps or
> analysing memory fragmentation.  Add a KPF flag to report these pages
> to userspace and update page-types.c to interpret that flag.
> 
> Note that only pages currently accounted as NR_PAGETABLES are tracked
> as PageTable; this does not include pgd/p4d/pud/pmd pages.  Those will
> be the subject of a later patch.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/tile/mm/pgtable.c                 | 3 +++
>  fs/proc/page.c                         | 2 ++
>  include/linux/mm.h                     | 2 ++
>  include/linux/page-flags.h             | 6 ++++++
>  include/uapi/linux/kernel-page-flags.h | 1 +
>  tools/vm/page-types.c                  | 1 +
>  6 files changed, 15 insertions(+)
> 


Helloi Matthew,

I have bisected a regression on OpenRISC in v4.18-rc1 to this commit.  Using
our defconfig after boot I am getting:

    BUG: Bad page state in process hostname  pfn:00b5c
    page:c1ff0b80 count:0 mapcount:-1024 mapping:00000000 index:0x0
    flags: 0x0()
    raw: 00000000 00000000 00000000 fffffbff 00000000 00000100 00000200 00000000
    page dumped because: nonzero mapcount
    Modules linked in:
    CPU: 1 PID: 38 Comm: hostname Tainted: G    B
    4.17.0-simple-smp-07461-g1d40a5ea01d5-dirty #993
    Call trace:
    [<(ptrval)>] show_stack+0x44/0x54
    [<(ptrval)>] dump_stack+0xb0/0xe8
    [<(ptrval)>] bad_page+0x138/0x174
    [<(ptrval)>] ? ipi_icache_page_inv+0x0/0x24
    [<(ptrval)>] ? cpumask_next+0x24/0x34
    [<(ptrval)>] free_pages_check_bad+0x6c/0xd0
    [<(ptrval)>] free_pcppages_bulk+0x174/0x42c
    [<(ptrval)>] free_unref_page_commit.isra.17+0xb8/0xc8
    [<(ptrval)>] free_unref_page_list+0x10c/0x190
    [<(ptrval)>] ? set_reset_devices+0x0/0x2c
    [<(ptrval)>] release_pages+0x3a0/0x414
    [<(ptrval)>] tlb_flush_mmu_free+0x5c/0x90
    [<(ptrval)>] tlb_flush_mmu+0x90/0xa4
    [<(ptrval)>] arch_tlb_finish_mmu+0x50/0x94
    [<(ptrval)>] tlb_finish_mmu+0x30/0x64
    [<(ptrval)>] exit_mmap+0x110/0x1e0
    [<(ptrval)>] mmput+0x50/0xf0
    [<(ptrval)>] do_exit+0x274/0xa94
    [<(ptrval)>] ? _raw_spin_unlock_irqrestore+0x1c/0x2c
    [<(ptrval)>] ? __up_read+0x70/0x88
    [<(ptrval)>] do_group_exit+0x50/0x110
    [<(ptrval)>] __wake_up_parent+0x0/0x38
    [<(ptrval)>] _syscall_return+0x0/0x4


In this series we are overloading mapcount with page_type, the above is caused
due to this check in mm/page_alloc.c (free_pages_check_bad):

        if (unlikely(atomic_read(&page->_mapcount) != -1))
                bad_reason = "nonzero mapcount";

We can see in the dump above that _mapcount is fffffbff, this corresponds to the
'PG_table' flag.  Which was added here.  But it seems for some case in openrisc
its not getting cleared during page free.

This is as far as I got tracing it.  It might be an issue with OpenRISC, but our
implementation is mostly generic.  I will look into it more in the next few days
but I figured you might be able to spot something more quickly.

-Stafford
