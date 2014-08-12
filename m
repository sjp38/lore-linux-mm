Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9F06B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 15:53:09 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id q107so10125851qgd.14
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:53:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l3si27160824qao.113.2014.08.12.12.53.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Aug 2014 12:53:08 -0700 (PDT)
Date: Tue, 12 Aug 2014 14:55:20 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/3] mm/hugetlb: take refcount under page table lock
 in follow_huge_pmd()
Message-ID: <20140812185520.GA8975@nhori.bos.redhat.com>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1408091600040.15311@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408091600040.15311@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Sat, Aug 09, 2014 at 04:01:39PM -0700, Hugh Dickins wrote:
> On Fri, 1 Aug 2014, Naoya Horiguchi wrote:
...
> > diff --git mmotm-2014-07-22-15-58.orig/mm/gup.c mmotm-2014-07-22-15-58/mm/gup.c
> > index 91d044b1600d..e4bd59efe686 100644
> > --- mmotm-2014-07-22-15-58.orig/mm/gup.c
> > +++ mmotm-2014-07-22-15-58/mm/gup.c
> > @@ -174,21 +174,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >  	pmd = pmd_offset(pud, address);
> >  	if (pmd_none(*pmd))
> >  		return no_page_table(vma, flags);
> > -	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> > -		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> > -		if (flags & FOLL_GET) {
> > -			/*
> > -			 * Refcount on tail pages are not well-defined and
> > -			 * shouldn't be taken. The caller should handle a NULL
> > -			 * return when trying to follow tail pages.
> > -			 */
> > -			if (PageHead(page))
> > -				get_page(page);
> > -			else
> > -				page = NULL;
> > -		}
> > -		return page;
> > -	}
> > +	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB)
> > +		return follow_huge_pmd_lock(vma, address, pmd, flags);
> 
> Yes, that's good (except I don't like the _lock name).
> 
> >  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
> >  		return no_page_table(vma, flags);
> >  	if (pmd_trans_huge(*pmd)) {
> > diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
> > index 7263c770e9b3..4437896cd6ed 100644
> > --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> > +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> > @@ -3687,6 +3687,33 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
> >  
> >  #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
> >  
> > +struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
> > +				unsigned long address, pmd_t *pmd, int flags)
> > +{
> > +	struct page *page;
> > +	spinlock_t *ptl;
> > +
> > +	if (flags & FOLL_GET)
> > +		ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
> > +
> 
> But this is not good enough, I'm afraid.
> 
> > +	page = follow_huge_pmd(vma->vm_mm, address, pmd, flags & FOLL_WRITE);
> > +
> > +	if (flags & FOLL_GET) {
> > +		/*
> > +		 * Refcount on tail pages are not well-defined and
> > +		 * shouldn't be taken. The caller should handle a NULL
> > +		 * return when trying to follow tail pages.
> > +		 */
> > +		if (PageHead(page))
> > +			get_page(page);
> > +		else
> > +			page = NULL;
> > +		spin_unlock(ptl);
> > +	}
> > +
> > +	return page;
> > +}
> > +
> >  #ifdef CONFIG_MEMORY_FAILURE
> >  
> >  /* Should be called in hugetlb_lock */
> > -- 
> > 1.9.3
> 
> Thanks a lot for remembering this, but it's not enough, I think.

Thank you very much for detailed comments.

> It is an improvement over the current code (except for the annoying new
> level, and its confusing name follow_huge_pmd_lock); but I don't want to
> keep on coming back, repeatedly sending new corrections to four or more
> releases of -stable.  Please let's get it right and be done with it.
> 
> I see two problems with the above, but perhaps I'm mistaken.
> 
> One is hugetlb_vmtruncate(): follow_huge_pmd_lock() is only called
> when we have observed pmd_huge(*pmd), fine, but how can we assume
> that pmd_huge(*pmd) still after getting the necessary huge_pte_lock?
> Truncation could have changed that *pmd to none, and then pte_page()
> will supply an incorrect (but non-NULL) address.

OK, this race window is still open, so double-checking inside
huge_pte_lock() should be necessary.

> (I observe the follow_huge_pmd()s all doing an "if (page)" after
> their pte_page(), but when I checked at the time of the original
> follow_huge_addr() problem, I could not find any architecture with
> a pte_page() returning NULL for an invalid entry - pte_page() is
> a simple blind translation in every architecture, I believe, but
> please check.)

I agree that no implementation of pte_page() has invalid entry check.
They essentially do (base address + pfn calculated by pte_val), so
never return null for any regular input.

