In-reply-to: <4df4ef0c0801211839p73b6b203q47549fba2be8438b@mail.gmail.com>
	(salikhmetov@gmail.com)
Subject: Re: [PATCH -v7 2/2] Update ctime and mtime for memory-mapped files
References: <12009619562023-git-send-email-salikhmetov@gmail.com>
	 <12009619584168-git-send-email-salikhmetov@gmail.com>
	 <alpine.LFD.1.00.0801211805220.2957@woody.linux-foundation.org> <4df4ef0c0801211839p73b6b203q47549fba2be8438b@mail.gmail.com>
Message-Id: <E1JHErd-0007qW-J7@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 22 Jan 2008 09:52:13 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> > >
> > >  /*
> > > + * Scan the PTEs for pages belonging to the VMA and mark them read-only.
> > > + * It will force a pagefault on the next write access.
> > > + */
> > > +static void vma_wrprotect(struct vm_area_struct *vma)
> > > +{
> > > +     unsigned long addr;
> > > +
> > > +     for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> > > +             spinlock_t *ptl;
> > > +             pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> > > +             pud_t *pud = pud_offset(pgd, addr);
> > > +             pmd_t *pmd = pmd_offset(pud, addr);
> > > +             pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >
> > This is extremely expensive over bigger areas, especially sparsely mapped
> > ones (it does all the lookups for all four levels over and over and over
> > again for eachg page).
> >
> > I think Peter Zijlstra posted a version that uses the regular kind of
> > nested loop (with inline functions to keep the thing nice and clean),
> > which gets rid of that.
> 
> Thanks for your feedback, Linus!
> 
> I will use Peter Zijlstra's version of such an operation in my next
> patch series.

But note, that those functions iterate over all the vmas for the given
page range, not just the one msync was performed on.  This might get
even more expensive, if the file is mapped lots of times.

The old version, that Linus was referring to, needs some modification
as well, because it doesn't write protect the ptes, just marks them
clean.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
