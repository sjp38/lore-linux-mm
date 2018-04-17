Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A13116B0011
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so201276pfh.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:04 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b7si2783831pfh.257.2018.04.16.19.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:03 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 09/21] mm, THP, swap: Swapin a THP as a whole
Date: Tue, 17 Apr 2018 10:02:18 +0800
Message-Id: <20180417020230.26412-10-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

With this patch, when page fault handler find a PMD swap mapping, it
will swap in a THP as a whole.  This avoids the overhead of
splitting/collapsing before/after the THP swapping.  And improves the
swap performance greatly for reduced page fault count etc.

do_huge_pmd_swap_page() is added in the patch to implement this.  It
is similar to do_swap_page() for normal page swapin.

If failing to allocate a THP, the huge swap cluster and the PMD swap
mapping will be split to fallback to normal page swapin.

If the huge swap cluster has been split already, the PMD swap mapping
will be split to fallback to normal page swapin.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/huge_mm.h |   9 +++
 include/linux/swap.h    |   9 +++
 mm/huge_memory.c        | 171 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c             |  16 ++--
 4 files changed, 199 insertions(+), 6 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0dbfbe34b01a..f5348d072351 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -402,4 +402,13 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifdef CONFIG_THP_SWAP
+extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
+#else /* CONFIG_THP_SWAP */
+static inline int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
+{
+	return 0;
+}
+#endif /* CONFIG_THP_SWAP */
+
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c42e7edcf141..32b9c8df938f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -560,6 +560,15 @@ static inline struct page *lookup_swap_cache(swp_entry_t swp,
 	return NULL;
 }
 
+static inline struct page *read_swap_cache_async(swp_entry_t swp,
+						 gfp_t gft_mask,
+						 struct vm_area_struct *vma,
+						 unsigned long addr,
+						 bool do_poll)
+{
+	return NULL;
+}
+
 static inline int add_to_swap(struct page *page)
 {
 	return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a40e27447cac..f9b3bef2d2f4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -33,6 +33,8 @@
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
+#include <linux/delayacct.h>
+#include <linux/swap.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1612,6 +1614,175 @@ static void __split_huge_swap_pmd(struct vm_area_struct *vma,
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
 }
