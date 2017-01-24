Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2EB86B0270
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:41:26 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so252520798pfa.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:41:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t7si20762971pfi.147.2017.01.24.13.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:41:24 -0800 (PST)
Date: Tue, 24 Jan 2017 13:41:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/12] mm: introduce page_check_walk()
Message-Id: <20170124134122.5560b55ca13c2c2cc09c2a4e@linux-foundation.org>
In-Reply-To: <20170124162824.91275-3-kirill.shutemov@linux.intel.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
	<20170124162824.91275-3-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 24 Jan 2017 19:28:14 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> The patch introduce new interface to check if a page is mapped into a vma.
> It aims to address shortcomings of page_check_address{,_transhuge}.
> 
> Existing interface is not able to handle PTE-mapped THPs: it only finds
> the first PTE. The rest lefted unnoticed.
> 
> page_check_walk() iterates over all possible mapping of the page in the
> vma.

I really don't like the name page_check_walk().  "check" could mean any
damn thing.  Something like page_vma_mapped_walk() has meaning.  We
could omit the "_walk" for brevity.


> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/rmap.h |  65 ++++++++++++++++++++++
>  mm/Makefile          |   6 ++-
>  mm/huge_memory.c     |   9 ++--
>  mm/page_check.c      | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 223 insertions(+), 5 deletions(-)
>  create mode 100644 mm/page_check.c
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 15321fb1df6b..474279810742 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -232,6 +232,71 @@ static inline bool page_check_address_transhuge(struct page *page,
>  }
>  #endif
>  
> +/* Avoid racy checks */
> +#define PAGE_CHECK_WALK_SYNC		(1 << 0)
> +/* Look for migarion entries rather than present ptes */
> +#define PAGE_CHECK_WALK_MIGRATION	(1 << 1)
> +
> +struct page_check_walk {
> +	struct page *page;
> +	struct vm_area_struct *vma;
> +	unsigned long address;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +	unsigned int flags;
> +};

One thing which I don't think was documented is that it is the caller's
responsibility to initialize this appropriately before calling
page_check_walk().  At least, .pte and .ptl must be NULL, for
page_check_walk_done().

> +static inline void page_check_walk_done(struct page_check_walk *pcw)
> +{
> +	if (pcw->pte)
> +		pte_unmap(pcw->pte);
> +	if (pcw->ptl)
> +		spin_unlock(pcw->ptl);
> +}
> +
> +bool __page_check_walk(struct page_check_walk *pcw);
> +
> +/**
> + * page_check_walk - check if @pcw->page is mapped in @pcw->vma at @pcw->address
> + * @pcw: pointer to struce page_check_walk. page, vma and address must be set.

"struct"

> + *
> + * Returns true, if the page is mapped in the vma. @pcw->pmd and @pcw->pte point

"Returns true if"

> + * to relevant page table entries. @pcw->ptl is locked. @pcw->address is
> + * adjusted if needed (for PTE-mapped THPs).
> + *
> + * If @pcw->pmd is set, but @pcw->pte is not, you have found PMD-mapped page

"is set but"

> + * (usually THP). For PTE-mapped THP, you should run page_check_walk() in 
> + * a loop to find all PTEs that maps the THP.

"that map"

> + *
> + * For HugeTLB pages, @pcw->pte is set to relevant page table entry regardless

"set to the relevant", "regardless of"

> + * which page table level the page mapped at. @pcw->pmd is NULL.

"the page is"

> + *
> + * Retruns false, if there's no more page table entries for the page in the vma.

"Returns false if there are"

> + * @pcw->ptl is unlocked and @pcw->pte is unmapped.
> + *
> + * If you need to stop the walk before page_check_walk() returned false, use
> + * page_check_walk_done(). It will do the housekeeping.
> + */
> +static inline bool page_check_walk(struct page_check_walk *pcw)
> +{
> +	/* The only possible pmd mapping has been handled on last iteration */
> +	if (pcw->pmd && !pcw->pte) {
> +		page_check_walk_done(pcw);
> +		return false;
> +	}
> +
> +	/* Only for THP, seek to next pte entry makes sense */
> +	if (pcw->pte) {
> +		if (!PageTransHuge(pcw->page) || PageHuge(pcw->page)) {
> +			page_check_walk_done(pcw);
> +			return false;
> +		}
> +	}
> +
> +	return __page_check_walk(pcw);
> +}

Was the decision to inline this a correct one?

> --- /dev/null
> +++ b/mm/page_check.c
> @@ -0,0 +1,148 @@
> +#include <linux/mm.h>
> +#include <linux/rmap.h>
> +#include <linux/hugetlb.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +
> +#include "internal.h"
> +
> +static inline bool check_pmd(struct page_check_walk *pcw)
> +{
> +	pmd_t pmde = *pcw->pmd;
> +	barrier();
> +	return pmd_present(pmde) && !pmd_trans_huge(pmde);
> +}

Can we please have a comment explaining what the barrier() does?

