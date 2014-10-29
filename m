Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 92046900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 04:58:16 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so2719763pab.8
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:58:16 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id nx11si3470334pab.172.2014.10.29.01.58.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 01:58:15 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so2566306pdb.39
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:58:15 -0700 (PDT)
Date: Thu, 30 Oct 2014 00:54:34 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH v2] smaps should deal with huge zero page exactly same as
 normal zero page.
Message-ID: <20141029165434.GA16983@gmail.com>
References: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
 <20141027151748.3901b18abcb65426e7ed50b0@linux-foundation.org>
 <20141028150944.GA13840@gmail.com>
 <20141028131810.GB9768@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141028131810.GB9768@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org

On Tue, Oct 28, 2014 at 03:18:10PM +0200, Kirill A. Shutemov wrote:
> On Tue, Oct 28, 2014 at 11:18:38PM +0800, Fengwei Yin wrote:
> > On Mon, Oct 27, 2014 at 03:17:48PM -0700, Andrew Morton wrote:
> > > On Mon, 27 Oct 2014 23:02:13 +0800 Fengwei Yin <yfw.kernel@gmail.com> wrote:
> > > 
> > > > We could see following memory info in /proc/xxxx/smaps with THP enabled.
> > > >   7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
> > > >   Size:           4294967296 kB
> > > >   Rss:            10612736 kB
> > > >   Pss:            10612736 kB
> > > >   Shared_Clean:          0 kB
> > > >   Shared_Dirty:          0 kB
> > > >   Private_Clean:  10612736 kB
> > > >   Private_Dirty:         0 kB
> > > >   Referenced:     10612736 kB
> > > >   Anonymous:             0 kB
> > > >   AnonHugePages:  10612736 kB
> > > >   Swap:                  0 kB
> > > >   KernelPageSize:        4 kB
> > > >   MMUPageSize:           4 kB
> > > >   Locked:                0 kB
> > > >   VmFlags: rd mr mw me
> > > > which is wrong becuase just huge_zero_page/normal_zero_page is used for
> > > > /dev/zero. Most of the value should be 0.
> > > > 
> > > > This patch detects huge_zero_page (original implementation just detect
> > > > normal_zero_page) and avoids to update the wrong value for huge_zero_page.
> > > > 
> > > > ...
> > > >
> > > > --- a/mm/memory.c
> > > > +++ b/mm/memory.c
> > > > @@ -41,6 +41,7 @@
> > > >  #include <linux/kernel_stat.h>
> > > >  #include <linux/mm.h>
> > > >  #include <linux/hugetlb.h>
> > > > +#include <linux/huge_mm.h>
> > > >  #include <linux/mman.h>
> > > >  #include <linux/swap.h>
> > > >  #include <linux/highmem.h>
> > > > @@ -787,6 +788,9 @@ check_pfn:
> > > >  		return NULL;
> > > >  	}
> > > >  
> > > > +	if (is_huge_zero_pfn(pfn))
> > > > +		return NULL;
> > > > +
> > > 
> > > Why this change?
> > > 
> > I suppose the huge zero page should have same behavior as normal zero
> > page. vm_normal_page will return NULL if the pte is for normal zero
> > page. This change make it return NULL for huge zero page.
> > 
> > > What effect does it have upon vm_normal_page()'s many existing callers?
> > This is good question. I suppose it will not impact existing caller.
> 
> vm_normal_page() is designed to handle pte. We only get there due hack
> with pmd to pte cast in smaps_pte_range(). Let's try to get rid of it
> instead.
> 
> Could you test the patch below? I think it's a better fix.
I will test the patch tomorrow and let you know the result. Thanks.

