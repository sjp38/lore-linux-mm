Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E91B06B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 22:43:38 -0500 (EST)
Received: by yxe10 with SMTP id 10so3551553yxe.12
        for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:43:37 -0800 (PST)
Message-ID: <4B2C4BE3.3030104@gmail.com>
Date: Sat, 19 Dec 2009 12:43:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 3/4] lockless vma caching
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>	<20091216101107.GA15031@basil.fritz.box>	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>	<20091216102806.GC15031@basil.fritz.box>	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com> <20091218094513.490f27b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091218094513.490f27b4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



KAMEZAWA Hiroyuki wrote:
> For accessing vma in lockless style, some modification for vma lookup is
> required. Now, rb-tree is used and it doesn't allow read while modification.
> 
> This is a trial to caching vma rather than diving into rb-tree. The last
> fault vma is cached to pgd's page->cached_vma field. And, add reference count
> and waitqueue to vma.
> 
> The accessor will have to do
> 
> 	vma = lookup_vma_cache(mm, address);
> 	if (vma) {
> 		if (mm_check_version(mm) && /* no write lock at this point ? */
> 		    (vma->vm_start <= address) && (vma->vm_end > address))
> 			goto found_vma; /* start speculative job */
> 		else
> 			vma_release_cache(vma);
> 		vma = NULL;
> 	}
> 	vma = find_vma();
> found_vma:
> 	....do some jobs....
> 	vma_release_cache(vma);
> 
> Maybe some more consideration for invalidation point is necessary.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/mm.h       |   20 +++++++++
>  include/linux/mm_types.h |    5 ++
>  mm/memory.c              |   14 ++++++
>  mm/mmap.c                |  102 +++++++++++++++++++++++++++++++++++++++++++++--
>  mm/page_alloc.c          |    1 
>  5 files changed, 138 insertions(+), 4 deletions(-)
> 
> Index: mmotm-mm-accessor/include/linux/mm.h
> ===================================================================
> --- mmotm-mm-accessor.orig/include/linux/mm.h
> +++ mmotm-mm-accessor/include/linux/mm.h
> @@ -763,6 +763,26 @@ unsigned long unmap_vmas(struct mmu_gath
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *);
>  
> +struct vm_area_struct *lookup_vma_cache(struct mm_struct *mm,
> +		unsigned long address);
> +void invalidate_vma_cache(struct mm_struct *mm,
> +		struct vm_area_struct *vma);
> +void wait_vmas_cache_range(struct vm_area_struct *vma, unsigned long end);
> +
> +static inline void vma_hold(struct vm_area_struct *vma)
Nitpick:
How about static inline void vma_cache_[get/put] naming?

> +{
> +	atomic_inc(&vma->cache_access);
> +}
> +
> +void __vma_release(struct vm_area_struct *vma);
> +static inline void vma_release(struct vm_area_struct *vma)
> +{
> +	if (atomic_dec_and_test(&vma->cache_access)) {
> +		if (waitqueue_active(&vma->cache_wait))
> +			__vma_release(vma);
> +	}
> +}
> +
>  /**
>   * mm_walk - callbacks for walk_page_range
>   * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> Index: mmotm-mm-accessor/include/linux/mm_types.h
> ===================================================================
> --- mmotm-mm-accessor.orig/include/linux/mm_types.h
> +++ mmotm-mm-accessor/include/linux/mm_types.h
> @@ -12,6 +12,7 @@
>  #include <linux/completion.h>
>  #include <linux/cpumask.h>
>  #include <linux/page-debug-flags.h>
> +#include <linux/wait.h>
>  #include <asm/page.h>
>  #include <asm/mmu.h>
>  
> @@ -77,6 +78,7 @@ struct page {
>  	union {
>  		pgoff_t index;		/* Our offset within mapping. */
>  		void *freelist;		/* SLUB: freelist req. slab lock */
> +		void *cache;

Let's add annotation "/* vm_area_struct cache when the page is used as page table */".


>  	};
>  	struct list_head lru;		/* Pageout list, eg. active_list
>  					 * protected by zone->lru_lock !
> @@ -180,6 +182,9 @@ struct vm_area_struct {
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>  	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
>  
> +	atomic_t cache_access;
> +	wait_queue_head_t cache_wait;
> +
>  #ifndef CONFIG_MMU
>  	struct vm_region *vm_region;	/* NOMMU mapping region */
>  #endif
> Index: mmotm-mm-accessor/mm/memory.c
> ===================================================================
> --- mmotm-mm-accessor.orig/mm/memory.c
> +++ mmotm-mm-accessor/mm/memory.c
> @@ -145,6 +145,14 @@ void pmd_clear_bad(pmd_t *pmd)
>  	pmd_clear(pmd);
>  }
>  

Let's put the note here. "The caller needs to hold the pte lock"

> +static void update_vma_cache(pmd_t *pmd, struct vm_area_struct *vma)
> +{
> +	struct page *page;
> +	/* ptelock is held */
> +	page = pmd_page(*pmd);
> +	page->cache = vma;
> +}
> +
>  /*
>   * Note: this doesn't free the actual pages themselves. That
>   * has been handled earlier when unmapping all the memory regions.
> @@ -2118,6 +2126,7 @@ reuse:
>  		if (ptep_set_access_flags(vma, address, page_table, entry,1))
>  			update_mmu_cache(vma, address, entry);
>  		ret |= VM_FAULT_WRITE;
> +		update_vma_cache(pmd, vma);
>  		goto unlock;
>  	}
>  
..
<snip>
..

> Index: mmotm-mm-accessor/mm/page_alloc.c
> ===================================================================
> --- mmotm-mm-accessor.orig/mm/page_alloc.c
> +++ mmotm-mm-accessor/mm/page_alloc.c
> @@ -698,6 +698,7 @@ static int prep_new_page(struct page *pa
>  
>  	set_page_private(page, 0);
>  	set_page_refcounted(page);
> +	page->cache = NULL;

Is here is proper place to initialize page->cache?
It cause unnecessary overhead about not pmd page.

How about pmd_alloc?

>  
>  	arch_alloc_page(page, order);
>  	kernel_map_pages(page, 1 << order, 1);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
