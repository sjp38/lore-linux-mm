Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFA36B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:04:25 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so28617001pdb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:04:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fo9si14228791pdb.98.2015.04.23.14.04.22
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:04:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 03/28] memcg: adjust to support new THP refcounting
Date: Fri, 24 Apr 2015 00:03:38 +0300
Message-Id: <1429823043-157133-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with rmap, with new refcounting we cannot rely on PageTransHuge() to
check if we need to charge size of huge page form the cgroup. We need to
get information from caller to know whether it was mapped with PMD or
PTE.

We do uncharge when last reference on the page gone. At that point if we
see PageTransHuge() it means we need to unchange whole huge page.

The tricky part is partial unmap -- when we try to unmap part of huge
page. We don't do a special handing of this situation, meaning we don't
uncharge the part of huge page unless last user is gone or
split_huge_page() is triggered. In case of cgroup memory pressure
happens the partial unmapped page will be split through shrinker. This
should be good enough.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/memcontrol.h | 16 +++++++-----
 kernel/events/uprobes.c    |  7 +++---
 mm/filemap.c               |  8 +++---
 mm/huge_memory.c           | 31 ++++++++++++-----------
 mm/memcontrol.c            | 62 +++++++++++++++++-----------------------------
 mm/memory.c                | 26 +++++++++----------
 mm/shmem.c                 | 21 +++++++++-------
 mm/swapfile.c              |  9 ++++---
 8 files changed, 87 insertions(+), 93 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 72dff5fb0d0c..6a70e6c4bece 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -74,10 +74,12 @@ void mem_cgroup_events(struct mem_cgroup *memcg,
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
-			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
+			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
+			  bool compound);
 void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
-			      bool lrucare);
-void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg);
+			      bool lrucare, bool compound);
+void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
+		bool compound);
 void mem_cgroup_uncharge(struct page *page);
 void mem_cgroup_uncharge_list(struct list_head *page_list);
 
@@ -209,7 +211,8 @@ static inline bool mem_cgroup_low(struct mem_cgroup *root,
 
 static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask,
-					struct mem_cgroup **memcgp)
+					struct mem_cgroup **memcgp,
+					bool compound)
 {
 	*memcgp = NULL;
 	return 0;
@@ -217,12 +220,13 @@ static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 
 static inline void mem_cgroup_commit_charge(struct page *page,
 					    struct mem_cgroup *memcg,
-					    bool lrucare)
+					    bool lrucare, bool compound)
 {
 }
 
 static inline void mem_cgroup_cancel_charge(struct page *page,
-					    struct mem_cgroup *memcg)
+					    struct mem_cgroup *memcg,
+					    bool compound)
 {
 }
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 5523daf59953..04e26bdf0717 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -169,7 +169,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	const unsigned long mmun_end   = addr + PAGE_SIZE;
 	struct mem_cgroup *memcg;
 
-	err = mem_cgroup_try_charge(kpage, vma->vm_mm, GFP_KERNEL, &memcg);
+	err = mem_cgroup_try_charge(kpage, vma->vm_mm, GFP_KERNEL, &memcg,
+			false);
 	if (err)
 		return err;
 
@@ -184,7 +185,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	get_page(kpage);
 	page_add_new_anon_rmap(kpage, vma, addr, false);
-	mem_cgroup_commit_charge(kpage, memcg, false);
+	mem_cgroup_commit_charge(kpage, memcg, false, false);
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
@@ -207,7 +208,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
-	mem_cgroup_cancel_charge(kpage, memcg);
+	mem_cgroup_cancel_charge(kpage, memcg, false);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	unlock_page(page);
 	return err;
diff --git a/mm/filemap.c b/mm/filemap.c
index 7aeeb33618bf..ce4d6e3d740f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -555,7 +555,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	if (!huge) {
 		error = mem_cgroup_try_charge(page, current->mm,
-					      gfp_mask, &memcg);
+					      gfp_mask, &memcg, false);
 		if (error)
 			return error;
 	}
@@ -563,7 +563,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
 		if (!huge)
-			mem_cgroup_cancel_charge(page, memcg);
+			mem_cgroup_cancel_charge(page, memcg, false);
 		return error;
 	}
 
@@ -579,7 +579,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
-		mem_cgroup_commit_charge(page, memcg, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
 err_insert:
@@ -587,7 +587,7 @@ err_insert:
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
-		mem_cgroup_cancel_charge(page, memcg);
+		mem_cgroup_cancel_charge(page, memcg, false);
 	page_cache_release(page);
 	return error;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b40fc0ff9315..534f353e12bf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -725,12 +725,12 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, mm, gfp, &memcg))