> Two is x86-32 PAE (and perhaps some other architectures), in which
> the pmd entry spans two machine words, loaded independently.  It's a
> very narrow race window, but we cannot safely access the whole *pmd
> without locking: we might pick up two mismatched halves.  Take a look
> at pte_unmap_same() in mm/memory.c, it's handling that issue on ptes.

OK, so ...

> So, if I follow my distaste for the intermediate follow_huge_pmd_lock
> level (and in patch 4/3 you are already changing all the declarations,
> so no need to be deterred by that task), I think what we need is:
> 
> struct page *
> follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
> 		pmd_t *pmd, unsigned int flags)
> {
> 	struct page *page;
> 	spinlock_t *ptl;
> 
> 	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
> 
> 	if (!pmd_huge(*pmd)) {

.. I guess that checking pte_same() is better than pmd_huge(), because
it also covers your 2nd concern above?

> 		page = NULL;
> 		goto out;
> 	}
> 
> 	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
> 
> 	if (flags & FOLL_GET) {
> 		/*
> 		 * Refcount on tail pages are not well-defined and
> 		 * shouldn't be taken. The caller should handle a NULL
> 		 * return when trying to follow tail pages.
> 		 */
> 		if (PageHead(page))
> 			get_page(page);
> 		else
> 			page = NULL;
> 	}
> out:
> 	spin_unlock(ptl);
> 	return page;
> }
> 
> Yes, there are many !FOLL_GET cases which could use an ACCESS_ONCE(*pmd)
> and avoid taking the lock; but follow_page_pte() is content to take its
> lock in all cases, so I don't see any need to avoid it in this much less
> common case.

OK.

> And it looks to me as if this follow_huge_pmd() would be good for every
> hugetlb architecture (but I may especially be wrong on that, having
> compiled it for none but x86_64).  On some architectures, the ones which
> currently present just a stub follow_huge_pmd(), the optimizer should
> eliminate everything after the !pmd_huge test, and we won't be calling
> it on those anyway.  On mips s390 and tile, I think the above represents
> what they're currently doing, despite some saying HPAGE_MASK in place of
> PMD_MASK, and having that funny "if (page)" condition after pte_page().

Yes, I think that we can replace all arch-dependent follow_huge_pmd()
with the above one.
Then we need check hugepage_migration_supported() on move_pages() side.

> Please check carefully: I think the above follow_huge_pmd() can sit in
> mm/hugetlb.c, for use on all architectures; and the variants be deleted;
> and I think that would be an improvement.

Yes, I'll try this.

> I'm not sure what should happen to follow_huge_pud() if we go this way.
> There's a good argument for adapting it in exactly the same way, but
> that may not appeal to those wanting to remove the never used argument.
> 
> And, please, let's go just a little further, while we are having to
> think of these issues.  Isn't what we're doing here much the same as
> we need to do to follow_huge_addr(), to fix the May 28th issues which
> led you to disable hugetlb migration on all but x86_64?

Currently follow_huge_addr() ignores FOLL_GET, so just fixing locking
problem as this patch do is not enough for follow_huge_addr().
But when we reenable hugepage migration for example on powerpc, we will
need consider exactly the same problem.

> I'm not arguing to re-enable hugetlb migration on those architectures
> which you cannot test, no, you did the right thing to leave that to
> them.  But could we please update follow_huge_addr() (in a separate
> patch) to make it consistent with this follow_huge_pmd(), so that at
> least you can tell maintainers that you believe it is working now?

OK, I'll do it. What we can do is to take page table lock for pte_page,
and to remove unnecessary "if (page)" check, I think.

> Uh oh.  I thought I had finished writing about this patch, but just
> realized more.  Above you can see that I've faithfully copied your
> "Refcount on tail pages are not well-defined" comment and !PageHead
> NULL.  But that's nonsense, isn't it?  Refcount on tail pages is and
> must be well-defined, and that's been handled in follow_hugetlb_page()
> for, well, at least ten years.

Ah, this "it's not well-defined" was completely wrong. I'll remove it.

> 
> But note the "Some archs" comment in follow_hugetlb_page(): I have
> not followed it up, and it may prove to be irrelevant here; but it
> suggests that in general some additional care might be needed for
> the get_page()s - or perhaps they should now be get_page_folls()?

Yes, it's get_page_folls() now, and it internally pins tail pages by
incrementing page->_mapcount, so using get_page_unless_zero() in
follow_huge_pmd_lock() might be better (to skip tails naturally.)

Thanks,
Naoya Horiguchi

> I guess the "not well-defined" comment was your guess as to why I had
> put in the BUG_ON(flags & FOLL_GET)s: no, they were because nobody
> required huge FOLL_GET at that time, and that case lacked the locking
> which you are now supplying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
