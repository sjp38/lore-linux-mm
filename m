Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2036B00A7
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:49 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so906098pab.22
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:49 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uv6si3082252pbc.255.2014.11.05.06.50.45
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:46 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/19] rmap: add argument to charge compound page
Date: Wed,  5 Nov 2014 16:49:40 +0200
Message-Id: <1415198994-15252-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to allow mapping of individual 4k pages of THP compound
page. It means we cannot rely on PageTransHuge() check to decide if map
small page or THP.

The patch adds new argument to rmap function to indicate whethe we want
to map whole compound page or only the small page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h    | 14 +++++++++++---
 kernel/events/uprobes.c |  4 ++--
 mm/filemap_xip.c        |  2 +-
 mm/huge_memory.c        | 16 ++++++++--------
 mm/hugetlb.c            |  4 ++--
 mm/ksm.c                |  4 ++--
 mm/memory.c             | 14 +++++++-------
 mm/migrate.c            |  8 ++++----
 mm/rmap.c               | 46 ++++++++++++++++++++++++++++------------------
 mm/swapfile.c           |  4 ++--
 10 files changed, 67 insertions(+), 49 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index be574506e6a9..ef09ca48c789 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -156,16 +156,24 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
 
 struct anon_vma *page_get_anon_vma(struct page *page);
 
+/* flags for do_page_add_anon_rmap() */
+enum {
+	RMAP_EXCLUSIVE = 1,
+	RMAP_COMPOUND = 2,
+};
+
 /*
  * rmap interfaces called when adding or removing pte of page
  */
 void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
-void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void page_add_anon_rmap(struct page *, struct vm_area_struct *,
+		unsigned long, bool);
 void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
-void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
+		unsigned long, bool);
 void page_add_file_rmap(struct page *);
-void page_remove_rmap(struct page *);
+void page_remove_rmap(struct page *, bool);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 			    unsigned long);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1d0af8a2c646..de133050e948 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -183,7 +183,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		goto unlock;
 
 	get_page(kpage);
-	page_add_new_anon_rmap(kpage, vma, addr);
+	page_add_new_anon_rmap(kpage, vma, addr, false);
 	mem_cgroup_commit_charge(kpage, memcg, false);
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
@@ -196,7 +196,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	pte_unmap_unlock(ptep, ptl);
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3f685c..8f7587e44004 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -193,7 +193,7 @@ retry:
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
-			page_remove_rmap(page);
+			page_remove_rmap(page, false);
 			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 52973809777f..9c53800c4eea 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -748,7 +748,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pmd_t entry;
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		page_add_new_anon_rmap(page, vma, haddr);
+		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
@@ -1048,7 +1048,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
-		page_add_new_anon_rmap(pages[i], vma, haddr);
+		page_add_new_anon_rmap(pages[i], vma, haddr, false);
 		mem_cgroup_commit_charge(pages[i], memcg, false);
 		lru_cache_add_active_or_unevictable(pages[i], vma);
 		pte = pte_offset_map(&_pmd, haddr);
@@ -1060,7 +1060,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	page_remove_rmap(page);
+	page_remove_rmap(page, true);
 	spin_unlock(ptl);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -1180,7 +1180,7 @@ alloc:
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush(vma, haddr, pmd);
-		page_add_new_anon_rmap(new_page, vma, haddr);
+		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -1190,7 +1190,7 @@ alloc:
 			put_huge_zero_page();
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			put_page(page);
 		}
 		ret |= VM_FAULT_WRITE;
@@ -1409,7 +1409,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			put_huge_zero_page();
 		} else {
 			page = pmd_page(orig_pmd);
-			page_remove_rmap(page);
+			page_remove_rmap(page, true);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
@@ -2319,7 +2319,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			 * superfluous.
 			 */
 			pte_clear(vma->vm_mm, address, _pte);
-			page_remove_rmap(src_page);
+			page_remove_rmap(src_page, false);
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
@@ -2615,7 +2615,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
-	page_add_new_anon_rmap(new_page, vma, address);
+	page_add_new_anon_rmap(new_page, vma, address, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eeceeeb09019..dad8e0732922 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2683,7 +2683,7 @@ again:
 		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
+		page_remove_rmap(page, true);
 		force_flush = !__tlb_remove_page(tlb, page);
 		if (force_flush) {
 			spin_unlock(ptl);
@@ -2901,7 +2901,7 @@ retry_avoidcopy:
 		huge_ptep_clear_flush(vma, address, ptep);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
-		page_remove_rmap(old_page);
+		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, address);
 		/* Make the old page be freed below */
 		new_page = old_page;
diff --git a/mm/ksm.c b/mm/ksm.c
index f7de4c07c693..00da250cc560 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -960,13 +960,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	}
 
 	get_page(kpage);
-	page_add_anon_rmap(kpage, vma, addr);
+	page_add_anon_rmap(kpage, vma, addr, false);
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	if (!page_mapped(page))
 		try_to_free_swap(page);
 	put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index 042f8b3cabc1..6f84c8a51cc0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1141,7 +1141,7 @@ again:
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}
-			page_remove_rmap(page);
+			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(!__tlb_remove_page(tlb, page))) {
@@ -2232,7 +2232,7 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address);
+		page_add_new_anon_rmap(new_page, vma, address, false);
 		mem_cgroup_commit_charge(new_page, memcg, false);
 		lru_cache_add_active_or_unevictable(new_page, vma);
 		/*
@@ -2265,7 +2265,7 @@ gotten:
 			 * mapcount is visible. So transitively, TLBs to
 			 * old page will be flushed before it can be reused.
 			 */
