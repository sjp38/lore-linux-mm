Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id DA5E96B0062
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 10:36:16 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH V2 1/2] mm: Move all mmu notifier invocations to be done outside the PT lock
Date: Thu,  6 Sep 2012 17:34:54 +0300
Message-Id: <1346942095-23927-2-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
References: <20120904150737.a6774600.akpm@linux-foundation.org>
 <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Andrea Arcangeli <andrea@qumranet.com>

From: Sagi Grimberg <sagig@mellanox.com>

In order to allow sleeping during mmu notifier calls, we need to avoid
invoking them under the page table spinlock. This patch solves the
problem by calling invalidate_page notification after releasing
the lock (but before freeing the page itself), or by wrapping the page
invalidation with calls to invalidate_range_begin and
invalidate_range_end.

To prevent accidental changes to the invalidate_range_end arguments after
the call to invalidate_range_begin, the patch introduces a convention of
saving the arguments in consistently named locals:

> unsigned long mmun_start;	/* For mmu_notifiers */
> unsigned long mmun_end;	/* For mmu_notifiers */
>
> ...
>
> mmun_start = ...
> mmun_end = ...
> mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>
> ...
>
> mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);

The patch changes code to use this convention for all calls to
mmu_notifier_invalidate_range_start/end, except those where the calls are
close enough so that anyone who glances at the code can see the values
aren't changing.

This patchset is a preliminary step towards on-demand paging design to be
added to the RDMA stack.

On 05/09/2012 01:06, Andrew Morton wrote:
> Exactly why do we want on-demand paging for Infiniband?

Applications register memory with an RDMA adapter using system calls,
and subsequently post IO operations that refer to the corresponding
virtual addresses directly to HW. Until now, this was achieved by
pinning the memory during the registration calls. The goal of on demand
paging is to avoid pinning the pages of registered memory regions (MRs).
This will allow users the same flexibility they get when swapping any
other part of their processes address spaces. Instead of requiring the
entire MR to fit in physical memory, we can allow the MR to be larger,
and only fit the current working set in physical memory.

> Why should anyone care?  What problems are users currently experiencing?

This can make programming with RDMA much simpler. Today, developers that
are working with more data than their RAM can hold need either to
deregister and reregister memory regions throughout their process's
life, or keep a single memory region and copy the data to it. On demand
paging will allow these developers to register a single MR at the
beginning of their process's life, and let the operating system manage
which pages needs to be fetched at a given time. In the future, we might
be able to provide a single memory access key for each process that
would provide the entire process's address as one large memory region,
and the developers wouldn't need to register memory regions at all.

> Is there any prospect that any other subsystems will utilise these
> infrastructural changes?  If so, which and how, etc?

As for other subsystems, I understand that XPMEM wanted to sleep in MMU
notifiers, as Christoph Lameter wrote at
http://lkml.indiana.edu/hypermail/linux/kernel/0802.1/0460.html
and perhaps Andrea knows about other use cases.

Scheduling in mmu notifications is required since we need to sync the
hardware with the secondary page tables change. A TLB flush of an IO
device is inherently slower than a CPU TLB flush, so our design works by
sending the invalidation request to the device, and waiting for an
interrupt before exiting the mmu notifier handler.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 include/linux/mmu_notifier.h | 47 --------------------------------------------
 mm/filemap_xip.c             |  4 +++-
 mm/huge_memory.c             | 42 +++++++++++++++++++++++++++++++++------
 mm/hugetlb.c                 | 21 ++++++++++++--------
 mm/memory.c                  | 24 +++++++++++++++-------
 mm/mremap.c                  |  8 ++++++--
 mm/rmap.c                    | 18 ++++++++++++++---
 7 files changed, 90 insertions(+), 74 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index ee2baf0..2702bcb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -246,50 +246,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 		__mmu_notifier_mm_destroy(mm);
 }
 
