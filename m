Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B99BD6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 06:53:40 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so33201553wgj.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 03:53:40 -0700 (PDT)
Received: from johanna3.inet.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id xs10si2711545wjc.81.2015.07.01.03.53.38
        for <linux-mm@kvack.org>;
        Wed, 01 Jul 2015 03:53:39 -0700 (PDT)
Date: Wed, 1 Jul 2015 13:53:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 16/24] huge tmpfs: fix problems from premature exposure
 of pagetable
Message-ID: <20150701105334.GA18721@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
 <alpine.LSU.2.11.1502202015090.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1502202015090.14414@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 20, 2015 at 08:16:32PM -0800, Hugh Dickins wrote:
> Andrea wrote a very interesting comment on THP in mm/memory.c,
> just before the end of __handle_mm_fault():
> 
>  * A regular pmd is established and it can't morph into a huge pmd
>  * from under us anymore at this point because we hold the mmap_sem
>  * read mode and khugepaged takes it in write mode. So now it's
>  * safe to run pte_offset_map().
> 
> This comment hints at several difficulties, which anon THP solved
> for itself with mmap_sem and anon_vma lock, but which huge tmpfs
> may need to solve differently.
> 
> The reference to pte_offset_map() above: I believe that's a hint
> that on a 32-bit machine, the pagetables might need to come from
> kernel-mapped memory, but a huge pmd pointing to user memory beyond
> that limit could be racily substituted, causing undefined behavior
> in the architecture-dependent pte_offset_map().
> 
> That itself is not a problem on x86_64, but there's plenty more:
> how about those places which use pte_offset_map_lock() - if that
> spinlock is in the struct page of a pagetable, which has been
> deposited and might be withdrawn and freed at any moment (being
> on a list unattached to the allocating pmd in the case of x86),
> taking the spinlock might corrupt someone else's struct page.
> 
> Because THP has departed from the earlier rules (when pagetable
> was only freed under exclusive mmap_sem, or at exit_mmap, after
> removing all affected vmas from the rmap list): zap_huge_pmd()
> does pte_free() even when serving MADV_DONTNEED under down_read
> of mmap_sem.
> 
> And what of the "entry = *pte" at the start of handle_pte_fault(),
> getting the entry used in pte_same(,orig_pte) tests to validate all
> fault handling?  If that entry can itself be junk picked out of some
> freed and reused pagetable, it's hard to estimate the consequences.
> 
> We need to consider the safety of concurrent faults, and the
> safety of rmap lookups, and the safety of miscellaneous operations
> such as smaps_pte_range() for reading /proc/<pid>/smaps.
> 
> I set out to make safe the places which descend pgd,pud,pmd,pte,
> using more careful access techniques like mm_find_pmd(); but with
> pte_offset_map() being architecture-defined, it's too big a job to
> tighten it up all over.
> 
> Instead, approach from the opposite direction: just do not expose
> a pagetable in an empty *pmd, until vm_ops->fault has had a chance
> to ask for a huge pmd there.  This is a much easier change to make,
> and we are lucky that all the driver faults appear to be using
> interfaces (like vm_insert_page() and remap_pfn_range()) which
> automatically do the pte_alloc() if it was not already done.
> 
> But we must not get stuck refaulting: need FAULT_FLAG_MAY_HUGE for
> __do_fault() to tell shmem_fault() to try for huge only when *pmd is
> empty (could instead add pmd to vmf and let shmem work that out for
> itself, but probably better to hide pmd from vm_ops->faults).
> 
> Without a pagetable to hold the pte_none() entry found in a newly
> allocated pagetable, handle_pte_fault() would like to provide a static
> none entry for later orig_pte checks.  But architectures have never had
> to provide that definition before; and although almost all use zeroes
> for an empty pagetable, a few do not - nios2, s390, um, xtensa.
> 
> Never mind, forget about pte_same(,orig_pte), the three __do_fault()
> callers can follow do_anonymous_page()'s example, and just use a
> pte_none() check instead - supplemented by a pte_file pte_to_pgoff
> check until the day VM_NONLINEAR is removed.
> 
> do_fault_around() presents one last problem: it wants pagetable to
> have been allocated, but was being called by do_read_fault() before
> __do_fault().  But I see no disadvantage to moving it after,
> allowing huge pmd to be chosent first.

One disadvantage is addtional radix-tree lookup for page cache hot case.
IIRC, the difference was small, but measurable back when I implemented
faultaround.

Have you considered pushing page table allocation even futher -- into
do_set_pte()?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
