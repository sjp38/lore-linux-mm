Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 521E86B7EA0
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:41:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s22so1832574pgv.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:41:55 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:41:53 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 09/21] swap: Swapin a THP in one piece
Date: Fri,  7 Dec 2018 13:41:09 +0800
Message-Id: <20181207054122.27822-10-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

With this patch, when page fault handler find a PMD swap mapping, it
will swap in a THP in one piece.  This avoids the overhead of
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
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/huge_mm.h |   9 +++
 mm/huge_memory.c        | 174 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c             |  16 ++--
 3 files changed, 193 insertions(+), 6 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f4dbd0662438..909321c772b5 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -373,4 +373,13 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma,
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
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2004d8ae4390..3bb2df7f5f84 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -34,6 +34,8 @@
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/delayacct.h>
+#include <linux/swap.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1667,6 +1669,178 @@ static void __split_huge_swap_pmd(struct vm_area_struct *vma,
 	pmd_populate(mm, pmd, pgtable);
 }
 
+#ifdef CONFIG_THP_SWAP
+static int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			       unsigned long address, pmd_t orig_pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	spinlock_t *ptl;
+	int ret = 0;
+
+	ptl = pmd_lock(mm, pmd);
+	if (pmd_same(*pmd, orig_pmd))
+		__split_huge_swap_pmd(vma, address, pmd);
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
+				/*
+				 * Failed to allocate huge page, split huge swap
+				 * cluster, and fallback to swapin normal page
+				 */
+				ret = split_swap_cluster(entry, 0);
+				/* Somebody else swapin the swap entry, retry */
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
+	if (mem_cgroup_try_charge_delay(page, vma->vm_mm, GFP_KERNEL,
+					&memcg, true)) {
+		ret = VM_FAULT_OOM;
+		goto out_page;
+	}
+
+	/*
+	 * Back out if somebody else already faulted in this pmd.
+	 */
+	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
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
+	swap_free(entry, HPAGE_PMD_NR);
+	if (mem_cgroup_swap_full(page) ||
+	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+		try_to_free_swap(page);
+	unlock_page(page);
+
+	if (vmf->flags & FAULT_FLAG_WRITE) {
+		spin_unlock(vmf->ptl);
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
+#endif
+
 /*
  * Return true if we do MADV_FREE successfully on entire pmd page.
  * Otherwise, return false.
diff --git a/mm/memory.c b/mm/memory.c
index 35973cc5425b..39b9e9ab412f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3865,13 +3865,17 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 
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
+			} else if (IS_ENABLED(CONFIG_THP_SWAP)) {
+				ret = do_huge_pmd_swap_page(&vmf, orig_pmd);
+				if (!(ret & VM_FAULT_FALLBACK))
+					return ret;
+			} else
+				VM_BUG_ON(1);
+		} else if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-- 
2.18.1
