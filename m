Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98E816B02C4
	for <linux-mm@kvack.org>; Tue, 16 May 2017 16:29:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t26so60755890qtg.12
        for <linux-mm@kvack.org>; Tue, 16 May 2017 13:29:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b29si329663qtb.70.2017.05.16.13.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 13:29:23 -0700 (PDT)
Date: Tue, 16 May 2017 22:29:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] thp: fix MADV_DONTNEED vs. numa balancing race
Message-ID: <20170516202919.GA2843@redhat.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
 <f105f6a5-bb5e-9480-6b2e-d2d15f631af9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f105f6a5-bb5e-9480-6b2e-d2d15f631af9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2017 at 03:33:35PM +0200, Vlastimil Babka wrote:
> On 03/02/2017 04:10 PM, Kirill A. Shutemov wrote:
> > In case prot_numa, we are under down_read(mmap_sem). It's critical
> > to not clear pmd intermittently to avoid race with MADV_DONTNEED
> > which is also under down_read(mmap_sem):
> > 
> > 	CPU0:				CPU1:
> > 				change_huge_pmd(prot_numa=1)
> > 				 pmdp_huge_get_and_clear_notify()
> > madvise_dontneed()
> >  zap_pmd_range()
> >   pmd_trans_huge(*pmd) == 0 (without ptl)
> >   // skip the pmd
> > 				 set_pmd_at();
> > 				 // pmd is re-established
> > 
> > The race makes MADV_DONTNEED miss the huge pmd and don't clear it
> > which may break userspace.
> > 
> > Found by code analysis, never saw triggered.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/huge_memory.c | 34 +++++++++++++++++++++++++++++++++-
> >  1 file changed, 33 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index e7ce73b2b208..bb2b3646bd78 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1744,7 +1744,39 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >  	if (prot_numa && pmd_protnone(*pmd))
> >  		goto unlock;
> >  
> > -	entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
> > +	/*
> > +	 * In case prot_numa, we are under down_read(mmap_sem). It's critical
> > +	 * to not clear pmd intermittently to avoid race with MADV_DONTNEED
> > +	 * which is also under down_read(mmap_sem):
> > +	 *
> > +	 *	CPU0:				CPU1:
> > +	 *				change_huge_pmd(prot_numa=1)
> > +	 *				 pmdp_huge_get_and_clear_notify()
> > +	 * madvise_dontneed()
> > +	 *  zap_pmd_range()
> > +	 *   pmd_trans_huge(*pmd) == 0 (without ptl)
> > +	 *   // skip the pmd
> > +	 *				 set_pmd_at();
> > +	 *				 // pmd is re-established
> > +	 *
> > +	 * The race makes MADV_DONTNEED miss the huge pmd and don't clear it
> > +	 * which may break userspace.
> > +	 *
> > +	 * pmdp_invalidate() is required to make sure we don't miss
> > +	 * dirty/young flags set by hardware.
> > +	 */
> > +	entry = *pmd;
> > +	pmdp_invalidate(vma, addr, pmd);
> > +
> > +	/*
> > +	 * Recover dirty/young flags.  It relies on pmdp_invalidate to not
> > +	 * corrupt them.
> > +	 */
> 
> pmdp_invalidate() does:
> 
>         pmd_t entry = *pmdp;
>         set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
> 
> so it's not atomic and if CPU sets dirty or accessed in the middle of
> this, they will be lost?

I agree it looks like the dirty bit can be lost. Furthermore this also
loses a MMU notifier invalidate that will lead to corruption at the
secondary MMU level (which will keep using the old protection
permission, potentially keeping writing to a wrprotected page).

> 
> But I don't see how the other invalidate caller
> __split_huge_pmd_locked() deals with this either. Andrea, any idea?

The original code I wrote did this in __split_huge_page_map to create
the "entry" to establish in the pte pagetables:

    	       entry = mk_pte(page + i, vma->vm_page_prot);
	       entry = maybe_mkwrite(pte_mkdirty(entry),
	       	       		   vma);

For anonymous memory the dirty bit is only meaningful for swapping,
and THP couldn't be swapped so setting it unconditional avoided any
issue with the pmdp_invalidate; pmdp_establish.

pmdp_invalidate is needed primarily to avoid aliasing of two different
TLB translation pointing from the same virtual address to the the same
physical address that triggered machine checks (while needing to keep
the pmd huge at all times, back then it was also splitting huge,
splitting is a software bit so userland could still access the data,
splitting bit only blocked kernel code to manipulate on it similar to
what migration entry does right now upstream, except those prevent
userland to access the page during split which is less efficient than
the splitting bit, but at least it's only used for the physical split,
back then there was no difference between virtual and physical split
and physical split is less frequent than the virtual one right now).

It looks like this needs a pmdp_populate that atomically grabs the
value of the pmd and returns it like pmdp_huge_get_and_clear_notify
does and a _notify variant to use "freeze" is false (if freeze is true
the MMU notifier invalidate must have happened when the pmd was set to
a migration entry). If pmdp_populate_notify (freeze==true)
/pmd_populate (freeze==false) would return the old pmd value
atomically with xchg() (just instead of setting it to 0 we should set
it to the mknotpresent one), then we can set the dirty bit on the ptes
(__split_huge_pmd_locked) or in the pmd itself in the change_huge_pmd
accordingly.

If the "dirty" flag information is obtained by the pmd read before
calling pmdp_invalidate is not ok (losing _notify also not ok).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
