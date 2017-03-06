Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 605806B0391
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:47:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so210374877pfg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:47:18 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x3si20109530pfx.74.2017.03.06.12.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:47:17 -0800 (PST)
Subject: Re: [PATCHv4 18/33] x86/xen: convert __xen_pgd_walk() and
 xen_cleanmfnmap() to support p4d
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <20170306135357.3124-19-kirill.shutemov@linux.intel.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <ab2868ea-1dd1-d51b-4c5a-921ef5c9a427@oracle.com>
Date: Mon, 6 Mar 2017 15:48:24 -0500
MIME-Version: 1.0
In-Reply-To: <20170306135357.3124-19-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xiong Zhang <xiong.y.zhang@intel.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>


> +static int xen_p4d_walk(struct mm_struct *mm, p4d_t *p4d,
> +		int (*func)(struct mm_struct *mm, struct page *, enum pt_level),
> +		bool last, unsigned long limit)
> +{
> +	int i, nr, flush =3D 0;
> +
> +	nr =3D last ? p4d_index(limit) + 1 : PTRS_PER_P4D;
> +	for (i =3D 0; i < nr; i++) {
> +		pud_t *pud;
> +
> +		if (p4d_none(p4d[i]))
> +			continue;
> +
> +		pud =3D pud_offset(&p4d[i], 0);
> +		if (PTRS_PER_PUD > 1)
> +			flush |=3D (*func)(mm, virt_to_page(pud), PT_PUD);
> +		xen_pud_walk(mm, pud, func, last && i =3D=3D nr - 1, limit);
> +	}
> +	return flush;
> +}

=2E.

> +		p4d =3D p4d_offset(&pgd[i], 0);
> +		if (PTRS_PER_P4D > 1)
> +			flush |=3D (*func)(mm, virt_to_page(p4d), PT_P4D);
> +		xen_p4d_walk(mm, p4d, func, i =3D=3D nr - 1, limit);


We are losing flush status at all levels so we need something like

flush |=3D xen_XXX_walk(...)



