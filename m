Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B71736B025A
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:03:35 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so3303196wgk.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:03:34 -0700 (PDT)
Received: from johanna3.inet.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id o4si641950wjx.75.2015.07.14.02.03.33
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 02:03:33 -0700 (PDT)
Date: Tue, 14 Jul 2015 12:02:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-ID: <20150714090252.GA20071@node.dhcp.inet.fi>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436819284-3964-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Jul 13, 2015 at 11:28:04PM +0300, Ebru Akagunduz wrote:
> This patch makes swapin readahead to improve thp collapse rate.
> When khugepaged scanned pages, there can be a few of the pages
> in swap area.
> 
> With the patch THP can collapse 4kB pages into a THP when
> there are up to max_ptes_swap swap ptes in a 2MB range.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area.
> 
> Without the patch, system did not swap in readahead.
> THP rate was %47 of the program of the memory, it
> did not change over time.
> 
> With this patch, after 10 minutes of waiting khugepaged had
> collapsed %99 of the program's memory.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> Changes in v2:
>  - Use FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT flag
>    instead of 0x0 when called do_swap_page from
>    __collapse_huge_page_swapin (Rik van Riel)
> 
> Changes in v3:
>  - Catch VM_FAULT_HWPOISON and VM_FAULT_OOM return cases
>    in __collapse_huge_page_swapin (Kirill A. Shutemov)
> 
> Test results:
> 
>                         After swapped out
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 267128 kB | 266240 kB     | 532876 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
> -------------------------------------------------------------------
> 
>                         After swapped in
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 533876 kB | 530432 kB     | 266128 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
> -------------------------------------------------------------------
> 
>  include/linux/mm.h                 |  4 ++++
>  include/trace/events/huge_memory.h | 24 ++++++++++++++++++++++
>  mm/huge_memory.c                   | 41 ++++++++++++++++++++++++++++++++++++++
>  mm/memory.c                        |  2 +-
>  4 files changed, 70 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index eacf348..603f3ba 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -40,6 +40,10 @@
>  #define MM_COLLAPSE_ISOLATE_FAIL 5
>  #define MM_EXCEED_SWAP_PTE	2
>  
> +extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address, pte_t *page_table, pmd_t *pmd,
> +			unsigned int flags, pte_t orig_pte);
> +
>  struct mempolicy;
>  struct anon_vma;
>  struct anon_vma_chain;
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index b6bdcc4..8d34086 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -98,6 +98,30 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
>  		__entry->ret)
>  );
>  
> +TRACE_EVENT(mm_collapse_huge_page_swapin,
> +
> +	TP_PROTO(struct mm_struct *mm, int swap_pte, int ret),
> +
> +	TP_ARGS(mm, swap_pte, ret),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(int, swap_pte)
> +		__field(int, ret)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->swap_pte = swap_pte;
> +		__entry->ret = ret;
> +	),
> +
> +	TP_printk("mm=%p, swap_pte=%d, ret=%d",
> +		__entry->mm,
> +		__entry->swap_pte,
> +		__entry->ret)
> +);
> +
>  #endif /* __HUGE_MEMORY_H */
>  #include <trace/define_trace.h>
>  
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b4cef9d..b372b40 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2511,6 +2511,45 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
>  	return true;
>  }
>  
> +/*
> + * Bring missing pages in from swap, to complete THP collapse.
> + * Only done if khugepaged_scan_pmd believes it is worthwhile.
> + *
> + * Called and returns without pte mapped or spinlocks held,
> + * but with mmap_sem held to protect against vma changes.
> + */
> +
> +static void __collapse_huge_page_swapin(struct mm_struct *mm,
> +					struct vm_area_struct *vma,
> +					unsigned long address, pmd_t *pmd,
> +					pte_t *pte)
> +{
> +	unsigned long _address;
> +	pte_t pteval = *pte;
> +	int swap_pte = 0, ret = 0;
> +
> +	pte = pte_offset_map(pmd, address);
> +	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
> +	     pte++, _address += PAGE_SIZE) {
> +		pteval = *pte;
> +		if (is_swap_pte(pteval)) {
> +			swap_pte++;
> +			ret = do_swap_page(mm, vma, _address, pte, pmd,
> +			FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> +			pteval);

Indentation looks broken.

You can reclaim some horizontal space if you'll revert the check above:

		if (!is_space_pte(pteval))
			continue;

> +			if (ret == VM_FAULT_HWPOISON || ret == VM_FAULT_OOM) {

No, this is wrong. ret is bitmask and more than one bit can be set.

The right way would be: 

			if (ret & VM_FAULT_ERROR) {

> +				trace_mm_collapse_huge_page_swapin(mm, vma->vm_start, swap_pte, 0);
> +				return;
> +			}
> +			/* pte is unmapped now, we need to map it */
> +			pte = pte_offset_map(pmd, _address);
> +		}
> +	}
> +	pte--;
> +	pte_unmap(pte);
> +	trace_mm_collapse_huge_page_swapin(mm, swap_pte, 1);
> +}
> +
>  static void collapse_huge_page(struct mm_struct *mm,
>  				   unsigned long address,
>  				   struct page **hpage,
> @@ -2584,6 +2623,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  
>  	anon_vma_lock_write(vma->anon_vma);
>  
> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
> +
>  	pte = pte_offset_map(pmd, address);
>  	pte_ptl = pte_lockptr(mm, pmd);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 67afe75..eec23a2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2443,7 +2443,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
>   * We return with the mmap_sem locked or unlocked in the same cases
>   * as does filemap_fault().
>   */
> -static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pte_t *page_table, pmd_t *pmd,
>  		unsigned int flags, pte_t orig_pte)
>  {
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
