Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D16A6B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:00:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b140so1039813wme.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:00:15 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j20si30706443wrb.254.2017.03.07.05.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 05:00:13 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id n11so863122wma.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:00:13 -0800 (PST)
Date: Tue, 7 Mar 2017 16:00:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 18/33] x86/xen: convert __xen_pgd_walk() and
 xen_cleanmfnmap() to support p4d
Message-ID: <20170307130009.GA2154@node>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <20170306135357.3124-19-kirill.shutemov@linux.intel.com>
 <ab2868ea-1dd1-d51b-4c5a-921ef5c9a427@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ab2868ea-1dd1-d51b-4c5a-921ef5c9a427@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, "Zhang, Xiong Y" <xiong.y.zhang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>

On Mon, Mar 06, 2017 at 03:48:24PM -0500, Boris Ostrovsky wrote:
> 
> > +static int xen_p4d_walk(struct mm_struct *mm, p4d_t *p4d,
> > +		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
> > +		bool last, unsigned long limit)
> > +{
> > +	int i, nr, flush = 0;
> > +
> > +	nr = last ? p4d_index(limit) + 1 : PTRS_PER_P4D;
> > +	for (i = 0; i < nr; i++) {
> > +		pud_t *pud;
> > +
> > +		if (p4d_none(p4d[i]))
> > +			continue;
> > +
> > +		pud = pud_offset(&p4d[i], 0);
> > +		if (PTRS_PER_PUD > 1)
> > +			flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
> > +		xen_pud_walk(mm, pud, func, last && i == nr - 1, limit);
> > +	}
> > +	return flush;
> > +}
> 
> ..
> 
> > +		p4d = p4d_offset(&pgd[i], 0);
> > +		if (PTRS_PER_P4D > 1)
> > +			flush |= (*func)(mm, virt_to_page(p4d), PT_P4D);
> > +		xen_p4d_walk(mm, p4d, func, i == nr - 1, limit);
> 
> 
> We are losing flush status at all levels so we need something like
> 
> flush |= xen_XXX_walk(...)

+ Xiong.

Thanks for noticing this. The fixup is below.

Please test, I don't have a setup for this.