-/*
- * These two macros will sometime replace ptep_clear_flush.
- * ptep_clear_flush is implemented as macro itself, so this also is
- * implemented as a macro until ptep_clear_flush will converted to an
- * inline function, to diminish the risk of compilation failure. The
- * invalidate_page method over time can be moved outside the PT lock
- * and these two macros can be later removed.
- */
-#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
-	__pte;								\
-})
-
-#define pmdp_clear_flush_notify(__vma, __address, __pmdp)		\
-({									\
-	pmd_t __pmd;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
-	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
-					    (__address)+HPAGE_PMD_SIZE);\
-	__pmd = pmdp_clear_flush(___vma, ___address, __pmdp);		\
-	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
-					  (__address)+HPAGE_PMD_SIZE);	\
-	__pmd;								\
-})
-
-#define pmdp_splitting_flush_notify(__vma, __address, __pmdp)		\
-({									\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
-	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
-					    (__address)+HPAGE_PMD_SIZE);\
-	pmdp_splitting_flush(___vma, ___address, __pmdp);		\
-	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
-					  (__address)+HPAGE_PMD_SIZE);	\
-})
-
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
@@ -370,9 +326,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
-#define ptep_clear_flush_notify ptep_clear_flush
-#define pmdp_clear_flush_notify pmdp_clear_flush
-#define pmdp_splitting_flush_notify pmdp_splitting_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 13e013b..a002a6d 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -193,11 +193,13 @@ retry:
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush_notify(vma, address, pte);
+			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page);
 			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
+			/* must invalidate_page _before_ freeing the page */
+			mmu_notifier_invalidate_page(mm, address);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b93..e7b40bc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -832,6 +832,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	pmd_t _pmd;
 	int ret = 0, i;
 	struct page **pages;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
 			GFP_KERNEL);
@@ -868,12 +870,16 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		cond_resched();
 	}
 
+	mmun_start = haddr;
+	mmun_end   = haddr + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON(!PageHead(page));
 
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = get_pmd_huge_pte(mm);
@@ -896,6 +902,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(&mm->page_table_lock);
 
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
 
@@ -904,6 +912,7 @@ out:
 
 out_free_pages:
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		mem_cgroup_uncharge_page(pages[i]);
@@ -920,6 +929,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int ret = 0;
 	struct page *page, *new_page;
 	unsigned long haddr;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	VM_BUG_ON(!vma->anon_vma);
 	spin_lock(&mm->page_table_lock);
@@ -970,20 +981,24 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
+	mmun_start = haddr;
+	mmun_end   = haddr + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	spin_lock(&mm->page_table_lock);
 	put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(&mm->page_table_lock);
 		mem_cgroup_uncharge_page(new_page);
 		put_page(new_page);
-		goto out;
+		goto out_mn;
 	} else {
 		pmd_t entry;
 		VM_BUG_ON(!PageHead(page));
 		entry = mk_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		entry = pmd_mkhuge(entry);
-		pmdp_clear_flush_notify(vma, haddr, pmd);
+		pmdp_clear_flush(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache(vma, address, entry);
@@ -991,10 +1006,14 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(page);
 		ret |= VM_FAULT_WRITE;
 	}
-out_unlock:
 	spin_unlock(&mm->page_table_lock);
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out:
 	return ret;
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return ret;
 }
 
 struct page *follow_trans_huge_pmd(struct mm_struct *mm,
@@ -1207,7 +1226,11 @@ static int __split_huge_page_splitting(struct page *page,
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
 	int ret = 0;
+	/* For mmu_notifiers */
+	const unsigned long mmun_start = address;
+	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
 				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
@@ -1219,10 +1242,11 @@ static int __split_huge_page_splitting(struct page *page,
 		 * and it won't wait on the anon_vma->root->mutex to
 		 * serialize against split_huge_page*.
 		 */
-		pmdp_splitting_flush_notify(vma, address, pmd);
+		pmdp_splitting_flush(vma, address, pmd);
 		ret = 1;
 	}
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	return ret;
 }
@@ -1849,6 +1873,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spinlock_t *ptl;
 	int isolated;
 	unsigned long hstart, hend;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 #ifndef CONFIG_NUMA
@@ -1937,6 +1963,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	ptl = pte_lockptr(mm, pmd);
 
+	mmun_start = address;
+	mmun_end   = address + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	spin_lock(&mm->page_table_lock); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -1944,8 +1973,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * huge and small TLB entries for the same virtual address
 	 * to avoid the risk of CPU bugs in that area.
 	 */
-	_pmd = pmdp_clear_flush_notify(vma, address, pmd);
+	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	spin_lock(ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc72712..aaa3b4b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2355,13 +2355,15 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
+	const unsigned long mmun_start = start;	/* For mmu_notifiers */
+	const unsigned long mmun_end   = end;	/* For mmu_notifiers */
 
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
 	tlb_start_vma(tlb, vma);
-	mmu_notifier_invalidate_range_start(mm, start, end);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 again:
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
@@ -2425,7 +2427,7 @@ again:
 		if (address < end && !ref_page)
 			goto again;
 	}
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	tlb_end_vma(tlb, vma);
 }
 
