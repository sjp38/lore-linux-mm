Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 326246B006C
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 13:44:28 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id c9so6355685qcz.9
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 10:44:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k32si422022qgf.75.2014.10.07.10.44.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 10:44:27 -0700 (PDT)
Date: Tue, 7 Oct 2014 12:56:45 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 2/5] mm/hugetlb: take page table lock in
 follow_huge_pmd()
Message-ID: <20141007165645.GA24093@nhori.bos.redhat.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1410820799-27278-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1409292041540.4640@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409292041540.4640@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

Hi Hugh,

Sorry for the delayed response, I was off for vacation.

On Mon, Sep 29, 2014 at 09:32:20PM -0700, Hugh Dickins wrote:
> On Mon, 15 Sep 2014, Naoya Horiguchi wrote:
> > We have a race condition between move_pages() and freeing hugepages,
> 
> I've been looking through these 5 today, and they're much better now,
> thank you.  But a new concern below, and a minor correction to 3/5.
> 
> > --- mmotm-2014-09-09-14-42.orig/mm/gup.c
> > +++ mmotm-2014-09-09-14-42/mm/gup.c
> > @@ -162,33 +162,16 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >  
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
> > +		return follow_huge_pmd(mm, address, pmd, flags);
> 
> This code here allows for pmd_none() and pmd_huge(), and for pmd_numa()
> and pmd_trans_huge() below; but makes no explicit allowance for !present
> migration and hwpoison entries.
> 
> Is it assumed that the pmd_bad() test in follow_page_pte() will catch
> those?

Yes, it is now.

> But what of races?

The current patch is still racy when hugepage migrations from different
reasons (hotremove and mbind, for example) happen concurrently.
We need a fix.

> migration entries are highly volatile.  And
> is it assumed that a migration entry cannot pass the pmd_huge() test?

Yes, _PAGE_PSE bit is always clear for migration/hwpoison entry, so they
can never pass pmd_huge() test for now.

> That may be true of x86 today, I'm not certain; but if the soft-dirty
> people catch up with the hugetlb-migration people, that might change
> (they #define _PAGE_SWP_SOFT_DIRTY _PAGE_PSE).

Yes, this problem is not visible now (note that currently _PAGE_SWP_SOFT_DIRTY
is never set on pmd because hugepage is never swapped out,)
but it's potential one.

> 
> Why pmd_huge() does not itself test for present, I cannot say; but it
> probably didn't matter at all before hwpoison and migration were added.

Correct, so we need check _PAGE_PRESENT bit in x86_64 pmd_huge() now.
And we need do some proper actions if we find migration/hwpoison here.
To do this, adding another routine like huge_pmd_present() might be useful
(pmd_present() is already used for thp.)

> 
> Mind you, with __get_user_pages()'s is_vm_hugtlb_page() test avoiding
> all this code, maybe the only thing that can stumble here is your own
> hugetlb migration code; but that appears to be guarded only by
> down_read of mmap_sem, so races would be possible (if userspace
> is silly enough or malicious enough to do so).

I guess that the race is fixed by this patch with checking _PAGE_PRESENT
in pmd_huge(). Or are you mentioning another race?

> 
> What we have here today looks too fragile to me, but it's probably
> best dealt with by a separate patch.
> 
> Or I may be over-anxious, and there may be something "obvious"
> that I'm missing, which saves us from further change.

No, you found a new issue in the current code, thank you very much.

> >  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
> >  		return no_page_table(vma, flags);
> >  	if (pmd_trans_huge(*pmd)) {
> > diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
> > index 34351251e164..941832ee3d5a 100644
> > --- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
> > +++ mmotm-2014-09-09-14-42/mm/hugetlb.c
> > @@ -3668,26 +3668,34 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
> >  
> >  struct page * __weak
> >  follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> > -		pmd_t *pmd, int write)
> > +		pmd_t *pmd, int flags)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> > +	spinlock_t *ptl;
> >  
> > -	page = pte_page(*(pte_t *)pmd);
> > -	if (page)
> > -		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
> > +	ptl = pmd_lockptr(mm, pmd);
> > +	spin_lock(ptl);
> > +
> > +	if (!pmd_huge(*pmd))
> > +		goto out;
> 
> And similarly here.  Though at least here we now have the necessary
> lock, so it's no longer racy, and maybe this pmd_huge() test just needs
> to be replaced by a pmd_present() test?  Or are both needed?

This check is introduced because the first pmd_huge() check outside
follow_huge_pmd() is called without page table lock. So keeping it to
recheck after holding lock looks correct to me.
But as I mentioned above, I'm thinking of changing x86_64's pmd_huge to
check both _PAGE_PRESENT and _PAGE_PSE to make sure that *pmd is pointing
to a normal hugepage, so this check is internally changed to check both.

Thanks,
Naoya Horiguchi

> > +
> > +	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
> > +
> > +	if (flags & FOLL_GET)
> > +		get_page(page);
> > +out:
> > +	spin_unlock(ptl);
> >  	return page;
> >  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