> 
> 
> 
> >  	}
> >  
> > -out:
> >  	/* Do the top level last, so that the callbacks can use it as
> >  	   a cue to do final things like tlb flushes. */
> >  	flush |= (*func)(mm, virt_to_page(pgd), PT_PGD);
> > @@ -1150,57 +1161,97 @@ static void __init xen_cleanmfnmap_free_pgtbl(void *pgtbl, bool unpin)
> >  	xen_free_ro_pages(pa, PAGE_SIZE);
> >  }
> >  
> > +static void __init xen_cleanmfnmap_pmd(pmd_t *pmd, bool unpin)
> > +{
> > +	unsigned long pa;
> > +	pte_t *pte_tbl;
> > +	int i;
> > +
> > +	if (pmd_large(*pmd)) {
> > +		pa = pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
> > +		xen_free_ro_pages(pa, PMD_SIZE);
> > +		return;
> > +	}
> > +
> > +	pte_tbl = pte_offset_kernel(pmd, 0);
> > +	for (i = 0; i < PTRS_PER_PTE; i++) {
> > +		if (pte_none(pte_tbl[i]))
> > +			continue;
> > +		pa = pte_pfn(pte_tbl[i]) << PAGE_SHIFT;
> > +		xen_free_ro_pages(pa, PAGE_SIZE);
> > +	}
> > +	set_pmd(pmd, __pmd(0));
> > +	xen_cleanmfnmap_free_pgtbl(pte_tbl, unpin);
> > +}
> > +
> > +static void __init xen_cleanmfnmap_pud(pud_t *pud, bool unpin)
> > +{
> > +	unsigned long pa;
> > +	pmd_t *pmd_tbl;
> > +	int i;
> > +
> > +	if (pud_large(*pud)) {
> > +		pa = pud_val(*pud) & PHYSICAL_PAGE_MASK;
> > +		xen_free_ro_pages(pa, PUD_SIZE);
> > +		return;
> > +	}
> > +
> > +	pmd_tbl = pmd_offset(pud, 0);
> > +	for (i = 0; i < PTRS_PER_PMD; i++) {
> > +		if (pmd_none(pmd_tbl[i]))
> > +			continue;
> > +		xen_cleanmfnmap_pmd(pmd_tbl + i, unpin);
> > +	}
> > +	set_pud(pud, __pud(0));
> > +	xen_cleanmfnmap_free_pgtbl(pmd_tbl, unpin);
> > +}
> > +
> > +static void __init xen_cleanmfnmap_p4d(p4d_t *p4d, bool unpin)
> > +{
> > +	unsigned long pa;
> > +	pud_t *pud_tbl;
> > +	int i;
> > +
> > +	if (p4d_large(*p4d)) {
> > +		pa = p4d_val(*p4d) & PHYSICAL_PAGE_MASK;
> > +		xen_free_ro_pages(pa, P4D_SIZE);
> > +		return;
> > +	}
> > +
> > +	pud_tbl = pud_offset(p4d, 0);
> > +	for (i = 0; i < PTRS_PER_PUD; i++) {
> > +		if (pud_none(pud_tbl[i]))
> > +			continue;
> > +		xen_cleanmfnmap_pud(pud_tbl + i, unpin);
> > +	}
> > +	set_p4d(p4d, __p4d(0));
> > +	xen_cleanmfnmap_free_pgtbl(pud_tbl, unpin);
> > +}
> > +
> >  /*
> >   * Since it is well isolated we can (and since it is perhaps large we should)
> >   * also free the page tables mapping the initial P->M table.
> >   */
> >  static void __init xen_cleanmfnmap(unsigned long vaddr)
> >  {
> > -	unsigned long va = vaddr & PMD_MASK;
> > -	unsigned long pa;
> > -	pgd_t *pgd = pgd_offset_k(va);
> > -	pud_t *pud_page = pud_offset(pgd, 0);
> > -	pud_t *pud;
> > -	pmd_t *pmd;
> > -	pte_t *pte;
> > +	pgd_t *pgd;
> > +	p4d_t *p4d;
> >  	unsigned int i;
> >  	bool unpin;
> >  
> >  	unpin = (vaddr == 2 * PGDIR_SIZE);
> > -	set_pgd(pgd, __pgd(0));
> > -	do {
> > -		pud = pud_page + pud_index(va);
> > -		if (pud_none(*pud)) {
> > -			va += PUD_SIZE;
> > -		} else if (pud_large(*pud)) {
> > -			pa = pud_val(*pud) & PHYSICAL_PAGE_MASK;
> > -			xen_free_ro_pages(pa, PUD_SIZE);
> > -			va += PUD_SIZE;
> > -		} else {
> > -			pmd = pmd_offset(pud, va);
> > -			if (pmd_large(*pmd)) {
> > -				pa = pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
> > -				xen_free_ro_pages(pa, PMD_SIZE);
> > -			} else if (!pmd_none(*pmd)) {
> > -				pte = pte_offset_kernel(pmd, va);
> > -				set_pmd(pmd, __pmd(0));
> > -				for (i = 0; i < PTRS_PER_PTE; ++i) {
> > -					if (pte_none(pte[i]))
> > -						break;
> > -					pa = pte_pfn(pte[i]) << PAGE_SHIFT;
> > -					xen_free_ro_pages(pa, PAGE_SIZE);
> > -				}
> > -				xen_cleanmfnmap_free_pgtbl(pte, unpin);
> > -			}
> > -			va += PMD_SIZE;
> > -			if (pmd_index(va))
> > -				continue;
> > -			set_pud(pud, __pud(0));
> > -			xen_cleanmfnmap_free_pgtbl(pmd, unpin);
> > -		}
> > -
> > -	} while (pud_index(va) || pmd_index(va));
> > -	xen_cleanmfnmap_free_pgtbl(pud_page, unpin);
> > +	vaddr &= PMD_MASK;
> > +	pgd = pgd_offset_k(vaddr);
> > +	p4d = p4d_offset(pgd, 0);
> > +	for (i = 0; i < PTRS_PER_P4D; i++) {
> > +		if (p4d_none(p4d[i]))
> > +			continue;
> > +		xen_cleanmfnmap_p4d(p4d + i, unpin);
> > +	}
> 
> Don't we need to pass vaddr down to all routines so that they select
> appropriate tables? You seem to always be choosing the first one.

IIUC, we clear whole page table subtree covered by one pgd entry.
So, no, there's no need to pass vaddr down. Just pointer to page table
entry is enough.

But I know virtually nothing about Xen. Please re-check my reasoning.

I would also appreciate help with getting x86 Xen code work with 5-level
paging enabled. For now I make CONFIG_XEN dependent on !CONFIG_X86_5LEVEL.

Fixup:

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index a4079cfab007..d66b7e79781a 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -629,7 +629,8 @@ static int xen_pud_walk(struct mm_struct *mm, pud_t *pud,
 		pmd = pmd_offset(&pud[i], 0);
 		if (PTRS_PER_PMD > 1)
 			flush |= (*func)(mm, virt_to_page(pmd), PT_PMD);
-		xen_pmd_walk(mm, pmd, func, last && i == nr - 1, limit);
+		flush |= xen_pmd_walk(mm, pmd, func,
+				last && i == nr - 1, limit);
 	}
 	return flush;
 }
@@ -650,7 +651,8 @@ static int xen_p4d_walk(struct mm_struct *mm, p4d_t *p4d,
 		pud = pud_offset(&p4d[i], 0);
 		if (PTRS_PER_PUD > 1)
 			flush |= (*func)(mm, virt_to_page(pud), PT_PUD);
-		xen_pud_walk(mm, pud, func, last && i == nr - 1, limit);
+		flush |= xen_pud_walk(mm, pud, func,
+				last && i == nr - 1, limit);
 	}
 	return flush;
 }
@@ -706,7 +708,7 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 		p4d = p4d_offset(&pgd[i], 0);
 		if (PTRS_PER_P4D > 1)
 			flush |= (*func)(mm, virt_to_page(p4d), PT_P4D);
-		xen_p4d_walk(mm, p4d, func, i == nr - 1, limit);
+		flush |= xen_p4d_walk(mm, p4d, func, i == nr - 1, limit);
 	}
 
 	/* Do the top level last, so that the callbacks can use it as
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
