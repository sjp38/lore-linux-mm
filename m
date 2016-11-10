Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68CF66B026E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:36:56 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 20so205864652uak.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:36:56 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id i38si1636539uaa.240.2016.11.10.11.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 11:36:53 -0800 (PST)
Message-ID: <1478806599.7430.139.camel@kernel.crashing.org>
Subject: Re: [PATCH 3/4] hugetlb: Change the function prototype to take
 vma_area_struct as arg
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 11 Nov 2016 06:36:39 +1100
In-Reply-To: <20161110092918.21139-3-aneesh.kumar@linux.vnet.ibm.com>
References: <20161110092918.21139-1-aneesh.kumar@linux.vnet.ibm.com>
	 <20161110092918.21139-3-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 2016-11-10 at 14:59 +0530, Aneesh Kumar K.V wrote:
> This help us to find the hugetlb page size which we need ot use on some
> archs like ppc64 for tlbflush. This also make the interface consistent
> with other hugetlb functions

What about my requested simpler approach ?

For normal (non-huge) pages, we already know the size.

For huge pages, can't we encode in the top SW bits of the PTE the
page size that we obtain from set_pte_at ?

That would be a lot less churn and avoid touching all these archs...
especially since the current DD1 workaround is horrible and I want
the fix to be backported, so something simpler and contained in
arch/powerpc feels more suitable.

Ben.


> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> A arch/arm/include/asm/hugetlb-3level.hA A A A A A A A |A A 8 ++++----
> A arch/arm64/include/asm/hugetlb.hA A A A A A A A A A A A A |A A 4 ++--
> A arch/arm64/mm/hugetlbpage.cA A A A A A A A A A A A A A A A A A |A A 7 +++++--
> A arch/ia64/include/asm/hugetlb.hA A A A A A A A A A A A A A |A A 8 ++++----
> A arch/metag/include/asm/hugetlb.hA A A A A A A A A A A A A |A A 8 ++++----
> A arch/mips/include/asm/hugetlb.hA A A A A A A A A A A A A A |A A 7 ++++---
> A arch/parisc/include/asm/hugetlb.hA A A A A A A A A A A A |A A 4 ++--
> A arch/parisc/mm/hugetlbpage.cA A A A A A A A A A A A A A A A A |A A 6 ++++--
> A arch/powerpc/include/asm/book3s/32/pgtable.h |A A 4 ++--
> A arch/powerpc/include/asm/book3s/64/hugetlb.h | 10 ++++++++++
> A arch/powerpc/include/asm/book3s/64/pgtable.h |A A 9 ---------
> A arch/powerpc/include/asm/hugetlb.hA A A A A A A A A A A |A A 6 +++---
> A arch/powerpc/include/asm/nohash/32/pgtable.h |A A 4 ++--
> A arch/powerpc/include/asm/nohash/64/pgtable.h |A A 4 ++--
> A arch/s390/include/asm/hugetlb.hA A A A A A A A A A A A A A | 12 ++++++------
> A arch/s390/mm/hugetlbpage.cA A A A A A A A A A A A A A A A A A A |A A 3 ++-
> A arch/sh/include/asm/hugetlb.hA A A A A A A A A A A A A A A A |A A 8 ++++----
> A arch/sparc/include/asm/hugetlb.hA A A A A A A A A A A A A |A A 6 +++---
> A arch/sparc/mm/hugetlbpage.cA A A A A A A A A A A A A A A A A A |A A 3 ++-
> A arch/tile/include/asm/hugetlb.hA A A A A A A A A A A A A A |A A 8 ++++----
> A arch/x86/include/asm/hugetlb.hA A A A A A A A A A A A A A A |A A 8 ++++----
> A mm/hugetlb.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A |A A 6 +++---
> A 22 files changed, 76 insertions(+), 67 deletions(-)
> 
> diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
> index d4014fbe5ea3..b71839e1786f 100644
> --- a/arch/arm/include/asm/hugetlb-3level.h
> +++ b/arch/arm/include/asm/hugetlb-3level.h
> @@ -49,16 +49,16 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> > A 	ptep_clear_flush(vma, addr, ptep);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index bbc1e35aa601..4e54d4b58d3e 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -76,9 +76,9 @@ extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> A extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> > A 				A A A A A A unsigned long addr, pte_t *ptep,
> > A 				A A A A A A pte_t pte, int dirty);
> -extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +extern pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 				A A A A A unsigned long addr, pte_t *ptep);
> -extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +extern void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 				A A A A unsigned long addr, pte_t *ptep);
> A extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
> > A 				A A unsigned long addr, pte_t *ptep);
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 2e49bd252fe7..5c8903433cd9 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -197,10 +197,11 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> > A 	return entry;
> A }
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 			A A A A A A unsigned long addr, pte_t *ptep)
> A {
> > A 	pte_t pte;
> > +	struct mm_struct *mm = vma->vm_mm;
> A 
> > A 	if (pte_cont(*ptep)) {
> > A 		int ncontig, i;
> @@ -263,9 +264,11 @@ int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> > A 	}
> A }
> A 
> -void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 			A A A A A unsigned long addr, pte_t *ptep)
> A {
> > +	struct mm_struct *mm = vma->vm_mm;
> +
> > A 	if (pte_cont(*ptep)) {
> > A 		int ncontig, i;
> > A 		pte_t *cpte;
> diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
> index ef65f026b11e..eb1c1d674200 100644
> --- a/arch/ia64/include/asm/hugetlb.h
> +++ b/arch/ia64/include/asm/hugetlb.h
> @@ -26,10 +26,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> @@ -47,10 +47,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/metag/include/asm/hugetlb.h b/arch/metag/include/asm/hugetlb.h
> index 905ed422dbeb..310b103127a6 100644
> --- a/arch/metag/include/asm/hugetlb.h
> +++ b/arch/metag/include/asm/hugetlb.h
> @@ -28,10 +28,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> @@ -49,10 +49,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
> index 982bc0685330..4380acbff8e2 100644
> --- a/arch/mips/include/asm/hugetlb.h
> +++ b/arch/mips/include/asm/hugetlb.h
> @@ -53,11 +53,12 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > A 	pte_t clear;
> > A 	pte_t pte = *ptep;
> > +	struct mm_struct *mm = vma->vm_mm;
> A 
> > A 	pte_val(clear) = (unsigned long)invalid_pte_table;
> > A 	set_pte_at(mm, addr, ptep, clear);
> @@ -81,10 +82,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
> index a65d888716c4..3a6070842016 100644
> --- a/arch/parisc/include/asm/hugetlb.h
> +++ b/arch/parisc/include/asm/hugetlb.h
> @@ -8,7 +8,7 @@
> A void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 		A A A A A pte_t *ptep, pte_t pte);
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
> > A 			A A A A A A pte_t *ptep);
> A 
> A static inline int is_hugepage_only_range(struct mm_struct *mm,
> @@ -54,7 +54,7 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep);
> A 
> A int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/parisc/mm/hugetlbpage.c b/arch/parisc/mm/hugetlbpage.c
> index 5d6eea925cf4..e01fd08ed72c 100644
> --- a/arch/parisc/mm/hugetlbpage.c
> +++ b/arch/parisc/mm/hugetlbpage.c
> @@ -142,11 +142,12 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> A }
> A 
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
> > A 			A A A A A A pte_t *ptep)
> A {
> > A 	unsigned long flags;
> > A 	pte_t entry;
> > +	struct mm_struct *mm = vma->vma_mm;
> A 
> > A 	purge_tlb_start(flags);
> > A 	entry = *ptep;
> @@ -157,11 +158,12 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> A }
> A 
> A 
> -void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 				unsigned long addr, pte_t *ptep)
> A {
> > A 	unsigned long flags;
> > A 	pte_t old_pte;
> > +	struct mm_struct *mm = vma->vm_mm;
> A 
> > A 	purge_tlb_start(flags);
> > A 	old_pte = *ptep;
> diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
> index 0713626e9189..34c8fd0c5d04 100644
> --- a/arch/powerpc/include/asm/book3s/32/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
> @@ -216,10 +216,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
> A {
> > A 	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
> A }
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A 
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index a7d2b6107383..58e00dbbf15c 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -28,4 +28,14 @@ static inline int hstate_get_psize(struct hstate *hstate)
> > A 		return mmu_virtual_psize;
> > A 	}
> A }
> +
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > +					A A A unsigned long addr, pte_t *ptep)
> +{
> > +	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
> > +		return;
> +
> > +	pte_update(vma->vm_mm, addr, ptep, _PAGE_WRITE, 0, 1);
> +}
> +
> A #endif
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 46d739457d68..ef2eef1ba99a 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -346,15 +346,6 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
> > A 	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 0);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> > -					A A A unsigned long addr, pte_t *ptep)
> -{
> > -	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
> > -		return;
> -
> > -	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 1);
> -}
> -
> A #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
> A static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
> > A 				A A A A A A A unsigned long addr, pte_t *ptep)
> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index c03e0a3dd4d8..b152e0c8dc4e 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -132,11 +132,11 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> A #ifdef CONFIG_PPC64
> > -	return __pte(pte_update(mm, addr, ptep, ~0UL, 0, 1));
> > +	return __pte(pte_update(vma->vm_mm, addr, ptep, ~0UL, 0, 1));
> A #else
> > A 	return __pte(pte_update(ptep, ~0UL, 0));
> A #endif
> @@ -146,7 +146,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> > A 					A unsigned long addr, pte_t *ptep)
> A {
> > A 	pte_t pte;
> > -	pte = huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
> > +	pte = huge_ptep_get_and_clear(vma, addr, ptep);
> > A 	flush_hugetlb_page(vma, addr);
> A }
> A 
> diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
> index 24ee66bf7223..db83c15f1d54 100644
> --- a/arch/powerpc/include/asm/nohash/32/pgtable.h
> +++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
> @@ -260,10 +260,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
> A {
> > A 	pte_update(ptep, (_PAGE_RW | _PAGE_HWWRITE), _PAGE_RO);
> A }
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A 
> diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
> index 86d49dc60ec6..16c77d923209 100644
> --- a/arch/powerpc/include/asm/nohash/64/pgtable.h
> +++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
> @@ -257,13 +257,13 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
> > A 	pte_update(mm, addr, ptep, _PAGE_RW, 0, 0);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > A 	if ((pte_val(*ptep) & _PAGE_RW) == 0)
> > A 		return;
> A 
> > -	pte_update(mm, addr, ptep, _PAGE_RW, 0, 1);
> > +	pte_update(vma->vm_mm, addr, ptep, _PAGE_RW, 0, 1);
> A }
> A 
> A /*
> diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
> index 4c7fac75090e..eb411d59ab77 100644
> --- a/arch/s390/include/asm/hugetlb.h
> +++ b/arch/s390/include/asm/hugetlb.h
> @@ -19,7 +19,7 @@
> A void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 		A A A A A pte_t *ptep, pte_t pte);
> A pte_t huge_ptep_get(pte_t *ptep);
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 			A A A A A A unsigned long addr, pte_t *ptep);
> A 
> A /*
> @@ -50,7 +50,7 @@ static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> > A 					A unsigned long address, pte_t *ptep)
> A {
> > -	huge_ptep_get_and_clear(vma->vm_mm, address, ptep);
> > +	huge_ptep_get_and_clear(vma, address, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> @@ -59,17 +59,17 @@ static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> A {
> > A 	int changed = !pte_same(huge_ptep_get(ptep), pte);
> > A 	if (changed) {
> > -		huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
> > +		huge_ptep_get_and_clear(vma, addr, ptep);
> > A 		set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> > A 	}
> > A 	return changed;
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	pte_t pte = huge_ptep_get_and_clear(mm, addr, ptep);
> > -	set_huge_pte_at(mm, addr, ptep, pte_wrprotect(pte));
> > +	pte_t pte = huge_ptep_get_and_clear(vma, addr, ptep);
> > +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte_wrprotect(pte));
> A }
> A 
> A static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
> diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
> index cd404aa3931c..61146137b0d2 100644
> --- a/arch/s390/mm/hugetlbpage.c
> +++ b/arch/s390/mm/hugetlbpage.c
> @@ -136,12 +136,13 @@ pte_t huge_ptep_get(pte_t *ptep)
> > A 	return __rste_to_pte(pte_val(*ptep));
> A }
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 			A A A A A A unsigned long addr, pte_t *ptep)
> A {
> > A 	pte_t pte = huge_ptep_get(ptep);
> > A 	pmd_t *pmdp = (pmd_t *) ptep;
> > A 	pud_t *pudp = (pud_t *) ptep;
> > +	struct mm_struct *mm = vma->vm_mm;
> A 
> > A 	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
> > A 		pudp_xchg_direct(mm, addr, pudp, __pud(_REGION3_ENTRY_EMPTY));
> diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
> index ef489a56fcce..925cbc0b4da9 100644
> --- a/arch/sh/include/asm/hugetlb.h
> +++ b/arch/sh/include/asm/hugetlb.h
> @@ -40,10 +40,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> @@ -61,10 +61,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index dcbf985ab243..c7c21738b46c 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -8,7 +8,7 @@
> A void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 		A A A A A pte_t *ptep, pte_t pte);
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
> > A 			A A A A A A pte_t *ptep);
> A 
> A static inline int is_hugepage_only_range(struct mm_struct *mm,
> @@ -46,11 +46,11 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > A 	pte_t old_pte = *ptep;
> > -	set_huge_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
> > +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte_wrprotect(old_pte));
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
> index 988acc8b1b80..c5d1fb4a83a7 100644
> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -174,10 +174,11 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	maybe_tlb_batch_add(mm, addr + REAL_HPAGE_SIZE, ptep, orig, 0);
> A }
> A 
> -pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> +pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma, unsigned long addr,
> > A 			A A A A A A pte_t *ptep)
> A {
> > A 	pte_t entry;
> > +	struct mm_struct *mm = vma->vm_mm;
> A 
> > A 	entry = *ptep;
> > A 	if (pte_present(entry))
> diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
> index 2fac5be4de26..aab3ff1cdb10 100644
> --- a/arch/tile/include/asm/hugetlb.h
> +++ b/arch/tile/include/asm/hugetlb.h
> @@ -54,10 +54,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte(ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> @@ -76,10 +76,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 3a106165e03a..47b7a102a6a2 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -41,10 +41,10 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> > A 	set_pte_at(mm, addr, ptep, pte);
> A }
> A 
> -static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +static inline pte_t huge_ptep_get_and_clear(struct vm_area_struct *vma,
> > A 					A A A A unsigned long addr, pte_t *ptep)
> A {
> > -	return ptep_get_and_clear(mm, addr, ptep);
> > +	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> @@ -63,10 +63,10 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
> > A 	return pte_wrprotect(pte);
> A }
> A 
> -static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +static inline void huge_ptep_set_wrprotect(struct vm_area_struct *vma,
> > A 					A A A unsigned long addr, pte_t *ptep)
> A {
> > -	ptep_set_wrprotect(mm, addr, ptep);
> > +	ptep_set_wrprotect(vma->vm_mm, addr, ptep);
> A }
> A 
> A static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec49d9ef1eef..6b140f213e33 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3182,7 +3182,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> > A 			set_huge_pte_at(dst, addr, dst_pte, entry);
> > A 		} else {
> > A 			if (cow) {
> > -				huge_ptep_set_wrprotect(src, addr, src_pte);
> > +				huge_ptep_set_wrprotect(vma, addr, src_pte);
> > A 				mmu_notifier_invalidate_range(src, mmun_start,
> > A 								A A A mmun_end);
> > A 			}
> @@ -3271,7 +3271,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> > A 			set_vma_resv_flags(vma, HPAGE_RESV_UNMAPPED);
> > A 		}
> A 
> > -		pte = huge_ptep_get_and_clear(mm, address, ptep);
> > +		pte = huge_ptep_get_and_clear(vma, address, ptep);
> > A 		tlb_remove_tlb_entry(tlb, ptep, address);
> > A 		if (huge_pte_dirty(pte))
> > A 			set_page_dirty(page);
> @@ -4020,7 +4020,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> > A 			continue;
> > A 		}
> > A 		if (!huge_pte_none(pte)) {
> > -			pte = huge_ptep_get_and_clear(mm, address, ptep);
> > +			pte = huge_ptep_get_and_clear(vma, address, ptep);
> > A 			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
> > A 			pte = arch_make_huge_pte(pte, vma, NULL, 0);
> > A 			set_huge_pte_at(mm, address, ptep, pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
