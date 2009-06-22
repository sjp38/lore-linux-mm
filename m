Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 83FF56B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 18:15:17 -0400 (EDT)
Date: Mon, 22 Jun 2009 15:15:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][RFC] mm: uncached vma support with writenotify
Message-Id: <20090622151537.2f8009f7.akpm@linux-foundation.org>
In-Reply-To: <20090615033240.GC31902@linux-sh.org>
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se>
	<20090615033240.GC31902@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: magnus.damm@gmail.com, arnd@arndb.de, linux-mm@kvack.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 12:32:40 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> On Sun, Jun 14, 2009 at 10:28:45PM +0900, Magnus Damm wrote:
> > --- 0001/mm/mmap.c
> > +++ work/mm/mmap.c	2009-06-11 21:43:16.000000000 +0900
> > @@ -1209,8 +1209,20 @@ munmap_back:
> >  	pgoff = vma->vm_pgoff;
> >  	vm_flags = vma->vm_flags;
> >  
> > -	if (vma_wants_writenotify(vma))
> > +	if (vma_wants_writenotify(vma)) {
> > +		pgprot_t pprot = vma->vm_page_prot;
> > +
> > +		/* Can vma->vm_page_prot have changed??
> > +		 *
> > +		 * Answer: Yes, drivers may have changed it in their
> > +		 *         f_op->mmap method.
> > +		 *
> > +		 * Ensures that vmas marked as uncached stay that way.
> > +		 */
> >  		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
> > +		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
> > +			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> > +	}
> >  
> >  	vma_link(mm, vma, prev, rb_link, rb_parent);
> >  	file = vma->vm_file;
> > 
> I guess the only real issue here is that we presently have no generic
> interface in the kernel for setting a VMA uncached. pgprot_noncached()
> is the closest approximation we have, but there are still architectures
> that do not implement it.
> 
> Given that this comes up at least once a month, perhaps it makes sense to
> see which platforms are still outstanding. At least cris, h8300,
> m68knommu, s390, and xtensa all presently lack a definition for it. The
> nommu cases are easily handled, but the rest still require some attention
> from their architecture maintainers before we can really start treating
> this as a generic interface.
> 
> Until then, you will have to do what every other user of
> pgprot_noncached() code does in generic code:
> 
> 	#ifdef pgprot_noncached
> 		vma->vm_page_prot = pgprot_noncached(...);
> 	#endif
> 
> OTOH, I guess we could just add something like:
> 
> 	#define pgprot_noncached(x)	(x) 
> 
> which works fine for the nommu case, and which functionally is no
> different from what happens right now anyways for the users that don't
> wire it up sanely.
> 
> Arnd, what do you think about throwing this at asm-generic?
> 

I think Arnd fell asleep ;)

> 
>  include/asm-generic/pgtable.h |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index e410f60..e2bd73e 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -129,6 +129,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addres
>  #define move_pte(pte, prot, old_addr, new_addr)	(pte)
>  #endif
>  
> +#ifndef pgprot_noncached
> +#define pgprot_noncached(prot)	(prot)
> +#endif
> +
>  #ifndef pgprot_writecombine
>  #define pgprot_writecombine pgprot_noncached
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