+	if (mem_cgroup_try_charge(page, mm, gfp, &memcg, true))
 		return VM_FAULT_OOM;
 
 	pgtable = pte_alloc_one(mm, haddr);
 	if (unlikely(!pgtable)) {
-		mem_cgroup_cancel_charge(page, memcg);
+		mem_cgroup_cancel_charge(page, memcg, true);
 		return VM_FAULT_OOM;
 	}
 
@@ -745,7 +745,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_none(*pmd))) {
 		spin_unlock(ptl);
-		mem_cgroup_cancel_charge(page, memcg);
+		mem_cgroup_cancel_charge(page, memcg, true);
 		put_page(page);
 		pte_free(mm, pgtable);
 	} else {
@@ -753,7 +753,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr, true);
-		mem_cgroup_commit_charge(page, memcg, false);
+		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -999,13 +999,14 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					       vma, address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
 			     mem_cgroup_try_charge(pages[i], mm, GFP_KERNEL,
-						   &memcg))) {
+						   &memcg, false))) {
 			if (pages[i])
 				put_page(pages[i]);
 			while (--i >= 0) {
 				memcg = (void *)page_private(pages[i]);
 				set_page_private(pages[i], 0);
-				mem_cgroup_cancel_charge(pages[i], memcg);
+				mem_cgroup_cancel_charge(pages[i], memcg,
+						false);
 				put_page(pages[i]);
 			}
 			kfree(pages);
@@ -1044,7 +1045,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vma, haddr, false);
-		mem_cgroup_commit_charge(pages[i], memcg, false);
+		mem_cgroup_commit_charge(pages[i], memcg, false, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		pte = pte_offset_map(&_pmd, haddr);
 		VM_BUG_ON(!pte_none(*pte));
@@ -1072,7 +1073,7 @@ out_free_pages:
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		mem_cgroup_cancel_charge(pages[i], memcg);
+		mem_cgroup_cancel_charge(pages[i], memcg, false);
 		put_page(pages[i]);
 	}
 	kfree(pages);
