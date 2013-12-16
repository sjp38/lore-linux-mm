Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3E53D6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:48:39 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5269312pdj.16
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:48:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id eb3si8797052pbc.206.2013.12.16.04.48.37
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 04:48:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com>
 <52AA0613.2000908@oracle.com>
 <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Content-Transfer-Encoding: 7bit
Message-Id: <20131216124754.29063E0090@blue.fi.intel.com>
Date: Mon, 16 Dec 2013 14:47:54 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Linus Torvalds wrote:
> On Sun, Dec 15, 2013 at 2:03 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> > On 12/15/2013 02:16 PM, Linus Torvalds wrote:
> >>
> >> Can anybody see what's wrong with that code? It all seems to happen
> >> with mmap_sem held for reading, so there is no mmap activity going on,
> >> but what about concurrent pmd splitting due to page faults etc?
> >
> > There's one thing that seems odd to me: the only place that allocated
> > the ptl is in pgtable_page_ctor() called from pte_alloc_one().

pgtable_page_ctor() allocates pte ptl, pgtable_pmd_page_ctor() allocates
pmd ptl.

> > However, I don't see how ptl is allocated through all the
> > mk_pmd()/mk_huge_pmd()
> > calls in mm/huge_memory.c .

pmd ptl allocated on pmd_alloc_one(), usually something like:
 __handle_mm_fault()
   pmd_alloc()
     __pmd_alloc()
       pmd_alloc_one()
         pgtable_pmd_page_ctor()

It's not specific to huge pages: we allocate it for any pmd table if
USE_SPLIT_PMD_PTLOCKS != 0

> >
> > I've added some debug output, and it seems that indeed the results of
> > mk_pmd() are
> > with ptl == NULL and one of them ends up getting to swapin_walk_pmd_entry
> > where it NULL
> > ptr derefs.

Sorry, I haven't got what debug output you're talking about.
mk_pmd() creates pmd *entry* and ptl is property of page tables, not
entries. I would guess you check page->ptl of stack page, where result of
mk_pmd() first stored.

I probably miss some context here. Do you have crash on some use-case or
what? Could you point me to start of discussion.

> Hmm. I don't see that in my tree either, so that doesn't seem to be a
> linux-next issue.
> 
> How are we not hitting this left and right? Sure, you need spinlock
> debugging or something like that to trigger the BLOATED_SPINLOCKS
> case, and you'd need the USE_SPLIT_PTE_PTLOCKS case to have this at
> all, but that shouldn't be *that* unusual. And afaik, we should hit
> this on just about any page table traversal.
> 
> So I *think* the rule is that largepages don't have ptl entries (since
> they don't have page tables associated with them), and they need to be
> handled specially.

Huh? Huge pages have page tables. On x86-64 it's PMD table for 2M pages
and PUD table for 1G pages. And we have split ptl for PMD: see
USE_SPLIT_PMD_PTLOCKS.

> But it's also possibly just that maybe nothing really uses
> large-pages. And afaik, we used to disable USE_SPLIT_PTE_PTLOCKS
> entirely with big spinlocks until Kirill added that indirection
> pointer, so that would explain why we just never noticed this issue
> before (although I'd have expected that the spinlock still needs to be
> initialized, even if it doesn't need allocating - otherwise we'd
> possibly just hang on a "spin_lock()" that never succeeds).

I've added missed pgtable_page_ctor() on few archs, but x86 was fine.
And it should work even without spin_lock() if we don't allocate page->ptl
dynamically, just because we zero out the field in struct page on page
allocation.

> Adding Kirill to the participants, since he did the
> pgtable_pmd_page_ctor/dtor stuff and enabled split PTE locks even with
> BLOATED_SPINLOCKS. And Andrea, since largepages are involved. And
> linux-mm just to have *some* list cc'd.
> 
> Kirill? Sasha seems to trigger this problem with
> madvise(MADV_WILLNEED), possibly on a hugepage mapping (but see
> below..) The
> 
>         orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
> 
> in swapin_walk_pmd_entry() ends up taking a NULL ptr fault because the
> pmd doesn't have a ptl pointer..
> 
> But why would we trigger this bug then, since we have:
> 
>         if (pmd_none_or_trans_huge_or_clear_bad(pmd))
>                 return 0;
> 
> in swapin_walk_pmd_entry(). Possibly racing with a page-in? Should we
> check the "vma->vm_flags" for VM_HUGETLB?

VM_HUGETLB is for hugetlbfs, and it's a different path in page walker.

I don't see how we can race with THP: swap in doesn't trigger creating THP
page. khugepaged can collapse small page into THP, but it takes mmap_sem
on write and we hold it on read in WILL_NEED path.

> Let's hope the new people have more answers than questions ;)

Sorry, I don't have answers based on the info.

If page->ptl is NULL on pte_offset_map_lock(), we most likely miss
pgtable_page_ctor() somewhere, but I haven't found where.

And I don't see an evidence that huge pages involved. It would be nice to
check if it's reproducible with USE_SPLIT_PMD_PTLOCKS==0.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
