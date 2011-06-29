Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2BB6B0106
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 08:09:09 -0400 (EDT)
Date: Wed, 29 Jun 2011 14:09:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-preallocate-page-before-lock_page-at-filemap-cow.patch
 added to -mm tree
Message-ID: <20110629120902.GE19166@tiehlicka.suse.cz>
References: <201106290017.p5T0HKC3016797@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106290017.p5T0HKC3016797@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, lvml@5t9.de, nishimura@mxp.nes.nec.co.jp, yinghan@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Shouldn't we discuss unlock, charge, unlock&recheck_mapping approach
as well before this gets merged? There are some concerns expressed
during discussion - https://lkml.org/lkml/2011/6/23/135.
The full thread is at https://lkml.org/lkml/2011/6/22/163

I do not mind which bugfix is used in the end I would just be happier if
they would get some more review.

On Tue 28-06-11 17:17:20, Andrew Morton wrote:
> ------------------------------------------------------
> Subject: mm: preallocate page before lock_page() at filemap COW
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Currently we are keeping faulted page locked throughout whole __do_fault
> call (except for page_mkwrite code path) after calling file system's fault
> code.  If we do early COW, we allocate a new page which has to be charged
> for a memcg (mem_cgroup_newpage_charge).
> 
> This function, however, might block for unbounded amount of time if memcg
> oom killer is disabled or fork-bomb is running because the only way out of
> the OOM situation is either an external event or OOM-situation fix.
> 
> In the end we are keeping the faulted page locked and blocking other
> processes from faulting it in which is not good at all because we are
> basically punishing potentially an unrelated process for OOM condition in
> a different group (I have seen stuck system because of ld-2.11.1.so being
> locked).
> 
> We can do test easily.
> 
>  % cgcreate -g memory:A
>  % cgset -r memory.limit_in_bytes=64M A
>  % cgset -r memory.memsw.limit_in_bytes=64M A
>  % cd kernel_dir; cgexec -g memory:A make -j
> 
> Then, the whole system will live-locked until you kill 'make -j'
> by hands (or push reboot...) This is because some important page in a
> a shared library are locked.
> 
> Considering again, the new page is not necessary to be allocated
> with lock_page() held. And usual page allocation may dive into
> long memory reclaim loop with holding lock_page() and can cause
> very long latency.
> 
> There are 3 ways.
>   1. do allocation/charge before lock_page()
>      Pros. - simple and can handle page allocation in the same manner.
>              This will reduce holding time of lock_page() in general.
>      Cons. - we do page allocation even if ->fault() returns error.
> 
>   2. do charge after unlock_page(). Even if charge fails, it's just OOM.
>      Pros. - no impact to non-memcg path.
>      Cons. - implemenation requires special cares of LRU and we need to modify
>              page_add_new_anon_rmap()...
> 
>   3. do unlock->charge->lock again method.
>      Pros. - no impact to non-memcg path.
>      Cons. - This may kill LOCK_PAGE_RETRY optimization. We need to release
>              lock and get it again...
> 
> This patch moves "charge" and memory allocation for COW page
> before lock_page(). Then, we can avoid scanning LRU with holding
> a lock on a page and latency under lock_page() will be reduced.
> 
> Then, above livelock disappears.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reported-by: Lutz Vieweg <lvml@5t9.de>
> Original-idea-by: Michal Hocko <mhocko@suse.cz>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Ying Han <yinghan@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memory.c |   56 ++++++++++++++++++++++++++++++--------------------
>  1 file changed, 34 insertions(+), 22 deletions(-)
> 
> diff -puN mm/memory.c~mm-preallocate-page-before-lock_page-at-filemap-cow mm/memory.c
> --- a/mm/memory.c~mm-preallocate-page-before-lock_page-at-filemap-cow
> +++ a/mm/memory.c
> @@ -3104,14 +3104,34 @@ static int __do_fault(struct mm_struct *
>  	pte_t *page_table;
>  	spinlock_t *ptl;
>  	struct page *page;
> +	struct page *cow_page;
>  	pte_t entry;
>  	int anon = 0;
> -	int charged = 0;
>  	struct page *dirty_page = NULL;
>  	struct vm_fault vmf;
>  	int ret;
>  	int page_mkwrite = 0;
>  
> +	/*
> +	 * If we do COW later, allocate page befor taking lock_page()
> +	 * on the file cache page. This will reduce lock holding time.
> +	 */
> +	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> +
> +		if (unlikely(anon_vma_prepare(vma)))
> +			return  VM_FAULT_OOM;
> +
> +		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +		if (!cow_page)
> +			return VM_FAULT_OOM;
> +
> +		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
> +			page_cache_release(cow_page);
> +			return VM_FAULT_OOM;
> +		}
> +	} else
> +		cow_page = NULL;
> +
>  	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
>  	vmf.pgoff = pgoff;
>  	vmf.flags = flags;
> @@ -3120,12 +3140,13 @@ static int __do_fault(struct mm_struct *
>  	ret = vma->vm_ops->fault(vma, &vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
>  			    VM_FAULT_RETRY)))
> -		return ret;
> +		goto uncharge_out;
>  
>  	if (unlikely(PageHWPoison(vmf.page))) {
>  		if (ret & VM_FAULT_LOCKED)
>  			unlock_page(vmf.page);
> -		return VM_FAULT_HWPOISON;
> +		ret = VM_FAULT_HWPOISON;
> +		goto uncharge_out;
>  	}
>  
>  	/*
> @@ -3143,23 +3164,8 @@ static int __do_fault(struct mm_struct *
>  	page = vmf.page;
>  	if (flags & FAULT_FLAG_WRITE) {
>  		if (!(vma->vm_flags & VM_SHARED)) {
> +			page = cow_page;
>  			anon = 1;
> -			if (unlikely(anon_vma_prepare(vma))) {
> -				ret = VM_FAULT_OOM;
> -				goto out;
> -			}
> -			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
> -						vma, address);
> -			if (!page) {
> -				ret = VM_FAULT_OOM;
> -				goto out;
> -			}
> -			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
> -				ret = VM_FAULT_OOM;
> -				page_cache_release(page);
> -				goto out;
> -			}
> -			charged = 1;
>  			copy_user_highpage(page, vmf.page, address, vma);
>  			__SetPageUptodate(page);
>  		} else {
> @@ -3228,8 +3234,8 @@ static int __do_fault(struct mm_struct *
>  		/* no need to invalidate: a not-present page won't be cached */
>  		update_mmu_cache(vma, address, page_table);
>  	} else {
> -		if (charged)
> -			mem_cgroup_uncharge_page(page);
> +		if (cow_page)
> +			mem_cgroup_uncharge_page(cow_page);
>  		if (anon)
>  			page_cache_release(page);
>  		else
> @@ -3238,7 +3244,6 @@ static int __do_fault(struct mm_struct *
>  
>  	pte_unmap_unlock(page_table, ptl);
>  
> -out:
>  	if (dirty_page) {
>  		struct address_space *mapping = page->mapping;
>  
> @@ -3268,6 +3273,13 @@ out:
>  unwritable_page:
>  	page_cache_release(page);
>  	return ret;
> +uncharge_out:
> +	/* fs's fault handler get error */
> +	if (cow_page) {
> +		mem_cgroup_uncharge_page(cow_page);
> +		page_cache_release(cow_page);
> +	}
> +	return ret;
>  }
>  
>  static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> _
> 
> Patches currently in -mm which might be from kamezawa.hiroyu@jp.fujitsu.com are
> 
> memcg-fix-reclaimable-lru-check-in-memcg.patch
> memcg-fix-reclaimable-lru-check-in-memcg-checkpatch-fixes.patch
> memcg-fix-reclaimable-lru-check-in-memcg-fix.patch
> memcg-fix-numa-scan-information-update-to-be-triggered-by-memory-event.patch
> memcg-fix-numa-scan-information-update-to-be-triggered-by-memory-event-fix.patch
> mm-preallocate-page-before-lock_page-at-filemap-cow.patch
> mm-preallocate-page-before-lock_page-at-filemap-cow-fix.patch
> mm-page_cgroupc-simplify-code-by-using-section_align_up-and-section_align_down-macros.patch
> memcg-do-not-expose-uninitialized-mem_cgroup_per_node-to-world.patch
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