-			page_remove_rmap(old_page);
+			page_remove_rmap(old_page, false);
 		}
 
 		/* Free the old page.. */
@@ -2524,7 +2524,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
-		exclusive = 1;
+		exclusive = RMAP_EXCLUSIVE;
 	}
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(orig_pte))
@@ -2534,7 +2534,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		do_page_add_anon_rmap(page, vma, address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
@@ -2672,7 +2672,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto release;
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, address);
+	page_add_new_anon_rmap(page, vma, address, false);
 	mem_cgroup_commit_charge(page, memcg, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
@@ -2757,7 +2757,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		entry = pte_mksoft_dirty(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, vma, address, false);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
 		page_add_file_rmap(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index ad4694515f31..6b9413df1661 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -163,7 +163,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		else
 			page_dup_rmap(new);
 	} else if (PageAnon(new))
-		page_add_anon_rmap(new, vma, addr);
+		page_add_anon_rmap(new, vma, addr, false);
 	else
 		page_add_file_rmap(new);
 
@@ -1863,7 +1863,7 @@ fail_putback:
 	 * guarantee the copy is visible before the pagetable update.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_anon_rmap(new_page, vma, mmun_start);
+	page_add_anon_rmap(new_page, vma, mmun_start, true);
 	pmdp_clear_flush(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
@@ -1873,13 +1873,13 @@ fail_putback:
 		set_pmd_at(mm, mmun_start, pmd, orig_entry);
 		flush_tlb_range(vma, mmun_start, mmun_end);
 		update_mmu_cache_pmd(vma, address, &entry);
-		page_remove_rmap(new_page);
+		page_remove_rmap(new_page, true);
 		goto fail_putback;
 	}
 
 	mem_cgroup_migrate(page, new_page, false);
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, true);
 
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
diff --git a/mm/rmap.c b/mm/rmap.c
index 3e8491c504f8..f706a6af1801 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -973,9 +973,9 @@ static void __page_check_anon_rmap(struct page *page,
  * (but PageKsm is never downgraded to PageAnon).
  */
 void page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address)
+	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
-	do_page_add_anon_rmap(page, vma, address, 0);
+	do_page_add_anon_rmap(page, vma, address, compound ? RMAP_COMPOUND : 0);
 }
 
 /*
@@ -984,21 +984,24 @@ void page_add_anon_rmap(struct page *page,
  * Everybody else should continue to use page_add_anon_rmap above.
  */
 void do_page_add_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address, int exclusive)
+	struct vm_area_struct *vma, unsigned long address, int flags)
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first) {
+		bool compound = flags & RMAP_COMPOUND;
+		int nr = compound ? hpage_nr_pages(page) : 1;
 		/*
 		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
 		 * these counters are not modified in interrupt context, and
 		 * pte lock(a spinlock) is held, which implies preemption
 		 * disabled.
 		 */
-		if (PageTransHuge(page))
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-				hpage_nr_pages(page));
+		}
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1006,7 +1009,8 @@ void do_page_add_anon_rmap(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	/* address might be in next vma when migration races vma_adjust */
 	if (first)
-		__page_set_anon_rmap(page, vma, address, exclusive);
+		__page_set_anon_rmap(page, vma, address,
+				flags & RMAP_EXCLUSIVE);
 	else
 		__page_check_anon_rmap(page, vma, address);
 }
@@ -1022,15 +1026,18 @@ void do_page_add_anon_rmap(struct page *page,
  * Page does not have to be locked.
  */
 void page_add_new_anon_rmap(struct page *page,
-	struct vm_area_struct *vma, unsigned long address)
+	struct vm_area_struct *vma, unsigned long address, bool compound)
 {
+	int nr = compound ? hpage_nr_pages(page) : 1;
+
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	if (PageTransHuge(page))
+	if (compound) {
+		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-			hpage_nr_pages(page));
+	}
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1059,7 +1066,7 @@ void page_add_file_rmap(struct page *page)
  *
  * The caller needs to hold the pte lock.
  */
-void page_remove_rmap(struct page *page)
+void page_remove_rmap(struct page *page, bool compound)
 {
 	bool anon = PageAnon(page);
 	bool locked;
@@ -1089,12 +1096,15 @@ void page_remove_rmap(struct page *page)
 	if (unlikely(PageHuge(page)))
 		goto out;
 	if (anon) {
-		if (PageTransHuge(page))
+		int nr = compound ? hpage_nr_pages(page) : 1;
+		if (compound) {
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			__dec_zone_page_state(page,
-					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-				-hpage_nr_pages(page));
+					NR_ANON_TRANSPARENT_HUGEPAGES);
+		}
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
 	} else {
+		VM_BUG_ON_PAGE(compound, page);
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 		mem_cgroup_end_update_page_stat(page, &locked, &flags);
@@ -1227,7 +1237,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	} else
 		dec_mm_counter(mm, MM_FILEPAGES);
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, false);
 	page_cache_release(page);
 
 out_unmap:
@@ -1374,7 +1384,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
+		page_remove_rmap(page, false);
 		page_cache_release(page);
 		dec_mm_counter(mm, MM_FILEPAGES);
 		(*mapcount)--;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..57252bb35041 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1121,10 +1121,10 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
-		page_add_anon_rmap(page, vma, addr);
+		page_add_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, addr);
+		page_add_new_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
