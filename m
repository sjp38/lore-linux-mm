Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5D66B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:38:36 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b205so4685883wmb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:38:36 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id vl10si46273125wjc.75.2016.02.23.10.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:38:35 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id c200so234987397wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:38:35 -0800 (PST)
Date: Tue, 23 Feb 2016 21:38:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: THP race?
Message-ID: <20160223183832.GB21820@node.shutemov.name>
References: <20160223154950.GA22449@node.shutemov.name>
 <20160223180609.GC23289@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223180609.GC23289@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm@kvack.org

On Tue, Feb 23, 2016 at 07:06:09PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 23, 2016 at 06:49:50PM +0300, Kirill A. Shutemov wrote:
> > Hi Andrea,
> > 
> > I suspect there's race with THP in __handle_mm_fault(). It's pure
> > theoretical and race window is small, but..
> > 
> > Consider following scenario:
> > 
> >   - THP got allocated by other thread just before "pmd_none() &&
> >     __pte_alloc()" check, so pmd_none() is false and we don't
> >     allocate the page table.
> > 
> >   - But before pmd_trans_huge() check the page got unmap by
> >     MADV_DONTNEED in other thread.
> > 
> >   - At this point we will call pte_offset_map() for pmd which is
> >     pmd_none().
> > 
> > Nothing pleasant would happen after this...
> > 
> > Do you see anything what would prevent this scenario?
> 
> No so I think we need s/pmd_trans_huge/pmd_trans_unstable/ and use the
> atomic read in C to sort this out lockless. The MADV_DONTNEED part
> that isn't holding the mmap_sem for writing unfortunately wasn't
> sorted out immediately, that was unexpected in
> fact. pmd_trans_unstable() was introduced precisely to handle this
> trouble caused by MADV_DONTNEED running with the mmap_sem only for
> reading which causes infinite possible transactions back and forth
> between none and transhuge while holding only the mmap_sem for
> reading.
> 
> ==
> From eae4f251604299082dd824dc8acade71268c8d88 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 23 Feb 2016 18:56:55 +0100
> Subject: [PATCH 1/1] mm: thp: fix SMP race condition between THP page fault
>  and MADV_DONTNEED
> 
> pmd_trans_unstable/pmd_none_or_trans_huge_or_clear_bad were introduced
> to locklessy (but atomically) detect when a pmd is a regular (stable)
> pmd or when the pmd is unstable and can infinitely transition from
> pmd_none and pmd_trans_huge from under us, while only holding the
> mmap_sem for reading (for writing not).
> 
> While holding the mmap_sem only for reading, MADV_DONTNEED can run
> from under us and so before we can threat the pmd as regular we need
> to compare it against pmd_none and pmd_trans_huge in an atomic way,
> with pmd_trans_unstable(). The old pmd_trans_huge check is correct but
> it leaves a tiny window for a race.
> 
> Useful applications are unlikely to notice the difference as doing
> MADV_DONTNEED concurrently with a page fault would lead to undefined
> behavior.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/memory.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 635451a..d5912b0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3404,8 +3404,19 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (unlikely(pmd_none(*pmd)) &&
>  	    unlikely(__pte_alloc(mm, vma, pmd, address)))
>  		return VM_FAULT_OOM;
> -	/* if an huge pmd materialized from under us just retry later */
> -	if (unlikely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
> +	/*
> +	 * If an huge pmd materialized from under us just retry later.
> +	 * Use pmd_trans_unstable() instead of pmd_trans_huge() to
> +	 * ensure the pmd didn't become pmd_trans_huge from under us
> +	 * and then immediately back to pmd_none as result of
> +	 * MADV_DONTNEED running immediately after a huge_pmd fault of
> +	 * a different thread of this mm, in turn leading to a false
> +	 * negative pmd_trans_huge() retval. All we have to ensure is
> +	 * that it is a regular pmd that we can walk with
> +	 * pte_offset_map() and we can do that through an atomic read
> +	 * in C, which is what pmd_trans_unstable() is provided for.
> +	 */
> +	if (unlikely(pmd_trans_unstable(*pmd) || pmd_devmap(*pmd)))

pmd_trans_unstable(pmd), otherwise looks good:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

BTW, I guess DAX would need to introduce the same infrastructure for
pmd_devmap(). Dan?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