>  	}
> =20
> -out:
>  	/* Do the top level last, so that the callbacks can use it as
>  	   a cue to do final things like tlb flushes. */
>  	flush |=3D (*func)(mm, virt_to_page(pgd), PT_PGD);
> @@ -1150,57 +1161,97 @@ static void __init xen_cleanmfnmap_free_pgtbl(v=
oid *pgtbl, bool unpin)
>  	xen_free_ro_pages(pa, PAGE_SIZE);
>  }
> =20
> +static void __init xen_cleanmfnmap_pmd(pmd_t *pmd, bool unpin)
> +{
> +	unsigned long pa;
> +	pte_t *pte_tbl;
> +	int i;
> +
> +	if (pmd_large(*pmd)) {
> +		pa =3D pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
> +		xen_free_ro_pages(pa, PMD_SIZE);
> +		return;
> +	}
> +
> +	pte_tbl =3D pte_offset_kernel(pmd, 0);
> +	for (i =3D 0; i < PTRS_PER_PTE; i++) {
> +		if (pte_none(pte_tbl[i]))
> +			continue;
> +		pa =3D pte_pfn(pte_tbl[i]) << PAGE_SHIFT;
> +		xen_free_ro_pages(pa, PAGE_SIZE);
> +	}
> +	set_pmd(pmd, __pmd(0));
> +	xen_cleanmfnmap_free_pgtbl(pte_tbl, unpin);
> +}
> +
> +static void __init xen_cleanmfnmap_pud(pud_t *pud, bool unpin)
> +{
> +	unsigned long pa;
> +	pmd_t *pmd_tbl;
> +	int i;
> +
> +	if (pud_large(*pud)) {
> +		pa =3D pud_val(*pud) & PHYSICAL_PAGE_MASK;
> +		xen_free_ro_pages(pa, PUD_SIZE);
> +		return;
> +	}
> +
> +	pmd_tbl =3D pmd_offset(pud, 0);
> +	for (i =3D 0; i < PTRS_PER_PMD; i++) {
> +		if (pmd_none(pmd_tbl[i]))
> +			continue;
> +		xen_cleanmfnmap_pmd(pmd_tbl + i, unpin);
> +	}
> +	set_pud(pud, __pud(0));
> +	xen_cleanmfnmap_free_pgtbl(pmd_tbl, unpin);
> +}
> +
> +static void __init xen_cleanmfnmap_p4d(p4d_t *p4d, bool unpin)
> +{
> +	unsigned long pa;
> +	pud_t *pud_tbl;
> +	int i;
> +
> +	if (p4d_large(*p4d)) {
> +		pa =3D p4d_val(*p4d) & PHYSICAL_PAGE_MASK;
> +		xen_free_ro_pages(pa, P4D_SIZE);
> +		return;
> +	}
> +
> +	pud_tbl =3D pud_offset(p4d, 0);
> +	for (i =3D 0; i < PTRS_PER_PUD; i++) {
> +		if (pud_none(pud_tbl[i]))
> +			continue;
> +		xen_cleanmfnmap_pud(pud_tbl + i, unpin);
> +	}
> +	set_p4d(p4d, __p4d(0));
> +	xen_cleanmfnmap_free_pgtbl(pud_tbl, unpin);
> +}
> +
>  /*
>   * Since it is well isolated we can (and since it is perhaps large we =
should)
>   * also free the page tables mapping the initial P->M table.
>   */
>  static void __init xen_cleanmfnmap(unsigned long vaddr)
>  {
> -	unsigned long va =3D vaddr & PMD_MASK;
> -	unsigned long pa;
> -	pgd_t *pgd =3D pgd_offset_k(va);
> -	pud_t *pud_page =3D pud_offset(pgd, 0);
> -	pud_t *pud;
> -	pmd_t *pmd;
> -	pte_t *pte;
> +	pgd_t *pgd;
> +	p4d_t *p4d;
>  	unsigned int i;
>  	bool unpin;
> =20
>  	unpin =3D (vaddr =3D=3D 2 * PGDIR_SIZE);
> -	set_pgd(pgd, __pgd(0));
> -	do {
> -		pud =3D pud_page + pud_index(va);
> -		if (pud_none(*pud)) {
> -			va +=3D PUD_SIZE;
> -		} else if (pud_large(*pud)) {
> -			pa =3D pud_val(*pud) & PHYSICAL_PAGE_MASK;
> -			xen_free_ro_pages(pa, PUD_SIZE);
> -			va +=3D PUD_SIZE;
> -		} else {
> -			pmd =3D pmd_offset(pud, va);
> -			if (pmd_large(*pmd)) {
> -				pa =3D pmd_val(*pmd) & PHYSICAL_PAGE_MASK;
> -				xen_free_ro_pages(pa, PMD_SIZE);
> -			} else if (!pmd_none(*pmd)) {
> -				pte =3D pte_offset_kernel(pmd, va);
> -				set_pmd(pmd, __pmd(0));
> -				for (i =3D 0; i < PTRS_PER_PTE; ++i) {
> -					if (pte_none(pte[i]))
> -						break;
> -					pa =3D pte_pfn(pte[i]) << PAGE_SHIFT;
> -					xen_free_ro_pages(pa, PAGE_SIZE);
> -				}
> -				xen_cleanmfnmap_free_pgtbl(pte, unpin);
> -			}
> -			va +=3D PMD_SIZE;
> -			if (pmd_index(va))
> -				continue;
> -			set_pud(pud, __pud(0));
> -			xen_cleanmfnmap_free_pgtbl(pmd, unpin);
> -		}
> -
> -	} while (pud_index(va) || pmd_index(va));
> -	xen_cleanmfnmap_free_pgtbl(pud_page, unpin);
> +	vaddr &=3D PMD_MASK;
> +	pgd =3D pgd_offset_k(vaddr);
> +	p4d =3D p4d_offset(pgd, 0);
> +	for (i =3D 0; i < PTRS_PER_P4D; i++) {
> +		if (p4d_none(p4d[i]))
> +			continue;
> +		xen_cleanmfnmap_p4d(p4d + i, unpin);
> +	}

Don't we need to pass vaddr down to all routines so that they select
appropriate tables? You seem to always be choosing the first one.

-boris

> +	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
> +		set_pgd(pgd, __pgd(0));
> +		xen_cleanmfnmap_free_pgtbl(p4d, unpin);
> +	}
>  }
> =20
>  static void __init xen_pagetable_p2m_free(void)
> diff --git a/arch/x86/xen/mmu.h b/arch/x86/xen/mmu.h
> index 73809bb951b4..3fe2b3292915 100644
> --- a/arch/x86/xen/mmu.h
> +++ b/arch/x86/xen/mmu.h
> @@ -5,6 +5,7 @@
> =20
>  enum pt_level {
>  	PT_PGD,
> +	PT_P4D,
>  	PT_PUD,
>  	PT_PMD,
>  	PT_PTE


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