> +static inline bool not_found(struct page_check_walk *pcw)
> +{
> +	page_check_walk_done(pcw);
> +	return false;
> +}
> +
> +static inline bool map_pte(struct page_check_walk *pcw)
> +{
> +	pcw->pte = pte_offset_map(pcw->pmd, pcw->address);
> +	if (!(pcw->flags & PAGE_CHECK_WALK_SYNC)) {
> +		if (pcw->flags & PAGE_CHECK_WALK_MIGRATION) {
> +			if (!is_swap_pte(*pcw->pte))
> +				return false;
> +		} else {
> +			if (!pte_present(*pcw->pte))
> +				return false;
> +		}
> +	}
> +	pcw->ptl = pte_lockptr(pcw->vma->vm_mm, pcw->pmd);
> +	spin_lock(pcw->ptl);
> +	return true;
> +}

The compiler will just ignore all these "inline" statements.

> +static inline bool check_pte(struct page_check_walk *pcw)
> +{
> +	if (pcw->flags & PAGE_CHECK_WALK_MIGRATION) {
> +		swp_entry_t entry;
> +		if (!is_swap_pte(*pcw->pte))
> +			return false;
> +		entry = pte_to_swp_entry(*pcw->pte);
> +		if (!is_migration_entry(entry))
> +			return false;
> +		if (migration_entry_to_page(entry) - pcw->page >=
> +				hpage_nr_pages(pcw->page)) {
> +			return false;
> +		}
> +		if (migration_entry_to_page(entry) < pcw->page)
> +			return false;
> +	} else {
> +		if (!pte_present(*pcw->pte))
> +			return false;
> +
> +		/* THP can be referenced by any subpage */
> +		if (pte_page(*pcw->pte) - pcw->page >=
> +				hpage_nr_pages(pcw->page)) {
> +			return false;
> +		}
> +		if (pte_page(*pcw->pte) < pcw->page)
> +			return false;
> +	}
> +
> +	return true;
> +}

Thankfully, because inlining this one does seem inappropriate - it's
enormous!

> +bool __page_check_walk(struct page_check_walk *pcw)
> +{
> +	struct mm_struct *mm = pcw->vma->vm_mm;
> +	struct page *page = pcw->page;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +
> +	/* For THP, seek to next pte entry */
> +	if (pcw->pte)
> +		goto next_pte;
> +
> +	if (unlikely(PageHuge(pcw->page))) {
> +		/* when pud is not present, pte will be NULL */
> +		pcw->pte = huge_pte_offset(mm, pcw->address);
> +		if (!pcw->pte)
> +			return false;
> +
> +		pcw->ptl = huge_pte_lockptr(page_hstate(page), mm, pcw->pte);
> +		spin_lock(pcw->ptl);
> +		if (!check_pte(pcw))
> +			return not_found(pcw);
> +		return true;
> +	}
> +restart:
> +	pgd = pgd_offset(mm, pcw->address);
> +	if (!pgd_present(*pgd))
> +		return false;
> +	pud = pud_offset(pgd, pcw->address);
> +	if (!pud_present(*pud))
> +		return false;
> +	pcw->pmd = pmd_offset(pud, pcw->address);
> +	if (pmd_trans_huge(*pcw->pmd)) {
> +		pcw->ptl = pmd_lock(mm, pcw->pmd);
> +		if (!pmd_present(*pcw->pmd))
> +			return not_found(pcw);
> +		if (likely(pmd_trans_huge(*pcw->pmd))) {
> +			if (pcw->flags & PAGE_CHECK_WALK_MIGRATION)
> +				return not_found(pcw);
> +			if (pmd_page(*pcw->pmd) != page)
> +				return not_found(pcw);
> +			return true;
> +		} else {
> +			/* THP pmd was split under us: handle on pte level */
> +			spin_unlock(pcw->ptl);
> +			pcw->ptl = NULL;
> +		}
> +	} else {
> +		if (!check_pmd(pcw))
> +			return false;
> +	}
> +	if (!map_pte(pcw))
> +		goto next_pte;
> +	while (1) {
> +		if (check_pte(pcw))
> +			return true;
> +next_pte:	do {
> +			pcw->address += PAGE_SIZE;
> +			if (pcw->address >= __vma_address(pcw->page, pcw->vma) +
> +					hpage_nr_pages(pcw->page) * PAGE_SIZE)
> +				return not_found(pcw);
> +			/* Did we cross page table boundary? */
> +			if (pcw->address % PMD_SIZE == 0) {
> +				pte_unmap(pcw->pte);
> +				if (pcw->ptl) {
> +					spin_unlock(pcw->ptl);
> +					pcw->ptl = NULL;
> +				}
> +				goto restart;
> +			} else {
> +				pcw->pte++;
> +			}
> +		} while (pte_none(*pcw->pte));
> +
> +		if (!pcw->ptl) {
> +			pcw->ptl = pte_lockptr(mm, pcw->pmd);
> +			spin_lock(pcw->ptl);
> +		}
> +	}
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
