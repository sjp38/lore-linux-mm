Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DAD936B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 21:03:30 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 653833EE0C0
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:03:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4630545DEBF
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:03:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BA8145DEB5
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:03:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18CD11DB804D
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:03:29 +0900 (JST)
Received: from g01jpexchyt26.g01.fujitsu.local (g01jpexchyt26.g01.fujitsu.local [10.128.193.109])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F4CAE08011
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:03:28 +0900 (JST)
Message-ID: <5136A3CF.7020407@jp.fujitsu.com>
Date: Wed, 6 Mar 2013 11:02:55 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 3/5] mm: get_user_pages: use NON-MOVABLE pages when
 FOLL_DURABLE flag is set
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com> <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

2013/03/05 15:57, Marek Szyprowski wrote:
> Ensure that newly allocated pages, which are faulted in in FOLL_DURABLE
> mode comes from non-movalbe pageblocks, to workaround migration failures
> with Contiguous Memory Allocator.

In your idea, all users who uses non-movable pageblocks need to set
gup_flags. It's not good.

So how about prepare "get_user_pages_non_movable"? The idea is based on
following Lin Feng's idea:
https://lkml.org/lkml/2013/2/21/123

int get_user_pages_non_movable()
{
        int flags = FOLL_TOUCH | FOLL_DURABLE;

        if (pages)
                flags |= FOLL_GET;
        if (write)
                flags |= FOLL_WRITE;
        if (force)
                flags |= FOLL_FORCE;

	return __get_user_pages();
}

> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>   include/linux/highmem.h |   12 ++++++++++--
>   include/linux/mm.h      |    2 ++
>   mm/memory.c             |   24 ++++++++++++++++++------
>   3 files changed, 30 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 7fb31da..cf0b9d8 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -168,7 +168,8 @@ __alloc_zeroed_user_highpage(gfp_t movableflags,
>   #endif
>   
>   /**
> - * alloc_zeroed_user_highpage_movable - Allocate a zeroed HIGHMEM page for a VMA that the caller knows can move
> + * alloc_zeroed_user_highpage_movable - Allocate a zeroed HIGHMEM page for
> + *					a VMA that the caller knows can move
>    * @vma: The VMA the page is to be allocated for
>    * @vaddr: The virtual address the page will be inserted into
>    *
> @@ -177,11 +178,18 @@ __alloc_zeroed_user_highpage(gfp_t movableflags,
>    */
>   static inline struct page *
>   alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
> -					unsigned long vaddr)
> +				   unsigned long vaddr)
>   {
>   	return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
>   }
>   
> +static inline struct page *
> +alloc_zeroed_user_highpage(gfp_t gfp, struct vm_area_struct *vma,
> +			   unsigned long vaddr)
> +{
> +	return __alloc_zeroed_user_highpage(gfp, vma, vaddr);
> +}
> +
>   static inline void clear_highpage(struct page *page)
>   {
>   	void *kaddr = kmap_atomic(page);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 9806e54..c11f58f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -165,6 +165,7 @@ extern pgprot_t protection_map[16];
>   #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
>   #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
>   #define FAULT_FLAG_TRIED	0x40	/* second try */

> +#define FAULT_FLAG_NO_CMA	0x80	/* don't use CMA pages */

How about FAULT_FLAG_NO_MIGLATABLE? I want to use it to not only CMA but
also memory hotplug.

>   
>   /*
>    * vm_fault is filled by the the pagefault handler and passed to the vma's
> @@ -1633,6 +1634,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
>   #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
>   #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
>   #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
> +#define FOLL_DURABLE	0x800	/* get the page reference for a long time */
>   
>   typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>   			void *data);
> diff --git a/mm/memory.c b/mm/memory.c
> index 42dfd8e..2b9c2dd 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1816,6 +1816,9 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>   				int ret;
>   				unsigned int fault_flags = 0;
>   
> +				if (gup_flags & FOLL_DURABLE)
> +					fault_flags = FAULT_FLAG_NO_CMA;
> +
>   				/* For mlock, just skip the stack guard page. */
>   				if (foll_flags & FOLL_MLOCK) {
>   					if (stack_guard_page(vma, start))
> @@ -2495,7 +2498,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>    */
>   static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		spinlock_t *ptl, pte_t orig_pte)
> +		spinlock_t *ptl, pte_t orig_pte, unsigned int flags)
>   	__releases(ptl)
>   {
>   	struct page *old_page, *new_page = NULL;
> @@ -2505,6 +2508,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	struct page *dirty_page = NULL;
>   	unsigned long mmun_start = 0;	/* For mmu_notifiers */
>   	unsigned long mmun_end = 0;	/* For mmu_notifiers */
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +

> +	if (IS_ENABLED(CONFIG_CMA) && (flags & FAULT_FLAG_NO_CMA))
> +		gfp &= ~__GFP_MOVABLE;

Pleae remove IS_ENABLED(CONFIG_CMA) check.

>   
>   	old_page = vm_normal_page(vma, address, orig_pte);
>   	if (!old_page) {
> @@ -2668,11 +2675,11 @@ gotten:
>   		goto oom;
>   
>   	if (is_zero_pfn(pte_pfn(orig_pte))) {
> -		new_page = alloc_zeroed_user_highpage_movable(vma, address);
> +		new_page = alloc_zeroed_user_highpage(gfp, vma, address);
>   		if (!new_page)
>   			goto oom;
>   	} else {
> -		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +		new_page = alloc_page_vma(gfp, vma, address);
>   		if (!new_page)
>   			goto oom;
>   		cow_user_page(new_page, old_page, address, vma);
> @@ -3032,7 +3039,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	}
>   
>   	if (flags & FAULT_FLAG_WRITE) {
> -		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> +		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte, flags);
>   		if (ret & VM_FAULT_ERROR)
>   			ret &= VM_FAULT_ERROR;
>   		goto out;
> @@ -3187,6 +3194,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   	struct vm_fault vmf;
>   	int ret;
>   	int page_mkwrite = 0;
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +

> +	if (IS_ENABLED(CONFIG_CMA) && (flags & FAULT_FLAG_NO_CMA))
> +		gfp &= ~__GFP_MOVABLE;

Pleae remove IS_ENABLED(CONFIG_CMA) check.

> +
>   
>   	/*
>   	 * If we do COW later, allocate page befor taking lock_page()
> @@ -3197,7 +3209,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   		if (unlikely(anon_vma_prepare(vma)))
>   			return VM_FAULT_OOM;
>   
> -		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +		cow_page = alloc_page_vma(gfp, vma, address);
>   		if (!cow_page)
>   			return VM_FAULT_OOM;
>   
> @@ -3614,7 +3626,7 @@ int handle_pte_fault(struct mm_struct *mm,
>   	if (flags & FAULT_FLAG_WRITE) {
>   		if (!pte_write(entry))
>   			return do_wp_page(mm, vma, address,
> -					pte, pmd, ptl, entry);
> +					pte, pmd, ptl, entry, flags);
>   		entry = pte_mkdirty(entry);
>   	}
>   	entry = pte_mkyoung(entry);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
