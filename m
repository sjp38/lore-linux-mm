Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5657A6B009A
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:13:57 -0500 (EST)
Date: Tue, 26 Jan 2010 19:13:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08 of 31] add pmd paravirt ops
Message-ID: <20100126191341.GM16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <89fa0f684abe1cec34c3.1264513923@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <89fa0f684abe1cec34c3.1264513923@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:03PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Paravirt ops pmd_update/pmd_update_defer/pmd_set_at. Not all might be necessary
> (vmware needs pmd_update, Xen needs set_pmd_at, nobody needs pmd_update_defer),
> but this is to keep full simmetry with pte paravirt ops, which looks cleaner
> and simpler from a common code POV.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -449,6 +449,11 @@ static inline void pte_update(struct mm_
>  {
>  	PVOP_VCALL3(pv_mmu_ops.pte_update, mm, addr, ptep);
>  }
> +static inline void pmd_update(struct mm_struct *mm, unsigned long addr,
> +			      pmd_t *pmdp)
> +{
> +	PVOP_VCALL3(pv_mmu_ops.pmd_update, mm, addr, pmdp);
> +}
>  
>  static inline void pte_update_defer(struct mm_struct *mm, unsigned long addr,
>  				    pte_t *ptep)
> @@ -456,6 +461,12 @@ static inline void pte_update_defer(stru
>  	PVOP_VCALL3(pv_mmu_ops.pte_update_defer, mm, addr, ptep);
>  }
>  
> +static inline void pmd_update_defer(struct mm_struct *mm, unsigned long addr,
> +				    pmd_t *pmdp)
> +{
> +	PVOP_VCALL3(pv_mmu_ops.pmd_update_defer, mm, addr, pmdp);
> +}
> +
>  static inline pte_t __pte(pteval_t val)
>  {
>  	pteval_t ret;
> @@ -557,6 +568,18 @@ static inline void set_pte_at(struct mm_
>  		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> +			      pmd_t *pmdp, pmd_t pmd)
> +{
> +	if (sizeof(pmdval_t) > sizeof(long))
> +		/* 5 arg words */
> +		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
> +	else
> +		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
> +}
> +#endif
> +
>  static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
>  	pmdval_t val = native_pmd_val(pmd);
> diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
> --- a/arch/x86/include/asm/paravirt_types.h
> +++ b/arch/x86/include/asm/paravirt_types.h
> @@ -266,10 +266,16 @@ struct pv_mmu_ops {
>  	void (*set_pte_at)(struct mm_struct *mm, unsigned long addr,
>  			   pte_t *ptep, pte_t pteval);
>  	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
> +	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
> +			   pmd_t *pmdp, pmd_t pmdval);
>  	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
>  			   pte_t *ptep);
>  	void (*pte_update_defer)(struct mm_struct *mm,
>  				 unsigned long addr, pte_t *ptep);
> +	void (*pmd_update)(struct mm_struct *mm, unsigned long addr,
> +			   pmd_t *pmdp);
> +	void (*pmd_update_defer)(struct mm_struct *mm,
> +				 unsigned long addr, pmd_t *pmdp);
>  
>  	pte_t (*ptep_modify_prot_start)(struct mm_struct *mm, unsigned long addr,
>  					pte_t *ptep);
> diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
> --- a/arch/x86/kernel/paravirt.c
> +++ b/arch/x86/kernel/paravirt.c
> @@ -422,8 +422,11 @@ struct pv_mmu_ops pv_mmu_ops = {
>  	.set_pte = native_set_pte,
>  	.set_pte_at = native_set_pte_at,
>  	.set_pmd = native_set_pmd,
> +	.set_pmd_at = native_set_pmd_at,
>  	.pte_update = paravirt_nop,
>  	.pte_update_defer = paravirt_nop,
> +	.pmd_update = paravirt_nop,
> +	.pmd_update_defer = paravirt_nop,
>  
>  	.ptep_modify_prot_start = __ptep_modify_prot_start,
>  	.ptep_modify_prot_commit = __ptep_modify_prot_commit,
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
