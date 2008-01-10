Date: Fri, 11 Jan 2008 00:18:44 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080110231844.GA4722@wotan.suse.de>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com> <20080107044355.GA11222@wotan.suse.de> <1199972007.20471.10.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199972007.20471.10.camel@cotte.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 10, 2008 at 02:33:27PM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> > We initially wanted to do the whole vm_normal_page thing this way, with another
> > pte bit, but we thought there were one or two archs with no spare bits. BTW. I
> > also need this bit in order to implement my lockless get_user_pages, so I do hope
> > to get it in. I'd like to know what architectures cannot spare a software bit in
> > their pte_present ptes...
> I've been playing with the original PAGE_SPECIAL patch a little bit, and
> you can find the corresponding s390 definition below that you might want
> to add to your patch queue.
> It is a little unclear to me, how you'd like to proceed from here:
> - with PTE_SPECIAL, do we still have VM_MIXEDMAP or similar flag to
> distinguish our new type of mapping from VM_PFNMAP? Which vma flags are
> we supposed to use for xip mappings?

We should not need anything in the VMA, because the vm can get all the
required information from the pte. However, we still need to keep the
MIXEMAP and PFNMAP stuff around for architectures that don't provide a
pte_special.


> - does VM_PFNMAP work as before, or do you intend to replace it?

PFNMAP can be replaced with pte_special as well. They are all schemes
used to exempt a pte from having its struct page refcounted... if we
use a bit per pte, then we need nothing else.

> - what about vm_normal_page? Do you intend to have one per arch? The one
> proposed by this patch breaks Jared's pfn_valid() thing and VM_PFNMAP
> for archs that don't have PAGE_SPECIAL as far as I can tell.

I think just have 2 in the core code. Switched by ifdef. I'll work on a
more polished patch for that.

> 
> ---
> Index: linux-2.6/include/asm-s390/pgtable.h
> ===================================================================
> --- linux-2.6.orig/include/asm-s390/pgtable.h
> +++ linux-2.6/include/asm-s390/pgtable.h
> @@ -228,6 +228,7 @@ extern unsigned long vmalloc_end;
>  /* Software bits in the page table entry */
>  #define _PAGE_SWT	0x001		/* SW pte type bit t */
>  #define _PAGE_SWX	0x002		/* SW pte type bit x */
> +#define _PAGE_SPECIAL	0x004		/* SW associated with special page */
>  
>  /* Six different types of pages. */
>  #define _PAGE_TYPE_EMPTY	0x400
> @@ -504,6 +505,12 @@ static inline int pte_file(pte_t pte)
>  	return (pte_val(pte) & mask) == _PAGE_TYPE_FILE;
>  }
>  
> +static inline int pte_special(pte_t pte)
> +{
> +	BUG_ON(!pte_present(pte));
> +	return (pte_val(pte) & _PAGE_SPECIAL);
> +}
> +
>  #define __HAVE_ARCH_PTE_SAME
>  #define pte_same(a,b)  (pte_val(a) == pte_val(b))
>  
> @@ -654,6 +661,13 @@ static inline pte_t pte_mkyoung(pte_t pt
>  	return pte;
>  }
>  
> +static inline pte_t pte_mkspecial(pte_t pte)
> +{
> +	BUG_ON(!pte_present(pte));
> +	pte_val(pte) |= _PAGE_SPECIAL;
> +	return pte;
> +}
> +
>  #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
>  static inline int ptep_test_and_clear_young(struct vm_area_struct *vma,
>  					    unsigned long addr, pte_t *ptep)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
