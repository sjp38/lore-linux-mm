Message-Id: <200601202154.k0KLsYg04513@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH/RFC] Shared page tables
Date: Fri, 20 Jan 2006 13:54:34 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>, Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Friday, January 20, 2006 1:24 PM
> More comments, mostly trivial, against extracts from the patch below.
> (Quite often I comment on one instance, but same applies in similar places.)
> 
> > --- 2.6.15/./include/asm-x86_64/pgtable.h	2006-01-02 21:21:10.000000000 -0600
> > +++ 2.6.15-shpt/./include/asm-x86_64/pgtable.h	2006-01-03 10:30:01.000000000 -0600
> > @@ -324,7 +321,8 @@ static inline int pmd_large(pmd_t pte) {
> >  /*
> >   * Level 4 access.
> >   */
> > -#define pgd_page(pgd) ((unsigned long) __va((unsigned long)pgd_val(pgd) & PTE_MASK))
> > +#define pgd_page_kernel(pgd) ((unsigned long) __va((unsigned long)pgd_val(pgd) & PTE_MASK))
> > +#define pgd_page(pgd)		(pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT))
> 
> Hmm, so pgd_page changes its meaning: is that wise?  Looks like it isn't
> used much outside of include/ so perhaps you're okay, and I can see the
> attraction of using "_page" for something that supplies a struct page *.
> I can also see the attraction of appending "_kernel" to the other,
> following pte_offset_kernel, but "_kernel" isn't really appropriate.
> Musing aloud, no particular suggestion.

I was wondering about that myself too:  in current code, pgd_page() and
pud_page() deviate from pmd_page and pte_page in terms of symmetry.  The
first two return virtual address of the pgd_val or pud_val, while pmd_page
and pte_page both return point of struct page of underlying entry.  Is
the asymmetry intentional?


Because the way shared page table uses pgd_page and pud_page, it causes
every arch who wants to enable the feature to redefine pgd_page and
pud_page, not exactly nice though.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