@@ -1138,7 +1139,8 @@ alloc:
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, huge_gfp, &memcg))) {
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, huge_gfp,
+					&memcg, true))) {
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
@@ -1167,7 +1169,7 @@ alloc:
 		put_user_huge_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(ptl);
-		mem_cgroup_cancel_charge(new_page, memcg);
+		mem_cgroup_cancel_charge(new_page, memcg, true);
 		put_page(new_page);
 		goto out_mn;
 	} else {
@@ -1176,7 +1178,7 @@ alloc:
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
-		mem_cgroup_commit_charge(new_page, memcg, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache_pmd(vma, address, pmd);
@@ -2493,8 +2495,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   gfp, &memcg)))
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true)))
 		return;
 
 	/*
@@ -2581,7 +2582,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address, true);
-	mem_cgroup_commit_charge(new_page, memcg, false);
+	mem_cgroup_commit_charge(new_page, memcg, false, true);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, address, pmd, _pmd);
@@ -2596,7 +2597,7 @@ out_up_write:
 	return;
 
 out:
-	mem_cgroup_cancel_charge(new_page, memcg);
+	mem_cgroup_cancel_charge(new_page, memcg, true);
 	goto out_up_write;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f2017e37..f659d4f77138 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -827,7 +827,7 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 struct page *page,
-					 int nr_pages)
+					 bool compound, int nr_pages)
 {
 	/*
 	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
@@ -840,9 +840,11 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
 
-	if (PageTransHuge(page))
+	if (compound) {
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
 				nr_pages);
+	}
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
@@ -4740,30 +4742,24 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
  * from old cgroup.
  */
 static int mem_cgroup_move_account(struct page *page,
-				   unsigned int nr_pages,
+				   bool compound,
 				   struct mem_cgroup *from,
 				   struct mem_cgroup *to)
 {
 	unsigned long flags;
+	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
 	int ret;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
-	/*
-	 * The page is isolated from LRU. So, collapse function
-	 * will not handle this page. But page splitting can happen.
-	 * Do this check under compound_page_lock(). The caller should
-	 * hold it.
-	 */
-	ret = -EBUSY;
-	if (nr_pages > 1 && !PageTransHuge(page))
-		goto out;
+	VM_BUG_ON(compound && !PageTransHuge(page));
 
 	/*
 	 * Prevent mem_cgroup_migrate() from looking at page->mem_cgroup
 	 * of its source page while we change it: page migration takes
 	 * both pages off the LRU, but page cache replacement doesn't.
 	 */
+	ret = -EBUSY;
 	if (!trylock_page(page))
 		goto out;
 
@@ -4800,9 +4796,9 @@ static int mem_cgroup_move_account(struct page *page,
 	ret = 0;
 
 	local_irq_disable();
-	mem_cgroup_charge_statistics(to, page, nr_pages);
+	mem_cgroup_charge_statistics(to, page, compound, nr_pages);
 	memcg_check_events(to, page);
-	mem_cgroup_charge_statistics(from, page, -nr_pages);
+	mem_cgroup_charge_statistics(from, page, compound, -nr_pages);
 	memcg_check_events(from, page);
 	local_irq_enable();
 out_unlock:
@@ -5079,7 +5075,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 		if (target_type == MC_TARGET_PAGE) {
 			page = target.page;
 			if (!isolate_lru_page(page)) {
-				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
+				if (!mem_cgroup_move_account(page, true,
 							     mc.from, mc.to)) {
 					mc.precharge -= HPAGE_PMD_NR;
 					mc.moved_charge += HPAGE_PMD_NR;
@@ -5108,7 +5104,8 @@ retry:
 			page = target.page;
 			if (isolate_lru_page(page))
 				goto put;
-			if (!mem_cgroup_move_account(page, 1, mc.from, mc.to)) {
+			if (!mem_cgroup_move_account(page, false,
+						mc.from, mc.to)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
@@ -5456,10 +5453,11 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
  * with mem_cgroup_cancel_charge() in case page instantiation fails.
  */
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
-			  gfp_t gfp_mask, struct mem_cgroup **memcgp)
+			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
+			  bool compound)
 {
 	struct mem_cgroup *memcg = NULL;
-	unsigned int nr_pages = 1;
+	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
 	int ret = 0;
 
 	if (mem_cgroup_disabled())
@@ -5477,11 +5475,6 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			goto out;
 	}
 
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-	}
-
 	if (do_swap_account && PageSwapCache(page))
 		memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
@@ -5517,9 +5510,9 @@ out:
  * Use mem_cgroup_cancel_charge() to cancel the transaction instead.
  */
 void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
-			      bool lrucare)
+			      bool lrucare, bool compound)
 {
-	unsigned int nr_pages = 1;
+	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
 
 	VM_BUG_ON_PAGE(!page->mapping, page);
 	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
@@ -5536,13 +5529,8 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	commit_charge(page, memcg, lrucare);
 
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-	}
-
 	local_irq_disable();
-	mem_cgroup_charge_statistics(memcg, page, nr_pages);
+	mem_cgroup_charge_statistics(memcg, page, compound, nr_pages);
 	memcg_check_events(memcg, page);
 	local_irq_enable();
 
@@ -5564,9 +5552,10 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
  *
  * Cancel a charge transaction started by mem_cgroup_try_charge().
  */
-void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
+void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
+		bool compound)
 {
-	unsigned int nr_pages = 1;
+	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
 
 	if (mem_cgroup_disabled())
 		return;
@@ -5578,11 +5567,6 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 	if (!memcg)
 		return;
 
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-	}
-
 	cancel_charge(memcg, nr_pages);
 }
 
@@ -5836,7 +5820,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	/* XXX: caller holds IRQ-safe mapping->tree_lock */
 	VM_BUG_ON(!irqs_disabled());
 
-	mem_cgroup_charge_statistics(memcg, page, -1);
+	mem_cgroup_charge_statistics(memcg, page, false, -1);
 	memcg_check_events(memcg, page);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index d6171752ea59..559c6651d6b6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2080,7 +2080,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))
+	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false))
 		goto oom_free_new;
 
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
@@ -2109,7 +2109,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address, false);
-		mem_cgroup_commit_charge(new_page, memcg, false);
+		mem_cgroup_commit_charge(new_page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
 		 * We call the notify macro here because, when using secondary
@@ -2148,7 +2148,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		new_page = old_page;
 		page_copied = 1;
 	} else {
-		mem_cgroup_cancel_charge(new_page, memcg);
+		mem_cgroup_cancel_charge(new_page, memcg, false);
 	}
 
 	if (new_page)
