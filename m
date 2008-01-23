Received: by wa-out-1112.google.com with SMTP id m33so4933101wag.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2008 04:53:40 -0800 (PST)
Message-ID: <4df4ef0c0801230453n9c2946ei537881118d367b75@mail.gmail.com>
Date: Wed, 23 Jan 2008 15:53:40 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
In-Reply-To: <1201078035.6341.45.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	 <1201044083504-git-send-email-salikhmetov@gmail.com>
	 <1201078035.6341.45.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/23, Peter Zijlstra <a.p.zijlstra@chello.nl>:
>
> On Wed, 2008-01-23 at 02:21 +0300, Anton Salikhmetov wrote:
>
> > +static void vma_wrprotect_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> > +             unsigned long start, unsigned long end)
> > +{
> > +     while (start < end) {
> > +             spinlock_t *ptl;
> > +             pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
> > +
> > +             if (pte_dirty(*pte) && pte_write(*pte)) {
> > +                     pte_t entry = ptep_clear_flush(vma, start, pte);
> > +
> > +                     entry = pte_wrprotect(entry);
> > +                     set_pte_at(vma->vm_mm, start, pte, entry);
> > +             }
> > +
> > +             pte_unmap_unlock(pte, ptl);
> > +             start += PAGE_SIZE;
> > +     }
> > +}
>
> You've had two examples on how to write this loop, one from git commit
> 204ec841fbea3e5138168edbc3a76d46747cc987, and one from my draft, but
> this one looks like neither and is much less efficient. Take the lock
> only once per pmd, not once per pte please.
>
> > +static void vma_wrprotect_pud_range(struct vm_area_struct *vma, pud_t *pud,
> > +             unsigned long start, unsigned long end)
> > +{
> > +     pmd_t *pmd = pmd_offset(pud, start);
> > +
> > +     while (start < end) {
> > +             unsigned long next = pmd_addr_end(start, end);
> > +
> > +             if (!pmd_none_or_clear_bad(pmd))
> > +                     vma_wrprotect_pmd_range(vma, pmd, start, next);
> > +
> > +             ++pmd;
> > +             start = next;
> > +     }
> > +}
> > +
> > +static void vma_wrprotect_pgd_range(struct vm_area_struct *vma, pgd_t *pgd,
> > +             unsigned long start, unsigned long end)
> > +{
> > +     pud_t *pud = pud_offset(pgd, start);
> > +
> > +     while (start < end) {
> > +             unsigned long next = pud_addr_end(start, end);
> > +
> > +             if (!pud_none_or_clear_bad(pud))
> > +                     vma_wrprotect_pud_range(vma, pud, start, next);
> > +
> > +             ++pud;
> > +             start = next;
> > +     }
> > +}
> > +
> > +static void vma_wrprotect(struct vm_area_struct *vma)
> > +{
> > +     unsigned long addr = vma->vm_start;
> > +     pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> > +
> > +     while (addr < vma->vm_end) {
> > +             unsigned long next = pgd_addr_end(addr, vma->vm_end);
> > +
> > +             if (!pgd_none_or_clear_bad(pgd))
> > +                     vma_wrprotect_pgd_range(vma, pgd, addr, next);
> > +
> > +             ++pgd;
> > +             addr = next;
> > +     }
> > +}
>
> I think you want to pass start, end here too, you might not need to
> sweep the whole vma.

Thanks for you feedback, Peter!

I will redesign the vma_wrprotect_pmd_range() routine the way it
acquires the spinlock outside of the loop. I will also rewrite the
vma_wrprotect() function to process only the specified range.

>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
