Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id E96C76B008A
	for <linux-mm@kvack.org>; Tue, 28 May 2013 21:10:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 29 May 2013 06:33:57 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6131B394004E
	for <linux-mm@kvack.org>; Wed, 29 May 2013 06:40:04 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4T19vZi6160840
	for <linux-mm@kvack.org>; Wed, 29 May 2013 06:39:58 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4T1A1cu019670
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:10:01 +1000
Date: Wed, 29 May 2013 09:09:59 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
Message-ID: <20130529010959.GA6530@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369770771-8447-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Tue, May 28, 2013 at 03:52:50PM -0400, Naoya Horiguchi wrote:
>Currently all of page table handling by hugetlbfs code are done under
>mm->page_table_lock. This is not optimal because there can be lock
>contentions between unrelated components using this lock.
>
>This patch makes hugepage support split page table lock so that
>we use page->ptl of the leaf node of page table tree which is pte for
>normal pages but can be pmd and/or pud for hugepages of some architectures.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> arch/x86/mm/hugetlbpage.c |  6 ++--
> include/linux/hugetlb.h   | 18 ++++++++++
> mm/hugetlb.c              | 84 ++++++++++++++++++++++++++++-------------------
> 3 files changed, 73 insertions(+), 35 deletions(-)
>
>diff --git v3.10-rc3.orig/arch/x86/mm/hugetlbpage.c v3.10-rc3/arch/x86/mm/hugetlbpage.c
>index ae1aa71..0e4a396 100644
>--- v3.10-rc3.orig/arch/x86/mm/hugetlbpage.c
>+++ v3.10-rc3/arch/x86/mm/hugetlbpage.c
>@@ -75,6 +75,7 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> 	unsigned long saddr;
> 	pte_t *spte = NULL;
> 	pte_t *pte;
>+	spinlock_t *ptl;
>
> 	if (!vma_shareable(vma, addr))
> 		return (pte_t *)pmd_alloc(mm, pud, addr);
>@@ -89,6 +90,7 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> 			spte = huge_pte_offset(svma->vm_mm, saddr);
> 			if (spte) {
> 				get_page(virt_to_page(spte));
>+				ptl = huge_pte_lockptr(mm, spte);
> 				break;
> 			}
> 		}
>@@ -97,12 +99,12 @@ huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> 	if (!spte)
> 		goto out;
>
>-	spin_lock(&mm->page_table_lock);
>+	spin_lock(ptl);
> 	if (pud_none(*pud))
> 		pud_populate(mm, pud, (pmd_t *)((unsigned long)spte & PAGE_MASK));
> 	else
> 		put_page(virt_to_page(spte));
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
> out:
> 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> 	mutex_unlock(&mapping->i_mmap_mutex);
>diff --git v3.10-rc3.orig/include/linux/hugetlb.h v3.10-rc3/include/linux/hugetlb.h
>index a639c87..40f3215 100644
>--- v3.10-rc3.orig/include/linux/hugetlb.h
>+++ v3.10-rc3/include/linux/hugetlb.h
>@@ -32,6 +32,24 @@ void hugepage_put_subpool(struct hugepage_subpool *spool);
>
> int PageHuge(struct page *page);
>
>+#if USE_SPLIT_PTLOCKS
>+#define huge_pte_lockptr(mm, ptep) ({__pte_lockptr(virt_to_page(ptep)); })
>+#else	/* !USE_SPLIT_PTLOCKS */
>+#define huge_pte_lockptr(mm, ptep) ({&(mm)->page_table_lock; })
>+#endif	/* USE_SPLIT_PTLOCKS */
>+
>+#define huge_pte_offset_lock(mm, address, ptlp)		\
>+({							\
>+	pte_t *__pte = huge_pte_offset(mm, address);	\
>+	spinlock_t *__ptl = NULL;			\
>+	if (__pte) {					\
>+		__ptl = huge_pte_lockptr(mm, __pte);	\
>+		*(ptlp) = __ptl;			\
>+		spin_lock(__ptl);			\
>+	}						\
>+	__pte;						\
>+})
>+
> void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
> int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>diff --git v3.10-rc3.orig/mm/hugetlb.c v3.10-rc3/mm/hugetlb.c
>index 463fb5e..8e1af32 100644
>--- v3.10-rc3.orig/mm/hugetlb.c
>+++ v3.10-rc3/mm/hugetlb.c
>@@ -2325,6 +2325,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
>
> 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>+		spinlock_t *srcptl, *dstptl;
> 		src_pte = huge_pte_offset(src, addr);
> 		if (!src_pte)
> 			continue;
>@@ -2336,8 +2337,10 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> 		if (dst_pte == src_pte)
> 			continue;
>
>-		spin_lock(&dst->page_table_lock);
>-		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
>+		dstptl = huge_pte_lockptr(dst, dst_pte);
>+		srcptl = huge_pte_lockptr(src, src_pte);
>+		spin_lock(dstptl);
>+		spin_lock_nested(srcptl, SINGLE_DEPTH_NESTING);
> 		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> 			if (cow)
> 				huge_ptep_set_wrprotect(src, addr, src_pte);
>@@ -2347,8 +2350,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> 			page_dup_rmap(ptepage);
> 			set_huge_pte_at(dst, addr, dst_pte, entry);
> 		}
>-		spin_unlock(&src->page_table_lock);
>-		spin_unlock(&dst->page_table_lock);
>+		spin_unlock(srcptl);
>+		spin_unlock(dstptl);
> 	}
> 	return 0;
>
>@@ -2391,6 +2394,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> 	unsigned long address;
> 	pte_t *ptep;
> 	pte_t pte;
>+	spinlock_t *ptl;
> 	struct page *page;
> 	struct hstate *h = hstate_vma(vma);
> 	unsigned long sz = huge_page_size(h);
>@@ -2404,25 +2408,24 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> 	tlb_start_vma(tlb, vma);
> 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> again:
>-	spin_lock(&mm->page_table_lock);
> 	for (address = start; address < end; address += sz) {
>-		ptep = huge_pte_offset(mm, address);
>+		ptep = huge_pte_offset_lock(mm, address, &ptl);
> 		if (!ptep)
> 			continue;
>
> 		if (huge_pmd_unshare(mm, &address, ptep))
>-			continue;
>+			goto unlock;
>
> 		pte = huge_ptep_get(ptep);
> 		if (huge_pte_none(pte))
>-			continue;
>+			goto unlock;
>
> 		/*
> 		 * HWPoisoned hugepage is already unmapped and dropped reference
> 		 */
> 		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
> 			huge_pte_clear(mm, address, ptep);
>-			continue;
>+			goto unlock;
> 		}
>
> 		page = pte_page(pte);
>@@ -2433,7 +2436,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> 		 */
> 		if (ref_page) {
> 			if (page != ref_page)
>-				continue;
>+				goto unlock;
>
> 			/*
> 			 * Mark the VMA as having unmapped its page so that
>@@ -2450,13 +2453,18 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>
> 		page_remove_rmap(page);
> 		force_flush = !__tlb_remove_page(tlb, page);
>-		if (force_flush)
>+		if (force_flush) {
>+			spin_unlock(ptl);
> 			break;
>+		}
> 		/* Bail out after unmapping reference page if supplied */
>-		if (ref_page)
>+		if (ref_page) {
>+			spin_unlock(ptl);
> 			break;
>+		}
>+unlock:
>+		spin_unlock(ptl);
> 	}
>-	spin_unlock(&mm->page_table_lock);
> 	/*
> 	 * mmu_gather ran out of room to batch pages, we break out of
> 	 * the PTE lock to avoid doing the potential expensive TLB invalidate
>@@ -2570,6 +2578,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 	int outside_reserve = 0;
> 	unsigned long mmun_start;	/* For mmu_notifiers */
> 	unsigned long mmun_end;		/* For mmu_notifiers */
>+	spinlock_t *ptl = huge_pte_lockptr(mm, ptep);
>
> 	old_page = pte_page(pte);
>
>@@ -2601,7 +2610,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 	page_cache_get(old_page);
>
> 	/* Drop page_table_lock as buddy allocator may be called */
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
> 	new_page = alloc_huge_page(vma, address, outside_reserve);
>
> 	if (IS_ERR(new_page)) {
>@@ -2619,7 +2628,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 			BUG_ON(huge_pte_none(pte));
> 			if (unmap_ref_private(mm, vma, old_page, address)) {
> 				BUG_ON(huge_pte_none(pte));
>-				spin_lock(&mm->page_table_lock);
>+				spin_lock(ptl);
> 				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> 				if (likely(pte_same(huge_ptep_get(ptep), pte)))
> 					goto retry_avoidcopy;
>@@ -2633,7 +2642,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 		}
>
> 		/* Caller expects lock to be held */
>-		spin_lock(&mm->page_table_lock);
>+		spin_lock(ptl);
> 		if (err == -ENOMEM)
> 			return VM_FAULT_OOM;
> 		else
>@@ -2648,7 +2657,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 		page_cache_release(new_page);
> 		page_cache_release(old_page);
> 		/* Caller expects lock to be held */
>-		spin_lock(&mm->page_table_lock);
>+		spin_lock(ptl);
> 		return VM_FAULT_OOM;
> 	}
>
>@@ -2663,7 +2672,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 	 * Retake the page_table_lock to check for racing updates
> 	 * before the page tables are altered
> 	 */
>-	spin_lock(&mm->page_table_lock);
>+	spin_lock(ptl);
> 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
> 		/* Break COW */
>@@ -2675,10 +2684,10 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> 		/* Make the old page be freed below */
> 		new_page = old_page;
> 	}
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
> 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> 	/* Caller expects lock to be held */
>-	spin_lock(&mm->page_table_lock);
>+	spin_lock(ptl);
> 	page_cache_release(new_page);
> 	page_cache_release(old_page);
> 	return 0;
>@@ -2728,6 +2737,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 	struct page *page;
> 	struct address_space *mapping;
> 	pte_t new_pte;
>+	spinlock_t *ptl;
>
> 	/*
> 	 * Currently, we are forced to kill the process in the event the
>@@ -2813,7 +2823,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 			goto backout_unlocked;
> 		}
>
>-	spin_lock(&mm->page_table_lock);
>+	ptl = huge_pte_lockptr(mm, ptep);
>+	spin_lock(ptl);
> 	size = i_size_read(mapping->host) >> huge_page_shift(h);
> 	if (idx >= size)
> 		goto backout;
>@@ -2835,13 +2846,13 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
> 	}
>
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
> 	unlock_page(page);
> out:
> 	return ret;
>
> backout:
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
> backout_unlocked:
> 	unlock_page(page);
> 	put_page(page);
>@@ -2853,6 +2864,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> {
> 	pte_t *ptep;
> 	pte_t entry;
>+	spinlock_t *ptl;
> 	int ret;
> 	struct page *page = NULL;
> 	struct page *pagecache_page = NULL;
>@@ -2921,7 +2933,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 	if (page != pagecache_page)
> 		lock_page(page);
>
>-	spin_lock(&mm->page_table_lock);
>+	ptl = huge_pte_lockptr(mm, ptep);
>+	spin_lock(ptl);
> 	/* Check for a racing update before calling hugetlb_cow */
> 	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
> 		goto out_page_table_lock;
>@@ -2941,7 +2954,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 		update_mmu_cache(vma, address, ptep);
>
> out_page_table_lock:
>-	spin_unlock(&mm->page_table_lock);
>+	spin_unlock(ptl);
>
> 	if (pagecache_page) {
> 		unlock_page(pagecache_page);
>@@ -2976,9 +2989,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 	unsigned long remainder = *nr_pages;
> 	struct hstate *h = hstate_vma(vma);
>
>-	spin_lock(&mm->page_table_lock);
> 	while (vaddr < vma->vm_end && remainder) {
> 		pte_t *pte;
>+		spinlock_t *ptl = NULL;
> 		int absent;
> 		struct page *page;
>
>@@ -2986,8 +2999,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 		 * Some archs (sparc64, sh*) have multiple pte_ts to
> 		 * each hugepage.  We have to make sure we get the
> 		 * first, for the page indexing below to work.
>+		 *
>+		 * Note that page table lock is not held when pte is null.
> 		 */
>-		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
>+		pte = huge_pte_offset_lock(mm, vaddr & huge_page_mask(h), &ptl);
> 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
>
> 		/*
>@@ -2999,6 +3014,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 		 */
> 		if (absent && (flags & FOLL_DUMP) &&
> 		    !hugetlbfs_pagecache_present(h, vma, vaddr)) {
>+			if (pte)
>+				spin_unlock(ptl);
> 			remainder = 0;
> 			break;
> 		}
>@@ -3018,10 +3035,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 		      !huge_pte_write(huge_ptep_get(pte)))) {
> 			int ret;
>
>-			spin_unlock(&mm->page_table_lock);
>+			if (pte)
>+				spin_unlock(ptl);
> 			ret = hugetlb_fault(mm, vma, vaddr,
> 				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
>-			spin_lock(&mm->page_table_lock);
> 			if (!(ret & VM_FAULT_ERROR))
> 				continue;
>
>@@ -3052,8 +3069,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> 			 */
> 			goto same_page;
> 		}
>+		spin_unlock(ptl);
> 	}
>-	spin_unlock(&mm->page_table_lock);
> 	*nr_pages = remainder;
> 	*position = vaddr;
>
>@@ -3074,13 +3091,14 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> 	flush_cache_range(vma, address, end);
>
> 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
>-	spin_lock(&mm->page_table_lock);
> 	for (; address < end; address += huge_page_size(h)) {
>-		ptep = huge_pte_offset(mm, address);
>+		spinlock_t *ptl;
>+		ptep = huge_pte_offset_lock(mm, address, &ptl);
> 		if (!ptep)
> 			continue;
> 		if (huge_pmd_unshare(mm, &address, ptep)) {
> 			pages++;
>+			spin_unlock(ptl);
> 			continue;
> 		}
> 		if (!huge_pte_none(huge_ptep_get(ptep))) {
>@@ -3090,8 +3108,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> 			set_huge_pte_at(mm, address, ptep, pte);
> 			pages++;
> 		}
>+		spin_unlock(ptl);
> 	}
>-	spin_unlock(&mm->page_table_lock);
> 	/*
> 	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
> 	 * may have cleared our pud entry and done put_page on the page table:
>-- 
>1.7.11.7
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
