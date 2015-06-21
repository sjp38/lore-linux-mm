Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 25E4A6B006E
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 13:56:00 -0400 (EDT)
Received: by wgwi7 with SMTP id i7so4854206wgw.0
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 10:55:59 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id jv5si15703339wid.14.2015.06.21.10.55.58
        for <linux-mm@kvack.org>;
        Sun, 21 Jun 2015 10:55:58 -0700 (PDT)
Date: Sun, 21 Jun 2015 20:55:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 2/3] mm: make optimistic check for swapin readahead
Message-ID: <20150621175520.GB6611@node.dhcp.inet.fi>
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434799686-7929-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Sat, Jun 20, 2015 at 02:28:05PM +0300, Ebru Akagunduz wrote:
> This patch makes optimistic check for swapin readahead
> to increase thp collapse rate. Before getting swapped
> out pages to memory, checks them and allows up to a
> certain number. It also prints out using tracepoints
> amount of unmapped ptes.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> ---
> Changes in v2:
>  - Nothing changed
> 
>  include/trace/events/huge_memory.h | 11 +++++++----
>  mm/huge_memory.c                   | 13 ++++++++++---
>  2 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index 4b9049b..53c9f2e 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -9,9 +9,9 @@
>  TRACE_EVENT(mm_khugepaged_scan_pmd,
>  
>  	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, bool writable,
> -		bool referenced, int none_or_zero, int collapse),
> +		bool referenced, int none_or_zero, int collapse, int unmapped),
>  
> -	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse),
> +	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse, unmapped),
>  
>  	TP_STRUCT__entry(
>  		__field(struct mm_struct *, mm)
> @@ -20,6 +20,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>  		__field(bool, referenced)
>  		__field(int, none_or_zero)
>  		__field(int, collapse)
> +		__field(int, unmapped)
>  	),
>  
>  	TP_fast_assign(
> @@ -29,15 +30,17 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>  		__entry->referenced = referenced;
>  		__entry->none_or_zero = none_or_zero;
>  		__entry->collapse = collapse;
> +		__entry->unmapped = unmapped;
>  	),
>  
> -	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d",
> +	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d, unmapped=%d",
>  		__entry->mm,
>  		__entry->vm_start,
>  		__entry->writable,
>  		__entry->referenced,
>  		__entry->none_or_zero,
> -		__entry->collapse)
> +		__entry->collapse,
> +		__entry->unmapped)
>  );
>  
>  TRACE_EVENT(mm_collapse_huge_page,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9bb97fc..22bc0bf 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -24,6 +24,7 @@
>  #include <linux/migrate.h>
>  #include <linux/hashtable.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/swapops.h>
>  
>  #include <asm/tlb.h>
>  #include <asm/pgalloc.h>
> @@ -2639,11 +2640,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  {
>  	pmd_t *pmd;
>  	pte_t *pte, *_pte;
> -	int ret = 0, none_or_zero = 0;
> +	int ret = 0, none_or_zero = 0, unmapped = 0;
>  	struct page *page;
>  	unsigned long _address;
>  	spinlock_t *ptl;
> -	int node = NUMA_NO_NODE;
> +	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;

I think this deserve sysfs knob. Like we have for
khugepaged_max_ptes_none.

>  	bool writable = false, referenced = false;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> @@ -2657,6 +2658,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
>  	     _pte++, _address += PAGE_SIZE) {
>  		pte_t pteval = *_pte;
> +		if (is_swap_pte(pteval)) {

IIRC, is_swap_pte() is true for migration entries too,
Should we distinguish swap entries from migration entries here?

I guess no. On other hand we can expect migration entires to be converted
to normal ptes soon...

> +			if (++unmapped <= max_ptes_swap)
> +				continue;
> +			else
> +				goto out_unmap;
> +		}
>  		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
>  			if (!userfaultfd_armed(vma) &&
>  			    ++none_or_zero <= khugepaged_max_ptes_none)
> @@ -2701,7 +2708,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
>  	trace_mm_khugepaged_scan_pmd(mm, vma->vm_start, writable, referenced,
> -				     none_or_zero, ret);
> +				     none_or_zero, ret, unmapped);
>  	if (ret) {
>  		node = khugepaged_find_target_node();
>  		/* collapse_huge_page will return with the mmap_sem released */
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
