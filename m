Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6586B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 15:53:01 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id z2so2740170wiv.6
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:53:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id pt5si5693617wjc.105.2013.12.16.12.53.00
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 12:53:00 -0800 (PST)
Date: Mon, 16 Dec 2013 21:52:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap
 file prefetch
Message-ID: <20131216205244.GG21218@redhat.com>
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com>
 <52AA0613.2000908@oracle.com>
 <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AF19CF.2060102@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Hi,

On Mon, Dec 16, 2013 at 10:18:39AM -0500, Sasha Levin wrote:
> On 12/16/2013 07:47 AM, Kirill A. Shutemov wrote:
> > I probably miss some context here. Do you have crash on some use-case or
> > what? Could you point me to start of discussion.
> 
> Yes, Sorry, here's the crash that started this discussion originally:
> 
> The code points to:
> 

At this point pmd_none_or_trans_huge_or_clear_bad guaranteed us the
pmd points to a regular pte. And in turn the *pmd value is stable and
cannot change from under us as long as we hold the mmap_sem for
reading (writing not required).

pmd_none_or_trans_huge_or_clear_bad implements a proper barrier() to
be sure to check a single snapshot of the pmdval, and we read it
atomically on 32bit archs too. (64bit always relies on gcc everywhere
to access pagetables in a single instruction, including when we write
pagetables, or the CPU could also get confused during TLB miss)

Hmm we can optimize away the barrier() with an ACCESS_ONCE(*pmdp), but
it's not related to this, the full barrier() is safer if something.

>          for (index = start; index != end; index += PAGE_SIZE) {
>                  pte_t pte;
>                  swp_entry_t entry;
>                  struct page *page;
>                  spinlock_t *ptl;
> 
>                  orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);  <=== HERE
>                  pte = *(orig_pte + ((index - start) / PAGE_SIZE));
>                  pte_unmap_unlock(orig_pte, ptl);

This code looks weird, why is it doing the math of
index-start/PAGE_SIZE when it could just pass "index" instead of
"start" to pte_offset_map_lock.

It actually looks safe but this is more complex for nothing. It should
simply do:

                  orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, index, &ptl);
                  pte = *orig_pte;
                  pte_unmap_unlock(orig_pte, ptl);

Is the bug reproducible? If yes the simplest is probably to add some
allocation tracking to the page, so if page->ptl is null we can simply
print a stack trace of who allocated the page (and later forgot to
initialize the ptl).

/* Reset page->mapping so free_pages_check won't complain. */
static inline void pte_lock_deinit(struct page *page)
{
	page->mapping = NULL;
	ptlock_free(page);
}

btw, page->mapping = NULL should be removed, that most certainly comes
from older kernels when page->mapping was in the same union with
page->ptl. page->mapping of pagetables should stay zero at all times.

Agree with Kirill that it would help to verify the bug goes away by
disabling USE_SPLIT_PTE_PTLOCKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
