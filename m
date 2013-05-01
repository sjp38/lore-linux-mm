Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B19206B0088
	for <linux-mm@kvack.org>; Wed,  1 May 2013 12:21:19 -0400 (EDT)
Date: Wed, 1 May 2013 17:21:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 7/9] ARM64: mm: HugeTLB support.
Message-ID: <20130501162111.GD17387@arm.com>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-8-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339448-21727-8-git-send-email-steve.capper@linaro.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Tue, Apr 30, 2013 at 05:30:46PM +0100, Steve Capper wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 43b0e9f..16aa780 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -185,6 +185,15 @@ config HW_PERF_EVENTS
>  	  Enable hardware performance counter support for perf events. If
>  	  disabled, perf events will use software events only.
>  
> +config SYS_SUPPORTS_HUGETLBFS
> +	def_bool y if MMU
> +
> +config ARCH_WANT_GENERAL_HUGETLB
> +	def_bool y if MMU

We could drop MMU here, I don't plan a uClinux port ;)

> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> new file mode 100644
> index 0000000..d00d72a
> --- /dev/null
> +++ b/arch/arm64/include/asm/hugetlb.h
...
> +static inline pte_t huge_ptep_get(pte_t *ptep)
> +{
> +	return *ptep;
> +}
> +
> +static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
> +				   pte_t *ptep, pte_t pte)
> +{
> +	set_pte_at(mm, addr, ptep, pte);
> +}
> +
> +static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
> +					 unsigned long addr, pte_t *ptep)
> +{
> +	ptep_clear_flush(vma, addr, ptep);
> +}
> +
> +static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> +					   unsigned long addr, pte_t *ptep)
> +{
> +	ptep_set_wrprotect(mm, addr, ptep);
> +}
> +
> +static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> +					    unsigned long addr, pte_t *ptep)
> +{
> +	return ptep_get_and_clear(mm, addr, ptep);
> +}
> +
> +static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
> +					     unsigned long addr, pte_t *ptep,
> +					     pte_t pte, int dirty)
> +{
> +	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
> +}
> +
> +static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
> +					  unsigned long addr, unsigned long end,
> +					  unsigned long floor,
> +					  unsigned long ceiling)
> +{
> +	free_pgd_range(tlb, addr, end, floor, ceiling);
> +}
...
> +static inline int huge_pte_none(pte_t pte)
> +{
> +	return pte_none(pte);
> +}
> +
> +static inline pte_t huge_pte_wrprotect(pte_t pte)
> +{
> +	return pte_wrprotect(pte);
> +}

Could we make these generic too?

> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> new file mode 100644
> index 0000000..06c74e8
> --- /dev/null
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -0,0 +1,70 @@
> +/*
> + * arch/arm64/mm/hugetlbpage.c
> + *
> + * Copyright (C) 2013 Linaro Ltd.
> + *
> + * Based on arch/x86/mm/hugetlbpage.c.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
> + */
> +
> +#include <linux/init.h>
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +#include <linux/hugetlb.h>
> +#include <linux/pagemap.h>
> +#include <linux/err.h>
> +#include <linux/sysctl.h>
> +#include <asm/mman.h>
> +#include <asm/tlb.h>
> +#include <asm/tlbflush.h>
> +#include <asm/pgalloc.h>
> +
> +#ifndef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> +int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
> +{
> +	return 0;
> +}
> +#endif
> +
> +struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
> +			      int write)
> +{
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +int pmd_huge(pmd_t pmd)
> +{
> +	return (pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_SECT;
> +}
> +
> +int pud_huge(pud_t pud)
> +{
> +	return (pud_val(pud) & PMD_TYPE_MASK) == PMD_TYPE_SECT;
> +}

The types are mismatched here since pud_val() returns a pgd when
pgtable-nopud.h is used. I think we should defined PGD_TYPE_* in terms
of pgdval_t and PUD_TYPE_* just an alias for them.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
