Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B01596B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 07:59:37 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so132564919wic.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 04:59:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li12si2435938wic.91.2015.06.24.04.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 04:59:36 -0700 (PDT)
Subject: Re: [RFC v2 1/3] mm: add tracepoint for scanning pages
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-2-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <558A9BA1.5070508@suse.cz>
Date: Wed, 24 Jun 2015 13:59:29 +0200
MIME-Version: 1.0
In-Reply-To: <1434799686-7929-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/20/2015 01:28 PM, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.

I agree and welcome the addition. But to get most of the tracepoints, I'd like
to suggest quite a lot of improvements below.

> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> Changes in v2:
>  - Nothing changed
> 
>  include/trace/events/huge_memory.h | 96 ++++++++++++++++++++++++++++++++++++++
>  mm/huge_memory.c                   | 10 +++-
>  2 files changed, 105 insertions(+), 1 deletion(-)
>  create mode 100644 include/trace/events/huge_memory.h
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> new file mode 100644
> index 0000000..4b9049b
> --- /dev/null
> +++ b/include/trace/events/huge_memory.h
> @@ -0,0 +1,96 @@
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
> +	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, bool writable,
> +		bool referenced, int none_or_zero, int collapse),
> +
> +	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, vm_start)
> +		__field(bool, writable)
> +		__field(bool, referenced)
> +		__field(int, none_or_zero)
> +		__field(int, collapse)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->vm_start = vm_start;
> +		__entry->writable = writable;
> +		__entry->referenced = referenced;
> +		__entry->none_or_zero = none_or_zero;
> +		__entry->collapse = collapse;
> +	),
> +
> +	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d",
> +		__entry->mm,
> +		__entry->vm_start,
> +		__entry->writable,
> +		__entry->referenced,
> +		__entry->none_or_zero,
> +		__entry->collapse)
> +);
> +
> +TRACE_EVENT(mm_collapse_huge_page,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, int isolated),

Why vm_start and not the address of the page itself?

> +
> +	TP_ARGS(mm, vm_start, isolated),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, vm_start)
> +		__field(int, isolated)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->vm_start = vm_start;
> +		__entry->isolated = isolated;
> +	),
> +
> +	TP_printk("mm=%p, vm_start=%04lx, isolated=%d",
> +		__entry->mm,
> +		__entry->vm_start,
> +		__entry->isolated)
> +);
> +
> +TRACE_EVENT(mm_collapse_huge_page_isolate,
> +
> +	TP_PROTO(unsigned long vm_start, int none_or_zero,
> +		bool referenced, bool  writable),
> +
> +	TP_ARGS(vm_start, none_or_zero, referenced, writable),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, vm_start)
> +		__field(int, none_or_zero)
> +		__field(bool, referenced)
> +		__field(bool, writable)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->vm_start = vm_start;
> +		__entry->none_or_zero = none_or_zero;
> +		__entry->referenced = referenced;
> +		__entry->writable = writable;
> +	),
> +
> +	TP_printk("vm_start=%04lx, none_or_zero=%d, referenced=%d, writable=%d",
> +		__entry->vm_start,
> +		__entry->none_or_zero,
> +		__entry->referenced,
> +		__entry->writable)
> +);
> +
> +#endif /* __HUGE_MEMORY_H */
> +#include <trace/define_trace.h>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9671f51..9bb97fc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -29,6 +29,9 @@
>  #include <asm/pgalloc.h>
>  #include "internal.h"
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/huge_memory.h>
> +
>  /*
>   * By default transparent hugepage support is disabled in order that avoid
>   * to risk increase the memory footprint of applications without a guaranteed
> @@ -2266,6 +2269,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  	if (likely(referenced && writable))
>  		return 1;

No tracepoint here, so it only traces isolation failures. That's misleading,
because the event name doesnt suggest that. I suggest recording both, and
distinguishing by another event parameter, with value matching what's returned
from the function.

>  out:
> +	trace_mm_collapse_huge_page_isolate(vma->vm_start, none_or_zero,

Again, why vm_start and not the value of address? Or maybe, the initial value of
address (=the beginning of future hugepage) in case isolation succeeds, or the
current value of address when it fails on a particular pte due to one of the
"goto out"s.

> +					    referenced, writable);

OK so again there are numerous reasons why isolation can fail due to the "goto
out"s, which the tracepoint doesn't tell us. "referenced" and "writable" tells
us that if we've seen such pte in the previous iterations, but otherwise they
may have nothing to do with the failure. We could distinguish "unexpected pte",
failure to lock, gup pin, reuse_swap_page() fail, isolate_lru_page() fail...

>  	release_pte_pages(pte, _pte);
>  	return 0;
>  }
> @@ -2501,7 +2506,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	pgtable_t pgtable;
>  	struct page *new_page;
>  	spinlock_t *pmd_ptl, *pte_ptl;
> -	int isolated;
> +	int isolated = 0;

It's only used for 0/1 so why not convert it to bool, together with the return
value of __collapse_huge_page_isolate(). And the tracepoints accordingly.

>  	unsigned long hstart, hend;
>  	struct mem_cgroup *memcg;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
> @@ -2619,6 +2624,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	khugepaged_pages_collapsed++;
>  out_up_write:
>  	up_write(&mm->mmap_sem);
> +	trace_mm_collapse_huge_page(mm, vma->vm_start, isolated);

The tracepoint as it is cannot distinguish many cases why collapse_huge_page()
fails:
- khugepaged_alloc_page() fails, or cgroup charge fails. In that case the
tracepoint isn't even called, which might be surprising.
- the various checks before isolation is attempted fail. Isolated will be
reported as 0 which might suggest it failed, but in fact it wasn't even attempted.

Distinguishing all reasons to fail would be probably overkill, but it would make
sense to report separately allocation fail, memcg charge fail, isolation not
attempted (= any of checks after taking mmap_sem fail), isolation failed.

It would be a bit intrusive even when tracepoint is disabled, but this is not
exactly hot path. See e.g. how trace_mm_compaction_end reports various outcomes
of the status as a string.

>  	return;
>  
>  out:
> @@ -2694,6 +2700,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		ret = 1;
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> +	trace_mm_khugepaged_scan_pmd(mm, vma->vm_start, writable, referenced,
> +				     none_or_zero, ret);

This is similar to trace_mm_collapse_huge_page_isolate and I think all my
suggestions apply here too. In fact the tracepoints could probably have the same
signature and you could use a single DECLARE_EVENT_CLASS for them both.
>  	if (ret) {
>  		node = khugepaged_find_target_node();
>  		/* collapse_huge_page will return with the mmap_sem released */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
