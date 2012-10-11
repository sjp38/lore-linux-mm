Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CC8B06B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:36:38 -0400 (EDT)
Date: Thu, 11 Oct 2012 19:36:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 22/33] autonuma: make khugepaged pte_numa aware
Message-ID: <20121011183634.GF3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-23-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-23-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:51:04AM +0200, Andrea Arcangeli wrote:
> If any of the ptes that khugepaged is collapsing was a pte_numa, the
> resulting trans huge pmd will be a pmd_numa too.
> 
> See the comment inline for why we require just one pte_numa pte to
> make a pmd_numa pmd. If needed later we could change the number of
> pte_numa ptes required to create a pmd_numa and make it tunable with
> sysfs too.
> 

It does increase the number of NUMA hinting faults that are incurred though,
potentially offsetting the gains from using THP. Is this something that
would just go away when THP pages are natively migrated by autonuma?
Does it make a measurable improvement now?

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c |   33 +++++++++++++++++++++++++++++++--
>  1 files changed, 31 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 152d4dd..1023e67 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1833,12 +1833,19 @@ out:
>  	return isolated;
>  }
>  
> -static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
> +/*
> + * Do the actual data copy for mapped ptes and release the mapped
> + * pages, or alternatively zero out the transparent hugepage in the
> + * mapping holes. Transfer the page_autonuma information in the
> + * process. Return true if any of the mapped ptes was of numa type.
> + */
> +static bool __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  				      struct vm_area_struct *vma,
>  				      unsigned long address,
>  				      spinlock_t *ptl)
>  {
>  	pte_t *_pte;
> +	bool mknuma = false;
>  	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
>  		pte_t pteval = *_pte;
>  		struct page *src_page;
> @@ -1865,11 +1872,29 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  			page_remove_rmap(src_page);
>  			spin_unlock(ptl);
>  			free_page_and_swap_cache(src_page);
> +
> +			/*
> +			 * Only require one pte_numa mapped by a pmd
> +			 * to make it a pmd_numa, too. To avoid the
> +			 * risk of losing NUMA hinting page faults, it
> +			 * is better to overestimate the NUMA node
> +			 * affinity with a node where we just
> +			 * collapsed a hugepage, rather than
> +			 * underestimate it.
> +			 *
> +			 * Note: if AUTONUMA_SCAN_PMD_FLAG is set, we
> +			 * won't find any pte_numa ptes since we're
> +			 * only setting NUMA hinting at the pmd
> +			 * level.
> +			 */
> +			mknuma |= pte_numa(pteval);
>  		}
>  
>  		address += PAGE_SIZE;
>  		page++;
>  	}
> +
> +	return mknuma;
>  }
>  
>  static void collapse_huge_page(struct mm_struct *mm,
> @@ -1887,6 +1912,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	spinlock_t *ptl;
>  	int isolated;
>  	unsigned long hstart, hend;
> +	bool mknuma = false;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  #ifndef CONFIG_NUMA
> @@ -2005,7 +2031,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 */
>  	anon_vma_unlock(vma->anon_vma);
>  
> -	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
> +	mknuma = pmd_numa(_pmd);
> +	mknuma |= __collapse_huge_page_copy(pte, new_page, vma, address, ptl);
>  	pte_unmap(pte);
>  	__SetPageUptodate(new_page);
>  	pgtable = pmd_pgtable(_pmd);
> @@ -2015,6 +2042,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	_pmd = mk_pmd(new_page, vma->vm_page_prot);
>  	_pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
>  	_pmd = pmd_mkhuge(_pmd);
> +	if (mknuma)
> +		_pmd = pmd_mknuma(_pmd);
>  
>  	/*
>  	 * spin_lock() below is not the equivalent of smp_wmb(), so
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
