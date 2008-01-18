Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
	files
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu>
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <12006091211208-git-send-email-salikhmetov@gmail.com>
	 <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Fri, 18 Jan 2008 11:15:36 +0100
Message-Id: <1200651337.5920.9.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-01-18 at 10:51 +0100, Miklos Szeredi wrote:

> > diff --git a/mm/msync.c b/mm/msync.c
> > index a4de868..a49af28 100644
> > --- a/mm/msync.c
> > +++ b/mm/msync.c
> > @@ -13,11 +13,33 @@
> >  #include <linux/syscalls.h>
> >  
> >  /*
> > + * Scan the PTEs for pages belonging to the VMA and mark them read-only.
> > + * It will force a pagefault on the next write access.
> > + */
> > +static void vma_wrprotect(struct vm_area_struct *vma)
> > +{
> > +	unsigned long addr;
> > +
> > +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> > +		spinlock_t *ptl;
> > +		pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> > +		pud_t *pud = pud_offset(pgd, addr);
> > +		pmd_t *pmd = pmd_offset(pud, addr);
> > +		pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +
> > +		if (pte_dirty(*pte) && pte_write(*pte))
> > +			*pte = pte_wrprotect(*pte);
> > +		pte_unmap_unlock(pte, ptl);
> > +	}
> > +}
> 
> What about ram based filesystems?  They don't start out with read-only
> pte's, so I think they don't want them read-protected now either.
> Unless this is essential for correct mtime/ctime accounting on these
> filesystems (I don't think it really is).  But then the mapping should
> start out read-only as well, otherwise the time update will only work
> after an msync(MS_ASYNC).

page_mkclean() has all the needed logic for this, it also walks the rmap
and cleans out all other users, which I think is needed too for
consistencies sake:

Process A			Process B

mmap(foo.txt)			mmap(foo.txt)

dirty page
				dirty page

msync(MS_ASYNC)

				dirty page

msync(MS_ASYNC) <--- now what?!


So what I would suggest is using the page table walkers from mm, and
walks the page range, obtain the page using vm_normal_page() and call
page_mkclean(). (Oh, and ensure you don't nest the pte lock :-)

All in all, that sounds rather expensive..



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