+
+static int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			       unsigned long address, pmd_t orig_pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
+	int ret = 0;
+
+	ptl = pmd_lock(mm, pmd);
+	if (pmd_same(*pmd, orig_pmd))
+		__split_huge_swap_pmd(vma, address & HPAGE_PMD_MASK, pmd);
+	else
+		ret = -ENOENT;
+	spin_unlock(ptl);
+
+	return ret;
+}
+
+int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
+{
+	struct page *page;
+	struct mem_cgroup *memcg;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
+	swp_entry_t entry;
+	pmd_t pmd;
+	int i, locked, exclusive = 0, ret = 0;
+
+	entry = pmd_to_swp_entry(orig_pmd);
+	VM_BUG_ON(non_swap_entry(entry));
+	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
+retry:
+	page = lookup_swap_cache(entry, NULL, vmf->address);
+	if (!page) {
+		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE, vma,
+					     haddr, false);
+		if (!page) {
+			/*
+			 * Back out if somebody else faulted in this pmd
+			 * while we released the pmd lock.
+			 */
+			if (likely(pmd_same(*vmf->pmd, orig_pmd))) {
+				ret = split_swap_cluster(entry, false);
+				/*
+				 * Retry if somebody else swap in the swap
+				 * entry
+				 */
+				if (ret == -EEXIST) {
+					ret = 0;
+					goto retry;
+				/* swapoff occurs under us */
+				} else if (ret == -EINVAL)
+					ret = 0;
+				else
+					goto fallback;
+			}
+			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+			goto out;
+		}
+
+		/* Had to read the page from swap area: Major fault */
+		ret = VM_FAULT_MAJOR;
+		count_vm_event(PGMAJFAULT);
+		count_memcg_event_mm(vma->vm_mm, PGMAJFAULT);
+	} else if (!PageTransCompound(page))
+		goto fallback;
+
+	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
+
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!locked) {
+		ret |= VM_FAULT_RETRY;
+		goto out_release;
+	}
+
+	/*
+	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not
+	 * release the swapcache from under us.  The page pin, and pmd_same
+	 * test below, are not enough to exclude that.  Even if it is still
+	 * swapcache, we need to check that the page's swap has not changed.
+	 */
+	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
+		goto out_page;
+
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL,
+				  &memcg, true)) {
+		ret = VM_FAULT_OOM;
+		goto out_page;
+	}
+
+	/*
+	 * Back out if somebody else already faulted in this pmd.
+	 */
+	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
+	VM_BUG_ON_VMA(!vma->anon_vma, vma);
+	spin_lock(vmf->ptl);
+	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
+		goto out_nomap;
+
+	if (unlikely(!PageUptodate(page))) {
+		ret = VM_FAULT_SIGBUS;
+		goto out_nomap;
+	}
+
+	/*
+	 * The page isn't present yet, go ahead with the fault.
+	 *
+	 * Be careful about the sequence of operations here.
+	 * To get its accounting right, reuse_swap_page() must be called
+	 * while the page is counted on swap but not yet in mapcount i.e.
+	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
+	 * must be called after the swap_free(), or it will never succeed.
+	 */
+
+	add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	add_mm_counter(vma->vm_mm, MM_SWAPENTS, -HPAGE_PMD_NR);
+	pmd = mk_huge_pmd(page, vma->vm_page_prot);
+	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
+		pmd = maybe_pmd_mkwrite(pmd_mkdirty(pmd), vma);
+		vmf->flags &= ~FAULT_FLAG_WRITE;
+		ret |= VM_FAULT_WRITE;
+		exclusive = RMAP_EXCLUSIVE;
+	}
+	for (i = 0; i < HPAGE_PMD_NR; i++)
+		flush_icache_page(vma, page + i);
+	if (pmd_swp_soft_dirty(orig_pmd))
+		pmd = pmd_mksoft_dirty(pmd);
+	do_page_add_anon_rmap(page, vma, haddr,
+			      exclusive | RMAP_COMPOUND);
+	mem_cgroup_commit_charge(page, memcg, true, true);
+	activate_page(page);
+	set_pmd_at(vma->vm_mm, haddr, vmf->pmd, pmd);
+
+	swap_free(entry, true);
+	if (mem_cgroup_swap_full(page) ||
+	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+		try_to_free_swap(page);
+	unlock_page(page);
+
+	if (vmf->flags & FAULT_FLAG_WRITE) {
+		ret |= do_huge_pmd_wp_page(vmf, pmd);
+		if (ret & VM_FAULT_ERROR)
+			ret &= VM_FAULT_ERROR;
+		goto out;
+	}
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
+	spin_unlock(vmf->ptl);
+out:
+	return ret;
+out_nomap:
+	mem_cgroup_cancel_charge(page, memcg, true);
+	spin_unlock(vmf->ptl);
+out_page:
+	unlock_page(page);
+out_release:
+	put_page(page);
+	return ret;
+fallback:
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!split_huge_swap_pmd(vmf->vma, vmf->pmd, vmf->address, orig_pmd))
+		ret = VM_FAULT_FALLBACK;
+	else
+		ret = 0;
+	if (page)
+		put_page(page);
+	return ret;
+}
 #else
 static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
 					 unsigned long haddr,
diff --git a/mm/memory.c b/mm/memory.c
index 37dc3b15fe11..13e6289f7af4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4063,13 +4063,17 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 		barrier();
 		if (unlikely(is_swap_pmd(orig_pmd))) {
-			VM_BUG_ON(thp_migration_supported() &&
-					  !is_pmd_migration_entry(orig_pmd));
-			if (is_pmd_migration_entry(orig_pmd))
+			if (thp_migration_supported() &&
+			    is_pmd_migration_entry(orig_pmd)) {
 				pmd_migration_entry_wait(mm, vmf.pmd);
-			return 0;
-		}
-		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
+				return 0;
+			} else if (thp_swap_supported()) {
+				ret = do_huge_pmd_swap_page(&vmf, orig_pmd);
+				if (!(ret & VM_FAULT_FALLBACK))
+					return ret;
+			} else
+				VM_BUG_ON(1);
+		} else if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-- 
2.17.0
