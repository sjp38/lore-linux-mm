Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 4AE796B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 11:46:20 -0400 (EDT)
Date: Fri, 13 Sep 2013 11:45:36 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1379087136-kk1xxduo-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 8/9] mm: implement split page table lock for PMD level
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Sep 13, 2013 at 04:06:15PM +0300, Kirill A. Shutemov wrote:
> The basic idea is the same as with PTE level: the lock is embedded into
> struct page of table's page.
> 
> Split pmd page table lock only makes sense on big machines.
> Let's say >= 32 CPUs for now.
> 
> We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
> take mm->page_table_lock anymore. Let's reuse page->lru of table's page
> for that.

Looks nice.

> hugetlbfs hasn't converted to split locking: disable split locking if
> hugetlbfs enabled.

I don't think that we have to disable when hugetlbfs is enabled,
because hugetlbfs code doesn't use huge_pmd_lockptr() or huge_pmd_lock().

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h       | 31 +++++++++++++++++++++++++++++++
>  include/linux/mm_types.h |  5 +++++
>  kernel/fork.c            |  4 ++--
>  mm/Kconfig               | 10 ++++++++++
>  4 files changed, 48 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index d2f8a50..5b3922d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1294,13 +1294,44 @@ static inline void pgtable_page_dtor(struct page *page)
>  	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
>  		NULL: pte_offset_kernel(pmd, address))
>  
> +#if USE_SPLIT_PMD_PTLOCKS
> +
> +static inline spinlock_t *huge_pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
> +{
> +	return &virt_to_page(pmd)->ptl;
> +}
> +
> +static inline void pgtable_pmd_page_ctor(struct page *page)
> +{
> +	spin_lock_init(&page->ptl);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	page->pmd_huge_pte = NULL;
> +#endif
> +}
> +
> +static inline void pgtable_pmd_page_dtor(struct page *page)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	VM_BUG_ON(page->pmd_huge_pte);
> +#endif
> +}
> +
> +#define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd_huge_pte)
> 
> +
> +#else
> +
>  static inline spinlock_t *huge_pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
>  {
>  	return &mm->page_table_lock;
>  }
>  
> +static inline void pgtable_pmd_page_ctor(struct page *page) {}
> +static inline void pgtable_pmd_page_dtor(struct page *page) {}
> +
>  #define pmd_huge_pte(mm, pmd) ((mm)->pmd_huge_pte)
>  
> +#endif
> +
>  static inline spinlock_t *huge_pmd_lock(struct mm_struct *mm, pmd_t *pmd)
>  {
>  	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1c64730..5706ddf 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -24,6 +24,8 @@
>  struct address_space;
>  
>  #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTE_PTLOCK_CPUS)
> +#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
> +		NR_CPUS >= CONFIG_SPLIT_PMD_PTLOCK_CPUS)
>  
>  /*
>   * Each physical page in the system has a struct page associated with
> @@ -130,6 +132,9 @@ struct page {
>  
>  		struct list_head list;	/* slobs list of pages */
>  		struct slab *slab_page; /* slab fields */
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> +		pgtable_t pmd_huge_pte; /* protected by page->ptl */
> +#endif
>  	};
>  
>  	/* Remainder is not double word aligned */

Can we remove pmd_huge_pte from mm_struct when USE_SPLIT_PMD_PTLOCKS is true?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
