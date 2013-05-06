Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 37C996B0118
	for <linux-mm@kvack.org>; Mon,  6 May 2013 03:16:32 -0400 (EDT)
Message-ID: <51875977.4090006@cn.fujitsu.com>
Date: Mon, 06 May 2013 15:19:19 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 3/5] mm: get_user_pages: use NON-MOVABLE pages when
 FOLL_DURABLE flag is set
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com> <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hi Marek,

It has been a long time since this patch-set was sent.
And I'm pushing memory hot-remove works. I think I need your
[patch3/5] to fix a problem I met.

We have sent a similar patch before. But I think yours may be better. :)
https://lkml.org/lkml/2013/2/21/126

So would you please update and resend your patch again ?
Or do you have your own plan to push it ?

Thanks. :)

On 03/05/2013 02:57 PM, Marek Szyprowski wrote:
> Ensure that newly allocated pages, which are faulted in in FOLL_DURABLE
> mode comes from non-movalbe pageblocks, to workaround migration failures
> with Contiguous Memory Allocator.
>
> Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park<kyungmin.park@samsung.com>
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
> +				if (gup_flags&  FOLL_DURABLE)
> +					fault_flags = FAULT_FLAG_NO_CMA;
> +
>   				/* For mlock, just skip the stack guard page. */
>   				if (foll_flags&  FOLL_MLOCK) {
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
> +	if (IS_ENABLED(CONFIG_CMA)&&  (flags&  FAULT_FLAG_NO_CMA))
> +		gfp&= ~__GFP_MOVABLE;
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
>   	if (flags&  FAULT_FLAG_WRITE) {
> -		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> +		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte, flags);
>   		if (ret&  VM_FAULT_ERROR)
>   			ret&= VM_FAULT_ERROR;
>   		goto out;
> @@ -3187,6 +3194,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   	struct vm_fault vmf;
>   	int ret;
>   	int page_mkwrite = 0;
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +
> +	if (IS_ENABLED(CONFIG_CMA)&&  (flags&  FAULT_FLAG_NO_CMA))
> +		gfp&= ~__GFP_MOVABLE;
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
>   	if (flags&  FAULT_FLAG_WRITE) {
>   		if (!pte_write(entry))
>   			return do_wp_page(mm, vma, address,
> -					pte, pmd, ptl, entry);
> +					pte, pmd, ptl, entry, flags);
>   		entry = pte_mkdirty(entry);
>   	}
>   	entry = pte_mkyoung(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