@@ -2522,7 +2522,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_page;
 	}
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, false)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
@@ -2564,10 +2564,10 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	set_pte_at(mm, address, page_table, pte);
 	if (page == swapcache) {
 		do_page_add_anon_rmap(page, vma, address, exclusive);
-		mem_cgroup_commit_charge(page, memcg, true);
+		mem_cgroup_commit_charge(page, memcg, true, false);
 	} else { /* ksm created a completely new copy */
 		page_add_new_anon_rmap(page, vma, address, false);
-		mem_cgroup_commit_charge(page, memcg, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
 
@@ -2602,7 +2602,7 @@ unlock:
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_cancel_charge(page, memcg);
+	mem_cgroup_cancel_charge(page, memcg, false);
 	pte_unmap_unlock(page_table, ptl);
 out_page:
 	unlock_page(page);
@@ -2692,7 +2692,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg))
+	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, false))
 		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -2705,7 +2705,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address, false);
-	mem_cgroup_commit_charge(page, memcg, false);
+	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2716,7 +2716,7 @@ unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
 release:
-	mem_cgroup_cancel_charge(page, memcg);
+	mem_cgroup_cancel_charge(page, memcg, false);
 	page_cache_release(page);
 	goto unlock;
 oom_free_page:
@@ -2962,7 +2962,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!new_page)
 		return VM_FAULT_OOM;
 
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false)) {
 		page_cache_release(new_page);
 		return VM_FAULT_OOM;
 	}
@@ -2982,14 +2982,14 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto uncharge_out;
 	}
 	do_set_pte(vma, address, new_page, pte, true, true);
-	mem_cgroup_commit_charge(new_page, memcg, false);
+	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
 	page_cache_release(fault_page);
 	return ret;
 uncharge_out:
-	mem_cgroup_cancel_charge(new_page, memcg);
+	mem_cgroup_cancel_charge(new_page, memcg, false);
 	page_cache_release(new_page);
 	return ret;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 2026b3b8dd28..d0ab2f9e83f6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -706,7 +706,8 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
 	 * Charged back to the user (not to caller) when swap account is used.
 	 */
-	error = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL, &memcg);
+	error = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL, &memcg,
+			false);
 	if (error)
 		goto out;
 	/* No radix_tree_preload: swap entry keeps a place for page in tree */
@@ -729,9 +730,9 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 	if (error) {
 		if (error != -ENOMEM)
 			error = 0;
-		mem_cgroup_cancel_charge(page, memcg);
+		mem_cgroup_cancel_charge(page, memcg, false);
 	} else
-		mem_cgroup_commit_charge(page, memcg, true);
+		mem_cgroup_commit_charge(page, memcg, true, false);
 out:
 	unlock_page(page);
 	page_cache_release(page);
@@ -1114,7 +1115,8 @@ repeat:
 				goto failed;
 		}
 
-		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
+		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg,
+				false);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
 						swp_to_radix_entry(swap));
@@ -1131,14 +1133,14 @@ repeat:
 			 * "repeat": reading a hole and writing should succeed.
 			 */
 			if (error) {
-				mem_cgroup_cancel_charge(page, memcg);
+				mem_cgroup_cancel_charge(page, memcg, false);
 				delete_from_swap_cache(page);
 			}
 		}
 		if (error)
 			goto failed;
 
-		mem_cgroup_commit_charge(page, memcg, true);
+		mem_cgroup_commit_charge(page, memcg, true, false);
 
 		spin_lock(&info->lock);
 		info->swapped--;
@@ -1177,7 +1179,8 @@ repeat:
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
-		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
+		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg,
+				false);
 		if (error)
 			goto decused;
 		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
@@ -1187,10 +1190,10 @@ repeat:
 			radix_tree_preload_end();
 		}
 		if (error) {
-			mem_cgroup_cancel_charge(page, memcg);
+			mem_cgroup_cancel_charge(page, memcg, false);
 			goto decused;
 		}
-		mem_cgroup_commit_charge(page, memcg, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 65825c2687f5..6dd365d1c488 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1103,14 +1103,15 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg, false))
+	{
 		ret = -ENOMEM;
 		goto out_nolock;
 	}
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (unlikely(!maybe_same_pte(*pte, swp_entry_to_pte(entry)))) {
-		mem_cgroup_cancel_charge(page, memcg);
+		mem_cgroup_cancel_charge(page, memcg, false);
 		ret = 0;
 		goto out;
 	}
@@ -1122,10 +1123,10 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
 		page_add_anon_rmap(page, vma, addr, false);
-		mem_cgroup_commit_charge(page, memcg, true);
+		mem_cgroup_commit_charge(page, memcg, true, false);
 	} else { /* ksm created a completely new copy */
 		page_add_new_anon_rmap(page, vma, addr, false);
-		mem_cgroup_commit_charge(page, memcg, false);
+		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
 	swap_free(entry);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
