Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D3D166B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 04:39:41 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so170662301wib.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 01:39:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4si35669583wjq.202.2015.07.28.01.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 01:39:39 -0700 (PDT)
Subject: Re: [RFC v3 1/3] mm: add tracepoint for scanning pages
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B73FC1.2070708@suse.cz>
Date: Tue, 28 Jul 2015 10:39:29 +0200
MIME-Version: 1.0
In-Reply-To: <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 07/13/2015 10:28 PM, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.
>
> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.
>
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> Changes in v2:
>   - Nothing changed
>
> Changes in v3:
>   - Print page address instead of vm_start (Vlastimil Babka)
>   - Define constants to specify exact tracepoint result (Vlastimil Babka)

Hi, and thanks for improving the tracepoints!

>
>   include/linux/mm.h                 |  18 ++++++
>   include/trace/events/huge_memory.h | 100 ++++++++++++++++++++++++++++++++
>   mm/huge_memory.c                   | 114 +++++++++++++++++++++++++++----------
>   3 files changed, 203 insertions(+), 29 deletions(-)
>   create mode 100644 include/trace/events/huge_memory.h
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7f47178..bf341c0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -21,6 +21,24 @@
>   #include <linux/resource.h>
>   #include <linux/page_ext.h>
>
> +#define MM_PMD_NULL		0
> +#define MM_EXCEED_NONE_PTE	3
> +#define MM_PTE_NON_PRESENT	4
> +#define MM_PAGE_NULL		5
> +#define MM_SCAN_ABORT		6
> +#define MM_PAGE_COUNT		7
> +#define MM_PAGE_LRU		8
> +#define MM_ANY_PROCESS		0
> +#define MM_VMA_NULL		2
> +#define MM_VMA_CHECK		3
> +#define MM_ADDRESS_RANGE	4
> +#define MM_PAGE_LOCK		2
> +#define MM_SWAP_CACHE_PAGE	6
> +#define MM_ISOLATE_LRU_PAGE	7
> +#define MM_ALLOC_HUGE_PAGE_FAIL	6
> +#define MM_CGROUP_CHARGE_FAIL	7
> +#define MM_COLLAPSE_ISOLATE_FAIL 5

this would better go to mm/huge_memory.c since it's used nowhere else, 
so we shouldn't pollute a global header. Also I'd suggest changing the 
MM_ prefix to e.g. SCAN_ ?
Reusing the numbers depending on whether they can appear in a single 
function is unnecessarily complicated, we don't have to fit in some 
small limit here. You could also use an enum to avoid defining each 
constant's value manually.

>   struct mempolicy;
>   struct anon_vma;
>   struct anon_vma_chain;
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> new file mode 100644
> index 0000000..cbc56fc
> --- /dev/null
> +++ b/include/trace/events/huge_memory.h
> @@ -0,0 +1,100 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM huge_memory
> +
> +#if !defined(__HUGE_MEMORY_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define __HUGE_MEMORY_H
> +
> +#include  <linux/tracepoint.h>
> +
> +TRACE_EVENT(mm_khugepaged_scan_pmd,
> +
> +	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
> +		 bool referenced, int none_or_zero, int ret),
> +
> +	TP_ARGS(mm, page, writable, referenced, none_or_zero, ret),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(struct page *, page)
> +		__field(bool, writable)
> +		__field(bool, referenced)
> +		__field(int, none_or_zero)
> +		__field(int, ret)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->page = page;
> +		__entry->writable = writable;
> +		__entry->referenced = referenced;
> +		__entry->none_or_zero = none_or_zero;
> +		__entry->ret = ret;
> +	),
> +
> +	TP_printk("mm=%p, page=%p, writable=%d, referenced=%d, none_or_zero=%d, ret=%d",
> +		__entry->mm,
> +		__entry->page,

Sorry, when I suggested "the address of the page itself" instead of 
vm_start, I was thinking physical address (pfn).
Compaction tracepoints recently standardized on this print format so I'd 
recommend it here too:

	scan_pfn=0x%lx

> +		__entry->writable,
> +		__entry->referenced,
> +		__entry->none_or_zero,
> +		__entry->ret)

