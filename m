Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB636B0071
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 14:11:48 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so124574548wgb.2
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 11:11:48 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id cx2si30947941wjc.111.2015.06.21.11.11.46
        for <linux-mm@kvack.org>;
        Sun, 21 Jun 2015 11:11:46 -0700 (PDT)
Date: Sun, 21 Jun 2015 21:11:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-ID: <20150621181131.GA6710@node.dhcp.inet.fi>
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Sat, Jun 20, 2015 at 02:28:06PM +0300, Ebru Akagunduz wrote:
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
>    instead of 0x0 when called do_swap_page
>    from __collapse_huge_page_swapin
> 
> Test results:
> 
> 			After swapped out
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 265772 kB | 264192 kB     | 534232 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
> -------------------------------------------------------------------
> 
>                         After swapped in
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 532756 kB | 528384 kB     | 267248 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
> -------------------------------------------------------------------
> 
>  include/linux/mm.h                 |  4 ++++
>  include/trace/events/huge_memory.h | 24 ++++++++++++++++++++++++
>  mm/huge_memory.c                   | 37 +++++++++++++++++++++++++++++++++++++
>  mm/memory.c                        |  2 +-
>  4 files changed, 66 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7f47178..f66ff8a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -29,6 +29,10 @@ struct user_struct;
>  struct writeback_control;
>  struct bdi_writeback;
>  
> +extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address, pte_t *page_table, pmd_t *pmd,
> +			unsigned int flags, pte_t orig_pte);
> +
>  #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
>  extern unsigned long max_mapnr;
>  
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index 53c9f2e..0117ab9 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -95,5 +95,29 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
>  		__entry->writable)
>  );
>  
> +TRACE_EVENT(mm_collapse_huge_page_swapin,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, int swap_pte),
> +
> +	TP_ARGS(mm, vm_start, swap_pte),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, vm_start)
> +		__field(int, swap_pte)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->vm_start = vm_start;
> +		__entry->swap_pte = swap_pte;
> +	),
> +
> +	TP_printk("mm=%p, vm_start=%04lx, swap_pte=%d",
> +		__entry->mm,
> +		__entry->vm_start,
> +		__entry->swap_pte)
> +);
> +
>  #endif /* __HUGE_MEMORY_H */
>  #include <trace/define_trace.h>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 22bc0bf..064fd72 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2496,6 +2496,41 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
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
> +	int swap_pte = 0;
> +
> +	pte = pte_offset_map(pmd, address);
> +	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
> +	     pte++, _address += PAGE_SIZE) {
> +		pteval = *pte;
> +		if (is_swap_pte(pteval)) {
> +			swap_pte++;
> +			do_swap_page(mm, vma, _address, pte, pmd,
> +				     FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> +				     pteval);

Hm. I guess this lacking error handling.
We really should abort early at least for VM_FAULT_HWPOISON and VM_FAULT_OOM.

> +			/* pte is unmapped now, we need to map it */
> +			pte = pte_offset_map(pmd, _address);

No, it's within the same pte page table. It should be mapped with
pte_offset_map() above.

> +		}
> +	}
> +	pte--;
> +	pte_unmap(pte);
> +	trace_mm_collapse_huge_page_swapin(mm, vma->vm_start, swap_pte);
> +}
> +
>  static void collapse_huge_page(struct mm_struct *mm,
>  				   unsigned long address,
>  				   struct page **hpage,
> @@ -2551,6 +2586,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	if (!pmd)
>  		goto out;
>  
> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
> +

And now the pages we swapped in are not isolated, right?
What prevents them from being swapped out again or whatever?

>  	anon_vma_lock_write(vma->anon_vma);
>  
>  	pte = pte_offset_map(pmd, address);
> diff --git a/mm/memory.c b/mm/memory.c
> index e1c45d0..d801dc5 100644
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