@@ -2525,6 +2527,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *old_page, *new_page;
 	int avoidcopy;
 	int outside_reserve = 0;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	old_page = pte_page(pte);
 
@@ -2611,6 +2615,9 @@ retry_avoidcopy:
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
 
+	mmun_start = address & huge_page_mask(h);
+	mmun_end   = (address & huge_page_mask(h)) + huge_page_size(h);
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	/*
 	 * Retake the page_table_lock to check for racing updates
 	 * before the page tables are altered
@@ -2619,9 +2626,6 @@ retry_avoidcopy:
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
 		/* Break COW */
-		mmu_notifier_invalidate_range_start(mm,
-			address & huge_page_mask(h),
-			(address & huge_page_mask(h)) + huge_page_size(h));
 		huge_ptep_clear_flush(vma, address, ptep);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
@@ -2629,10 +2633,11 @@ retry_avoidcopy:
 		hugepage_add_new_anon_rmap(new_page, vma, address);
 		/* Make the old page be freed below */
 		new_page = old_page;
-		mmu_notifier_invalidate_range_end(mm,
-			address & huge_page_mask(h),
-			(address & huge_page_mask(h)) + huge_page_size(h));
 	}
+	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	/* Caller expects lock to be held */
+	spin_lock(&mm->page_table_lock);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..fe7948f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1039,6 +1039,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 	int ret;
 
 	/*
@@ -1071,8 +1073,12 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * parent mm. And a permission downgrade will only happen if
 	 * is_cow_mapping() returns true.
 	 */
-	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_start(src_mm, addr, end);
+	if (is_cow_mapping(vma->vm_flags)) {
+		mmun_start = addr;
+		mmun_end   = end;
+		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
+						    mmun_end);
+	}
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1089,8 +1095,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_end(src_mm,
-						  vma->vm_start, end);
+		mmu_notifier_invalidate_range_end(src_mm, mmun_start,
+						  mmun_end);
 	return ret;
 }
 
@@ -2516,7 +2522,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		spinlock_t *ptl, pte_t orig_pte)
 	__releases(ptl)
 {
-	struct page *old_page, *new_page;
+	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int ret = 0;
 	int page_mkwrite = 0;
@@ -2760,10 +2766,14 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
-	if (new_page)
-		page_cache_release(new_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (new_page) {
+		if (new_page == old_page)
+			/* cow happened, notify before releasing old_page */
+			mmu_notifier_invalidate_page(mm, address);
+		page_cache_release(new_page);
+	}
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/mremap.c b/mm/mremap.c
index cc06d0e..0bf94d0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -127,11 +127,15 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
 	bool need_flush = false;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
-	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
+	mmun_start = old_addr;
+	mmun_end   = old_end;
+	mmu_notifier_invalidate_range_start(vma->vm_mm, mmun_start, mmun_end);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
@@ -175,7 +179,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	if (likely(need_flush))
 		flush_tlb_range(vma, old_end-len, old_addr);
 
-	mmu_notifier_invalidate_range_end(vma->vm_mm, old_end-len, old_end);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
 
 	return len + old_addr - old_end;	/* how much done */
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..f0b4d54 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -929,7 +929,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = ptep_clear_flush(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -937,6 +937,9 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+	if (ret)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 }
@@ -1256,7 +1259,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -1318,6 +1321,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	if (ret != SWAP_FAIL)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 
@@ -1382,6 +1387,8 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 	unsigned long end;
 	int ret = SWAP_AGAIN;
 	int locked_vma = 0;
@@ -1405,6 +1412,10 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	if (!pmd_present(*pmd))
 		return ret;
 
+	mmun_start = address;
+	mmun_end   = end;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
 	 * keep the sem while scanning the cluster for mlocking pages.
@@ -1438,7 +1449,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -1454,6 +1465,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