Instead of printing a number that has to be translated manually, I'd 
recommend converting to string. Look at how compaction_status_string is 
defined in mm/compaction.c and used from the tracepoints.

[ ... ]

>
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/huge_memory.h>
> +
>   /*
>    * By default transparent hugepage support is disabled in order that avoid
>    * to risk increase the memory footprint of applications without a guaranteed
> @@ -2190,25 +2193,32 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   					unsigned long address,
>   					pte_t *pte)
>   {
> -	struct page *page;
> +	struct page *page = NULL;
>   	pte_t *_pte;
> -	int none_or_zero = 0;
> +	int none_or_zero = 0, ret = 0;
>   	bool referenced = false, writable = false;
>   	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>   	     _pte++, address += PAGE_SIZE) {
>   		pte_t pteval = *_pte;
>   		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
>   			if (!userfaultfd_armed(vma) &&
> -			    ++none_or_zero <= khugepaged_max_ptes_none)
> +			    ++none_or_zero <= khugepaged_max_ptes_none) {
>   				continue;
> -			else
> +			} else {
> +				ret = MM_EXCEED_NONE_PTE;
>   				goto out;
> +			}
>   		}
> -		if (!pte_present(pteval))
> +		if (!pte_present(pteval)) {
> +			ret = MM_PTE_NON_PRESENT;
>   			goto out;
> +		}
> +
>   		page = vm_normal_page(vma, address, pteval);
> -		if (unlikely(!page))
> +		if (unlikely(!page)) {
> +			ret = MM_PAGE_NULL;
>   			goto out;
> +		}
>
>   		VM_BUG_ON_PAGE(PageCompound(page), page);
>   		VM_BUG_ON_PAGE(!PageAnon(page), page);
> @@ -2220,8 +2230,10 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		 * is needed to serialize against split_huge_page
>   		 * when invoked from the VM.
>   		 */
> -		if (!trylock_page(page))
> +		if (!trylock_page(page)) {
> +			ret = MM_PAGE_LOCK;
>   			goto out;
> +		}
>
>   		/*
>   		 * cannot use mapcount: can't collapse if there's a gup pin.
> @@ -2230,6 +2242,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		 */
>   		if (page_count(page) != 1 + !!PageSwapCache(page)) {
>   			unlock_page(page);
> +			ret = MM_PAGE_COUNT;
>   			goto out;
>   		}
>   		if (pte_write(pteval)) {
> @@ -2237,6 +2250,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		} else {
>   			if (PageSwapCache(page) && !reuse_swap_page(page)) {
>   				unlock_page(page);
> +				ret = MM_SWAP_CACHE_PAGE;
>   				goto out;
>   			}
>   			/*
> @@ -2251,6 +2265,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		 */
>   		if (isolate_lru_page(page)) {
>   			unlock_page(page);
> +			ret = MM_ISOLATE_LRU_PAGE;
>   			goto out;
>   		}
>   		/* 0 stands for page_is_file_cache(page) == false */
> @@ -2263,11 +2278,16 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		    mmu_notifier_test_young(vma->vm_mm, address))
>   			referenced = true;
>   	}
> -	if (likely(referenced && writable))
> +	if (likely(referenced && writable)) {
> +		trace_mm_collapse_huge_page_isolate(page, none_or_zero,
> +						    referenced, writable, ret);
>   		return 1;
> +	}
>   out:
>   	release_pte_pages(pte, _pte);
> -	return 0;
> +	trace_mm_collapse_huge_page_isolate(page, none_or_zero,
> +					    referenced, writable, ret);
> +	return ret;
>   }

Having success returned as "1" and failures of either 0 or other 
positive values is uncommon and may lead to mistakes. Per 
Documentation/CodingStyle Chapter 16, it should be either 0 = success 
and any other = error, or 0 = failure, non-zero = success. Here the 
first variant would be applicable. Following the chapter strictly, the 
function should have been using this variant even before your patch, 
since here the "name of a function is an action or an imperative 
command" :) but yeah...

