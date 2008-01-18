Date: Fri, 18 Jan 2008 23:46:22 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/6] mm: introduce pte_special pte bit
Message-ID: <20080118224622.GA11563@wotan.suse.de>
References: <20080118045649.334391000@suse.de> <20080118045755.516986000@suse.de> <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 18, 2008 at 08:41:22AM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 18 Jan 2008, npiggin@suse.de wrote:
> >   */
> > +#ifdef __HAVE_ARCH_PTE_SPECIAL
> > +# define HAVE_PTE_SPECIAL 1
> > +#else
> > +# define HAVE_PTE_SPECIAL 0
> > +#endif
> >  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
> >  {
> > -	unsigned long pfn = pte_pfn(pte);
> > +	unsigned long pfn;
> > +
> > +	if (HAVE_PTE_SPECIAL) {
> 
> I really don't think this is *any* different from "#ifdefs in code".
> 
> #ifdef's in code is not about syntax, it's about abstraction. This is 
> still the exact same thing as having an #ifdef around it, and in many ways 
> it is *worse*, because now it's just made to look somewhat different with 
> a particularly ugly #ifdef.
> 
> IOW, this didn't abstract the issue away, it just massaged it to look 
> different.

Yes, the if () is just to please Andrew, not you ;)

I thought in your last mail on the subject, that you had conceded the
vma-based scheme should stay, so I might have misunderstood that to mean
you would, reluctantly, go with the scheme. I guess I need to try a bit
harder ;)

 
> I suspect that the nicest abstraction would be to simply make the whole 
> function be a per-architecture thing. Not exposing a "pte_special()" bit 
> at all, but instead having the interface simply be:
> 
>  - create special entries:
> 	pte_t pte_mkspecial(pte_t pte)
> 
>  - check if an entry is special:
> 	struct page *vm_normal_page(vma, addr, pte)
> 
> and now it's not while the naming is a bit odd (for historical reasons), 
> at least it is properly *abstracted* and you don't have any #ifdef's in 
> code (and we'd probably need to extend that abstraction then for the 
> "locklessly look up page" case eventually).

Now I would have done this in a flash, except the existing vm_normal_page
code is quite a lot, and complex, to duplicate in every architecture.

 
> [ To make it slightly more regular, we could make "pte_mkspecial()" take 
>   the vma/addr thing too, even though it would never really use it except 
>   to perhaps have a VM_BUG_ON() that it only happens within XIP/PFNMAP 
>   vma's.
> 
>   The "pte_mkspecial()" definitely has more to to with "vm_normal_page()"
>   than with the other "pte_mkxyzzy()" functions, so it really might make
>   sense to instead make the thing
> 
> 	void set_special_page(vma, addr, pte_t *, pfn, pgprot) 
> 
>   because it is never acceptable to do "pte_mkspecial()" on any existent 
>   PTE *anyway*, so we might as well make the interface reflect that: it's 
>   not that you make a pte "special", it's that you insert a special page 
>   into the VM.
> 
>   So the operation really conceptually has more to do with "set_pte()" 
>   than with "pte_mkxxx()", no? ]

Possibly, although I think going that far is hiding things from mm/ a bit
much. If you have a look at the places that call pte_mkspecial, it isn't
too much I think...

 
> Then, just have a library version of the long form, and make architectures 
> that don't support it just use that (just so that you don't have to 
> duplicate that silly thing). So an architecture that support special page 
> flags would do somethiing like
> 
> 	#define set_special_page(vma,addr,ptep,pfn,prot) \
> 		set_pte_at(vma, addr, ptep, mk_special_pte(pfn,prot))
> 	#define vm_normal_page(vma,addr,pte)
> 		(pte_special(pte) ? NULL : pte_page(pte))
> 
> and other architectures would just do
> 
> 	#define set_special_page(vma,addr,ptep,pfn,prot) \
> 		set_pte_at(vma, addr, ptep, mk_pte(pfn,prot))
> 	#define vm_normal_page(vma,addr,pte) \
> 		generic_vm_normal_page(vma,addr,pte)
> 
> or something.
> 
> THAT is what I mean by "no #ifdef's in code" - that the selection is done 
> at a higher level, the same way we have good interfaces with clear 
> *conceptual* meaning for all the other PTE accessing stuff, rather than 
> have conditionals in the architecture-independent code.

OK, that gets around the "duplicate vm_normal_page everywhere" issue I
had. I'm still not quite happy with it ;)

How about taking a different approach. How about also having a pte_normal()
function. Each architecture that has a pte special bit would make this
!pte_special, and those that don't would return 0. They return 0 from both
pte_special and pte_normal because they don't know whether the pte is
special or normal.

Then vm_normal_page would become:

    if (pte_special(pte))
        return NULL;
    else if (pte_normal(pte))
        return pte_page(pte);

    ... /* vma based scheme */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