> 
> From 592a7e789128d92e7f5165b583558443e82c88fd Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 28 Oct 2014 14:51:31 +0200
> Subject: [PATCH] mm: fix huge zero page accounting in smaps report
> 
> As a small zero page, huge zero page should not be accounted in smaps
> report as normal page.
> 
> For small pages we rely on vm_normal_page() to filter out zero page, but
> vm_normal_page() is not designed to handle pmds. We only get here due
> hackish cast pmd to pte in smaps_pte_range() -- pte and pmd format is
> not necessary compatible on each and every architecture.
> 
> Let's add separate codepath to handle pmds. follow_trans_huge_pmd() will
> detect huge zero page for us.
> 
> We would need pmd_dirty() helper to do this properly. The patch adds it
> to THP-enabled architectures which don't yet have one.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/arm64/include/asm/pgtable.h         |   1 +
>  arch/powerpc/include/asm/pgtable-ppc64.h |   1 +
>  arch/sparc/include/asm/pgtable_64.h      |   7 +++
>  arch/x86/include/asm/pgtable.h           |   5 ++
>  fs/proc/task_mmu.c                       | 101 ++++++++++++++++++++-----------
>  5 files changed, 79 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 41a43bf26492..df22314f57cf 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -279,6 +279,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
>  #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> +#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
>  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
>  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
>  #define pmd_mksplitting(pmd)	pte_pmd(pte_mkspecial(pmd_pte(pmd)))
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index ae153c40ab7c..9b4b1904efae 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -467,6 +467,7 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>  }
>  
>  #define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
> +#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
>  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
>  #define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
>  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index bfeb626085ac..90af17ee6184 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -667,6 +667,13 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>  }
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmd_dirty(pmd_t pmd)
> +{
> +	pte_t pte = __pte(pmd_val(pmd));
> +
> +	return pte_dirty(pte);
> +}
> +
>  static inline unsigned long pmd_young(pmd_t pmd)
>  {
>  	pte_t pte = __pte(pmd_val(pmd));
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index aa97a070f09f..081d6f45e006 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -99,6 +99,11 @@ static inline int pte_young(pte_t pte)
>  	return pte_flags(pte) & _PAGE_ACCESSED;
>  }
>  
> +static inline int pmd_dirty(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_DIRTY;
> +}
> +
>  static inline int pmd_young(pmd_t pmd)
>  {
>  	return pmd_flags(pmd) & _PAGE_ACCESSED;
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 4e0388cffe3d..2ab200d429be 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -447,58 +447,88 @@ struct mem_size_stats {
>  	u64 pss;
>  };
>  
> +static void smaps_account(struct mem_size_stats *mss, struct page *page,
> +		unsigned long size, bool young, bool dirty)
> +{
> +	int mapcount;
> +
> +	if (PageAnon(page))
> +		mss->anonymous += size;
>  
> -static void smaps_pte_entry(pte_t ptent, unsigned long addr,
> -		unsigned long ptent_size, struct mm_walk *walk)
> +	mss->resident += size;
> +	/* Accumulate the size in pages that have been accessed. */
> +	if (young || PageReferenced(page))
> +		mss->referenced += size;
> +	mapcount = page_mapcount(page);
> +	if (mapcount >= 2) {
> +		if (dirty || PageDirty(page))
> +			mss->shared_dirty += size;
> +		else
> +			mss->shared_clean += size;
> +		mss->pss += (size << PSS_SHIFT) / mapcount;
> +	} else {
> +		if (dirty || PageDirty(page))
> +			mss->private_dirty += size;
> +		else
> +			mss->private_clean += size;
> +		mss->pss += (size << PSS_SHIFT);
> +	}
> +}
> +
> +
> +static void smaps_pte_entry(pte_t *pte, unsigned long addr,
> +		struct mm_walk *walk)
>  {
>  	struct mem_size_stats *mss = walk->private;
>  	struct vm_area_struct *vma = mss->vma;
>  	pgoff_t pgoff = linear_page_index(vma, addr);
>  	struct page *page = NULL;
> -	int mapcount;
>  
> -	if (pte_present(ptent)) {
> -		page = vm_normal_page(vma, addr, ptent);
> -	} else if (is_swap_pte(ptent)) {
> -		swp_entry_t swpent = pte_to_swp_entry(ptent);
> +	if (pte_present(*pte)) {
> +		page = vm_normal_page(vma, addr, *pte);
> +	} else if (is_swap_pte(*pte)) {
> +		swp_entry_t swpent = pte_to_swp_entry(*pte);
>  
>  		if (!non_swap_entry(swpent))
> -			mss->swap += ptent_size;
> +			mss->swap += PAGE_SIZE;
>  		else if (is_migration_entry(swpent))
>  			page = migration_entry_to_page(swpent);
> -	} else if (pte_file(ptent)) {
> -		if (pte_to_pgoff(ptent) != pgoff)
> -			mss->nonlinear += ptent_size;
> +	} else if (pte_file(*pte)) {
> +		if (pte_to_pgoff(*pte) != pgoff)
> +			mss->nonlinear += PAGE_SIZE;
>  	}
>  
>  	if (!page)
>  		return;
>  
> -	if (PageAnon(page))
> -		mss->anonymous += ptent_size;
> -
>  	if (page->index != pgoff)
> -		mss->nonlinear += ptent_size;
> +		mss->nonlinear += PAGE_SIZE;
>  
> -	mss->resident += ptent_size;
> -	/* Accumulate the size in pages that have been accessed. */
> -	if (pte_young(ptent) || PageReferenced(page))
> -		mss->referenced += ptent_size;
> -	mapcount = page_mapcount(page);
> -	if (mapcount >= 2) {
> -		if (pte_dirty(ptent) || PageDirty(page))
> -			mss->shared_dirty += ptent_size;
> -		else
> -			mss->shared_clean += ptent_size;
> -		mss->pss += (ptent_size << PSS_SHIFT) / mapcount;
> -	} else {
> -		if (pte_dirty(ptent) || PageDirty(page))
> -			mss->private_dirty += ptent_size;
> -		else
> -			mss->private_clean += ptent_size;
> -		mss->pss += (ptent_size << PSS_SHIFT);
> -	}
> +	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
> +}
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
> +		struct mm_walk *walk)
> +{
> +	struct mem_size_stats *mss = walk->private;
> +	struct vm_area_struct *vma = mss->vma;
> +	struct page *page;
> +
> +	/* FOLL_DUMP will return -EFAULT on huge zero page */
> +	page = follow_trans_huge_pmd(vma, addr, pmd, FOLL_DUMP);
> +	if (IS_ERR_OR_NULL(page))
> +		return;
> +	mss->anonymous_thp += HPAGE_PMD_SIZE;
> +	smaps_account(mss, page, HPAGE_PMD_SIZE,
> +			pmd_young(*pmd), pmd_dirty(*pmd));
>  }
> +#else
> +static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
> +		struct mm_walk *walk)
> +{
> +}
> +#endif
>  
>  static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			   struct mm_walk *walk)
> @@ -509,9 +539,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	spinlock_t *ptl;
>  
>  	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> -		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
> +		smaps_pmd_entry(pmd, addr, walk);
>  		spin_unlock(ptl);
> -		mss->anonymous_thp += HPAGE_PMD_SIZE;
>  		return 0;
>  	}
>  
> @@ -524,7 +553,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	 */
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; pte++, addr += PAGE_SIZE)
> -		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk);
> +		smaps_pte_entry(pte, addr, walk);
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
>  	return 0;
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