Anyway I don't think you need to return the exact error, since the 
caller doesn't use it. It's there only for the tracepoint, so you can 
simply keep returning just 1 or 0. Then with tracepoints disabled in 
.config, the compiler should be also able to eliminate all the 
assignments that would be unused in the end.
Same suggestions apply to khugepaged_scan_pmd()

>
>   static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
> @@ -2501,7 +2521,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   	pgtable_t pgtable;
>   	struct page *new_page;
>   	spinlock_t *pmd_ptl, *pte_ptl;
> -	int isolated;
> +	int isolated = 0, ret = 1;
>   	unsigned long hstart, hend;
>   	struct mem_cgroup *memcg;
>   	unsigned long mmun_start;	/* For mmu_notifiers */
> @@ -2516,12 +2536,18 @@ static void collapse_huge_page(struct mm_struct *mm,
>
>   	/* release the mmap_sem read lock. */
>   	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
> -	if (!new_page)
> +	if (!new_page) {
> +		ret = MM_ALLOC_HUGE_PAGE_FAIL;
> +		trace_mm_collapse_huge_page(mm, isolated, ret);
>   		return;
> +	}
>
>   	if (unlikely(mem_cgroup_try_charge(new_page, mm,
> -					   gfp, &memcg)))
> +					   gfp, &memcg))) {
> +		ret = MM_CGROUP_CHARGE_FAIL;
> +		trace_mm_collapse_huge_page(mm, isolated, ret);
>   		return;
> +	}

You could add a label called e.g. "out_nolock" right after 
"up_write(&mm->mmap_sem);" below, and goto there to avoid the multiple 
tracepoints.

>
>   	/*
>   	 * Prevent all access to pagetables with the exception of
> @@ -2529,21 +2555,31 @@ static void collapse_huge_page(struct mm_struct *mm,
>   	 * handled by the anon_vma lock + PG_lock.
>   	 */
>   	down_write(&mm->mmap_sem);
> -	if (unlikely(khugepaged_test_exit(mm)))
> +	if (unlikely(khugepaged_test_exit(mm))) {
> +		ret = MM_ANY_PROCESS;
>   		goto out;
> +	}
>
>   	vma = find_vma(mm, address);
> -	if (!vma)
> +	if (!vma) {
> +		ret = MM_VMA_NULL;
>   		goto out;
> +	}
>   	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>   	hend = vma->vm_end & HPAGE_PMD_MASK;
> -	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
> +	if (address < hstart || address + HPAGE_PMD_SIZE > hend) {
> +		ret = MM_ADDRESS_RANGE;
>   		goto out;
> -	if (!hugepage_vma_check(vma))
> +	}
> +	if (!hugepage_vma_check(vma)) {
> +		ret = MM_VMA_CHECK;
>   		goto out;
> +	}
>   	pmd = mm_find_pmd(mm, address);
> -	if (!pmd)
> +	if (!pmd) {
> +		ret = MM_PMD_NULL;
>   		goto out;
> +	}
>
>   	anon_vma_lock_write(vma->anon_vma);
>
> @@ -2568,7 +2604,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   	isolated = __collapse_huge_page_isolate(vma, address, pte);
>   	spin_unlock(pte_ptl);
>
> -	if (unlikely(!isolated)) {
> +	if (unlikely(isolated != 1)) {
>   		pte_unmap(pte);
>   		spin_lock(pmd_ptl);
>   		BUG_ON(!pmd_none(*pmd));
> @@ -2580,6 +2616,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
>   		spin_unlock(pmd_ptl);
>   		anon_vma_unlock_write(vma->anon_vma);
> +		ret = MM_COLLAPSE_ISOLATE_FAIL;
>   		goto out;
>   	}
>
> @@ -2619,6 +2656,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>   	khugepaged_pages_collapsed++;
>   out_up_write:
>   	up_write(&mm->mmap_sem);

out_nolock:

> +	trace_mm_collapse_huge_page(mm, isolated, ret);
>   	return;
>
>   out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
